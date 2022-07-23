defmodule CodeEditor.Data do
  alias CodeEditor.{CodeView}

  defstruct [:codeview, :clients_map, :view_infos]

  def new(codeview \\ CodeView.new) do
    data = %__MODULE__{
      codeview: codeview,
      clients_map: %{},
      view_infos: initial_view_infos(codeview)
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

  defp with_actions(data, actions \\ []), do: { data, actions }
  defp wrap_ok({data, actions}), do: {:ok, data, actions}

  defp apply_delta({data, _} = data_actions, client_pid, editor_id, delta) do
    IO.inspect data

    editor = String.to_atom(editor_id)
    source_info = data.view_infos[editor].sources

    source_info =
      source_info
      |> Map.update!(:deltas, &(&1 ++ [delta]))
      |> Map.update!(:revision, &(&1 + 1))

    data_actions
    |> update_view_info!(editor, source_info)
    |> add_action({:broadcast_delta, client_pid, editor_id, delta})
  end

  defp update_view_info!({data, _} = data_actions, editor_id, source_info) do
    view_infos = Keyword.replace!(data.view_infos, editor_id, Map.replace(data.view_infos[editor_id], :sources, source_info))
    IO.inspect view_infos
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
      {view.id, new_view_info()}
    end
  end

  defp new_view_info() do
    %{
      sources: new_source_info(),
      eval: new_eval_info()
    }
  end

  defp new_source_info() do
    %{
      revision: 0,
      deltas: []
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
