default rel

%include "pablocc.inc"
%include "sintaxis.inc"
%include "compilador.inc"

extern get_token_ptr
extern get_ast_ptr
extern ast_alloc
extern pablo_set_error_token
extern pablo_map_type_token
extern pablo_token_text
extern pablo_range_equals_cstr

global parser_preparar

section .rdata
kw_funcion db "funcion", 0

msg_inesperado db "Token inesperado en el parser del hito actual.", 0
msg_no_soportado db "Construccion reconocida pero aun no soportada.", 0
msg_ident db "Se esperaba un identificador.", 0
msg_tipo db "Se esperaba un tipo.", 0
msg_funcion db "Se esperaba una declaracion de funcion o externa.", 0
msg_expr db "Se esperaba una expresion valida.", 0
msg_ast db "Se alcanzo la capacidad maxima del AST.", 0
msg_asignable db "Solo se puede asignar a identificadores en la V1.", 0
msg_constante db "La declaracion constante requiere inicializacion.", 0

section .text
parser_preparar:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    mov dword [rcx + CTX_ast_count], 0
    mov dword [rcx + CTX_current_token], 0
    mov dword [rbp - 12], -1
    mov dword [rbp - 16], -1

    mov edx, PABLO_AST_PROGRAMA
    mov r8d, -1
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 20], eax

.loop:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_FIN_ARCHIVO
    je .done
    mov rcx, [rbp - 8]
    call parse_top_level_declaration
    test eax, eax
    js .error
    cmp dword [rbp - 12], -1
    jne .append
    mov [rbp - 12], eax
    mov [rbp - 16], eax
    jmp .loop
.append:
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov edx, [rbp - 24]
    mov [rax + AST_next], edx
    mov eax, [rbp - 24]
    mov [rbp - 16], eax
    jmp .loop

.done:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 20]
    call get_ast_ptr
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    xor eax, eax
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_function:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp - 8], rcx
    mov dword [rbp - 12], -1
    mov dword [rbp - 16], -1

    mov rcx, [rbp - 8]
    call consume_funcion
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_IDENTIFICADOR
    lea r8, [rel msg_ident]
    call expect_token
    test eax, eax
    js .error
    mov [rbp - 20], eax

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_IZQ
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_PAR_DER
    je .params_done
.params_loop:
    mov rcx, [rbp - 8]
    call parse_param
    test eax, eax
    js .error
    cmp dword [rbp - 12], -1
    jne .append_param
    mov [rbp - 12], eax
    mov [rbp - 16], eax
    jmp .after_param
.append_param:
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov edx, [rbp - 24]
    mov [rax + AST_next], edx
    mov eax, [rbp - 24]
    mov [rbp - 16], eax
.after_param:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_COMA
    jne .params_done
    mov rcx, [rbp - 8]
    call advance_token
    jmp .params_loop

.params_done:
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_DER
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_FLECHA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    call parse_type_ref
    cmp eax, PABLO_TIPO_INVALIDO
    je .error
    mov [rbp - 28], eax

    mov rcx, [rbp - 8]
    call parse_block
    test eax, eax
    js .error
    mov [rbp - 32], eax

    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_DECLARACION_FUNCION
    mov r8d, [rbp - 20]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 36], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 36]
    call get_ast_ptr
    mov edx, [rbp - 28]
    mov [rax + AST_tipo], edx
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 32]
    mov [rax + AST_b], edx
    mov eax, [rbp - 36]
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_top_level_declaration:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 8], rcx

    call current_type
    cmp eax, PABLO_TOKEN_EXTERNA
    je .externa
    mov rcx, [rbp - 8]
    call parse_function
    jmp .fin

.externa:
    mov rcx, [rbp - 8]
    call parse_external_declaration

.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_external_declaration:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp - 8], rcx
    mov dword [rbp - 12], -1
    mov dword [rbp - 16], -1

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_EXTERNA
    lea r8, [rel msg_funcion]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_IDENTIFICADOR
    lea r8, [rel msg_ident]
    call expect_token
    test eax, eax
    js .error
    mov [rbp - 20], eax

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_IZQ
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_PAR_DER
    je .params_done
.params_loop:
    mov rcx, [rbp - 8]
    call parse_param
    test eax, eax
    js .error
    cmp dword [rbp - 12], -1
    jne .append_param
    mov [rbp - 12], eax
    mov [rbp - 16], eax
    jmp .after_param
.append_param:
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov edx, [rbp - 24]
    mov [rax + AST_next], edx
    mov eax, [rbp - 24]
    mov [rbp - 16], eax
