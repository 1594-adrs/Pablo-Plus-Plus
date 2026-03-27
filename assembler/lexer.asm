default rel

%include "pablocc.inc"
%include "sintaxis.inc"
%include "compilador.inc"

extern printf
extern token_alloc
extern get_token_ptr
extern pablo_range_equals_cstr
extern pablo_token_text
extern pablo_token_type_name
extern pablo_set_error_position

global lexer_preparar
global lexer_dump_tokens

section .rdata
kw_funcion db "funcion", 0
kw_devolver db "devolver", 0
kw_si db "si", 0
kw_si_no db "siNo", 0
kw_mientras db "mientras", 0
kw_para db "para", 0
kw_continuar db "continuar", 0
kw_romper db "romper", 0
kw_sea db "sea", 0
kw_constante db "constante", 0
kw_externa db "externa", 0
kw_vacio db "vacio", 0
kw_logico db "logico", 0
kw_entero8 db "entero8", 0
kw_entero16 db "entero16", 0
kw_entero32 db "entero32", 0
kw_entero64 db "entero64", 0
kw_nat8 db "natural8", 0
kw_nat16 db "natural16", 0
kw_nat32 db "natural32", 0
kw_nat64 db "natural64", 0
kw_verdadero db "verdadero", 0
kw_falso db "falso", 0

msg_char_invalido db "Caracter invalido en el codigo fuente.", 0
msg_comentario_abierto db "Comentario de bloque sin cierre.", 0
msg_entero_invalido db "Literal entero invalido o fuera de rango.", 0
msg_max_tokens db "Se supero la capacidad maxima de tokens.", 0

fmt_token_head db "[%d] %s linea %d columna %d ", 0
fmt_token_text db "texto: %.*s", 10, 0
fmt_token_fin db "texto: <EOF>", 10, 0

section .text
lexer_preparar:
    push rbp
    mov rbp, rsp
    sub rsp, 128

    mov [rbp - 8], rcx     ; ctx
    mov dword [rcx + CTX_token_count], 0

    xor eax, eax
    mov [rbp - 16], rax    ; offset
    mov dword [rbp - 20], 1 ; linea
    mov dword [rbp - 24], 1 ; columna

.loop:
    mov rax, [rbp - 16]
    cmp rax, [rcx + CTX_source_length]
    jae .emit_eof

    mov rdx, [rcx + CTX_source_buffer]
    movzx eax, byte [rdx + rax]

    cmp al, ' '
    je .space
    cmp al, 9
    je .space
    cmp al, 13
    je .space
    cmp al, 10
    je .newline

    cmp al, '/'
    jne .not_comment
    mov r8, [rbp - 16]
    inc r8
    cmp r8, [rcx + CTX_source_length]
    jae .slash_token
    mov rdx, [rcx + CTX_source_buffer]
    movzx edx, byte [rdx + r8]
    cmp dl, '/'
    je .line_comment
    cmp dl, '*'
    je .block_comment
.slash_token:
    jmp .single_slash

.not_comment:
    cmp al, '0'
    jb .check_ident
    cmp al, '9'
    jbe .lex_integer

.check_ident:
    cmp al, 'A'
    jb .check_underscore
    cmp al, 'Z'
    jbe .lex_identifier
    cmp al, 'a'
    jb .check_underscore
    cmp al, 'z'
    jbe .lex_identifier
.check_underscore:
    cmp al, '_'
    je .lex_identifier

    cmp al, '('
    je .token_par_izq
    cmp al, ')'
    je .token_par_der
    cmp al, '{'
    je .token_llave_izq
    cmp al, '}'
    je .token_llave_der
    cmp al, ','
    je .token_coma
    cmp al, ';'
    je .token_pyc
    cmp al, ':'
    je .token_dos_puntos
    cmp al, '+'
    je .token_suma
    cmp al, '*'
    je .token_mul
    cmp al, '%'
    je .token_mod

    cmp al, '-'
    jne .check_equal
    mov r8, [rbp - 16]
    inc r8
    cmp r8, [rcx + CTX_source_length]
    jae .token_resta
    mov rdx, [rcx + CTX_source_buffer]
    movzx edx, byte [rdx + r8]
    cmp dl, '>'
    je .token_flecha
    jmp .token_resta

