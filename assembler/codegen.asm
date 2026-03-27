default rel

%include "pablocc.inc"
%include "sintaxis.inc"
%include "compilador.inc"

extern fopen
extern fclose
extern fprintf
extern fputs
extern setbuf
extern get_ast_ptr
extern get_function_ptr
extern pablo_token_text
extern pablo_set_error_simple
extern pablo_set_error_token

global codegen_preparar

section .rdata
mode_wb db "wb", 0

txt_default_rel db "default rel", 10, 0
txt_section_text db 10, "section .text", 10, 10, 0
txt_push_rbp db "    push rbp", 10, 0
txt_mov_rbp db "    mov rbp, rsp", 10, 0
txt_mov_rsp_rbp db "    mov rsp, rbp", 10, 0
txt_pop_rbp db "    pop rbp", 10, 0
txt_ret db "    ret", 10, 10, 0
txt_xor_eax_eax db "    xor eax, eax", 10, 0
txt_mov_eax_eax db "    mov eax, eax", 10, 0
txt_mov_eax_1 db "    mov eax, 1", 10, 0
txt_neg_rax db "    neg rax", 10, 0
txt_cmp_rax_zero db "    cmp rax, 0", 10, 0
txt_xor_edx_edx db "    xor edx, edx", 10, 0
txt_mov_rax_rcx db "    mov rax, rcx", 10, 0
txt_mov_rax_rdx db "    mov rax, rdx", 10, 0
txt_mov_rax_r8 db "    mov rax, r8", 10, 0
txt_mov_rax_r9 db "    mov rax, r9", 10, 0
txt_mov_r10_rax db "    mov r10, rax", 10, 0
txt_cqo db "    cqo", 10, 0
txt_idiv_r10 db "    idiv r10", 10, 0
txt_div_r10 db "    div r10", 10, 0
txt_sub_rsp_16 db "    sub rsp, 16", 10, 0
txt_add_rsp_16 db "    add rsp, 16", 10, 0
txt_store_rsp_rax db "    mov qword [rsp], rax", 10, 0
txt_load_rax_rsp db "    mov rax, qword [rsp]", 10, 0
txt_sub_rsp_32 db "    sub rsp, 32", 10, 0
txt_add_rsp_32 db "    add rsp, 32", 10, 0
txt_store_rsp0_rax db "    mov qword [rsp], rax", 10, 0
txt_store_rsp8_rax db "    mov qword [rsp+8], rax", 10, 0
txt_store_rsp16_rax db "    mov qword [rsp+16], rax", 10, 0
txt_store_rsp24_rax db "    mov qword [rsp+24], rax", 10, 0
txt_load_rcx_rsp0 db "    mov rcx, qword [rsp]", 10, 0
txt_load_rdx_rsp8 db "    mov rdx, qword [rsp+8]", 10, 0
txt_load_r8_rsp16 db "    mov r8, qword [rsp+16]", 10, 0
txt_load_r9_rsp24 db "    mov r9, qword [rsp+24]", 10, 0
txt_add_rax_r10 db "    add rax, r10", 10, 0
txt_sub_rax_r10 db "    sub rax, r10", 10, 0
txt_imul_rax_r10 db "    imul rax, r10", 10, 0
txt_cmp_rax_r10 db "    cmp rax, r10", 10, 0
txt_setl_al db "    setl al", 10, 0
txt_setle_al db "    setle al", 10, 0
txt_setg_al db "    setg al", 10, 0
txt_setge_al db "    setge al", 10, 0
txt_setb_al db "    setb al", 10, 0
txt_setbe_al db "    setbe al", 10, 0
txt_seta_al db "    seta al", 10, 0
txt_setae_al db "    setae al", 10, 0
txt_sete_al db "    sete al", 10, 0
txt_setne_al db "    setne al", 10, 0
txt_movzx_eax_al db "    movzx eax, al", 10, 0
txt_movzx_eax_ax db "    movzx eax, ax", 10, 0
txt_movsx_rax_al db "    movsx rax, al", 10, 0
txt_movsx_rax_ax db "    movsx rax, ax", 10, 0
txt_movsxd_rax_eax db "    movsxd rax, eax", 10, 0

