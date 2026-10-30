defmodule Ratdec.Eval do
  @moduledoc """
  Evaluates the AST returned by Ratdec.Parser.parse/1.

  The shared AST is {:number, integer_digits, fraction_digits_or_nil,
  repeat_digits_or_nil}, {:unary, operator, child}, or
  {:binary, operator, left, right}. Binary nodes are evaluated depth first:
  the left child, then the right child, then the operation.
  """

  alias Ratdec.{Parser, Rat}

  @type rational :: Rat.rational()
  @type result :: {:ok, rational()} | {:error, binary()}

  @spec eval(Parser.ast()) :: result()
  def eval({:number, integer_digits, fraction_digits, repeat_digits}) do
    Rat.literal(integer_digits, fraction_digits, repeat_digits)
  end

  def eval({:unary, :+, child}), do: eval(child)

  def eval({:unary, :-, child}) do
    case eval(child) do
      {:ok, {numerator, denominator}} -> Rat.normalize(-numerator, denominator)
      {:error, _reason} = error -> error
    end
  end

  def eval({:binary, operator, left, right}) do
    with {:ok, left_value} <- eval(left),
         {:ok, right_value} <- eval(right) do
      apply_operation(operator, left_value, right_value)
    end
  end

  @spec apply_operation(:+ | :- | :* | :/ | :^, rational(), rational()) :: result()
  defp apply_operation(:+, left, right), do: Rat.add(left, right)
  defp apply_operation(:-, left, right), do: Rat.subtract(left, right)
  defp apply_operation(:*, left, right), do: Rat.multiply(left, right)
  defp apply_operation(:/, left, right), do: Rat.divide(left, right)
  defp apply_operation(:^, base, exponent), do: Rat.power(base, exponent)
end
