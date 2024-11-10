/* Inicio de la seccion de prólogo (declaraciones y definiciones de C y directivas del preprocesador) */
%{
#include <stdio.h>
#include <math.h>
#include "general.h"
#include <string.h>

	/* Declaración de la funcion yylex del analizador léxico, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla cada vez que solicite un nuevo token */
extern int yylex(void);
extern char *yytext;
extern FILE *yyin;
	/* Declaracion de la función yyerror para reportar errores, necesaria para que la función yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char*);

t_especificadores especificadores_aux;
t_especificadores especificadoresAuxFuncion;
%}
/* Fin de la sección de prólogo (declaraciones y definiciones de C y directivas del preprocesador) */

/* Inicio de la sección de declaraciones de Bison */

	/* Para requerir una versión mínima de Bison para procesar la gramática */
/* %require "2.4.1" */

	/* Para requirle a Bison que describa más detalladamente los mensajes de error al invocar a yyerror */
%define parse.error verbose
	/* Nota: esta directiva (escrita de esta manera) quedó obsoleta a partir de Bison v3.0, siendo reemplazada por la directiva: %define parse.error verbose */

	/* Para activar el seguimiento de las ubicaciones de los tokens (número de linea, número de columna) */
%locations

	/* Para especificar la colección completa de posibles tipos de datos para los valores semánticos */
%union {
	unsigned long unsigned_long_type;
        char* sval;
        t_lugar lugar;
        t_identificador id;
        t_nodo* nodo;
}

/* DEFINICION DE LOS TOKENS */

%token OPER_ASIGNACION          // = | += | -= | *= | /=
%token OPER_RELACIONAL          // > | >= | < | <=
%token OPER_UNARIO              // & | * | - | !
%token OPER_IGUALDAD            // == | !=
%token OR                       // ||
%token AND                      // &&
%token MASOMENOS                // ++ | --
%token <id>IDENTIFICADOR
%token CONSTANTE
%token LITERAL_CADENA
//%token <sval>TIPO_DATO ESPECIFICADOR_ALMACENAMIENTO CALIFICADOR_TIPO
%token SIZEOF
%token NOMBRE_TIPO
%token VOID
%token CHAR
%token DOUBLE
%token ENUM
%token FLOAT
%token INT
%token LONG
%token SHORT
%token STRUCT
%token UNION
%token SIGNED
%token UNSIGNED
%token AUTO
%token EXTERN
%token REGISTER
%token STATIC
%token TYPEDEF
%token CONST
%token VOLATILE
%token <lugar>IF
%token <lugar>ELSE
%token <lugar>WHILE
%token <lugar>DO
%token <lugar>FOR
%token <lugar>SWITCH
%token <lugar>CASE
%token <lugar>DEFAULT
%token <lugar>RETURN
%token <lugar>CONTINUE
%token <lugar>BREAK
%token <lugar>GOTO


	/* Para especificar el no-terminal de inicio de la gramática (el axioma). Si esto se omitiera, se asumiría que es el no-terminal de la primera regla */
%start input

/* Fin de la sección de declaraciones de Bison */

/* Inicio de la sección de reglas gramaticales */
%%

input   
        :                       /* vacio */
        | input line
        ;

line    
        : definicionExterna
        ;

//EXPRESION
expresion
        : expAsignacion
        ;
expAsignacion
        : expCondicional {$<nodo>$ = $<nodo>1;}
        | expUnaria OPER_ASIGNACION expAsignacion {$<nodo>$ = crear_nodo(expresion,NULL,NULL); 
                        aniadir_hijo($<nodo>1,$<nodo>$); 
                        aniadir_hijo_nuevo_nodo("=",$<nodo>$); 
                        aniadir_hijo($<nodo>3,$<nodo>$);
                        t_nodo_expresion* aux = (t_nodo_expresion*)$<nodo>1->data;
                        t_especificadores espe1 = aux->especificadores;
                        aux = (t_nodo_expresion*)$<nodo>3->data;
                        t_especificadores espe2 = aux->especificadores;
                        if(espe1.calificador_tipo == e_const){
                                t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                error->codigo_error = SOLO_LECTURA;
                                error->identificador = $<nodo>1->text;
                                error->lineaA = @2.first_line;
                                error->columnaA = @2.first_column-1;
                                aniadir_a_lista(&lista_errores_semanticos, error);
                        }
                        if(espe2.especificador_tipo_dato == e_void){
                                t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                error->codigo_error = NO_IGNORA_VOID;
                                error->identificador = $<nodo>3->text;
                                error->lineaA = @2.first_line;
                                error->columnaA = @2.first_column-1;
                                aniadir_a_lista(&lista_errores_semanticos, error);
                        }
                        aux = (t_nodo_expresion*)$<nodo>1->data;
                        if (aux->EsModificable == 0){ 
                                t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                error->codigo_error = VALORL_NO_MODIFICABLE;
                                error->lineaA = @2.first_line;
                                error->columnaA = @2.first_column-1;
                                aniadir_a_lista(&lista_errores_semanticos, error);
                        } 
                }
        ;
expCondicional
        : expOr {$<nodo>$ = $<nodo>1;}
        | expOr '?' expresion ':' expCondicional
        ;
expOr
        : expAnd {$<nodo>$ = $<nodo>1;}
        | expOr OR expAnd
        ;
expAnd
        : expIgualdad {$<nodo>$ = $<nodo>1;}
        | expAnd AND expIgualdad
        ;
expIgualdad
        : expRelacional {$<nodo>$ = $<nodo>1;}
        | expIgualdad OPER_IGUALDAD expRelacional
        ;
expRelacional 
        : expAditiva {$<nodo>$ = $<nodo>1;}
        | expRelacional OPER_RELACIONAL expAditiva
        ;
expAditiva
        : expMultiplicativa {$<nodo>$ = $<nodo>1;}
        | expAditiva '+' expMultiplicativa
        | expAditiva '-' expMultiplicativa
        ;
expMultiplicativa
        : expUnaria {$<nodo>$ = $<nodo>1;}
        | expMultiplicativa '*' expUnaria {
                $<nodo>$ = $<nodo>1;
                t_nodo_expresion* aux = (t_nodo_expresion*)$<nodo>1->data;
                t_especificadores espe1 = aux->especificadores;
                aux = (t_nodo_expresion*)$<nodo>3->data;
                t_especificadores espe2 = aux->especificadores;
                if(!((espe1.especificador_tipo_dato < 5) && (espe2.especificador_tipo_dato < 5))){
                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                        error->codigo_error = CONTROL_TIPO_DATOS;
                        error->lineaA = $<lugar.linea>2; 
                        error->columnaA = $<lugar.columna>2;
                        error->espeL = espe1;
                        error->espeR = espe2;
                        aniadir_a_lista(&lista_errores_semanticos, error);
                }
        }
        | expMultiplicativa '/' expUnaria
        ;
expUnaria
        : expPostfijo {$<nodo>$ = $<nodo>1;}
        | MASOMENOS expUnaria {$<nodo>$ = $<nodo>2;}
        | expUnaria MASOMENOS {$<nodo>$ = $<nodo>1;}
        | OPER_UNARIO expUnaria {$<nodo>$ = $<nodo>2;}
        | SIZEOF '(' nombreTipo ')'
        ;
expPostfijo
        : IDENTIFICADOR  '(' listaArgumentos ')' aux_expPostfijo {  
                symrec* entrada = getsym($<id.identificador>1);
                t_nodo_expresion* aux = malloc(sizeof(t_nodo_expresion));
                aux->especificadores = crear_inicializar_especificador();
                aux->especificadores.especificador_tipo_dato = e_int;
                aux->EsModificable = 0;
                if(entrada){
                        aux->especificadores = entrada->especificadores;
                        if(entrada->type != TYP_VAR) {
                                int args_esperados = entrada->especificadores.listaParametros.size;
                                int args_recibidos = contar_hijos_postorden($<nodo>3);
                                if(args_recibidos < args_esperados) {
                                        if(entrada->especificadores.especificador_tipo_dato != 5) {
                                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                        error->codigo_error = MENOS_ARGUMENTOS;
                                        error->lineaA = $<id.linea>1; 
                                        error->columnaA = $<id.columna>1;
                                        error->lineaB = entrada->linea;
                                        error->columnaB = entrada->columna;
                                        error->identificador = $<id.identificador>1;
                                        aniadir_a_lista(&lista_errores_semanticos, error);
                                        }
                                } else if (args_recibidos > args_esperados) {
                                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                        error->codigo_error = MAS_ARGUMENTOS;
                                        error->lineaA = $<id.linea>1;
                                        error->columnaA = $<id.columna>1;
                                        error->lineaB = entrada->linea;
                                        error->columnaB = entrada->columna;
                                        error->identificador = $<id.identificador>1;
                                        aniadir_a_lista(&lista_errores_semanticos, error);
                                } /* else {
                                        t_especificadores especificadores = crear_inicializar_especificador();
                                        conseguir_especificadores($<nodo>3, &especificadores);
                                        if(!comparar_especificadores(especificadores, entrada->especificadores)) {
                                                t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                                error->codigo_error = PARAMETROS_INCOMPATIBLES;
                                                error->lineaA = $<id.linea>1;
                                                error->columnaA = $<id.columna>1;
                                                error->espeL = entrada->especificadores; // el tipo de dato que esperaba
                                                error->espeR = especificadores; // el tipo de dato que obtuve
                                                error->lineaB = entrada->linea;
                                                error->columnaB = entrada->columna;
                                                error->identificador = $<id.identificador>1;
                                                aniadir_a_lista(&lista_errores_semanticos, error);
                                        }
                                }  */
                        } else {
                                t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                error->codigo_error = INVOCACION_INVALIDA;
                                error->lineaA = $<id.linea>1;
                                error->columnaA = $<id.columna>1;
                                error->identificador = $<id.identificador>1;
                                error->lineaB = entrada->linea;
                                error->columnaB = entrada->columna;
                                aniadir_a_lista(&lista_errores_semanticos, error);
                        }
                }else{
                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                        error->codigo_error = NO_DECLARACION_FUNCION;
                        error->lineaA = $<id.linea>1; 
                        error->columnaA = $<id.columna>1;
                        error->identificador = $<id.identificador>1;
                        aniadir_a_lista(&lista_errores_semanticos, error);
                }
                $<nodo>$ = crear_nodo(expresion,$<id.identificador>1,aux);}
        | IDENTIFICADOR {
                symrec* entrada = getsym($<id.identificador>1);
                t_nodo_expresion* aux = malloc(sizeof(t_nodo_expresion));
                aux->especificadores = crear_inicializar_especificador();
                aux->especificadores.especificador_tipo_dato = e_int;
                aux->EsModificable = 1;
                if(entrada){
                        aux->especificadores = entrada->especificadores;
                        if(entrada->type != TYP_VAR){
                                aux->especificadores.EsPunteroFuncion = 1;
                        }
                }else{
                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                        error->codigo_error = NO_DECLARACION_EXPRESION;
                        error->lineaA = $<id.linea>1; 
                        error->columnaA = $<id.columna>1;
                        error->identificador = $<id.identificador>1;
                        aniadir_a_lista(&lista_errores_semanticos, error);
                }
                $<nodo>$ = crear_nodo(expresion,$<id.identificador>1,aux);}
        | expPrimaria aux_expPostfijo
        ;

aux_expPostfijo
        :
        | '[' expresion ']' aux_expPostfijo
        | '(' listaArgumentos ')' aux_expPostfijo
        ;

listaArgumentos
        : expAsignacion {$<nodo>$ = crear_nodo(listaArgumentos, NULL, NULL); aniadir_hijo($<nodo>1, $<nodo>$);}
        | listaArgumentos ',' expAsignacion {$<nodo>$ = crear_nodo(listaArgumentos, NULL, NULL); aniadir_hijo($<nodo>1,$<nodo>$); aniadir_hijo($<nodo>3, $<nodo>$);}
        |
        ;
expPrimaria
        : CONSTANTE {t_nodo_expresion* aux = malloc(sizeof(t_nodo_expresion));
                aux->especificadores = crear_inicializar_especificador();
                aux->especificadores.especificador_tipo_dato = e_int;
                aux->EsModificable = 0;
                $<nodo>$ = crear_nodo(expresion,NULL,aux);} //falta cambiar int
        | '-' CONSTANTE {t_nodo_expresion* aux = malloc(sizeof(t_nodo_expresion));
                aux->especificadores = crear_inicializar_especificador();
                aux->especificadores.especificador_tipo_dato = e_int;
                aux->EsModificable = 0;
                $<nodo>$ = crear_nodo(expresion,NULL,aux);}
        | LITERAL_CADENA {
                t_nodo_expresion* aux = malloc(sizeof(t_nodo_expresion));
                aux->especificadores = crear_inicializar_especificador();
                aux->especificadores.especificador_tipo_dato = e_cadena;
                aux->EsModificable = 0;
                $<nodo>$ = crear_nodo(expresion,NULL,aux);
                }
        | '(' expresion ')' {$<nodo>$ = $<nodo>2;}
        ;
nombreTipo
        : NOMBRE_TIPO
        ;

//DECLARACION
declaracion
        : especificadores listaVarSimples ';' {especificadores_aux = crear_inicializar_especificador();}
        | especificadores IDENTIFICADOR '(' parametros ')' ';' {
                symrec* entrada = getsym($<id.identificador>2);
                t_especificadores especificadores = crear_inicializar_especificador();
                conseguir_especificadores($<nodo>1, &especificadores);
                conseguir_especificadores($<nodo>4, &especificadores);
                if(!entrada){
                        putsym($<id.identificador>2, TYP_FNCT_DECL, especificadores,$<id.linea>2, $<id.columna>2);
                } else {
                        if(entrada->type == TYP_VAR){
                                t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                error->codigo_error = REDECLARACION_SIMBOLO_DIFERENTE;
                                error->lineaA = $<id.linea>2; 
                                error->columnaA = $<id.columna>2;
                                error->espeL = entrada->especificadores;
                                error->identificador = entrada->name;
                                error->lineaB = entrada->linea;
                                error->columnaB = entrada->columna;
                                aniadir_a_lista(&lista_errores_semanticos, error);
                        }  else{
                                if(!comparar_especificadores(especificadores, entrada->especificadores)){
                                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                        error->codigo_error = REDECLARACION_TIPO_DIFERENTE;
                                        error->lineaA = $<id.linea>2; 
                                        error->columnaA = $<id.columna>2;
                                        error->espeL = especificadores;
                                        error->espeR = entrada->especificadores;
                                        error->identificador = entrada->name;
                                        error->lineaB = entrada->linea;
                                        error->columnaB = entrada->columna;
                                        aniadir_a_lista(&lista_errores_semanticos, error);  
                                }
                        }
                }
                especificadores_aux = crear_inicializar_especificador();
                }
        | error
        ;

especificadores                 
        : aux_guardar_especificadores {$<nodo>$ = $<nodo>1;conseguir_especificadores($<nodo>1, &especificadores_aux);}
        ;

aux_guardar_especificadores                 
        : especificadorTipo especificadores {$<nodo>$ = crear_nodo(especificadores, NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);aniadir_hijo($<nodo>2,$<nodo>$);}
        | especificadorTipo  {$<nodo>$ = crear_nodo(especificadores, NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);}
        | especificadorAlmacenamiento especificadores {$<nodo>$ = crear_nodo(especificadores, NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);aniadir_hijo($<nodo>2,$<nodo>$);}
        | especificadorAlmacenamiento  {$<nodo>$ = crear_nodo(especificadores, NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);}
        | calificadorTipo  {$<nodo>$ = crear_nodo(especificadores, NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);}
        | calificadorTipo especificadores {$<nodo>$ = crear_nodo(especificadores, NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);aniadir_hijo($<nodo>2,$<nodo>$);}
        ;

especificadorTipo
        : VOID  {int* aux = malloc(sizeof(int)); *aux = e_void;$<nodo>$ = crear_nodo(especificadorTipoDato, NULL,aux);}   
        | CHAR {int* aux = malloc(sizeof(int)); *aux = e_char;$<nodo>$ = crear_nodo(especificadorTipoDato, NULL,aux);}  
        | DOUBLE {int* aux = malloc(sizeof(int)); *aux = e_double;$<nodo>$ = crear_nodo(especificadorTipoDato, NULL,aux);}  
        | ENUM {int* aux = malloc(sizeof(int)); *aux = e_enum;$<nodo>$ = crear_nodo(especificadorTipoDato, NULL,aux);}  
        | FLOAT {int* aux = malloc(sizeof(int)); *aux = e_float;$<nodo>$ = crear_nodo(especificadorTipoDato, NULL,aux);}  
        | INT {int* aux = malloc(sizeof(int)); *aux = e_int;$<nodo>$ = crear_nodo(especificadorTipoDato, NULL,aux);}  
        | STRUCT {int* aux = malloc(sizeof(int)); *aux = e_struct;$<nodo>$ = crear_nodo(especificadorTipoDato, NULL,aux);}  
        | UNION {int* aux = malloc(sizeof(int)); *aux = e_union;$<nodo>$ = crear_nodo(especificadorTipoDato, NULL,aux);}  
        | SIGNED {int* aux = malloc(sizeof(int)); *aux = e_signed;$<nodo>$ = crear_nodo(especificadorTipoSigned, NULL,aux);}
        | UNSIGNED {int* aux = malloc(sizeof(int)); *aux = e_unsigned;$<nodo>$ = crear_nodo(especificadorTipoSigned, NULL,aux);}
        | LONG {int* aux = malloc(sizeof(int)); *aux = e_long;$<nodo>$ = crear_nodo(especificadorTipoLong, NULL,aux);}
        | SHORT {int* aux = malloc(sizeof(int)); *aux = e_short;$<nodo>$ = crear_nodo(especificadorTipoLong, NULL,aux);}
        ;
especificadorAlmacenamiento
        : AUTO 
        | EXTERN
        | REGISTER
        | STATIC
        | TYPEDEF
        ;
calificadorTipo
        : CONST {int* aux = malloc(sizeof(int)); *aux = e_const;$<nodo>$ = crear_nodo(calificadorTipo, NULL,aux);}
        | VOLATILE {int* aux = malloc(sizeof(int)); *aux = e_volatile;$<nodo>$ = crear_nodo(calificadorTipo, NULL,aux);}
        ;
listaVarSimples
        : listaVarSimples ',' unaVarSimple
        | unaVarSimple    
        ;
unaVarSimple
        : IDENTIFICADOR OPER_ASIGNACION expresion {
                        symrec* entrada = getsym($<id.identificador>1);
                        if(!entrada){
                                putsym($<id.identificador>1,TYP_VAR,especificadores_aux,$<id.linea>1, $<id.columna>1);
                        }else{
                                if(entrada->type != TYP_VAR){
                                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                        error->codigo_error = REDECLARACION_SIMBOLO_DIFERENTE;
                                        error->lineaA = $<id.linea>1; 
                                        error->columnaA = $<id.columna>1;
                                        error->espeL = entrada->especificadores;
                                        error->identificador = entrada->name;
                                        error->lineaB = entrada->linea;
                                        error->columnaB = entrada->columna;
                                        aniadir_a_lista(&lista_errores_semanticos, error);
                                }
                        }
                        t_nodo_expresion* aux = (t_nodo_expresion*)$<nodo>3->data;
                        t_especificadores espe2 = aux->especificadores;
                        if(!((especificadores_aux.especificador_tipo_dato < 5) && (espe2.especificador_tipo_dato < 5))){
                                t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                error->codigo_error = INCOMPATIBILIDAD_TIPOS;
                                error->lineaA = @2.first_line;
                                error->columnaA= @2.first_column+1;
                                error->espeL = especificadores_aux;
                                error->espeR = espe2;
                                aniadir_a_lista(&lista_errores_semanticos, error);
                        }
                }
        | IDENTIFICADOR {
                        symrec* entrada = getsym($<id.identificador>1);
                        if(!entrada){
                                putsym($<id.identificador>1,TYP_VAR,especificadores_aux,$<id.linea>1, $<id.columna>1);
                        }
                        else {
                                if(comparar_especificadores(especificadores_aux, entrada->especificadores)){
                                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                        error->codigo_error = REDEFINICION_TIPO_IGUAL_VARIABLE;
                                        error->lineaA = $<id.linea>1;
                                        error->columnaA = $<id.columna>1;
                                        error->identificador = $<id.identificador>1;
                                        error->espeL = entrada->especificadores;
                                        error->lineaB = entrada->linea;
                                        error->columnaB = entrada->columna;
                                        aniadir_a_lista(&lista_errores_semanticos, error);
                                }
                                else{
                                       t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                        error->codigo_error = REDECLARACION_TIPO_DIFERENTE;
                                        error->lineaA = $<id.linea>1;
                                        error->columnaA = $<id.columna>1;
                                        error->identificador = $<id.identificador>1;
                                        error->espeL = especificadores_aux;
                                        error->espeR = entrada->especificadores;
                                        error->lineaB = entrada->linea;
                                        error->columnaB = entrada->columna;
                                        aniadir_a_lista(&lista_errores_semanticos, error);
                                }
                        }
                }
        ;
/* inicializacion
        : OPER_ASIGNACION expresion
        ; */
parametros
        : parametro {$<nodo>$ = crear_nodo(parametros,NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);}
        | parametro ',' parametros {$<nodo>$ = crear_nodo(parametros,NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);aniadir_hijo($<nodo>3,$<nodo>$);}
        | 
        ;
parametro
        : especificadores IDENTIFICADOR {$<nodo>$ = crear_nodo(parametro,$<id.identificador>2,NULL);aniadir_hijo($<nodo>1,$<nodo>$);especificadores_aux = crear_inicializar_especificador();}
        | especificadores {$<nodo>$ = crear_nodo(parametro,NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$); especificadores_aux = crear_inicializar_especificador();}
        ;

//SENTENCIA
sentencia
        : sentCompuesta
        | sentExpresion
        | sentSeleccion
        | sentIteracion
        | sentSalto
        | senEtiquetada
        | error
        ;
sentCompuesta
        : '{' listaDeclaraciones listaSentencias '}'
        ;
listaDeclaraciones
        : declaracion
        | listaDeclaraciones declaracion
        |
        ;
listaSentencias
        : sentencia
        | listaSentencias sentencia
        |
        ;
sentExpresion
        : expresion ';'
        | ';' 
        | expresion error {agregar_error_sintactico($<nodo>1, @1.first_line);}
        ;
sentSeleccion
        : IF '(' expresion ')' sentencia {agregar_sentencia("if", $1.linea, $1.columna);}
        | IF '(' expresion ')' sentencia  ELSE sentencia {agregar_sentencia("if/else", $1.linea, $1.columna);}
        | SWITCH '(' expresion ')' sentencia {agregar_sentencia("switch", $1.linea, $1.columna);}
        ;
sentIteracion
        : WHILE '(' expresion ')' sentencia {agregar_sentencia("while", $1.linea, $1.columna);}
        | DO sentencia WHILE '(' expresion ')' ';' {agregar_sentencia("do/while", $1.linea, $1.columna);}
        | FOR '(' sentExpresion sentExpresion expresion ')' sentencia {agregar_sentencia("for", $1.linea, $1.columna);}
        ;
sentSalto
        : RETURN expresion ';' {
                agregar_sentencia("return", $1.linea, $1.columna);
                t_nodo_expresion* aux = (t_nodo_expresion*)$<nodo>2->data;
                t_especificadores especificadores = aux->especificadores;
                if((especificadores.especificador_tipo_dato != especificadoresAuxFuncion.especificador_tipo_dato) && especificadores.especificador_tipo_dato >= 5) {
                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                        error->codigo_error = RETORNO_INCOMPATIBLE;
                        error->lineaA = @1.first_line;
                        error->columnaA = @1.first_column+1;
                        error->espeL = especificadores;
                        error->espeR = especificadoresAuxFuncion;
                        aniadir_a_lista(&lista_errores_semanticos, error); 
                }

        } // tipos distintos con especificadoresFuncionAux
        | RETURN ';'{
                agregar_sentencia("return", $1.linea, $1.columna);
                if(especificadoresAuxFuncion.especificador_tipo_dato != e_void){
                        t_error_semantico* error = malloc(sizeof(t_error_semantico));
                        error->codigo_error = NO_RETORNA;
                        error->lineaA = @1.first_line; 
                        error->columnaA = @1.first_column;
                        aniadir_a_lista(&lista_errores_semanticos, error);
                }            
        } //error si no se esperaba void 
        | CONTINUE ';' {agregar_sentencia("continue", $1.linea, $1.columna);}
        | BREAK ';' {agregar_sentencia("break", $1.linea, $1.columna);}
        | GOTO IDENTIFICADOR ';' {agregar_sentencia("goto", $1.linea, $1.columna);}
        ;
senEtiquetada
        : CASE expCondicional ':' sentencia {agregar_sentencia("case", $1.linea, $1.columna);}
        | DEFAULT ':' sentencia {agregar_sentencia("default", $1.linea, $1.columna);}
        | IDENTIFICADOR ':' sentencia
        ;

//DEFINICIONES EXTERNAS
definicionExterna
        : defFuncion
        | declaracion
        ;
defFuncion
        : especificadores IDENTIFICADOR '(' parametros ')' {
                symrec* entrada = getsym_definicion($<id.identificador>2);
                t_especificadores especificadores = crear_inicializar_especificador();
                if(!entrada) {
                        //t_especificadores especificadores = crear_inicializar_especificador();
                        conseguir_especificadores($<nodo>1, &especificadores);
                        conseguir_especificadores($<nodo>4, &especificadores);
                        putsym($<id.identificador>2, TYP_FNCT_DEF,especificadores,$<id.linea>2, $<id.columna>2);
                }else if (comparar_especificadores(entrada->especificadores,especificadores)!=0){
                                t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                error->codigo_error = REDECLARACION_TIPO_DIFERENTE;
                                error->lineaA = $<id.linea>2; 
                                error->columnaA = $<id.columna>2;
                                error->espeL = especificadores;
                                error->espeR = entrada->especificadores;
                                error->identificador = entrada->name;
                                error->lineaB = entrada->linea;
                                error->columnaB = entrada->columna;
                                aniadir_a_lista(&lista_errores_semanticos, error);  
                        }
                        else{
                                t_error_semantico* error = malloc(sizeof(t_error_semantico));
                                error->codigo_error = REDEFINICION_TIPO_IGUAL_FUNCION;
                                error->lineaA = $<id.linea>2;
                                error->columnaA = $<id.columna>2;
                                error->identificador = $<id.identificador>2;
                                error->espeL = entrada->especificadores;
                                error->lineaB = entrada->linea;
                                error->columnaB = entrada->columna;
                                aniadir_a_lista(&lista_errores_semanticos, error);
                        }
                //especificadoresAuxFuncion = especificadores_aux;
                conseguir_especificadores($<nodo>1, &especificadoresAuxFuncion);
                especificadores_aux = crear_inicializar_especificador();
        }  sentCompuesta {especificadoresAuxFuncion = crear_inicializar_especificador();}
        ;

%%
/* Fin de la sección de reglas gramaticales */

/* Inicio de la sección de epílogo (código de usuario) */

int main(int argc, char *argv[]){
        if (argc != 2){
                printf("Error en cantidad de parámetros para llamada al programa.\n");
                return 1;
        }
        lista_errores_semanticos.lista = NULL;
        #if YYDEBUG
                yydebug = 0;
        #endif
        inicializarUbicacion();
        especificadores_aux = crear_inicializar_especificador();
        especificadoresAuxFuncion = crear_inicializar_especificador();
        yyin = fopen(argv[1], "r");
        yyparse();
        imprimir_reporte();
        liberar_memoria(&lista_variables_declaradas,&lista_sentencias,&lista_errores_sintacticos,&lista_cadenas_no_reconocidas);
        return 0;
} 

	/* Definición de la funcion yyerror para reportar errores, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla para reportar un error */
 void yyerror(const char* literalCadena)
{ 
        //agregar_error_sintactico(literalCadena, yylloc.first_line);
        if (DEBUG){
                fprintf(stderr, "Bison: %d:%d: %s\n", yylloc.first_line, yylloc.first_column, literalCadena);
        }
        //yyerrok;
}

void inicializarUbicacion()
{
    yylloc.first_line = INICIO_CONTEO_LINEA;
    yylloc.last_line = INICIO_CONTEO_LINEA;
    yylloc.first_column = INICIO_CONTEO_COLUMNA;
    yylloc.last_column = INICIO_CONTEO_COLUMNA;
}

/* Fin de la sección de epílogo (código de usuario) */