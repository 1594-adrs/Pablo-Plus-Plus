# examples/

Estos ejemplos fijan el tono inicial de `pablo-plus-plus`: sintaxis seria de bajo nivel, pero con nombres y escenas inspiradas en aventuras de patio.

## Archivos actuales
- `historia-minima.p++`: programa minimo con `historiaPrincipal()`.
- `retorno-siete.p++`: ejemplo minimo verificado que retorna `7`.
- `aritmetica-basica.p++`: ejemplo verificado de precedencia aritmetica.
- `contar-saltos.p++`: ejemplo de variables, bucle `mientras` y llamada de funcion.
- `si-logico.p++`: ejemplo verificado de `si/siNo`, `verdadero`, `falso`, `&&` y `!`.
- `vuelta-con-para.p++`: ejemplo verificado de `para`.
- `control-bucle.p++`: ejemplo verificado de `continuar` y `romper`.
- `externa-abs.p++`: ejemplo verificado de FFI minima con `externa`.
- `tipos-escalares.p++`: ejemplo verificado de los tipos escalares soportados por la V1.
- `imprimir-basico.p++`: ejemplo verificado de salida a consola con `imprimirEntero32` e `imprimirLinea`.
- `imprimir-logico.p++`: ejemplo verificado de salida a consola con `imprimirLogico`.

## Estado de verificacion
- `historia-minima.p++` ya esta verificado de punta a punta y debe salir con codigo `0`.
- `retorno-siete.p++` ya esta verificado de punta a punta y debe salir con codigo `7`.
- `aritmetica-basica.p++` ya esta verificado de punta a punta y debe salir con codigo `7`.
- `contar-saltos.p++` ya esta verificado de punta a punta y debe salir con codigo `5`.
- `si-logico.p++` ya esta verificado de punta a punta y debe salir con codigo `1`.
- `vuelta-con-para.p++` ya esta verificado de punta a punta y debe salir con codigo `4`.
- `control-bucle.p++` ya esta verificado de punta a punta y debe salir con codigo `5`.
- `externa-abs.p++` ya esta verificado de punta a punta y debe salir con codigo `7`.
- `tipos-escalares.p++` ya esta verificado de punta a punta y debe salir con codigo `9`.
- `imprimir-basico.p++` ya esta verificado de punta a punta y debe salir con codigo `0` e imprimir `7`.
- `imprimir-logico.p++` ya esta verificado de punta a punta y debe salir con codigo `0` e imprimir `verdadero` y `falso`.
- `contar-saltos.p++` tambien esta verificado con `-o .\build\custom.exe` y con rutas de salida que incluyen espacios.

## Verificacion recomendada
Desde la raiz del repo:

```powershell
powershell -ExecutionPolicy Bypass -File .\assembler\verify.ps1
```

Ese script reconstruye `pablocc` y recorre la matriz positiva y negativa usada para cerrar el estado actual del compilador anfitrion.

## Regla de estilo
El humor vive en los nombres y la narrativa, no en la semantica del lenguaje. Las construcciones base deben seguir siendo claras, estables y compatibles con una evolucion futura del compilador.