fmt_text db "%s", 0
fmt_global db "global %.*s", 10, 0
fmt_extern db "extern %.*s", 10, 0
fmt_extern_escaped db "extern $%.*s", 10, 0
fmt_label db "%.*s:", 10, 0
fmt_sub_rsp db "    sub rsp, %d", 10, 0
fmt_add_rsp db "    add rsp, %d", 10, 0
fmt_store_rcx db "    mov qword [rbp-%d], rcx", 10, 0
fmt_store_rdx db "    mov qword [rbp-%d], rdx", 10, 0
fmt_store_r8 db "    mov qword [rbp-%d], r8", 10, 0
fmt_store_r9 db "    mov qword [rbp-%d], r9", 10, 0
fmt_store_local db "    mov qword [rbp-%d], rax", 10, 0
fmt_load_local db "    mov rax, qword [rbp-%d]", 10, 0
fmt_load_param_stack db "    mov rax, qword [rbp+%d]", 10, 0
fmt_mov_imm db "    mov rax, %lld", 10, 0
fmt_call db "    call %.*s", 10, 0
fmt_call_escaped db "    call $%.*s", 10, 0
fmt_store_stack_arg db "    mov qword [rsp+%d], rax", 10, 0
fmt_label_internal db "pablo_L_%d:", 10, 0
fmt_jmp_label db "    jmp pablo_L_%d", 10, 0
fmt_je_label db "    je pablo_L_%d", 10, 0
fmt_jne_label db "    jne pablo_L_%d", 10, 0
fmt_exit_label db "pablo_fin_%d:", 10, 0
fmt_jmp_exit db "    jmp pablo_fin_%d", 10, 0

msg_open_fail db "No se pudo abrir el archivo .asm de salida.", 0
msg_unsupported db "El backend actual no soporta este nodo del AST.", 0
msg_unresolved db "No se pudo resolver el offset o la funcion en codegen.", 0

section .bss
loop_break_stack resd 128
loop_continue_stack resd 128
loop_stack_top resd 1

section .text
codegen_preparar:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 72
    mov [rbp - 16], rcx

    mov dword [rcx + CTX_label_counter], 0
    mov dword [rel loop_stack_top], 0

    mov rcx, [rbp - 16]
    mov rcx, [rcx + CTX_output_asm_path]
    lea rdx, [rel mode_wb]
    call fopen
    test rax, rax
    jnz .opened
    mov rcx, [rbp - 16]
    mov edx, PABLO_ETAPA_CODEGEN
    mov r8d, PABLO_CODEGEN_NO_PUDO_ABRIR
    lea r9, [rel msg_open_fail]
    call pablo_set_error_simple
    mov eax, -1
    jmp .fin

.opened:
    mov [rbp - 24], rax
    mov rcx, rax
    xor edx, edx
    call setbuf
    mov rcx, [rbp - 24]
    lea rdx, [rel txt_default_rel]
    call emit_text
    mov rcx, [rbp - 24]
    lea rdx, [rel txt_section_text]
    call emit_text

    xor ebx, ebx
.globals:
    mov rcx, [rbp - 16]
    cmp ebx, [rcx + CTX_function_count]
    jge .functions
    mov edx, ebx
    call get_function_ptr
    mov [rbp - 56], rax
    mov ecx, [rax + FUNC_name_token]
    mov [rbp - 28], ecx
    mov rcx, [rbp - 16]
    mov edx, [rbp - 28]
    call pablo_token_text
    mov [rbp - 40], rax
    mov [rbp - 44], edx
    mov rcx, [rbp - 24]
    mov rax, [rbp - 56]
    test dword [rax + FUNC_flags], PABLO_FUNC_FLAG_BUILTIN_RUNTIME
    jnz .extern_plain_symbol
    test dword [rax + FUNC_flags], PABLO_FUNC_FLAG_EXTERNA
    jz .global_symbol
    lea rdx, [rel fmt_extern_escaped]
    jmp .print_symbol
.extern_plain_symbol:
    lea rdx, [rel fmt_extern]
    jmp .print_symbol
.global_symbol:
    lea rdx, [rel fmt_global]
.print_symbol:
    mov r8d, [rbp - 44]
    mov r9, [rbp - 40]
    call fprintf
    inc ebx
    jmp .globals

.functions:
    xor ebx, ebx
.function_loop:
    mov rcx, [rbp - 16]
    cmp ebx, [rcx + CTX_function_count]
    jge .done
    mov rcx, [rbp - 16]
    mov edx, ebx
    mov r8, [rbp - 24]
    call emit_function
    test eax, eax
    js .error
    inc ebx
    jmp .function_loop

.done:
    xor eax, eax
    jmp .fin

.error:
    mov eax, -1

.fin:
    add rsp, 72
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

emit_function:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 104
    mov [rbp - 16], rcx
    mov [rbp - 20], edx
    mov [rbp - 32], r8

    mov rcx, [rbp - 16]
    mov eax, [rbp - 20]
    mov [rcx + CTX_current_function], eax
    mov edx, [rbp - 20]
    call get_function_ptr
    mov [rbp - 40], rax
    test dword [rax + FUNC_flags], PABLO_FUNC_FLAG_EXTERNA
    jz .emit_body
    xor eax, eax
    jmp .fin

.emit_body:

    mov ecx, [rax + FUNC_name_token]
    mov [rbp - 24], ecx
    mov rcx, [rbp - 16]
    mov edx, [rbp - 24]
    call pablo_token_text
    mov [rbp - 48], rax
    mov [rbp - 52], edx

    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_label]
    mov r8d, [rbp - 52]
    mov r9, [rbp - 48]
    call fprintf
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_push_rbp]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_mov_rbp]
    call emit_text

    mov rax, [rbp - 40]
    mov eax, [rax + FUNC_stack_size]
    mov [rbp - 56], eax
    cmp eax, 0
    jle .spill_params
    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_sub_rsp]
    mov r8d, [rbp - 56]
    call fprintf

