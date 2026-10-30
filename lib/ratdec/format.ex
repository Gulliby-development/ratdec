defmodule Ratdec.Format do
  @moduledoc "Exact textual representations and decimal analysis for rational values."

  alias Ratdec.Rat

  @type result :: {:ok, binary()} | {:error, binary()}

  @spec format(Rat.rational(), binary()) :: result()
  def format(pair, "frac"), do: {:ok, fraction(pair)}
  def format(pair, "mixed"), do: {:ok, mixed(pair)}
  def format(pair, "dec"), do: decimal(pair, 200)

  def format(pair, "all") do
    with {:ok, decimal} <- decimal(pair, 200) do
      {:ok, Enum.join([fraction(pair), mixed(pair), decimal], " = ")}
    end
  end

  @spec cf(Rat.rational()) :: result()
  def cf({numerator, denominator}) do
    [first | rest] = continued_fraction(numerator, denominator, [])

    rendered =
      case rest do
        [] -> "[#{first}]"
        _ -> "[#{first}; #{Enum.join(rest, ", ")}]"
      end

    {:ok, rendered}
  end

  @spec period(Rat.rational()) :: result()
  def period({numerator, denominator}) do
    remainder = rem(abs(numerator), denominator)

    if remainder == 0 do
      {:ok, "pre=0 period=0"}
    else
      case traverse(remainder, denominator, 10_000) do
        {:ok, digits, nil} ->
          {:ok, "pre=#{byte_size(digits)} period=0"}

        {:ok, _digits, {prefix_length, cycle_length}} ->
          {:ok, "pre=#{prefix_length} period=#{cycle_length}"}

        {:error, _reason} = error ->
          error
      end
    end
  end

  defp fraction({numerator, 1}), do: Integer.to_string(numerator)
  defp fraction({numerator, denominator}), do: "#{numerator}/#{denominator}"

  defp mixed({numerator, denominator}) do
    sign = if numerator < 0, do: "-", else: ""
    magnitude = abs(numerator)
    whole = div(magnitude, denominator)
    remainder = rem(magnitude, denominator)

    cond do
      remainder == 0 -> sign <> Integer.to_string(whole)
      whole == 0 -> "#{sign}#{remainder}/#{denominator}"
      true -> "#{sign}#{whole} #{remainder}/#{denominator}"
    end
  end

  defp decimal({numerator, denominator}, limit) do
    sign = if numerator < 0, do: "-", else: ""
    magnitude = abs(numerator)
    whole = div(magnitude, denominator)
    remainder = rem(magnitude, denominator)

    if remainder == 0 do
      {:ok, sign <> Integer.to_string(whole)}
    else
      case traverse(remainder, denominator, limit) do
        {:ok, digits, nil} ->
          {:ok, "#{sign}#{whole}.#{digits}"}

        {:ok, digits, {prefix_length, _cycle_length}} ->
          prefix = binary_part(digits, 0, prefix_length)
          cycle = binary_part(digits, prefix_length, byte_size(digits) - prefix_length)
          {:ok, "#{sign}#{whole}.#{prefix}(#{cycle})"}

        {:error, _reason} = error ->
          error
      end
    end
  end

  # Classify termination and repetition before rejecting a digit beyond the inclusive limit.
  defp traverse(remainder, denominator, limit) do
    traverse(remainder, denominator, limit, 0, %{}, [])
  end

  defp traverse(0, _denominator, _limit, _index, _seen, digits) do
    {:ok, digits |> Enum.reverse() |> digits_binary(), nil}
  end

  defp traverse(remainder, _denominator, _limit, index, seen, digits) when is_map_key(seen, remainder) do
    prefix = Map.fetch!(seen, remainder)
    {:ok, digits |> Enum.reverse() |> digits_binary(), {prefix, index - prefix}}
  end

  defp traverse(_remainder, _denominator, limit, index, _seen, _digits) when index >= limit do
    {:error, "expansion longer than #{limit} digits"}
  end

  defp traverse(remainder, denominator, limit, index, seen, digits) do
    scaled = remainder * 10
    digit = div(scaled, denominator)
    next_remainder = rem(scaled, denominator)

    traverse(next_remainder, denominator, limit, index + 1, Map.put(seen, remainder, index), [digit | digits])
  end

  defp digits_binary(digits), do: Enum.map_join(digits, &Integer.to_string/1)

  defp continued_fraction(numerator, denominator, acc) do
    quotient = Integer.floor_div(numerator, denominator)
    remainder = numerator - quotient * denominator

    if remainder == 0 do
      Enum.reverse([quotient | acc])
    else
      continued_fraction(denominator, remainder, [quotient | acc])
    end
  end
end
