defmodule Ratdec do
  @moduledoc false

  def main(args) do
    :io.setopts(:standard_io, encoding: :latin1)
    :io.setopts(:standard_error, encoding: :latin1)
    stdin = if Ratdec.CLI.reads_stdin?(args), do: read_stdin(), else: ""
    {status, out, err} = Ratdec.CLI.run(args, stdin)
    IO.binwrite(:stdio, out)
    IO.binwrite(:stderr, err)
    System.halt(status)
  end

  defp read_stdin do
    case IO.binread(:stdio, :eof) do
      data when is_binary(data) -> data
      _ -> ""
    end
  end
end