.spill_params:
    mov rax, [rbp - 40]
    mov eax, [rax + FUNC_first_param]
    mov [rbp - 60], eax
    xor ebx, ebx
.spill_loop:
    cmp dword [rbp - 60], -1
    je .body
    mov rcx, [rbp - 16]
    mov edx, [rbp - 60]
    call get_ast_ptr
    mov [rbp - 64], rax
    mov edx, [rax + AST_aux]
    mov [rbp - 68], edx
    mov edx, [rax + AST_tipo]
    mov [rbp - 72], edx
    mov rcx, [rbp - 32]
    cmp ebx, 0
    je .spill_rcx
    cmp ebx, 1
    je .spill_rdx
    cmp ebx, 2
    je .spill_r8
    cmp ebx, 3
    je .spill_r9
    jmp .spill_stack
.spill_rcx:
    lea rdx, [rel txt_mov_rax_rcx]
    call emit_text
    jmp .spill_normalize
.spill_rdx:
    lea rdx, [rel txt_mov_rax_rdx]
    call emit_text
    jmp .spill_normalize
.spill_r8:
    lea rdx, [rel txt_mov_rax_r8]
    call emit_text
    jmp .spill_normalize
.spill_r9:
    lea rdx, [rel txt_mov_rax_r9]
    call emit_text
    jmp .spill_normalize
.spill_stack:
    mov eax, ebx
    sub eax, 4
    imul eax, 8
    add eax, 48
    mov [rbp - 76], eax
    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_load_param_stack]
    mov r8d, [rbp - 76]
    call fprintf
.spill_normalize:
    mov rcx, [rbp - 32]
    mov edx, [rbp - 72]
    call emit_normalize_type
    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_store_local]
    mov r8d, [rbp - 68]
    call fprintf
.spill_next:
    mov rax, [rbp - 64]
    mov eax, [rax + AST_next]
    mov [rbp - 60], eax
    inc ebx
    jmp .spill_loop

.body:
    mov rax, [rbp - 40]
    mov edx, [rax + FUNC_body_node]
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_statement
    test eax, eax
    js .fin

    mov rcx, [rbp - 32]
    lea rdx, [rel txt_xor_eax_eax]
    call emit_text

    mov rcx, [rbp - 32]
    mov edx, [rbp - 20]
    call emit_exit_label
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_mov_rsp_rbp]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_pop_rbp]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_ret]
    call emit_text
    xor eax, eax

.fin:
    add rsp, 104
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

emit_block:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 24], r8

    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov eax, [rax + AST_a]
    mov [rbp - 16], eax

.loop:
    cmp dword [rbp - 16], -1
    je .ok
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    mov r8, [rbp - 24]
    call emit_statement
    test eax, eax
    js .fin
    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_ast_ptr
    mov eax, [rax + AST_next]
    mov [rbp - 16], eax
    jmp .loop

.ok:
    xor eax, eax

.fin:
    mov rsp, rbp
    pop rbp
    ret

emit_statement:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 24], r8

    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov [rbp - 32], rax

    mov eax, [rax + AST_kind]
    cmp eax, PABLO_AST_BLOQUE
    je .block
    cmp eax, PABLO_AST_DECLARACION_VARIABLE
    je .var_decl
    cmp eax, PABLO_AST_DECLARACION_CONSTANTE
    je .var_decl
    cmp eax, PABLO_AST_SENTENCIA_DEVOLVER
    je .ret
    cmp eax, PABLO_AST_SENTENCIA_SI
    je .stmt_if
    cmp eax, PABLO_AST_SENTENCIA_MIENTRAS
    je .stmt_while
    cmp eax, PABLO_AST_SENTENCIA_PARA
    je .stmt_para
    cmp eax, PABLO_AST_SENTENCIA_EXPRESION
    je .stmt_expr
    cmp eax, PABLO_AST_SENTENCIA_CONTINUAR
    je .stmt_continue
    cmp eax, PABLO_AST_SENTENCIA_ROMPER
    je .stmt_break
    jmp .unsupported

.block:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, [rbp - 24]
    call emit_block
    jmp .fin

.var_decl:
    mov rax, [rbp - 32]
    mov eax, [rax + AST_a]
    cmp eax, -1
    jne .var_init
    mov rcx, [rbp - 24]
    lea rdx, [rel txt_xor_eax_eax]
    call emit_text
    jmp .var_store
.var_init:
    mov edx, eax
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_expression
    test eax, eax
    js .fin
.var_store:
    mov rax, [rbp - 32]
    mov rcx, [rbp - 24]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    mov rax, [rbp - 32]
    mov edx, [rax + AST_aux]
    mov rcx, [rbp - 24]
    lea rdx, [rel fmt_store_local]
    mov r8d, [rax + AST_aux]
    call fprintf
    xor eax, eax
    jmp .fin

