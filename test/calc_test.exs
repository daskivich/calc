defmodule CalcTest do
  use ExUnit.Case
  doctest Calc

  test "2 + 3" do
    assert Calc.eval("2 + 3") == "5"
  end

  test "5 * 1" do
    assert Calc.eval("5 * 1") == "5"
  end

  test "20 / 4" do
    assert Calc.eval("20 / 4") == "5"
  end

  test "24 / 6 + (5 - 4)" do
    assert Calc.eval("24 / 6 + (5 - 4)") == "5"
  end

  test "1 + 3 * 3 + 1" do
    assert Calc.eval("1 + 3 * 3 + 1") == "11"
  end

  test "1 - 4 - 5 - 6 - 7" do
    assert Calc.eval("1 - 4 - 5 - 6 - 7") == "-21"
  end

  test "((24 / 6) + 3) * (5 - 4)" do
    assert Calc.eval("((24 / 6) + 3) * (5 - 4)") == "7"
  end

  test "2  + 3" do
    assert Calc.eval("2 + 3") == "5"
  end

  test "5 *  1" do
    assert Calc.eval("5  * 1") == "5"
  end

  test " 5 * 1 " do
    assert Calc.eval(" 5 * 1 ") == "5"
  end

  test "(5 * 2)" do
    assert Calc.eval("(5 * 2)") == "10"
  end

  test "((5 * 2))" do
    assert Calc.eval("(5 * 2)") == "10"
  end

  test "   (   5   *   2   )   " do
    assert Calc.eval("   (   5   *   2   )   ") == "10"
  end

  test "24 / 6 + ( 5 - 4 )" do
    assert Calc.eval("24 / 6 + ( 5 - 4 )") == "5"
  end
end
