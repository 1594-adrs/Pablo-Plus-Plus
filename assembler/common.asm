default rel

%include "pablocc.inc"
%include "sintaxis.inc"
%include "compilador.inc"

extern fopen
extern fclose
extern fseek
extern ftell
extern fread
extern printf
extern puts
extern system
extern GetModuleFileNameA

global compiler_get_context
global ctx_reset
global pablo_make_build_dir
global pablo_load_source
global token_alloc
global ast_alloc
global function_alloc
global local_alloc
global get_token_ptr
global get_ast_ptr
global get_function_ptr
global get_local_ptr
global pablo_range_equals_cstr
global pablo_token_equals_token
global pablo_token_text
global pablo_token_type_name
global pablo_ast_kind_name
global pablo_stage_name
global pablo_map_type_token
global pablo_set_error_simple
global pablo_set_error_token
global pablo_set_error_position
global pablo_print_diagnostic
global pablo_print_usage
global pablo_copy_cstring
global pablo_align16

section .data
cmd_make_build db "if not exist build mkdir build", 0
modo_rb db "rb", 0
fmt_error db "error[%s:%d] linea %d columna %d: %s", 10, 0
fmt_usage_1 db "Uso: pablocc archivo.p++ [-tokens | -ast | -emit-asm] [-o salida.exe]", 0
fmt_usage_2 db "V1 actual: compila una sola unidad fuente y ya genera .exe para el subconjunto verificado.", 0
path_asm_default db "build\\program.asm", 0
path_exe_default db "build\\program.exe", 0
path_runtime_default db "runtime\\program_runtime.asm", 0
path_script_default db ".\\program-build.ps1", 0
suffix_program_asm db "\\program.asm", 0
suffix_program_exe db "\\program.exe", 0
suffix_runtime_asm db "\\runtime\\program_runtime.asm", 0
suffix_toolchain_script db "\\assembler\\program-build.ps1", 0

stage_cli db "cli", 0
stage_lexer db "lexer", 0
stage_parser db "parser", 0
stage_ast db "ast", 0
stage_semantic db "semantic", 0
stage_codegen db "codegen", 0
stage_toolchain db "toolchain", 0
stage_unknown db "unknown", 0

token_name_eof db "FIN_ARCHIVO", 0
token_name_ident db "IDENTIFICADOR", 0
token_name_entero db "ENTERO", 0
token_name_logico db "LOGICO", 0
token_name_cadena db "CADENA", 0
token_name_par_izq db "PAR_IZQ", 0
token_name_par_der db "PAR_DER", 0
token_name_llave_izq db "LLAVE_IZQ", 0
token_name_llave_der db "LLAVE_DER", 0
token_name_coma db "COMA", 0
token_name_pyc db "PUNTO_Y_COMA", 0
token_name_dos_puntos db "DOS_PUNTOS", 0
token_name_flecha db "FLECHA", 0
token_name_asignar db "ASIGNAR", 0
token_name_suma db "SUMA", 0
token_name_resta db "RESTA", 0
token_name_mul db "MULTIPLICAR", 0
token_name_div db "DIVIDIR", 0
token_name_mod db "MODULO", 0
token_name_igual db "IGUAL_QUE", 0
token_name_dist db "DISTINTO_QUE", 0
token_name_menor db "MENOR_QUE", 0
token_name_menor_igual db "MENOR_O_IGUAL", 0
token_name_mayor db "MAYOR_QUE", 0
token_name_mayor_igual db "MAYOR_O_IGUAL", 0
token_name_y db "Y_LOGICO", 0
token_name_o db "O_LOGICO", 0
token_name_negar db "NEGAR", 0
token_name_funcion db "FUNCION", 0
token_name_devolver db "DEVOLVER", 0
token_name_si db "SI", 0
token_name_si_no db "SI_NO", 0
token_name_mientras db "MIENTRAS", 0
token_name_para db "PARA", 0
token_name_continuar db "CONTINUAR", 0
token_name_romper db "ROMPER", 0
token_name_sea db "SEA", 0
token_name_constante db "CONSTANTE", 0
token_name_externa db "EXTERNA", 0
token_name_tipo_vacio db "TIPO_VACIO", 0
token_name_tipo_logico db "TIPO_LOGICO", 0
token_name_tipo_entero8 db "TIPO_ENTERO8", 0
token_name_tipo_entero16 db "TIPO_ENTERO16", 0
token_name_tipo_entero32 db "TIPO_ENTERO32", 0
token_name_tipo_entero64 db "TIPO_ENTERO64", 0
token_name_tipo_nat8 db "TIPO_NATURAL8", 0
token_name_tipo_nat16 db "TIPO_NATURAL16", 0
token_name_tipo_nat32 db "TIPO_NATURAL32", 0
token_name_tipo_nat64 db "TIPO_NATURAL64", 0
token_name_desconocido db "TOKEN_DESCONOCIDO", 0

