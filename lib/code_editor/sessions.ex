defmodule CodeEditor.Sessions do
  # This module is responsible for starting and discovering a session
  alias CodeEditor.{Session, Utils}

  def create_session(opts \\ []) do
    id = Utils.random_node_aware_id
    opts = Keyword.put(opts, :id, id)

    case DynamicSupervisor.start_child(CodeEditor.SessionSupervisor, {Session, opts}) do
      {:ok, pid} ->
        session = Session.get_by_pid(pid)

        # Track the session and notify other processes about this new session
        case CodeEditor.Tracker.track_session(session) do
          :ok -> {:ok, session}
          {:error, reason} ->
            Session.close(pid)
            {:error, reason}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  # TODO: How could we handle the message???
  def subscribe do
    Phoenix.PubSub.subscribe(CodeEditor.PubSub, "tracker_sessions")
  end
end
