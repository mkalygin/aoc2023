# 13114317

defmodule ScratchCardsTeller do
  defmodule ScratchCard do
    defstruct winning: [], actual: [], matches: 0

    def parse(line) do
      [winning, actual] = line
      |> String.split(~r/:\s*|\s*\|\s*/)
      |> List.delete_at(0)
      |> Enum.map(&String.split(&1, ~r/\s+/, trim: true))
      |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))

      set = MapSet.new(winning)
      matches = Enum.reduce(actual, 0, &(if MapSet.member?(set, &1), do: &2 + 1, else: &2))

      %__MODULE__{
        winning: winning,
        actual: actual,
        matches: matches
      }
    end

    def tally({%__MODULE__{ matches: 0 }, index}, counts) do
      Map.update(counts, index, 1, & &1 + 1)
    end
    def tally({%__MODULE__{ matches: matches }, index}, counts) do
      counts = Map.update(counts, index, 1, & &1 + 1)
      count = Map.get(counts, index)

      (index + 1)..(index + matches)
      |> Enum.reduce(counts, fn key, acc ->
        Map.update(acc, key, count, & &1 + count)
      end)
    end
  end

  def parse(stream) do
    stream
    |> Stream.map(&ScratchCard.parse/1)
  end

  def sum(stream) do
    stream
    |> Stream.with_index()
    |> Enum.reduce(%{}, &ScratchCard.tally/2)
    |> Map.values()
    |> Enum.sum()
  end
end

File.stream!("./inputs/04.txt")
|> Stream.map(&String.trim_trailing/1)
|> ScratchCardsTeller.parse()
|> ScratchCardsTeller.sum()
|> IO.inspect()
