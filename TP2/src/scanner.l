/* Inicio de la sección de definiciones. Aquí: */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "analizador.h"

#define DEBUG 0
#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

// Variables globales para almacenamiento de datos
Identificador *lista_identificadores = NULL;
LiteralCadena *lista_literales_cadena = NULL;
PalabraReservada *lista_palabras_reservadas_tipo_datos = NULL;
PalabraReservada *lista_palabras_reservadas_estruc_control = NULL;
PalabraReservada *lista_palabras_reservadas_otras = NULL;
ConstanteDecimal *lista_constantes_decimales = NULL;
ConstanteHexadecimal *lista_constantes_hexadecimales = NULL;
ConstanteOctal *lista_constantes_octales = NULL;
ConstanteReal *lista_constantes_reales = NULL;
ConstanteCaracter *lista_constantes_caracter = NULL;
Operador *lista_operadores = NULL;
CadenaNoReconocida *lista_cadenas_no_reconocidas = NULL;

int linea = INICIO_CONTEO_LINEA;
int columna = INICIO_CONTEO_COLUMNA;


void agregar_identificador(Identificador **lista_identificadores, const char *identificador) {
    
    Identificador *actual = *lista_identificadores;
    Identificador *prev = NULL;

    // Buscar si el identificador ya existe en la lista
    while (actual != NULL && strcmp(actual->identificador, identificador) < 0) {
        prev = actual;
        actual = actual->next;
    }

    // Si el identificador ya existe, actualizar el count
    if (actual != NULL && strcmp(actual->identificador, identificador) == 0) {
        actual->count++;
        return;
    }

    // Crear un nuevo nodo
    Identificador *nuevo = (Identificador *)malloc(sizeof(Identificador));

    nuevo->identificador = strdup(identificador);

    nuevo->count = 1;
    nuevo->next = NULL;

    // Insertar el nuevo nodo en la posición correcta
    if (prev == NULL) {
        // Insertar al principio de la lista
        nuevo->next = *lista_identificadores;
        *lista_identificadores = nuevo;
    } else {
        // Insertar en el medio o al final de la lista
        nuevo->next = actual;
        prev->next = nuevo;
    }
}

void agregar_literal_cadena(LiteralCadena **lista_literales_cadena, const char *literal, int length) {

    // Crear un nuevo nodo
    LiteralCadena *nuevo = (LiteralCadena *)malloc(sizeof(LiteralCadena));

    nuevo->literal = strdup(literal);

    nuevo->length = length;
    nuevo->next = NULL;

    // Caso 1: Lista vacía
    if (*lista_literales_cadena == NULL) {
        *lista_literales_cadena = nuevo;
        return;
    }

    // Caso 2: Insertar al principio (longitud menor)
    if ((*lista_literales_cadena)->length > length) {
        nuevo->next = *lista_literales_cadena;
        *lista_literales_cadena = nuevo;
        return;
    }

    // Buscar el lugar adecuado para insertar el nuevo nodo
    LiteralCadena *actual = *lista_literales_cadena;
    while (actual->next != NULL && (actual->next->length < length)) {
        actual = actual->next;
    }

    // Insertar el nuevo nodo
    if (actual->next != NULL && actual->next->length == length) {
        // Longitud igual, insertar en el orden de aparición
        nuevo->next = actual->next;
        actual->next = nuevo;
    } else {
        // Longitud diferente
        nuevo->next = actual->next;
        actual->next = nuevo;
    }
}

