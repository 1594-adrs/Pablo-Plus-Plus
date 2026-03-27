default rel

%include "win64.inc"
%include "pablocc.inc"

extern puts
extern ExitProcess
extern pipeline_compilar

global main

section .rdata
banner_inicio db "pablocc 0.1.0 - compilador anfitrion de pablo-plus-plus", 0
banner_objetivo db "Objetivo actual: compilar un subconjunto serio hasta .exe con historiaPrincipal().", 0

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, WIN64_SHADOW_SPACE + 16

    mov [rbp - 8], rcx
    mov [rbp - 16], rdx

    lea rcx, [banner_inicio]
    call puts

    lea rcx, [banner_objetivo]
    call puts

    mov rcx, [rbp - 8]
    mov rdx, [rbp - 16]
    call pipeline_compilar
    mov ecx, eax
    call ExitProcess
