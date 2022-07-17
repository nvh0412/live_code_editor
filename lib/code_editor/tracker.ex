defmodule CodeEditor.Tracker do
  use Phoenix.Tracker

  @name __MODULE__
  @sessions_topic "sessions"

  @impl true
  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
  end

  def start_link(opts) do
    opts = Keyword.merge([name: __MODULE__], opts)

    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def handle_diff(diff, state) do
    for {topic, topic_diff} <- diff do
      handle_topic_diff(topic, topic_diff, state)
    end

    {:ok, state}
  end

  def track_session(session) do
    case Phoenix.Tracker.track(@name, session.pid, @sessions_topic, session.id, %{
      session: session
    }) do
      {:ok, _ref} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def list_sessions do
    presences = Phoenix.Tracker.list(@name, @sessions_topic)
    for {_id, %{session: session}} <- presences, do: session
  end

  defp handle_topic_diff(@sessions_topic, {joins, leaves}, state) do
    joins = Map.new(joins)
    leaves = Map.new(leaves)

    messages =
      for id <- Enum.uniq(Map.keys(joins) ++ Map.keys(leaves)) do
        case {joins[id], leaves[:id]} do
          {%{session: session}, nil} -> {:session_created, session}
          {nil, %{session: session}} -> {:session_closed, session}
          {%{session: session}, %{}} -> {:session_updated, session}
        end
      end

    for message <- messages do
      Phoenix.PubSub.direct_broadcast!(
        state.node_name,
        state.pubsub_server,
        "tracker_sessions",
        message
      )
    end
  end
end
