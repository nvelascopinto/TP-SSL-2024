/* Inicio de la seccion de prólogo (declaraciones y definiciones de C y directivas del preprocesador) */
%{
#include <stdio.h>
#include <math.h>

#include "general.h"

	/* Declaración de la funcion yylex del analizador léxico, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla cada vez que solicite un nuevo token */
extern int yylex(void);
	/* Declaracion de la función yyerror para reportar errores, necesaria para que la función yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char*);

int yywrap(){
        return(1);
}

%}
/* Fin de la sección de prólogo (declaraciones y definiciones de C y directivas del preprocesador) */

/* Inicio de la sección de declaraciones de Bison */

	/* Para requerir una versión mínima de Bison para procesar la gramática */
/* %require "2.4.1" */

	/* Para requirle a Bison que describa más detalladamente los mensajes de error al invocar a yyerror */
%error-verbose
	/* Nota: esta directiva (escrita de esta manera) quedó obsoleta a partir de Bison v3.0, siendo reemplazada por la directiva: %define parse.error verbose */

	/* Para activar el seguimiento de las ubicaciones de los tokens (número de linea, número de columna) */
%locations

	/* Para especificar la colección completa de posibles tipos de datos para los valores semánticos */
%union {
	unsigned long unsigned_long_type;
        *char sval;
}

/* DEFINICION DE LOS TOKENS */

%token OPER_ASIGNACION          // = | += | -= | *= | /=
%token OPER_RELACIONAL          // > | >= | < | <=
%token OPER_UNARIO              // & | * | - | !
%token OPER_IGUALDAD            // == | !=
%token OR                       // ||
%token AND                      // &&
%token MASOMENOS                // ++ | --
%token SALTO_DE_LINEA
%token <sval> IDENTIFICADOR
%token CONSTANTE
%token <sval>LITERAL_CADENA
%token <sval>TIPO_DATO
%token <sval>SIZEOF
%token <sval>NOMBRE_TIPO
%token <sval>IF
%token <sval>ELSE
%token <sval>WHILE
%token <sval>DO
%token <sval>FOR
%token <sval>SWITCH
%token <sval>CASE
%token <sval>DEFAULT
%token <sval>RETURN
%token <sval>CONTINUE
%token <sval>BREAK
%token <sval>GOTO

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
        : SALTO_DE_LINEA
        | expresion ';' | declaracion ';' | sentencia ';' | definicionExterna ';'
        | ';'
        ;

//EXPRESION
expresion
        : expAsignacion
        ;
expAsignacion
        : expCondicional
        | expUnaria OPER_ASIGNACION expAsignacion
        ;
expCondicional
        : expOr
        | expOr '?' expresion ';' expCondicional
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
        : expPostfijo
        | MASOMENOS expUnaria
        | expUnaria MASOMENOS
        | OPER_UNARIO expUnaria
        | SIZEOF '(' nombreTipo ')'
        ;
expPostfijo
        : expPrimaria
        | expPostfijo '[' expresion ']'
        | expPostfijo '(' listaArgumentos ')'
        ;
listaArgumentos
        : expAsignacion
        | listaArgumentos ',' expAsignacion
        ;
expPrimaria
        : IDENTIFICADOR 
        | CONSTANTE 
        | LITERAL_CADENA 
        | '(' expresion ')'
        ;
nombreTipo
        : NOMBRE_TIPO
        ;

//DECLARACION
declaracion
        : declaVarSimples
        | protFuncion
        ;

declaVarSimples
        : TIPO_DATO listaVarSimples ';'
        ;
tipoDato
        : TIPO_DATO
        ;
listaVarSimples
        : unaVarSimple
        | listaVarSimples ',' unaVarSimple
        ;
unaVarSimple
        : IDENTIFICADOR inicializacion
        ;
inicializacion
        : '=' expresion
        ;
protFuncion
        : TIPO_DATO IDENTIFICADOR '(' parametros ')'
        ;
parametros
        : parametro
        | parametro ',' parametros
        |
        ;
parametro
        : TIPO_DATO IDENTIFICADOR
        ;

//SENTENCIA
sentencia
        : sentCompuesta
        | sentExpresion
        | sentSeleccion
        | sentIteracion
        | sentSalto
        | senEtiquetada
        ;
sentCompuesta
        : '{' listaDeclaraciones listaSentencias '}'
        ;
listaDeclaraciones
        : declaracion
        | listaDeclaraciones declaracion
        ;
listaSentencias
        : sentencia
        | listaSentencias sentencia
        ;
sentExpresion
        : expresion ';'
        ;
sentSeleccion
        : IF '(' expresion ')' sentencia 
        | IF '(' expresion ')' sentencia  ELSE sentencia
        | SWITCH '(' expresion ')' sentencia
        ;
sentIteracion
        : WHILE '(' expresion ')' sentencia
        | DO sentencia WHILE '(' expresion ')' ';'
        | FOR '(' expresion ';' expresion ';' expresion ')' sentencia
        ;
sentSalto
        : RETURN expresion ';'
        | CONTINUE ';'
        | BREAK ';'
        | GOTO IDENTIFICADOR ';'
        ;
senEtiquetada
        : CASE expCondicional ':' sentencia
        | DEFAULT ':' sentencia
        | IDENTIFICADOR ':' sentencia
        ;

//DEFINICIONES EXTERNAS
definicionExterna
        : defFuncion
        | declaracion
        ;
defFuncion
        : protFuncion '{' instrucciones '}'
        ;
instrucciones
        : instruccion
        | instruccion instrucciones
        |
        ;
instruccion
        : sentencia
        | expresion
        | declaracion
        | sentSalto
        ;

%%
/* Fin de la sección de reglas gramaticales */

/* Inicio de la sección de epílogo (código de usuario) */

int main(int argc, char *argv[]){
        if (argc != 2){
                printf("Error en cantidad de parámetros para llamada al programa.");
                return EXIT_FAILURE;
        }
        #if YYDEBUG
                yydebug = 1;
        #endif
        inicializarUbicacion(); 
        yyparse ();
        return EXIT_SUCCESS;
}

	/* Definición de la funcion yyerror para reportar errores, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char* literalCadena)
{
        fprintf(stderr, "Bison: %d:%d: %s\n", yylloc.first_line, yylloc.first_column, literalCadena);
}

/* Fin de la sección de epílogo (código de usuario) */