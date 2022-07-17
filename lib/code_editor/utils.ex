defmodule CodeEditor.Utils do
  def random_node_aware_id do
    node_part = node_hash(node())
    random_part = :crypto.strong_rand_bytes(9)

    binary = <<node_part::binary, random_part::binary>>
    Base.encode32(binary, case: :lower)
  end

  defp node_hash(node) do
    node_str = Atom.to_string(node)
    :erlang.md5(node_str)
  end
end
