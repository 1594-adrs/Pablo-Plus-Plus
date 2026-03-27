default rel

%include "pablocc.inc"
%include "sintaxis.inc"
%include "compilador.inc"

extern get_ast_ptr
extern get_function_ptr
extern get_local_ptr
extern token_alloc
extern ast_alloc
extern function_alloc
extern local_alloc
extern pablo_token_equals_token
extern pablo_set_error_token
extern pablo_align16
extern pablo_range_equals_cstr
extern pablo_token_text

global semantic_preparar

section .rdata
entry_name db "historiaPrincipal", 0
builtin_imprimir_entero8 db "imprimirEntero8", 0
builtin_imprimir_entero16 db "imprimirEntero16", 0
builtin_imprimir_entero32 db "imprimirEntero32", 0
builtin_imprimir_entero64 db "imprimirEntero64", 0
builtin_imprimir_natural8 db "imprimirNatural8", 0
builtin_imprimir_natural16 db "imprimirNatural16", 0
builtin_imprimir_natural32 db "imprimirNatural32", 0
builtin_imprimir_natural64 db "imprimirNatural64", 0
builtin_imprimir_logico db "imprimirLogico", 0
builtin_imprimir_linea db "imprimirLinea", 0

msg_func_dup db "La funcion ya fue declarada.", 0
msg_historia_falt db "No existe historiaPrincipal().", 0
msg_historia_inv db "historiaPrincipal() debe devolver entero32 y no recibir parametros.", 0
msg_ident_desconocido db "Identificador no resuelto en el alcance actual.", 0
msg_llamada_invalida db "Llamada de funcion invalida o aridad incompatible.", 0
msg_tipo_unsupported db "Tipo reconocido pero aun no soportado por el hito ejecutable.", 0
msg_tipo_incompatible db "Tipos incompatibles en una expresion o retorno.", 0
msg_stmt_no_soportado db "Sentencia aun no soportada por la semantica actual.", 0
msg_var_dup db "La variable ya fue declarada en este alcance.", 0
msg_condicion db "La condicion debe ser de tipo logico.", 0
msg_control_fuera_bucle db "La sentencia solo puede usarse dentro de un bucle.", 0
msg_retorno_invalido db "La sentencia devolver no coincide con el tipo de retorno de la funcion.", 0
msg_constante_asignacion db "No se puede asignar a una constante.", 0
msg_externa_invalida db "Las funciones externas solo admiten firma y no cuerpo.", 0
msg_builtin_func_space db "No hubo espacio para registrar las primitivas internas del runtime.", 0
msg_builtin_token_space db "No hubo espacio para registrar los nombres internos del runtime.", 0
msg_builtin_ast_space db "No hubo espacio para registrar las firmas internas del runtime.", 0

section .text
semantic_preparar:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    mov rcx, [rbp - 8]
    mov dword [rcx + CTX_function_count], 0
    call register_builtin_functions
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    mov edx, 0
    call get_ast_ptr
    mov eax, [rax + AST_a]
    mov [rbp - 12], eax
.register_loop:
    cmp dword [rbp - 12], -1
    je .validate_entry
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call register_function
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov eax, [rax + AST_next]
    mov [rbp - 12], eax
    jmp .register_loop

.validate_entry:
    mov rcx, [rbp - 8]
    call ensure_entrypoint
    test eax, eax
    js .error

    mov rcx, [rbp - 8]
    mov edx, 0
    call get_ast_ptr
    mov eax, [rax + AST_a]
    mov [rbp - 16], eax
.analyze_loop:
    cmp dword [rbp - 16], -1
    je .ok
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call analyze_function
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov eax, [rax + AST_next]
    mov [rbp - 16], eax
    jmp .analyze_loop

.ok:
    xor eax, eax
    jmp .fin
.error:
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

register_builtin_functions:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 8], rcx

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_entero8]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_ENTERO8
    call register_builtin_function
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_entero16]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_ENTERO16
    call register_builtin_function
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_entero32]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_ENTERO32
    call register_builtin_function
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_entero64]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_ENTERO64
    call register_builtin_function
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_natural8]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_NATURAL8
    call register_builtin_function
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_natural16]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_NATURAL16
    call register_builtin_function
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_natural32]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_NATURAL32
    call register_builtin_function
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_natural64]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_NATURAL64
    call register_builtin_function
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_logico]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_LOGICO
    call register_builtin_function
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    lea rdx, [rel builtin_imprimir_linea]
    mov r8d, PABLO_TIPO_VACIO
    mov r9d, PABLO_TIPO_INVALIDO
    call register_builtin_function

.fin:
    mov rsp, rbp
    pop rbp
    ret

register_builtin_function:
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp - 8], rcx
    mov [rbp - 16], rdx
    mov [rbp - 20], r8d
    mov [rbp - 24], r9d

    mov rcx, [rbp - 8]
    mov rdx, [rbp - 16]
    call create_builtin_name_token
    test eax, eax
    js .fin
    mov [rbp - 28], eax

    mov rcx, [rbp - 8]
    call function_alloc
    test rax, rax
    jnz .have_function
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_MAX_FUNCTIONS
    lea r8, [rel msg_builtin_func_space]
    call semantic_error_simple
    mov eax, -1
    jmp .fin

.have_function:
    mov [rbp - 40], rax
    mov [rbp - 44], edx
    mov edx, [rbp - 28]
    mov [rax + FUNC_name_token], edx
    mov edx, [rbp - 20]
    mov [rax + FUNC_return_type], edx
    mov edx, [rbp - 44]
    mov [rax + FUNC_label_id], edx
    mov dword [rax + FUNC_flags], PABLO_FUNC_FLAG_EXTERNA | PABLO_FUNC_FLAG_BUILTIN_RUNTIME
    mov dword [rax + FUNC_first_param], -1
    mov dword [rax + FUNC_param_count], 0

    cmp dword [rbp - 24], PABLO_TIPO_INVALIDO
    je .ok

    mov rcx, [rbp - 8]
    call ast_alloc
    test rax, rax
    jnz .have_param
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_MAX_AST
    lea r8, [rel msg_builtin_ast_space]
    call semantic_error_simple
    mov eax, -1
    jmp .fin