.ret:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    cmp edx, -1
    je .ret_jump
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_expression
    test eax, eax
    js .fin
    mov rcx, [rbp - 8]
    mov edx, [rcx + CTX_current_function]
    call get_function_ptr
    mov rcx, [rbp - 24]
    mov edx, [rax + FUNC_return_type]
    call emit_normalize_type
.ret_jump:
    mov rcx, [rbp - 8]
    mov eax, [rcx + CTX_current_function]
    mov rcx, [rbp - 24]
    mov edx, eax
    call emit_jmp_exit
    xor eax, eax
    jmp .fin

.stmt_expr:
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_expression
    jmp .fin

.stmt_if:
    mov rcx, [rbp - 8]
    call next_label_id
    mov [rbp - 40], eax
    mov rcx, [rbp - 8]
    call next_label_id
    mov [rbp - 44], eax

    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_expression
    test eax, eax
    js .fin
    mov rcx, [rbp - 24]
    lea rdx, [rel txt_cmp_rax_zero]
    call emit_text
    mov rcx, [rbp - 24]
    mov edx, [rbp - 40]
    call emit_je_label

    mov rax, [rbp - 32]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_statement
    test eax, eax
    js .fin

    mov rax, [rbp - 32]
    cmp dword [rax + AST_c], -1
    je .if_no_else
    mov rcx, [rbp - 24]
    mov edx, [rbp - 44]
    call emit_jmp_label
    mov rcx, [rbp - 24]
    mov edx, [rbp - 40]
    call emit_plain_label
    mov rax, [rbp - 32]
    mov edx, [rax + AST_c]
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_statement
    test eax, eax
    js .fin
    mov rcx, [rbp - 24]
    mov edx, [rbp - 44]
    call emit_plain_label
    xor eax, eax
    jmp .fin

.if_no_else:
    mov rcx, [rbp - 24]
    mov edx, [rbp - 40]
    call emit_plain_label
    xor eax, eax
    jmp .fin

.stmt_while:
    mov rcx, [rbp - 8]
    call next_label_id
    mov [rbp - 40], eax
    mov rcx, [rbp - 8]
    call next_label_id
    mov [rbp - 44], eax

    mov rcx, [rbp - 24]
    mov edx, [rbp - 40]
    call emit_plain_label
    mov rax, [rbp - 32]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_expression
    test eax, eax
    js .fin
    mov rcx, [rbp - 24]
    lea rdx, [rel txt_cmp_rax_zero]
    call emit_text
    mov rcx, [rbp - 24]
    mov edx, [rbp - 44]
    call emit_je_label
    mov ecx, [rbp - 40]
    mov edx, [rbp - 44]
    call push_loop_labels

    mov rax, [rbp - 32]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_statement
    call pop_loop_labels
    test eax, eax
    js .fin
    mov rcx, [rbp - 24]
    mov edx, [rbp - 40]
    call emit_jmp_label
    mov rcx, [rbp - 24]
    mov edx, [rbp - 44]
    call emit_plain_label
    xor eax, eax
    jmp .fin

.stmt_para:
    mov rax, [rbp - 32]
    cmp dword [rax + AST_a], -1
    je .para_labels
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_statement
    test eax, eax
    js .fin
.para_labels:
    mov rcx, [rbp - 8]
    call next_label_id
    mov [rbp - 40], eax
    mov rcx, [rbp - 8]
    call next_label_id
    mov [rbp - 44], eax
    mov rcx, [rbp - 8]
    call next_label_id
    mov [rbp - 48], eax

    mov rcx, [rbp - 24]
    mov edx, [rbp - 40]
    call emit_plain_label
    mov rax, [rbp - 32]
    cmp dword [rax + AST_b], -1
    je .para_body
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_expression
    test eax, eax
    js .fin
    mov rcx, [rbp - 24]
    lea rdx, [rel txt_cmp_rax_zero]
    call emit_text
    mov rcx, [rbp - 24]
    mov edx, [rbp - 48]
    call emit_je_label

.para_body:
    mov ecx, [rbp - 44]
    mov edx, [rbp - 48]
    call push_loop_labels
    mov rax, [rbp - 32]
    mov edx, [rax + AST_c]
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_statement
    call pop_loop_labels
    test eax, eax
    js .fin

    mov rcx, [rbp - 24]
    mov edx, [rbp - 44]
    call emit_plain_label
    mov rax, [rbp - 32]
    mov edx, [rax + AST_valor]
    cmp edx, -1
    je .para_repeat
    mov rcx, [rbp - 8]
    mov r8, [rbp - 24]
    call emit_expression
    test eax, eax
    js .fin
.para_repeat:
    mov rcx, [rbp - 24]
    mov edx, [rbp - 40]
    call emit_jmp_label
    mov rcx, [rbp - 24]
    mov edx, [rbp - 48]
    call emit_plain_label
    xor eax, eax
    jmp .fin

