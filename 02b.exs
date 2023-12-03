# 59795

defmodule GameCalculator do
  defmodule Subset do
    defstruct red: 0, green: 0, blue: 0

    def parse(line) do
      line
      |> String.split(", ")
      |> Enum.map(&String.split(&1, " "))
      |> Enum.reduce(%__MODULE__{}, &parse_color/2)
    end

    def max(%__MODULE__{ red: r1, green: g1, blue: b1 }, %__MODULE__{ red: r2, green: g2, blue: b2 }) do
      %__MODULE__{
        red: Kernel.max(r1, r2),
        green: Kernel.max(g1, g2),
        blue: Kernel.max(b1, b2)
      }
    end

    def power(%__MODULE__{ red: red, green: green, blue: blue }) do
      red * green * blue
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

    def power(%__MODULE__{ subsets: subsets }) do
      subsets
      |> Enum.reduce(%Subset{}, &Subset.max/2)
      |> Subset.power()
    end
  end

  def parse(stream) do
    stream
    |> Stream.map(&Game.parse/1)
  end

  def sum(stream) do
    stream
    |> Stream.map(&Game.power/1)
    |> Enum.sum()
  end
end

File.stream!("./inputs/02.txt")
|> Stream.map(&String.trim_trailing/1)
|> GameCalculator.parse()
|> GameCalculator.sum()
|> IO.inspect()
