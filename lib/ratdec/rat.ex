defmodule Ratdec.Rat do
  @moduledoc """
  Exact arithmetic for reduced rational values represented as {numerator, denominator}.
  Denominators are positive and zero is always represented as {0, 1}. Literal conversion
  preserves decimal run lengths when constructing powers of ten for finite and repeating values.
  """

  @type rational :: {integer(), pos_integer()}
  @type result :: {:ok, rational()} | {:error, binary()}

  @digit_limit 300

  @spec literal(binary(), binary() | nil, binary() | nil) :: result()
  def literal(integer_digits, fraction_digits, repeat_digits)
      when is_binary(integer_digits) and (is_binary(fraction_digits) or is_nil(fraction_digits)) and
             (is_binary(repeat_digits) or is_nil(repeat_digits)) do
    integer = parse_digits(integer_digits)
    fraction = if fraction_digits, do: parse_digits(fraction_digits), else: 0

    {numerator, denominator} =
      case repeat_digits do
        nil ->
          places = if fraction_digits, do: byte_size(fraction_digits), else: 0
          scale = Integer.pow(10, places)
          {integer * scale + fraction, scale}

        repeat ->
          fraction_places = if fraction_digits, do: byte_size(fraction_digits), else: 0
          repeat_places = byte_size(repeat)
          fraction_scale = Integer.pow(10, fraction_places)
          repeat_scale = Integer.pow(10, repeat_places) - 1
          prefix = integer * fraction_scale + fraction
          {prefix * repeat_scale + parse_digits(repeat), fraction_scale * repeat_scale}
      end

    normalize(numerator, denominator)
  end

  @spec normalize(integer(), integer()) :: result()
  def normalize(_numerator, 0), do: {:error, "division by zero"}

  def normalize(numerator, denominator) when is_integer(numerator) and is_integer(denominator) do
    {numerator, denominator} =
      if denominator < 0, do: {-numerator, -denominator}, else: {numerator, denominator}

    divisor = Integer.gcd(abs(numerator), denominator)
    numerator = div(numerator, divisor)
    denominator = div(denominator, divisor)
    rational = {numerator, denominator}

    if within_limit?(rational), do: {:ok, rational}, else: {:error, "result too large"}
  end

  @spec add(rational(), rational()) :: result()
  def add({left_n, left_d}, {right_n, right_d}) do
    normalize(left_n * right_d + right_n * left_d, left_d * right_d)
  end

  @spec subtract(rational(), rational()) :: result()
  def subtract({left_n, left_d}, {right_n, right_d}) do
    normalize(left_n * right_d - right_n * left_d, left_d * right_d)
  end

  @spec multiply(rational(), rational()) :: result()
  def multiply({left_n, left_d}, {right_n, right_d}) do
    normalize(left_n * right_n, left_d * right_d)
  end

  @spec divide(rational(), rational()) :: result()
  def divide(_left, {0, _right_d}), do: {:error, "division by zero"}

  def divide({left_n, left_d}, {right_n, right_d}) do
    normalize(left_n * right_d, left_d * right_n)
  end

  @spec power(rational(), rational()) :: result()
  def power({base_n, base_d}, {exponent_n, exponent_d}) do
    cond do
      exponent_d != 1 ->
        {:error, "exponent is not an integer"}

      exponent_n < -64 or exponent_n > 64 ->
        {:error, "exponent too large"}

      base_n == 0 and exponent_n < 0 ->
        {:error, "division by zero"}

      exponent_n >= 0 ->
        normalize(Integer.pow(base_n, exponent_n), Integer.pow(base_d, exponent_n))

      true ->
        magnitude = -exponent_n
        normalize(Integer.pow(base_d, magnitude), Integer.pow(base_n, magnitude))
    end
  end

  defp parse_digits(digits) do
    {value, ""} = Integer.parse(digits)
    value
  end

  defp within_limit?({numerator, denominator}) do
    decimal_digits(abs(numerator)) <= @digit_limit and decimal_digits(denominator) <= @digit_limit
  end

  defp decimal_digits(0), do: 1
  defp decimal_digits(integer), do: byte_size(Integer.to_string(integer))
end