.after_param:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_COMA
    jne .params_done
    mov rcx, [rbp - 8]
    call advance_token
    jmp .params_loop

.params_done:
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_DER
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_FLECHA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    call parse_type_ref
    cmp eax, PABLO_TIPO_INVALIDO
    je .error
    mov [rbp - 28], eax

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PUNTO_Y_COMA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_DECLARACION_EXTERNA
    mov r8d, [rbp - 20]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 32], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 32]
    call get_ast_ptr
    mov edx, [rbp - 28]
    mov [rax + AST_tipo], edx
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov eax, [rbp - 32]
    jmp .fin

.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_param:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_IDENTIFICADOR
    lea r8, [rel msg_ident]
    call expect_token
    test eax, eax
    js .error
    mov [rbp - 12], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_DOS_PUNTOS
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    call parse_type_ref
    cmp eax, PABLO_TIPO_INVALIDO
    je .error
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_PARAMETRO
    mov r8d, [rbp - 12]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 20]
    call get_ast_ptr
    mov edx, [rbp - 16]
    mov [rax + AST_tipo], edx
    mov eax, [rbp - 20]
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_block:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    mov dword [rbp - 12], -1
    mov dword [rbp - 16], -1

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_LLAVE_IZQ
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov [rbp - 20], eax

.stmt_loop:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_LLAVE_DER
    je .close
    cmp eax, PABLO_TOKEN_FIN_ARCHIVO
    je .unexpected_eof
    mov rcx, [rbp - 8]
    call parse_statement
    test eax, eax
    js .error
    cmp dword [rbp - 12], -1
    jne .append_stmt
    mov [rbp - 12], eax
    mov [rbp - 16], eax
    jmp .stmt_loop
.append_stmt:
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov edx, [rbp - 24]
    mov [rax + AST_next], edx
    mov eax, [rbp - 24]
    mov [rbp - 16], eax
    jmp .stmt_loop

.close:
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_BLOQUE
    mov r8d, [rbp - 20]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 28], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 28]
    call get_ast_ptr
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov eax, [rbp - 28]
    jmp .fin

.unexpected_eof:
    mov rcx, [rbp - 8]
    mov edx, PABLO_PARSER_TOKEN_INESPERADO
    lea r8, [rel msg_inesperado]
    call parser_error_current
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_local_binding:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 16], r8d
    mov [rbp - 20], r9d

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_IDENTIFICADOR
    lea r8, [rel msg_ident]
    call expect_token
    test eax, eax
    js .error
    mov [rbp - 24], eax

    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_DOS_PUNTOS
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    call parse_type_ref
    cmp eax, PABLO_TIPO_INVALIDO
    je .error
    mov [rbp - 28], eax

    mov dword [rbp - 32], -1
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_ASIGNAR
    jne .after_init
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .error
    mov [rbp - 32], eax
.after_init:
    cmp dword [rbp - 16], 0
    je .maybe_semicolon
    cmp dword [rbp - 32], -1
    jne .maybe_semicolon
    mov rcx, [rbp - 8]
    mov edx, PABLO_PARSER_NO_SOPORTADO
    lea r8, [rel msg_constante]
    call parser_error_current
    mov eax, -1
    jmp .fin

.maybe_semicolon:
    cmp dword [rbp - 20], 0
    je .build
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PUNTO_Y_COMA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

.build:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8d, [rbp - 24]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 36], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 36]
    call get_ast_ptr
    mov edx, [rbp - 28]
    mov [rax + AST_tipo], edx
    mov edx, [rbp - 32]
    mov [rax + AST_a], edx
    mov eax, [rbp - 36]
    jmp .fin

.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_statement:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp - 8], rcx
    mov dword [rbp - 36], -1
    call current_type
    cmp eax, PABLO_TOKEN_DEVOLVER
    je .ret
    cmp eax, PABLO_TOKEN_SEA
    je .var_decl
    cmp eax, PABLO_TOKEN_CONSTANTE
    je .const_decl
    cmp eax, PABLO_TOKEN_SI
    je .stmt_if
    cmp eax, PABLO_TOKEN_MIENTRAS
    je .stmt_while
    cmp eax, PABLO_TOKEN_LLAVE_IZQ
    je .nested_block
    cmp eax, PABLO_TOKEN_CONTINUAR
    je .stmt_continue
    cmp eax, PABLO_TOKEN_ROMPER
    je .stmt_break
    cmp eax, PABLO_TOKEN_PARA
    je .stmt_for

    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 36], eax
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .error
    mov [rbp - 12], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PUNTO_Y_COMA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_SENTENCIA_EXPRESION
    mov r8d, [rbp - 36]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov eax, [rbp - 16]
    jmp .fin