ast_name_programa db "PROGRAMA", 0
ast_name_funcion db "FUNCION", 0
ast_name_param db "PARAMETRO", 0
ast_name_bloque db "BLOQUE", 0
ast_name_decl_var db "DECLARACION_VARIABLE", 0
ast_name_decl_const db "DECLARACION_CONSTANTE", 0
ast_name_decl_externa db "DECLARACION_EXTERNA", 0
ast_name_si db "SENTENCIA_SI", 0
ast_name_mientras db "SENTENCIA_MIENTRAS", 0
ast_name_para db "SENTENCIA_PARA", 0
ast_name_devolver db "SENTENCIA_DEVOLVER", 0
ast_name_expr db "SENTENCIA_EXPRESION", 0
ast_name_continuar db "SENTENCIA_CONTINUAR", 0
ast_name_romper db "SENTENCIA_ROMPER", 0
ast_name_lit_ent db "LITERAL_ENTERO", 0
ast_name_lit_log db "LITERAL_LOGICO", 0
ast_name_ident db "IDENTIFICADOR", 0
ast_name_llamada db "LLAMADA", 0
ast_name_unario db "UNARIO", 0
ast_name_binario db "BINARIO", 0
ast_name_asign db "ASIGNACION", 0
ast_name_desconocido db "AST_DESCONOCIDO", 0

section .bss
align 16
ctx_global resb CTX_SIZE
source_buffer resb PABLO_MAX_SOURCE_BYTES + 1
tokens_buffer resb TOKEN_SIZE * PABLO_MAX_TOKENS
ast_buffer resb AST_SIZE * PABLO_MAX_AST_NODES
functions_buffer resb FUNC_SIZE * PABLO_MAX_FUNCTIONS
locals_buffer resb LOCAL_SIZE * PABLO_MAX_LOCALS
path_asm_buffer resb PABLO_MAX_PATH
path_exe_buffer resb PABLO_MAX_PATH
path_runtime_buffer resb PABLO_MAX_PATH
path_script_buffer resb PABLO_MAX_PATH
module_path_buffer resb PABLO_MAX_PATH
repo_root_buffer resb PABLO_MAX_PATH

section .text
compiler_get_context:
    lea rax, [rel ctx_global]
    ret

ctx_reset:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov qword [rcx + CTX_source_path], 0
    mov dword [rcx + CTX_mode], PABLO_MODO_COMPILAR
    mov dword [rcx + CTX_flags], 0
    lea rax, [rel source_buffer]
    mov qword [rcx + CTX_source_buffer], rax
    mov qword [rcx + CTX_source_length], 0
    lea rax, [rel tokens_buffer]
    mov qword [rcx + CTX_tokens_ptr], rax
    mov dword [rcx + CTX_token_count], 0
    mov dword [rcx + CTX_token_capacity], PABLO_MAX_TOKENS
    lea rax, [rel ast_buffer]
    mov qword [rcx + CTX_ast_ptr], rax
    mov dword [rcx + CTX_ast_count], 0
    mov dword [rcx + CTX_ast_capacity], PABLO_MAX_AST_NODES
    lea rax, [rel functions_buffer]
    mov qword [rcx + CTX_functions_ptr], rax
    mov dword [rcx + CTX_function_count], 0
    mov dword [rcx + CTX_function_capacity], PABLO_MAX_FUNCTIONS
    lea rax, [rel locals_buffer]
    mov qword [rcx + CTX_locals_ptr], rax
    mov dword [rcx + CTX_local_count], 0
    mov dword [rcx + CTX_local_capacity], PABLO_MAX_LOCALS
    mov dword [rcx + CTX_current_token], 0
    mov dword [rcx + CTX_current_function], -1
    mov dword [rcx + CTX_current_depth], 0
    mov dword [rcx + CTX_current_slot], 0
    mov dword [rcx + CTX_max_slot], 0
    mov dword [rcx + CTX_label_counter], 0
    mov dword [rcx + CTX_diag_stage], 0
    mov dword [rcx + CTX_diag_code], 0
    mov dword [rcx + CTX_diag_line], 0
    mov dword [rcx + CTX_diag_column], 0
    mov qword [rcx + CTX_diag_offset], 0
    mov qword [rcx + CTX_diag_message], 0
    mov dword [rcx + CTX_loop_depth], 0

    lea rax, [rel path_asm_default]
    mov qword [rel ctx_global + CTX_output_asm_path], rax
    lea rax, [rel path_exe_default]
    mov qword [rel ctx_global + CTX_output_exe_path], rax
    lea rax, [rel path_runtime_default]
    mov qword [rel ctx_global + CTX_runtime_asm_path], rax
    lea rax, [rel path_script_default]
    mov qword [rel ctx_global + CTX_toolchain_script_path], rax

    mov byte [rel source_buffer], 0
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret

