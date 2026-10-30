defmodule Ratdec.PeriodTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "periodCountsDecimalDigits 10" do
    row(["period", "1/7"], "", 0, "pre=0 period=6\n", "")
    row(["period", "1/6"], "", 0, "pre=1 period=1\n", "")
    row(["period", "1/8"], "", 0, "pre=3 period=0\n", "")
    row(["period", "5"], "", 0, "pre=0 period=0\n", "")
    row(["period", "-1/12"], "", 0, "pre=2 period=1\n", "")
    row(["period", "1/97"], "", 0, "pre=0 period=96\n", "")
    row(["period", "1/3^64"], "", 1, "", "ratdec: 1/3^64: expansion longer than 10000 digits\n")
    row(["period", "0.1(6)"], "", 0, "pre=1 period=1\n", "")
    row(["period", "1/"], "", 1, "", "ratdec: 1/: unexpected end of expression\n")
    row(["period"], "", 2, "", "ratdec: period needs exactly one EXPR\n")
  end
end