void agregar_palabra_reservada(PalabraReservada **lista_palabras_reservadas, const char *palabra, int linea, int columna) {
    PalabraReservada *nuevo = (PalabraReservada *)malloc(sizeof(PalabraReservada));
    nuevo->palabra = strdup(palabra);
    nuevo->linea = linea;
    nuevo->columna = columna;
    nuevo->next = NULL;

    if (*lista_palabras_reservadas == NULL) {
        *lista_palabras_reservadas = nuevo;
    } else {
        PalabraReservada *actual = *lista_palabras_reservadas;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_constante_decimal(ConstanteDecimal **lista_constantes_decimales, int valor) {
    ConstanteDecimal *nuevo = (ConstanteDecimal *)malloc(sizeof(ConstanteDecimal));
    nuevo->valor = valor;
    nuevo->next = NULL;

    if (*lista_constantes_decimales == NULL) {
        *lista_constantes_decimales = nuevo;
    } else {
        ConstanteDecimal *actual = *lista_constantes_decimales;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_constante_hexadecimal(ConstanteHexadecimal **lista_constantes_hexadecimales, const char *valor_hex, int valor_decimal) {
    ConstanteHexadecimal *nuevo = (ConstanteHexadecimal *)malloc(sizeof(ConstanteHexadecimal));
    nuevo->valor_hex = strdup(valor_hex);
    nuevo->valor_decimal = valor_decimal;
    nuevo->next = NULL;

    if (*lista_constantes_hexadecimales == NULL) {
        *lista_constantes_hexadecimales = nuevo;
    } else {
        ConstanteHexadecimal *actual = *lista_constantes_hexadecimales;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_constante_octal(ConstanteOctal **lista_constantes_octales, const char *valor_octal, int valor_decimal) {
    ConstanteOctal *nuevo = (ConstanteOctal *)malloc(sizeof(ConstanteOctal));
    nuevo->valor_octal = strdup(valor_octal);
    nuevo->valor_decimal = valor_decimal;
    nuevo->next = NULL;

    if (*lista_constantes_octales == NULL) {
        *lista_constantes_octales = nuevo;
    } else {
        ConstanteOctal *actual = *lista_constantes_octales;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_constante_real(ConstanteReal **lista_constantes_reales, const char *valor_real) {
    ConstanteReal *nuevo = (ConstanteReal *)malloc(sizeof(ConstanteReal));
    double valor = atof(valor_real);                    // convierte el número a flotante
    double _parte_entera = floor(valor);                // toma la parte entera
    double _mantisa = valor - _parte_entera;            // se queda con la parte decimal
    nuevo->valor_real = strdup(valor_real);
    nuevo->parte_entera = _parte_entera;
    nuevo->mantisa = _mantisa;
    nuevo->next = NULL;

    if (*lista_constantes_reales == NULL) {
        *lista_constantes_reales = nuevo;
    } else {
        ConstanteReal *actual = *lista_constantes_reales;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_constante_caracter(ConstanteCaracter **lista_constantes_caracter, const char *valor_caracter) {
    ConstanteCaracter *nuevo = (ConstanteCaracter *)malloc(sizeof(ConstanteCaracter));
    nuevo->valor_caracter = strdup(valor_caracter);
    nuevo->next = NULL;

    if (*lista_constantes_caracter == NULL) {
        *lista_constantes_caracter = nuevo;
    } else {
        ConstanteCaracter *actual = *lista_constantes_caracter;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_operador(Operador **lista_operadores, const char *operador) {
    Operador *actual = *lista_operadores;
    while (actual) {
        if (strcmp(actual->operador, operador) == 0) {
            actual->count++;
            return;
        }
        actual = actual->next;
    }

    Operador *nuevo = (Operador *)malloc(sizeof(Operador));
    nuevo->operador = strdup(operador);
    nuevo->count = 1;
    nuevo->next = NULL;

    if (*lista_operadores == NULL) {
        *lista_operadores = nuevo;
    } else {
        Operador *temp = *lista_operadores;
        while (temp->next != NULL) {
            temp = temp->next;
        }
        temp->next = nuevo;
    }
}

void agregar_cadena_no_reconocida(CadenaNoReconocida **lista_cadenas_no_reconocidas, const char *cadena, int linea, int columna) {
    CadenaNoReconocida *nuevo = (CadenaNoReconocida *)malloc(sizeof(CadenaNoReconocida));
    nuevo->cadena = strdup(cadena);
    nuevo->linea = linea;
    nuevo->columna = columna;
    nuevo->next = NULL;

    if (*lista_cadenas_no_reconocidas == NULL) {
        *lista_cadenas_no_reconocidas = nuevo;
    } else {
        CadenaNoReconocida *actual = *lista_cadenas_no_reconocidas;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void liberar_memoria_identificadores(Identificador **lista_identificadores){

    Identificador *actual = *lista_identificadores;
    Identificador *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual->identificador);
        free(actual);
        actual = siguiente;
    }

    *lista_identificadores = NULL;
}

void liberar_memoria_literales_cadena(LiteralCadena **lista_literales_cadena){
    
    LiteralCadena *actual = *lista_literales_cadena;
    LiteralCadena *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual->literal);
        free(actual);
        actual = siguiente;
    }

    *lista_literales_cadena = NULL;
}

void liberar_memoria_palabras_reservadas(PalabraReservada **lista_palabras_reservadas){

    PalabraReservada *actual = *lista_palabras_reservadas;
    PalabraReservada *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual->palabra);
        free(actual);
        actual = siguiente;
    }

    *lista_palabras_reservadas = NULL;
}

void liberar_memoria_constante_decimal(ConstanteDecimal **lista_constantes_decimales){

    ConstanteDecimal *actual = *lista_constantes_decimales;
    ConstanteDecimal *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual);
        actual = siguiente;
    }

    *lista_constantes_decimales = NULL;
}

void liberar_memoria_constante_hexadecimal(ConstanteHexadecimal **lista_constantes_hexadecimales){

    ConstanteHexadecimal *actual = *lista_constantes_hexadecimales;
    ConstanteHexadecimal *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual->valor_hex);
        free(actual);
        actual = siguiente;
    }

    *lista_constantes_hexadecimales = NULL;
}

void liberar_memoria_constante_octal(ConstanteOctal **lista_constantes_octales){

    ConstanteOctal *actual = *lista_constantes_octales;
    ConstanteOctal *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual->valor_octal);
        free(actual);
        actual = siguiente;
    }

    *lista_constantes_octales = NULL;
}

void liberar_memoria_constante_real(ConstanteReal **lista_constantes_reales){

    ConstanteReal *actual = *lista_constantes_reales;
    ConstanteReal *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual->valor_real);
        free(actual);
        actual = siguiente;
    }

    *lista_constantes_reales = NULL;
}