.ret:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 36], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov dword [rbp - 12], -1
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_PUNTO_Y_COMA
    je .ret_ready
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .error
    mov [rbp - 12], eax
.ret_ready:
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PUNTO_Y_COMA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_SENTENCIA_DEVOLVER
    mov r8d, [rbp - 36]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov eax, [rbp - 16]
    jmp .fin

.var_decl:
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_DECLARACION_VARIABLE
    xor r8d, r8d
    mov r9d, 1
    call parse_local_binding
    test eax, eax
    js .error
    jmp .fin

.const_decl:
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_DECLARACION_CONSTANTE
    mov r8d, 1
    mov r9d, 1
    call parse_local_binding
    test eax, eax
    js .error
    jmp .fin

.stmt_if:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 32], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_IZQ
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .error
    mov [rbp - 12], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_DER
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    call parse_statement
    test eax, eax
    js .error
    mov [rbp - 20], eax
    mov dword [rbp - 24], -1
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_SI_NO
    jne .build_if
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_statement
    test eax, eax
    js .error
    mov [rbp - 24], eax
.build_if:
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_SENTENCIA_SI
    mov r8d, [rbp - 32]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 20]
    mov [rax + AST_b], edx
    mov edx, [rbp - 24]
    mov [rax + AST_c], edx
    mov eax, [rbp - 16]
    jmp .fin

.stmt_while:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 32], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_IZQ
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .error
    mov [rbp - 12], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_DER
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    call parse_statement
    test eax, eax
    js .error
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_SENTENCIA_MIENTRAS
    mov r8d, [rbp - 32]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 20]
    mov [rax + AST_b], edx
    mov eax, [rbp - 16]
    jmp .fin

.stmt_continue:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 32], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PUNTO_Y_COMA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_SENTENCIA_CONTINUAR
    mov r8d, [rbp - 32]
    call new_ast_node
    jmp .fin

.stmt_break:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 32], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PUNTO_Y_COMA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_SENTENCIA_ROMPER
    mov r8d, [rbp - 32]
    call new_ast_node
    jmp .fin

.stmt_for:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 32], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_IZQ
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov dword [rbp - 40], -1
    mov dword [rbp - 44], -1
    mov dword [rbp - 48], -1

    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_PUNTO_Y_COMA
    je .for_after_init
    cmp eax, PABLO_TOKEN_SEA
    je .for_init_var
    cmp eax, PABLO_TOKEN_CONSTANTE
    je .for_init_const
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 52], eax
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .error
    mov [rbp - 56], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_SENTENCIA_EXPRESION
    mov r8d, [rbp - 52]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 40], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 40]
    call get_ast_ptr
    mov edx, [rbp - 56]
    mov [rax + AST_a], edx
    jmp .for_after_init

.for_init_var:
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_DECLARACION_VARIABLE
    xor r8d, r8d
    xor r9d, r9d
    call parse_local_binding
    test eax, eax
    js .error
    mov [rbp - 40], eax
    jmp .for_after_init

.for_init_const:
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_DECLARACION_CONSTANTE
    mov r8d, 1
    xor r9d, r9d
    call parse_local_binding
    test eax, eax
    js .error
    mov [rbp - 40], eax

.for_after_init:
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PUNTO_Y_COMA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_PUNTO_Y_COMA
    je .for_after_cond
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .error
    mov [rbp - 44], eax

.for_after_cond:
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PUNTO_Y_COMA
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_PAR_DER
    je .for_after_update
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .error
    mov [rbp - 48], eax

.for_after_update:
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_DER
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    call parse_statement
    test eax, eax
    js .error
    mov [rbp - 60], eax

    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_SENTENCIA_PARA
    mov r8d, [rbp - 32]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov edx, [rbp - 40]
    mov [rax + AST_a], edx
    mov edx, [rbp - 44]
    mov [rax + AST_b], edx
    mov edx, [rbp - 60]
    mov [rax + AST_c], edx
    mov edx, [rbp - 48]
    mov qword [rax + AST_valor], rdx
    mov eax, [rbp - 16]
    jmp .fin

.nested_block:
    mov rcx, [rbp - 8]
    call parse_block
    jmp .fin

