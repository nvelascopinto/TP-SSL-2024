/* Inicio de la seccion de prólogo (declaraciones y definiciones de C y directivas del preprocesador) */
%{
#include <stdio.h>
#include <math.h>

#include "general.h"

	/* Declaración de la funcion yylex del analizador léxico, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla cada vez que solicite un nuevo token */
extern int yylex(void);
	/* Declaracion de la función yyerror para reportar errores, necesaria para que la función yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char*);
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
}

        /* */
%token OPERASIGNACION // = | += | -= | *= | /=
%token OPERRELACIONAL // > | >= | < | <=
%token OPERUNARIO // & | * | - | !
%token OPERIGUAL // == | !=
%token OR // ||
%token AND // &&
%token MASOMENOS // ++ | --
%token IDENTIFICADOR
%token CONSTANTE
%token LITERALCADENA
	/* */

	/* Para especificar el no-terminal de inicio de la gramática (el axioma). Si esto se omitiera, se asumiría que es el no-terminal de la primera regla */
%start input

/* Fin de la sección de declaraciones de Bison */

/* Inicio de la sección de reglas gramaticales */
%%

input:    /* vacio */
        | input line
;

line:     '\n'
        | expresion ';'| declaracion ';' | sentencia ';' | definicionExterna ';'
        | ';'
;

expresion
        : expAsignacion
        ;
expAsignacion
        : expCondicional
        | expUnaria OPERASIGNACION expAsignacion
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
        | expIgualdad OPERIGUAL expRelacional
        ;
expRelacional 
        : expAditiva
        | expRelacional OPERRELACIONAL expAditiva
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
        | OPERUNARIO expUnaria
//        | SIZEOF '(' nombreTipo ')'
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
expPrimaria: IDENTIFICADOR | CONSTANTE | LITERALCADENA | '(' expresion ')';
//nombreTipo: CHAR | INT | DOUBLE;

declaracion:;

sentencia:;

definicionExterna:;


%%
/* Fin de la sección de reglas gramaticales */

/* Inicio de la sección de epílogo (código de usuario) */

int main(void)
{
        inicializarUbicacion();

        return 0;
}

	/* Definición de la funcion yyerror para reportar errores, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char* literalCadena)
{
        fprintf(stderr, "Bison: %d:%d: %s\n", yylloc.first_line, yylloc.first_column, literalCadena);
}

/* Fin de la sección de epílogo (código de usuario) */