# Semantic Errors in TP_Compil

This document summarizes semantic diagnostics implemented in `syn.y` (with symbol/type helpers in `TS.c`).
It describes **observed/implemented** behavior only.

## How diagnostics are reported

- Semantic errors are printed by `semantic_error(const char* msg)` in `syn.y`:

```c
printf("Erreur semantique ligne %d col %d: %s\n", nb_ligne, nb_colonne, msg);
semantic_errors++;
```

- `nb_ligne` and `nb_colonne` are maintained by the lexer (`lex2.l`).
- `semantic_errors` is a global counter; after parse, the parser reports:
  - `Analyse semantique: Aucune erreur` when zero
  - `Analyse semantique: <N> erreur(s) detectee(s)` otherwise

## Semantic error matrix

| Category | Trigger condition | Example input (representative) | Emitted diagnostic text |
|---|---|---|---|
| Undeclared variable (assignment target) | `IDF := EXPR` where target identifier is not declared | `Z := 10;` | `Variable 'Z' non declaree` |
| Undeclared variable (expression use) | `IDF` used in expression without declaration | `Prod := D * F;` (`D` undeclared) | `Variable 'D' non declaree` |
| Duplicate declaration (implemented check) | Declaration logic detects already-declared identifier in declaration processing | `L : Entier; ... L : Entier;` | `Variable 'L' deja declaree` |
| Assignment type incompatibility | Variable type differs from computed expression type (`Entier` vs `Reel`) | `X := F + W;` where `X` is `Entier`, `F/W` are `Reel` | `Incompatibilite de type pour 'X': INT attendu` (or `FLOAT attendu`) |
| Undeclared FOR variable | `For <idf> ...` and loop variable not declared | `For count de 1 à 5 pas 1 { ... }` | `Variable de boucle 'count' non declaree` |
| Non-integer FOR variable | Loop variable exists but is not `Entier` | `For F de 1 à 5 pas 1 { ... }` where `F` is `Reel` | `Variable de boucle 'F' doit etre de type INT` |
| Invalid FOR step (`0`) | `pas 0` | `For i de 1 à 10 pas 0 { ... }` | `Le pas de la boucle FOR ne peut pas etre zero` |
| FOR bounds/step inconsistency (infinite direction) | Positive step with start > end, or negative step with start < end | `For i de 10 à 1 pas 1 { ... }` | `Boucle FOR infinie: verifier debut, fin et pas` |
| Undeclared array identifier | `IDF[CST]` where identifier is not declared | `arr[5];` with no declaration for `arr` | `Tableau 'arr' non declare` |
| Invalid array size | `IDF[CST]` with `CST <= 0` | `arr[0];` | `Taille du tableau doit etre positive (obtenu: 0)` |

## Notes and limitations

- Error strings above reflect wording present in `syn.y`.
- Duplicate declaration detection exists in helper logic (`check_duplicate`) but may not be fully robust for all declaration flows.
- Array handling currently validates declaration existence and positive size in `ARRAY_DECL`; it does not provide full array access semantics.
- Conditions (`If`, `While`) reuse expression parsing and can indirectly surface undeclared-variable errors via `EXPR`.
