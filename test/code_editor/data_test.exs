defmodule CodeEditor.DataTest do
  use ExUnit.Case, async: true

  import CodeEditor.TestHelpers

  alias CodeEditor.Data
  alias CodeEditor.Users.User

  describe "apply_operation/2 given :client_join" do
    test "returns an error if the given process is already a client" do
      user = User.new()

      data =
        data_after_operations!([
          {:client_join, self(), user}
        ])

      operation = {:client_join, self(), user}
      assert :error = Data.apply_operation(data, operation)
    end

    test "adds the given process and user to their corresponding maps" do
      client_pid = self()

      %{id: user_id} = user = User.new
      data = Data.new

      operation = {:client_join, client_pid, user}

      assert {
        :ok,
        %{
          clients_map: %{^client_pid => ^user_id},
          users_map: %{^user_id => ^user}
        },
        []
      } = Data.apply_operation(data, operation)
    end
  end
end
