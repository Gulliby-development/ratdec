defmodule Ratdec.SyntaxBTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "evalNamesTheFirstBadToken 12" do
    row(["eval", "1."], "", 1, "", "ratdec: 1.: bad number at column 1\n")
    row(["eval", "0.()"], "", 1, "", "ratdec: 0.(): bad number at column 1\n")
    row(["eval", "0.(3"], "", 1, "", "ratdec: 0.(3: bad number at column 1\n")
    row(["eval", ".5"], "", 1, "", "ratdec: .5: unexpected \".\" at column 1\n")
    row(["eval", "1.2.3"], "", 1, "", "ratdec: 1.2.3: unexpected \".\" at column 4\n")
    row(["eval", "0.(3)(4)"], "", 1, "", "ratdec: 0.(3)(4): unexpected \"(\" at column 6\n")
    row(["eval", "1e3"], "", 1, "", "ratdec: 1e3: unexpected character \"e\" at column 2\n")
    row(["eval", "\t1"], "", 1, "", "ratdec: \t1: unexpected character \"\\x09\" at column 1\n")
    row(["eval", "1+\xc3\xa9"], "", 1, "", "ratdec: 1+\xc3\xa9: unexpected character \"\\xc3\" at column 3\n")
    row(["eval", "2 ^ 0.(a)"], "", 1, "", "ratdec: 2 ^ 0.(a): bad number at column 5\n")
    row(["eval", "11111111111111111111111111111111111111111"], "", 1, "", "ratdec: 11111111111111111111111111111111111111111: number too long at column 1\n")
    row(["eval", "0.1111111111111111111111111111111111111111+2"], "", 0, "21111111111111111111111111111111111111111/10000000000000000000000000000000000000000\n", "")
  end
end
