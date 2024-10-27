/* En los archivos (*.c) se pueden poner tanto DECLARACIONES como DEFINICIONES de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "general.h"
#include <string.h>

VariableDeclarada *lista_variables_declaradas = NULL;
VariableDeclarada *lista_variables_declaradas_b = NULL;
Funcion *lista_funciones = NULL;
Parametro *lista_parametros = NULL;
Sentencia *lista_sentencias = NULL;
Syntax_Error *lista_errores_sintacticos = NULL;

void agregar_variable_declarada(const char *nombre, const char *tipo_dato, unsigned int linea, unsigned int columna){
    VariableDeclarada *nuevo = (VariableDeclarada *)malloc(sizeof(VariableDeclarada));
    nuevo->nombre = strdup(nombre);
    nuevo->tipo_dato = strdup(tipo_dato);
    nuevo->linea = linea;
    nuevo->columna = columna;
    nuevo->next = NULL;

    if (lista_variables_declaradas == NULL) {
        lista_variables_declaradas = nuevo;
    } else {
        VariableDeclarada *actual = lista_variables_declaradas;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_variable_declarada_b(const char *nombre, unsigned int linea, unsigned int columna){
    VariableDeclarada *nuevo = (VariableDeclarada *)malloc(sizeof(VariableDeclarada));
    nuevo->nombre = strdup(nombre);
    nuevo->tipo_dato = NULL;
    nuevo->linea = linea;
    nuevo->columna = columna;
    nuevo->next = NULL;

    if (lista_variables_declaradas_b == NULL) {
        lista_variables_declaradas_b = nuevo;
    } else {
        VariableDeclarada *actual = lista_variables_declaradas_b;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_variables(char* tipo, unsigned int linea, unsigned int columna){
    VariableDeclarada *actual_variable_declarada = lista_variables_declaradas_b;
        while (actual_variable_declarada){
            agregar_variable_declarada(actual_variable_declarada->nombre, tipo, linea, columna);
            actual_variable_declarada = actual_variable_declarada -> next;
        }
    lista_variables_declaradas_b = NULL;
}

void agregar_error_sintactico(t_nodo* nodo, int linea){
    Syntax_Error *nuevo = (Syntax_Error *)malloc(sizeof(Syntax_Error));
    nuevo->nodo = nodo;
    nuevo->linea = linea;
    nuevo->next = NULL;

    if (lista_errores_sintacticos == NULL) {
        lista_errores_sintacticos = nuevo;
    } else {
        Syntax_Error *actual = lista_errores_sintacticos;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregarFuncion(char *nombre, char *tipoRetorno, int linea, int esDefinicion) {
    Funcion *nuevo = (Funcion *)malloc(sizeof(Funcion));
    nuevo->nombre = strdup(nombre);
    nuevo->tipoRetorno = strdup(tipoRetorno);
    nuevo->parametros = lista_parametros;
    nuevo->linea = linea;
    nuevo->esDefinicion = esDefinicion;
    nuevo->next = NULL;

    if (lista_funciones == NULL) {
        lista_funciones = nuevo;
    } else {
        Funcion *actual = lista_funciones;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregarParametro(char* tipo,const char *identificador){
    Parametro *nuevo = (Parametro *)malloc(sizeof(Parametro));
    nuevo->tipo_dato = tipo;
    nuevo->identificador = strdup(identificador);
    nuevo->next = NULL;

    if (lista_parametros == NULL) {
        lista_parametros = nuevo;
    } else {
        Parametro *actual = lista_parametros;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_sentencia(const char *nombre, int linea, int columna){
    Sentencia *nuevo = (Sentencia *)malloc(sizeof(Sentencia));
    nuevo->nombre = strdup(nombre);
    nuevo->linea = linea;
    nuevo->columna = columna;
    nuevo->next = NULL;

    if (lista_sentencias == NULL) {
        lista_sentencias = nuevo;
    } else {
        Sentencia *actual = lista_sentencias;
        while (actual->next != NULL && actual->next->linea<nuevo->linea) {
            actual = actual->next;
        }
        if(actual->next != NULL){
            nuevo->next = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_cadena_no_reconocida(const char *cadena, int linea, int columna) {
    CadenaNoReconocida *nuevo = (CadenaNoReconocida *)malloc(sizeof(CadenaNoReconocida));
    nuevo->cadena = strdup(cadena);
    nuevo->linea = linea;
    nuevo->columna = columna;
    nuevo->next = NULL;

    if (lista_cadenas_no_reconocidas == NULL) {
        lista_cadenas_no_reconocidas = nuevo;
    } else {
        CadenaNoReconocida *actual = lista_cadenas_no_reconocidas;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void imprimir_reporte() {

    printf("* Listado de variables declaradas (tipo de dato y numero de linea):\n");
    VariableDeclarada *actual_variable_declarada = lista_variables_declaradas;
    if (!actual_variable_declarada){
        printf("-\n");
    }
    else{
        while (actual_variable_declarada){
            printf("%s: %s, linea %d, columna %d\n", actual_variable_declarada->nombre, actual_variable_declarada->tipo_dato,actual_variable_declarada->linea,actual_variable_declarada->columna);
            actual_variable_declarada = actual_variable_declarada -> next; 
        }
    }
    printf("\n* Listado de funciones declaradas o definidas:\n");
    Funcion *actual_funcion = lista_funciones;
    if (!actual_funcion){
        printf("-\n");
    }
    else {
        while (actual_funcion){
            printf("%s: ", actual_funcion->nombre);
            if(actual_funcion->esDefinicion == 1){
                printf("definicion");
            }else{
                printf("declaracion");
            }
            printf(", input:");
            Parametro* actual_parametro = actual_funcion->parametros;
            while(actual_parametro){
                printf(" %s",actual_parametro->tipo_dato, actual_parametro->identificador);
                if(strcmp(actual_parametro->identificador, "0")){printf(" %s", actual_parametro->identificador);}
                printf(",");
                actual_parametro = actual_parametro->next;
            }         
            printf(" retorna: %s, linea %d\n", actual_funcion->tipoRetorno, actual_funcion->linea);
            actual_funcion = actual_funcion -> next;
        }
    }

/*     printf("\n* Listado de sentencias indicando tipo, numero de linea y de columna:\n");
    Sentencia *actual_sentencia = lista_sentencias;
    if (!actual_sentencia) {
        printf("-\n");
    } else {
        while (actual_sentencia) {
            printf("%s: linea %d, columna %d\n", actual_sentencia->nombre, actual_sentencia->linea, actual_sentencia->columna);
            actual_sentencia = actual_sentencia->next;
        }
    } */
    printf("\n* Listado de errores semanticos:\n");

    //DESARROLLAR

    printf("\n* Listado de errores sintacticos:\n");
    Syntax_Error *actual_error_sintactico = lista_errores_sintacticos;
    if (!actual_error_sintactico) {
        printf("-\n");
    } else {
        while (actual_error_sintactico) {
            printf("\"");
            recorrer(actual_error_sintactico->nodo);
            printf("\"");
            printf(": linea %d\n", actual_error_sintactico->linea);
            actual_error_sintactico = actual_error_sintactico->next;
        }
    }

    printf("\n* Listado de errores lexicos:\n");
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

