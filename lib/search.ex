defmodule Pathfinding.Search do
  @moduledoc """
  Search definition to contain traversal information
  """

  alias Pathfinding.{
    Node,
    Search
  }

  @enforce_keys [:start_x, :start_y, :heap]
  defstruct [
    :start_x,
    :start_y,
    :end_x,
    :end_y,
    :cost_threshold,
    :heap,
    cache: %{}
  ]

  def new(start_x, start_y, cost_threshold \\ nil) do
    new(start_x, start_y, nil, nil, cost_threshold)
  end

  def new(start_x, start_y, end_x, end_y, cost_threshold \\ nil) do
    %Search{
      start_x: start_x,
      start_y: start_y,
      end_x: end_x,
      end_y: end_y,
      cost_threshold: cost_threshold,
      heap:
        Heap.new(fn a, b ->
          Node.guess_total_cost(a) < Node.guess_total_cost(b)
        end)
    }
  end

  def push(%Search{heap: heap} = search, node) do
    %Search{
      Search.cache(search, node)
      | heap: Heap.push(heap, node)
    }
  end

  def peek(%Search{heap: heap}) do
    Heap.root(heap)
  end

  def pop(%Search{heap: heap} = search) do
    {node, heap} = Heap.split(heap)
    {node, %Search{search | heap: heap}}
  end

  def size(%Search{heap: heap}) do
    Heap.size(heap)
  end

  def update(%Search{heap: _heap} = search, _node) do
    search
  end

  def traversed_nodes(%Search{cache: cache}) do
    cache
    |> Map.values()
    |> Enum.reduce([], fn map, collection ->
      collection ++ Map.values(map)
    end)
    |> Enum.reverse()
  end

  def cache(%Search{cache: cache} = search, %{x: x, y: y} = node) do
    nested_cache = cache |> Map.get(y, %{})

    cache =
      cache
      |> Map.put(y, Map.put(nested_cache, x, node))

    %Search{search | cache: cache}
  end

  def get_node(%Search{cache: cache}, x, y) do
    cache
    |> Map.get(y, %{})
    |> Map.get(x)
  end
end
