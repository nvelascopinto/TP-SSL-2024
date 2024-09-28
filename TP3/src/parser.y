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
%token <sval>TIPO_DATO ESPECIFICADOR_ALMACENAMIENTO CALIFICADOR_TIPO
%token SIZEOF
%token NOMBRE_TIPO
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
        : sentencia 
        | definicionExterna
        | error '\n' 
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
        : especificadores listaVarSimples ';' {tipo_dato = NULL;}
        ;
especificadores
        : especificadorTipo especificadores
        | especificadorTipo
        | especificadorAlmacenamiento especificadores
        | especificadorAlmacenamiento
        | calificadorTipo
        | calificadorTipo especificadores
        ;
especificadorTipo
        : TIPO_DATO {if(tipo_dato == NULL){tipo_dato = yylval.sval;}else{strcat(tipo_dato," ");strcat(tipo_dato,yylval.sval);}} //cambiar strcat
        ;
especificadorAlmacenamiento
        : ESPECIFICADOR_ALMACENAMIENTO {if(tipo_dato == NULL){tipo_dato = yylval.sval;}else{strcat(tipo_dato," ");strcat(tipo_dato,yylval.sval);}} 
        ;
calificadorTipo
        : CALIFICADOR_TIPO {if(tipo_dato == NULL){tipo_dato = yylval.sval;}else{strcat(tipo_dato," ");strcat(tipo_dato,yylval.sval);}}
        ;
listaVarSimples
        : listaVarSimples ',' unaVarSimple
        | unaVarSimple 
        ;
unaVarSimple
        : IDENTIFICADOR inicializacion {agregar_variable_declarada($<id.identificador>1, tipo_dato, yylval.id.linea);}
        | IDENTIFICADOR {agregar_variable_declarada($<id.identificador>1, tipo_dato, yylval.id.linea);}
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
        : TIPO_DATO IDENTIFICADOR //{agregarParametro(yylval.variable.tipo_dato,yylval.variable.identificador);}
        | TIPO_DATO //{agregarParametro(yylval.variable.tipo_dato,yylval.variable.identificador);}
        ;

//SENTENCIA
sentencia
        : sentCompuesta
        | sentExpresion
        | sentSeleccion
        | sentIteracion
        | sentSalto
        | senEtiquetada
        | error '\n' 
        |'\n'
        ;
sentCompuesta
        : '{' listaDeclaraciones listaSentencias '}'
        ;
listaDeclaraciones
        : declaracion
        | listaDeclaraciones declaracion
        | '\n'
        |
        ;
listaSentencias
        : sentencia
        | listaSentencias sentencia
        | '\n'
        |
        ;
sentExpresion
        : expresion ';'
        | ';'
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
//hay que cambiar prototipo de funcion, tendria que estar en declaracion
definicionExterna
        : defFuncion
        | declaracion
        | protFuncion
        ;
protFuncion
        : TIPO_DATO IDENTIFICADOR '(' parametros ')'  {
                //agregarFuncion(yylval.variable.identificador, yylval.variable.tipo_dato, lista_parametros, yylloc.first_line, 0);
                //liberar_memoria_parametros(&lista_parametros);
        }
        ;
defFuncion
        : TIPO_DATO IDENTIFICADOR '(' parametros ')' sentCompuesta {
                //agregarFuncion(yylval.variable.identificador, yylval.variable.tipo_dato, lista_parametros, yylloc.first_line, 1);
                //liberar_memoria_parametros(&lista_parametros);
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
        imprimir_reporte(lista_variables_declaradas,lista_funciones,lista_sentencias,lista_errores_sintacticos,lista_cadenas_no_reconocidas);
        liberar_memoria(&lista_variables_declaradas,&lista_sentencias,&lista_funciones,&lista_errores_sintacticos,&lista_cadenas_no_reconocidas);
        return 0;
} 

	/* Definición de la funcion yyerror para reportar errores, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char* literalCadena)
{
        agregar_error_sintactico(literalCadena, yylloc.first_line);
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