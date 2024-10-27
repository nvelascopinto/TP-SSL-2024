
/* Inicio de la sección de definiciones. Aquí: */
    /* 1. Cualquier texto sangrado o encerrado entre '%{' y '%}' (estos últimos dos sin sangrar en líneas ocupadas únicamente por ellos) se copia íntegramente al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */
        /* De esas formas podemos poner declaraciones y definiciones de C y directivas del preprocesador */
    /* 2. Los comentarios (sólo hay de múltiples líneas) sin sangría también se copian tal cual al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */

%{

#include "general.h"

/* Es indispensable que incluyamos el archivo de cabecera con las definiciones de YACC (*.tab.h) que se genera a partir del archivo fuente de YACC (*.y) */
#include "parser.tab.h"
#define DEBUG 0
CadenaNoReconocida *lista_cadenas_no_reconocidas = NULL;


%}

DIGITO_DECIMAL [0-9]
DIGITO_NO_CERO [1-9]
DIGITO_OCTAL [0-7]
DIGITO_HEXADECIMAL [0-9a-fA-F]
DIGITO_UNSIGNED [uU]
DIGITO_LONG [lL]
DIGITO_EXPONENTE [eE]
DIGITO_SIGNO_EXPONENTE [+-]
DIGITO_FLOAT [fFlL]
CARACTER_SIMPLE [a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?`~]
CARACTER_CON_NEGACION [^"\\\n]
SECUENCIA_DE_ESCAPE [abfnrtv\\'\"?]
SIMBOLOS_DE_AGRUPACION [()\{}\[\];,.:]
OPERADORES_ARITMETICOS [\+\-\*/%]
OPERADORES_DE_ASIGNACION "="|"+="|"-="|"*="|"/="
OPERADORES_DE_COMPARACION "=="|"!="|">="|"<="|">"|"<"
OPERADORES_IGUAL "=="|"!="
OPERADORES_RELACIONAL ">="|"<="|">"|"<"
OPERADORES_LOGICOS "&&"|"||"|"!""
OPERADORES_BIT_A_BIT [\&|\||\^|\~|\<\<|\>\>]
IDENTIFICADOR [a-zA-Z_][a-zA-Z0-9_]*

    /* La siguiente línea define explícitamente a yytext como un puntero a un caracter ( char* yytext; ). Ésta es la opción por defecto si no se pone nada. */
%pointer
    /* Con la siguiente opción la función de análisis int yylex(void); se comporta como si en la sección de usuario existiera la función int yywrap(void) return 1; la cual devuelve verdadero (no-cero), haciendo que una vez que la función de análisis int yylex(void) reciba una indicación de EOF desde YY_INPUT, asuma que no hay nada más para analizar de yyin y finalice (haciendo un return 0;) */
%option noyywrap

/* %option yylineno */

    /* Condiciones de arranque inclusivas */
/* %s */
    /* Condiciones de arranque exclusivas */
%x tokenNoReconocido
%x restoLinea


/* Fin de la sección de definiciones */

/* Inicio de la sección de reglas. Aquí: */
    /* 1. Cualquier texto sangrado o encerrado entre '%{' y '%}' (estos últimos dos sin sangrar en líneas ocupadas únicamente por ellos) se copia íntegramente al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */
        /* Esto podría utilizarse para declarar variables que son locales a la rutina de análisis léxico y (después de las declaraciones) al código que debe ejecutarse siempre que se entra a la rutina de análisis léxico */
    /* 2. NO pueden hacerse comentarios sin sangría, ya que estos no se copian literalmente al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */
%%


"+" { 
    if (DEBUG){
        fprintf(stderr,"Leo un signo +.\n");
    }
    yylloc.first_column += yyleng;
    return '+'; 
}

"-" { 
    yylloc.first_column += yyleng; 
    return '-'; 
}

"*" { 
    yylloc.first_column += yyleng; 
    return '*'; 
}

"/" { 
    yylloc.first_column += yyleng; 
    return '/'; 
}

"^" { 
    yylloc.first_column += yyleng; 
    return '^'; 
}

"," { 
    if (DEBUG){
        fprintf(stderr,"Leo una coma.\n");
    }
    yylloc.first_column += yyleng;
    return ',';
}

"{" {
    if (DEBUG){
        fprintf(stderr,"Leo una llave.\n");
    }
    yylloc.first_column += yyleng;
    return '{';
}

"}" {
    if (DEBUG){
        fprintf(stderr,"Leo una llave.\n");
    }
    yylloc.first_column += yyleng;
    return '}';
}

":" {
    if (DEBUG){
        fprintf(stderr,"Token :\n");
    }
    yylloc.first_column += yyleng;
    return ':';
}

{DIGITO_NO_CERO}{DIGITO_DECIMAL}*{DIGITO_UNSIGNED}?{DIGITO_LONG}{0,2} {
    if (DEBUG){
        fprintf(stderr,"Leo una constante entera decimal.\n");
    }
    yylloc.first_column += yyleng;
    return CONSTANTE;
}

0{DIGITO_OCTAL}*{DIGITO_UNSIGNED}?{DIGITO_LONG}{0,2} {
    if (DEBUG){
        fprintf(stderr,"Leo una constante entera octal.\n");
    }
    yylloc.first_column += yyleng; 
    return CONSTANTE;
}

0[xX]{DIGITO_HEXADECIMAL}+{DIGITO_UNSIGNED}?{DIGITO_LONG}{0,2} {
    if (DEBUG){
        fprintf(stderr,"Leo una constante entera hexadecimal. %s\n", yytext);
    }
    yylloc.first_column += yyleng;
    return CONSTANTE;
}

{DIGITO_SIGNO_EXPONENTE}?({DIGITO_DECIMAL}*\.{DIGITO_DECIMAL}+({DIGITO_EXPONENTE}{DIGITO_SIGNO_EXPONENTE}?{DIGITO_DECIMAL}+)?|{DIGITO_DECIMAL}+\.({DIGITO_EXPONENTE}{DIGITO_SIGNO_EXPONENTE}?{DIGITO_DECIMAL}+)?){DIGITO_FLOAT}? {
    if (DEBUG){
        fprintf(stderr,"Leo una constante entera real.\n");
    }
    yylloc.first_column += yyleng;
    return CONSTANTE;
}

\'({CARACTER_SIMPLE}|\\{SECUENCIA_DE_ESCAPE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXADECIMAL}+)?\' {
    if (DEBUG){
        fprintf(stderr,"Leo una constante caracter.\n");
    }
    yylloc.first_column += yyleng;
    return CONSTANTE;
}

\"({CARACTER_CON_NEGACION}|\\{SECUENCIA_DE_ESCAPE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXADECIMAL}+)*\" {
    if (DEBUG){
        fprintf(stderr,"Leo un literal cadena.\n");
    }
    yylloc.first_column += yyleng;
    return LITERAL_CADENA;
}

(void) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return VOID;
}

(char) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return CHAR;
}

(double) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return DOUBLE;
}

(enum) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return ENUM;
}

(float) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return FLOAT;
}

(int) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return INT;
}

(long) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return LONG;
}

(short) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return SHORT;
}

(struct) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return STRUCT;
}

(union) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return UNION;
}

(signed) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return SIGNED;
}

(unsigned) {
    if (DEBUG){
        fprintf(stderr,"Leo un tipo de dato:%s\n", yytext);
    }
    yylval.sval = strdup(yytext);
    yylloc.first_column += yyleng;
    return UNSIGNED;
}


(if) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada IF.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return IF;
}

(else) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada ELSE.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return ELSE;
}

(while) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada WHILE.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return WHILE;
}

(do) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada DO.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return DO;
}

(for) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada FOR.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return FOR;
}

(switch) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada SWITCH.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return SWITCH;
}

(case) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada CASE.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return CASE;
}

(default) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada DEFAULT.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return DEFAULT;
}

(return) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada RETURN.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return RETURN;
}

(break) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada BREAK.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return BREAK;
}

(continue) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada CONTINUE.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return CONTINUE;
}

(goto) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada GOTO.\n");
    }
    yylval.lugar.linea = yylloc.first_line;
    yylval.lugar.columna = yylloc.first_column;
    yylloc.first_column += yyleng;
    return GOTO;
}

(sizeof) {
    if (DEBUG){
        fprintf(stderr,"Leo palabra reservada SIZEOF.\n");
    }
    yylloc.first_column += yyleng;
    return SIZEOF;
}

(auto) {
    if (DEBUG){
        fprintf(stderr,"Leo un especificador de almacenamiento:%s\n", yytext);
    }
    yylloc.first_column += yyleng;
    yylval.sval = strdup(yytext);
    return AUTO;

}

(extern) {
    if (DEBUG){
        fprintf(stderr,"Leo un especificador de almacenamiento:%s\n", yytext);
    }
    yylloc.first_column += yyleng;
    yylval.sval = strdup(yytext);
    return EXTERN;

}

(register) {
    if (DEBUG){
        fprintf(stderr,"Leo un especificador de almacenamiento:%s\n", yytext);
    }
    yylloc.first_column += yyleng;
    yylval.sval = strdup(yytext);
    return REGISTER;

}

(static) {
    if (DEBUG){
        fprintf(stderr,"Leo un especificador de almacenamiento:%s\n", yytext);
    }
    yylloc.first_column += yyleng;
    yylval.sval = strdup(yytext);
    return STATIC;

}

(typedef) {
    if (DEBUG){
        fprintf(stderr,"Leo un especificador de almacenamiento:%s\n", yytext);
    }
    yylloc.first_column += yyleng;
    yylval.sval = strdup(yytext);
    return TYPEDEF;

}

(const) {
    if (DEBUG){
        fprintf(stderr,"Leo un calificador de tipo:%s\n", yytext);
    }
    yylloc.first_column += yyleng;
    yylval.sval = strdup(yytext);
    return CONST;
}

(volatile) {
    if (DEBUG){
        fprintf(stderr,"Leo un calificador de tipo:%s\n", yytext);
    }
    yylloc.first_column += yyleng;
    yylval.sval = strdup(yytext);
    return VOLATILE;
}

{IDENTIFICADOR} { 
    if (DEBUG){
        fprintf(stderr,"Leo un identificador:%s,%d\n", yytext, yylloc.first_column);
    }
    yylval.id.identificador = strdup(yytext);
    yylval.id.linea = yylloc.first_line;
    yylval.id.columna = yylloc.first_column;        //Agrego el envio de la columna por parte del analizador lexico
    yylloc.first_column += yyleng; 
    if (DEBUG){
        fprintf(stderr,"Leo un identificador:%s,%d\n", yytext, yylloc.first_column);
    }
    return IDENTIFICADOR;
}

"(" {
    if (DEBUG){
        fprintf(stderr,"Leo un parentesis.\n");
    }
    yylloc.first_column += yyleng;
    return '(';
}

")" {
    if (DEBUG){
        fprintf(stderr,"Leo un parentesis.\n");
    }
    yylloc.first_column += yyleng;
    return ')'; 
}

"[" {
    if (DEBUG){
        fprintf(stderr,"Leo un corchete.\n");
    }
    yylloc.first_column += yyleng;
    return '['; 

}

"]" {
    if (DEBUG){
        fprintf(stderr,"Leo un corchete.\n");
    }
    yylloc.first_column += yyleng;
    return ']'; 
}

";" {
    if (DEBUG){
        fprintf(stderr,"Leo un punto y coma.\n");
    }
    yylloc.first_column += yyleng;
    return ';'; 
}

{OPERADORES_ARITMETICOS} { //problema con * de expunaria y de multiplicacion??
    if (DEBUG){
        fprintf(stderr,"Leo un operador aritmetico.\n");
    }
    yylloc.first_column += yyleng;
    //return yytext[0];
}

{OPERADORES_DE_ASIGNACION} {
    if (DEBUG){
        fprintf(stderr,"Leo un operador de asignacion.\n");
    }
    yylloc.first_column += yyleng;
    return OPER_ASIGNACION;
}

{OPERADORES_IGUAL} {
    if (DEBUG){
        fprintf(stderr,"Leo un operador de IGUAL.\n");
    }
    yylloc.first_column += yyleng;
    return OPER_IGUALDAD;
}

{OPERADORES_RELACIONAL} {
    if (DEBUG){
        fprintf(stderr,"Leo un operador de relacion.\n");
    }
    yylloc.first_column += yyleng;
    return OPER_RELACIONAL;
}

"||" {
    if (DEBUG){
        fprintf(stderr,"Leo un OR.\n");
    }
    yylloc.first_column += yyleng;
    return OR; 
}

"&&" {
    if (DEBUG){
        fprintf(stderr,"Leo un AND.\n");
    }
    yylloc.first_column += yyleng;
    return AND; 
}

(\+\+|--) {
    if (DEBUG){
        fprintf(stderr,"Leo un incremento o decremento: %s.\n",yytext);
    }
    yylloc.first_column += yyleng;
    return MASOMENOS; 
}

[{SIMBOLOS_DE_AGRUPACION}|{OPERADORES_ARITMETICOS}|{OPERADORES_DE_ASIGNACION}|{OPERADORES_DE_COMPARACION}|{OPERADORES_LOGICOS}|{OPERADORES_BIT_A_BIT}] {
    if (DEBUG){
        fprintf(stderr,"Leo un operador.\n");
    }
    yylloc.first_column += yyleng;
}

[ \t]+ { 
    if (DEBUG){
        fprintf(stderr,"Leo un espacio o tabulación.\n");
    }
    yylloc.first_column += yyleng; 
    }

\n+ {
    if (DEBUG){
        fprintf(stderr,"Leo un salto de linea.\n");
    }
        yylloc.first_line += yyleng;
        yylloc.first_column = INICIO_CONTEO_COLUMNA;
    }

[^ \t\n] { if (DEBUG)
            {
                fprintf(stderr, "%d:%d: Error lexico: token no reconocido: %s\n", yylloc.first_line, yylloc.first_column, yytext);
            }
            yyless(0);
			BEGIN(tokenNoReconocido);
        }
<tokenNoReconocido>{
    <<EOF>> {
            fprintf(stderr, "\n");
            BEGIN(INITIAL);
    }
    [^ \t\n]+ {
            agregar_cadena_no_reconocida(yytext, yylloc.first_line, yylloc.first_column);
            yylloc.first_column += yyleng;
            BEGIN(restoLinea);
    }
}
<restoLinea>{
    (.)*$ {
        BEGIN(INITIAL);
    }
}


    /* Reglas por defecto de Flex: */
        /* <*>.|\n { ECHO; } */
            /* (ECHO; escribe yytext en la salida del escáner: FILE* yyout (variable global a la cual por defecto se le asigna stdout)) */
        /* <<EOF>> { yyterminate(); } */
            /* (yyterminate(); hace que la función yylex finalice retornando un 0, indicando un fin-de-entrada (EOF)) */

%%
/* Fin de la sección de reglas */ 

/* Inicio de la sección de código de usuario, la cual: */
	/* 1. Se utiliza para rutinas de complemento que llaman al analizador léxico o son llamadas por este; la presencia de esta sección es opcional */
    /* 2. Toda esta sección simplemente se copia íntegramente al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */

/* Fin de la sección de código de usuario */