pablo_make_build_dir:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    lea rcx, [rel cmd_make_build]
    call system
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret

pablo_init_default_paths:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    xor ecx, ecx
    lea rdx, [rel module_path_buffer]
    mov r8d, PABLO_MAX_PATH
    call GetModuleFileNameA
    test eax, eax
    jz .fallback

    lea rcx, [rel module_path_buffer]
    call path_trim_filename

    lea rcx, [rel repo_root_buffer]
    lea rdx, [rel module_path_buffer]
    call pablo_copy_cstring
    lea rcx, [rel repo_root_buffer]
    call path_trim_filename

    lea rcx, [rel path_asm_buffer]
    lea rdx, [rel module_path_buffer]
    call pablo_copy_cstring
    lea rcx, [rel path_asm_buffer]
    lea rdx, [rel suffix_program_asm]
    call path_append_cstr
    lea rax, [rel path_asm_buffer]
    mov qword [rel ctx_global + CTX_output_asm_path], rax

    lea rcx, [rel path_exe_buffer]
    lea rdx, [rel module_path_buffer]
    call pablo_copy_cstring
    lea rcx, [rel path_exe_buffer]
    lea rdx, [rel suffix_program_exe]
    call path_append_cstr
    lea rax, [rel path_exe_buffer]
    mov qword [rel ctx_global + CTX_output_exe_path], rax

    lea rcx, [rel path_runtime_buffer]
    lea rdx, [rel repo_root_buffer]
    call pablo_copy_cstring
    lea rcx, [rel path_runtime_buffer]
    lea rdx, [rel suffix_runtime_asm]
    call path_append_cstr
    lea rax, [rel path_runtime_buffer]
    mov qword [rel ctx_global + CTX_runtime_asm_path], rax

    lea rcx, [rel path_script_buffer]
    lea rdx, [rel repo_root_buffer]
    call pablo_copy_cstring
    lea rcx, [rel path_script_buffer]
    lea rdx, [rel suffix_toolchain_script]
    call path_append_cstr
    lea rax, [rel path_script_buffer]
    mov qword [rel ctx_global + CTX_toolchain_script_path], rax
    jmp .fin

.fallback:
    lea rax, [rel path_asm_default]
    mov qword [rel ctx_global + CTX_output_asm_path], rax
    lea rax, [rel path_exe_default]
    mov qword [rel ctx_global + CTX_output_exe_path], rax
    lea rax, [rel path_runtime_default]
    mov qword [rel ctx_global + CTX_runtime_asm_path], rax
    lea rax, [rel path_script_default]
    mov qword [rel ctx_global + CTX_toolchain_script_path], rax

.fin:
    mov rsp, rbp
    pop rbp
    ret

path_trim_filename:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    xor eax, eax
.seek_end:
    mov dl, [rcx + rax]
    cmp dl, 0
    je .walk_back
    inc eax
    jmp .seek_end
.walk_back:
    test eax, eax
    jz .done
    dec eax
    mov dl, [rcx + rax]
    cmp dl, '\'
    je .cut
    cmp dl, '/'
    je .cut
    jmp .walk_back
.cut:
    mov byte [rcx + rax], 0
.done:
    mov rsp, rbp
    pop rbp
    ret

path_append_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    xor eax, eax
.find_end:
    mov dl, [rcx + rax]
    cmp dl, 0
    je .append
    inc eax
    jmp .find_end
.append:
    add rcx, rax
    call pablo_copy_cstring
    mov rsp, rbp
    pop rbp
    ret

pablo_load_source:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    mov rax, [rcx + CTX_source_path]
    test rax, rax
    jnz .abrir

    lea r9, [rel msg_no_source]
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_CLI_SIN_FUENTE
    call pablo_set_error_simple
    jmp .fin

.abrir:
    mov [rbp - 8], rcx
    lea rdx, [rel modo_rb]
    mov rcx, rax
    call fopen
    mov [rbp - 16], rax
    test rax, rax
    jnz .tamano

    mov rcx, [rbp - 8]
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_IO_NO_PUDO_ABRIR
    lea r9, [rel msg_open_fail]
    call pablo_set_error_simple
    jmp .fin

.tamano:
    mov rcx, [rbp - 16]
    xor edx, edx
    mov r8d, 2
    call fseek
    mov rcx, [rbp - 16]
    call ftell
    mov [rbp - 24], rax
    cmp rax, PABLO_MAX_SOURCE_BYTES
    jbe .leer

    mov rcx, [rbp - 16]
    call fclose
    mov rcx, [rbp - 8]
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_IO_ARCHIVO_MUY_GRANDE
    lea r9, [rel msg_file_big]
    call pablo_set_error_simple
    jmp .fin