.have_param:
    mov [rbp - 56], rax
    mov [rbp - 60], edx
    mov dword [rax + AST_kind], PABLO_AST_PARAMETRO
    mov dword [rax + AST_token], -1
    mov edx, [rbp - 24]
    mov [rax + AST_tipo], edx
    mov dword [rax + AST_next], -1
    mov rax, [rbp - 40]
    mov edx, [rbp - 60]
    mov [rax + FUNC_first_param], edx
    mov dword [rax + FUNC_param_count], 1

.ok:
    xor eax, eax
.fin:
    mov rsp, rbp
    pop rbp
    ret

create_builtin_name_token:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp - 8], rcx
    mov [rbp - 16], rdx

    xor eax, eax
.len_loop:
    cmp byte [rdx + rax], 0
    je .len_done
    inc eax
    jmp .len_loop
.len_done:
    mov [rbp - 20], eax

    mov rcx, [rbp - 8]
    mov rax, [rcx + CTX_source_length]
    mov [rbp - 32], rax
    mov edx, [rbp - 20]
    movsxd rdx, edx
    add rax, rdx
    inc rax
    cmp rax, PABLO_MAX_SOURCE_BYTES
    jbe .space_ok
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_MAX_TOKENS
    lea r8, [rel msg_builtin_token_space]
    call semantic_error_simple
    mov eax, -1
    jmp .fin

.space_ok:
    mov rcx, [rbp - 8]
    call token_alloc
    test rax, rax
    jnz .token_ok
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_MAX_TOKENS
    lea r8, [rel msg_builtin_token_space]
    call semantic_error_simple
    mov eax, -1
    jmp .fin

.token_ok:
    mov [rbp - 40], rax
    mov [rbp - 44], edx
    mov rcx, [rbp - 8]
    mov rax, [rcx + CTX_source_buffer]
    add rax, [rbp - 32]
    mov [rbp - 56], rax

    xor r8d, r8d
.copy_loop:
    mov eax, [rbp - 20]
    cmp r8d, eax
    jae .copy_done
    mov rax, [rbp - 16]
    mov dl, [rax + r8]
    mov rax, [rbp - 56]
    mov [rax + r8], dl
    inc r8d
    jmp .copy_loop
.copy_done:
    mov rax, [rbp - 56]
    mov byte [rax + r8], 0

    mov rax, [rbp - 40]
    mov dword [rax + TOKEN_tipo], PABLO_TOKEN_IDENTIFICADOR
    mov dword [rax + TOKEN_linea], 0
    mov dword [rax + TOKEN_columna], 0
    mov ecx, [rbp - 20]
    mov [rax + TOKEN_longitud], ecx
    mov rcx, [rbp - 32]
    mov [rax + TOKEN_offset], rcx
    mov qword [rax + TOKEN_valor], 0

    mov rcx, [rbp - 8]
    mov rax, [rbp - 32]
    mov edx, [rbp - 20]
    movsxd rdx, edx
    add rax, rdx
    inc rax
    mov [rcx + CTX_source_length], rax

    mov eax, [rbp - 44]
.fin:
    mov rsp, rbp
    pop rbp
    ret

register_function:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 88
    mov [rbp - 8], rcx
    mov [rbp - 12], edx

    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov [rbp - 24], rax
    mov eax, [rax + AST_token]
    mov [rbp - 16], eax

    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call lookup_function
    test eax, eax
    js .new_function
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_FUNCION_DUPLICADA
    mov r8d, [rbp - 16]
    lea r9, [rel msg_func_dup]
    call semantic_error_token
    mov eax, -1
    jmp .fin

.new_function:
    mov rcx, [rbp - 8]
    call function_alloc
    test rax, rax
    jnz .fill
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_MAX_FUNCTIONS
    lea r8, [rel msg_func_dup]
    call semantic_error_simple
    mov eax, -1
    jmp .fin

.fill:
    mov [rbp - 32], rax
    mov [rbp - 36], edx
    mov rcx, [rbp - 24]
    mov edx, [rcx + AST_kind]
    cmp edx, PABLO_AST_DECLARACION_EXTERNA
    jne .not_externa
    mov dword [rax + FUNC_flags], PABLO_FUNC_FLAG_EXTERNA
.not_externa:
    mov edx, [rcx + AST_token]
    mov rax, [rbp - 32]
    mov [rax + FUNC_name_token], edx
    mov edx, [rcx + AST_tipo]
    mov [rax + FUNC_return_type], edx
    mov edx, [rcx + AST_a]
    mov [rax + FUNC_first_param], edx
    mov edx, [rcx + AST_b]
    mov [rax + FUNC_body_node], edx
    mov edx, [rbp - 36]
    mov [rax + FUNC_label_id], edx

    xor ebx, ebx
    mov eax, [rcx + AST_a]
    mov [rbp - 40], eax
.count_params:
    cmp dword [rbp - 40], -1
    je .store_count
    inc ebx
    mov rcx, [rbp - 8]
    mov edx, [rbp - 40]
    call get_ast_ptr
    mov eax, [rax + AST_next]
    mov [rbp - 40], eax
    jmp .count_params
.store_count:
    mov rax, [rbp - 32]
    mov [rax + FUNC_param_count], ebx
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov edx, [rbp - 36]
    mov [rax + AST_aux], edx
    xor eax, eax
.fin:
    add rsp, 88
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

ensure_entrypoint:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 72
    mov [rbp - 8], rcx
    mov dword [rbp - 12], -1
    xor ebx, ebx
.loop:
    cmp ebx, [rcx + CTX_function_count]
    jge .after
    mov edx, ebx
    call get_function_ptr
    mov [rbp - 24], rax
    mov rcx, [rbp - 8]
    mov edx, [rax + FUNC_name_token]
    lea r8, [rel entry_name]
    call token_matches_name
    test eax, eax
    jz .next
    cmp dword [rbp - 12], -1
    jne .invalid
    mov [rbp - 12], ebx