.check_equal:
    cmp al, '='
    jne .check_not
    mov r8, [rbp - 16]
    inc r8
    cmp r8, [rcx + CTX_source_length]
    jae .token_asignar
    mov rdx, [rcx + CTX_source_buffer]
    movzx edx, byte [rdx + r8]
    cmp dl, '='
    je .token_igual
    jmp .token_asignar

.check_not:
    cmp al, '!'
    jne .check_less
    mov r8, [rbp - 16]
    inc r8
    cmp r8, [rcx + CTX_source_length]
    jae .token_negar
    mov rdx, [rcx + CTX_source_buffer]
    movzx edx, byte [rdx + r8]
    cmp dl, '='
    je .token_distinto
    jmp .token_negar

.check_less:
    cmp al, '<'
    jne .check_greater
    mov r8, [rbp - 16]
    inc r8
    cmp r8, [rcx + CTX_source_length]
    jae .token_menor
    mov rdx, [rcx + CTX_source_buffer]
    movzx edx, byte [rdx + r8]
    cmp dl, '='
    je .token_menor_igual
    jmp .token_menor

.check_greater:
    cmp al, '>'
    jne .check_and
    mov r8, [rbp - 16]
    inc r8
    cmp r8, [rcx + CTX_source_length]
    jae .token_mayor
    mov rdx, [rcx + CTX_source_buffer]
    movzx edx, byte [rdx + r8]
    cmp dl, '='
    je .token_mayor_igual
    jmp .token_mayor

.check_and:
    cmp al, '&'
    jne .check_or
    mov r8, [rbp - 16]
    inc r8
    cmp r8, [rcx + CTX_source_length]
    jae .invalid_char
    mov rdx, [rcx + CTX_source_buffer]
    movzx edx, byte [rdx + r8]
    cmp dl, '&'
    jne .invalid_char
    mov edx, PABLO_TOKEN_Y_LOGICO
    mov r8d, 2
    jmp .emit_fixed

.check_or:
    cmp al, '|'
    jne .invalid_char
    mov r8, [rbp - 16]
    inc r8
    cmp r8, [rcx + CTX_source_length]
    jae .invalid_char
    mov rdx, [rcx + CTX_source_buffer]
    movzx edx, byte [rdx + r8]
    cmp dl, '|'
    jne .invalid_char
    mov edx, PABLO_TOKEN_O_LOGICO
    mov r8d, 2
    jmp .emit_fixed

.single_slash:
    mov edx, PABLO_TOKEN_DIVIDIR
    mov r8d, 1
    jmp .emit_fixed

.space:
    inc qword [rbp - 16]
    inc dword [rbp - 24]
    mov rcx, [rbp - 8]
    jmp .loop

.newline:
    inc qword [rbp - 16]
    inc dword [rbp - 20]
    mov dword [rbp - 24], 1
    mov rcx, [rbp - 8]
    jmp .loop

.line_comment:
    add qword [rbp - 16], 2
    add dword [rbp - 24], 2
.line_comment_loop:
    mov rax, [rbp - 16]
    cmp rax, [rcx + CTX_source_length]
    jae .loop
    mov rdx, [rcx + CTX_source_buffer]
    movzx eax, byte [rdx + rax]
    cmp al, 10
    je .loop
    inc qword [rbp - 16]
    inc dword [rbp - 24]
    jmp .line_comment_loop

.block_comment:
    add qword [rbp - 16], 2
    add dword [rbp - 24], 2