.leer:
    mov rcx, [rbp - 16]
    xor edx, edx
    xor r8d, r8d
    call fseek

    lea rcx, [rel source_buffer]
    mov rdx, 1
    mov r8, [rbp - 24]
    mov r9, [rbp - 16]
    call fread
    mov [rbp - 32], rax

    mov rcx, [rbp - 16]
    call fclose

    mov rax, [rbp - 32]
    cmp rax, [rbp - 24]
    je .ok

    mov rcx, [rbp - 8]
    mov edx, PABLO_ETAPA_TOOLCHAIN
    mov r8d, PABLO_IO_LECTURA_INVALIDA
    lea r9, [rel msg_read_fail]
    call pablo_set_error_simple
    jmp .fin

.ok:
    mov rcx, [rbp - 8]
    mov rax, [rbp - 24]
    mov [rcx + CTX_source_length], rax
    mov rdx, [rbp - 24]
    lea rax, [rel source_buffer]
    mov byte [rax + rdx], 0
    xor eax, eax

.fin:
    mov rsp, rbp
    pop rbp
    ret

token_alloc:
    mov eax, [rcx + CTX_token_count]
    cmp eax, [rcx + CTX_token_capacity]
    jb .ok
    xor rax, rax
    mov edx, -1
    ret
.ok:
    mov edx, eax
    imul rax, TOKEN_SIZE
    add rax, [rcx + CTX_tokens_ptr]
    inc dword [rcx + CTX_token_count]
    mov qword [rax + TOKEN_offset], 0
    mov qword [rax + TOKEN_valor], 0
    ret

ast_alloc:
    mov eax, [rcx + CTX_ast_count]
    cmp eax, [rcx + CTX_ast_capacity]
    jb .ok
    xor rax, rax
    mov edx, -1
    ret
.ok:
    mov edx, eax
    imul rax, AST_SIZE
    add rax, [rcx + CTX_ast_ptr]
    inc dword [rcx + CTX_ast_count]
    mov dword [rax + AST_kind], 0
    mov dword [rax + AST_token], -1
    mov dword [rax + AST_tipo], PABLO_TIPO_INVALIDO
    mov dword [rax + AST_aux], 0
    mov dword [rax + AST_a], -1
    mov dword [rax + AST_b], -1
    mov dword [rax + AST_c], -1
    mov dword [rax + AST_next], -1
    mov qword [rax + AST_valor], 0
    ret

function_alloc:
    mov eax, [rcx + CTX_function_count]
    cmp eax, [rcx + CTX_function_capacity]
    jb .ok
    xor rax, rax
    mov edx, -1
    ret
.ok:
    mov edx, eax
    imul rax, FUNC_SIZE
    add rax, [rcx + CTX_functions_ptr]
    inc dword [rcx + CTX_function_count]
    mov dword [rax + FUNC_name_token], -1
    mov dword [rax + FUNC_return_type], PABLO_TIPO_INVALIDO
    mov dword [rax + FUNC_param_count], 0
    mov dword [rax + FUNC_first_param], -1
    mov dword [rax + FUNC_body_node], -1
    mov dword [rax + FUNC_stack_size], 0
    mov dword [rax + FUNC_label_id], 0
    mov dword [rax + FUNC_flags], 0
    ret

local_alloc:
    mov eax, [rcx + CTX_local_count]
    cmp eax, [rcx + CTX_local_capacity]
    jb .ok
    xor rax, rax
    mov edx, -1
    ret
.ok:
    mov edx, eax
    imul rax, LOCAL_SIZE
    add rax, [rcx + CTX_locals_ptr]
    inc dword [rcx + CTX_local_count]
    mov dword [rax + LOCAL_name_token], -1
    mov dword [rax + LOCAL_type], PABLO_TIPO_INVALIDO
    mov dword [rax + LOCAL_depth], 0
    mov dword [rax + LOCAL_slot_offset], 0
    mov dword [rax + LOCAL_is_param], 0
    mov dword [rax + LOCAL_param_ordinal], -1
    mov dword [rax + LOCAL_active], 0
    mov dword [rax + LOCAL_flags], 0
    ret

get_token_ptr:
    imul rdx, TOKEN_SIZE
    mov rax, [rcx + CTX_tokens_ptr]
    add rax, rdx
    ret

get_ast_ptr:
    imul rdx, AST_SIZE
    mov rax, [rcx + CTX_ast_ptr]
    add rax, rdx
    ret

get_function_ptr:
    imul rdx, FUNC_SIZE
    mov rax, [rcx + CTX_functions_ptr]
    add rax, rdx
    ret

get_local_ptr:
    imul rdx, LOCAL_SIZE
    mov rax, [rcx + CTX_locals_ptr]
    add rax, rdx
    ret