.next:
    mov rcx, [rbp - 8]
    inc ebx
    jmp .loop
.after:
    cmp dword [rbp - 12], -1
    jne .validate
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_HISTORIA_FALTANTE
    lea r8, [rel msg_historia_falt]
    call semantic_error_simple
    mov eax, -1
    jmp .fin
.validate:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_function_ptr
    test dword [rax + FUNC_flags], PABLO_FUNC_FLAG_EXTERNA
    jnz .invalid
    cmp dword [rax + FUNC_param_count], 0
    jne .invalid
    cmp dword [rax + FUNC_return_type], PABLO_TIPO_ENTERO32
    jne .invalid
    xor eax, eax
    jmp .fin
.invalid:
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_HISTORIA_INVALIDA
    lea r8, [rel msg_historia_inv]
    call semantic_error_simple
    mov eax, -1
.fin:
    add rsp, 72
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

analyze_function:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 104
    mov [rbp - 8], rcx
    mov [rbp - 12], edx

    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov [rbp - 24], rax
    mov eax, [rax + AST_aux]
    mov [rbp - 16], eax

    mov rcx, [rbp - 8]
    mov dword [rcx + CTX_local_count], 0
    mov dword [rcx + CTX_current_slot], 0
    mov dword [rcx + CTX_max_slot], 0
    mov dword [rcx + CTX_current_depth], 0
    mov dword [rcx + CTX_loop_depth], 0
    mov eax, [rbp - 16]
    mov [rcx + CTX_current_function], eax

    mov rax, [rbp - 24]
    mov eax, [rax + AST_tipo]
    mov edx, eax
    call is_valid_return_type
    test eax, eax
    jnz .maybe_externa
    mov rax, [rbp - 24]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_tipo_unsupported]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_TIPO_NO_SOPORTADO
    call semantic_error_token
    mov eax, -1
    jmp .fin

.maybe_externa:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_function_ptr
    test dword [rax + FUNC_flags], PABLO_FUNC_FLAG_EXTERNA
    jz .params
    xor eax, eax
    jmp .fin

.params:
    mov rax, [rbp - 24]
    mov eax, [rax + AST_a]
    mov [rbp - 48], eax
    xor ebx, ebx
.params_loop:
    cmp dword [rbp - 48], -1
    je .body
    mov rcx, [rbp - 8]
    mov edx, [rbp - 48]
    call get_ast_ptr
    mov [rbp - 32], rax

    mov eax, [rax + AST_tipo]
    mov edx, eax
    call is_valid_storage_type
    test eax, eax
    jnz .param_type_ok
    mov rax, [rbp - 32]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_TIPO_NO_SOPORTADO
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_tipo_unsupported]
    call semantic_error_token
    mov eax, -1
    jmp .fin

.param_type_ok:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_token]
    mov r8d, 0
    mov rcx, [rbp - 8]
    call lookup_local_in_depth
    test eax, eax
    js .alloc_param
    mov rax, [rbp - 32]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_var_dup]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_VARIABLE_DUPLICADA
    call semantic_error_token
    mov eax, -1
    jmp .fin

.alloc_param:
    mov rcx, [rbp - 8]
    call local_alloc
    test rax, rax
    jnz .fill_param
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_MAX_LOCALS
    lea r8, [rel msg_stmt_no_soportado]
    call semantic_error_simple
    mov eax, -1
    jmp .fin

.fill_param:
    mov [rbp - 40], rax
    mov rdx, [rbp - 32]
    mov ecx, [rdx + AST_token]
    mov rax, [rbp - 40]
    mov [rax + LOCAL_name_token], ecx
    mov ecx, [rdx + AST_tipo]
    mov [rax + LOCAL_type], ecx
    mov dword [rax + LOCAL_depth], 0
    mov dword [rax + LOCAL_is_param], 1
    mov [rax + LOCAL_param_ordinal], ebx
    mov dword [rax + LOCAL_active], 1
    mov dword [rax + LOCAL_flags], PABLO_LOCAL_FLAG_PARAM

    mov rcx, [rbp - 8]
    mov edx, [rcx + CTX_current_slot]
    inc edx
    mov [rcx + CTX_current_slot], edx
    mov eax, [rcx + CTX_max_slot]
    cmp edx, eax
    jle .slot_param_ok
    mov [rcx + CTX_max_slot], edx
.slot_param_ok:
    mov eax, edx
    shl eax, 3
    mov [rbp - 44], eax
    mov rdx, [rbp - 40]
    mov ecx, [rbp - 44]
    mov [rdx + LOCAL_slot_offset], ecx
    mov rdx, [rbp - 32]
    mov ecx, [rbp - 44]
    mov [rdx + AST_aux], ecx

    inc ebx
    mov rax, [rbp - 32]
    mov eax, [rax + AST_next]
    mov [rbp - 48], eax
    jmp .params_loop

.body:
    mov rax, [rbp - 24]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 8]
    call analyze_block
    test eax, eax
    js .fin

    mov rcx, [rbp - 8]
    mov ecx, [rcx + CTX_max_slot]
    shl ecx, 3
    call pablo_align16
    mov [rbp - 52], eax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_function_ptr
    mov edx, [rbp - 52]
    mov [rax + FUNC_stack_size], edx
    xor eax, eax
.fin:
    add rsp, 104
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

analyze_block:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    mov [rbp - 12], edx

    mov rcx, [rbp - 8]
    inc dword [rcx + CTX_current_depth]
    mov eax, [rcx + CTX_current_depth]
    mov [rbp - 16], eax

    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov eax, [rax + AST_a]
    mov [rbp - 20], eax
.loop:
    cmp dword [rbp - 20], -1
    je .close_scope
    mov rcx, [rbp - 8]
    mov edx, [rbp - 20]
    call analyze_statement
    test eax, eax
    js .error
    mov rcx, [rbp - 8]
    mov edx, [rbp - 20]
    call get_ast_ptr
    mov eax, [rax + AST_next]
    mov [rbp - 20], eax
    jmp .loop

