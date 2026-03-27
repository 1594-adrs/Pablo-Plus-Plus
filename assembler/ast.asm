default rel

%include "pablocc.inc"
%include "sintaxis.inc"
%include "compilador.inc"

extern printf
extern get_ast_ptr
extern pablo_ast_kind_name
extern pablo_token_text
extern pablo_token_type_name

global ast_preparar
global ast_dump_tree

section .rdata
fmt_header db "AST (%d nodos)", 10, 0
fmt_indent db "%s", 0
fmt_simple db "- %s", 10, 0
fmt_name db "- %s nombre=%.*s", 10, 0
fmt_value db "- %s valor=%lld", 10, 0
fmt_operator db "- %s operador=%s", 10, 0

indent_piece db "  ", 0

section .text
ast_preparar:
    xor eax, eax
    ret

ast_dump_tree:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx

    lea rcx, [rel fmt_header]
    mov rax, [rbp - 8]
    mov edx, [rax + CTX_ast_count]
    call printf

    mov rcx, [rbp - 8]
    xor edx, edx
    xor r8d, r8d
    call dump_node_recursive

    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret

dump_node_recursive:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 16], r8d

    cmp dword [rbp - 12], -1
    je .ok

    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    call get_ast_ptr
    mov [rbp - 24], rax

    mov ecx, [rbp - 16]
    call print_indent

    mov rcx, [rbp - 8]
    mov rdx, [rbp - 24]
    call print_node_line

    mov eax, [rbp - 16]
    inc eax
    mov [rbp - 28], eax

    mov rax, [rbp - 24]
    mov edx, [rax + AST_a]
    cmp edx, -1
    je .child_b
    mov rcx, [rbp - 8]
    mov r8d, [rbp - 28]
    call dump_node_recursive

.child_b:
    mov rax, [rbp - 24]
    mov edx, [rax + AST_b]
    cmp edx, -1
    je .child_c
    mov rcx, [rbp - 8]
    mov r8d, [rbp - 28]
    call dump_node_recursive

.child_c:
    mov rax, [rbp - 24]
    mov edx, [rax + AST_c]
    cmp edx, -1
    je .extra_child
    mov rcx, [rbp - 8]
    mov r8d, [rbp - 28]
    call dump_node_recursive

.extra_child:
    mov rax, [rbp - 24]
    cmp dword [rax + AST_kind], PABLO_AST_SENTENCIA_PARA
    jne .next
    mov edx, [rax + AST_valor]
    cmp edx, -1
    je .next
    mov rcx, [rbp - 8]
    mov r8d, [rbp - 28]
    call dump_node_recursive

.next:
    mov rax, [rbp - 24]
    mov edx, [rax + AST_next]
    cmp edx, -1
    je .ok
    mov rcx, [rbp - 8]
    mov r8d, [rbp - 16]
    call dump_node_recursive

.ok:
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret

print_indent:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 4], ecx

.loop:
    cmp dword [rbp - 4], 0
    jle .fin
    lea rcx, [rel fmt_indent]
    lea rdx, [rel indent_piece]
    call printf
    dec dword [rbp - 4]
    jmp .loop

.fin:
    mov rsp, rbp
    pop rbp
    ret

print_node_line:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    mov [rbp - 16], rdx

    mov edx, [rdx + AST_kind]
    call pablo_ast_kind_name
    mov [rbp - 24], rax

    mov rax, [rbp - 16]
    mov edx, [rax + AST_kind]
    cmp edx, PABLO_AST_LITERAL_ENTERO
    je .value
    cmp edx, PABLO_AST_LITERAL_LOGICO
    je .value
    cmp edx, PABLO_AST_DECLARACION_FUNCION
    je .named
    cmp edx, PABLO_AST_DECLARACION_EXTERNA
    je .named
    cmp edx, PABLO_AST_PARAMETRO
    je .named
    cmp edx, PABLO_AST_DECLARACION_VARIABLE
    je .named
    cmp edx, PABLO_AST_DECLARACION_CONSTANTE
    je .named
    cmp edx, PABLO_AST_IDENTIFICADOR
    je .named
    cmp edx, PABLO_AST_LLAMADA
    je .named
    cmp edx, PABLO_AST_UNARIO
    je .operator
    cmp edx, PABLO_AST_BINARIO
    je .operator

    lea rcx, [rel fmt_simple]
    mov rdx, [rbp - 24]
    call printf
    jmp .fin

.named:
    mov rax, [rbp - 16]
    mov edx, [rax + AST_token]
    cmp edx, -1
    je .simple_fallback
    mov rcx, [rbp - 8]
    call pablo_token_text
    mov [rbp - 32], rax
    mov [rbp - 36], edx
    lea rcx, [rel fmt_name]
    mov rdx, [rbp - 24]
    mov r8d, [rbp - 36]
    mov r9, [rbp - 32]
    call printf
    jmp .fin

.operator:
    mov rax, [rbp - 16]
    mov edx, [rax + AST_aux]
    call pablo_token_type_name
    mov [rbp - 40], rax
    lea rcx, [rel fmt_operator]
    mov rdx, [rbp - 24]
    mov r8, [rbp - 40]
    call printf
    jmp .fin

.value:
    lea rcx, [rel fmt_value]
    mov rdx, [rbp - 24]
    mov rax, [rbp - 16]
    mov r8, [rax + AST_valor]
    call printf
    jmp .fin

.simple_fallback:
    lea rcx, [rel fmt_simple]
    mov rdx, [rbp - 24]
    call printf

.fin:
    mov rsp, rbp
    pop rbp
    ret
