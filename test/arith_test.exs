defmodule Ratdec.ArithTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "evalFollowsPrecedence 12" do
    row(["eval", "1/3+1/6"], "", 0, "1/2\n", "")
    row(["eval", "2/3*3/4"], "", 0, "1/2\n", "")
    row(["eval", "1-5"], "", 0, "-4\n", "")
    row(["eval", "7/2/7"], "", 0, "1/2\n", "")
    row(["eval", "1+2*3-4/2"], "", 0, "5\n", "")
    row(["eval", "(1+2)*(3-4)"], "", 0, "-3\n", "")
    row(["eval", "2^-2"], "", 0, "1/4\n", "")
    row(["eval", "-2^2"], "", 0, "-4\n", "")
    row(["eval", "2^3^2"], "", 0, "512\n", "")
    row(["eval", "--3"], "", 0, "3\n", "")
    row(["eval", "0^0"], "", 0, "1\n", "")
    row(["eval", "1+1", "2*3", "1/4"], "", 0, "2\n6\n1/4\n", "")
  end
end
