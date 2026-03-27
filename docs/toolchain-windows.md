# Toolchain de Windows para `pablocc`

## Objetivo
El proyecto apunta a Windows x86-64 y genera:

1. archivos `.asm` en sintaxis NASM
2. archivos objeto `win64`
3. ejecutables `.exe` enlazados con GCC/MinGW y CRT

## Dependencias minimas
- NASM
- GCC para Windows con soporte `x86_64-w64-mingw32` o equivalente
- utilidades de shell para ejecutar `assembler/build.ps1`

## Ruta recomendada
La ruta recomendada para desarrollo local es instalar:

- NASM desde su sitio oficial
- MSYS2 para obtener un entorno MinGW-w64 moderno
- el paquete `mingw-w64-ucrt-x86_64-gcc` dentro del entorno UCRT64 de MSYS2

Esto sigue la direccion sugerida por la documentacion oficial de MSYS2 para toolchains nativos de Windows y es consistente con la documentacion de NASM para entornos Windows/POSIX.

## Instalacion rapida verificada en este repositorio
En esta maquina se valido una ruta automatizable con `winget`:

```powershell
winget install -e --id NASM.NASM --silent --accept-source-agreements --accept-package-agreements
winget install -e --id BrechtSanders.WinLibs.POSIX.UCRT --silent --accept-source-agreements --accept-package-agreements
```

Notas:
- `NASM.NASM` instala NASM para Windows.
- `BrechtSanders.WinLibs.POSIX.UCRT` aporta `gcc`, `ld` y el entorno MinGW-w64/UCRT.
- `assembler/build.ps1` ya contempla instalaciones via `PATH` o via carpetas de `winget` en `%LOCALAPPDATA%\Microsoft\WinGet\Packages`.

## Verificacion del entorno
Despues de instalar, asegurate de que estos comandos respondan desde una terminal nueva:

```powershell
nasm -v
gcc --version
```

## Build del compilador
Desde la raiz del repositorio:

```powershell
powershell -ExecutionPolicy Bypass -File .\assembler\build.ps1
```

Salida esperada:
- objetos `.obj` en `build/`
- ejecutable `build/pablocc.exe`

La version actual del script imprime tambien las rutas detectadas de `nasm` y `gcc`, lo que facilita depurar instalaciones hechas con `winget`.

## Pipeline actual para programas `p++`
En el estado actual del repositorio, la compilacion completa hasta `.exe` usa este flujo:

1. `pablocc archivo.p++`
2. `codegen` genera `build/program.asm`
3. `toolchain.asm` invoca:
   `powershell.exe -ExecutionPolicy Bypass -File .\program-build.ps1 -AsmPath "build\program.asm" -RuntimePath "runtime\program_runtime.asm" -ExePath "..."`
4. `program-build.ps1` actua como wrapper y encuentra el script real en `assembler/program-build.ps1`
5. `assembler/program-build.ps1` resuelve `nasm` y `gcc`, genera objetos derivados del nombre final del `.exe` y enlaza el ejecutable

El runtime enlazado en ese paso ya aporta las builtins de salida a consola de la V1, asi que programas `.p++` pueden usar `imprimirEntero32`, `imprimirLogico`, `imprimirLinea` y el resto de variantes tipadas sin declarar `externa`.

La ruta `-o` tambien esta verificada para salidas personalizadas, incluyendo rutas con espacios.

La toolchain actual tambien esta verificada en dos modos de uso:

- desde la raiz del repo, por ejemplo `.\build\pablocc.exe .\examples\historia-minima.p++`
- desde `build/`, por ejemplo `.\pablocc.exe ..\examples\historia-minima.p++`

Nota practica:
- cuando `pablocc.exe` se invoca desde `build/` y se usan rutas por defecto, los artefactos salen en `build/build/`
- cuando se usa `-o`, la ruta final del `.exe` sigue el `cwd` desde el que el usuario invoca `pablocc`

Ejemplos reales:

```powershell
.\build\pablocc.exe .\examples\contar-saltos.p++
.\build\pablocc.exe .\examples\contar-saltos.p++ -o .\build\custom.exe
.\build\pablocc.exe .\examples\contar-saltos.p++ -o ".\build\salida personalizada.exe"
```

## Verificacion automatizada
La forma recomendada de validar el entorno y el estado del compilador anfitrion es:

```powershell
powershell -ExecutionPolicy Bypass -File .\assembler\verify.ps1
```

El script reconstruye `pablocc`, valida dumps (`-tokens`, `-ast`, `-emit-asm`), comprueba la matriz positiva end-to-end y fuerza errores reales de lexer, parser, semantica y toolchain.

## Referencias oficiales consultadas
- NASM: `https://www.nasm.us/`
- Documentacion NASM: `https://www.nasm.us/doc/`
- MSYS2: `https://www.msys2.org/`
- MinGW-w64: `https://www.mingw-w64.org/`
