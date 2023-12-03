# 2617

defmodule GameValidator do
  defmodule Subset do
    @max_red 12
    @max_green 13
    @max_blue 14

    defstruct red: 0, green: 0, blue: 0

    def parse(line) do
      line
      |> String.split(", ")
      |> Enum.map(&String.split(&1, " "))
      |> Enum.reduce(%__MODULE__{}, &parse_color/2)
    end

    def valid?(%__MODULE__{ red: red, green: green, blue: blue }) do
      red <= @max_red && green <= @max_green && blue <= @max_blue
    end

    defp parse_color([count, "red"], %__MODULE__{} = acc), do: %{acc | red: String.to_integer(count)}
    defp parse_color([count, "green"], %__MODULE__{} = acc), do: %{acc | green: String.to_integer(count)}
    defp parse_color([count, "blue"], %__MODULE__{} = acc), do: %{acc | blue: String.to_integer(count)}
  end

  defmodule Game do
    defstruct id: nil, subsets: []

    def parse(line) do
      [label, rest] = String.split(line, ": ")
      id = Regex.replace(~r/\D/, label, "")

      subsets = rest
      |> String.split("; ")
      |> Enum.map(&Subset.parse/1)

      %__MODULE__{
        id: String.to_integer(id),
        subsets: subsets
      }
    end

    def valid?(%__MODULE__{ subsets: subsets }) do
      !Enum.any?(subsets, & !Subset.valid?(&1))
    end
  end

  def validate(stream) do
    stream
    |> Stream.map(&Game.parse/1)
    |> Stream.filter(&Game.valid?/1)
  end

  def sum(stream) do
    stream
    |> Stream.map(& &1.id)
    |> Enum.sum()
  end
end

File.stream!("./inputs/02.txt")
|> Stream.map(&String.trim_trailing/1)
|> GameValidator.validate()
|> GameValidator.sum()
|> IO.inspect()