.close_scope:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call deactivate_locals_in_depth
    mov rcx, [rbp - 8]
    dec dword [rcx + CTX_current_depth]
    xor eax, eax
    jmp .fin
.error:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call deactivate_locals_in_depth
    mov rcx, [rbp - 8]
    dec dword [rcx + CTX_current_depth]
    mov eax, -1
.fin:
    mov rsp, rbp
    pop rbp
    ret

analyze_statement:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 176
    mov [rbp - 8], rcx
    mov [rbp - 12], edx

    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov [rbp - 24], rax
    mov edx, [rax + AST_kind]
    cmp edx, PABLO_AST_BLOQUE
    je .stmt_block
    cmp edx, PABLO_AST_DECLARACION_VARIABLE
    je .stmt_var
    cmp edx, PABLO_AST_DECLARACION_CONSTANTE
    je .stmt_const
    cmp edx, PABLO_AST_SENTENCIA_DEVOLVER
    je .stmt_return
    cmp edx, PABLO_AST_SENTENCIA_SI
    je .stmt_if
    cmp edx, PABLO_AST_SENTENCIA_MIENTRAS
    je .stmt_while
    cmp edx, PABLO_AST_SENTENCIA_PARA
    je .stmt_para
    cmp edx, PABLO_AST_SENTENCIA_EXPRESION
    je .stmt_expr
    cmp edx, PABLO_AST_SENTENCIA_CONTINUAR
    je .stmt_continue
    cmp edx, PABLO_AST_SENTENCIA_ROMPER
    je .stmt_break
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_stmt_no_soportado]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_TIPO_INCOMPATIBLE
    call semantic_error_token
    mov eax, -1
    jmp .fin

.stmt_block:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call analyze_block
    jmp .fin

.stmt_var:
    xor ebx, ebx
    jmp .stmt_binding

.stmt_const:
    mov ebx, PABLO_LOCAL_FLAG_CONST

.stmt_binding:
    mov eax, [rax + AST_tipo]
    mov edx, eax
    call is_valid_storage_type
    test eax, eax
    jnz .stmt_var_type_ok
    mov rax, [rbp - 24]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_tipo_unsupported]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_TIPO_NO_SOPORTADO
    call semantic_error_token
    mov eax, -1
    jmp .fin

.stmt_var_type_ok:
    mov rax, [rbp - 24]
    mov edx, [rax + AST_token]
    mov rcx, [rbp - 8]
    mov r8d, [rcx + CTX_current_depth]
    call lookup_local_in_depth
    test eax, eax
    js .alloc_local
    mov rax, [rbp - 24]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_var_dup]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_VARIABLE_DUPLICADA
    call semantic_error_token
    mov eax, -1
    jmp .fin

.alloc_local:
    mov rcx, [rbp - 8]
    call local_alloc
    test rax, rax
    jnz .fill_local
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_MAX_LOCALS
    lea r8, [rel msg_stmt_no_soportado]
    call semantic_error_simple
    mov eax, -1
    jmp .fin

.fill_local:
    mov [rbp - 32], rax
    mov rdx, [rbp - 24]
    mov ecx, [rdx + AST_token]
    mov rax, [rbp - 32]
    mov [rax + LOCAL_name_token], ecx
    mov ecx, [rdx + AST_tipo]
    mov [rax + LOCAL_type], ecx
    mov rcx, [rbp - 8]
    mov ecx, [rcx + CTX_current_depth]
    mov [rax + LOCAL_depth], ecx
    mov dword [rax + LOCAL_is_param], 0
    mov dword [rax + LOCAL_param_ordinal], -1
    mov dword [rax + LOCAL_active], 1
    mov rdx, [rbp - 24]
    cmp dword [rdx + AST_kind], PABLO_AST_DECLARACION_CONSTANTE
    jne .store_local_flags
    mov ebx, PABLO_LOCAL_FLAG_CONST
.store_local_flags:
    mov [rax + LOCAL_flags], ebx

    mov rcx, [rbp - 8]
    mov edx, [rcx + CTX_current_slot]
    inc edx
    mov [rcx + CTX_current_slot], edx
    mov eax, [rcx + CTX_max_slot]
    cmp edx, eax
    jle .slot_local_ok
    mov [rcx + CTX_max_slot], edx
.slot_local_ok:
    mov eax, edx
    shl eax, 3
    mov [rbp - 36], eax
    mov rdx, [rbp - 32]
    mov ecx, [rbp - 36]
    mov [rdx + LOCAL_slot_offset], ecx
    mov rdx, [rbp - 24]
    mov ecx, [rbp - 36]
    mov [rdx + AST_aux], ecx

    mov eax, [rdx + AST_a]
    cmp eax, -1
    je .ok
    mov rcx, [rbp - 8]
    mov edx, eax
    mov rax, [rbp - 24]
    mov r8d, [rax + AST_tipo]
    call analyze_expression_expected
    jmp .fin

.stmt_return:
    mov rcx, [rbp - 8]
    mov edx, [rcx + CTX_current_function]
    call get_function_ptr
    mov [rbp - 40], rax
    mov eax, [rax + FUNC_return_type]
    cmp eax, PABLO_TIPO_VACIO
    jne .stmt_return_value
    mov rax, [rbp - 24]
    cmp dword [rax + AST_a], -1
    je .ok
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_retorno_invalido]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_RETORNO_INVALIDO
    call semantic_error_token
    mov eax, -1
    jmp .fin

.stmt_return_value:
    mov rax, [rbp - 24]
    mov edx, [rax + AST_a]
    cmp edx, -1
    jne .stmt_return_expr
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_retorno_invalido]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_RETORNO_INVALIDO
    call semantic_error_token
    mov eax, -1
    jmp .fin

.stmt_return_expr:
    mov rcx, [rbp - 8]
    mov rax, [rbp - 40]
    mov r8d, [rax + FUNC_return_type]
    mov rax, [rbp - 24]
    mov edx, [rax + AST_a]
    call analyze_expression_expected
    jmp .fin

