/* Inicio de la sección de definiciones. Aquí: */
/* 1. Cualquier texto sangrado o encerrado entre '%{' y '%}' (estos últimos dos sin sangrar en líneas ocupadas únicamente por ellos) se copia íntegramente al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */
/* De esas formas podemos poner declaraciones y definiciones de C y directivas del preprocesador */
/* 2. Los comentarios (sólo hay de múltiples líneas) sin sangría también se copian tal cual al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */

%{

#include "analizador.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define DEBUG 1 // Habilitar depuración
#if DEBUG
#define DEBUG_PRINT(fmt, ...) fprintf(stderr, fmt, __VA_ARGS__)
#else
#define DEBUG_PRINT(fmt, ...)
#endif

// Variables globales para almacenamiento de datos
Identificador *lista_identificadores = NULL;
LiteralCadena *lista_literales_cadena = NULL;
PalabraReservada *lista_palabras_reservadas = NULL;
ConstanteDecimal *lista_constantes_decimales = NULL;
ConstanteHexadecimal *lista_constantes_hexadecimales = NULL;
ConstanteOctal *lista_constantes_octales = NULL;
ConstanteReal *lista_constantes_reales = NULL;
ConstanteCaracter *lista_constantes_caracter = NULL;
Operador *lista_operadores = NULL;
CadenaNoReconocida *lista_cadenas_no_reconocidas = NULL;

int linea = 1;
int columna = 1;

//De esta forma la lista se carga "al reves", ya que los nuevos nodos son insertados al principio.

void agregar_identificador(Identificador **lista_identificadores, const char *identificador) {
    Identificador *actual = lista_identificadores;
    while (actual) {
        if (strcmp(actual->identificador, identificador) == 0) {
            actual->count++;
            return;
        }
        actual = actual->next;
    }
    Identificador *nuevo = (Identificador *)malloc(sizeof(Identificador));
    nuevo->identificador = strdup(identificador);
    nuevo->count = 1;
    nuevo->next = *lista_identificadores;
    lista_identificadores = nuevo;
}

void agregar_literal_cadena(LiteralCadena **lista_literales_cadena, const char *literal, int length) {
    LiteralCadena *nuevo = (LiteralCadena *)malloc(sizeof(LiteralCadena));
    nuevo->literal = strdup(literal);
    nuevo->length = length;
    nuevo->next = *lista_literales_cadena;
    lista_literales_cadena = nuevo;
}

void agregar_palabra_reservada(PalabraReservada **lista_palabras_reservadas, const char *palabra, int linea, int columna, const char *tipo) {
    PalabraReservada *nuevo = (PalabraReservada *)malloc(sizeof(PalabraReservada));
    nuevo->palabra = strdup(palabra);
    nuevo->linea = linea;
    nuevo->columna = columna;
    nuevo->tipo = strdup(tipo);
    nuevo->next = *lista_palabras_reservadas;
    lista_palabras_reservadas = nuevo;
}

void agregar_constante_decimal(ConstanteDecimal **lista_constantes_decimales, int valor) {
    ConstanteDecimal *nuevo = (ConstanteDecimal *)malloc(sizeof(ConstanteDecimal));
    nuevo->valor = valor;
    nuevo->next = *lista_constantes_decimales;
    lista_constantes_decimales = nuevo;
}

void agregar_constante_hexadecimal(ConstanteHexadecimal **lista_constantes_hexadecimales, const char *valor_hex, int valor_decimal) {
    ConstanteHexadecimal *nuevo = (ConstanteHexadecimal *)malloc(sizeof(ConstanteHexadecimal));
    nuevo->valor_hex = strdup(valor_hex);
    nuevo->valor_decimal = valor_decimal;
    nuevo->next = *lista_constantes_hexadecimales;
    lista_constantes_hexadecimales = nuevo;
}

void agregar_constante_octal(ConstanteOctal **lista_constantes_octales, const char *valor_octal, int valor_decimal) {
    ConstanteOctal *nuevo = (ConstanteOctal *)malloc(sizeof(ConstanteOctal));
    nuevo->valor_octal = strdup(valor_octal);
    nuevo->valor_decimal = valor_decimal;
    nuevo->next = *lista_constantes_octales;
    lista_constantes_octales = nuevo;
}

void agregar_constante_real(ConstanteReal **lista_constantes_reales, const char *valor_real) {
    ConstanteReal *nuevo = (ConstanteReal *)malloc(sizeof(ConstanteReal));
    double valor = atof(valor_real);                    // convierte el numero a flotante
    double _parte_entera = floor(valor);                // toma la parte entera
    double _mantisa = valor - _parte_entera;       // se queda con la parte decimal
    nuevo->valor_real = strdup(valor_real);
    nuevo->parte_entera = _parte_entera;
    nuevo->mantisa = _mantisa;
    nuevo->next = *lista_constantes_reales;
    *lista_constantes_reales = nuevo;
}

void agregar_constante_caracter(ConstanteCaracter **lista_constantes_caracter, const char *valor_caracter) {
    ConstanteCaracter *nuevo = (ConstanteCaracter *)malloc(sizeof(ConstanteCaracter));
    nuevo->valor_caracter = strdup(valor_caracter);
    nuevo->next = *lista_constantes_caracter;
    lista_constantes_caracter = nuevo;
}

void agregar_operador(Operador **lista_operadores, const char *operador) {
    Operador *actual = lista_operadores;
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
    nuevo->next = *lista_operadores;
    lista_operadores = nuevo;
}

void agregar_cadena_no_reconocida(CadenaNoReconocida **lista_cadenas_no_reconocidas, const char *cadena, int linea, int columna) {
    CadenaNoReconocida *nuevo = (CadenaNoReconocida *)malloc(sizeof(CadenaNoReconocida));
    nuevo->cadena = strdup(cadena);
    nuevo->linea = linea;
    nuevo->columna = columna;
    nuevo->next = *lista_cadenas_no_reconocidas;
    lista_cadenas_no_reconocidas = nuevo;
}

void liberar_memoria(Identificador **lista_identificadores, LiteralCadena **lista_literales_cadena, PalabraReservada **lista_palabras_reservadas, ConstanteDecimal **lista_constantes_decimales, ConstanteHexadecimal **lista_constantes_hexadecimales, ConstanteOctal **lista_constantes_octales, ConstanteReal **lista_constantes_reales, ConstanteCaracter **lista_constantes_caracter, Operador **lista_operadores, CadenaNoReconocida **lista_cadenas_no_reconocidas) {
    // Liberar memoria de identificadores
    Identificador *actual_ident = lista_identificadores;
    while (actual_ident) {
        Identificador *temp = actual_ident;
        actual_ident = actual_ident->next;
        free(temp->identificador);
        free(temp);
    }

    /* VERSION PARA LIBERAR MEMORIA DE LA LISTA GLOBAL - REPLICAR PARA TODAS LAS LISTAS

    void liberar_memoria(Identificador **lista) {
    Identificador *actual = *lista;
    Identificador *siguiente;

    while (actual != NULL) {
        siguiente = actual->next;  // Guarda el siguiente nodo
        free(actual->identificador);  // Libera la memoria del identificador
        free(actual);  // Libera la memoria del nodo actual
        actual = siguiente;  // Avanza al siguiente nodo
    }

    *lista = NULL;  // Asegúrate de que la lista ahora apunta a NULL
    } */

    // Liberar memoria de literales cadena
    LiteralCadena *actual_literal = lista_literales_cadena;
    while (actual_literal) {
        LiteralCadena *temp = actual_literal;
        actual_literal = actual_literal->next;
        free(temp->literal);
        free(temp);
    }

    // Liberar memoria de palabras reservadas
    PalabraReservada *actual_palabra = lista_palabras_reservadas;
    while (actual_palabra) {
        PalabraReservada *temp = actual_palabra;
        actual_palabra = actual_palabra->next;
        free(temp->palabra);
        free(temp->tipo);
        free(temp);
    }

    // Liberar memoria de constantes decimales
    ConstanteDecimal *actual_decimal = lista_constantes_decimales;
    while (actual_decimal) {
        ConstanteDecimal *temp = actual_decimal;
        actual_decimal = actual_decimal->next;
        free(temp);
    }

    // Liberar memoria de constantes hexadecimales
    ConstanteHexadecimal *actual_hex = lista_constantes_hexadecimales;
    while (actual_hex) {
        ConstanteHexadecimal *temp = actual_hex;
        actual_hex = actual_hex->next;
        free(temp->valor_hex);
        free(temp);
    }

    // Liberar memoria de constantes octales
    ConstanteOctal *actual_octal = lista_constantes_octales;
    while (actual_octal) {
        ConstanteOctal *temp = actual_octal;
        actual_octal = actual_octal->next;
        free(temp->valor_octal);
        free(temp);
    }

    // Liberar memoria de constantes reales
    ConstanteReal *actual_real = lista_constantes_reales;
    while (actual_real) {
        ConstanteReal *temp = actual_real;
        actual_real = actual_real->next;
        free(temp->valor_real);
        free(temp);
    }

    // Liberar memoria de constantes caracteres
    ConstanteCaracter *actual_caracter = lista_constantes_caracter;
    while (actual_caracter) {
        ConstanteCaracter *temp = actual_caracter;
        actual_caracter = actual_caracter->next;
        free(temp->valor_caracter);
        free(temp);
    }

    // Liberar memoria de operadores
    Operador *actual_operador = lista_operadores;
    while (actual_operador) {
        Operador *temp = actual_operador;
        actual_operador = actual_operador->next;
        free(temp->operador);
        free(temp);
    }

    // Liberar memoria de cadenas no reconocidas
    CadenaNoReconocida *actual_cadena_no_reconocida = lista_cadenas_no_reconocidas;
    while (actual_cadena_no_reconocida) {
        CadenaNoReconocida *temp = actual_cadena_no_reconocida;
        actual_cadena_no_reconocida = actual_cadena_no_reconocida->next;
        free(temp->cadena);
        free(temp);
    }
}

void insertar_ordenado_id(Identificador **lista_identificadores, Identificador *nuevo) {
    if (*lista_identificadores == NULL || strcmp((*lista_identificadores)->identificador, nuevo->identificador) > 0) {
        nuevo->next = *lista_identificadores;
        *lista_identificadores = nuevo;
    } else {
        Identificador *actual = *lista_identificadores;
        while (actual->next != NULL && strcmp(actual->next->identificador, nuevo->identificador) <= 0) {
            actual = actual->next;
        }
        nuevo->next = actual->next;
        actual->next = nuevo;
    }
}

void ordenar_listado_identificadores(Identificador **lista_identificadores) {
    Identificador *ordenada = NULL;
    Identificador *actual = *lista_identificadores;
    while (actual != NULL) {
        Identificador *siguiente = actual->next;
        actual->next = NULL;
        insertar_ordenado_id(&ordenada, actual);
        actual = siguiente;
    }
    *lista_identificadores = ordenada;
}

void ordenar_listado_literales_cadena(LiteralCadena **lista_literales_cadena) {
    if (*lista_literales_cadena == NULL) return;

    LiteralCadena *ordenada = NULL;  // Nueva lista ordenada
    LiteralCadena *actual = *lista_literales_cadena;

    while (actual != NULL) {
        LiteralCadena *siguiente = actual->next;
        if (ordenada == NULL || strlen(actual->cadena) < strlen(ordenada->cadena)) {
            actual->next = ordenada;
            ordenada = actual;
        } else {
            LiteralCadena *temp = ordenada;
            while (temp->next != NULL && strlen(temp->next->cadena) <= strlen(actual->cadena)) {
                temp = temp->next;
            }
            actual->next = temp->next;
            temp->next = actual;
        }
        actual = siguiente;
    }

    *lista_literales_cadena = ordenada;
}

// PASAR POR PARAMETRO LAS LISTAS para la funcion imprimir_reporte
void imprimir_reporte(Identificador *lista_identificadores, LiteralCadena *lista_literales_cadena, PalabraReservada *lista_palabras_reservadas, ConstanteDecimal *lista_constantes_decimales, ConstanteHexadecimal *lista_constantes_hexadecimales, ConstanteOctal *lista_constantes_octales, ConstanteReal *lista_constantes_reales, ConstanteCaracter *lista_constantes_caracter, Operador *lista_operadores, CadenaNoReconocida *lista_cadenas_no_reconocidas) {
    // Imprimir listado de identificadores
    printf("* Listado de identificadores encontrados:\n");
    Identificador *actual_ident = lista_identificadores;
    if (!actual_ident) {
        printf("-\n");
    } else {
        while (actual_ident) {
            printf("%s: aparece %d veces\n", actual_ident->identificador, actual_ident->count);
            actual_ident = actual_ident->next;
        }
    }

    // Imprimir listado de literales cadena
    printf("\n* Listado de literales cadena encontrados:\n");
    LiteralCadena *actual_literal = lista_literales_cadena;
    if (!actual_literal) {
        printf("-\n");
    } else {
        while (actual_literal) {
            printf("\"%s\": longitud %d\n", actual_literal->literal, actual_literal->length);
            actual_literal = actual_literal->next;
        }
    }

    // Imprimir listado de palabras reservadas
    printf("\n* Listado de palabras reservadas (tipos de dato):\n");
    PalabraReservada *actual_palabra = lista_palabras_reservadas;
    int found = 0;
    while (actual_palabra) {
        if (strcmp(actual_palabra->tipo, "tipos de dato") == 0) {
            printf("%s: linea %d, columna %d\n", actual_palabra->palabra, actual_palabra->linea, actual_palabra->columna);
            found = 1;
        }
        actual_palabra = actual_palabra->next;
    }
    if (!found) printf("-\n");

    printf("\n* Listado de palabras reservadas (estructuras de control):\n");
    actual_palabra = lista_palabras_reservadas;
    found = 0;
    while (actual_palabra) {
        if (strcmp(actual_palabra->tipo, "estructuras de control") == 0) {
            printf("%s: linea %d, columna %d\n", actual_palabra->palabra, actual_palabra->linea, actual_palabra->columna);
            found = 1;
        }
        actual_palabra = actual_palabra->next;
    }
    if (!found) printf("-\n");

    printf("\n* Listado de palabras reservadas (otros):\n");
    actual_palabra = lista_palabras_reservadas;
    found = 0;
    while (actual_palabra) {
        if (strcmp(actual_palabra->tipo, "otros") == 0) {
            printf("%s: linea %d, columna %d\n", actual_palabra->palabra, actual_palabra->linea, actual_palabra->columna);
            found = 1;
        }
        actual_palabra = actual_palabra->next;
    }
    if (!found) printf("-\n");

    // Imprimir listado de constantes enteras decimales
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

    // Imprimir listado de constantes hexadecimales
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

    // Imprimir listado de constantes octales
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

    // Imprimir listado de constantes reales
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

    // Imprimir listado de constantes caracteres
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

    // Imprimir listado de operadores/caracteres de puntuación
    printf("\n* Listado de operadores/caracteres de puntuación:\n");
    Operador *actual_operador = lista_operadores;
    if (!actual_operador) {
        printf("-\n");
    } else {
        while (actual_operador) {
            printf("%s: aparece %d veces\n", actual_operador->operador, actual_operador->count);
            actual_operador = actual_operador->next;
        }
    }

    // Imprimir listado de cadenas no reconocidas
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

/* La siguiente línea define explícitamente a yytext como un puntero a un caracter ( char* yytext; ). Ésta es la opción por defecto si no se pone nada. */
%pointer
/* Con la siguiente opción la función de análisis int yylex(void); se comporta como si en la sección de usuario existiera la función int yywrap(void) return 1; la cual devuelve verdadero (no-cero), haciendo que una vez que la función de análisis int yylex(void) reciba una indicación de EOF desde YY_INPUT, asuma que no hay nada más para analizar de yyin y finalice (haciendo un return 0;) */
%option noyywrap

/* Condiciones de arranque inclusivas */
/* %s */
/* Condiciones de arranque exclusivas */
/* %x */

/* Declaraciones con cada nombre y su definición; se utilizan para simplificar las reglas */
/* digito [0-9] */

/* Fin de la sección de definiciones */

/* Inicio de la sección de reglas. Aquí: */
/* 1. Cualquier texto sangrado o encerrado entre '%{' y '%}' (estos últimos dos sin sangrar en líneas ocupadas únicamente por ellos) se copia íntegramente al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */
/* Esto podría utilizarse para declarar variables que son locales a la rutina de análisis léxico y (después de las declaraciones) al código que debe ejecutarse siempre que se entra a la rutina de análisis léxico */
/* 2. NO pueden hacerse comentarios sin sangría, ya que estos no se copian literalmente al archivo de salida del analizador léxico (scanner) generado (*.lex.yy.c) */
%%

[1-9][0-9]+[uU]?[lL]{0,2} {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    agregar_constante_decimal(&lista_constantes_decimales, yytext)
}
0[0-7]+[uU]?[lL]{0,2} {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    agregar_constante_octal(&lista_constantes_octales, yytext, atoi(yytext)) 
}
0[xX][0-9a-fA-F]+[uU]?[lL]{0,2} {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    agregar_constante_hexadecimal(&lista_constantes_hexadecimales, yytext, atoi(yytext)) 
}
[+-]?([0-9]*\.[0-9]+([eE][+-]?[0-9]+)?|[0-9]+\.([eE][+-]?[0-9]+)?) [fFlL]? {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    agregar_constante_real(&lista_constantes_reales, yytext)
}
\'[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?`~]\' {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    agregar_constante_caracter(&lista_constantes_caracter, yytext)
}
\"([^"\\\n]|\\[abfnrtv\\'"?]|\\[0-7]{1,3}|\\x[0-9a-fA-F]+)*\" {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    agregar_literal_cadena(&lista_literales_cadena, yytext, strlen(yytext))
}
(char|double|enum|float|int|long|short|struct|union|void) {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    /*REVISAR TEMA LINEA, COLUMNAS Y COMO MANEJAR EL TIPO DE PALABRA RESERVADA*/
    agregar_palabra_reservada(&lista_palabras_reservadas, yytext, int linea, int columna, const char *tipo)
} 
(break|case|continue|default|do|else|for|goto|if|return|switch|while) {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    /*REVISAR TEMA LINEA, COLUMNAS Y COMO MANEJAR EL TIPO DE PALABRA RESERVADA*/
    agregar_palabra_reservada(&lista_palabras_reservadas, yytext, int linea, int columna, const char *tipo)
} 
(auto|const|extern|register|signed|sizeof|static|typedef|unsigned|volatile) {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    /*REVISAR TEMA LINEA, COLUMNAS Y COMO MANEJAR EL TIPO DE PALABRA RESERVADA*/
    agregar_palabra_reservada(&lista_palabras_reservadas, yytext, int linea, int columna, const char *tipo)
} 
[_a-zA-Z][_a-zA-Z0-9]* {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    agregar_identificador(&lista_identificadores, yytext)
}
[(){}\[\];,.:]|[\+\-\*/%]|[\=\+\=\-\=\*\=\%\=]|[\=\=|\!\=|\>\=|\<\=|\>\>|\<]|[\&\&|\|\||\!]|\[\&|\||\^|\~|\<\<|\>\>] {
    DEBUG_PRINT("Cadena reconocida: %s\n", yytext);
    agregar_operador(&lista_operadores, yytext)
}
.* {
    DEBUG_PRINT("Cadena no reconocida: %s\n", yytext);
    /*REVISAR TEMA LINEA Y COLUMNAS*/
    agregar_cadena_no_reconocida(&lista_cadenas_no_reconocidas, yytext, int linea, int columna)
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

int main(void)
{
    yylex();
    ordenar_listado_identificadores(&lista_identificadores);
    ordenar_listado_literales_cadena(&lista_literales_cadena);
    imprimir_reporte(lista_identificadores, lista_literales_cadena, lista_palabras_reservadas, lista_constantes_decimales, lista_constantes_hexadecimales, lista_constantes_octales, lista_constantes_reales, lista_constantes_caracter, lista_operadores, lista_cadenas_no_reconocidas);
    liberar_memoria(&lista_identificadores, &lista_literales_cadena, &lista_palabras_reservadas, &lista_constantes_decimales, &lista_constantes_hexadecimales, &lista_constantes_octales, &lista_constantes_reales, &lista_constantes_caracter, &lista_operadores, &lista_cadenas_no_reconocidas);
    return 0;
}

/* Fin de la sección de código de usuario */