.stmt_continue:
    call current_continue_label
    test eax, eax
    js .unsupported
    mov rcx, [rbp - 24]
    mov edx, eax
    call emit_jmp_label
    xor eax, eax
    jmp .fin

.stmt_break:
    call current_break_label
    test eax, eax
    js .unsupported
    mov rcx, [rbp - 24]
    mov edx, eax
    call emit_jmp_label
    xor eax, eax
    jmp .fin

.unsupported:
    mov rax, [rbp - 32]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_unsupported]
    mov rcx, [rbp - 8]
    mov edx, PABLO_CODEGEN_NODO_INVALIDO
    call codegen_error_token
    mov eax, -1

.fin:
    mov rsp, rbp
    pop rbp
    ret

emit_expression:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 120
    mov [rbp - 16], rcx
    mov [rbp - 20], edx
    mov [rbp - 32], r8

    mov rcx, [rbp - 16]
    mov edx, [rbp - 20]
    call get_ast_ptr
    mov [rbp - 40], rax

    mov eax, [rax + AST_kind]
    cmp eax, PABLO_AST_LITERAL_ENTERO
    je .literal_value
    cmp eax, PABLO_AST_LITERAL_LOGICO
    je .literal_value
    cmp eax, PABLO_AST_IDENTIFICADOR
    je .identifier
    cmp eax, PABLO_AST_LLAMADA
    je .call
    cmp eax, PABLO_AST_UNARIO
    je .unary
    cmp eax, PABLO_AST_BINARIO
    je .binary
    cmp eax, PABLO_AST_ASIGNACION
    je .assign
    jmp .unsupported

.literal_value:
    lea rcx, [rel fmt_mov_imm]
    mov rdx, [rbp - 32]
    mov rax, [rbp - 40]
    mov r8, [rax + AST_valor]
    xchg rcx, rdx
    call fprintf
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    xor eax, eax
    jmp .fin

.identifier:
    mov rax, [rbp - 40]
    mov eax, [rax + AST_aux]
    cmp eax, 0
    jle .unresolved
    mov [rbp - 44], eax
    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_load_local]
    mov r8d, [rbp - 44]
    call fprintf
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    xor eax, eax
    jmp .fin

.assign:
    mov rax, [rbp - 40]
    mov eax, [rax + AST_b]
    mov edx, eax
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_expression
    test eax, eax
    js .fin
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    mov rax, [rbp - 40]
    mov eax, [rax + AST_aux]
    cmp eax, 0
    jle .unresolved
    mov [rbp - 44], eax
    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_store_local]
    mov r8d, [rbp - 44]
    call fprintf
    xor eax, eax
    jmp .fin

.unary:
    mov rax, [rbp - 40]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_expression
    test eax, eax
    js .fin
    mov rax, [rbp - 40]
    mov eax, [rax + AST_aux]
    cmp eax, PABLO_TOKEN_RESTA
    je .unary_minus
    cmp eax, PABLO_TOKEN_NEGAR
    je .unary_not
    jmp .unsupported
.unary_minus:
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_neg_rax]
    call emit_text
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    xor eax, eax
    jmp .fin
.unary_not:
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_cmp_rax_zero]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_sete_al]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_movzx_eax_al]
    call emit_text
    xor eax, eax
    jmp .fin

.binary:
    mov rax, [rbp - 40]
    mov eax, [rax + AST_aux]
    cmp eax, PABLO_TOKEN_Y_LOGICO
    je .logical_and
    cmp eax, PABLO_TOKEN_O_LOGICO
    je .logical_or

    mov rax, [rbp - 40]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_expression
    test eax, eax
    js .fin

    mov rcx, [rbp - 32]
    lea rdx, [rel txt_sub_rsp_16]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_store_rsp_rax]
    call emit_text

    mov rax, [rbp - 40]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_expression
    test eax, eax
    jns .binary_rhs_ok
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_add_rsp_16]
    call emit_text
    mov eax, -1
    jmp .fin
.binary_rhs_ok:
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_mov_r10_rax]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_load_rax_rsp]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_add_rsp_16]
    call emit_text

    mov rax, [rbp - 40]
    mov edx, [rax + AST_tipo]
    call codegen_is_signed_type
    mov [rbp - 80], eax
    mov rcx, [rbp - 16]
    mov rax, [rbp - 40]
    mov edx, [rax + AST_a]
    call get_ast_ptr
    mov edx, [rax + AST_tipo]
    call codegen_is_signed_type
    mov [rbp - 84], eax

    mov rax, [rbp - 40]
    mov eax, [rax + AST_aux]
    cmp eax, PABLO_TOKEN_SUMA
    je .emit_add
    cmp eax, PABLO_TOKEN_RESTA
    je .emit_sub
    cmp eax, PABLO_TOKEN_MULTIPLICAR
    je .emit_mul
    cmp eax, PABLO_TOKEN_DIVIDIR
    je .emit_div
    cmp eax, PABLO_TOKEN_MODULO
    je .emit_mod
    cmp eax, PABLO_TOKEN_MENOR_QUE
    je .emit_lt
    cmp eax, PABLO_TOKEN_MENOR_O_IGUAL
    je .emit_le
    cmp eax, PABLO_TOKEN_MAYOR_QUE
    je .emit_gt
    cmp eax, PABLO_TOKEN_MAYOR_O_IGUAL
    je .emit_ge
    cmp eax, PABLO_TOKEN_IGUAL_QUE
    je .emit_eq
    cmp eax, PABLO_TOKEN_DISTINTO_QUE
    je .emit_ne
    jmp .unsupported

