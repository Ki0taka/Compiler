## Features

- **Lexical analysis (Flex)** in `lex2.l`
  - Recognizes keywords, identifiers, integer constants, strings, operators, separators, comments (`## ...`), and whitespace/newlines.
  - Tracks source position with `nb_ligne` and `nb_colonne`.
- **Syntax analysis (Bison)** in `syn.y`
  - Parses declarations, assignments, arithmetic expressions, conditions, `If/Else/EndIf`, `For`, `Do/While`, and `Write`.
- **Semantic analysis** in `syn.y` + `TS.c`
  - Performs declaration/type checks and specific loop/array validations.
  - Reports diagnostics with line/column context.
- **Symbol-table support** in `TS.c` / `TS.h`
  - Stores identifiers/constants and tables for keywords/separators.
  - Prints table content after parsing.
- **Diagnostics**
  - Lexical errors (`Erreur lexicale ...`)
  - Syntax errors (`Erreur syntaxique ligne ... col ...`)
  - Semantic errors (`Erreur semantique ligne ... col ...`)

## Compiler pipeline / architecture

1. **Lexer (`lex2.l`)** tokenizes source input and records tokens in symbol tables via `rechercher(...)`.
2. **Parser (`syn.y`)** consumes tokens and validates grammar.
3. **Semantic checks (`syn.y` actions + `TS.c`)** verify declarations, types, and loop/array constraints.
4. **Reporting**
   - Parser prints semantic summary (`Analyse semantique: ...`).
   - `afficher()` prints identifier/keyword/separator tables.

## Supported language constructs (verified from source)

### Keywords and blocks
- `MainProgram`, `Declaration`, `Entier`, `Reel`, `Body`
- `begin ... end`
- `Write("...")`
- `If (...) { ... } Else { ... } EndIf;`
- `For <idf> de <cst> à <cst> pas <cst> { ... }`
- `Do { ... } While (...);`

### Expressions and operators
- Arithmetic: `+`, `-`, `*`, `/`
- Assignment: `:=`
- Comparisons: `==`, `!=`, `<`, `<=`, `>`, `>=`
- Logical: `AND`, `OR`, `NOT`
- Parenthesized expressions

### Data declarations
- Scalar declarations using `Entier` and `Reel`.
- Array-shaped syntax in instructions: `idf[constant]`.

### Comments and strings
- Line comments begin with `##`.
- Strings are double-quoted (`"..."`) and are used by `Write`.

### Important implementation notes
- The parser has an `ARRAY_DECL` rule, but no full array indexing/read-write semantics are implemented.
- `For` bounds/step currently require integer constants (`CST`) in grammar.
- Only behavior visible in `lex2.l`, `syn.y`, and `TS.c` is documented here.

## Repository structure

| Path | Role |
|---|---|
| `lex2.l` | Flex lexer specification (source) |
| `syn.y` | Bison grammar + semantic checks (source) |
| `TS.c`, `TS.h` | Symbol-table and semantic helper functions (source) |
| `test.txt` | Sample TP input program for manual testing |
| `com.bat` | Windows build/run helper commands |
| `rapport.docx` | Project report document |
| `lex.yy.c` | **Generated** Flex output |
| `syn.tab.c`, `syn.tab.h`, `syn.output` | **Generated** Bison outputs |
| `ACADAB.exe` | **Build artifact** (platform/toolchain-specific executable) |

> Generated/build outputs should generally not be hand-edited.

## Prerequisites

- [Flex](https://github.com/westes/flex)
- [Bison](https://www.gnu.org/software/bison/)
- [GCC](https://gcc.gnu.org/)
- Windows users can run `com.bat` directly (if tools are in PATH).

Checked-in generated files and `ACADAB.exe` can differ by OS, compiler, and toolchain versions.

## Build and run

### Windows (`com.bat`)

```bat
flex lex2.l
bison -d syn.y
gcc lex.yy.c syn.tab.c TS.c -o ACADAB.exe
ACADAB.exe < test.txt
```

Run:

```bat
com.bat
```

### Portable shell equivalent (Linux/macOS/WSL)

```sh
flex lex2.l
bison -d syn.y
gcc lex.yy.c syn.tab.c TS.c -o ACADAB
./ACADAB < test.txt
```

## Input format

A TP source file is read from standard input.

Minimal example:

```txt
MainProgram Demo;
Declaration
x : Entier;
Body
begin
{
  x := 1 + 2;
  Write("Hello TP");
}
end
```

## Testing

Use the included sample:

```sh
./ACADAB < test.txt
```

`test.txt` intentionally triggers multiple semantic diagnostics. Current categories include:
- undeclared identifiers
- type incompatibility on assignment
- invalid `For` variable type
- zero `For` step
- inconsistent `For` bounds/step (reported as potentially infinite)

See [`docs/semantic-errors.md`](docs/semantic-errors.md) for the detailed matrix.

## Semantic diagnostics (implemented checks)

Implemented in `syn.y`/`TS.c`:

- Undeclared variable usage/assignment
- Duplicate declaration detection logic (implemented, but may not catch all duplicate patterns reliably)
- Assignment type incompatibility (`Entier` vs `Reel`)
- `For` loop variable must be declared
- `For` loop variable must be `INT` (`Entier`)
- `For` step cannot be zero
- `For` bounds + step consistency check to prevent non-terminating direction
- Array name must be declared before `idf[constant]`
- Array size constant must be strictly positive

## Representative output

Typical output includes semantic diagnostics followed by a summary and symbol tables, for example:

```txt
Erreur semantique ligne 17 col 7: Variable 'Z' non declaree
...
Analyse semantique: 11 erreur(s) detectee(s)
```

Exact line/column and ordering can vary with source content and parser state.

## Limitations and future improvements

- Current grammar focuses on front-end analysis; there is no code generation stage.
- Array support is partial (declaration-form check only, no indexed expression semantics).
- Duplicate declaration handling exists but should be hardened and covered with dedicated tests.
- Diagnostics are currently French strings; internationalization/normalization could be added.

## Contributing

Contributions are welcome for grammar extensions, stronger semantic checks, and automated tests.
Please keep generated files synchronized with source changes when relevant.

## License / project status

No explicit open-source license file is present in the repository at this time.
Project appears to be an academic/compiler-course work repository.