.stmt_if:
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 8]
    mov r8d, PABLO_TIPO_LOGICO
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov rax, [rbp - 24]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 8]
    call analyze_statement
    test eax, eax
    js .fin
    mov rax, [rbp - 24]
    mov edx, [rax + AST_c]
    cmp edx, -1
    je .ok
    mov rcx, [rbp - 8]
    call analyze_statement
    jmp .fin

.stmt_while:
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 8]
    mov r8d, PABLO_TIPO_LOGICO
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov rcx, [rbp - 8]
    inc dword [rcx + CTX_loop_depth]
    mov rax, [rbp - 24]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 8]
    call analyze_statement
    mov rcx, [rbp - 8]
    dec dword [rcx + CTX_loop_depth]
    jmp .fin

.stmt_para:
    mov rcx, [rbp - 8]
    inc dword [rcx + CTX_current_depth]
    mov eax, [rcx + CTX_current_depth]
    mov [rbp - 44], eax

    mov rax, [rbp - 24]
    mov edx, [rax + AST_a]
    cmp edx, -1
    je .stmt_para_cond
    mov rcx, [rbp - 8]
    call analyze_statement
    test eax, eax
    js .stmt_para_error

.stmt_para_cond:
    mov rax, [rbp - 24]
    mov edx, [rax + AST_b]
    cmp edx, -1
    je .stmt_para_body
    mov rcx, [rbp - 8]
    mov r8d, PABLO_TIPO_LOGICO
    call analyze_expression_expected
    test eax, eax
    js .stmt_para_error

.stmt_para_body:
    mov rcx, [rbp - 8]
    inc dword [rcx + CTX_loop_depth]
    mov rax, [rbp - 24]
    mov edx, [rax + AST_c]
    mov rcx, [rbp - 8]
    call analyze_statement
    mov rcx, [rbp - 8]
    dec dword [rcx + CTX_loop_depth]
    test eax, eax
    js .stmt_para_error

    mov rax, [rbp - 24]
    mov edx, [rax + AST_valor]
    cmp edx, -1
    je .stmt_para_close
    mov rcx, [rbp - 8]
    mov r8d, PABLO_TIPO_INVALIDO
    call analyze_expression_expected
    test eax, eax
    js .stmt_para_error

.stmt_para_close:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 44]
    call deactivate_locals_in_depth
    mov rcx, [rbp - 8]
    dec dword [rcx + CTX_current_depth]
    xor eax, eax
    jmp .fin

.stmt_para_error:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 44]
    call deactivate_locals_in_depth
    mov rcx, [rbp - 8]
    dec dword [rcx + CTX_current_depth]
    mov eax, -1
    jmp .fin

.stmt_expr:
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 8]
    mov r8d, PABLO_TIPO_INVALIDO
    call analyze_expression_expected
    jmp .fin

.stmt_continue:
    mov rcx, [rbp - 8]
    cmp dword [rcx + CTX_loop_depth], 0
    jg .ok
    mov rax, [rbp - 24]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_control_fuera_bucle]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_CONTROL_INVALIDO
    call semantic_error_token
    mov eax, -1
    jmp .fin

.stmt_break:
    mov rcx, [rbp - 8]
    cmp dword [rcx + CTX_loop_depth], 0
    jg .ok
    mov rax, [rbp - 24]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_control_fuera_bucle]
    mov rcx, [rbp - 8]
    mov edx, PABLO_SEMA_CONTROL_INVALIDO
    call semantic_error_token
    mov eax, -1
    jmp .fin

.ok:
    xor eax, eax
.fin:
    add rsp, 176
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

analyze_expression:
    mov r8d, PABLO_TIPO_INVALIDO
    jmp analyze_expression_expected

analyze_expression_expected:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 160
    mov [rbp - 16], rcx
    mov [rbp - 20], edx
    mov [rbp - 24], r8d

    mov rcx, [rbp - 16]
    mov edx, [rbp - 20]
    call get_ast_ptr
    mov [rbp - 32], rax
    mov edx, [rax + AST_kind]
    cmp edx, PABLO_AST_LITERAL_ENTERO
    je .literal_int
    cmp edx, PABLO_AST_LITERAL_LOGICO
    je .literal_bool
    cmp edx, PABLO_AST_IDENTIFICADOR
    je .identifier
    cmp edx, PABLO_AST_LLAMADA
    je .call
    cmp edx, PABLO_AST_UNARIO
    je .unary
    cmp edx, PABLO_AST_BINARIO
    je .binary
    cmp edx, PABLO_AST_ASIGNACION
    je .assign
    mov eax, -1
    jmp .fin

.literal_int:
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .literal_default
    mov edx, eax
    call is_arithmetic_type
    test eax, eax
    jz .type_error
    mov rax, [rbp - 32]
    mov rdx, [rax + AST_valor]
    mov ecx, [rbp - 24]
    call literal_fits_type
    test eax, eax
    jz .type_error
    mov rax, [rbp - 32]
    mov ecx, [rbp - 24]
    mov [rax + AST_tipo], ecx
    mov eax, ecx
    jmp .fin

.literal_default:
    mov rax, [rbp - 32]
    mov dword [rax + AST_tipo], PABLO_TIPO_ENTERO32
    mov eax, PABLO_TIPO_ENTERO32
    jmp .fin

.literal_bool:
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .literal_bool_ok
    cmp eax, PABLO_TIPO_LOGICO
    jne .type_error
.literal_bool_ok:
    mov rax, [rbp - 32]
    mov dword [rax + AST_tipo], PABLO_TIPO_LOGICO
    mov eax, PABLO_TIPO_LOGICO
    jmp .fin

.identifier:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_token]
    mov rcx, [rbp - 16]
    call lookup_local
    test eax, eax
    js .ident_error
    mov [rbp - 40], eax
    mov rcx, [rbp - 16]
    mov edx, eax
    call get_local_ptr
    mov [rbp - 48], rax
    mov rdx, [rbp - 32]
    mov ecx, [rax + LOCAL_slot_offset]
    mov [rdx + AST_aux], ecx
    mov ecx, [rax + LOCAL_type]
    mov [rdx + AST_tipo], ecx
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .identifier_ok
    cmp eax, [rdx + AST_tipo]
    jne .type_error
