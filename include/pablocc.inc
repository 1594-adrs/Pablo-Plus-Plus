%ifndef PABLOCC_INC
%define PABLOCC_INC

; Codigos de salida del compilador
%define PABLO_ERR_EXITO 0
%define PABLO_ERR_USO 1
%define PABLO_ERR_NO_IMPLEMENTADO 2
%define PABLO_ERR_INTERNO 3

; Version inicial de arquitectura
%define PABLOCC_VERSION_MAYOR 0
%define PABLOCC_VERSION_MENOR 1
%define PABLOCC_VERSION_PARCHE 0

; Tipos primitivos de la V1
%define PABLO_TIPO_VACIO 0
%define PABLO_TIPO_LOGICO 1
%define PABLO_TIPO_ENTERO8 2
%define PABLO_TIPO_ENTERO16 3
%define PABLO_TIPO_ENTERO32 4
%define PABLO_TIPO_ENTERO64 5
%define PABLO_TIPO_NATURAL8 6
%define PABLO_TIPO_NATURAL16 7
%define PABLO_TIPO_NATURAL32 8
%define PABLO_TIPO_NATURAL64 9

; Identificadores de etapas del pipeline
%define PABLO_ETAPA_LEXER 0
%define PABLO_ETAPA_PARSER 1
%define PABLO_ETAPA_AST 2
%define PABLO_ETAPA_SEMANTIC 3
%define PABLO_ETAPA_CODEGEN 4
%define PABLO_ETAPA_TOOLCHAIN 5

; Entry point canonico del lenguaje
%define PABLO_ENTRY_HISTORIA_PRINCIPAL "historiaPrincipal"

%endif
