defmodule Ratdec.FailuresTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "evalReportsEvaluationErrors 11" do
    row(["eval", "1/0"], "", 1, "", "ratdec: 1/0: division by zero\n")
    row(["eval", "1/(2-2)"], "", 1, "", "ratdec: 1/(2-2): division by zero\n")
    row(["eval", "0^-1"], "", 1, "", "ratdec: 0^-1: division by zero\n")
    row(["eval", "2^0.5"], "", 1, "", "ratdec: 2^0.5: exponent is not an integer\n")
    row(["eval", "2^65"], "", 1, "", "ratdec: 2^65: exponent too large\n")
    row(["eval", "2^-65"], "", 1, "", "ratdec: 2^-65: exponent too large\n")
    row(["eval", "2^64"], "", 0, "18446744073709551616\n", "")
    row(["eval", "(10^64)^5"], "", 1, "", "ratdec: (10^64)^5: result too large\n")
    row(["eval", "10^64*10^64*10^64*10^64*10^64"], "", 1, "", "ratdec: 10^64*10^64*10^64*10^64*10^64: result too large\n")
    row(["eval", "1/0+"], "", 1, "", "ratdec: 1/0+: unexpected end of expression\n")
    row(["eval", "1/0", "1/2", "2^65", "3"], "", 1, "1/2\n3\n", "ratdec: 1/0: division by zero\nratdec: 2^65: exponent too large\n")
  end
end
