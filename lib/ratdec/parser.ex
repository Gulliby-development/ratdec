defmodule Ratdec.Parser do
  @moduledoc """
  Parses expressions as bytes and returns an AST shared with Ratdec.Eval.

  AST nodes are {:number, integer_digits, fraction_digits_or_nil, repeat_digits_or_nil},
  {:unary, :+ | :-, ast}, and {:binary, :+ | :- | :* | :/ | :^, left, right}.
  Digit runs remain binaries so their original spelling and leading zeros are preserved.
  """

  @type ast ::
          {:number, binary(), binary() | nil, binary() | nil}
          | {:unary, :+ | :-, ast()}
          | {:binary, :+ | :- | :* | :/ | :^, ast(), ast()}

  @spec parse(binary()) :: {:ok, ast()} | {:error, binary()}
  def parse(text) when is_binary(text) do
    state = %{text: text, size: byte_size(text)}
    start = skip_spaces(state, 0)

    if start == state.size do
      {:error, "empty expression"}
    else
      with {:ok, ast, pos} <- parse_expr(state, start),
           pos <- skip_spaces(state, pos),
           true <- pos == state.size do
        {:ok, ast}
      else
        {:error, _} = error -> error
        false -> {:error, token_error(state, skip_spaces(state, parse_end(state, start)))}
      end
    end
  end

  # Internal parser functions return the next byte offset alongside each node.
  defp parse_end(state, start) do
    case parse_expr(state, start) do
      {:ok, _ast, pos} -> pos
      {:error, _} -> state.size
    end
  end

  defp parse_expr(state, pos) do
    with {:ok, left, next} <- parse_term(state, skip_spaces(state, pos)) do
      parse_sum_tail(state, left, next)
    end
  end

  defp parse_sum_tail(state, left, pos) do
    at = skip_spaces(state, pos)

    case byte(state, at) do
      ?+ -> continue_sum(state, left, at, :+, at + 1)
      ?- -> continue_sum(state, left, at, :-, at + 1)
      _ -> {:ok, left, pos}
    end
  end

  defp continue_sum(state, left, _at, op, pos) do
    with {:ok, right, next} <- parse_term(state, skip_spaces(state, pos)) do
      parse_sum_tail(state, {:binary, op, left, right}, next)
    end
  end

  defp parse_term(state, pos) do
    with {:ok, left, next} <- parse_unary(state, pos) do
      parse_product_tail(state, left, next)
    end
  end

  defp parse_product_tail(state, left, pos) do
    at = skip_spaces(state, pos)

    case byte(state, at) do
      ?* -> continue_product(state, left, :*, at + 1)
      ?/ -> continue_product(state, left, :/, at + 1)
      _ -> {:ok, left, pos}
    end
  end

  defp continue_product(state, left, op, pos) do
    with {:ok, right, next} <- parse_unary(state, skip_spaces(state, pos)) do
      parse_product_tail(state, {:binary, op, left, right}, next)
    end
  end

  defp parse_unary(state, pos) do
    at = skip_spaces(state, pos)

    case byte(state, at) do
      ?+ -> unary_child(state, :+, at + 1)
      ?- -> unary_child(state, :-, at + 1)
      _ -> parse_power(state, at)
    end
  end

  defp unary_child(state, op, pos) do
    with {:ok, child, next} <- parse_unary(state, skip_spaces(state, pos)) do
      {:ok, {:unary, op, child}, next}
    end
  end

  defp parse_power(state, pos) do
    with {:ok, left, next} <- parse_atom(state, pos) do
      at = skip_spaces(state, next)

      if byte(state, at) == ?^ do
        with {:ok, right, end_pos} <- parse_unary(state, skip_spaces(state, at + 1)) do
          {:ok, {:binary, :^, left, right}, end_pos}
        end
      else
        {:ok, left, next}
      end
    end
  end

  defp parse_atom(state, pos) do
    at = skip_spaces(state, pos)

    case byte(state, at) do
      c when c in ?0..?9 ->
        parse_number(state, at)

      ?( ->
        with {:ok, ast, next} <- parse_expr(state, at + 1) do
          close = skip_spaces(state, next)

          if byte(state, close) == ?) do
            {:ok, ast, close + 1}
          else
            {:error, token_error(state, close)}
          end
        end

      _ ->
        {:error, token_error(state, at)}
    end
  end

  defp parse_number(state, start) do
    int_end = scan_digits(state, start)

    case byte(state, int_end) do
      ?. -> parse_decimal_number(state, start, int_end)
      _ -> finish_number(state, start, int_end, nil, nil, int_end)
    end
  end

  defp parse_decimal_number(state, start, point) do
    fraction_start = point + 1
    fraction_end = scan_digits(state, fraction_start)

    case byte(state, fraction_end) do
      ?( -> parse_repeating_number(state, start, point, fraction_start, fraction_end)
      _ when fraction_end == fraction_start -> {:error, "bad number at column #{start + 1}"}
      _ -> finish_number(state, start, scan_digits(state, start), binary_part(state.text, fraction_start, fraction_end - fraction_start), nil, fraction_end)
    end
  end

  defp parse_repeating_number(state, start, point, fraction_start, fraction_end) do
    repeat_start = fraction_end + 1
    repeat_end = scan_digits(state, repeat_start)

    if repeat_end == repeat_start or byte(state, repeat_end) != ?) do
      {:error, "bad number at column #{start + 1}"}
    else
      integer_end = point
      fraction = if fraction_end == fraction_start, do: nil, else: binary_part(state.text, fraction_start, fraction_end - fraction_start)
      repeat = binary_part(state.text, repeat_start, repeat_end - repeat_start)
      finish_number(state, start, integer_end, fraction, repeat, repeat_end + 1)
    end
  end

  defp finish_number(state, start, int_end, fraction, repeat, next) do
    integer = binary_part(state.text, start, int_end - start)
    runs = [integer, fraction, repeat] |> Enum.reject(&is_nil/1)

    if Enum.any?(runs, &(byte_size(&1) > 40)) do
      {:error, "number too long at column #{start + 1}"}
    else
      {:ok, {:number, integer, fraction, repeat}, next}
    end
  end

  defp scan_digits(state, pos) do
    if digit?(byte(state, pos)), do: scan_digits(state, pos + 1), else: pos
  end

  defp digit?(c), do: c >= ?0 and c <= ?9

  defp skip_spaces(state, pos) do
    if byte(state, pos) == 32, do: skip_spaces(state, pos + 1), else: pos
  end

  defp byte(state, pos) when pos < state.size, do: :binary.at(state.text, pos)
  defp byte(_state, _pos), do: nil

  defp token_error(state, pos) do
    case byte(state, pos) do
      nil ->
        "unexpected end of expression"

      c when c in [?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?., ?(, ?), ?+, ?-, ?*, ?/, ?^] ->
        "unexpected #{quoted_byte(c)} at column #{pos + 1}"

      c ->
        "unexpected character #{quoted_byte(c)} at column #{pos + 1}"
    end
  end

  defp quoted_byte(c) when c >= 32 and c <= 126, do: <<34, c, 34>>
  defp quoted_byte(c), do: <<34, "\\x", hex(div(c, 16)), hex(rem(c, 16)), 34>>
  defp hex(n) when n < 10, do: ?0 + n
  defp hex(n), do: ?a + n - 10
end
