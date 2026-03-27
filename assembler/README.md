# assembler/

Aqui vive la implementacion inicial de `pablocc` en NASM x86-64.

## Modulos
- `pablocc.asm`: punto de entrada del compilador y banner de arquitectura.
- `pipeline.asm`: orquesta el flujo `fuente -> lexer -> parser -> AST -> semantica -> codegen -> toolchain`.
- `lexer.asm`: analizador lexico real del subconjunto actual.
- `parser.asm`: parser real para funciones, bloques, expresiones y sentencias base.
- `ast.asm`: construccion y dump del AST.
- `semantic.asm`: resolucion semantica del subconjunto hoy verificado.
- `codegen.asm`: backend NASM x86-64 del subconjunto actual.
- `toolchain.asm`: wrapper de ensamblado y link a `.exe` via `program-build.ps1`.
- `build.ps1`: script de build para generar `pablocc.exe` con NASM + GCC/MinGW.
- `verify.ps1`: smoke/acceptance del estado verificado actual.

## Estado
El compilador anfitrion ya no esta solo en fase de base modular: hoy construye `.exe` reales en Windows para el subconjunto cubierto por `examples/` y por `verify.ps1`.
