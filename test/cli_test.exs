defmodule Ratdec.CliTest do
  use ExUnit.Case, async: true

  import Ratdec.Harness

  test "cliDispatchesTheCommandLine 13" do
    row([], "", 2, "", "usage: ratdec eval [--as frac|mixed|dec|all] [EXPR...]\n       ratdec cf EXPR\n       ratdec period EXPR\n")
    row(["help"], "", 0, "usage: ratdec eval [--as frac|mixed|dec|all] [EXPR...]\n       ratdec cf EXPR\n       ratdec period EXPR\n", "")
    row(["-h", "x"], "", 0, "usage: ratdec eval [--as frac|mixed|dec|all] [EXPR...]\n       ratdec cf EXPR\n       ratdec period EXPR\n", "")
    row(["--help", "eval"], "", 0, "usage: ratdec eval [--as frac|mixed|dec|all] [EXPR...]\n       ratdec cf EXPR\n       ratdec period EXPR\n", "")
    row(["--version"], "", 0, "ratdec 0.1.0\n", "")
    row(["--version", "x"], "", 0, "ratdec 0.1.0\n", "")
    row(["frob"], "", 2, "", "ratdec: unknown command frob\n")
    row(["Eval", "1"], "", 2, "", "ratdec: unknown command Eval\n")
    row([""], "", 2, "", "ratdec: unknown command \n")
    row(["eval", "--as"], "", 2, "", "ratdec: --as needs one of frac, mixed, dec, all\n")
    row(["eval", "--as", "hex", "1"], "", 2, "", "ratdec: --as needs one of frac, mixed, dec, all\n")
    row(["--as", "dec"], "", 2, "", "ratdec: unknown command --as\n")
    row(["eval", "-3"], "", 0, "-3\n", "")
  end
end
