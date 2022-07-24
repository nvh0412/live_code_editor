defmodule CodeEditor.Session do
  defstruct [:id, :pid]

  use GenServer, restart: :temporary

  alias CodeEditor.{Data, CodeView}

  @timeout :infinity

  @impl true
  def init(init_args) do
    id = Keyword.fetch!(init_args, :id)

    with {:ok, state} <- init_state(id, init_args) do
      {:ok, state}
    else
      {:error, error} -> {:stop, error}
    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  ### Client APIs
  def subscribe(session_id) do
    Phoenix.PubSub.subscribe(CodeEditor.PubSub, "sessions:#{session_id}")
  end

  def get_by_pid(pid) do
    GenServer.call(pid, :describe_self, @timeout)
  end

  def get_data(pid) do
    GenServer.call(pid, :get_data, @timeout)
  end

  def register_client(pid, client_id, user_id) do
    GenServer.call(pid, {:register_client, client_id, user_id}, @timeout)
  end

  def close(pid) do
    GenServer.call(pid, :close, @timeout)
    :ok
  end

  def queue_code_evaluation(session_pid, editor_id) do
    GenServer.cast(session_pid, {:queue_code_evaluation, self(), editor_id})
  end

  def apply_view_delta(session_pid, editor_id, delta) do
    GenServer.cast(session_pid, {:apply_view_delta, self(), editor_id, delta})
  end

  ### Server Implementations
  @impl true
  def handle_call(:describe_self, _from, state) do
    {:reply, self_from_state(state), state}
  end

  @impl true
  def handle_call({:register_client, client_pid, user}, _from, state) do
    Process.monitor(client_pid)

    state = handle_operation(state, {:client_join, client_pid, user})

    {:reply, state.data, state}
  end

  defp self_from_state(state) do
    %__MODULE__{
      id: state[:session_id],
      pid: self()
    }
  end

  @impl true
  def handle_call(:close, _from, state) do
    broadcast_message(state[:session_id], :session_closed)
    {:stop, :shutdown, :ok, state}
  end

  @impl true
  def handle_cast({:queue_code_evaluation, client_pid, editor_id}, state) do
    operation = {:queue_code_evaluation, client_pid, editor_id}
    {:noreply, handle_operation(state, operation)}
  end

  @impl true
  def handle_cast({:apply_view_delta, client_pid, view_id, delta}, state) do
    operation = {:apply_view_delta, client_pid, view_id, delta}
    {:noreply, handle_operation(state, operation)}
  end

  def handle_info(_message, socket), do: {:noreply, socket}

  defp handle_operation(state, operation) do
    broadcast_operation(state.session_id, operation)

    case Data.apply_operation(state.data, operation) do
      {:ok, new_data, actions} ->
        %{state | data: new_data}
        |> after_operation(state, operation)
        |> handle_actions(actions)
      :error ->
        state
    end
  end

  def handle_call(:get_data, _from, state) do
    {:reply, state.data, state}
  end

  def handle_info(_message, state), do: {:noreply, state}

  defp after_operation(state, _prev_state, {:apply_view_delta, client_pid, detal}) do
    state
  end

  defp after_operation(state, _prev_state, _operation), do: state

  defp broadcast_operation(session_id, operation) do
    broadcast_message(session_id, {:operation, operation})
  end

  defp broadcast_message(session_id, message) do
    Phoenix.PubSub.broadcast(CodeEditor.PubSub, "sessions:#{session_id}", message)
  end

  defp handle_actions(state, actions) do
    Enum.reduce(actions, state, &handle_action(&2, &1))
  end

  defp handle_action(state, operation) do
    state
  end

  defp handle_action(state, _action), do: state

  defp init_state(id, opts) do
    with {:ok, data} <- init_data(opts) do
      state = %{
        session_id: id,
        data: data
      }

      {:ok, state}
    end
  end

  defp init_data(opts) do
    codeview = CodeView.new(opts)
    data = Data.new(codeview)

    {:ok, data}
  end

end
