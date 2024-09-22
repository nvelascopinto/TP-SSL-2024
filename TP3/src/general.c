/* En los archivos (*.c) se pueden poner tanto DECLARACIONES como DEFINICIONES de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#include <stdio.h>

#include "general.h"

//extern YYLTYPE yylloc;

void inicializarUbicacion(void)
{
    yylloc.first_line = yylloc.last_line = INICIO_CONTEO_LINEA;
    yylloc.first_column = yylloc.last_column = INICIO_CONTEO_COLUMNA;
}

void agregar_variable_declarada(VariableDeclarada **lista_variables_declaradas, const char *nombre, const char *tipo_dato int linea){
    VariableDeclarada *nuevo = (VariableDeclarada *)malloc(sizeof(VariableDeclarada));
    nuevo->nombre = strdup(nombre);
    nuevo->tipo_dato = strdup(tipo_dato);
    nuevo->linea = linea;
    nuevo->next = NULL;

    if (*lista_variables_declaradas == NULL) {
        *lista_variables_declaradas = nuevo;
    } else {
        VariableDeclarada *actual = *lista_variables_declaradas;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_error_sintactico(Syntax_Error **syntax_error_list, const char *cadena, int linea){
    Syntax_Error *nuevo = (Syntax_Error *)malloc(sizeof(Syntax_Error));
    nuevo->cadena = strdup(cadena);
    nuevo->linea = linea;
    nuevo->next = NULL;

    if (*syntax_error_list == NULL) {
        *syntax_error_list = nuevo;
    } else {
        Syntax_Error *actual = *syntax_error_list;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
}

void agregar_sentencia(Sentencia **lista_sentencias, const char *nombre, int linea, int columna){
    Sentencia *nuevo = (Sentencia *)malloc(sizeof(Sentencia));
    nuevo->nombre = strdup(nombre);
    nuevo->linea = linea;
    nuevo->columna = columna;
    nuevo->next = NULL;

    if (*lista_sentencias == NULL) {
        *lista_sentencias = nuevo;
    } else {
        Sentencia *actual = *lista_sentencias;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
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

void imprimir_reporte(VariableDeclarada *lista_variables_declaradas, Funciones *lista_funciones, Sentencia *lista_sentencias, Syntax_Error *lista_errores_sintacticos, CadenaNoReconocida *lista_cadenas_no_reconocidas) {

    printf("* Listado de variables declaradas (tipo de dato y numero de linea):\n");
    VariableDeclarada *actual_variable_declarada = lista_variables_declaradas;
    if (!actual_variable_declarada){
        printf("-\n");
    }
    else{
        while (actual_variable_declarada){
            printf("%s: %s, linea %d\n", actual_variable_declarada->nombre, actual_variable_declarada->tipo_dato,actual_variable_declarada->linea);
            actual_variable_declarada = actual_variable_declarada -> next; 
        }
    }

    printf("\n* Listado de funciones declaradas o definidas:\n");
    //NOMBRE_FUNCION: (definicion o declaracion), input: TIPO_DATO IDENTIFICADOR, TIPO_DATO IDENTIFICADOR, retorna: TIPO_DATO, LINEA
    printf("\n* Listado de sentencias indicando tipo, numero de linea y de columna:\n");
    Sentencia *actual_sentencia = lista_sentencias;
    if (!actual_sentencia) {
        printf("-\n");
    } else {
        while (actual_sentencia) {
            printf("%s: linea %d, columna %d\n", actual_sentencia->nombre, actual_sentencia->linea, actual_sentencia->columna);
            actual_sentencia = actual_sentencia->next;
        }
    }

    printf("\n* Listado de estructuras sintácticas no reconocidas\n");
    Syntax_Error *actual_error_sintactico = lista_errores_sintacticos;
    if (!actual_error_sintactico) {
        printf("-\n");
    } else {
        while (actual_error_sintactico) {
            printf("\"%s\": linea %d\n", actual_error_sintactico->cadena, actual_error_sintactico->linea);
            actual_error_sintactico = actual_error_sintactico->next;
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

/* void agregarFuncion(Funcion **lista_funciones, char *nombre, char *tipoRetorno, Parametro *lista_parametros, int linea, bool esDefinicion) {
    Funcion *nuevaFuncion = malloc(sizeof(Funcion));
    nuevaFuncion->nombre = strdup(nombre);
    nuevaFuncion->tipoRetorno = strdup(tipoRetorno);
    nuevaFuncion->parametros = malloc(sizeof(Parametro));
    nuevaFuncion->linea = linea;
    nuevaFuncion->esDefinicion = esDefinicion;

    while (nuevaFuncion->parametros){

    }
}

void agregarParametro(Parametro **lista_parametros, const char *tipo_dato,const char *identificador ){
    Parametro *nuevo = (Parametro *)malloc(sizeof(Parametro));
    nuevo->tipo_dato = strdup(tipo_dato);
    nuevo->identificador = identificador;
    nuevo->next = NULL;

    if (*lista_parametros == NULL) {
        *lista_parametros = nuevo;
    } else {
        CadenaNoReconocida *actual = *lista_parametros;
        while (actual->next != NULL) {
            actual = actual->next;
        }
        actual->next = nuevo;
    }
} */
/* 
symrec *sym_table = NULL; 

symrec *putsym (char const *sym_name, int sym_type)
{
  symrec *ptr = (symrec *) malloc (sizeof (symrec));
  ptr->name = (char *) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name,sym_name);
  ptr->type = sym_type;
  ptr->next = (struct symrec *)sym_table;
  sym_table = ptr;
  return ptr;
}

symrec *getsym (char const *sym_name)
{
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *) 0;
       ptr = (symrec *)ptr->next)
    if (strcmp (ptr->name, sym_name) == 0)
      return ptr;
  return 0;
} */