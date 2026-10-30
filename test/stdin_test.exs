defmodule Ratdec.StdinTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "evalReadsLinesFromStandardInput 15" do
    row(["eval"], "1/3\n2+2\n", 0, "1/3\n4\n", "")
    row(["eval"], "1/3\n2+2", 0, "1/3\n4\n", "")
    row(["eval"], "", 0, "", "")
    row(["eval"], "\n\n", 1, "", "ratdec: : empty expression\nratdec: : empty expression\n")
    row(["eval"], "1+1\r\n", 1, "", "ratdec: 1+1\r: unexpected character \"\\x0d\" at column 4\n")
    row(["eval"], "1/0\n1/2\n", 1, "1/2\n", "ratdec: 1/0: division by zero\n")
    row(["eval"], "(1\n\n3\n", 1, "3\n", "ratdec: (1: unexpected end of expression\nratdec: : empty expression\n")
    row(["eval"], "2\xc3\xa9\n", 1, "", "ratdec: 2\xc3\xa9: unexpected character \"\\xc3\" at column 2\n")
    row(["eval", "1/4"], "ignored\n", 0, "1/4\n", "")
    reads(["eval"], true)
    reads(["eval", "--as", "dec"], true)
    reads(["eval", "--as", "hex"], false)
    reads(["eval", "1"], false)
    reads(["cf"], false)
    reads([], false)
  end
end
