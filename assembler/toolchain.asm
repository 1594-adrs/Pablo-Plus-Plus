default rel

%include "pablocc.inc"
%include "compilador.inc"

extern system
extern pablo_set_error_simple

global toolchain_preparar

section .rdata
powershell_exe db "powershell.exe", 0
arg_exec_policy db " -ExecutionPolicy Bypass -File ", 0
arg_asm db " -AsmPath ", 0
arg_runtime db " -RuntimePath ", 0
arg_exe db " -ExePath ", 0
msg_toolchain db "La toolchain externa fallo. Revisa la salida previa de program-build.ps1, NASM/GCC y la ruta indicada con -o.", 0

section .bss
toolchain_command resb PABLO_MAX_COMMAND

section .text
toolchain_preparar:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx

    lea rcx, [rel toolchain_command]
    lea rdx, [rel powershell_exe]
    call append_cstr
    mov [rbp - 16], rax

    mov rcx, [rbp - 16]
    lea rdx, [rel arg_exec_policy]
    call append_cstr
    mov [rbp - 16], rax

    mov rcx, [rbp - 16]
    mov rdx, [rbp - 8]
    mov rdx, [rdx + CTX_toolchain_script_path]
    call append_quoted_cstr
    mov [rbp - 16], rax

    mov rcx, [rbp - 16]
    lea rdx, [rel arg_asm]
    call append_cstr
    mov [rbp - 16], rax

    mov rcx, [rbp - 16]
    mov rdx, [rbp - 8]
    mov rdx, [rdx + CTX_output_asm_path]
    call append_quoted_cstr
    mov [rbp - 16], rax

    mov rcx, [rbp - 16]
    lea rdx, [rel arg_runtime]
    call append_cstr
    mov [rbp - 16], rax

    mov rcx, [rbp - 16]
    mov rdx, [rbp - 8]
    mov rdx, [rdx + CTX_runtime_asm_path]
    call append_quoted_cstr
    mov [rbp - 16], rax

    mov rcx, [rbp - 16]
    lea rdx, [rel arg_exe]
    call append_cstr
    mov [rbp - 16], rax

    mov rcx, [rbp - 16]
    mov rdx, [rbp - 8]
    mov rdx, [rdx + CTX_output_exe_path]
    call append_quoted_cstr

    lea rcx, [rel toolchain_command]
    call system
    test eax, eax
    jz .ok

    mov rcx, [rbp - 8]
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_TOOLCHAIN_FALLO
    lea r9, [rel msg_toolchain]
    call pablo_set_error_simple
    mov eax, -1
    jmp .fin

.ok:
    xor eax, eax
.fin:
    mov rsp, rbp
    pop rbp
    ret

append_cstr:
    xor r8d, r8d
.loop:
    mov al, [rdx + r8]
    mov [rcx + r8], al
    cmp al, 0
    je .fin
    inc r8
    jmp .loop
.fin:
    lea rax, [rcx + r8]
    ret

append_quoted_cstr:
    mov byte [rcx], '"'
    inc rcx
    call append_cstr
    mov byte [rax], '"'
    inc rax
    mov byte [rax], 0
    ret
