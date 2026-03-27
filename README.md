# Pablo-Plus-Plus

`pablo-plus-plus` es un lenguaje compilado, procedural y de bajo nivel, inspirado en C, con sintaxis en espanol y backend orientado a x86-64.

La implementacion anfitriona del compilador `pablocc` esta planteada en ensamblador NASM para Windows x86-64, con un pipeline objetivo:

`fuente .p++ -> tokens -> AST -> analisis semantico -> .asm -> .obj -> .exe`

La entrada canonica del lenguaje es `historiaPrincipal()`, con una identidad narrativa y ligeramente comica inspirada en aventuras de patio.

## Estado actual
El proyecto ya salio del puro esqueleto documental y entro en una V1 anfitriona funcional, de una sola unidad fuente por compilacion:

- CLI real en `pablocc`
- carga de archivo fuente `.p++`
- lexer real con keywords, operadores, comentarios y ubicacion linea/columna
- parser real para funciones, parametros, bloques, `devolver`, llamadas, `si`, `siNo`, `mientras`, `para`, `continuar`, `romper`, `sea`, `constante` y `externa`
- semantica real para funciones, parametros, variables locales, constantes, llamadas, asignacion, control de flujo, `vacio`, tipos escalares y validacion exacta de tipos
- backend NASM x86-64 que ya emite funciones reales, retornos, aritmetica, comparaciones signed/unsigned, llamadas Win64, `si`, `siNo`, `mientras`, `para`, `continuar` y `romper`
- runtime Win64 minimo y wrapper de toolchain integrados en el repo
- salida a consola basica via builtins del runtime
- verificacion automatizada de smoke/acceptance en `assembler/verify.ps1`

El hito actual verificado ya permite:

- generar `build/program.asm` con `-emit-asm`
- producir `.exe` finales en Windows
- ejecutar programas cuyo retorno sale de `historiaPrincipal()`
- usar `-o` con rutas personalizadas, incluyendo rutas con espacios
- compilar desde la raiz del repo o invocando `build/pablocc.exe` desde `build/`

Subconjunto verificado de punta a punta en esta iteracion:

- `funcion historiaPrincipal() -> entero32`
- funciones con parametros tipados y llamadas
- `devolver` y `devolver;` en funciones `vacio`
- literales enteros y logicos (`verdadero`, `falso`)
- aritmetica binaria basica (`+`, `-`, `*`, `/`, `%`)
- parametros tipados
- variables locales con `sea`
- `constante`
- asignacion
- llamadas de funcion del usuario y externas (`externa`)
- salida a consola basica con `imprimirEntero8`, `imprimirEntero16`, `imprimirEntero32`, `imprimirEntero64`, `imprimirNatural8`, `imprimirNatural16`, `imprimirNatural32`, `imprimirNatural64`, `imprimirLogico` e `imprimirLinea`
- comparaciones relacionales y de igualdad
- `&&`, `||`, `!`
- `si`, `siNo`
- `mientras`
- `para`
- `continuar` y `romper`
- tipos `entero8`, `entero16`, `entero32`, `entero64`, `natural8`, `natural16`, `natural32`, `natural64`, `logico` y `vacio`
- aridad mayor a 4 argumentos bajo Microsoft x64

Matriz positiva verificada hoy:

- `historia-minima.p++` => exit `0`
- `retorno-siete.p++` => exit `7`
- `aritmetica-basica.p++` => exit `7`
- `contar-saltos.p++` => exit `5`
- `si-logico.p++` => exit `1`
- `vuelta-con-para.p++` => exit `4`
- `control-bucle.p++` => exit `5`
- `externa-abs.p++` => exit `7`
- `tipos-escalares.p++` => exit `9`
- `imprimir-basico.p++` => exit `0`, stdout `7`
- `imprimir-logico.p++` => exit `0`, stdout `verdadero` / `falso`
- `contar-saltos.p++ -o .\build\custom.exe` => exit `5`
- `contar-saltos.p++ -o ".\build\salida personalizada.exe"` => exit `5`
- `build\pablocc.exe ..\examples\historia-minima.p++` ejecutado desde `build/` => exit `0`

## Estructura actual
```text
assembler/   Implementacion anfitriona de pablocc en NASM x86-64
docs/        Arquitectura y guia de toolchain Windows
examples/    Primeros ejemplos de sintaxis del lenguaje
include/     Constantes compartidas y definiciones ABI
runtime/     Punto de extension para el runtime del lenguaje
src/         Espacio reservado para crecimiento del proyecto
```

## Build del compilador
Requisitos:
- NASM en `PATH`
- GCC para Windows en `PATH` (recomendado: MinGW-w64 via MSYS2)

Opcion rapida verificada en este proyecto:

```powershell
winget install -e --id NASM.NASM --silent --accept-source-agreements --accept-package-agreements
winget install -e --id BrechtSanders.WinLibs.POSIX.UCRT --silent --accept-source-agreements --accept-package-agreements
```

Comando:

```powershell
powershell -ExecutionPolicy Bypass -File .\assembler\build.ps1
```

Si el entorno esta listo, el binario esperado es:

```text
build/pablocc.exe
```

## Verificacion automatizada
La verificacion recomendada del estado actual del compilador es:

```powershell
powershell -ExecutionPolicy Bypass -File .\assembler\verify.ps1
```

El script reconstruye `pablocc`, valida `-tokens`, `-ast`, `-emit-asm`, ejecuta la matriz positiva end-to-end y comprueba errores reales de lexer, parser, semantica y toolchain.

## Documentacion clave
- `docs/arquitectura-fase-1.md`
- `docs/sintaxis-fase-2.md`
- `docs/toolchain-windows.md`
- `assembler/README.md`
- `examples/README.md`

## Direccion de la V1
La V1 actual del lenguaje queda cerrada con estas restricciones y alcances:

- tipado estatico
- una sola unidad fuente por compilacion
- solo memoria en stack
- tipos enteros fijos, `logico` y `vacio`
- interoperabilidad externa via `externa`
- salida a consola basica via builtins del runtime, sin `printf` general
- sin heap, punteros expuestos, `structs` ni flotantes
- ABI Microsoft x64
- entrada canonica del lenguaje mediante `historiaPrincipal()`

## Fuera de alcance de esta V1
- compilacion multiarchivo o modulos del lenguaje
- heap del lenguaje
- punteros expuestos al usuario
- `structs`
- strings del usuario
- `printf` generico o funciones variadicas del lenguaje
- flotantes
- libreria estandar propia mas alla del runtime minimo/CRT