void liberar_memoria_constante_caracter(ConstanteCaracter **lista_constantes_caracter){

    ConstanteCaracter *actual = *lista_constantes_caracter;
    ConstanteCaracter *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual->valor_caracter);
        free(actual);
        actual = siguiente;
    }

    *lista_constantes_caracter = NULL;
}

void liberar_memoria_operador(Operador **lista_operadores){

    Operador *actual = *lista_operadores;
    Operador *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual->operador);
        free(actual);
        actual = siguiente;
    }

    *lista_operadores = NULL;
}

void liberar_memoria_cadena_no_reconocida(CadenaNoReconocida **lista_cadenas_no_reconocidas){

    CadenaNoReconocida *actual = *lista_cadenas_no_reconocidas;
    CadenaNoReconocida *siguiente = NULL;

    while (actual != NULL) {
        siguiente = actual->next;
        free(actual->cadena);
        free(actual);
        actual = siguiente;
    }

    *lista_cadenas_no_reconocidas = NULL;
}

void imprimir_reporte(Identificador *lista_identificadores, LiteralCadena *lista_literales_cadena, PalabraReservada *lista_palabras_reservadas_tipo_datos,
                     PalabraReservada *lista_palabras_reservadas_estruc_control,PalabraReservada *lista_palabras_reservadas_otras, ConstanteDecimal *lista_constantes_decimales,
                      ConstanteHexadecimal *lista_constantes_hexadecimales, ConstanteOctal *lista_constantes_octales, ConstanteReal *lista_constantes_reales, 
                      ConstanteCaracter *lista_constantes_caracter, Operador *lista_operadores, CadenaNoReconocida *lista_cadenas_no_reconocidas) {

    printf("* Listado de identificadores encontrados:\n");
    Identificador *actual_ident = lista_identificadores;
    if (!actual_ident) {
        printf("-\n");
    } else {
        while (actual_ident) {
            if(actual_ident->count == 1){
                printf("%s: aparece %d vez\n", actual_ident->identificador, actual_ident->count);
            }
            else{
                printf("%s: aparece %d veces\n", actual_ident->identificador, actual_ident->count);
            }
            actual_ident = actual_ident->next;
        }
    }

    printf("\n* Listado de literales cadena encontrados:\n");
    LiteralCadena *actual_literal = lista_literales_cadena;
    if (!actual_literal) {
        printf("-\n");
    } else {
        while (actual_literal) {
            printf("%s: longitud %d\n", actual_literal->literal, actual_literal->length);
            actual_literal = actual_literal->next;
        }
    }

    printf("\n* Listado de palabras reservadas (tipos de dato):\n");
    PalabraReservada *actual_palabra_TD = lista_palabras_reservadas_tipo_datos;
    if (!actual_palabra_TD) {
        printf("-\n");
    } else {
        while (actual_palabra_TD) {
            printf("%s: linea %d, columna %d\n", actual_palabra_TD->palabra, actual_palabra_TD->linea, actual_palabra_TD->columna);
            actual_palabra_TD = actual_palabra_TD->next;
        }
    }

    printf("\n* Listado de palabras reservadas (estructuras de control):\n");
    PalabraReservada *actual_palabra_EC = lista_palabras_reservadas_estruc_control;
    if (!actual_palabra_EC) {
        printf("-\n");
    } else {
        while (actual_palabra_EC) {
            printf("%s: linea %d, columna %d\n", actual_palabra_EC->palabra, actual_palabra_EC->linea, actual_palabra_EC->columna);
            actual_palabra_EC = actual_palabra_EC->next;
        }
    }

    printf("\n* Listado de palabras reservadas (otros):\n");
    PalabraReservada *actual_palabra_O = lista_palabras_reservadas_otras;
    if (!actual_palabra_O) {
        printf("-\n");
    } else {
        while (actual_palabra_O) {
            printf("%s: linea %d, columna %d\n", actual_palabra_O->palabra, actual_palabra_O->linea, actual_palabra_O->columna);
            actual_palabra_O = actual_palabra_O->next;
        }
    }


    printf("\n* Listado de constantes enteras decimales:\n");
    ConstanteDecimal *actual_decimal = lista_constantes_decimales;
    int total_decimal = 0;
    if (!actual_decimal) {
        printf("-\n");
    } else {
        while (actual_decimal) {
            printf("%d: valor %d\n", actual_decimal->valor, actual_decimal->valor);
            total_decimal += actual_decimal->valor;
            actual_decimal = actual_decimal->next;
        }
        printf("Total acumulado de sumar todas las constantes decimales: %d\n", total_decimal);
    }

    printf("\n* Listado de constantes enteras hexadecimales:\n");
    ConstanteHexadecimal *actual_hex = lista_constantes_hexadecimales;
    if (!actual_hex) {
        printf("-\n");
    } else {
        while (actual_hex) {
            printf("%s: valor entero decimal %d\n", actual_hex->valor_hex, actual_hex->valor_decimal);
            actual_hex = actual_hex->next;
        }
    }

    printf("\n* Listado de constantes enteras octales:\n");
    ConstanteOctal *actual_octal = lista_constantes_octales;
    if (!actual_octal) {
        printf("-\n");
    } else {
        while (actual_octal) {
            printf("%s: valor entero decimal %d\n", actual_octal->valor_octal, actual_octal->valor_decimal);
            actual_octal = actual_octal->next;
        }
    }

    printf("\n* Listado de constantes reales:\n");
    ConstanteReal *actual_real = lista_constantes_reales;
    if (!actual_real) {
        printf("-\n");
    } else {
        while (actual_real) {
            printf("%s: parte entera %.6f , mantisa %.6f\n", actual_real->valor_real, actual_real->parte_entera, actual_real->mantisa);
            actual_real = actual_real->next;
        }
    }

    printf("\n* Listado de constantes caracter enumerados:\n");
    ConstanteCaracter *actual_caracter = lista_constantes_caracter;
    int count = 1;
    if (!actual_caracter) {
        printf("-\n");
    } else {
        while (actual_caracter) {
            printf("%d) %s\n", count++, actual_caracter->valor_caracter);
            actual_caracter = actual_caracter->next;
        }
    }

    printf("\n* Listado de operadores/caracteres de puntuación:\n");
    Operador *actual_operador = lista_operadores;
    if (!actual_operador) {
        printf("-\n");
    } else {
        while (actual_operador) {
            if(actual_operador->count == 1){
                printf("%s: aparece %d vez\n", actual_operador->operador, actual_operador->count);
            }
            else{
                printf("%s: aparece %d veces\n", actual_operador->operador, actual_operador->count);
            }
            actual_operador = actual_operador->next;
        }
    }

    printf("\n* Listado de cadenas no reconocidas:\n");
    CadenaNoReconocida *actual_cadena_no_reconocida = lista_cadenas_no_reconocidas;
    if (!actual_cadena_no_reconocida) {
        printf("-\n");
    } else {
        while (actual_cadena_no_reconocida) {
            printf("%s: linea %d, columna %d\n", actual_cadena_no_reconocida->cadena, actual_cadena_no_reconocida->linea, actual_cadena_no_reconocida->columna);
            actual_cadena_no_reconocida = actual_cadena_no_reconocida->next;
        }
    }
}

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
OPERADORES_DE_ASIGNACION [\=\+\=\-\=\*\=\%\=]
OPERADORES_DE_COMPARACION [\=\=|\!\=|\>\=|\<\=|\>\>|\<]
OPERADORES_LOGICOS [\&\&|\|\||\!]
OPERADORES_BIT_A_BIT [\&|\||\^|\~|\<\<|\>\>]
IDENTIFICADOR [a-zA-Z_][a-zA-Z0-9_]*