pablo_token_text:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    call get_token_ptr
    mov edx, [rax + TOKEN_longitud]
    mov rcx, [rcx + CTX_source_buffer]
    add rcx, [rax + TOKEN_offset]
    mov rax, rcx
    mov rsp, rbp
    pop rbp
    ret

pablo_range_equals_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 24], r8
    xor eax, eax
    xor r9d, r9d
.loop:
    cmp r9d, [rbp - 12]
    jb .check_char
    mov r8, [rbp - 24]
    cmp byte [r8 + r9], 0
    jne .fail
    mov eax, 1
    jmp .fin
.check_char:
    mov rcx, [rbp - 8]
    mov dl, [rcx + r9]
    mov r8, [rbp - 24]
    cmp dl, [r8 + r9]
    jne .fail
    inc r9d
    jmp .loop
.fail:
    xor eax, eax
.fin:
    mov rsp, rbp
    pop rbp
    ret

pablo_token_equals_token:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 16], r8d

    mov edx, [rbp - 12]
    call get_token_ptr
    mov [rbp - 24], rax

    mov rcx, [rbp - 8]
    mov edx, [rbp - 16]
    call get_token_ptr
    mov [rbp - 32], rax

    mov r10, [rbp - 24]
    mov r11, [rbp - 32]
    mov eax, [r10 + TOKEN_longitud]
    cmp eax, [r11 + TOKEN_longitud]
    jne .fail

    mov rcx, [rbp - 8]
    mov rdx, [rcx + CTX_source_buffer]
    add rdx, [r10 + TOKEN_offset]
    mov r8, [rcx + CTX_source_buffer]
    add r8, [r11 + TOKEN_offset]
    mov ecx, [r10 + TOKEN_longitud]
    xor eax, eax
    xor r9d, r9d
.cmp_loop:
    cmp r9d, ecx
    jae .equal
    mov al, [rdx + r9]
    cmp al, [r8 + r9]
    jne .fail
    inc r9d
    jmp .cmp_loop
.equal:
    mov eax, 1
    jmp .fin
.fail:
    xor eax, eax
.fin:
    mov rsp, rbp
    pop rbp
    ret

pablo_map_type_token:
    mov eax, PABLO_TIPO_INVALIDO
    cmp edx, PABLO_TOKEN_TIPO_ENTERO8
    je .entero8
    cmp edx, PABLO_TOKEN_TIPO_ENTERO16
    je .entero16
    cmp edx, PABLO_TOKEN_TIPO_LOGICO
    je .logico
    cmp edx, PABLO_TOKEN_TIPO_ENTERO32
    je .entero32
    cmp edx, PABLO_TOKEN_TIPO_ENTERO64
    je .entero64
    cmp edx, PABLO_TOKEN_TIPO_NATURAL8
    je .nat8
    cmp edx, PABLO_TOKEN_TIPO_NATURAL16
    je .nat16
    cmp edx, PABLO_TOKEN_TIPO_NATURAL32
    je .nat32
    cmp edx, PABLO_TOKEN_TIPO_NATURAL64
    je .nat64
    cmp edx, PABLO_TOKEN_TIPO_VACIO
    je .vacio
    ret
.entero8:
    mov eax, PABLO_TIPO_ENTERO8
    ret
.entero16:
    mov eax, PABLO_TIPO_ENTERO16
    ret
.logico:
    mov eax, PABLO_TIPO_LOGICO
    ret
.entero32:
    mov eax, PABLO_TIPO_ENTERO32
    ret
.entero64:
    mov eax, PABLO_TIPO_ENTERO64
    ret
.nat8:
    mov eax, PABLO_TIPO_NATURAL8
    ret
.nat16:
    mov eax, PABLO_TIPO_NATURAL16
    ret
.nat32:
    mov eax, PABLO_TIPO_NATURAL32
    ret
.nat64:
    mov eax, PABLO_TIPO_NATURAL64
    ret
.vacio:
    mov eax, PABLO_TIPO_VACIO
    ret

