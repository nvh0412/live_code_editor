defmodule CodeEditor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CodeEditor.Repo,
      # Start the Telemetry supervisor
      CodeEditorWeb.Telemetry,
      # Start the DynamicSupervisor to manage Session
      {DynamicSupervisor, name: CodeEditor.SessionSupervisor, strategy: :one_for_one},
      # Start the PubSub system
      {Phoenix.PubSub, name: CodeEditor.PubSub},
      # Start the Tracker server
      {CodeEditor.Tracker, pubsub_server: CodeEditor.PubSub},
      # Start the Endpoint (http/https)
      CodeEditorWeb.Endpoint
      # Start a worker by calling: CodeEditor.Worker.start_link(arg)
      # {CodeEditor.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CodeEditor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CodeEditorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
