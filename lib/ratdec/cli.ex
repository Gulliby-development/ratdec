defmodule Ratdec.CLI do
  @moduledoc """
  Pure command-line dispatch for ratdec. Expression commands share one parse/evaluate
  pipeline; render_value/2 is the extension boundary for representation formats.
  """

  alias Ratdec.{Eval, Format, Parser}

  @usage "usage: ratdec eval [--as frac|mixed|dec|all] [EXPR...]\n       ratdec cf EXPR\n       ratdec period EXPR\n"
  @formats ["frac", "mixed", "dec", "all"]

  @type response :: {non_neg_integer(), binary(), binary()}

  @spec run([binary()], binary()) :: response()
  def run(args, stdin) when is_list(args) and is_binary(stdin) do
    dispatch(args, stdin)
  end

  @spec reads_stdin?([binary()]) :: boolean()
  def reads_stdin?(["eval"]), do: true
  def reads_stdin?(["eval", "--as", format]) when format in @formats, do: true
  def reads_stdin?(_args), do: false

  defp dispatch([], _stdin), do: {2, "", @usage}
  defp dispatch(["help" | _rest], _stdin), do: {0, @usage, ""}
  defp dispatch(["-h" | _rest], _stdin), do: {0, @usage, ""}
  defp dispatch(["--help" | _rest], _stdin), do: {0, @usage, ""}
  defp dispatch(["--version" | _rest], _stdin), do: {0, "ratdec 0.1.0\n", ""}
  defp dispatch(["eval" | rest], stdin), do: eval_command(rest, stdin)
  defp dispatch(["cf" | rest], _stdin), do: analysis_command("cf", rest)
  defp dispatch(["period" | rest], _stdin), do: analysis_command("period", rest)
  defp dispatch([word | _rest], _stdin), do: {2, "", "ratdec: unknown command #{word}\n"}

  defp eval_command(["--as"], _stdin), do: option_error()

  defp eval_command(["--as", format | expressions], stdin) do
    if format in @formats do
      expressions = if expressions == [], do: stdin_lines(stdin), else: expressions
      evaluate_expressions(expressions, format)
    else
      option_error()
    end
  end

  defp eval_command(expressions, stdin) do
    expressions = if expressions == [], do: stdin_lines(stdin), else: expressions
    evaluate_expressions(expressions, "frac")
  end

  defp option_error, do: {2, "", "ratdec: --as needs one of frac, mixed, dec, all\n"}

  defp analysis_command(command, [expression]) do
    with {:ok, ast} <- Parser.parse(expression),
         {:ok, value} <- Eval.eval(ast) do
      render_analysis(command, value, expression)
    else
      {:error, reason} -> {1, "", expression_error(expression, reason)}
    end
  end

  defp analysis_command(command, _args) do
    {2, "", "ratdec: #{command} needs exactly one EXPR\n"}
  end

  defp evaluate_expressions(expressions, format) do
    {out, err, failed?} =
      Enum.reduce(expressions, {"", "", false}, fn expression, {out, err, failed?} ->
        case evaluate_and_render(expression, format) do
          {:ok, rendered} -> {out <> rendered <> "\n", err, failed?}
          {:error, reason} -> {out, err <> expression_error(expression, reason), true}
        end
      end)

    {if(failed?, do: 1, else: 0), out, err}
  end

  defp evaluate_and_render(expression, format) do
    with {:ok, ast} <- Parser.parse(expression),
         {:ok, value} <- Eval.eval(ast),
         {:ok, rendered} <- render_value(format, value) do
      {:ok, rendered}
    end
  end

  defp render_value(format, value), do: Format.format(value, format)

  defp render_analysis("cf", value, expression) do
    analysis_result(Format.cf(value), expression)
  end

  defp render_analysis("period", value, expression) do
    analysis_result(Format.period(value), expression)
  end

  defp analysis_result({:ok, rendered}, _expression), do: {0, rendered <> "\n", ""}
  defp analysis_result({:error, reason}, expression), do: {1, "", expression_error(expression, reason)}

  defp expression_error(expression, reason), do: "ratdec: #{expression}: #{reason}\n"

  defp stdin_lines(""), do: []

  defp stdin_lines(stdin) do
    lines = :binary.split(stdin, "\n", [:global])
    if List.last(lines) == "", do: Enum.drop(lines, -1), else: lines
  end
end
