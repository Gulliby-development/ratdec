defmodule Ratdec.DecimalTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "evalAsDecimals 10" do
    row(["eval", "--as", "dec", "5"], "", 0, "5\n", "")
    row(["eval", "--as", "dec", "-1/8"], "", 0, "-0.125\n", "")
    row(["eval", "--as", "dec", "1/3"], "", 0, "0.(3)\n", "")
    row(["eval", "--as", "dec", "-1/6"], "", 0, "-0.1(6)\n", "")
    row(["eval", "--as", "dec", "22/7"], "", 0, "3.(142857)\n", "")
    row(["eval", "--as", "dec", "1/13"], "", 0, "0.(076923)\n", "")
    row(["eval", "--as", "dec", "1/1024"], "", 0, "0.0009765625\n", "")
    row(["eval", "--as", "dec", "-0.(9)"], "", 0, "-1\n", "")
    row(["eval", "--as", "dec", "1/3^64"], "", 1, "", "ratdec: 1/3^64: expansion longer than 200 digits\n")
    row(["eval", "--as", "dec", "1/7+1/1000000"], "", 0, "0.142858(142857)\n", "")
  end
end
