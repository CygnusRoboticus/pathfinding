defmodule Pathfinding.Node do
  @moduledoc """
  Node struct
  """

  alias Pathfinding.{
    Coord,
    Node
  }

  @enforce_keys [:x, :y, :cost, :distance]
  defstruct [:parent, :x, :y, :cost, :distance, visited: false]

  def guess_total_cost(%Node{cost: cost, distance: distance}) do
    cost + distance
  end

  def format_path(%Node{} = node) do
    format_collection([node], node)
    |> Enum.map(fn(node) ->
      %Coord{x: node.x, y: node.y}
    end)
  end
  defp format_collection(collection, %{parent: nil}), do: collection
  defp format_collection(collection, %{parent: parent}) do
    format_collection([parent | collection], parent)
  end
end
