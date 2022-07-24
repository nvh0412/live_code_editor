defmodule CodeEditor.TestHelpers do
  alias CodeEditor.Data

  def data_after_operations!(data \\ Data.new(), operations) do
    operations
    |> List.flatten()
    |> Enum.reduce(data, fn operation, data ->
      case Data.apply_operation(data, operation) do
        {:ok, data, _action} ->
          data

        :error ->
          raise "failed to set up test data, operation #{inspect(operation)} returned an error"
      end
    end)
  end
end