/* La siguiente línea define explícitamente a yytext como un puntero a un caracter ( char* yytext; ). Ésta es la opción por defecto si no se pone nada. */
%pointer
/* Con la siguiente opción la función de análisis int yylex(void); se comporta como si en la sección de usuario existiera la función int yywrap(void) return 1; la cual devuelve verdadero (no-cero), haciendo que una vez que la función de análisis int yylex(void) reciba una indicación de EOF desde YY_INPUT, asuma que no hay nada más para analizar de yyin y finalice (haciendo un return 0;) */
%option noyywrap

/* Condiciones de arranque inclusivas */
/* %s */
/* Condiciones de arranque exclusivas */
%x tokenNoReconocido

/* Declaraciones con cada nombre y su definición; se utilizan para simplificar las reglas */
/* digito [0-9] */

/* Fin de la sección de definiciones */

/* Inicio de la sección de reglas. Aquí: */
/* 1. Cualquier texto sangrado o encerrado entre '%{' y '%}' (estos últimos dos sin sangrar en líneas ocupadas únicamente por ellos) se copia íntegramente al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */
/* Esto podría utilizarse para declarar variables que son locales a la rutina de análisis léxico y (después de las declaraciones) al código que debe ejecutarse siempre que se entra a la rutina de análisis léxico */
/* 2. NO pueden hacerse comentarios sin sangría, ya que estos no se copian literalmente al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */
%%

