defmodule GridTest do
  use ExUnit.Case
  alias Pathfinding.{
    Grid
  }
  doctest Grid

  describe "to_coord_map/2" do
    test "converts list of coords to map of coords" do
      coords = [
        %{x: 0, y: 0},
        %{x: 0, y: 1},
        %{x: 0, y: 2},
        %{x: 1, y: 0},
        %{x: 2, y: 0},
        %{x: 2, y: 2}
      ]

      coord_map = Grid.to_coord_map(coords)
      assert coord_map == %{
        0 => %{
          0 => true,
          1 => true,
          2 => true
        },
        1 => %{
          0 => true
        },
        2 => %{
          0 => true,
          2 => true
        }
      }
    end

    test "accepts a default map" do
      coords = [
        %{x: 0, y: 0}
      ]
      default_map = %{
        1 => %{
          0 => false
        }
      }

      coord_map = Grid.to_coord_map(coords, default_map)
      assert coord_map == %{
        0 => %{
          0 => true
        },
        1 => %{
          0 => false
        }
      }
    end

    test "accepts a default value" do
      coords = [
        %{x: 0, y: 0}
      ]

      coord_map = Grid.to_coord_map(coords, %{}, false)
      assert coord_map == %{
        0 => %{
          0 => false
        }
      }
    end
  end
end
