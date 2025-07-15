## Shark

Convert snake_case to camelCase and vice versa in nim source files.

#### Usage

Convert to camel case:

```
shark -c src/shark/text.nim
```

Convert to snake case:

```
shark -s src/shark/text.nim
```

Use `-t` and `-f` to toggle between 2 and 4 space indentation.

#### Usage as a library

Use the `to_camel_case`, `to_snake_case`, and `process_file` functions exported by the library.

Intended for nim source files but can be used on any text files.

---

Navid M &copy; 2025

No warranty. Not ever.
