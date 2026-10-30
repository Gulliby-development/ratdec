defmodule Ratdec.AllFormatsTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "evalAsAllThree 6" do
    row(["eval", "--as", "all", "7/3"], "", 0, "7/3 = 2 1/3 = 2.(3)\n", "")
    row(["eval", "--as", "all", "-1/6"], "", 0, "-1/6 = -1/6 = -0.1(6)\n", "")
    row(["eval", "--as", "all", "5"], "", 0, "5 = 5 = 5\n", "")
    row(["eval", "--as", "all", "-22/7"], "", 0, "-22/7 = -3 1/7 = -3.(142857)\n", "")
    row(["eval", "--as", "all", "1/3^64"], "", 1, "", "ratdec: 1/3^64: expansion longer than 200 digits\n")
    row(["eval", "--as", "all", "1/0", "2/3"], "", 1, "2/3 = 2/3 = 0.(6)\n", "ratdec: 1/0: division by zero\n")
  end
end