.identifier_ok:
    mov eax, [rdx + AST_tipo]
    jmp .fin

.call:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_token]
    mov rcx, [rbp - 16]
    call lookup_function
    test eax, eax
    js .call_error
    mov [rbp - 40], eax
    mov rcx, [rbp - 16]
    mov edx, eax
    call get_function_ptr
    mov [rbp - 48], rax
    mov rdx, [rbp - 32]
    mov ecx, [rbp - 40]
    mov [rdx + AST_aux], ecx
    mov ecx, [rax + FUNC_return_type]
    mov [rdx + AST_tipo], ecx

    mov eax, [rdx + AST_a]
    mov [rbp - 52], eax
    mov rax, [rbp - 48]
    mov eax, [rax + FUNC_first_param]
    mov [rbp - 56], eax
.call_arg_loop:
    cmp dword [rbp - 52], -1
    je .call_args_done
    cmp dword [rbp - 56], -1
    je .call_error
    mov rcx, [rbp - 16]
    mov edx, [rbp - 56]
    call get_ast_ptr
    mov r8d, [rax + AST_tipo]
    mov rcx, [rbp - 16]
    mov edx, [rbp - 52]
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov rcx, [rbp - 16]
    mov edx, [rbp - 52]
    call get_ast_ptr
    mov eax, [rax + AST_next]
    mov [rbp - 52], eax
    mov rcx, [rbp - 16]
    mov edx, [rbp - 56]
    call get_ast_ptr
    mov eax, [rax + AST_next]
    mov [rbp - 56], eax
    jmp .call_arg_loop

.call_args_done:
    cmp dword [rbp - 56], -1
    jne .call_error
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .call_ok
    mov rdx, [rbp - 32]
    cmp eax, [rdx + AST_tipo]
    jne .type_error
.call_ok:
    mov rax, [rbp - 32]
    mov eax, [rax + AST_tipo]
    jmp .fin

.unary:
    mov rax, [rbp - 32]
    mov ecx, [rax + AST_aux]
    cmp ecx, PABLO_TOKEN_RESTA
    je .unary_minus
    cmp ecx, PABLO_TOKEN_NEGAR
    je .unary_not
    jmp .type_error

.unary_minus:
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .unary_minus_infer
    mov edx, eax
    call is_signed_type
    test eax, eax
    jz .type_error
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8d, [rbp - 24]
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov rax, [rbp - 32]
    mov ecx, [rbp - 24]
    mov [rax + AST_tipo], ecx
    mov eax, ecx
    jmp .fin

.unary_minus_infer:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8d, PABLO_TIPO_INVALIDO
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov [rbp - 60], eax
    mov edx, eax
    call is_signed_type
    test eax, eax
    jz .type_error
    mov rax, [rbp - 32]
    mov ecx, [rbp - 60]
    mov [rax + AST_tipo], ecx
    mov eax, ecx
    jmp .fin

.unary_not:
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .unary_not_ok
    cmp eax, PABLO_TIPO_LOGICO
    jne .type_error
.unary_not_ok:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8d, PABLO_TIPO_LOGICO
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov rax, [rbp - 32]
    mov dword [rax + AST_tipo], PABLO_TIPO_LOGICO
    mov eax, PABLO_TIPO_LOGICO
    jmp .fin

.binary:
    mov rax, [rbp - 32]
    mov ecx, [rax + AST_aux]
    mov [rbp - 64], ecx
    cmp ecx, PABLO_TOKEN_Y_LOGICO
    je .binary_logical
    cmp ecx, PABLO_TOKEN_O_LOGICO
    je .binary_logical
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .binary_default_operands
    mov edx, eax
    call is_arithmetic_type
    test eax, eax
    jz .binary_default_operands
    mov eax, [rbp - 64]
    cmp eax, PABLO_TOKEN_SUMA
    je .binary_expected_operands
    cmp eax, PABLO_TOKEN_RESTA
    je .binary_expected_operands
    cmp eax, PABLO_TOKEN_MULTIPLICAR
    je .binary_expected_operands
    cmp eax, PABLO_TOKEN_DIVIDIR
    je .binary_expected_operands
    cmp eax, PABLO_TOKEN_MODULO
    jne .binary_default_operands

.binary_expected_operands:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8d, [rbp - 24]
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov [rbp - 68], eax
    mov rax, [rbp - 32]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 16]
    mov r8d, [rbp - 24]
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov [rbp - 72], eax
    jmp .binary_types_ready

.binary_default_operands:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8d, PABLO_TIPO_INVALIDO
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov [rbp - 68], eax

    mov rax, [rbp - 32]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 16]
    mov r8d, PABLO_TIPO_INVALIDO
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov [rbp - 72], eax

    mov eax, [rbp - 68]
    cmp eax, [rbp - 72]
    je .binary_types_ready
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8d, [rbp - 72]
    call coerce_integer_literal
    mov [rbp - 68], eax
    cmp eax, [rbp - 72]
    je .binary_types_ready
    mov rax, [rbp - 32]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 16]
    mov r8d, [rbp - 68]
    call coerce_integer_literal
    mov [rbp - 72], eax
    mov eax, [rbp - 68]
    cmp eax, [rbp - 72]
    jne .type_error

.binary_types_ready:
    mov eax, [rbp - 64]
    cmp eax, PABLO_TOKEN_SUMA
    je .binary_arith
    cmp eax, PABLO_TOKEN_RESTA
    je .binary_arith
    cmp eax, PABLO_TOKEN_MULTIPLICAR
    je .binary_arith
    cmp eax, PABLO_TOKEN_DIVIDIR
    je .binary_arith
    cmp eax, PABLO_TOKEN_MODULO
    je .binary_arith
    cmp eax, PABLO_TOKEN_MENOR_QUE
    je .binary_compare
    cmp eax, PABLO_TOKEN_MENOR_O_IGUAL
    je .binary_compare
    cmp eax, PABLO_TOKEN_MAYOR_QUE
    je .binary_compare
    cmp eax, PABLO_TOKEN_MAYOR_O_IGUAL
    je .binary_compare
    cmp eax, PABLO_TOKEN_IGUAL_QUE
    je .binary_equals
    cmp eax, PABLO_TOKEN_DISTINTO_QUE
    je .binary_equals
    jmp .type_error