{DIGITO_NO_CERO}{DIGITO_DECIMAL}*{DIGITO_UNSIGNED}?{DIGITO_LONG}{0,2} {
    if (DEBUG){
        fprintf(stderr,"Leo una constante entera decimal\n");
    }
    agregar_constante_decimal(&lista_constantes_decimales,atoi(yytext));
    columna += yyleng;
}

0{DIGITO_OCTAL}*{DIGITO_UNSIGNED}?{DIGITO_LONG}{0,2} {
    if (DEBUG){
        fprintf(stderr,"Leo una constante entera octal\n");
    }
    agregar_constante_octal(&lista_constantes_octales, yytext, strtol(yytext, NULL, 8));
    columna += yyleng; 
}

0[xX]{DIGITO_HEXADECIMAL}+{DIGITO_UNSIGNED}?{DIGITO_LONG}{0,2} {
    if (DEBUG){
        fprintf(stderr,"Leo una constante entera hexadecimal\n");
    }
    agregar_constante_hexadecimal(&lista_constantes_hexadecimales, yytext, strtol(yytext, NULL, 16));
    columna += yyleng;
}

{DIGITO_SIGNO_EXPONENTE}?({DIGITO_DECIMAL}*\.{DIGITO_DECIMAL}+({DIGITO_EXPONENTE}{DIGITO_SIGNO_EXPONENTE}?{DIGITO_DECIMAL}+)?|{DIGITO_DECIMAL}+\.({DIGITO_EXPONENTE}{DIGITO_SIGNO_EXPONENTE}?{DIGITO_DECIMAL}+)?){DIGITO_FLOAT}? {
    if (DEBUG){
        fprintf(stderr,"Leo una constante entera real\n");
    }
    agregar_constante_real(&lista_constantes_reales, yytext);
    columna += yyleng;
}

\'({CARACTER_SIMPLE}|\\{SECUENCIA_DE_ESCAPE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXADECIMAL}+)?\' {
    if (DEBUG){
        fprintf(stderr,"Leo una constante caracter\n");
    }
    agregar_constante_caracter(&lista_constantes_caracter, yytext);
    columna += yyleng;
}

\"({CARACTER_CON_NEGACION}|\\{SECUENCIA_DE_ESCAPE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXADECIMAL}+)*\" {
    if (DEBUG){
        fprintf(stderr,"Leo un literal cadena\n");
    }
    agregar_literal_cadena(&lista_literales_cadena, yytext, yyleng-2);
    columna += yyleng;
}

