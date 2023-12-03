# 55477

File.stream!("./inputs/01.txt")
|> Stream.map(&String.trim_trailing/1)
|> Stream.map(&Regex.replace(~r/\D/, &1, ""))
|> Stream.map(&String.to_integer(String.first(&1) <> String.last(&1)))
|> Enum.to_list()
|> Enum.sum()
|> IO.inspect()
