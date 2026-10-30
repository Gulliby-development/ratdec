defmodule Ratdec.MixedTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "evalAsMixedNumbers 9" do
    row(["eval", "--as", "mixed", "7/3"], "", 0, "2 1/3\n", "")
    row(["eval", "--as", "mixed", "-7/3"], "", 0, "-2 1/3\n", "")
    row(["eval", "--as", "mixed", "1/3"], "", 0, "1/3\n", "")
    row(["eval", "--as", "mixed", "-1/3"], "", 0, "-1/3\n", "")
    row(["eval", "--as", "mixed", "-6/3"], "", 0, "-2\n", "")
    row(["eval", "--as", "mixed", "0"], "", 0, "0\n", "")
    row(["eval", "--as", "mixed", "-1000000/3"], "", 0, "-333333 1/3\n", "")
    row(["eval", "--as", "mixed", "0.(142857)"], "", 0, "1/7\n", "")
    row(["eval", "--as", "mixed"], "7/3\n-7/3\n", 0, "2 1/3\n-2 1/3\n", "")
  end
end