.emit_add:
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_add_rax_r10]
    call emit_text
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    xor eax, eax
    jmp .fin
.emit_sub:
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_sub_rax_r10]
    call emit_text
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    xor eax, eax
    jmp .fin
.emit_mul:
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_imul_rax_r10]
    call emit_text
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    xor eax, eax
    jmp .fin
.emit_div:
    cmp dword [rbp - 80], 0
    je .emit_div_unsigned
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_cqo]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_idiv_r10]
    call emit_text
    jmp .emit_div_done
.emit_div_unsigned:
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_xor_edx_edx]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_div_r10]
    call emit_text
.emit_div_done:
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    xor eax, eax
    jmp .fin
.emit_mod:
    cmp dword [rbp - 80], 0
    je .emit_mod_unsigned
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_cqo]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_idiv_r10]
    call emit_text
    jmp .emit_mod_done
.emit_mod_unsigned:
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_xor_edx_edx]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_div_r10]
    call emit_text
.emit_mod_done:
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_mov_rax_rdx]
    call emit_text
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    xor eax, eax
    jmp .fin
.emit_lt:
    cmp dword [rbp - 84], 0
    je .emit_lt_unsigned
    lea rdx, [rel txt_setl_al]
    jmp .emit_compare_common
.emit_lt_unsigned:
    lea rdx, [rel txt_setb_al]
    jmp .emit_compare_common
.emit_le:
    cmp dword [rbp - 84], 0
    je .emit_le_unsigned
    lea rdx, [rel txt_setle_al]
    jmp .emit_compare_common
.emit_le_unsigned:
    lea rdx, [rel txt_setbe_al]
    jmp .emit_compare_common
.emit_gt:
    cmp dword [rbp - 84], 0
    je .emit_gt_unsigned
    lea rdx, [rel txt_setg_al]
    jmp .emit_compare_common
.emit_gt_unsigned:
    lea rdx, [rel txt_seta_al]
    jmp .emit_compare_common
.emit_ge:
    cmp dword [rbp - 84], 0
    je .emit_ge_unsigned
    lea rdx, [rel txt_setge_al]
    jmp .emit_compare_common
.emit_ge_unsigned:
    lea rdx, [rel txt_setae_al]
    jmp .emit_compare_common
.emit_eq:
    lea rdx, [rel txt_sete_al]
    jmp .emit_compare_common
.emit_ne:
    lea rdx, [rel txt_setne_al]
.emit_compare_common:
    mov [rbp - 56], rdx
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_cmp_rax_r10]
    call emit_text
    mov rcx, [rbp - 32]
    mov rdx, [rbp - 56]
    call emit_text
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_movzx_eax_al]
    call emit_text
    xor eax, eax
    jmp .fin

.logical_and:
    mov rcx, [rbp - 16]
    call next_label_id
    mov [rbp - 60], eax
    mov rcx, [rbp - 16]
    call next_label_id
    mov [rbp - 64], eax
    mov rax, [rbp - 40]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_expression
    test eax, eax
    js .fin
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_cmp_rax_zero]
    call emit_text
    mov rcx, [rbp - 32]
    mov edx, [rbp - 60]
    call emit_je_label
    mov rax, [rbp - 40]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_expression
    test eax, eax
    js .fin
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_cmp_rax_zero]
    call emit_text
    mov rcx, [rbp - 32]
    mov edx, [rbp - 60]
    call emit_je_label
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_mov_eax_1]
    call emit_text
    mov rcx, [rbp - 32]
    mov edx, [rbp - 64]
    call emit_jmp_label
    mov rcx, [rbp - 32]
    mov edx, [rbp - 60]
    call emit_plain_label
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_xor_eax_eax]
    call emit_text
    mov rcx, [rbp - 32]
    mov edx, [rbp - 64]
    call emit_plain_label
    xor eax, eax
    jmp .fin

