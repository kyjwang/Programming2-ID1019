defmodule Train do

  # Returns the train containing first n wagons
  def take(_, 0) do [] end
  def take([], _n) do [] end
  def take([head | tail], n) when n > 0 do [head | take(tail, n - 1)] end

  # Returns train without its first n wagons
  def drop([], _n) do [] end
  def drop(train, 0) do train end
  def drop([_head | tail], n) do drop(tail, n - 1) end

  # Combination of two trains
  def append(one, []) do one end
  def append([], two) do two end
  def append([head | tail], two) do [head | append(tail, two)] end

  # Check if wagon is in train
  def member([], _wagon) do false end
  def member([head | tail], wagon) do
    case head == wagon do
      true ->
        true
      _ ->
        member(tail, wagon)
    end
  end

  # Returns first posiont of wagon in train
  def position([head | tail], wagon) do
    case head == wagon do
      true ->
        1
      _ ->
        position(tail, wagon) + 1
    end
  end

  # Return tuple with two trains, wagon not in any of them
  def split(train, wagon) do
    {take(train, position(train, wagon) - 1), drop(train, position(train, wagon))}
  end

  # Return {k, remain, take} where remain & take are wagons of train
  def main([], n) do {n, [], []} end
  def main(train, 0) do {0, train, []} end
  def main([head | tail], n) do
    case main(tail, n) do
      {0, remain, take} ->
        {0, [head | remain], take}
      {k, remain, take} ->
        {k - 1, remain, [head | take]}
      end
  end

  # Possible to do with split/2
  def mainSplit(train, n) do
    {take, remain} = split(train, n)
    {n - length(take), remain, take}
  end
end

defmodule Moves do

  # Move is a binary tuple
  # First element is :one or :two
  # Second element is an integer
  # {:one, 2} or {:two, 1}

  # Decide by pattern-matching which track is involved
  # For a track decide wheter wagons are moved on or from (n + or -)
  # Use main/2 when moving wagons from main track

  def single({_, 0}, {main, one, two}) do {main, one, two} end
  # Move n wagons to track one
  def single({:one, n}, {main, one, two}) when n > 0 do
    {0, remain, take} = Train.main(main, n)
    {remain, Train.append(take, one), two}
    # {take, remain} = Train.split(main, length(main) - n)
    # {take, Train.append(remain, one), two}
  end
  def single({:one, n}, {main, one, two}) when n < 0 do
    n = abs(n)
    {Train.append(main, Train.take(one, n)), Train.drop(one, n), two}
  end
  def single({:two, n}, {main, one, two}) when n > 0 do
    {0, remain, take} = Train.main(main, n)
    {remain, one, Train.append(take, two)}
  end
  def single({:two, n}, {main, one, two}) when n < 0 do
    n = abs(n)
    {Train.append(main, Train.take(two, n)), one, Train.drop(two, n)}
  end

  def sequence([], state) do [state] end
  def sequence([head | tail], state) do
    [state | sequence(tail, single(head, state))]
  end

end

defmodule Shunt do

  def test do
    train = [:a, :b, :c, :d]
    desired = [:c, :b, :d, :a]
    compress(few(train, desired))
  end

  def find([], _) do [] end
  def find(xs, [y | ys]) do
    {hs, ts} = Train.split(xs, y)
    [
      {:one, length(ts) + 1},
      {:two, length(hs)},
      {:one, -(length(ts) + 1)},
      {:two, -length(hs)} |
      find(Train.append(hs, ts), ys)
    ]
  end

  def few([], _) do [] end
  def few([h | hs], [y | ys]) when h == y do
    few(hs, ys)
  end
  def few(hs, [y | ys]) do
    {hs, ts} = Train.split(hs, y)

    [
      {:one, length(ts) + 1},
      {:two, length(hs)},
      {:one, -(length(ts) + 1)},
      {:two, -length(hs)} |
      few(Train.append(hs, ts), ys)
    ]
  end

  def rules([]) do [] end
  def rules([{_, 0} | tail]) do rules(tail) end
  def rules([{:one, n}, {:one, m} | tail]) do rules([{:one, n + m} | tail]) end
  def rules([{:two, n}, {:two, m} | tail]) do rules([{:two, n + m} | tail]) end
  def rules([head | tail]) do [head | rules(tail)] end

  def compress(ms) do
    ns = rules(ms)
    if ns == ms do
      ms
    else
      compress(ns)
    end
  end
end
