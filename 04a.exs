# 24706

defmodule ScratchCardsTeller do
  defmodule ScratchCard do
    defstruct winning: [], actual: [], score: 0

    def parse(line) do
      [winning, actual] = line
      |> String.split(~r/:\s*|\s*\|\s*/)
      |> List.delete_at(0)
      |> Enum.map(&String.split(&1, ~r/\s+/, trim: true))
      |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))

      set = MapSet.new(winning)
      matches = Enum.reduce(actual, 0, &(if MapSet.member?(set, &1), do: &2 + 1, else: &2))
      score = if matches > 0, do: round(:math.pow(2, matches - 1)), else: 0

      %__MODULE__{
        winning: winning,
        actual: actual,
        score: score
      }
    end
  end

  def parse(stream) do
    stream
    |> Stream.map(&ScratchCard.parse/1)
  end

  def sum(stream) do
    stream
    |> Stream.map(& &1.score)
    |> Enum.sum()
  end
end

File.stream!("./inputs/04.txt")
|> Stream.map(&String.trim_trailing/1)
|> ScratchCardsTeller.parse()
|> ScratchCardsTeller.sum()
|> IO.inspect()
