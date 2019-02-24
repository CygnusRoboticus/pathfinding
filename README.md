# Pathfinding

Pathfinding is a simple package for performing 2d [A-star](https://en.wikipedia.org/wiki/A*_search_algorithm) pathfinding in square- and hex-based tile grids.

## Installation

[Available in Hex](https://hex.pm/packages/pathfinding), the package can be installed
by adding `pathfinding` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pathfinding, "~> 0.1.0"}
  ]
end
```

## Basic Usage

```elixir
grid = %Pathfinding.Grid{
  tiles: [
    [1, 1, 0, 1, 1],
    [1, 1, 0, 1, 1],
    [1, 1, 0, 1, 1],
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1]
  ],
  walkable_tiles: [1]
}

Pathfinding.find_path(grid, 1, 2, 3, 2) == [
  %{x: 1, y: 2},
  %{x: 1, y: 3},
  %{x: 2, y: 3},
  %{x: 3, y: 3},
  %{x: 3, y: 2}
]
```

## API Documentation

Documentation can be found at [https://hexdocs.pm/pathfinding](https://hexdocs.pm/pathfinding).