.logical_or:
    mov rcx, [rbp - 16]
    call next_label_id
    mov [rbp - 60], eax
    mov rcx, [rbp - 16]
    call next_label_id
    mov [rbp - 64], eax
    mov rax, [rbp - 40]
    mov edx, [rax + AST_a]
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_expression
    test eax, eax
    js .fin
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_cmp_rax_zero]
    call emit_text
    mov rcx, [rbp - 32]
    mov edx, [rbp - 60]
    call emit_jne_label
    mov rax, [rbp - 40]
    mov edx, [rax + AST_b]
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_expression
    test eax, eax
    js .fin
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_cmp_rax_zero]
    call emit_text
    mov rcx, [rbp - 32]
    mov edx, [rbp - 60]
    call emit_jne_label
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_xor_eax_eax]
    call emit_text
    mov rcx, [rbp - 32]
    mov edx, [rbp - 64]
    call emit_jmp_label
    mov rcx, [rbp - 32]
    mov edx, [rbp - 60]
    call emit_plain_label
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_mov_eax_1]
    call emit_text
    mov rcx, [rbp - 32]
    mov edx, [rbp - 64]
    call emit_plain_label
    xor eax, eax
    jmp .fin

.call:
    mov rax, [rbp - 40]
    mov eax, [rax + AST_aux]
    cmp eax, 0
    jl .unresolved
    mov [rbp - 44], eax
    mov rax, [rbp - 40]
    mov eax, [rax + AST_a]
    mov [rbp - 48], eax
    xor ebx, ebx
.count_args:
    cmp dword [rbp - 48], -1
    je .args_counted
    inc ebx
    mov rcx, [rbp - 16]
    mov edx, [rbp - 48]
    call get_ast_ptr
    mov eax, [rax + AST_next]
    mov [rbp - 48], eax
    jmp .count_args

.args_counted:
    mov [rbp - 56], ebx
    mov eax, ebx
    sub eax, 4
    jg .has_extra_args
    xor eax, eax
.has_extra_args:
    mov [rbp - 60], eax
    shl eax, 3
    add eax, 32
    mov [rbp - 64], eax
    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_sub_rsp]
    mov r8d, [rbp - 64]
    call fprintf

    mov rax, [rbp - 40]
    mov eax, [rax + AST_a]
    mov [rbp - 48], eax
    xor ebx, ebx
.arg_loop:
    cmp dword [rbp - 48], -1
    je .arg_load
    mov edx, [rbp - 48]
    mov rcx, [rbp - 16]
    mov r8, [rbp - 32]
    call emit_expression
    test eax, eax
    jns .arg_store
    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_add_rsp]
    mov r8d, [rbp - 64]
    call fprintf
    mov eax, -1
    jmp .fin
.arg_store:
    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_store_stack_arg]
    mov eax, ebx
    cmp ebx, 4
    jl .store_reg_arg
    sub eax, 4
    shl eax, 3
    add eax, 32
    jmp .store_arg_do
.store_reg_arg:
    shl eax, 3
.store_arg_do:
    mov r8d, eax
    call fprintf
    mov rcx, [rbp - 16]
    mov edx, [rbp - 48]
    call get_ast_ptr
    mov eax, [rax + AST_next]
    mov [rbp - 48], eax
    inc ebx
    jmp .arg_loop

.arg_load:
    cmp ebx, 0
    jle .call_target
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_load_rcx_rsp0]
    call emit_text
    cmp ebx, 1
    jle .call_target
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_load_rdx_rsp8]
    call emit_text
    cmp ebx, 2
    jle .call_target
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_load_r8_rsp16]
    call emit_text
    cmp ebx, 3
    jle .call_target
    mov rcx, [rbp - 32]
    lea rdx, [rel txt_load_r9_rsp24]
    call emit_text

.call_target:
    mov rcx, [rbp - 16]
    mov edx, [rbp - 44]
    call get_function_ptr
    mov [rbp - 88], rax
    mov ecx, [rax + FUNC_name_token]
    mov [rbp - 52], ecx
    mov rcx, [rbp - 16]
    mov edx, [rbp - 52]
    call pablo_token_text
    mov [rbp - 72], rax
    mov [rbp - 76], edx
    mov rcx, [rbp - 32]
    mov rax, [rbp - 88]
    test dword [rax + FUNC_flags], PABLO_FUNC_FLAG_BUILTIN_RUNTIME
    jnz .call_builtin
    test dword [rax + FUNC_flags], PABLO_FUNC_FLAG_EXTERNA
    jz .call_plain
    lea rdx, [rel fmt_call_escaped]
    jmp .call_format_ready
.call_builtin:
    lea rdx, [rel fmt_call]
    jmp .call_format_ready
.call_plain:
    lea rdx, [rel fmt_call]
.call_format_ready:
    mov r8d, [rbp - 76]
    mov r9, [rbp - 72]
    call fprintf
    mov rcx, [rbp - 32]
    lea rdx, [rel fmt_add_rsp]
    mov r8d, [rbp - 64]
    call fprintf
    mov rax, [rbp - 40]
    mov rcx, [rbp - 32]
    mov edx, [rax + AST_tipo]
    call emit_normalize_type
    xor eax, eax
    jmp .fin

.unsupported:
    mov rax, [rbp - 40]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_unsupported]
    mov rcx, [rbp - 16]
    mov edx, PABLO_CODEGEN_NODO_INVALIDO
    call codegen_error_token
    mov eax, -1
    jmp .fin