.unsupported:
    mov rcx, [rbp - 8]
    mov edx, PABLO_PARSER_NO_SOPORTADO
    lea r8, [rel msg_no_soportado]
    call parser_error_current
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_expression:
    jmp parse_assignment

parse_assignment:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    call parse_logical_or
    test eax, eax
    js .error
    mov [rbp - 12], eax
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_ASIGNAR
    jne .done
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    cmp dword [rax + AST_kind], PABLO_AST_IDENTIFICADOR
    je .parse_rhs
    mov rcx, [rbp - 8]
    mov edx, PABLO_PARSER_NO_SOPORTADO
    lea r8, [rel msg_asignable]
    call parser_error_current
    mov eax, -1
    jmp .fin
.parse_rhs:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_assignment
    test eax, eax
    js .error
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_ASIGNACION
    mov r8d, [rbp - 16]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 24]
    call get_ast_ptr
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 20]
    mov [rax + AST_b], edx
    mov eax, [rbp - 24]
    jmp .fin
.done:
    mov eax, [rbp - 12]
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_logical_or:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    call parse_logical_and
    test eax, eax
    js .error
    mov [rbp - 12], eax
.loop:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_O_LOGICO
    jne .done
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_logical_and
    test eax, eax
    js .error
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_BINARIO
    mov r8d, [rbp - 20]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 28], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 28]
    call get_ast_ptr
    mov edx, [rbp - 16]
    mov [rax + AST_aux], edx
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 24]
    mov [rax + AST_b], edx
    mov eax, [rbp - 28]
    mov [rbp - 12], eax
    jmp .loop
.done:
    mov eax, [rbp - 12]
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_logical_and:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    call parse_equality
    test eax, eax
    js .error
    mov [rbp - 12], eax
.loop:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_Y_LOGICO
    jne .done
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_equality
    test eax, eax
    js .error
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_BINARIO
    mov r8d, [rbp - 20]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 28], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 28]
    call get_ast_ptr
    mov edx, [rbp - 16]
    mov [rax + AST_aux], edx
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 24]
    mov [rax + AST_b], edx
    mov eax, [rbp - 28]
    mov [rbp - 12], eax
    jmp .loop
.done:
    mov eax, [rbp - 12]
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_equality:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    call parse_comparison
    test eax, eax
    js .error
    mov [rbp - 12], eax
.loop:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_IGUAL_QUE
    je .binary
    cmp eax, PABLO_TOKEN_DISTINTO_QUE
    jne .done
.binary:
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_comparison
    test eax, eax
    js .error
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_BINARIO
    mov r8d, [rbp - 20]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 28], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 28]
    call get_ast_ptr
    mov edx, [rbp - 16]
    mov [rax + AST_aux], edx
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 24]
    mov [rax + AST_b], edx
    mov eax, [rbp - 28]
    mov [rbp - 12], eax
    jmp .loop
.done:
    mov eax, [rbp - 12]
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_comparison:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    call parse_additive
    test eax, eax
    js .error
    mov [rbp - 12], eax
.loop:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_MENOR_QUE
    je .binary
    cmp eax, PABLO_TOKEN_MENOR_O_IGUAL
    je .binary
    cmp eax, PABLO_TOKEN_MAYOR_QUE
    je .binary
    cmp eax, PABLO_TOKEN_MAYOR_O_IGUAL
    jne .done
.binary:
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_additive
    test eax, eax
    js .error
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_BINARIO
    mov r8d, [rbp - 20]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 28], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 28]
    call get_ast_ptr
    mov edx, [rbp - 16]
    mov [rax + AST_aux], edx
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 24]
    mov [rax + AST_b], edx
    mov eax, [rbp - 28]
    mov [rbp - 12], eax
    jmp .loop
.done:
    mov eax, [rbp - 12]
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_additive:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    call parse_term
    test eax, eax
    js .error
    mov [rbp - 12], eax
.loop:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_SUMA
    je .binary
    cmp eax, PABLO_TOKEN_RESTA
    jne .done
.binary:
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_term
    test eax, eax
    js .error
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_BINARIO
    mov r8d, [rbp - 20]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 28], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 28]
    call get_ast_ptr
    mov edx, [rbp - 16]
    mov [rax + AST_aux], edx
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 24]
    mov [rax + AST_b], edx
    mov eax, [rbp - 28]
    mov [rbp - 12], eax
    jmp .loop
.done:
    mov eax, [rbp - 12]
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_term:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    call parse_unary
    test eax, eax
    js .error
    mov [rbp - 12], eax