pablo_token_type_name:
    mov rax, token_name_desconocido
    cmp edx, PABLO_TOKEN_FIN_ARCHIVO
    je .eof
    cmp edx, PABLO_TOKEN_IDENTIFICADOR
    je .ident
    cmp edx, PABLO_TOKEN_ENTERO
    je .entero
    cmp edx, PABLO_TOKEN_LOGICO
    je .logico
    cmp edx, PABLO_TOKEN_CADENA
    je .cadena
    cmp edx, PABLO_TOKEN_PAR_IZQ
    je .par_izq
    cmp edx, PABLO_TOKEN_PAR_DER
    je .par_der
    cmp edx, PABLO_TOKEN_LLAVE_IZQ
    je .llave_izq
    cmp edx, PABLO_TOKEN_LLAVE_DER
    je .llave_der
    cmp edx, PABLO_TOKEN_COMA
    je .coma
    cmp edx, PABLO_TOKEN_PUNTO_Y_COMA
    je .pyc
    cmp edx, PABLO_TOKEN_DOS_PUNTOS
    je .dp
    cmp edx, PABLO_TOKEN_FLECHA
    je .flecha
    cmp edx, PABLO_TOKEN_ASIGNAR
    je .asignar
    cmp edx, PABLO_TOKEN_SUMA
    je .suma
    cmp edx, PABLO_TOKEN_RESTA
    je .resta
    cmp edx, PABLO_TOKEN_MULTIPLICAR
    je .mul
    cmp edx, PABLO_TOKEN_DIVIDIR
    je .div
    cmp edx, PABLO_TOKEN_MODULO
    je .mod
    cmp edx, PABLO_TOKEN_IGUAL_QUE
    je .igual
    cmp edx, PABLO_TOKEN_DISTINTO_QUE
    je .dist
    cmp edx, PABLO_TOKEN_MENOR_QUE
    je .menor
    cmp edx, PABLO_TOKEN_MENOR_O_IGUAL
    je .menor_igual
    cmp edx, PABLO_TOKEN_MAYOR_QUE
    je .mayor
    cmp edx, PABLO_TOKEN_MAYOR_O_IGUAL
    je .mayor_igual
    cmp edx, PABLO_TOKEN_Y_LOGICO
    je .y_logico
    cmp edx, PABLO_TOKEN_O_LOGICO
    je .o_logico
    cmp edx, PABLO_TOKEN_NEGAR
    je .negar
    cmp edx, PABLO_TOKEN_FUNCION
    je .funcion
    cmp edx, PABLO_TOKEN_DEVOLVER
    je .devolver
    cmp edx, PABLO_TOKEN_SI
    je .si
    cmp edx, PABLO_TOKEN_SI_NO
    je .si_no
    cmp edx, PABLO_TOKEN_MIENTRAS
    je .mientras
    cmp edx, PABLO_TOKEN_PARA
    je .para
    cmp edx, PABLO_TOKEN_CONTINUAR
    je .continuar
    cmp edx, PABLO_TOKEN_ROMPER
    je .romper
    cmp edx, PABLO_TOKEN_SEA
    je .sea
    cmp edx, PABLO_TOKEN_CONSTANTE
    je .constante
    cmp edx, PABLO_TOKEN_EXTERNA
    je .externa
    cmp edx, PABLO_TOKEN_TIPO_VACIO
    je .tipo_vacio
    cmp edx, PABLO_TOKEN_TIPO_LOGICO
    je .tipo_logico
    cmp edx, PABLO_TOKEN_TIPO_ENTERO8
    je .tipo_e8
    cmp edx, PABLO_TOKEN_TIPO_ENTERO16
    je .tipo_e16
    cmp edx, PABLO_TOKEN_TIPO_ENTERO32
    je .tipo_e32
    cmp edx, PABLO_TOKEN_TIPO_ENTERO64
    je .tipo_e64
    cmp edx, PABLO_TOKEN_TIPO_NATURAL8
    je .tipo_n8
    cmp edx, PABLO_TOKEN_TIPO_NATURAL16
    je .tipo_n16
    cmp edx, PABLO_TOKEN_TIPO_NATURAL32
    je .tipo_n32
    cmp edx, PABLO_TOKEN_TIPO_NATURAL64
    je .tipo_n64
    ret
.eof: mov rax, token_name_eof
    ret
.ident: mov rax, token_name_ident
    ret
.entero: mov rax, token_name_entero
    ret
.logico: mov rax, token_name_logico
    ret
.cadena: mov rax, token_name_cadena
    ret
.par_izq: mov rax, token_name_par_izq
    ret
.par_der: mov rax, token_name_par_der
    ret
.llave_izq: mov rax, token_name_llave_izq
    ret
.llave_der: mov rax, token_name_llave_der
    ret
.coma: mov rax, token_name_coma
    ret
.pyc: mov rax, token_name_pyc
    ret
.dp: mov rax, token_name_dos_puntos
    ret
.flecha: mov rax, token_name_flecha
    ret
.asignar: mov rax, token_name_asignar
    ret
.suma: mov rax, token_name_suma
    ret
.resta: mov rax, token_name_resta
    ret
.mul: mov rax, token_name_mul
    ret
.div: mov rax, token_name_div
    ret
.mod: mov rax, token_name_mod
    ret
.igual: mov rax, token_name_igual
    ret
.dist: mov rax, token_name_dist
    ret
.menor: mov rax, token_name_menor
    ret
.menor_igual: mov rax, token_name_menor_igual
    ret
.mayor: mov rax, token_name_mayor
    ret