.unresolved:
    mov rax, [rbp - 40]
    mov r8d, [rax + AST_token]
    lea r9, [rel msg_unresolved]
    mov rcx, [rbp - 16]
    mov edx, PABLO_CODEGEN_NODO_INVALIDO
    call codegen_error_token
    mov eax, -1

.fin:
    add rsp, 120
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

next_label_id:
    mov eax, [rcx + CTX_label_counter]
    inc dword [rcx + CTX_label_counter]
    ret

codegen_is_signed_type:
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

emit_normalize_type:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 8], rcx
    cmp edx, PABLO_TIPO_ENTERO8
    je .i8
    cmp edx, PABLO_TIPO_ENTERO16
    je .i16
    cmp edx, PABLO_TIPO_ENTERO32
    je .i32
    cmp edx, PABLO_TIPO_NATURAL8
    je .u8
    cmp edx, PABLO_TIPO_NATURAL16
    je .u16
    cmp edx, PABLO_TIPO_NATURAL32
    je .u32
    cmp edx, PABLO_TIPO_LOGICO
    je .bool
    jmp .fin
.i8:
    mov rcx, [rbp - 8]
    lea rdx, [rel txt_movsx_rax_al]
    call emit_text
    jmp .fin
.i16:
    mov rcx, [rbp - 8]
    lea rdx, [rel txt_movsx_rax_ax]
    call emit_text
    jmp .fin
.i32:
    mov rcx, [rbp - 8]
    lea rdx, [rel txt_movsxd_rax_eax]
    call emit_text
    jmp .fin
.u8:
    mov rcx, [rbp - 8]
    lea rdx, [rel txt_movzx_eax_al]
    call emit_text
    jmp .fin
.u16:
    mov rcx, [rbp - 8]
    lea rdx, [rel txt_movzx_eax_ax]
    call emit_text
    jmp .fin
.u32:
    mov rcx, [rbp - 8]
    lea rdx, [rel txt_mov_eax_eax]
    call emit_text
    jmp .fin
.bool:
    mov rcx, [rbp - 8]
    lea rdx, [rel txt_cmp_rax_zero]
    call emit_text
    mov rcx, [rbp - 8]
    lea rdx, [rel txt_setne_al]
    call emit_text
    mov rcx, [rbp - 8]
    lea rdx, [rel txt_movzx_eax_al]
    call emit_text
.fin:
    mov rsp, rbp
    pop rbp
    ret

push_loop_labels:
    mov eax, [rel loop_stack_top]
    lea r8, [rel loop_continue_stack]
    mov [r8 + rax * 4], ecx
    lea r8, [rel loop_break_stack]
    mov [r8 + rax * 4], edx
    inc dword [rel loop_stack_top]
    ret

pop_loop_labels:
    cmp dword [rel loop_stack_top], 0
    jle .fin
    dec dword [rel loop_stack_top]
.fin:
    ret

current_continue_label:
    mov eax, [rel loop_stack_top]
    cmp eax, 0
    jg .ok
    mov eax, -1
    ret
.ok:
    dec eax
    lea r8, [rel loop_continue_stack]
    mov eax, [r8 + rax * 4]
    ret

current_break_label:
    mov eax, [rel loop_stack_top]
    cmp eax, 0
    jg .ok
    mov eax, -1
    ret
.ok:
    dec eax
    lea r8, [rel loop_break_stack]
    mov eax, [r8 + rax * 4]
    ret

emit_text:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rax, rcx
    mov rcx, rdx
    mov rdx, rax
    call fputs
    mov rsp, rbp
    pop rbp
    ret

emit_plain_label:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 4], edx
    lea rdx, [rel fmt_label_internal]
    mov r8d, [rbp - 4]
    call fprintf
    mov rsp, rbp
    pop rbp
    ret

emit_jmp_label:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 4], edx
    lea rdx, [rel fmt_jmp_label]
    mov r8d, [rbp - 4]
    call fprintf
    mov rsp, rbp
    pop rbp
    ret

emit_je_label:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 4], edx
    lea rdx, [rel fmt_je_label]
    mov r8d, [rbp - 4]
    call fprintf
    mov rsp, rbp
    pop rbp
    ret

emit_jne_label:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 4], edx
    lea rdx, [rel fmt_jne_label]
    mov r8d, [rbp - 4]
    call fprintf
    mov rsp, rbp
    pop rbp
    ret

emit_exit_label:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 4], edx
    lea rdx, [rel fmt_exit_label]
    mov r8d, [rbp - 4]
    call fprintf
    mov rsp, rbp
    pop rbp
    ret

emit_jmp_exit:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 4], edx
    lea rdx, [rel fmt_jmp_exit]
    mov r8d, [rbp - 4]
    call fprintf
    mov rsp, rbp
    pop rbp
    ret

codegen_error_token:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rsp + 32], r9
    mov r9d, r8d
    mov r8d, edx
    mov edx, PABLO_ETAPA_CODEGEN
    call pablo_set_error_token
    mov rsp, rbp
    pop rbp
    ret
