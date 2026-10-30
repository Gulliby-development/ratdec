defmodule Ratdec.ContFracTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "cfPrintsTheContinuedFraction 11" do
    row(["cf", "355/113"], "", 0, "[3; 7, 16]\n", "")
    row(["cf", "3"], "", 0, "[3]\n", "")
    row(["cf", "-7/3"], "", 0, "[-3; 1, 2]\n", "")
    row(["cf", "1/2"], "", 0, "[0; 2]\n", "")
    row(["cf", "0"], "", 0, "[0]\n", "")
    row(["cf", "-1/2"], "", 0, "[-1; 2]\n", "")
    row(["cf", "415/93"], "", 0, "[4; 2, 6, 7]\n", "")
    row(["cf", "(1+2"], "", 1, "", "ratdec: (1+2: unexpected end of expression\n")
    row(["cf", "1/0"], "", 1, "", "ratdec: 1/0: division by zero\n")
    row(["cf"], "", 2, "", "ratdec: cf needs exactly one EXPR\n")
    row(["cf", "1", "2"], "", 2, "", "ratdec: cf needs exactly one EXPR\n")
  end
end
