defmodule Ratdec.LiteralsTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "evalReadsLiterals 10" do
    row(["eval", "3"], "", 0, "3\n", "")
    row(["eval", "007"], "", 0, "7\n", "")
    row(["eval", "0.5"], "", 0, "1/2\n", "")
    row(["eval", "12.345"], "", 0, "2469/200\n", "")
    row(["eval", "0.(3)"], "", 0, "1/3\n", "")
    row(["eval", "0.1(6)"], "", 0, "1/6\n", "")
    row(["eval", "2.(9)"], "", 0, "3\n", "")
    row(["eval", "1.0(0)"], "", 0, "1\n", "")
    row(["eval", "0.0(01)"], "", 0, "1/990\n", "")
    row(["eval", "  1 / 4 "], "", 0, "1/4\n", "")
  end
end
