# Sintaxis base de `pablo-plus-plus`

## Resumen
`pablo-plus-plus` sera un lenguaje de bajo nivel con sintaxis completamente en espanol, tono ligeramente comico y una identidad narrativa inspirada en aventuras de patio. El humor vive en los nombres canonicos, ejemplos y estilo del lenguaje, pero la semantica sigue siendo seria y predecible para poder evolucionar a un compilador real de produccion.

La entrada oficial del programa pasa a ser:

`historiaPrincipal() -> entero32`

## Filosofia de la sintaxis
- Espanol completo en keywords, tipos y entry point.
- Superficie pequena y consistente, cercana a C.
- Bloques con llaves y terminacion explicita con `;`.
- Tipado estatico y legible.
- Nombres del usuario libres, con soporte para identificadores en espanol.
- Tono tematico en ejemplos y nombres sugeridos, sin convertir el lenguaje en un chiste dificil de mantener.

## Keywords reservadas
### Declaracion y funciones
- `funcion`
- `sea`
- `constante`
- `externa`
- `devolver`

### Control de flujo
- `si`
- `siNo`
- `mientras`
- `para`
- `continuar`
- `romper`

### Literales logicos
- `verdadero`
- `falso`

### Tipos base
- `vacio`
- `logico`
- `entero8`
- `entero16`
- `entero32`
- `entero64`
- `natural8`
- `natural16`
- `natural32`
- `natural64`

## Convenciones sintacticas
- Los identificadores distinguen mayusculas de minusculas.
- `historiaPrincipal` queda reservado como nombre canonico de entrada.
- Los nombres pueden usar letras, digitos y `_`, pero no pueden iniciar con digitos.
- La V1 acepta comentarios de linea con `//` y comentarios de bloque con `/* ... */`.
- Los literales enteros se expresan inicialmente en decimal; hexadecimal y binario quedan como extension futura.

## Forma general del programa
Un archivo `.p++` contiene una lista de declaraciones de funcion o declaraciones externas.

Ejemplo minimo:

```p++
funcion historiaPrincipal() -> entero32 {
    devolver 0;
}
```

## Declaracion de variables
La V1 usara declaraciones explicitas con `sea`:

```p++
sea pasos : entero32 = 7;
constante cancion : entero32 = 3;
```

Reglas:
- `sea` crea una variable mutable.
- `constante` crea una vinculacion inmutable.
- Toda declaracion local debe incluir tipo explicito.
- `constante` exige inicializacion.
- `sea` puede omitirse sin inicializacion y, en ese caso, se inicializa a cero del tipo declarado.

## Funciones
Las funciones se declaran con `funcion`, una lista de parametros tipados y un tipo de retorno explicito:

```p++
funcion saludar(aventura : entero32) -> entero32 {
    devolver aventura + 1;
}
```

Reglas:
- Todos los parametros llevan tipo.
- El tipo de retorno siempre aparece con `->`.
- `vacio` se usa cuando la funcion no devuelve valor.
- `historiaPrincipal()` no recibe parametros en la V1 y debe devolver `entero32`.

## Control de flujo
### Condicionales
```p++
si (pasos > 10) {
    devolver 1;
} siNo {
    devolver 0;
}
```

### Bucle `mientras`
```p++
mientras (indice < limite) {
    indice = indice + 1;
}
```

### Bucle `para`
```p++
para (sea i : entero32 = 0; i < 5; i = i + 1) {
    cantar(i);
}
```

## Funciones predeclaradas del runtime
La V1 ya incluye un conjunto pequeno de builtins de salida a consola. No requieren `externa` y no pueden redefinirse:

- `imprimirEntero8(valor : entero8) -> vacio`
- `imprimirEntero16(valor : entero16) -> vacio`
- `imprimirEntero32(valor : entero32) -> vacio`
- `imprimirEntero64(valor : entero64) -> vacio`
- `imprimirNatural8(valor : natural8) -> vacio`
- `imprimirNatural16(valor : natural16) -> vacio`
- `imprimirNatural32(valor : natural32) -> vacio`
- `imprimirNatural64(valor : natural64) -> vacio`
- `imprimirLogico(valor : logico) -> vacio`
- `imprimirLinea() -> vacio`

Reglas:
- ninguna imprime salto de linea automaticamente salvo `imprimirLinea()`
- no existe `imprimir(...)` generico en esta fase
- no existen strings del usuario ni `printf` variadico

## Expresiones y precedencia inicial
Precedencia propuesta de mayor a menor:

1. llamada: `nombre(...)`
2. unarios: `-expr`, `!expr`
3. multiplicativos: `*`, `/`, `%`
4. aditivos: `+`, `-`
5. relacionales: `<`, `<=`, `>`, `>=`
6. igualdad: `==`, `!=`
7. logicos: `&&`, `||`
8. asignacion: `=`

Notas:
- La asignacion es asociativa por la derecha.
- Las comparaciones devuelven `logico`.
- Los operadores logicos trabajan solo con `logico`.
- No hay promociones implicitas entre signed/unsigned ni entre anchos distintos en la V1.

## Literales
- Enteros: `0`, `1`, `42`, `1024`
- Logicos: `verdadero`, `falso`
- Cadenas: reservadas para runtime y diagnosticos; no entran al modelo de tipos del usuario en esta etapa

## EBNF inicial
```ebnf
programa            = { declaracion } ;

declaracion         = declaracion_funcion
                    | declaracion_externa ;

declaracion_funcion = "funcion" identificador "(" [ lista_parametros ] ")" "->" tipo bloque ;
declaracion_externa = "externa" identificador "(" [ lista_parametros ] ")" "->" tipo ";" ;

lista_parametros    = parametro { "," parametro } ;
parametro           = identificador ":" tipo ;

bloque              = "{" { sentencia } "}" ;

sentencia           = declaracion_variable ";"
                    | asignacion ";"
                    | expresion ";"
                    | sentencia_si
                    | sentencia_mientras
                    | sentencia_para
                    | sentencia_devolver ";"
                    | "continuar" ";"
                    | "romper" ";" ;

declaracion_variable = "sea" identificador ":" tipo [ "=" expresion ]
                     | "constante" identificador ":" tipo "=" expresion ;
sentencia_si        = "si" "(" expresion ")" bloque [ "siNo" bloque ] ;
sentencia_mientras  = "mientras" "(" expresion ")" bloque ;
sentencia_para      = "para" "(" declaracion_variable ";" expresion ";" asignacion ")" bloque ;
sentencia_devolver  = "devolver" [ expresion ] ;

asignacion          = identificador "=" expresion ;

expresion           = expresion_logica ;
expresion_logica    = expresion_igualdad { ( "&&" | "||" ) expresion_igualdad } ;
expresion_igualdad  = expresion_relacional { ( "==" | "!=" ) expresion_relacional } ;
expresion_relacional = expresion_aditiva { ( "<" | "<=" | ">" | ">=" ) expresion_aditiva } ;
expresion_aditiva   = expresion_multiplicativa { ( "+" | "-" ) expresion_multiplicativa } ;
expresion_multiplicativa = expresion_unaria { ( "*" | "/" | "%" ) expresion_unaria } ;
expresion_unaria    = [ "-" | "!" ] expresion_unaria | expresion_postfija ;
expresion_postfija  = primaria [ "(" [ lista_argumentos ] ")" ] ;
lista_argumentos    = expresion { "," expresion } ;

primaria            = literal
                    | identificador
                    | "(" expresion ")" ;

literal             = entero | "verdadero" | "falso" ;

tipo                = "vacio"
                    | "logico"
                    | "entero8"
                    | "entero16"
                    | "entero32"
                    | "entero64"
                    | "natural8"
                    | "natural16"
                    | "natural32"
                    | "natural64" ;
```

## Ejemplos de codigo
### Historia minima
```p++
funcion historiaPrincipal() -> entero32 {
    devolver 0;
}
```

### Conteo aventurero
```p++
funcion contarSaltos(meta : entero32) -> entero32 {
    sea saltos : entero32 = 0;

    mientras (saltos < meta) {
        saltos = saltos + 1;
    }

    devolver saltos;
}

funcion historiaPrincipal() -> entero32 {
    devolver contarSaltos(5);
}
```

### Decision dramatica de patio
```p++
funcion elegirCancion(energia : entero32) -> entero32 {
    si (energia > 7) {
        devolver 1;
    } siNo {
        devolver 0;
    }
}

funcion historiaPrincipal() -> entero32 {
    sea resultado : entero32 = elegirCancion(9);
    devolver resultado;
}
```

### Salida a consola basica
```p++
funcion historiaPrincipal() -> entero32 {
    imprimirEntero32(7);
    imprimirLinea();
    imprimirLogico(verdadero);
    devolver 0;
}
```

## Impacto en las siguientes fases
- El lexer debe reconocer estas keywords y operadores exactos.
- El parser debe tratar `siNo` como una sola palabra reservada.
- El analisis semantico debe reservar `historiaPrincipal` y validar su firma.
- El backend debe asumir que `historiaPrincipal()` corresponde al punto de entrada del programa del usuario.
