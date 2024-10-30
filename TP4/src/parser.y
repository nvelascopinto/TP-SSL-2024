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
        : expCondicional
        | expUnaria OPER_ASIGNACION expAsignacion {$<nodo>$ = crear_nodo(expresion,NULL,NULL); aniadir_hijo($<nodo>1,$<nodo>$); aniadir_hijo_nuevo_nodo("=",$<nodo>$); aniadir_hijo($<nodo>3,$<nodo>$);}
        ;
expCondicional
        : expOr
        | expOr '?' expresion ':' expCondicional
        ;
expOr
        : expAnd
        | expOr OR expAnd
        ;
expAnd
        : expIgualdad
        | expAnd AND expIgualdad
        ;
expIgualdad
        : expRelacional
        | expIgualdad OPER_IGUALDAD expRelacional
        ;
expRelacional 
        : expAditiva
        | expRelacional OPER_RELACIONAL expAditiva
        ;
expAditiva
        : expMultiplicativa
        | expAditiva '+' expMultiplicativa
        | expAditiva '-' expMultiplicativa
        ;
expMultiplicativa
        : expUnaria {$<nodo>$ = $<nodo>1;}
        | expMultiplicativa '*' expUnaria {
                t_especificadores espe1 = *(t_especificadores*)$<nodo>1->data, espe2 = *(t_especificadores*)$<nodo>3->data;
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
        : expPrimaria {$<nodo>$ = $<nodo>1;}
        | expPostfijo '[' expresion ']'
        | expPostfijo '(' listaArgumentos ')'
        ;
listaArgumentos
        : expAsignacion
        | listaArgumentos ',' expAsignacion
        ;
expPrimaria
        : IDENTIFICADOR {symrec* entrada = getsym($<id.identificador>1);
                t_especificadores* aux = malloc(sizeof(t_especificadores));
                *aux = crear_inicializar_especificador();
                aux->especificador_tipo_dato = e_int;
                if(entrada){
                        *aux = entrada->especificadores;
                }else{
                        //error semantico
                }
                $<nodo>$ = crear_nodo(expresion,$<id.identificador>1,aux);} //para las expresiones, estas guardan el tipo de dato de los operandos que las componen
        | CONSTANTE {t_especificadores* aux = malloc(sizeof(t_especificadores));
                *aux = crear_inicializar_especificador();
                aux->especificador_tipo_dato = e_int;
                $<nodo>$ = crear_nodo(expresion,NULL,aux);} //falta cambiar int
        | '-' CONSTANTE {t_especificadores* aux = malloc(sizeof(t_especificadores));
                *aux = crear_inicializar_especificador();
                aux->especificador_tipo_dato = e_int;
                $<nodo>$ = crear_nodo(expresion,NULL,aux);}
        | LITERAL_CADENA {t_especificadores* aux = malloc(sizeof(t_especificadores));
                *aux = crear_inicializar_especificador();
                aux->especificador_tipo_dato = e_cadena;
                $<nodo>$ = crear_nodo(expresion,NULL,aux);}
        | '(' expresion ')' {$<nodo>$ = $<nodo>2;}
        ;
nombreTipo
        : NOMBRE_TIPO
        ;

//DECLARACION
declaracion
        : especificadores listaVarSimples ';' {agregar_variables($<nodo>1);}
        | especificadores IDENTIFICADOR '(' parametros ')' ';' {
                if(!(getsym($<id.identificador>2))){
                        t_especificadores especificadores = crear_inicializar_especificador();
                        conseguir_especificadores($<nodo>1, &especificadores);
                        conseguir_especificadores($<nodo>4, &especificadores);
                        putsym($<id.identificador>2, TYP_FNCT_DECL, especificadores,$<id.linea>2, $<id.columna>2);
                }
                }
        | error
        ;

especificadores                 
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
        : IDENTIFICADOR inicializacion {agregar_variable_declarada_b($<id.identificador>1, $<id.linea>1, $<id.columna>1);}
        | IDENTIFICADOR {agregar_variable_declarada_b($<id.identificador>1, $<id.linea>1, $<id.columna>1);}
        ;
inicializacion
        : OPER_ASIGNACION expresion
        ;
parametros
        : parametro {$<nodo>$ = crear_nodo(parametros,NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);}
        | parametro ',' parametros {$<nodo>$ = crear_nodo(parametros,NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);aniadir_hijo($<nodo>3,$<nodo>$);}
        | 
        ;
parametro
        : especificadores IDENTIFICADOR {$<nodo>$ = crear_nodo(parametro,$<id.identificador>2,NULL);aniadir_hijo($<nodo>1,$<nodo>$);}
        | especificadores {$<nodo>$ = crear_nodo(parametro,NULL,NULL);aniadir_hijo($<nodo>1,$<nodo>$);}
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
        | FOR '(' sentExpresion sentExpresion expresion ')' sentencia {agregar_sentencia("for", $1.linea, $1.columna);} //
        ;
sentSalto
        : RETURN sentExpresion  {agregar_sentencia("return", $1.linea, $1.columna);}
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
        : especificadores IDENTIFICADOR '(' parametros ')' sentCompuesta {
                symrec* entrada = getsym_definicion($<id.identificador>2);
                if(!entrada) {
                        t_especificadores especificadores = crear_inicializar_especificador();
                        conseguir_especificadores($<nodo>1, &especificadores);
                        conseguir_especificadores($<nodo>4, &especificadores);
                        putsym($<id.identificador>2, TYP_FNCT_DEF,especificadores,$<id.linea>2, $<id.columna>2);
                }
        } 
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