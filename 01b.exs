# 54431

defmodule CalibrationReader do
  @regex ~r/one|two|three|four|five|six|seven|eight|nine/

  @replacements %{
    "one" => "o1e",
    "two" => "t2o",
    "three" => "t3e",
    "four" => "f4r",
    "five" => "f5e",
    "six" => "s6x",
    "seven" => "s7n",
    "eight" => "e8t",
    "nine" => "n9e"
  }

  def read(stream) do
    stream
    |> Stream.map(&replace_words/1)
    |> Stream.map(&Regex.replace(~r/\D/, &1, ""))
    |> Stream.map(&String.to_integer(String.first(&1) <> String.last(&1)))
  end

  def replace_words(line) do
    line
    |> String.replace(@regex, &Map.get(@replacements, &1, &1))
    |> String.replace(@regex, &Map.get(@replacements, &1, &1))
  end
end

File.stream!("./inputs/01.txt")
|> Stream.map(&String.trim_trailing/1)
|> CalibrationReader.read()
|> Enum.to_list()
|> Enum.sum()
|> IO.inspect()
