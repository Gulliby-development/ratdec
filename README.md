<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# ratdec

[![CI](https://github.com/Gulliby-development/ratdec/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/ratdec/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

ratdec is an integer-only exact rational calculator. Unlike floating-point arithmetic, it preserves exact fractions and can display repeating decimals such as `0.(3)`. It is intended for people checking invoice and tax splits, students, and authors of specifications that need exact values.

## Requirements and installation

Use Elixir 1.15 or newer with Erlang/OTP 26 or newer. From the project directory, build the escript:

```text
mix escript.build
```

This creates `ratdec`. On Windows, invoke it through the escript launcher as `escript ratdec ...`; on macOS and Linux, invoke `./ratdec ...`.

The Windows launcher drops empty arguments and splits an argument containing a tab before the program starts. Those two cases can be exercised through `Ratdec.CLI.run/2`; this launcher limitation does not change the CLI behavior for arguments it receives.

## Commands

The command synopsis is:

```text
usage: ratdec eval [--as frac|mixed|dec|all] [EXPR...]
       ratdec cf EXPR
       ratdec period EXPR
```

`eval` evaluates each expression, in order. The default format is `frac`; `--as FORMAT` is recognized only immediately after `eval`. Example:

```text
$ ./ratdec eval --as all "7/3"
7/3 = 2 1/3 = 2.(3)
```

The four formats for the same value are:

| Format | Command | Output |
| --- | --- | --- |
| `frac` | `./ratdec eval --as frac "7/3"` | `7/3` |
| `mixed` | `./ratdec eval --as mixed "7/3"` | `2 1/3` |
| `dec` | `./ratdec eval --as dec "7/3"` | `2.(3)` |
| `all` | `./ratdec eval --as all "7/3"` | `7/3 = 2 1/3 = 2.(3)` |

`frac` prints `N/D`, omitting `/1`; the sign is on the numerator. `mixed` prints a signed whole part and proper fraction (for example `-2 1/3`), just a fraction when the magnitude is below one, and an integer for whole values. `dec` prints the shortest decimal: digits before a repeating block followed by that block in parentheses, such as `0.1(6)`; terminating decimals have no parentheses. `all` joins these three forms with ` = ` and fails atomically if decimal expansion fails.

The other commands each take exactly one expression:

```text
$ ./ratdec cf -7/3
[-3; 1, 2]
$ ./ratdec period 1/6
pre=1 period=1
```

`cf` prints the canonical continued fraction: the first term is the floor, remaining terms are positive, and the last term is at least 2. Whole values print as `[A0]`. `period` reports the count of non-repeating digits and the repeating-cycle length; a terminating decimal has period zero.

`help`, `-h`, and `--help` print the synopsis; `--version` prints `ratdec 0.1.0`. Both help and version ignore trailing arguments. With no command the synopsis goes to standard error and the status is 2. Command names and formats are case-sensitive. For example:

```text
$ ./ratdec --help
usage: ratdec eval [--as frac|mixed|dec|all] [EXPR...]
       ratdec cf EXPR
       ratdec period EXPR
$ ./ratdec --version
ratdec 0.1.0
```

### Expressions

Whitespace is only the ASCII space byte (0x20), allowed between tokens and around an expression, never inside a number. The complete grammar is:

```text
expr   = term { ("+" | "-") term }
term   = unary { ("*" | "/") unary }
unary  = ("-" | "+") unary | power
power  = atom [ "^" unary ]
atom   = number | "(" expr ")"
number = DIGITS | DIGITS "." DIGITS | DIGITS "." [DIGITS] "(" DIGITS ")"
```

Each `DIGITS` run has one or more decimal digits. Leading zeroes are allowed. Examples include `0.5`, `0.(3)`, `0.1(6)`, and `2.(9)`. A repeating block follows the decimal point and any non-repeating digits. After a decimal point, there must be digits or a repeating block; a repeating block must contain digits and close with `)`.

Addition, subtraction, multiplication, and division associate left to right. Exponentiation binds more tightly than a unary sign on its left and associates right to left: `-2^2` is -4 and `2^3^2` is 512. The exponent can itself be signed, so `2^-2` is 1/4. `0^0` is 1. Implicit multiplication is not supported (`2(3)` is an error).

### Errors, limits, and input

A literal is read greedily. A malformed decimal point or repeating block reports `bad number at column N`, where N is the 1-based byte column of the literal's first digit. A well-formed literal with any digit run longer than 40 reports `number too long at column N`. Columns count bytes, not Unicode characters. For a wrong token, end of input reports `unexpected end of expression`; one of `0123456789.()+-*/^` reports `unexpected "C" at column N`; any other byte reports `unexpected character "C" at column N`. Printable ASCII bytes are shown directly; other bytes use lowercase `\\xHH` notation (for example, a tab is `\\x09`, and a UTF-8 letter begins with its first byte escaped). Empty or all-space input is `empty expression`. Parsing completes before evaluation, so a syntax error takes precedence over an evaluation error later in the expression.

Evaluation proceeds depth first and left first: evaluate the left operand, then the right operand, then apply the operation; evaluation stops at the first error. `division by zero` is reported for division by a zero right operand and for zero raised to a negative exponent. `exponent is not an integer` means the evaluated exponent is not a whole number. For exponentiation, checks occur in this order: the exponent must be an integer, it must be within the inclusive range -64 through 64, a zero base must not have a negative exponent, and the resulting value must satisfy the size limit. Thus a non-integer exponent takes precedence over an out-of-range check, and an out-of-range exponent takes precedence over the zero-base check. `exponent too large` means the exponent is outside that range. `result too large` means a reduced numerator or denominator exceeds 300 decimal digits; this limit is checked after each number and each `+`, `-`, `*`, `/`, or `^` operation. Denominators are positive.

Decimal output is limited inclusively to 200 digits before and within its repeating cycle. Period analysis is limited inclusively to 10000 such digits. Exceeding a limit reports `expansion longer than 200 digits` or `expansion longer than 10000 digits`, respectively. A repeating cycle is detected by tracking remainders.

An expression error is written to standard error as `ratdec: EXPR: ERROR`, with the original expression and exact error text; it produces no corresponding standard-output line. Other expressions in the same batch are still processed in order. Exit status is 0 if all succeed, 1 if any expression fails, and 2 for command, option, or arity errors. With no command, the three-line synopsis goes to standard error; an unrecognized command reports `ratdec: unknown command WORD`. A missing or unknown `--as` value reports `ratdec: --as needs one of frac, mixed, dec, all`. Only `eval --as FORMAT` treats the next word as the format; otherwise words including `-3` and `--as` are expressions. `cf` and `period` require exactly one expression and report `ratdec: cf needs exactly one EXPR` or `ratdec: period needs exactly one EXPR`.

With no expressions, `eval` reads standard input split at LF. A final empty piece after a trailing LF is omitted, but CR is retained as part of a line. Empty input has no lines to evaluate. When command-line expressions are present, standard input is ignored. Every emitted message ends in LF.

### Developer interface

The implementation uses Elixir's standard library only and performs arithmetic on integers; no floating-point arithmetic is used.

- `Ratdec.Parser.parse(binary)` returns `{:ok, ast}` or `{:error, binary}`. Its AST is `{:number, integer_digits_binary, fraction_digits_binary_or_nil, repeat_digits_binary_or_nil}`, `{:unary, :+ | :-, ast}`, or `{:binary, :+ | :- | :* | :/ | :^, left, right}`. The digit runs remain binaries, preserving leading zeroes.
- `Ratdec.Eval.eval(ast)` returns `{:ok, {integer_numerator, positive_integer_denominator}}` or `{:error, binary}`.
- `Ratdec.Rat` converts literals, normalizes fractions, and implements exact arithmetic.
- `Ratdec.Format.format(pair, format)`, `cf(pair)`, and `period(pair)` return `{:ok, binary_without_LF}` or `{:error, binary}`.
- `Ratdec.CLI.run(args, stdin)` is pure: it returns `{status, stdout_binary, stderr_binary}` and prints nothing. `Ratdec.CLI.reads_stdin?(args)` is true exactly for `["eval"]` and `["eval", "--as", FORMAT]` where FORMAT is `frac`, `mixed`, `dec`, or `all`; it is false otherwise.

Run the project checks during development:

```text
mix format --check-formatted
mix compile --warnings-as-errors
mix test
```

The test suite exercises the commands through `Ratdec.CLI.run/2`.

## License

MIT, see [LICENSE](LICENSE).

---

Built with BAKED
