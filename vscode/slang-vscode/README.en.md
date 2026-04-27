# SLANG Language Support for VSCode

VSCode language support for **SLANG**, the S-OS programming language used on Japanese 8-bit retro computer environments.

This extension provides syntax highlighting, language association, comments, bracket handling, indentation rules, and small snippets for `.SL` / `.sl` source files.

## Features

- Associates `.SL` and `.sl` files with the `SLANG` language mode.
- Highlights line comments and block comments:
  - `// ...`
  - `/* ... */`
  - `(* ... *)`
- Highlights preprocessor directives:
  - `#INCLUDE`, `#include`
  - `#CHAIN`
  - `#IF`, `#ELSE`, `#ENDIF`
  - `#MODULE`
  - `#ASM`, `#END`
- Highlights SLANG declarations, types, control keywords, constants, system arrays, registers, functions, operators, numbers, strings, and character constants.
- Adds simple highlighting for embedded Z80-style assembler in `#ASM ... #END` blocks.
- Adds basic indentation rules for `{ ... }`, `BEGIN ... END`, `FOR`, `IF`, `ELSE`, `ELIF`, `WHILE`, `LOOP`, and related closing keywords.
- Adds snippets for common blocks such as `MAIN()`, functions, `IF`, `WHILE`, `VAR`, and `ARRAY`.

## Install From VSIX

Download the `.vsix` file from the release page, then install it with one of these methods.

From the command line:

```sh
code --install-extension slang-language-0.1.0.vsix
```

From VSCode:

1. Open Extensions.
2. Select `...`.
3. Select `Install from VSIX...`.
4. Choose `slang-language-0.1.0.vsix`.
5. Run `Developer: Reload Window`.

After reload, open a `.SL` or `.sl` file. The language mode shown in the lower-right corner should be `SLANG`.

## Build VSIX

Install the VSCode extension packaging tool:

```sh
npm install -g @vscode/vsce
```

Package the extension:

```sh
cd slang-vscode
vsce package
```

This creates a file such as:

```text
slang-language-0.1.0.vsix
```

## Local Development Install

For quick local testing, copy this folder to a VSCode extensions directory and reload VSCode.

Windows VSCode:

```powershell
.\install-windows.ps1
```

VSCode Remote - WSL:

```sh
sh ./install-wsl.sh
```

Manual locations:

```text
Windows: %USERPROFILE%\.vscode\extensions\local.slang-language-0.1.0
WSL Remote: ~/.vscode-server/extensions/local.slang-language-0.1.0
```

For normal distribution, prefer the VSIX method.

## Notes

This is a TextMate grammar extension. It provides highlighting and editor behavior, but it does not compile SLANG, validate symbols, or perform semantic analysis.

The grammar is based on the public SLANG language specification and practical examples from existing SLANG source trees.

## License

MIT
