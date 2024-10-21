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

char* tipo_dato;


//Creación de las listas


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
        | expUnaria OPER_ASIGNACION expAsignacion {t_nodo* expresion = crear_nodo(NULL); aniadir_hijo($<nodo>1,expresion);aniadir_hijo_nuevo_nodo("=",expresion);aniadir_hijo($<nodo>3,expresion);$<nodo>$ = expresion;}
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
        : expUnaria
        | expMultiplicativa '*' expUnaria
        | expMultiplicativa '/' expUnaria
        ;
expUnaria
        : expPostfijo {$<nodo>$ = $<nodo>1;}
        | MASOMENOS expUnaria
        | expUnaria MASOMENOS
        | OPER_UNARIO expUnaria
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
        : IDENTIFICADOR {$<nodo>$ = crear_nodo($<id.identificador>1);}
        | CONSTANTE 
        | LITERAL_CADENA 
        | '(' expresion ')'
        ;
nombreTipo
        : NOMBRE_TIPO
        ;

//DECLARACION
declaracion
        : especificadores listaVarSimples ';' {agregar_variables($<sval>1, yylval.id.linea);}
        | especificadores IDENTIFICADOR '(' parametros ')' ';' {agregarFuncion($<id.identificador>2,$<sval>1, $<id.linea>2, 0);lista_parametros = NULL;}
        | error
        ;
especificadores
        : especificadorTipo especificadores {strcat($<sval>1, " ");strcat($<sval>1, $<sval>2);$<sval>$ = $<sval>1;}
        | especificadorTipo {$<sval>$ = $<sval>1;}
        | especificadorAlmacenamiento especificadores {strcat($<sval>1, " ");strcat($<sval>1, $<sval>2);$<sval>$ = $<sval>1;}
        | especificadorAlmacenamiento {$<sval>$ = $<sval>1;}
        | calificadorTipo {$<sval>$ = $<sval>1;}
        | calificadorTipo especificadores {strcat($<sval>1, " ");strcat($<sval>1, $<sval>2);$<sval>$ = $<sval>1;}
        ;
especificadorTipo
        : VOID          //: TIPO_DATO {$<sval>$ = $<sval>1;}
        | CHAR
        | DOUBLE
        | ENUM
        | FLOAT
        | INT
        | STRUCT
        | UNION
        | SIGNED
        | UNSIGNED
        | LONG
        | SHORT
        ;
especificadorAlmacenamiento
        : AUTO //ESPECIFICADOR_ALMACENAMIENTO {if(tipo_dato == NULL){tipo_dato = yylval.sval;}else{strcat(tipo_dato," ");strcat(tipo_dato,yylval.sval);}}
        | EXTERN
        | REGISTER
        | STATIC
        | TYPEDEF
        ;
calificadorTipo
        : CONST //{if(tipo_dato == NULL){tipo_dato = yylval.sval;}else{strcat(tipo_dato," ");strcat(tipo_dato,yylval.sval);}}
        | VOLATILE
        ;
listaVarSimples
        : listaVarSimples ',' unaVarSimple
        | unaVarSimple
        ;
unaVarSimple
        : IDENTIFICADOR inicializacion {agregar_variable_declarada_b($<id.identificador>1, yylval.id.linea);}
        | IDENTIFICADOR {agregar_variable_declarada_b($<id.identificador>1, yylval.id.linea);}
        ;
inicializacion
        : OPER_ASIGNACION expresion
        ;
parametros
        : parametro
        | parametro ',' parametros
        | 
        ;
parametro
        : especificadores IDENTIFICADOR {agregarParametro($<sval>1,$<id.identificador>2);}
        | especificadores {agregarParametro($<sval>1,"0");}
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
                agregarFuncion($<id.identificador>2, $<sval>1, $<id.linea>2, 1);
                lista_parametros = NULL;
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
        #if YYDEBUG
                yydebug = 0;
        #endif
        inicializarUbicacion();
        yyin = fopen(argv[1], "r");
        yyparse();
        imprimir_reporte();
        liberar_memoria(&lista_variables_declaradas,&lista_sentencias,&lista_funciones,&lista_errores_sintacticos,&lista_cadenas_no_reconocidas);
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