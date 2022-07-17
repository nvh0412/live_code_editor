defmodule CodeEditor.Session do
  defstruct [:id, :pid]

  use GenServer, restart: :temporary

  @timeout :infinity

  @impl true
  def init(init_args) do
    {:ok, init_args}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  ### Client APIs
  def get_by_pid(pid) do
    GenServer.call(pid, :describe_self, @timeout)
  end

  def close(pid) do
    GenServer.call(pid, :close, @timeout)
    :ok
  end

  def queue_code_evaluation(session_pid, editor_id) do
  end

  ### Server Implementations
  @impl true
  def handle_call(:describe_self, _from, state) do
    {:reply, self_from_state(state), state}
  end

  @impl true
  def handle_call(:close, _from, state) do
    broadcast_message(state[:session_id], :session_closed)
    {:stop, :shutdown, :ok, state}
  end

  defp self_from_state(state) do
    %__MODULE__{
      id: state[:id],
      pid: self()
    }
  end

  defp broadcast_message(session_id, message) do
    Phoenix.PubSub.broadcast(Livebook.PubSub, "sessions:#{session_id}", message)
  end
end
