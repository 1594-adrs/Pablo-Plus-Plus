%ifndef PABLO_COMPILADOR_INC
%define PABLO_COMPILADOR_INC

; Limites de la primera ola ejecutable.
%define PABLO_MAX_SOURCE_BYTES 262144
%define PABLO_MAX_TOKENS 8192
%define PABLO_MAX_AST_NODES 8192
%define PABLO_MAX_FUNCTIONS 128
%define PABLO_MAX_LOCALS 1024
%define PABLO_MAX_PATH 512
%define PABLO_MAX_COMMAND 2048
%define PABLO_MAX_TOKEN_TEXT 128
%define PABLO_MAX_ARGS_CALL 4

; Modos de ejecucion del CLI.
%define PABLO_MODO_COMPILAR 0
%define PABLO_MODO_TOKENS 1
%define PABLO_MODO_AST 2
%define PABLO_MODO_EMIT_ASM 3

; Codigos detallados de error.
%define PABLO_CLI_SIN_FUENTE 100
%define PABLO_CLI_FLAG_DESCONOCIDA 101
%define PABLO_CLI_FUENTE_DUPLICADA 102
%define PABLO_CLI_FALTA_SALIDA 103
%define PABLO_CLI_MODOS_INCOMPATIBLES 104

%define PABLO_IO_NO_PUDO_ABRIR 200
%define PABLO_IO_ARCHIVO_MUY_GRANDE 201
%define PABLO_IO_LECTURA_INVALIDA 202
%define PABLO_IO_NO_PUDO_ESCRIBIR 203

%define PABLO_LEXER_CARACTER_INVALIDO 300
%define PABLO_LEXER_COMENTARIO_SIN_CERRAR 301
%define PABLO_LEXER_ENTERO_INVALIDO 302
%define PABLO_LEXER_MAX_TOKENS 303

%define PABLO_PARSER_TOKEN_INESPERADO 400
%define PABLO_PARSER_NO_SOPORTADO 401
%define PABLO_PARSER_MAX_AST 402

%define PABLO_SEMA_FUNCION_DUPLICADA 500
%define PABLO_SEMA_HISTORIA_FALTANTE 501
%define PABLO_SEMA_HISTORIA_INVALIDA 502
%define PABLO_SEMA_IDENTIFICADOR_DESCONOCIDO 503
%define PABLO_SEMA_VARIABLE_DUPLICADA 504
%define PABLO_SEMA_LLAMADA_INVALIDA 505
%define PABLO_SEMA_TIPO_NO_SOPORTADO 506
%define PABLO_SEMA_TIPO_INCOMPATIBLE 507
%define PABLO_SEMA_DEMASIADOS_ARGUMENTOS 508
%define PABLO_SEMA_MAX_FUNCTIONS 509
%define PABLO_SEMA_MAX_LOCALS 510
%define PABLO_SEMA_CONTROL_INVALIDO 511
%define PABLO_SEMA_RETORNO_INVALIDO 512
%define PABLO_SEMA_DECLARACION_EXTERNA_INVALIDA 513
%define PABLO_SEMA_MAX_TOKENS 514
%define PABLO_SEMA_MAX_AST 515

%define PABLO_CODEGEN_NO_PUDO_ABRIR 600
%define PABLO_CODEGEN_NODO_INVALIDO 601

%define PABLO_TOOLCHAIN_FALLO 700

; Flags del contexto.
%define PABLO_FLAG_SALIDA_PERSONALIZADA 1

; Flags estructuradas de funciones/locales.
%define PABLO_FUNC_FLAG_EXTERNA 1
%define PABLO_FUNC_FLAG_BUILTIN_RUNTIME 2
%define PABLO_LOCAL_FLAG_PARAM 1
%define PABLO_LOCAL_FLAG_CONST 2

; Tipos internos del lenguaje activos en el hito.
%define PABLO_TIPO_INVALIDO -1

; Layout de Token
%define TOKEN_tipo 0
%define TOKEN_linea 4
%define TOKEN_columna 8
%define TOKEN_longitud 12
%define TOKEN_offset 16
%define TOKEN_valor 24
%define TOKEN_SIZE 32

; Layout de NodoAST
%define AST_kind 0
%define AST_token 4
%define AST_tipo 8
%define AST_aux 12
%define AST_a 16
%define AST_b 20
%define AST_c 24
%define AST_next 28
%define AST_valor 32
%define AST_SIZE 40

; Layout de simbolo de funcion
%define FUNC_name_token 0
%define FUNC_return_type 4
%define FUNC_param_count 8
%define FUNC_first_param 12
%define FUNC_body_node 16
%define FUNC_stack_size 20
%define FUNC_label_id 24
%define FUNC_flags 28
%define FUNC_SIZE 32

; Layout de simbolo local
%define LOCAL_name_token 0
%define LOCAL_type 4
%define LOCAL_depth 8
%define LOCAL_slot_offset 12
%define LOCAL_is_param 16
%define LOCAL_param_ordinal 20
%define LOCAL_active 24
%define LOCAL_flags 28
%define LOCAL_SIZE 32

; Layout del contexto de compilacion
%define CTX_source_path 0
%define CTX_output_exe_path 8
%define CTX_output_asm_path 16
%define CTX_runtime_asm_path 24
%define CTX_mode 32
%define CTX_flags 36
%define CTX_source_buffer 40
%define CTX_source_length 48
%define CTX_tokens_ptr 56
%define CTX_token_count 64
%define CTX_token_capacity 68
%define CTX_ast_ptr 72
%define CTX_ast_count 80
%define CTX_ast_capacity 84
%define CTX_functions_ptr 88
%define CTX_function_count 96
%define CTX_function_capacity 100
%define CTX_locals_ptr 104
%define CTX_local_count 112
%define CTX_local_capacity 116
%define CTX_current_token 120
%define CTX_current_function 124
%define CTX_current_depth 128
%define CTX_current_slot 132
%define CTX_max_slot 136
%define CTX_label_counter 140
%define CTX_diag_stage 144
%define CTX_diag_code 148
%define CTX_diag_line 152
%define CTX_diag_column 156
%define CTX_diag_offset 160
%define CTX_diag_message 168
%define CTX_loop_depth 176
%define CTX_toolchain_script_path 184
%define CTX_SIZE 192

%endif