void liberar_memoria(VariableDeclarada **lista_variables_declaradas,Sentencia **lista_sentencias,Funcion **lista_funciones,Syntax_Error **syntax_error_list,CadenaNoReconocida **lista_cadenas_no_reconocidas){
    // Liberar memoria de la lista de variables declaradas
    VariableDeclarada *var_actual = *lista_variables_declaradas;
    while (var_actual != NULL) {
        VariableDeclarada *temp = var_actual;
        var_actual = var_actual->next;
        free(temp->nombre);
        free(temp->tipo_dato);
        free(temp);
    }
    *lista_variables_declaradas = NULL;

    // Liberar memoria de la lista de sentencias
    Sentencia *sent_actual = *lista_sentencias;
    while (sent_actual != NULL) {
        Sentencia *temp = sent_actual;
        sent_actual = sent_actual->next;
        free(temp->nombre);
        free(temp);
    }
    *lista_sentencias = NULL;

    // Liberar memoria de la lista de funciones
    Funcion *func_actual = *lista_funciones;
    while (func_actual != NULL) {
        Funcion *temp = func_actual;
        func_actual = func_actual->next;
        free(temp->nombre);
        free(temp->tipoRetorno);
        // Si hay parámetros, también sería necesario liberarlos (dependiendo de la estructura Parametro)
        free(temp);
    }
    *lista_funciones = NULL;

    // Liberar memoria de la lista de errores sintácticos
    Syntax_Error *error_actual = *syntax_error_list;
    while (error_actual != NULL) {
        Syntax_Error *temp = error_actual;
        error_actual = error_actual->next;
        free(temp);
    }
    *syntax_error_list = NULL;

    // Liberar memoria de la lista de cadenas no reconocidas
    CadenaNoReconocida *cadena_actual = *lista_cadenas_no_reconocidas;
    while (cadena_actual != NULL) {
        CadenaNoReconocida *temp = cadena_actual;
        cadena_actual = cadena_actual->next;
        free(temp->cadena);
        free(temp);
    }
    *lista_cadenas_no_reconocidas = NULL;
}

void liberar_memoria_parametros(Parametro **lista_parametros){
    Parametro *parametros_actuales = *lista_parametros;
    while (parametros_actuales != NULL) {
        Parametro *temp = parametros_actuales;
        parametros_actuales = parametros_actuales->next;
        free(temp->tipo_dato);
        free(temp->identificador);
        free(temp);
    }
    *lista_parametros = NULL;
}