#ifndef GENERAL_H
#define GENERAL_H
#include "lists-nodes.h"

/* En los archivos de cabecera (header files) (*.h) poner DECLARACIONES (evitar DEFINICIONES) de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

//Tipos de listas
typedef struct Syntax_Error {
    t_nodo *nodo;
    int linea;
    struct Syntax_Error *next;
} Syntax_Error;

typedef struct CadenaNoReconocida {
    char *cadena;
    int linea;
    int columna;
    struct CadenaNoReconocida *next;
} CadenaNoReconocida;

typedef struct VariableDeclarada {
    char *nombre;
    char *tipo_dato;
    int linea;
    struct VariableDeclarada *next;
} VariableDeclarada;

typedef struct Sentencia {
    char *nombre;
    int linea;
    int columna;
    struct Sentencia *next;
} Sentencia;

typedef struct Parametro {
    char *tipo_dato;
    char *identificador;
    struct Parametro *next;
} Parametro;

typedef struct Funcion {
    char *nombre;
    char *tipoRetorno;
    Parametro *parametros;
    int linea;
    int esDefinicion;
    struct Funcion *next;
} Funcion; 

typedef struct t_lugar{
    unsigned int linea;
    unsigned int columna;
} t_lugar;

typedef struct t_variable{
    char* identificador;
    unsigned int linea;
} t_identificador;


extern VariableDeclarada *lista_variables_declaradas;
extern VariableDeclarada *lista_variables_declaradas_b;
extern Funcion *lista_funciones;
extern Parametro *lista_parametros;
extern Sentencia *lista_sentencias;
extern Syntax_Error *lista_errores_sintacticos ;
extern CadenaNoReconocida *lista_cadenas_no_reconocidas;

//Prototipos de funciones

void inicializarUbicacion();
void agregar_variable_declarada(const char *nombre, const char *tipo_dato, int linea);
void agregar_variable_declarada_b(const char *nombre, int linea);
void agregar_variables(char* tipo, int linea);
void agregar_sentencia(const char *nombre, int linea, int columna);
void agregarParametro(char* tipo,const char *identificador);
void agregarFuncion(char *nombre, char *tipoRetorno, int linea, int esDefinicion);
void agregar_error_sintactico(t_nodo*cadena, int linea);
void agregar_cadena_no_reconocida(const char *cadena, int linea, int columna);
void imprimir_reporte();
void liberar_memoria(VariableDeclarada **lista_variables_declaradas,Sentencia **lista_sentencias,Funcion **lista_funciones,Syntax_Error **syntax_error_list,CadenaNoReconocida **lista_cadenas_no_reconocidas);
void liberar_memoria_parametros(Parametro **lista_parametros);

#endif