.mayor_igual: mov rax, token_name_mayor_igual
    ret
.y_logico: mov rax, token_name_y
    ret
.o_logico: mov rax, token_name_o
    ret
.negar: mov rax, token_name_negar
    ret
.funcion: mov rax, token_name_funcion
    ret
.devolver: mov rax, token_name_devolver
    ret
.si: mov rax, token_name_si
    ret
.si_no: mov rax, token_name_si_no
    ret
.mientras: mov rax, token_name_mientras
    ret
.para: mov rax, token_name_para
    ret
.continuar: mov rax, token_name_continuar
    ret
.romper: mov rax, token_name_romper
    ret
.sea: mov rax, token_name_sea
    ret
.constante: mov rax, token_name_constante
    ret
.externa: mov rax, token_name_externa
    ret
.tipo_vacio: mov rax, token_name_tipo_vacio
    ret
.tipo_logico: mov rax, token_name_tipo_logico
    ret
.tipo_e8: mov rax, token_name_tipo_entero8
    ret
.tipo_e16: mov rax, token_name_tipo_entero16
    ret
.tipo_e32: mov rax, token_name_tipo_entero32
    ret
.tipo_e64: mov rax, token_name_tipo_entero64
    ret
.tipo_n8: mov rax, token_name_tipo_nat8
    ret
.tipo_n16: mov rax, token_name_tipo_nat16
    ret
.tipo_n32: mov rax, token_name_tipo_nat32
    ret
.tipo_n64: mov rax, token_name_tipo_nat64
    ret

pablo_ast_kind_name:
    mov rax, ast_name_desconocido
    cmp edx, PABLO_AST_PROGRAMA
    je .programa
    cmp edx, PABLO_AST_DECLARACION_FUNCION
    je .funcion
    cmp edx, PABLO_AST_PARAMETRO
    je .param
    cmp edx, PABLO_AST_BLOQUE
    je .bloque
    cmp edx, PABLO_AST_DECLARACION_VARIABLE
    je .decl_var
    cmp edx, PABLO_AST_DECLARACION_CONSTANTE
    je .decl_const
    cmp edx, PABLO_AST_DECLARACION_EXTERNA
    je .decl_externa
    cmp edx, PABLO_AST_SENTENCIA_SI
    je .si
    cmp edx, PABLO_AST_SENTENCIA_MIENTRAS
    je .mientras
    cmp edx, PABLO_AST_SENTENCIA_PARA
    je .para
    cmp edx, PABLO_AST_SENTENCIA_DEVOLVER
    je .devolver
    cmp edx, PABLO_AST_SENTENCIA_EXPRESION
    je .expr
    cmp edx, PABLO_AST_SENTENCIA_CONTINUAR
    je .continuar
    cmp edx, PABLO_AST_SENTENCIA_ROMPER
    je .romper
    cmp edx, PABLO_AST_LITERAL_ENTERO
    je .lit_ent
    cmp edx, PABLO_AST_LITERAL_LOGICO
    je .lit_log
    cmp edx, PABLO_AST_IDENTIFICADOR
    je .ident
    cmp edx, PABLO_AST_LLAMADA
    je .llamada
    cmp edx, PABLO_AST_UNARIO
    je .unario
    cmp edx, PABLO_AST_BINARIO
    je .binario
    cmp edx, PABLO_AST_ASIGNACION
    je .asign
    ret
.programa: mov rax, ast_name_programa
    ret
.funcion: mov rax, ast_name_funcion
    ret
.param: mov rax, ast_name_param
    ret
.bloque: mov rax, ast_name_bloque
    ret
.decl_var: mov rax, ast_name_decl_var
    ret
.decl_const: mov rax, ast_name_decl_const
    ret
.decl_externa: mov rax, ast_name_decl_externa
    ret
.si: mov rax, ast_name_si
    ret
.mientras: mov rax, ast_name_mientras
    ret
.para: mov rax, ast_name_para
    ret
.devolver: mov rax, ast_name_devolver
    ret
.expr: mov rax, ast_name_expr
    ret
.continuar: mov rax, ast_name_continuar
    ret
.romper: mov rax, ast_name_romper
    ret
.lit_ent: mov rax, ast_name_lit_ent
    ret
.lit_log: mov rax, ast_name_lit_log
    ret
.ident: mov rax, ast_name_ident
    ret
.llamada: mov rax, ast_name_llamada
    ret
.unario: mov rax, ast_name_unario
    ret
.binario: mov rax, ast_name_binario
    ret
.asign: mov rax, ast_name_asign
    ret