.binary_arith:
    mov edx, [rbp - 68]
    call is_arithmetic_type
    test eax, eax
    jz .type_error
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .binary_arith_ok
    cmp eax, [rbp - 68]
    jne .type_error
.binary_arith_ok:
    mov rax, [rbp - 32]
    mov ecx, [rbp - 68]
    mov [rax + AST_tipo], ecx
    mov eax, ecx
    jmp .fin

.binary_compare:
    mov edx, [rbp - 68]
    call is_arithmetic_type
    test eax, eax
    jz .type_error
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .binary_compare_ok
    cmp eax, PABLO_TIPO_LOGICO
    jne .type_error
.binary_compare_ok:
    mov rax, [rbp - 32]
    mov dword [rax + AST_tipo], PABLO_TIPO_LOGICO
    mov eax, PABLO_TIPO_LOGICO
    jmp .fin

.binary_equals:
    mov edx, [rbp - 68]
    call is_scalar_type
    test eax, eax
    jz .type_error
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .binary_equals_ok
    cmp eax, PABLO_TIPO_LOGICO
    jne .type_error
.binary_equals_ok:
    mov rax, [rbp - 32]
    mov dword [rax + AST_tipo], PABLO_TIPO_LOGICO
    mov eax, PABLO_TIPO_LOGICO
    jmp .fin

.binary_logical:
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .binary_logical_go
    cmp eax, PABLO_TIPO_LOGICO
    jne .type_error
.binary_logical_go:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8d, PABLO_TIPO_LOGICO
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov rax, [rbp - 32]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 16]
    mov r8d, PABLO_TIPO_LOGICO
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov rax, [rbp - 32]
    mov dword [rax + AST_tipo], PABLO_TIPO_LOGICO
    mov eax, PABLO_TIPO_LOGICO
    jmp .fin

.assign:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    call get_ast_ptr
    cmp dword [rax + AST_kind], PABLO_AST_IDENTIFICADOR
    jne .type_error
    mov [rbp - 48], rax
    mov rcx, [rbp - 16]
    mov edx, [rax + AST_token]
    call lookup_local
    test eax, eax
    js .ident_error
    mov [rbp - 40], eax
    mov rcx, [rbp - 16]
    mov edx, eax
    call get_local_ptr
    mov [rbp - 56], rax
    test dword [rax + LOCAL_flags], PABLO_LOCAL_FLAG_CONST
    jz .assign_rhs
    mov rax, [rbp - 48]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_constante_asignacion]
    mov rcx, [rbp - 16]
    mov edx, PABLO_SEMA_TIPO_INCOMPATIBLE
    call semantic_error_token
    mov eax, -1
    jmp .fin

.assign_rhs:
    mov ecx, [rax + LOCAL_type]
    mov [rbp - 76], ecx
    mov rax, [rbp - 32]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 16]
    mov r8d, [rbp - 76]
    call analyze_expression_expected
    test eax, eax
    js .fin
    mov rdx, [rbp - 48]
    mov rax, [rbp - 56]
    mov ecx, [rax + LOCAL_slot_offset]
    mov [rdx + AST_aux], ecx
    mov ecx, [rbp - 76]
    mov [rdx + AST_tipo], ecx
    mov rdx, [rbp - 32]
    mov rax, [rbp - 56]
    mov ecx, [rax + LOCAL_slot_offset]
    mov [rdx + AST_aux], ecx
    mov ecx, [rbp - 76]
    mov [rdx + AST_tipo], ecx
    mov eax, [rbp - 24]
    cmp eax, PABLO_TIPO_INVALIDO
    je .assign_ok
    cmp eax, [rbp - 76]
    jne .type_error
.assign_ok:
    mov eax, [rbp - 76]
    jmp .fin

.ident_error:
    mov rax, [rbp - 32]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_ident_desconocido]
    mov rcx, [rbp - 16]
    mov edx, PABLO_SEMA_IDENTIFICADOR_DESCONOCIDO
    call semantic_error_token
    mov eax, -1
    jmp .fin

.call_error:
    mov rax, [rbp - 32]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_llamada_invalida]
    mov rcx, [rbp - 16]
    mov edx, PABLO_SEMA_LLAMADA_INVALIDA
    call semantic_error_token
    mov eax, -1
    jmp .fin

.type_error:
    mov rax, [rbp - 32]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_tipo_incompatible]
    mov rcx, [rbp - 16]
    mov edx, PABLO_SEMA_TIPO_INCOMPATIBLE
    call semantic_error_token
    mov eax, -1
.fin:
    add rsp, 160
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

is_valid_return_type:
    cmp edx, PABLO_TIPO_VACIO
    je .yes
    jmp is_valid_storage_type
.yes:
    mov eax, 1
    ret

is_valid_storage_type:
    cmp edx, PABLO_TIPO_LOGICO
    je .yes
    jmp is_arithmetic_type
.yes:
    mov eax, 1
    ret

is_scalar_type:
    cmp edx, PABLO_TIPO_LOGICO
    je .yes
    jmp is_arithmetic_type
.yes:
    mov eax, 1
    ret

is_arithmetic_type:
    cmp edx, PABLO_TIPO_ENTERO8
    je .yes
    cmp edx, PABLO_TIPO_ENTERO16
    je .yes
    cmp edx, PABLO_TIPO_ENTERO32
    je .yes
    cmp edx, PABLO_TIPO_ENTERO64
    je .yes
    cmp edx, PABLO_TIPO_NATURAL8
    je .yes
    cmp edx, PABLO_TIPO_NATURAL16
    je .yes
    cmp edx, PABLO_TIPO_NATURAL32
    je .yes
    cmp edx, PABLO_TIPO_NATURAL64
    je .yes
    xor eax, eax
    ret
