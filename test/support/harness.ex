defmodule Ratdec.Harness do
  @moduledoc false

  import ExUnit.Assertions

  # row ARGS STDIN STATUS OUT ERR: runs the command line with STDIN as standard input and compares the exit
  # status, the standard output and the standard error byte for byte.
  def row(args, stdin, status, out, err) do
    assert Ratdec.CLI.run(args, stdin) == {status, out, err}
  end

  # reads ARGS EXPECTED: whether the entry point reads standard input for this command line.
  def reads(args, expected) do
    assert Ratdec.CLI.reads_stdin?(args) == expected
  end
end