.loop:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_MULTIPLICAR
    je .binary
    cmp eax, PABLO_TOKEN_DIVIDIR
    je .binary
    cmp eax, PABLO_TOKEN_MODULO
    jne .done
.binary:
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_unary
    test eax, eax
    js .error
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_BINARIO
    mov r8d, [rbp - 20]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 28], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 28]
    call get_ast_ptr
    mov edx, [rbp - 16]
    mov [rax + AST_aux], edx
    mov edx, [rbp - 12]
    mov [rax + AST_a], edx
    mov edx, [rbp - 24]
    mov [rax + AST_b], edx
    mov eax, [rbp - 28]
    mov [rbp - 12], eax
    jmp .loop
.done:
    mov eax, [rbp - 12]
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_unary:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    call current_type
    cmp eax, PABLO_TOKEN_NEGAR
    je .build_unary
    cmp eax, PABLO_TOKEN_RESTA
    jne .delegate
.build_unary:
    mov [rbp - 12], eax
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 16], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_unary
    test eax, eax
    js .error
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_UNARIO
    mov r8d, [rbp - 16]
    call new_ast_node
    test eax, eax
    js .error
    mov [rbp - 24], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 24]
    call get_ast_ptr
    mov edx, [rbp - 12]
    mov [rax + AST_aux], edx
    mov edx, [rbp - 20]
    mov [rax + AST_a], edx
    mov eax, [rbp - 24]
    jmp .fin
.delegate:
    mov rcx, [rbp - 8]
    call parse_primary
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_primary:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp - 8], rcx
    call current_type
    cmp eax, PABLO_TOKEN_ENTERO
    je .literal_int
    cmp eax, PABLO_TOKEN_LOGICO
    je .literal_bool
    cmp eax, PABLO_TOKEN_IDENTIFICADOR
    je .ident
    cmp eax, PABLO_TOKEN_PAR_IZQ
    je .paren
    mov rcx, [rbp - 8]
    mov edx, PABLO_PARSER_TOKEN_INESPERADO
    lea r8, [rel msg_expr]
    call parser_error_current
    mov eax, -1
    jmp .fin

.literal_int:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 12], eax
    mov rcx, [rbp - 8]
    mov edx, eax
    call get_token_ptr
    mov [rbp - 16], rax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_LITERAL_ENTERO
    mov r8d, [rbp - 12]
    call new_ast_node
    test eax, eax
    js .fin
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 20]
    call get_ast_ptr
    mov dword [rax + AST_tipo], PABLO_TIPO_INVALIDO
    mov rdx, [rbp - 16]
    mov rdx, [rdx + TOKEN_valor]
    mov [rax + AST_valor], rdx
    mov eax, [rbp - 20]
    jmp .fin

.literal_bool:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 12], eax
    mov rcx, [rbp - 8]
    mov edx, eax
    call get_token_ptr
    mov [rbp - 16], rax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_LITERAL_LOGICO
    mov r8d, [rbp - 12]
    call new_ast_node
    test eax, eax
    js .fin
    mov [rbp - 20], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 20]
    call get_ast_ptr
    mov dword [rax + AST_tipo], PABLO_TIPO_LOGICO
    mov rdx, [rbp - 16]
    mov rdx, [rdx + TOKEN_valor]
    mov [rax + AST_valor], rdx
    mov eax, [rbp - 20]
    jmp .fin

.ident:
    mov rcx, [rbp - 8]
    call current_index
    mov [rbp - 12], eax
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_PAR_IZQ
    jne .identifier_node
    mov rcx, [rbp - 8]
    call advance_token
    mov dword [rbp - 24], -1
    mov dword [rbp - 28], -1
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_PAR_DER
    je .finish_call_args
.call_loop:
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .fin
    cmp dword [rbp - 24], -1
    jne .append_arg
    mov [rbp - 24], eax
    mov [rbp - 28], eax
    jmp .after_arg
.append_arg:
    mov [rbp - 32], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 28]
    call get_ast_ptr
    mov edx, [rbp - 32]
    mov [rax + AST_next], edx
    mov eax, [rbp - 32]
    mov [rbp - 28], eax
.after_arg:
    mov rcx, [rbp - 8]
    call current_type
    cmp eax, PABLO_TOKEN_COMA
    jne .finish_call_args
    mov rcx, [rbp - 8]
    call advance_token
    jmp .call_loop
