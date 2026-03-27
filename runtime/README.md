# runtime/

Este directorio queda reservado para el runtime minimo del lenguaje.

## Responsabilidades previstas
- puente entre `historiaPrincipal()` y el entry point real del ejecutable
- interoperabilidad con `main`/CRT en Windows
- funciones minimas de entrada/salida
- soporte comun para programas `.p++`

## Estado actual
Ya existe un runtime minimo en [program_runtime.asm](/c:/Users/andres.rincon2/Desktop/test/Pablo-Plus-Plus/runtime/program_runtime.asm) que:

- expone `main`
- llama a `historiaPrincipal`
- implementa las builtins de salida a consola `imprimirEntero8`, `imprimirEntero16`, `imprimirEntero32`, `imprimirEntero64`, `imprimirNatural8`, `imprimirNatural16`, `imprimirNatural32`, `imprimirNatural64`, `imprimirLogico` e `imprimirLinea`
- deja listo el punto de entrada para el pipeline Win64

La salida a consola de esta V1 es deliberadamente simple:

- no existe `printf` general del lenguaje
- no existen strings del usuario todavia
- el formateo complejo queda para una fase posterior
