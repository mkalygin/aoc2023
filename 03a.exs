# 536202

defmodule EngineSchematic do
  @row_length 140

  defmodule Part do
    defstruct value: 0, borders: []

    def parse([top, middle, bottom]) do
      matches = List.flatten(Regex.scan(~r/\d+/, middle))
      positions = List.flatten(Regex.scan(~r/\d+/, middle, return: :index))

      Enum.zip(matches, positions)
      |> Enum.map(fn {match, {match_index, match_length}} ->
        index = max(match_index - 1, 0)
        length = min(match_length + match_index - index + 1, String.length(top) - index)

        borders = [top, middle, bottom]
        |> Enum.map(&String.slice(&1, index, length))
        |> Enum.join()
        |> String.replace(~r/\d|\./, "")
        |> String.graphemes()

        %__MODULE__{
          value: String.to_integer(match),
          borders: borders
        }
      end)
    end

    def valid?(%__MODULE__{ borders: [] }), do: false
    def valid?(%__MODULE__{}), do: true
  end

  def parse(stream) do
    empty = Stream.cycle([String.duplicate(".", @row_length)])

    Stream.concat([Stream.take(empty, 1), stream, Stream.take(empty, 1)])
    |> Stream.chunk_every(3, 1, :discard)
    |> Stream.flat_map(&Part.parse/1)
  end

  def sum(stream) do
    stream
    |> Stream.filter(&Part.valid?/1)
    |> Stream.map(& &1.value)
    |> Enum.sum()
  end
end

File.stream!("./inputs/03.txt")
|> Stream.map(&String.trim_trailing/1)
|> EngineSchematic.parse()
|> EngineSchematic.sum()
|> IO.inspect()
