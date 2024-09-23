/* Inicio de la seccion de prólogo (declaraciones y definiciones de C y directivas del preprocesador) */
%{
#include <stdio.h>
#include <math.h>
#include "general.h"

	/* Declaración de la funcion yylex del analizador léxico, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla cada vez que solicite un nuevo token */
extern int yylex(void);
extern char *yytext;
extern FILE *yyin;
	/* Declaracion de la función yyerror para reportar errores, necesaria para que la función yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char*);

VariableDeclarada *lista_variables_declaradas = NULL;
Funcion *lista_funciones = NULL;
Parametro *lista_parametros = NULL;
Sentencia *lista_sentencias = NULL;
Syntax_Error *lista_errores_sintacticos = NULL;
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
        t_lugar lugar;
        char tipo_dato[30];
        char identificador[30];
        int linea;
}

/* DEFINICION DE LOS TOKENS */

%token <sval>OPER_ASIGNACION          // = | += | -= | *= | /=
%token <sval>OPER_RELACIONAL          // > | >= | < | <=
%token <sval>OPER_UNARIO              // & | * | - | !
%token <sval>OPER_IGUALDAD            // == | !=
%token <sval>OR                       // ||
%token <sval>AND                      // &&
%token <sval>MASOMENOS                // ++ | --
%token <identificador>IDENTIFICADOR
%token <sval>CONSTANTE
%token <sval>LITERAL_CADENA
%token <tipo_dato>TIPO_DATO
%token <sval>SIZEOF
%token <sval>NOMBRE_TIPO
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
        : '\n'
        | expresion
        | declaracion 
        | sentencia 
        | definicionExterna
        | ';'
        | error '\n' {agregar_error_sintactico(&lista_errores_sintacticos,yytext,yylloc.first_line);yyerrok;}
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
        | protFuncion ';'
        ;
declaVarSimples
        : TIPO_DATO listaVarSimples 
        ;
listaVarSimples
        : listaVarSimples ',' unaVarSimple
        | unaVarSimple {printf("%s\n\n\n",yylval.identificador);printf("%s\n\n\n",yylval.tipo_dato);}//agregar_variable_declarada(&lista_variables_declaradas, yylval.identificador, yylval.tipo_dato, yylval.linea);}
        ;
unaVarSimple
        : IDENTIFICADOR inicializacion 
        | IDENTIFICADOR
        ;
inicializacion
        : OPER_ASIGNACION expresion
        ;
protFuncion
        : TIPO_DATO IDENTIFICADOR '(' parametros ')'  {
                /* agregarFuncion(&lista_funciones, strdup($2), strdup($1), lista_parametros, yylloc.first_line, 0);
                liberar_memoria_parametros(&lista_parametros); */
        }
        ;
parametros
        : parametro
        | parametro ',' parametros
        | 
        ;
parametro
        : TIPO_DATO IDENTIFICADOR //{agregarParametro(&lista_parametros,strdup($1),strdup($2));}
        | TIPO_DATO
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
        ;
sentSeleccion
        : IF '(' expresion ')' sentencia {agregar_sentencia(&lista_sentencias, "if", $1.linea, $1.columna);}
        | IF '(' expresion ')' sentencia  ELSE sentencia {agregar_sentencia(&lista_sentencias, "if/else", $1.linea, $1.columna);}
        | SWITCH '(' expresion ')' sentencia {agregar_sentencia(&lista_sentencias, "switch", $1.linea, $1.columna);}
        ;
sentIteracion
        : WHILE '(' expresion ')' sentencia {agregar_sentencia(&lista_sentencias, "while", $1.linea, $1.columna);}
        | DO sentencia WHILE '(' expresion ')' ';' {agregar_sentencia(&lista_sentencias, "do/while", $1.linea, $1.columna);}
        | FOR '(' sentExpresion sentExpresion expresion ')' sentencia {agregar_sentencia(&lista_sentencias, "for", $1.linea, $1.columna);} //
        ;
sentSalto
        : RETURN sentExpresion  {agregar_sentencia(&lista_sentencias, "return", $1.linea, $1.columna);}
        | CONTINUE ';' {agregar_sentencia(&lista_sentencias, "continue", $1.linea, $1.columna);}
        | BREAK ';' {agregar_sentencia(&lista_sentencias, "break", $1.linea, $1.columna);}
        | GOTO IDENTIFICADOR ';' {agregar_sentencia(&lista_sentencias, "goto", $1.linea, $1.columna);}
        ;
senEtiquetada
        : CASE expCondicional ':' sentencia {agregar_sentencia(&lista_sentencias, "case", $1.linea, $1.columna);}
        | DEFAULT ':' sentencia {agregar_sentencia(&lista_sentencias, "default", $1.linea, $1.columna);}
        | IDENTIFICADOR ':' sentencia
        ;

//DEFINICIONES EXTERNAS
definicionExterna
        : defFuncion
        | declaracion
        ;
defFuncion
        : TIPO_DATO IDENTIFICADOR '(' parametros ')' '{' instrucciones '}' {printf("Definicion de funcion \n\n\n\n");} /* {
                agregarFuncion(&lista_funciones, strdup($2), strdup($1), lista_parametros, yylloc.first_line, 1);
                liberar_memoria_parametros(&lista_parametros);
        }  */
        ;
instrucciones
        : instruccion
        | instrucciones instruccion
        |
        ;
instruccion
        : sentencia 
        | expresion
        | declaracion 
        | RETURN sentExpresion  
        | RETURN sentExpresion  
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