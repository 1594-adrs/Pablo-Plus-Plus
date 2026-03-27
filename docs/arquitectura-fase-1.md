# Arquitectura base de `pablo-plus-plus`

## Objetivo de la fase
Esta fase fija el armazon tecnico del proyecto para que las siguientes iteraciones agreguen funcionalidad sin redisenar la base. El objetivo no es tener aun un compilador completo, sino una arquitectura coherente con:

- compilador anfitrion escrito en ensamblador x86-64
- backend orientado a NASM Intel syntax
- ABI Win64 realista
- integracion con NASM + GCC/MinGW para producir ejecutables nativos de Windows

## Principios de diseno
- Lenguaje procedural y de bajo nivel, cercano a C.
- Tipado estatico y explicito.
- Control explicito del flujo y del uso del stack.
- Sin heap del lenguaje en la V1.
- Sin self-hosting en esta primera entrega.
- Separacion estricta por etapas del compilador.

## Pipeline objetivo
El pipeline completo que guiara la implementacion del compilador es:

`archivo.p++ -> tokens -> AST -> analisis semantico -> archivo.asm -> archivo.obj -> archivo.exe`

La fase base ya fue superada: hoy el repositorio no solo refleja esas etapas, sino que las ejecuta de punta a punta para una V1 real de una sola unidad fuente por compilacion.

## Modulos principales
- `pablocc.asm`
  Punto de entrada del compilador. Recibe argumentos del sistema, muestra estado y delega al pipeline.
- `pipeline.asm`
  Coordinador central del proceso de compilacion. En fases futuras recibira un contexto compartido.
- `lexer.asm`
  Generara tokens desde la fuente en espanol.
- `parser.asm`
  Convertira tokens en AST siguiendo la gramatica formal.
- `ast.asm`
  Definira y ayudara a construir/manipular nodos del arbol.
- `semantic.asm`
  Resolvera nombres, scopes y tipos.
- `codegen.asm`
  Convertira el AST validado a ensamblador NASM para Win64.
- `toolchain.asm`
  Encapsula la invocacion de NASM y GCC/MinGW para llegar a `.exe`.

## ABI y calling convention
La arquitectura del proyecto adopta Microsoft x64 ABI:

- argumentos 1-4 enteros/punteros en `RCX`, `RDX`, `R8`, `R9`
- retorno en `RAX`
- shadow space obligatorio de 32 bytes por llamada
- stack alineado a 16 bytes en call sites
- preservacion de registros no volatiles segun Win64

Esto permite que el compilador y el runtime convivan con CRT de C y con APIs nativas de Windows.

## Modelo del lenguaje V1
- Memoria local y parametros solo en stack.
- Tipos base:
  - `entero8`, `entero16`, `entero32`, `entero64`
  - `natural8`, `natural16`, `natural32`, `natural64`
  - `logico`
  - `vacio`
- Sin flotantes en la primera version.
- Sin punteros expuestos al usuario en la primera version.
- Sin `structs` en la primera version.
- Entrada canonica del programa: `historiaPrincipal() -> entero32`

## Estrategia de runtime
El runtime del lenguaje se apoyara inicialmente en `MinGW + CRT` para simplificar:

- entry point real del ejecutable
- adaptacion de `historiaPrincipal()` a `main`
- retorno de codigo de salida al sistema
- primeras primitivas de entrada/salida

El objetivo es aislar esos detalles en `runtime/` para que el usuario del lenguaje no tenga que escribir codigo dependiente de WinAPI o CRT.

## Evolucion prevista
La base actual deja espacio para:

- introducir una IR entre AST y codegen
- extender el sistema de tipos
- agregar heap y punteros
- separar frontend, backend y runtime con contratos mas finos
- habilitar optimizaciones y diagnosticos mas ricos

## Criterio de exito de esta fase
La fase queda implementada correctamente si:

- el repositorio ya expresa la arquitectura modular del compilador
- existe un esqueleto ensamblador enlazable con toolchain Win64
- la documentacion deja claras las invariantes del ABI, pipeline y tipos
- otra persona puede instalar dependencias, ensamblar `pablocc` y continuar el desarrollo sin redefinir decisiones base
