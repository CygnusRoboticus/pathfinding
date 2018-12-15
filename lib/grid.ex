defmodule Pathfinding.Grid do
  @moduledoc """
  Grid definition to be traversed
  """

  alias Pathfinding.Grid

  @enforce_keys []
  defstruct [
    costs: %{},
    extra_costs: %{},
    walkable_tiles: [],
    unwalkable_coords: %{},
    tiles: []
  ]

  def set_tile_cost(%Grid{costs: costs} = grid, tile, cost) do
    %Grid{grid | costs: Map.put(costs, tile, cost)}
  end

  def get_tile_cost(%Grid{tiles: tiles, costs: costs}, x, y) do
    tile = tiles
      |> Enum.at(y, [])
      |> Enum.at(x)
    costs
    |> Map.get(tile, 1)
  end

  def get_extra_cost(%Grid{extra_costs: extra_costs}, x, y) do
    extra_costs
    |> Map.get(y, %{})
    |> Map.get(x)
  end

  def is_coord_walkable(%Grid{tiles: tiles, walkable_tiles: walkable_tiles, unwalkable_coords: unwalkable_coords}, x, y) do
    tile = tiles |> Enum.at(y, []) |> Enum.at(x)
    case unwalkable_coords |> Map.get(y, %{}) |> Map.get(x) do
      nil -> Enum.member?(walkable_tiles, tile)
      _ -> false
    end
  end

  def add_extra_cost(%Grid{extra_costs: extra_costs} = grid, x, y, cost) do
    case Map.get(extra_costs, y) do
      nil ->
        grid
        |> Map.put(
          :extra_costs,
          extra_costs
          |> Map.put(y, Map.put(%{}, x, cost))
        )
      value ->
        grid
        |> Map.put(
          :extra_costs,
          extra_costs
          |> Map.put(y, Map.put(value, x, cost))
        )
    end
  end

  def remove_extra_cost(%Grid{extra_costs: extra_costs} = grid, x, y) do
    case Map.get(extra_costs, y) do
      nil -> grid
      value ->
        grid
        |> Map.put(
          :extra_costs,
          extra_costs
          |> Map.put(y, Map.delete(value, x))
        )
    end
  end

  def clear_extra_costs(%Grid{} = grid) do
    %Grid{grid | extra_costs: %{}}
  end

  def add_unwalkable_coord(%Grid{unwalkable_coords: unwalkable_coords} = grid, x, y) do
    case Map.get(unwalkable_coords, y) do
      nil ->
        grid
        |> Map.put(
          :unwalkable_coords,
          unwalkable_coords
          |> Map.put(y, Map.put(%{}, x, true))
        )
      value ->
        grid
        |> Map.put(
          :unwalkable_coords,
          unwalkable_coords
          |> Map.put(y, Map.put(value, x, true))
        )
    end
  end

  def remove_unwalkable_coord(%Grid{unwalkable_coords: unwalkable_coords} = grid, x, y) do
    case Map.get(unwalkable_coords, y) do
      nil -> grid
      value ->
        grid
        |> Map.put(
          :unwalkable_coords,
          unwalkable_coords
          |> Map.put(y, Map.delete(value, x))
        )
    end
  end

  def clear_unwalkable_coords(%Grid{} = grid) do
    %Grid{grid | unwalkable_coords: %{}}
  end
end
