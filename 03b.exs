# 78272573

defmodule EngineSchematic do
  @row_length 140

  defmodule Part do
    defstruct value: 0, start: 0, end: 0

    def parse(line) do
      matches = List.flatten(Regex.scan(~r/\d+/, line))
      positions = List.flatten(Regex.scan(~r/\d+/, line, return: :index))

      Enum.zip(matches, positions)
      |> Enum.map(fn {match, {index, length}} ->
        %__MODULE__{
          value: String.to_integer(match),
          start: index,
          end: index + length - 1,
        }
      end)
    end

    def adjacent?(%__MODULE__{ start: s, end: e }, i, length) do
      is = max(i - 1, 0)
      ie = min(i + 1, length - 1)

      s <= ie && is <= e
    end
  end

  defmodule Gear do
    @parts_count 2

    defstruct ratio: 0, parts: []

    def parse([top, middle, bottom]) do
      Regex.scan(~r/\*+/, middle, return: :index)
      |> List.flatten()
      |> Enum.map(fn {index, _} ->
        parts = [top, middle, bottom]
        |> Enum.flat_map(&Part.parse/1)
        |> Enum.filter(&Part.adjacent?(&1, index, String.length(top)))

        ratio = Enum.reduce(parts, 1, & &1.value * &2)

        %__MODULE__{
          ratio: ratio,
          parts: parts
        }
      end)
    end

    def valid?(%__MODULE__{ parts: parts }), do: length(parts) == @parts_count
  end

  def parse(stream) do
    empty = Stream.cycle([String.duplicate(".", @row_length)])

    Stream.concat([Stream.take(empty, 1), stream, Stream.take(empty, 1)])
    |> Stream.chunk_every(3, 1, :discard)
    |> Stream.flat_map(&Gear.parse/1)
  end

  def sum(stream) do
    stream
    |> Stream.filter(&Gear.valid?/1)
    |> Stream.map(& &1.ratio)
    |> Enum.sum()
  end
end

File.stream!("./inputs/03.txt")
|> Stream.map(&String.trim_trailing/1)
|> EngineSchematic.parse()
|> EngineSchematic.sum()
|> IO.inspect()