.finish_call_args:
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_DER
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .fin
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_LLAMADA
    mov r8d, [rbp - 12]
    call new_ast_node
    test eax, eax
    js .fin
    mov [rbp - 36], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 36]
    call get_ast_ptr
    mov edx, [rbp - 24]
    mov [rax + AST_a], edx
    mov eax, [rbp - 36]
    jmp .fin

.identifier_node:
    mov rcx, [rbp - 8]
    mov edx, PABLO_AST_IDENTIFICADOR
    mov r8d, [rbp - 12]
    call new_ast_node
    jmp .fin

.paren:
    mov rcx, [rbp - 8]
    call advance_token
    mov rcx, [rbp - 8]
    call parse_expression
    test eax, eax
    js .fin
    mov [rbp - 40], eax
    mov rcx, [rbp - 8]
    mov edx, PABLO_TOKEN_PAR_DER
    lea r8, [rel msg_inesperado]
    call expect_token
    test eax, eax
    js .fin
    mov eax, [rbp - 40]
.fin:
    mov rsp, rbp
    pop rbp
    ret

current_index:
    mov eax, [rcx + CTX_current_token]
    ret

current_type:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 8], rcx
    mov edx, [rcx + CTX_current_token]
    call get_token_ptr
    mov eax, [rax + TOKEN_tipo]
    mov rcx, [rbp - 8]
    mov rsp, rbp
    pop rbp
    ret

advance_token:
    inc dword [rcx + CTX_current_token]
    ret

expect_token:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 24], r8
    mov eax, [rcx + CTX_current_token]
    mov [rbp - 16], eax
    mov edx, eax
    call get_token_ptr
    mov edx, [rax + TOKEN_tipo]
    cmp edx, [rbp - 12]
    je .ok
    mov rcx, [rbp - 8]
    mov edx, PABLO_PARSER_TOKEN_INESPERADO
    mov r8, [rbp - 24]
    call parser_error_current
    mov eax, -1
    jmp .fin
.ok:
    mov rcx, [rbp - 8]
    call advance_token
    mov eax, [rbp - 16]
.fin:
    mov rsp, rbp
    pop rbp
    ret

parse_type_ref:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 8], rcx
    mov eax, [rcx + CTX_current_token]
    mov edx, eax
    call get_token_ptr
    mov edx, [rax + TOKEN_tipo]
    call pablo_map_type_token
    cmp eax, PABLO_TIPO_INVALIDO
    jne .ok
    mov rcx, [rbp - 8]
    mov edx, PABLO_PARSER_TOKEN_INESPERADO
    lea r8, [rel msg_tipo]
    call parser_error_current
    jmp .fin
.ok:
    mov rcx, [rbp - 8]
    call advance_token
.fin:
    mov rsp, rbp
    pop rbp
    ret

consume_funcion:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx
    call current_type
    cmp eax, PABLO_TOKEN_FUNCION
    je .ok
    cmp eax, PABLO_TOKEN_IDENTIFICADOR
    jne .error
    mov rcx, [rbp - 8]
    mov edx, [rcx + CTX_current_token]
    lea r8, [rel kw_funcion]
    call token_matches
    test eax, eax
    jz .error
.ok:
    mov eax, [rcx + CTX_current_token]
    mov rcx, [rbp - 8]
    call advance_token
    jmp .fin
.error:
    mov rcx, [rbp - 8]
    mov edx, PABLO_PARSER_TOKEN_INESPERADO
    lea r8, [rel msg_funcion]
    call parser_error_current
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

token_matches:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 24], r8
    call pablo_token_text
    mov r8, [rbp - 24]
    mov rcx, rax
    call pablo_range_equals_cstr
    mov rsp, rbp
    pop rbp
    ret

new_ast_node:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 16], r8d
    call ast_alloc
    test rax, rax
    jnz .ok
    mov rcx, [rbp - 8]
    mov edx, PABLO_PARSER_MAX_AST
    lea r8, [rel msg_ast]
    call parser_error_current
    mov eax, -1
    jmp .fin
.ok:
    mov [rbp - 20], edx
    mov edx, [rbp - 12]
    mov [rax + AST_kind], edx
    mov edx, [rbp - 16]
    mov [rax + AST_token], edx
    mov eax, [rbp - 20]
.fin:
    mov rsp, rbp
    pop rbp
    ret

parser_error_current:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rsp + 32], r8
    mov r9d, [rcx + CTX_current_token]
    mov r8d, edx
    mov edx, PABLO_ETAPA_PARSER
    call pablo_set_error_token
    mov rsp, rbp
    pop rbp
    ret
