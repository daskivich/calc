defmodule Calc do
  @moduledoc """
  A module to emulate a calculator with four integer operations:
  addition, subtraction, multiplication, (integer) division

  intput types:
    paren:
      an input string that contains at least one set of parantheses
    bin_op:
      an input string that contains no parentheses and only one operation
    mult_div:
      an input string that contains no parentheses and more than one operation,
      at least one of which is a multiplication or division
    add_sub:
      an input string that contains no parentheses and multiple addition and/or
      subtraction operations, but no multiplications or divisions

  input validity:
    binary operators must have at least one space around them
    the unary negative operator (e.g., -5) must have no spaces between
    itself and its operand
    multiple supurfluous parentheses must be avoided
  """

  @doc """
  Hello world.

  ## Examples

  iex> Calc.eval("2 * 4 + 5")
  "13"

  iex> Calc.eval("2 * (4 + 5)")
  "18"

  iex> Calc.eval("9 / 2")
  "4"

  iex> Calc.eval(" (  7 * ((3 +    2) - 8))")
  "-21"

  """

  # loop function to run the calculator
  def main(device \\ :stdio) do
    IO.gets(device, "> ")
    |> eval()
    |> IO.puts()
    main()
  end

  # evaluates a line of calculator input
  def eval(input) do
    # format the input string
    formatted = format(input)

    # process input based on its type
    case formatted |> type() do
      :paren ->
        formatted |> eliminateParen()
      :bin_op ->
        formatted |> binOp()
      :mult_div ->
        formatted |> eliminateMultDiv()
      :add_sub ->
        formatted |> eliminateAddSub()
    end
  end

  # formats the given input string appropriately for evaluation
  def format(input) do
    # trim leading/trailing white space
    trimmed = input |> String.trim()

    # change double spaces into single spaces
    singleSpaced = singleSpace(trimmed)

    # delete spaces after open parentheses
    noSpaceOpenParen = Regex.replace(~r/\(\s/, singleSpaced, "(")

    # delete spaces before closing parentheses
    Regex.replace(~r/\s\)/, noSpaceOpenParen, ")")
  end

  # recursive function to elimiate all multiple spaces in given input
  def singleSpace(input) do
    singleSpaced = Regex.replace(~r/\s\s/, input, " ")

    if String.contains?(singleSpaced, "  ") do
      singleSpace(singleSpaced)
    else
      singleSpaced
    end
  end

  # determines the type of input given
  def type(input) do
    cond do
      input |> String.contains?(")") ->
        :paren
      input |> String.split(" ") |> Kernel.length() <= 3 ->
        :bin_op
      input |> String.contains?("*") or input |> String.contains?("/") ->
        :mult_div
      true ->
        :add_sub
    end
  end

  # evaluates the first inner parenthetical operation
  # and then recurses with the replaced value
  def eliminateParen(input) do
    # determine the index of the first closed parenthesis
    [{firstClosedIndex, firstClosedLength} | restClosed] =
      Regex.run( ~r/\)/, input, return: :index)

    # determine the indexes of all opening parentheses
    open =
      Regex.scan(~r/\(/, input, return: :index)
      |> Enum.map(fn ([first | rest]) -> first end)

    # determine the index of the opening paran that matches the first closing
    matchingOpen =
      List.foldl(open, 0, fn ({i, l}, acc) ->
        if i > acc and i < firstClosedIndex do
          i
        else
          acc
        end
      end)

    # evaluate the expression inside the identified parentheses,
    # insert this back into the input string, and recurse
    if matchingOpen == 0 and firstClosedIndex == String.length(input) - 1 do
      eval(String.slice(input, 1..(firstClosedIndex - 1)))
    else
      String.slice(input, 0, matchingOpen) <>
      eval(String.slice(input, (matchingOpen + 1)..(firstClosedIndex - 1))) <>
      String.slice(input, (firstClosedIndex + 1)..(String.length(input) - 1))
      |> eval()
    end
  end

  # evaluates the given binary operation or unary expression
  def binOp(input) do
    case input |> String.split(" ") do
      # addition
      [a, "+", b] ->
        x = String.to_integer(a)
        y = String.to_integer(b)
        Integer.to_string(x + y)
      # subtraction
      [a, "-", b] ->
        x = String.to_integer(a)
        y = String.to_integer(b)
        Integer.to_string(x - y)
      # multiplication
      [a, "*", b] ->
        x = String.to_integer(a)
        y = String.to_integer(b)
        Integer.to_string(x * y)
      # division
      [a, "/", b] ->
        x = String.to_integer(a)
        y = String.to_integer(b)
        Integer.to_string(div(x, y))
      # unary expression
      x ->
        x
    end
  end

  # evaluates the first (from left to right) multiplication
  # or division operation encountered
  # and then recurses with the replaced value
  def eliminateMultDiv(input) do
    # determine the index of the first multiplication or division operator
    [{firstMultDivIndex, firstMultDivLength} | restClosed] =
      Regex.run(~r/(\*|\/)/, input, return: :index)

    # set indexes for spaces surrounding this operator
    leftSpace = firstMultDivIndex - 1
    rightSpace = firstMultDivIndex + 1

    # determine the indexes of all spaces in the input string
    spaces =
      Regex.scan(~r/\s/, input, return: :index)
      |> Enum.map(fn ([{i, l} | rest]) -> i end)

    # determine the indexes delimiting the operation identified
    {left, right} =
      List.foldl(spaces, {0, String.length(input)}, fn (i, {l, r}) ->
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

    # evaluate the identified expression
    # insert this back into the input string, and recurse
    if left == 0 do
      eval(String.slice(input, left..(right - 1))) <>
      String.slice(input, right..(String.length(input)))
      |> eval()
    else
      String.slice(input, 0..left) <>
      eval(String.slice(input, (left + 1)..(right - 1))) <>
      String.slice(input, right..(String.length(input)))
      |> eval()
    end
  end

  # evaluates the first (from left to right) addition
  # or subtraction operation encountered
  # and then recurses with the replaced value
  def eliminateAddSub(input) do
    # determine the index of the first addition or subtraction operator
    [{firstAddSubIndex, firstAddSubLength} | restClosed] =
      Regex.run(~r/(\+\s|\-\s)/, input, return: :index)

    # set indexes for spaces surrounding this operator
    leftSpace = firstAddSubIndex - 1
    rightSpace = firstAddSubIndex + 1

    # determine the indexes of all spaces in the input string
    spaces =
      Regex.scan(~r/\s/, input, return: :index)
      |> Enum.map(fn ([{i, l} | rest]) -> i end)

    # determine the indexes delimiting the operation identified
    {left, right} =
      List.foldl(spaces, {0, String.length(input)}, fn (i, {l, r}) ->
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

    # evaluate the identified expression
    # insert this back into the input string, and recurse
    if left == 0 do
      eval(String.slice(input, left..(right - 1))) <>
      String.slice(input, right..(String.length(input)))
      |> eval()
    else
      String.slice(input, 0..left) <>
      eval(String.slice(input, (left + 1)..(right - 1))) <>
      String.slice(input, right..(String.length(input)))
      |> eval()
    end
  end
end
