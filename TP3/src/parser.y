/* Inicio de la seccion de prólogo (declaraciones y definiciones de C y directivas del preprocesador) */
%{
#include <stdio.h>
#include <math.h>
#include "general.h"

	/* Declaración de la funcion yylex del analizador léxico, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla cada vez que solicite un nuevo token */
extern int yylex(void);

extern FILE *yyin;
	/* Declaracion de la función yyerror para reportar errores, necesaria para que la función yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char*);

extern VariableDeclarada *lista_variables_declaradas;
extern Funcion *lista_funciones;
extern Parametro *lista_parametros;
extern Sentencia *lista_sentencias;
extern Syntax_Error *lista_errores_sintacticos;
extern CadenaNoReconocida *lista_cadenas_no_reconocidas;

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
}

/* DEFINICION DE LOS TOKENS */

%token <sval>OPER_ASIGNACION          // = | += | -= | *= | /=
%token <sval>OPER_RELACIONAL          // > | >= | < | <=
%token <sval>OPER_UNARIO              // & | * | - | !
%token <sval>OPER_IGUALDAD            // == | !=
%token <sval>OR                       // ||
%token <sval>AND                      // &&
%token <sval>MASOMENOS                // ++ | --
%token <sval>IDENTIFICADOR
%token <sval>CONSTANTE
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
        : '\n'
        | expresion ';' 
        | declaracion ';' 
        | sentencia ';' 
        | definicionExterna ';'
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
        : TIPO_DATO unaVarSimple ';' {agregar_variable_declarada(&lista_variables_declaradas,strdup($<sval>2),strdup($1),yylloc.first_line);}
        ;
unaVarSimple
        : IDENTIFICADOR inicializacion  
        ;
inicializacion
        : '=' expresion
        ;
protFuncion
        : TIPO_DATO IDENTIFICADOR '(' parametros ')'  {
                agregarFuncion(&lista_funciones, strdup($2), strdup($1), lista_parametros, yylloc.first_line, 0);
                liberar_memoria_parametros(&lista_parametros);
        }
        ;
parametros
        : parametro
        | parametro ',' parametros
        |
        ;
parametro
        : TIPO_DATO IDENTIFICADOR {agregarParametro(&lista_parametros,strdup($1),strdup($2));}
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
        : IF '(' expresion ')' sentencia {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        | IF '(' expresion ')' sentencia  ELSE sentencia {agregar_sentencia(&lista_sentencias, "if/else", yylloc.first_line, yylloc.first_column);}
        | SWITCH '(' expresion ')' sentencia {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        ;
sentIteracion
        : WHILE '(' expresion ')' sentencia {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        | DO sentencia WHILE '(' expresion ')' ';' {agregar_sentencia(&lista_sentencias, "do/while", yylloc.first_line, yylloc.first_column);}
        | FOR '(' expresion ';' expresion ';' expresion ')' sentencia {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        ;
sentSalto
        : RETURN expresion ';' {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        | CONTINUE ';' {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        | BREAK ';' {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        | GOTO IDENTIFICADOR ';' {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        ;
senEtiquetada
        : CASE expCondicional ':' sentencia {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        | DEFAULT ':' sentencia {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        | IDENTIFICADOR ':' sentencia
        ;

//DEFINICIONES EXTERNAS
definicionExterna
        : defFuncion
        | declaracion
        ;
defFuncion
        : TIPO_DATO IDENTIFICADOR '(' parametros ')' '{' instrucciones '}' {
                agregarFuncion(&lista_funciones, strdup($2), strdup($1), lista_parametros, yylloc.first_line, 1);
                liberar_memoria_parametros(&lista_parametros);
        } 
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
        | RETURN expresion ';'        
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
                yydebug = 1;
        #endif
        inicializarUbicacion();
        yyin = fopen(argv[1], "r");
        yyparse();
        imprimir_reporte(lista_variables_declaradas,lista_funciones,lista_sentencias,lista_errores_sintacticos,lista_cadenas_no_reconocidas);
        liberar_memoria(&lista_variables_declaradas,&lista_sentencias,&lista_funciones,&lista_errores_sintacticos,&lista_cadenas_no_reconocidas);
        return 0;
} 

	/* Definición de la funcion yyerror para reportar errores, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char* literalCadena)
{
        agregar_error_sintactico(&lista_errores_sintacticos,literalCadena,yylloc.first_line);
        if (DEBUG){
                fprintf(stderr, "Bison: %d:%d: %s\n", yylloc.first_line, yylloc.first_column, literalCadena);
        }
}

void inicializarUbicacion()
{
    yylloc.first_line = INICIO_CONTEO_LINEA;
    yylloc.last_line = INICIO_CONTEO_LINEA;
    yylloc.first_column = INICIO_CONTEO_COLUMNA;
    yylloc.last_column = INICIO_CONTEO_COLUMNA;
}

/* Fin de la sección de epílogo (código de usuario) */