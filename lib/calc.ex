defmodule Calc do
  @moduledoc """
  Documentation for Calc.
  """

  @doc """
  Hello world.

  ## Examples

  iex> Calc.hello
  :world

  """

  def main(device \\ :stdio) do
    IO.gets(device, "> ")
    |> eval()
    |> IO.puts()
    main()
  end

  def eval(input) do
    trimmed = input |> String.trim()

    if trimmed |> String.contains?(")") do
      [{firstClosedIndex, firstClosedLength} | restClosed] = Regex.run( ~r/\)/, trimmed, return: :index)

      open =
        Regex.scan(~r/\(/, trimmed, return: :index)
        |> Enum.map(fn ([first | rest]) -> first end)

      Enum.map(open, fn ({i, l}) -> IO.puts(i) end)

      matchingOpen = List.foldl(open, 0, fn ({i, l}, acc) ->
        if i > acc and i < firstClosedIndex do
          i
        else
          acc
        end
      end)

      IO.puts(trimmed)
      IO.puts(Integer.to_string(matchingOpen))
      IO.puts(Integer.to_string(firstClosedIndex))

      eval(String.slice(trimmed, 0, matchingOpen) <>
      eval(String.slice(trimmed, (matchingOpen + 1)..(firstClosedIndex - 1))) <>
      String.slice(trimmed, (firstClosedIndex + 1)..(String.length(trimmed) - 1)))
    else
      parts = trimmed |> String.split(" ")

      if Kernel.length(parts) <= 3 do
        case parts do
          [a, "+", b] ->
            x = String.to_integer(a)
            y = String.to_integer(b)
            Integer.to_string(x + y)
          [a, "-", b] ->
            x = String.to_integer(a)
            y = String.to_integer(b)
            Integer.to_string(x - y)
          [a, "*", b] ->
            x = String.to_integer(a)
            y = String.to_integer(b)
            Integer.to_string(x * y)
          [a, "/", b] ->
            x = String.to_integer(a)
            y = String.to_integer(b)
            Integer.to_string(div(x, y))
            x -> x
        end
      else
        if String.contains?(trimmed, "*") or String.contains?(trimmed, "/") do
          [{firstMultDivIndex, firstMultDivLength} | restClosed] = Regex.run(~r/(\*|\/)/, trimmed, return: :index)

          leftSpace = firstMultDivIndex - 1
          rightSpace = firstMultDivIndex + 1

          IO.puts("left space: " <> Integer.to_string(leftSpace))
          IO.puts("right space: " <> Integer.to_string(rightSpace))

          spaces =
            Regex.scan(~r/\s/, trimmed, return: :index)
            |> Enum.map(fn ([{i, l} | rest]) -> i end)

          Enum.map(spaces, fn (i) -> IO.puts(i) end)

          {left, right} = List.foldl(spaces, {0, String.length(trimmed)}, fn (i, {l, r}) ->
            if i > l and i < leftSpace do
              {i, r}
            else
              if i < r and i > rightSpace do
                {l, i}
              else
                {l, r}
              end
            end
          end)

          IO.puts(trimmed)
          IO.puts(Integer.to_string(left))
          IO.puts(Integer.to_string(right))

          if left == 0 do
            eval(String.slice(trimmed, left..(right - 1))) <>
            String.slice(trimmed, right..(String.length(trimmed)))
            |> eval()
          else
            String.slice(trimmed, 0..left) <>
            eval(String.slice(trimmed, (left + 1)..(right - 1))) <>
            String.slice(trimmed, right..(String.length(trimmed)))
            |> eval()
          end
        else
          [{firstAddSubIndex, firstAddSubLength} | restClosed] = Regex.run(~r/(\+|\-)/, trimmed, return: :index)

          leftSpace = firstAddSubIndex - 1
          rightSpace = firstAddSubIndex + 1

          IO.puts("left space: " <> Integer.to_string(leftSpace))
          IO.puts("right space: " <> Integer.to_string(rightSpace))

          spaces =
            Regex.scan(~r/\s/, trimmed, return: :index)
            |> Enum.map(fn ([{i, l} | rest]) -> i end)

          Enum.map(spaces, fn (i) -> IO.puts(i) end)

          {left, right} = List.foldl(spaces, {0, String.length(trimmed)}, fn (i, {l, r}) ->
            if i > l and i < leftSpace do
              {i, r}
            else
              if i < r and i > rightSpace do
                {l, i}
              else
                {l, r}
              end
            end
          end)

          IO.puts(trimmed)
          IO.puts(Integer.to_string(left))
          IO.puts(Integer.to_string(right))

          if left == 0 do
            eval(String.slice(trimmed, left..(right - 1))) <>
            String.slice(trimmed, right..(String.length(trimmed)))
            |> eval()
          else
            String.slice(trimmed, 0..left) <>
            eval(String.slice(trimmed, (left + 1)..(right - 1))) <>
            String.slice(trimmed, right..(String.length(trimmed)))
            |> eval()
          end
        end
      end
    end
  end
end