.block_comment_loop:
    mov rax, [rbp - 16]
    cmp rax, [rcx + CTX_source_length]
    jae .error_unclosed_comment
    mov rdx, [rcx + CTX_source_buffer]
    movzx eax, byte [rdx + rax]
    cmp al, 10
    je .block_comment_newline
    cmp al, '*'
    jne .block_comment_next
    mov r8, [rbp - 16]
    inc r8
    cmp r8, [rcx + CTX_source_length]
    jae .error_unclosed_comment
    movzx edx, byte [rdx + r8]
    cmp dl, '/'
    je .block_comment_end
.block_comment_next:
    inc qword [rbp - 16]
    inc dword [rbp - 24]
    jmp .block_comment_loop
.block_comment_newline:
    inc qword [rbp - 16]
    inc dword [rbp - 20]
    mov dword [rbp - 24], 1
    jmp .block_comment_loop
.block_comment_end:
    add qword [rbp - 16], 2
    add dword [rbp - 24], 2
    mov rcx, [rbp - 8]
    jmp .loop

.lex_integer:
    mov rax, [rbp - 16]
    mov [rbp - 48], rax
    mov eax, [rbp - 24]
    mov [rbp - 52], eax
    xor r10, r10
.int_loop:
    mov rax, [rbp - 16]
    cmp rax, [rcx + CTX_source_length]
    jae .emit_integer
    mov rdx, [rcx + CTX_source_buffer]
    movzx eax, byte [rdx + rax]
    cmp al, '0'
    jb .emit_integer
    cmp al, '9'
    ja .emit_integer
    imul r10, r10, 10
    movzx eax, al
    sub eax, '0'
    add r10, rax
    cmp r10, 2147483647
    ja .error_bad_integer
    inc qword [rbp - 16]
    inc dword [rbp - 24]
    jmp .int_loop

.emit_integer:
    mov rcx, [rbp - 8]
    call token_alloc
    test rax, rax
    jz .error_max_tokens
    mov dword [rax + TOKEN_tipo], PABLO_TOKEN_ENTERO
    mov edx, [rbp - 20]
    mov [rax + TOKEN_linea], edx
    mov edx, [rbp - 52]
    mov [rax + TOKEN_columna], edx
    mov rdx, [rbp - 48]
    mov [rax + TOKEN_offset], rdx
    mov rdx, [rbp - 16]
    sub rdx, [rbp - 48]
    mov [rax + TOKEN_longitud], edx
    mov [rax + TOKEN_valor], r10
    mov rcx, [rbp - 8]
    jmp .loop

.lex_identifier:
    mov rax, [rbp - 16]
    mov [rbp - 48], rax
    mov eax, [rbp - 24]
    mov [rbp - 52], eax
.ident_loop:
    mov rax, [rbp - 16]
    cmp rax, [rcx + CTX_source_length]
    jae .ident_done
    mov rdx, [rcx + CTX_source_buffer]
    movzx eax, byte [rdx + rax]
    cmp al, '0'
    jb .ident_alpha
    cmp al, '9'
    jbe .ident_next
.ident_alpha:
    cmp al, 'A'
    jb .ident_underscore
    cmp al, 'Z'
    jbe .ident_next
    cmp al, 'a'
    jb .ident_underscore
    cmp al, 'z'
    jbe .ident_next
.ident_underscore:
    cmp al, '_'
    jne .ident_done
.ident_next:
    inc qword [rbp - 16]
    inc dword [rbp - 24]
    jmp .ident_loop

.ident_done:
    mov rax, [rbp - 16]
    sub rax, [rbp - 48]
    mov [rbp - 56], eax
    mov rdx, [rcx + CTX_source_buffer]
    add rdx, [rbp - 48]
    mov rcx, rdx
    mov edx, [rbp - 56]
    call classify_identifier
    mov [rbp - 60], eax
    mov [rbp - 64], edx

    mov rcx, [rbp - 8]
    call token_alloc
    test rax, rax
    jz .error_max_tokens
    mov edx, [rbp - 60]
    mov [rax + TOKEN_tipo], edx
    mov edx, [rbp - 20]
    mov [rax + TOKEN_linea], edx
    mov edx, [rbp - 52]
    mov [rax + TOKEN_columna], edx
    mov rdx, [rbp - 48]
    mov [rax + TOKEN_offset], rdx
    mov edx, [rbp - 56]
    mov [rax + TOKEN_longitud], edx
    mov edx, [rbp - 64]
    mov [rax + TOKEN_valor], rdx
    mov rcx, [rbp - 8]
    jmp .loop

