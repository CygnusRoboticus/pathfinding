defmodule PathfindingTest do
  use ExUnit.Case
  alias Pathfinding.{
    Grid
  }
  doctest Pathfinding

  describe "find_path" do
    test "only traverses walkable_tiles" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_path(grid, 1, 2, 3, 2)
      assert path == [
        %{x: 1, y: 2},
        %{x: 1, y: 3},
        %{x: 2, y: 3},
        %{x: 3, y: 3},
        %{x: 3, y: 2}
      ]
    end

    test "works with charlists" do
      grid = %Grid{
        tiles: [
          '""\r""',
          '""\r"',
          '""\r""',
          '"""""',
          '"""""'
        ],
        walkable_tiles: [34]
      }

      path = Pathfinding.find_path(grid, 1, 2, 3, 2)
      assert path == [
        %{x: 1, y: 2},
        %{x: 1, y: 3},
        %{x: 2, y: 3},
        %{x: 3, y: 3},
        %{x: 3, y: 2}
      ]
    end

    test "avoids unwalkable_coords" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }
      |> Grid.add_unwalkable_coord(2, 3)
      |> Grid.add_unwalkable_coord(3, 3)

      path = Pathfinding.find_path(grid, 1, 2, 3, 2)
      assert path == [
        %{x: 1, y: 2},
        %{x: 1, y: 3},
        %{x: 1, y: 4},
        %{x: 2, y: 4},
        %{x: 3, y: 4},
        %{x: 4, y: 4},
        %{x: 4, y: 3},
        %{x: 4, y: 2},
        %{x: 3, y: 2}
      ]
    end

    test "early returns when start === end" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_path(grid, 1, 2, 1, 2)
      assert path == []
    end

    test "returns nil when it cannot find a path" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_path(grid, 0, 2, 4, 2)
      assert is_nil(path)
    end

    test "returns nil when target is not walkable" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 0],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_path(grid, 0, 2, 4, 2)
      assert is_nil(path)
    end

    test "returns null when target is unwalkable" do
      grid = %Grid{
        tiles: [
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }
      |> Grid.add_unwalkable_coord(4, 2)

      path = Pathfinding.find_path(grid, 0, 2, 4, 2)
      assert is_nil(path)
    end

    test "returns null when target is unstoppable" do
      grid = %Grid{
        tiles: [
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }
      |> Grid.add_unstoppable_coord(4, 2)

      path = Pathfinding.find_path(grid, 0, 2, 4, 2)
      assert is_nil(path)
    end

    test "prefers straight paths" do
      grid = %Grid{
        tiles: [
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0]
        ],
        walkable_tiles: [0]
      }

      path = Pathfinding.find_path(grid, 0, 2, 4, 2)
      assert path == [
        %{x: 0, y: 2},
        %{x: 1, y: 2},
        %{x: 2, y: 2},
        %{x: 3, y: 2},
        %{x: 4, y: 2}
      ]
    end

    test "respects costs" do
      grid = %Grid{
        tiles: [
          [0, 2, 2, 2, 0],
          [0, 2, 2, 2, 0],
          [0, 2, 2, 2, 0],
          [0, 1, 1, 1, 0],
          [0, 1, 1, 1, 0]
        ],
        walkable_tiles: [0, 1, 2],
      }
      |> Grid.set_tile_cost(2, 4)

      path = Pathfinding.find_path(grid, 0, 2, 4, 2)
      assert path == [
        %{x: 0, y: 2},
        %{x: 0, y: 3},
        %{x: 1, y: 3},
        %{x: 2, y: 3},
        %{x: 3, y: 3},
        %{x: 4, y: 3},
        %{x: 4, y: 2}
      ]
    end

    test "respects extraCosts" do
      grid = %Grid{
        tiles: [
          [0, 2, 2, 2, 0],
          [0, 2, 2, 2, 0],
          [0, 2, 2, 2, 0],
          [0, 1, 1, 1, 0],
          [0, 1, 1, 1, 0]
        ],
        walkable_tiles: [0, 1],
      }
      |> Grid.add_extra_cost(1, 3, 4)
      |> Grid.add_extra_cost(3, 4, 4)

      path = Pathfinding.find_path(grid, 0, 2, 4, 2)
      assert path == [
        %{x: 0, y: 2},
        %{x: 0, y: 3},
        %{x: 0, y: 4},
        %{x: 1, y: 4},
        %{x: 2, y: 4},
        %{x: 2, y: 3},
        %{x: 3, y: 3},
        %{x: 4, y: 3},
        %{x: 4, y: 2}
      ]
    end

    test "cancels early with cost_threshold" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_path(grid, 1, 2, 3, 2, 3)
      assert is_nil(path)
      path = Pathfinding.find_path(grid, 1, 2, 3, 2, 4)
      assert path == [
        %{x: 1, y: 2},
        %{x: 1, y: 3},
        %{x: 2, y: 3},
        %{x: 3, y: 3},
        %{x: 3, y: 2}
      ]
    end

    test "it navigates hex grids" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 0, 1, 0, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1],
        type: :hex
      }

      path = Pathfinding.find_path(grid, 1, 1, 2, 2)
      assert path == [
        %{x: 1, y: 1},
        %{x: 0, y: 2},
        %{x: 0, y: 3},
        %{x: 1, y: 3},
        %{x: 2, y: 2}
      ]
    end

    test "it navigates intercardinal grids" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 0, 1, 0, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1],
        type: :intercardinal
      }

      path = Pathfinding.find_path(grid, 1, 1, 3, 3)
      assert path == [
        %{x: 1, y: 1},
        %{x: 2, y: 2},
        %{x: 3, y: 3}
      ]
    end
  end

  describe "find_walkable" do
    test "only traverses walkable_tiles" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [2, 2, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 2})
      assert path == [
        %{x: 1, y: 2},
        %{x: 0, y: 2},
        %{x: 1, y: 1},
        %{x: 0, y: 1},
        %{x: 1, y: 0},
        %{x: 0, y: 0}
      ]
    end

    test "accepts an alternative input" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [2, 2, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 2})
      assert path == [
        %{x: 1, y: 2},
        %{x: 0, y: 2},
        %{x: 1, y: 1},
        %{x: 0, y: 1},
        %{x: 1, y: 0},
        %{x: 0, y: 0}
      ]
    end

    test "searches from multiple sources" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [2, 2, 2, 2, 2],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_walkable(grid, [
        %{x: 1, y: 2},
        %{x: 4, y: 2}
      ])
      assert path == [
        %{x: 4, y: 2},
        %{x: 3, y: 2},
        %{x: 1, y: 2},
        %{x: 0, y: 2},
        %{x: 4, y: 1},
        %{x: 3, y: 1},
        %{x: 1, y: 1},
        %{x: 0, y: 1},
        %{x: 4, y: 0},
        %{x: 3, y: 0},
        %{x: 1, y: 0},
        %{x: 0, y: 0}
      ]
    end

    test "avoids unwalkable_coords" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1]
        ],
        walkable_tiles: [1]
      }
      |> Grid.add_unwalkable_coord(0, 3)
      |> Grid.add_unwalkable_coord(1, 3)

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 2})
      assert path == [
        %{x: 1, y: 2},
        %{x: 0, y: 2},
        %{x: 1, y: 1},
        %{x: 0, y: 1},
        %{x: 1, y: 0},
        %{x: 0, y: 0}
      ]
    end

    test "avoids unstoppable_coords" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1]
        ],
        walkable_tiles: [1]
      }
      |> Grid.add_unstoppable_coord(0, 3)
      |> Grid.add_unstoppable_coord(1, 3)

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 2})
      assert path == [
        %{x: 1, y: 4},
        %{x: 0, y: 4},
        %{x: 1, y: 3},
        %{x: 0, y: 3},
        %{x: 1, y: 2},
        %{x: 0, y: 2},
        %{x: 1, y: 1},
        %{x: 0, y: 1},
        %{x: 1, y: 0},
        %{x: 0, y: 0}
      ]
    end

    test "cancels early with cost_threshold" do
      grid = %Grid{
        tiles: [
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 0, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 2}, 1)
      assert path == [
        %{x: 1, y: 3},
        %{x: 1, y: 2},
        %{x: 0, y: 2},
        %{x: 1, y: 1}
      ]

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 2}, 4)
      assert path == [
        %{x: 3, y: 4},
        %{x: 2, y: 4},
        %{x: 1, y: 4},
        %{x: 0, y: 4},
        %{x: 4, y: 3},
        %{x: 3, y: 3},
        %{x: 2, y: 3},
        %{x: 1, y: 3},
        %{x: 0, y: 3},
        %{x: 3, y: 2},
        %{x: 1, y: 2},
        %{x: 0, y: 2},
        %{x: 1, y: 1},
        %{x: 0, y: 1},
        %{x: 1, y: 0},
        %{x: 0, y: 0}
      ]
    end

    test "reports the start square when cost_threshold = 0" do
      grid = %Grid{
        tiles: [
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: [1]
      }

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 2}, 0)
      assert path == [
        %{x: 1, y: 2},
      ]
    end

    test "doesn't report own tile when it is not walkable" do
      grid = %Grid{
        tiles: [
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1]
        ],
        walkable_tiles: []
      }

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 2}, 4)
      assert path == []
    end

    test "it navigates hex grids" do
      grid = %Grid{
        tiles: [
          [1, 0, 1, 0, 1],
          [0, 1, 0, 0, 1],
          [1, 0, 1, 0, 1],
          [0, 1, 0, 0, 1],
          [1, 1, 0, 1, 1]
        ],
        walkable_tiles: [1],
        type: :hex
      }

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 1})
      assert path == [
        %{x: 0, y: 2},
        %{x: 1, y: 1},
        %{x: 2, y: 0}
      ]
    end

    test "it navigates intercardinal grids" do
      grid = %Grid{
        tiles: [
          [1, 0, 0, 0, 0],
          [0, 1, 0, 0, 0],
          [0, 1, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [0, 1, 0, 0, 0]
        ],
        walkable_tiles: [1],
        type: :intercardinal
      }

      path = Pathfinding.find_walkable(grid, %{x: 1, y: 1})
      assert path == [
        %{x: 1, y: 4},
        %{x: 0, y: 3},
        %{x: 1, y: 2},
        %{x: 1, y: 1},
        %{x: 0, y: 0}
      ]
    end
  end
end