pablo_stage_name:
    mov rax, stage_unknown
    cmp edx, PABLO_ETAPA_LEXER
    je .lexer
    cmp edx, PABLO_ETAPA_PARSER
    je .parser
    cmp edx, PABLO_ETAPA_AST
    je .ast
    cmp edx, PABLO_ETAPA_SEMANTIC
    je .semantic
    cmp edx, PABLO_ETAPA_CODEGEN
    je .codegen
    cmp edx, PABLO_ETAPA_TOOLCHAIN
    je .toolchain
    ret
.lexer: mov rax, stage_lexer
    ret
.parser: mov rax, stage_parser
    ret
.ast: mov rax, stage_ast
    ret
.semantic: mov rax, stage_semantic
    ret
.codegen: mov rax, stage_codegen
    ret
.toolchain: mov rax, stage_toolchain
    ret

pablo_set_error_simple:
    mov [rcx + CTX_diag_stage], edx
    mov [rcx + CTX_diag_code], r8d
    mov dword [rcx + CTX_diag_line], 0
    mov dword [rcx + CTX_diag_column], 0
    mov qword [rcx + CTX_diag_offset], 0
    mov [rcx + CTX_diag_message], r9
    mov eax, r8d
    ret

pablo_set_error_token:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx
    mov [rbp - 12], edx
    mov [rbp - 16], r8d
    mov [rbp - 20], r9d
    mov rax, [rbp + 48]
    mov [rbp - 32], rax

    cmp dword [rbp - 20], 0
    jl .fallback
    mov rcx, [rbp - 8]
    mov eax, [rcx + CTX_token_count]
    cmp [rbp - 20], eax
    jae .fallback

    mov edx, [rbp - 20]
    call get_token_ptr
    mov [rbp - 40], rax
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov [rcx + CTX_diag_stage], edx
    mov eax, [rbp - 16]
    mov [rcx + CTX_diag_code], eax
    mov rax, [rbp - 40]
    mov edx, [rax + TOKEN_linea]
    mov [rcx + CTX_diag_line], edx
    mov edx, [rax + TOKEN_columna]
    mov [rcx + CTX_diag_column], edx
    mov rdx, [rax + TOKEN_offset]
    mov [rcx + CTX_diag_offset], rdx
    mov rdx, [rbp - 32]
    mov [rcx + CTX_diag_message], rdx
    mov eax, [rbp - 16]
    jmp .fin

.fallback:
    mov rcx, [rbp - 8]
    mov edx, [rbp - 12]
    mov [rcx + CTX_diag_stage], edx
    mov eax, [rbp - 16]
    mov [rcx + CTX_diag_code], eax
    mov dword [rcx + CTX_diag_line], 0
    mov dword [rcx + CTX_diag_column], 0
    mov qword [rcx + CTX_diag_offset], 0
    mov rdx, [rbp - 32]
    mov [rcx + CTX_diag_message], rdx
    mov eax, [rbp - 16]

.fin:
    mov rsp, rbp
    pop rbp
    ret

pablo_set_error_position:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rcx + CTX_diag_stage], edx
    mov [rcx + CTX_diag_code], r8d
    mov [rcx + CTX_diag_line], r9d
    mov rax, [rbp + 48]
    mov [rcx + CTX_diag_column], eax
    mov rax, [rbp + 56]
    mov [rcx + CTX_diag_offset], rax
    mov rax, [rbp + 64]
    mov [rcx + CTX_diag_message], rax
    mov eax, r8d
    mov rsp, rbp
    pop rbp
    ret

pablo_print_diagnostic:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx
    mov edx, [rcx + CTX_diag_stage]
    call pablo_stage_name
    mov [rbp - 16], rax
    mov rcx, fmt_error
    mov rdx, [rbp - 16]
    mov r10, [rbp - 8]
    mov r8d, [r10 + CTX_diag_code]
    mov r9d, [r10 + CTX_diag_line]
    mov eax, [r10 + CTX_diag_column]
    mov [rsp + 32], eax
    mov rax, [r10 + CTX_diag_message]
    mov [rsp + 40], rax
    call printf
    mov rsp, rbp
    pop rbp
    ret

pablo_print_usage:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    lea rcx, [fmt_usage_1]
    call puts
    lea rcx, [fmt_usage_2]
    call puts
    mov rsp, rbp
    pop rbp
    ret

pablo_copy_cstring:
    xor eax, eax
.copy:
    mov dl, [rdx + rax]
    mov [rcx + rax], dl
    cmp dl, 0
    je .fin
    inc eax
    jmp .copy
.fin:
    mov rax, rcx
    ret

pablo_align16:
    mov eax, ecx
    add eax, 15
    and eax, -16
    ret

section .rdata
msg_no_source db "No se proporciono archivo fuente.", 0
msg_open_fail db "No se pudo abrir el archivo fuente.", 0
msg_file_big db "El archivo fuente supera el limite del hito actual.", 0
msg_read_fail db "No se pudo leer completamente el archivo fuente.", 0
