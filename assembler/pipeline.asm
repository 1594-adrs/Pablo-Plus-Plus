default rel

%include "win64.inc"
%include "pablocc.inc"
%include "compilador.inc"

extern strcmp
extern compiler_get_context
extern ctx_reset
extern pablo_make_build_dir
extern pablo_load_source
extern pablo_set_error_simple
extern pablo_print_diagnostic
extern pablo_print_usage
extern pablo_copy_cstring
extern lexer_preparar
extern lexer_dump_tokens
extern parser_preparar
extern ast_preparar
extern ast_dump_tree
extern semantic_preparar
extern codegen_preparar
extern toolchain_preparar

global pipeline_compilar

section .rdata
arg_tokens db "-tokens", 0
arg_ast db "-ast", 0
arg_emit_asm db "-emit-asm", 0
arg_o db "-o", 0

msg_flag_desconocida db "Flag no reconocida.", 0
msg_fuente_duplicada db "Solo se admite un archivo fuente por invocacion.", 0
msg_falta_fuente db "Debes indicar un archivo fuente .p++.", 0
msg_falta_salida db "La bandera -o requiere una ruta de salida.", 0
msg_modos_incompatibles db "Solo puede seleccionarse un modo entre -tokens, -ast o -emit-asm.", 0

section .text
pipeline_compilar:
    push rbp
    mov rbp, rsp
    sub rsp, WIN64_SHADOW_SPACE + 80

    mov [rbp - 8], rcx      ; argc
    mov [rbp - 16], rdx     ; argv

    call compiler_get_context
    mov [rbp - 24], rax
    mov rcx, rax
    call ctx_reset
    call pablo_make_build_dir

    mov dword [rbp - 28], 0 ; cuenta de modos explicitos
    mov dword [rbp - 32], 1 ; indice argv

.parse_loop:
    mov eax, [rbp - 32]
    cmp eax, [rbp - 8]
    jge .post_parse

    mov rax, [rbp - 16]
    mov ecx, [rbp - 32]
    mov rdx, [rax + rcx * 8]
    mov [rbp - 40], rdx

    cmp byte [rdx], '-'
    je .handle_flag

    mov rcx, [rbp - 24]
    cmp qword [rcx + CTX_source_path], 0
    jne .error_fuente_duplicada
    mov rax, [rbp - 40]
    mov [rcx + CTX_source_path], rax
    jmp .next_arg

.handle_flag:
    mov rcx, [rbp - 40]
    mov rdx, arg_tokens
    call strcmp
    test eax, eax
    jne .check_ast
    mov rcx, [rbp - 24]
    mov dword [rcx + CTX_mode], PABLO_MODO_TOKENS
    inc dword [rbp - 28]
    jmp .next_arg

.check_ast:
    mov rcx, [rbp - 40]
    mov rdx, arg_ast
    call strcmp
    test eax, eax
    jne .check_emit
    mov rcx, [rbp - 24]
    mov dword [rcx + CTX_mode], PABLO_MODO_AST
    inc dword [rbp - 28]
    jmp .next_arg

.check_emit:
    mov rcx, [rbp - 40]
    mov rdx, arg_emit_asm
    call strcmp
    test eax, eax
    jne .check_o
    mov rcx, [rbp - 24]
    mov dword [rcx + CTX_mode], PABLO_MODO_EMIT_ASM
    inc dword [rbp - 28]
    jmp .next_arg

.check_o:
    mov rcx, [rbp - 40]
    mov rdx, arg_o
    call strcmp
    test eax, eax
    jne .error_flag

    mov eax, [rbp - 32]
    inc eax
    cmp eax, [rbp - 8]
    jge .error_falta_salida

    mov [rbp - 32], eax
    mov rax, [rbp - 16]
    mov ecx, [rbp - 32]
    mov rdx, [rax + rcx * 8]
    mov rcx, [rbp - 24]
    or dword [rcx + CTX_flags], PABLO_FLAG_SALIDA_PERSONALIZADA
    mov [rcx + CTX_output_exe_path], rdx
    jmp .next_arg

.next_arg:
    inc dword [rbp - 32]
    jmp .parse_loop

.post_parse:
    cmp dword [rbp - 28], 1
    jg .error_modos

    mov rcx, [rbp - 24]
    cmp qword [rcx + CTX_source_path], 0
    jne .load
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_CLI_SIN_FUENTE
    lea r9, [rel msg_falta_fuente]
    call pablo_set_error_simple
    call pablo_print_usage
    jmp .print_error

.load:
    call pablo_load_source
    test eax, eax
    jnz .print_error

    mov rcx, [rbp - 24]
    call lexer_preparar
    test eax, eax
    jnz .print_error

    mov rcx, [rbp - 24]
    cmp dword [rcx + CTX_mode], PABLO_MODO_TOKENS
    jne .parse
    call lexer_dump_tokens
    xor eax, eax
    jmp .fin

.parse:
    call parser_preparar
    test eax, eax
    jnz .print_error

    mov rcx, [rbp - 24]
    call ast_preparar
    test eax, eax
    jnz .print_error

    mov rcx, [rbp - 24]
    cmp dword [rcx + CTX_mode], PABLO_MODO_AST
    jne .semantic
    call ast_dump_tree
    xor eax, eax
    jmp .fin

.semantic:
    call semantic_preparar
    test eax, eax
    jnz .print_error

    mov rcx, [rbp - 24]
    call codegen_preparar
    test eax, eax
    jnz .print_error

    mov rcx, [rbp - 24]
    cmp dword [rcx + CTX_mode], PABLO_MODO_EMIT_ASM
    jne .toolchain
    xor eax, eax
    jmp .fin

.toolchain:
    call toolchain_preparar
    test eax, eax
    jnz .print_error
    xor eax, eax
    jmp .fin

.error_flag:
    mov rcx, [rbp - 24]
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_CLI_FLAG_DESCONOCIDA
    lea r9, [rel msg_flag_desconocida]
    call pablo_set_error_simple
    call pablo_print_usage
    jmp .print_error

.error_fuente_duplicada:
    mov rcx, [rbp - 24]
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_CLI_FUENTE_DUPLICADA
    lea r9, [rel msg_fuente_duplicada]
    call pablo_set_error_simple
    call pablo_print_usage
    jmp .print_error

.error_falta_salida:
    mov rcx, [rbp - 24]
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_CLI_FALTA_SALIDA
    lea r9, [rel msg_falta_salida]
    call pablo_set_error_simple
    call pablo_print_usage
    jmp .print_error

.error_modos:
    mov rcx, [rbp - 24]
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_CLI_MODOS_INCOMPATIBLES
    lea r9, [rel msg_modos_incompatibles]
    call pablo_set_error_simple
    call pablo_print_usage

.print_error:
    mov rcx, [rbp - 24]
    call pablo_print_diagnostic

.fin:
    mov rsp, rbp
    pop rbp
    ret