.yes:
    mov eax, 1
    ret

is_signed_type:
    cmp edx, PABLO_TIPO_ENTERO8
    je .yes
    cmp edx, PABLO_TIPO_ENTERO16
    je .yes
    cmp edx, PABLO_TIPO_ENTERO32
    je .yes
    cmp edx, PABLO_TIPO_ENTERO64
    je .yes
    xor eax, eax
    ret
.yes:
    mov eax, 1
    ret

literal_fits_type:
    cmp ecx, PABLO_TIPO_ENTERO8
    je .max_127
    cmp ecx, PABLO_TIPO_ENTERO16
    je .max_32767
    cmp ecx, PABLO_TIPO_ENTERO32
    je .max_i32
    cmp ecx, PABLO_TIPO_ENTERO64
    je .always
    cmp ecx, PABLO_TIPO_NATURAL8
    je .max_255
    cmp ecx, PABLO_TIPO_NATURAL16
    je .max_65535
    cmp ecx, PABLO_TIPO_NATURAL32
    je .always
    cmp ecx, PABLO_TIPO_NATURAL64
    je .always
    xor eax, eax
    ret
.max_127:
    cmp rdx, 127
    jbe .always
    xor eax, eax
    ret
.max_32767:
    cmp rdx, 32767
    jbe .always
    xor eax, eax
    ret
.max_i32:
    cmp rdx, 2147483647
    jbe .always
    xor eax, eax
    ret
.max_255:
    cmp rdx, 255
    jbe .always
    xor eax, eax
    ret
.max_65535:
    cmp rdx, 65535
    jbe .always
    xor eax, eax
    ret
.always:
    mov eax, 1
    ret

coerce_integer_literal:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 16], r8d
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov [rbp - 24], rax
    cmp dword [rax + AST_kind], PABLO_AST_LITERAL_ENTERO
    jne .current
    mov edx, [rbp - 16]
    call is_arithmetic_type
    test eax, eax
    jz .current
    mov rax, [rbp - 24]
    mov rdx, [rax + AST_valor]
    mov ecx, [rbp - 16]
    call literal_fits_type
    test eax, eax
    jz .current
    mov rax, [rbp - 24]
    mov ecx, [rbp - 16]
    mov [rax + AST_tipo], ecx
    mov eax, ecx
    jmp .fin
.current:
    mov rax, [rbp - 24]
    mov eax, [rax + AST_tipo]
.fin:
    mov rsp, rbp
    pop rbp
    ret

lookup_function:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 40
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    xor ebx, ebx
.loop:
    cmp ebx, [rcx + CTX_function_count]
    jge .fail
    mov edx, ebx
    call get_function_ptr
    mov [rbp - 24], rax
    mov r10d, [rax + FUNC_name_token]
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8d, r10d
    call pablo_token_equals_token
    test eax, eax
    jnz .found
    mov rcx, [rbp - 8]
    inc ebx
    jmp .loop
.found:
    mov eax, ebx
    jmp .fin
.fail:
    mov eax, -1
.fin:
    add rsp, 40
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

lookup_local:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 40
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov eax, [rcx + CTX_local_count]
    dec eax
    mov ebx, eax
.loop:
    cmp ebx, -1
    jle .fail
    mov rcx, [rbp - 8]
    mov edx, ebx
    call get_local_ptr
    cmp dword [rax + LOCAL_active], 1
    jne .next
    mov r10d, [rax + LOCAL_name_token]
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8d, r10d
    call pablo_token_equals_token
    test eax, eax
    jnz .found
.next:
    dec ebx
    jmp .loop
.found:
    mov eax, ebx
    jmp .fin
.fail:
    mov eax, -1
.fin:
    add rsp, 40
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

lookup_local_in_depth:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 40
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 16], r8d
    mov eax, [rcx + CTX_local_count]
    dec eax
    mov ebx, eax
.loop:
    cmp ebx, -1
    jle .fail
    mov rcx, [rbp - 8]
    mov edx, ebx
    call get_local_ptr
    cmp dword [rax + LOCAL_active], 1
    jne .next
    mov ecx, [rax + LOCAL_depth]
    cmp ecx, [rbp - 16]
    jne .next
    mov r10d, [rax + LOCAL_name_token]
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8d, r10d
    call pablo_token_equals_token
    test eax, eax
    jnz .found
.next:
    dec ebx
    jmp .loop
.found:
    mov eax, ebx
    jmp .fin
.fail:
    mov eax, -1
.fin:
    add rsp, 40
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

deactivate_locals_in_depth:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 40
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov eax, [rcx + CTX_local_count]
    dec eax
    mov ebx, eax
.loop:
    cmp ebx, -1
    jle .fin
    mov rcx, [rbp - 8]
    mov edx, ebx
    call get_local_ptr
    cmp dword [rax + LOCAL_active], 1
    jne .next
    mov ecx, [rax + LOCAL_depth]
    cmp ecx, [rbp - 12]
    jne .next
    mov dword [rax + LOCAL_active], 0
.next:
    dec ebx
    jmp .loop
.fin:
    add rsp, 40
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

token_matches_name:
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

semantic_error_simple:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rcx + CTX_diag_stage], dword PABLO_ETAPA_SEMANTIC
    mov [rcx + CTX_diag_code], edx
    mov dword [rcx + CTX_diag_line], 0
    mov dword [rcx + CTX_diag_column], 0
    mov qword [rcx + CTX_diag_offset], 0
    mov [rcx + CTX_diag_message], r8
    mov rsp, rbp
    pop rbp
    ret

semantic_error_token:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rsp + 32], r9
    mov r9d, r8d
    mov r8d, edx
    mov edx, PABLO_ETAPA_SEMANTIC
    call pablo_set_error_token
    mov rsp, rbp
    pop rbp
    ret
