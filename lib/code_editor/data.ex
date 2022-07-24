defmodule CodeEditor.Data do
  alias CodeEditor.{CodeView}

  defstruct [:codeview, :clients_map, :view_infos, :users_map]

  def new(codeview \\ CodeView.new) do
    data = %__MODULE__{
      codeview: codeview,
      view_infos: initial_view_infos(codeview),
      clients_map: %{},
      users_map: %{}
    }

    data
  end

  def apply_operation(data, operation)
  def apply_operation(data, {:queue_code_evaluation, client_pid, editor_id}) do
    {:ok, data, []}
  end
  def apply_operation(data, {:apply_view_delta, client_pid, editor_id, delta}) do
    data
    |> with_actions()
    |> apply_delta(client_pid, editor_id, delta)
    |> wrap_ok()
  end

  def apply_operation(data, {:client_join, client_pid, user}) do
    with false <- Map.has_key?(data.clients_map, client_pid) do
      data
      |> with_actions()
      |> client_join(client_pid, user)
      |> wrap_ok()
    else
      _ -> :error
    end
  end

  defp with_actions(data, actions \\ []), do: { data, actions }
  defp wrap_ok({data, actions}), do: {:ok, data, actions}

  defp client_join({data, _} = data_actions, client_pid, user) do
    data_actions
    |> set!(
      clients_map: Map.put(data.clients_map, client_pid, user.id),
      users_map: Map.put(data.users_map, user.id, user)
    )
    |> update_every_view_info(fn
      %{sources: _} = info ->
        update_in(
          info.sources,
          &(put_in(&1.revision_by_client_pid[client_pid], &1.revision))
        )
      info -> info
    end)
  end

  defp apply_delta({data, _} = data_actions, client_pid, editor_id, delta) do
    editor = String.to_atom(editor_id)
    source_info = data.view_infos[editor].sources

    source_info =
      source_info
      |> Map.update!(:deltas, &(&1 ++ [delta]))
      |> Map.update!(:revision, &(&1 + 1))

    source_info =
      if Map.has_key?(source_info.revision_by_client_pid, client_pid) do
        put_in(source_info.revision_by_client_pid[client_pid], source_info.revision)
        |> purge_deltas()
      else
        source_info
      end

    data_actions
    |> update_view_info!(editor, source_info)
    |> add_action({:broadcast_delta, client_pid, editor_id, delta})
  end

  defp purge_deltas(source_info) do
    min_client_revision =
      source_info.revision_by_client_pid
      |> Map.values()
      |> Enum.min(fn -> source_info.revision end)

    necessary_deltas = source_info.revision - min_client_revision
    deltas = Enum.take(source_info.deltas, -necessary_deltas)

    put_in(source_info.deltas, deltas)
  end

  defp update_view_info!({data, _} = data_actions, editor_id, source_info) do
    new_view_info = Map.replace(data.view_infos[editor_id], :sources, source_info)

    view_infos = Map.replace!(
      data.view_infos,
      editor_id,
      new_view_info
    )

    set!(data_actions, view_infos: view_infos)
  end

  defp update_every_view_info({data, _} = data_actions, fun) do
    view_infos =
      Map.new(data.view_infos, fn {view_id, info} ->
        {view_id, fun.(info)}
      end)

    set!(data_actions, view_infos: view_infos)
  end

  defp set!({data, actions}, changes) do
    changes
    |> Enum.reduce(data, fn {key, value}, info ->
      Map.replace!(info, key, value)
    end)
    |> with_actions(actions)
  end

  defp add_action({data, actions}, action) do
    {data, actions ++ [action]}
  end

  defp initial_view_infos(codeview) do
    for view <- CodeView.all_views(codeview) do
      {view.id, new_view_info(%{})}
    end
  end

  defp new_view_info(clients_map) do
    %{
      sources: new_source_info(clients_map),
      eval: new_eval_info()
    }
  end

  defp new_source_info(clients_map) do
    client_pids = Map.keys(clients_map)

    %{
      revision: 0,
      deltas: [],
      revision_by_client_pid: Map.new(client_pids, &{&1, 0})
    }
  end

  defp new_eval_info() do
    %{
      status: :ready,
      evaluation_time_ms: nil,
      evaluation_start: nil,
      evaluation_number: 0
    }
  end
end