.token_par_izq:
    mov edx, PABLO_TOKEN_PAR_IZQ
    mov r8d, 1
    jmp .emit_fixed
.token_par_der:
    mov edx, PABLO_TOKEN_PAR_DER
    mov r8d, 1
    jmp .emit_fixed
.token_llave_izq:
    mov edx, PABLO_TOKEN_LLAVE_IZQ
    mov r8d, 1
    jmp .emit_fixed
.token_llave_der:
    mov edx, PABLO_TOKEN_LLAVE_DER
    mov r8d, 1
    jmp .emit_fixed
.token_coma:
    mov edx, PABLO_TOKEN_COMA
    mov r8d, 1
    jmp .emit_fixed
.token_pyc:
    mov edx, PABLO_TOKEN_PUNTO_Y_COMA
    mov r8d, 1
    jmp .emit_fixed
.token_dos_puntos:
    mov edx, PABLO_TOKEN_DOS_PUNTOS
    mov r8d, 1
    jmp .emit_fixed
.token_suma:
    mov edx, PABLO_TOKEN_SUMA
    mov r8d, 1
    jmp .emit_fixed
.token_resta:
    mov edx, PABLO_TOKEN_RESTA
    mov r8d, 1
    jmp .emit_fixed
.token_mul:
    mov edx, PABLO_TOKEN_MULTIPLICAR
    mov r8d, 1
    jmp .emit_fixed
.token_mod:
    mov edx, PABLO_TOKEN_MODULO
    mov r8d, 1
    jmp .emit_fixed
.token_flecha:
    mov edx, PABLO_TOKEN_FLECHA
    mov r8d, 2
    jmp .emit_fixed
.token_asignar:
    mov edx, PABLO_TOKEN_ASIGNAR
    mov r8d, 1
    jmp .emit_fixed
.token_igual:
    mov edx, PABLO_TOKEN_IGUAL_QUE
    mov r8d, 2
    jmp .emit_fixed
.token_distinto:
    mov edx, PABLO_TOKEN_DISTINTO_QUE
    mov r8d, 2
    jmp .emit_fixed
.token_negar:
    mov edx, PABLO_TOKEN_NEGAR
    mov r8d, 1
    jmp .emit_fixed
.token_menor:
    mov edx, PABLO_TOKEN_MENOR_QUE
    mov r8d, 1
    jmp .emit_fixed
.token_menor_igual:
    mov edx, PABLO_TOKEN_MENOR_O_IGUAL
    mov r8d, 2
    jmp .emit_fixed
.token_mayor:
    mov edx, PABLO_TOKEN_MAYOR_QUE
    mov r8d, 1
    jmp .emit_fixed
.token_mayor_igual:
    mov edx, PABLO_TOKEN_MAYOR_O_IGUAL
    mov r8d, 2
    jmp .emit_fixed

.emit_fixed:
    mov [rbp - 68], edx
    mov [rbp - 72], r8d
    mov rax, [rbp - 16]
    mov [rbp - 48], rax
    mov eax, [rbp - 24]
    mov [rbp - 52], eax
    add qword [rbp - 16], r8
    add dword [rbp - 24], r8d
    mov rcx, [rbp - 8]
    call token_alloc
    test rax, rax
    jz .error_max_tokens
    mov edx, [rbp - 68]
    mov [rax + TOKEN_tipo], edx
    mov edx, [rbp - 20]
    mov [rax + TOKEN_linea], edx
    mov edx, [rbp - 52]
    mov [rax + TOKEN_columna], edx
    mov rdx, [rbp - 48]
    mov [rax + TOKEN_offset], rdx
    mov edx, [rbp - 72]
    mov [rax + TOKEN_longitud], edx
    mov qword [rax + TOKEN_valor], 0
    mov rcx, [rbp - 8]
    jmp .loop

