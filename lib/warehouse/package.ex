defmodule Warehouse.Package do
  defstruct [:id, :contents]
  alias Warehouse.Package

  def new(contents) do
    %Package {
      id: generate_package_id(),
      contents: contents,
    }
  end

  def random do
    content_options = ["Bat", "Ball", "Book", "Broom"]
    content_options |> Enum.random |> new
  end

  def random_batch(n), do: Stream.repeatedly(&Package.random/0) |> Enum.take(n)

  # this will generate a string like "MBE56YXTVM"
  # for use as an id.  Use uuid module for actual things
  defp generate_package_id do
    :crypto.strong_rand_bytes(10)
    |> Base.url_encode64
    |> binary_part(0, 10)
    |> String.upcase
    |> String.replace(~r/[-_]/, "X")
  end
end
