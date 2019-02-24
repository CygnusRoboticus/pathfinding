defmodule Pathfinding.Grid do
  @moduledoc """
  Grid definition to be traversed
  """

  alias Pathfinding.Grid

  @enforce_keys []
  defstruct costs: %{},
            extra_costs: %{},
            walkable_tiles: [],
            unwalkable_coords: %{},
            unstoppable_coords: %{},
            tiles: [],
            type: :cardinal # :hex, :intercardinal

  @type t :: %Grid{}

  @spec is_cardinal?(t) :: Boolean.t
  def is_cardinal?(%Grid{type: :cardinal}), do: true
  def is_cardinal?(%Grid{}), do: false

  @spec is_hex?(t) :: Boolean.t
  def is_hex?(%Grid{type: :hex}), do: true
  def is_hex?(%Grid{}), do: false

  @spec is_intercardinal?(t) :: Boolean.t
  def is_intercardinal?(%Grid{type: :intercardinal}), do: true
  def is_intercardinal?(%Grid{}), do: false

  @spec in_grid?(t, Number.t, Number.t) :: Boolean.t
  def in_grid?(%Grid{}, x, y) when x < 0 or y < 0, do: false
  def in_grid?(%Grid{tiles: tiles}, x, y) do
    case y < length(tiles) do
      false ->
        true

      true ->
        row = Enum.at(tiles, y)
        x < length(row)
    end
  end

  @spec is_coord_stoppable?(t, Number.t, Number.t) :: Boolean.t
  def is_coord_stoppable?(%Grid{unstoppable_coords: unstoppable_coords} = grid, x, y) do
    case unstoppable_coords |> Map.get(y, %{}) |> Map.get(x) do
      nil -> Grid.is_coord_walkable?(grid, x, y)
      _ -> false
    end
  end

  @spec is_coord_walkable?(t, Number.t, Number.t) :: Boolean.t
  def is_coord_walkable?(
        %Grid{tiles: tiles, walkable_tiles: walkable_tiles, unwalkable_coords: unwalkable_coords},
        x,
        y
      ) do
    tile = tiles |> Enum.at(y, []) |> Enum.at(x)

    case unwalkable_coords |> Map.get(y, %{}) |> Map.get(x) do
      nil -> Enum.member?(walkable_tiles, tile)
      _ -> false
    end
  end

  @doc """
  Converts a list of coordinates into a map of nested coordinates.
  """
  @spec to_coord_map([%{x: Number.t, y: Number.t}, ...], Map.t, Boolean.t) :: Map.t
  def to_coord_map(coords, map \\ %{}, value \\ true) when is_list(coords) do
    coords
    |> Enum.reduce(map, fn %{x: x, y: y}, coord_map ->
      coord_map
      |> Map.put(
        y,
        coord_map
        |> Map.get(y, %{})
        |> Map.put(x, value)
      )
    end)
  end

  @spec get_coord_cost(t, Number.t, Number.t) :: Number.t
  def get_coord_cost(%Grid{tiles: tiles, costs: costs} = grid, x, y) do
    case Grid.get_extra_cost(grid, x, y) do
      nil ->
        tile = tiles |> Enum.at(y, []) |> Enum.at(x)

        costs
        |> Map.get(tile, 1)

      extra_cost ->
        extra_cost
    end
  end

  @spec set_tile_cost(t, Number.t, Number.t) :: t
  def set_tile_cost(%Grid{costs: costs} = grid, tile, cost) do
    %Grid{grid | costs: Map.put(costs, tile, cost)}
  end

  @spec get_extra_cost(t, Number.t, Number.t) :: Number.t
  def get_extra_cost(%Grid{extra_costs: extra_costs}, x, y) do
    extra_costs
    |> Map.get(y, %{})
    |> Map.get(x)
  end

  @spec add_extra_cost(t, Number.t, Number.t, Number.t) :: t
  def add_extra_cost(%Grid{extra_costs: extra_costs} = grid, x, y, cost) do
    add_coord(grid, :extra_costs, extra_costs, x, y, cost)
  end

  @spec remove_extra_cost(t, Number.t, Number.t) :: t
  def remove_extra_cost(%Grid{extra_costs: extra_costs} = grid, x, y) do
    remove_coord(grid, :extra_costs, extra_costs, x, y)
  end

  @spec clear_extra_costs(t) :: t
  def clear_extra_costs(%Grid{} = grid) do
    clear_coords(grid, :extra_costs)
  end

  @spec add_unwalkable_coord(t, Number.t, Number.t) :: t
  def add_unwalkable_coord(%Grid{unwalkable_coords: unwalkable_coords} = grid, x, y) do
    add_coord(grid, :unwalkable_coords, unwalkable_coords, x, y)
  end

  @spec remove_unwalkable_coord(t, Number.t, Number.t) :: t
  def remove_unwalkable_coord(%Grid{unwalkable_coords: unwalkable_coords} = grid, x, y) do
    remove_coord(grid, :unwalkable_coords, unwalkable_coords, x, y)
  end

  @spec clear_unwalkable_coords(t) :: t
  def clear_unwalkable_coords(%Grid{} = grid) do
    clear_coords(grid, :unwalkable_coords)
  end

  @spec add_unstoppable_coord(t, Number.t, Number.t) :: t
  def add_unstoppable_coord(%Grid{unstoppable_coords: unstoppable_coords} = grid, x, y) do
    add_coord(grid, :unstoppable_coords, unstoppable_coords, x, y)
  end

  @spec remove_unstoppable_coord(t, Number.t, Number.t) :: t
  def remove_unstoppable_coord(%Grid{unstoppable_coords: unstoppable_coords} = grid, x, y) do
    remove_coord(grid, :unstoppable_coords, unstoppable_coords, x, y)
  end

  @spec clear_unstoppable_coords(t) :: t
  def clear_unstoppable_coords(%Grid{} = grid) do
    clear_coords(grid, :unstoppable_coords)
  end

  defp add_coord(%Grid{} = grid, key, coords, x, y, value \\ true) do
    case Map.get(coords, y) do
      nil ->
        grid
        |> Map.put(
          key,
          coords
          |> Map.put(y, Map.put(%{}, x, value))
        )

      nested ->
        grid
        |> Map.put(
          key,
          coords
          |> Map.put(y, Map.put(nested, x, value))
        )
    end
  end

  defp remove_coord(%Grid{} = grid, key, coords, x, y) do
    case Map.get(coords, y) do
      nil ->
        grid

      value ->
        grid
        |> Map.put(
          key,
          coords
          |> Map.put(y, Map.delete(value, x))
        )
    end
  end

  defp clear_coords(%Grid{} = grid, key) do
    grid
    |> Map.put(key, %{})
  end
end