.emit_eof:
    mov rcx, [rbp - 8]
    call token_alloc
    test rax, rax
    jz .error_max_tokens
    mov dword [rax + TOKEN_tipo], PABLO_TOKEN_FIN_ARCHIVO
    mov edx, [rbp - 20]
    mov [rax + TOKEN_linea], edx
    mov edx, [rbp - 24]
    mov [rax + TOKEN_columna], edx
    mov rdx, [rbp - 16]
    mov [rax + TOKEN_offset], rdx
    mov dword [rax + TOKEN_longitud], 0
    mov qword [rax + TOKEN_valor], 0
    xor eax, eax
    jmp .fin

.invalid_char:
    mov rcx, [rbp - 8]
    mov edx, PABLO_ETAPA_LEXER
    mov r8d, PABLO_LEXER_CARACTER_INVALIDO
    mov r9d, [rbp - 20]
    mov eax, [rbp - 24]
    mov [rsp + 32], eax
    mov rax, [rbp - 16]
    mov [rsp + 40], rax
    lea rax, [rel msg_char_invalido]
    mov [rsp + 48], rax
    call pablo_set_error_position
    jmp .fin

.error_unclosed_comment:
    mov rcx, [rbp - 8]
    mov edx, PABLO_ETAPA_LEXER
    mov r8d, PABLO_LEXER_COMENTARIO_SIN_CERRAR
    mov r9d, [rbp - 20]
    mov eax, [rbp - 24]
    mov [rsp + 32], eax
    mov rax, [rbp - 16]
    mov [rsp + 40], rax
    lea rax, [rel msg_comentario_abierto]
    mov [rsp + 48], rax
    call pablo_set_error_position
    jmp .fin

.error_bad_integer:
    mov rcx, [rbp - 8]
    mov edx, PABLO_ETAPA_LEXER
    mov r8d, PABLO_LEXER_ENTERO_INVALIDO
    mov r9d, [rbp - 20]
    mov eax, [rbp - 52]
    mov [rsp + 32], eax
    mov rax, [rbp - 48]
    mov [rsp + 40], rax
    lea rax, [rel msg_entero_invalido]
    mov [rsp + 48], rax
    call pablo_set_error_position
    jmp .fin

.error_max_tokens:
    mov rcx, [rbp - 8]
    mov edx, PABLO_ETAPA_LEXER
    mov r8d, PABLO_LEXER_MAX_TOKENS
    mov r9d, [rbp - 20]
    mov eax, [rbp - 24]
    mov [rsp + 32], eax
    mov rax, [rbp - 16]
    mov [rsp + 40], rax
    lea rax, [rel msg_max_tokens]
    mov [rsp + 48], rax
    call pablo_set_error_position

.fin:
    mov rsp, rbp
    pop rbp
    ret

classify_identifier:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    xor edx, edx

    mov edx, [rbp - 12]
    lea r8, [rel kw_funcion]
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_devolver
    mov eax, PABLO_TOKEN_FUNCION
    jmp .fin
.check_devolver:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_devolver
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_si
    mov eax, PABLO_TOKEN_DEVOLVER
    jmp .fin
.check_si:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_si
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_si_no
    mov eax, PABLO_TOKEN_SI
    jmp .fin
.check_si_no:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_si_no
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_mientras
    mov eax, PABLO_TOKEN_SI_NO
    jmp .fin
.check_mientras:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_mientras
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_para
    mov eax, PABLO_TOKEN_MIENTRAS
    jmp .fin
.check_para:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_para
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_continuar
    mov eax, PABLO_TOKEN_PARA
    jmp .fin
