defmodule Pathfinding.Node do
  @moduledoc """
  Node struct
  """

  alias Pathfinding.Node

  @enforce_keys [:x, :y, :cost, :distance]
  defstruct [:parent, :x, :y, :cost, :distance, visited: false]

  def guess_total_cost(%Node{cost: cost, distance: distance}) do
    cost + distance
  end
end
