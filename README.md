# Solth

**Solth** is a tiny, minimal interpreted toy language written using **C** and **Lua**.  
It is designed to be extremely simple, easy to read, and quick to learn—most programmers can understand the language in under five minutes.

Solth is intentionally minimal and does **not** attempt to handle edge cases. The goal is clarity, not completeness.

---

## What is Solth?

Solth is my **third programming language**, built as a learning project and as an experiment in minimal language design.

It supports a small set of core features such as:
- Input and output
- Variables
- Conditional execution
- Functions (including nested functions)

The entire interpreter is lightweight and easy to inspect or modify.

---

## Why Lua?

Lua is the only interpreted language I actively use.  
It is small, fast, embeddable, and has a very clean C API.

The Lua codebase used in Solth is intentionally tiny and easy to understand, making experimentation and modification straightforward.

---

## What is the role of C?

Originally, Solth was written purely in Lua.  
However, Lua alone does not provide native command-line argument handling in this setup.

To solve this, Solth uses a **C host** that embeds **LuaJIT**, turning the interpreter into a **standalone executable**.

In short:
- **Lua** → language logic
- **C + LuaJIT** → executable interpreter

---

## Supported Features

Solth currently supports:

- Input and output
- Variables
- Dynamic typing (no explicit data types)
- `if` / `else`
- Comparisons
- Function declaration
- Function calls
- Nested functions
- Expression evaluation

---

## Unsupported / Broken Features

Solth is intentionally incomplete. The following are **not supported or broken**:

- Loops
- `elseif` (currently broken)
- Function arguments
- Underscores (`_`) in function names
- Many basic programming language features

This is expected and by design.

---

## How to Learn Solth

Simply read the `demo.solth` file.

That is enough to understand the entire language.

---

## How to Build Solth

You need **LuaJIT headers and libraries** installed.

Then run:
```sh
make
```
**⚠️ IMPORTANT
Do NOT remove solth.lua.
The interpreter depends on it at runtime.**

## Author
Created by Dhejesh
Github : https://github.com/dhejesh926
Website : https://dhejesh926.github.io

```sh
mak
