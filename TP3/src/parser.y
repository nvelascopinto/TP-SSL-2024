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
        int parametro;
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
        | protFuncion   {;}
        ;
declaVarSimples
        : TIPO_DATO listaVarSimples ';' 
        ;
listaVarSimples
        : unaVarSimple
        | listaVarSimples ',' unaVarSimple
        ;
unaVarSimple
        : IDENTIFICADOR inicializacion  {agregar_variable_declarada(&lista_variables_declaradas,strdup($1),strdup(yytext),yylloc.first_line);}
        ;
inicializacion
        : '=' expresion
        ;
protFuncion
        : TIPO_DATO IDENTIFICADOR '(' parametros ')' /* {
                Parametro *parametros = malloc(sizeof(Parametro) * $3.numParam);
                for (int i = 0; i < $3.numParam; i++) {
                        parametros[i] = $3.parametros[i];
                }
                agregarFuncion($2, $1, parametros, $3.numParam, yylloc.first_line, 0);
        } */
        ;
parametros
        : parametro
        | parametro ',' parametros
        |
        ;
parametro
        : TIPO_DATO IDENTIFICADOR //{agregarParametro(&lista_parametros,strdup($1),strdup($2));}
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
        | IF '(' expresion ')' sentencia  ELSE sentencia {agregar_sentencia(&lista_sentencias, strdup($1)+'/'+strdup($6), yylloc.first_line, yylloc.first_column);}
        | SWITCH '(' expresion ')' sentencia {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column)}
        ;
sentIteracion
        : WHILE '(' expresion ')' sentencia {agregar_sentencia(&lista_sentencias, strdup($1), yylloc.first_line, yylloc.first_column);}
        | DO sentencia WHILE '(' expresion ')' ';' {agregar_sentencia(&lista_sentencias, strdup($1)+'/'+strdup($3), yylloc.first_line, yylloc.first_column);}
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
        : protFuncion '{' instrucciones '}' /* {
            Parametro *parametros = malloc(sizeof(Parametro) * $3.numParam);
            for (int i = 0; i < $3.numParam; i++) {
                parametros[i] = $3.parametros[i]; // Supón que $3 contiene los parámetros
            }
            agregarFuncion($2, $1, parametros, $3.numParam, yylloc.first_line, 1); // 1 para definición
        } */
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

        //Declaración de listas
        VariableDeclarada *lista_variables_declaradas = NULL;
        Funciones *lista_funciones = NULL;
        Sentencia *lista_sentencias = NULL;
        Syntax_Error *lista_errores_sintacticos = NULL;
        CadenaNoReconocida *lista_cadenas_no_reconocidas = NULL;
        Symbol *tablaSimbolos = NULL;

        if (argc != 2){
                printf("Error en cantidad de parámetros para llamada al programa.");
                return EXIT_FAILURE;
        }
        #if YYDEBUG
                yydebug = 1;
        #endif

        inicializarUbicacion();
        yyparse();
        imprimir_reporte(lista_variables_declaradas,lista_funciones,lista_sentencias,lista_errores_sintacticos,lista_cadenas_no_reconocidas);
        liberar_memoria(&lista_variables_declaradas,&lista_funciones,&lista_sentencias,&lista_errores_sintacticos,&lista_cadenas_no_reconocidas);

        return EXIT_SUCCESS;
}

	/* Definición de la funcion yyerror para reportar errores, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char* literalCadena)
{
        agregar_error_sintactico(&lista_errores_sintacticos,literalCadena,yylloc.first_line);
        fprintf(stderr, "Bison: %d:%d: %s\n", yylloc.first_line, yylloc.first_column, literalCadena);
}

/* Fin de la sección de epílogo (código de usuario) */