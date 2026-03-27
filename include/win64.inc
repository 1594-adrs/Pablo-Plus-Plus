%ifndef WIN64_INC
%define WIN64_INC

; ABI objetivo: Microsoft x64 / Win64
%define WIN64_SHADOW_SPACE 32
%define WIN64_STACK_ALIGNMENT 16

; Registros de argumentos enteros/punteros
%define WIN64_ARG0 rcx
%define WIN64_ARG1 rdx
%define WIN64_ARG2 r8
%define WIN64_ARG3 r9

; Registro de retorno
%define WIN64_RETORNO rax

; Registros preservados por el callee
; rbx, rbp, rdi, rsi, r12-r15, xmm6-xmm15

%endif

