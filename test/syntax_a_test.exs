defmodule Ratdec.SyntaxATest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "evalNamesTheFirstSyntaxError 10" do
    row(["eval", ""], "", 1, "", "ratdec: : empty expression\n")
    row(["eval", "   "], "", 1, "", "ratdec:    : empty expression\n")
    row(["eval", "1+"], "", 1, "", "ratdec: 1+: unexpected end of expression\n")
    row(["eval", "*2"], "", 1, "", "ratdec: *2: unexpected \"*\" at column 1\n")
    row(["eval", "1 2"], "", 1, "", "ratdec: 1 2: unexpected \"2\" at column 3\n")
    row(["eval", "(1+2"], "", 1, "", "ratdec: (1+2: unexpected end of expression\n")
    row(["eval", "1+2)"], "", 1, "", "ratdec: 1+2): unexpected \")\" at column 4\n")
    row(["eval", "2(3)"], "", 1, "", "ratdec: 2(3): unexpected \"(\" at column 2\n")
    row(["eval", "()"], "", 1, "", "ratdec: (): unexpected \")\" at column 2\n")
    row(["eval", "1 + (2 *"], "", 1, "", "ratdec: 1 + (2 *: unexpected end of expression\n")
  end
end