.check_continuar:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_continuar
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_romper
    mov eax, PABLO_TOKEN_CONTINUAR
    jmp .fin
.check_romper:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_romper
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_sea
    mov eax, PABLO_TOKEN_ROMPER
    jmp .fin
.check_sea:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_sea
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_constante
    mov eax, PABLO_TOKEN_SEA
    jmp .fin
.check_constante:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_constante
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_externa
    mov eax, PABLO_TOKEN_CONSTANTE
    jmp .fin
.check_externa:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_externa
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_vacio
    mov eax, PABLO_TOKEN_EXTERNA
    jmp .fin
.check_vacio:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_vacio
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_logico
    mov eax, PABLO_TOKEN_TIPO_VACIO
    jmp .fin
.check_logico:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_logico
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_entero8
    mov eax, PABLO_TOKEN_TIPO_LOGICO
    jmp .fin
.check_entero8:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_entero8
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_entero16
    mov eax, PABLO_TOKEN_TIPO_ENTERO8
    jmp .fin
.check_entero16:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_entero16
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_entero32
    mov eax, PABLO_TOKEN_TIPO_ENTERO16
    jmp .fin
.check_entero32:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_entero32
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_entero64
    mov eax, PABLO_TOKEN_TIPO_ENTERO32
    jmp .fin
.check_entero64:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_entero64
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_nat8
    mov eax, PABLO_TOKEN_TIPO_ENTERO64
    jmp .fin
.check_nat8:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_nat8
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_nat16
    mov eax, PABLO_TOKEN_TIPO_NATURAL8
    jmp .fin
.check_nat16:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_nat16
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_nat32
    mov eax, PABLO_TOKEN_TIPO_NATURAL16
    jmp .fin
.check_nat32:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_nat32
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_nat64
    mov eax, PABLO_TOKEN_TIPO_NATURAL32
    jmp .fin
.check_nat64:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_nat64
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_true
    mov eax, PABLO_TOKEN_TIPO_NATURAL64
    jmp .fin
.check_true:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_verdadero
    call pablo_range_equals_cstr
    test eax, eax
    jz .check_false
    mov eax, PABLO_TOKEN_LOGICO
    mov edx, 1
    jmp .fin
.check_false:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov r8, kw_falso
    call pablo_range_equals_cstr
    test eax, eax
    jz .default_ident
    mov eax, PABLO_TOKEN_LOGICO
    xor edx, edx
    jmp .fin
.default_ident:
    mov eax, PABLO_TOKEN_IDENTIFICADOR
    xor edx, edx
.fin:
    mov rsp, rbp
    pop rbp
    ret

lexer_dump_tokens:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp - 8], rcx
    xor ebx, ebx
.dump_loop:
    cmp ebx, [rcx + CTX_token_count]
    jge .fin
    mov edx, ebx
    call get_token_ptr
    mov [rbp - 16], rax
    mov edx, [rax + TOKEN_tipo]
    call pablo_token_type_name
    mov [rbp - 24], rax
    mov rcx, fmt_token_head
    mov edx, ebx
    mov r8, [rbp - 24]
    mov rax, [rbp - 16]
    mov r9d, [rax + TOKEN_linea]
    mov eax, [rax + TOKEN_columna]
    mov [rsp + 32], eax
    call printf
    mov rax, [rbp - 16]
    cmp dword [rax + TOKEN_tipo], PABLO_TOKEN_FIN_ARCHIVO
    je .print_eof
    mov rcx, [rbp - 8]
    mov edx, ebx
    call pablo_token_text
    mov [rbp - 32], rax
    mov [rbp - 36], edx
    mov rcx, fmt_token_text
    mov edx, [rbp - 36]
    mov r8, [rbp - 32]
    call printf
    jmp .next
.print_eof:
    mov rcx, fmt_token_fin
    call printf
.next:
    mov rcx, [rbp - 8]
    inc ebx
    jmp .dump_loop
.fin:
    mov rsp, rbp
    pop rbp
    ret