(char|double|enum|float|int|long|short|struct|union|void) {
    if (DEBUG){
        fprintf(stderr,"Leo una palabra reservada - tipo de dato\n");
    }
    agregar_palabra_reservada(&lista_palabras_reservadas_tipo_datos, yytext, linea, columna);
    columna += yyleng;
}

(break|case|continue|default|do|else|for|goto|if|return|switch|while) {
    if (DEBUG){
        fprintf(stderr,"Leo una palabra reservada - estructura de control\n");
    }
    agregar_palabra_reservada(&lista_palabras_reservadas_estruc_control, yytext, linea, columna);
    columna += yyleng;
}

(auto|const|extern|register|signed|sizeof|static|typedef|unsigned|volatile) {
    if (DEBUG){
        fprintf(stderr,"Leo una palabra reservada - otra categoría\n");
    }
    agregar_palabra_reservada(&lista_palabras_reservadas_otras, yytext, linea, columna);
    columna += yyleng;
}

{IDENTIFICADOR} {   
    if (DEBUG){
        fprintf(stderr,"Leo un identificador\n");
    }
    agregar_identificador(&lista_identificadores, yytext); 
    columna += yyleng; 
}

{SIMBOLOS_DE_AGRUPACION}|{OPERADORES_ARITMETICOS}|{OPERADORES_DE_ASIGNACION}|{OPERADORES_DE_COMPARACION}|{OPERADORES_LOGICOS}|\ {OPERADORES_BIT_A_BIT} {
    if (DEBUG){
        fprintf(stderr,"Leo un operador\n");
    }
    agregar_operador(&lista_operadores, yytext);
    columna += yyleng;
}

[ \t]+ { 
    if (DEBUG){
        fprintf(stderr,"Leo un espacio o tabulación.\n");
    }
    columna += yyleng; }

\n+ { 
    if (DEBUG){
        fprintf(stderr,"Leo un salto de linea\n");
    }
    linea += yyleng;
    columna = INICIO_CONTEO_COLUMNA; 
}

[^ \t\n] { if (DEBUG)
            {
                fprintf(stderr, "%d:%d: Error lexico: token no reconocido: %s", linea, columna, yytext);
            }
            yyless(0);
			BEGIN(tokenNoReconocido);
        }
<tokenNoReconocido>{
    <<EOF>> {
                    fprintf(stderr, "\n");
                    BEGIN(INITIAL);
    }
    " "|\t|\n {
				yyless(0);
                fprintf(stderr, "\n");
                BEGIN(INITIAL);
    }
    [^ \t\n]+ {
        agregar_cadena_no_reconocida(&lista_cadenas_no_reconocidas, yytext, linea, columna);
        columna += yyleng;
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

int main(int argc, char *argv[]){
    if (argc != 2){
        printf("error");
        return EXIT_FAILURE;
    } 
    yyin = fopen(argv[1], "r");
    yylex();
    imprimir_reporte(lista_identificadores, lista_literales_cadena, lista_palabras_reservadas_tipo_datos, lista_palabras_reservadas_estruc_control, lista_palabras_reservadas_otras, lista_constantes_decimales, lista_constantes_hexadecimales, lista_constantes_octales, lista_constantes_reales, lista_constantes_caracter, lista_operadores, lista_cadenas_no_reconocidas);
    liberar_memoria_identificadores(&lista_identificadores);
    liberar_memoria_literales_cadena(&lista_literales_cadena);
    liberar_memoria_palabras_reservadas(&lista_palabras_reservadas_tipo_datos);
    liberar_memoria_palabras_reservadas(&lista_palabras_reservadas_estruc_control);
    liberar_memoria_palabras_reservadas(&lista_palabras_reservadas_otras);
    liberar_memoria_constante_decimal(&lista_constantes_decimales);
    liberar_memoria_constante_hexadecimal(&lista_constantes_hexadecimales);
    liberar_memoria_constante_octal(&lista_constantes_octales);
    liberar_memoria_constante_real(&lista_constantes_reales);
    liberar_memoria_constante_caracter(&lista_constantes_caracter);
    liberar_memoria_operador(&lista_operadores);
    liberar_memoria_cadena_no_reconocida(&lista_cadenas_no_reconocidas);
    return EXIT_SUCCESS;
}

/* Fin de la sección de código de usuario */
