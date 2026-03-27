default rel

global main
global imprimirEntero8
global imprimirEntero16
global imprimirEntero32
global imprimirEntero64
global imprimirNatural8
global imprimirNatural16
global imprimirNatural32
global imprimirNatural64
global imprimirLogico
global imprimirLinea

extern historiaPrincipal
extern printf
extern puts

section .rdata
fmt_entero8 db "%hhd", 0
fmt_entero16 db "%hd", 0
fmt_entero32 db "%d", 0
fmt_entero64 db "%lld", 0
fmt_natural8 db "%hhu", 0
fmt_natural16 db "%hu", 0
fmt_natural32 db "%u", 0
fmt_natural64 db "%llu", 0
fmt_logico db "%s", 0
texto_vacio db "", 0
texto_verdadero db "verdadero", 0
texto_falso db "falso", 0

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    call historiaPrincipal
    mov rsp, rbp
    pop rbp
    ret

imprimirEntero8:
    lea rax, [rel fmt_entero8]
    jmp imprimir_formato_unario

imprimirEntero16:
    lea rax, [rel fmt_entero16]
    jmp imprimir_formato_unario

imprimirEntero32:
    lea rax, [rel fmt_entero32]
    jmp imprimir_formato_unario

imprimirEntero64:
    lea rax, [rel fmt_entero64]
    jmp imprimir_formato_unario

imprimirNatural8:
    lea rax, [rel fmt_natural8]
    jmp imprimir_formato_unario

imprimirNatural16:
    lea rax, [rel fmt_natural16]
    jmp imprimir_formato_unario

imprimirNatural32:
    lea rax, [rel fmt_natural32]
    jmp imprimir_formato_unario

imprimirNatural64:
    lea rax, [rel fmt_natural64]
    jmp imprimir_formato_unario

imprimir_formato_unario:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rdx, rcx
    mov rcx, rax
    call printf
    mov rsp, rbp
    pop rbp
    ret

imprimirLogico:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    cmp rcx, 0
    je .falso
    lea rdx, [rel texto_verdadero]
    jmp .emitir
.falso:
    lea rdx, [rel texto_falso]
.emitir:
    lea rcx, [rel fmt_logico]
    call printf
    mov rsp, rbp
    pop rbp
    ret

imprimirLinea:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    lea rcx, [rel texto_vacio]
    call puts
    mov rsp, rbp
    pop rbp
    ret
