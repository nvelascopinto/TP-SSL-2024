#ifndef GENERAL_H
#define GENERAL_H

/* En los archivos de cabecera (header files) (*.h) poner DECLARACIONES (evitar DEFINICIONES) de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

//Tipos de listas
typedef struct Syntax_Error {
    char *cadena;
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
    char* tipo_dato;
    int linea;
} t_variable;

//Prototipos de funciones

void inicializarUbicacion();
void agregar_variable_declarada(VariableDeclarada **lista_variables_declaradas, const char *nombre, const char *tipo_dato, int linea);
void agregar_sentencia(Sentencia **lista_sentencias, const char *nombre, int linea, int columna);
void agregarParametro(Parametro **lista_parametros, const char *tipo_dato,const char *identificador);
void agregarFuncion(Funcion **lista_funciones, char *nombre, char *tipoRetorno, Parametro *lista_parametros, int linea, int esDefinicion);
void agregar_error_sintactico(Syntax_Error **syntax_error_list, const char *cadena, int linea);
void agregar_cadena_no_reconocida(CadenaNoReconocida **lista_cadenas_no_reconocidas, const char *cadena, int linea, int columna);
void imprimir_reporte(VariableDeclarada *lista_variables_declaradas, Funcion *lista_funciones, Sentencia *lista_sentencias, Syntax_Error *lista_errores_sintacticos, CadenaNoReconocida *lista_cadenas_no_reconocidas);
void liberar_memoria(VariableDeclarada **lista_variables_declaradas,Sentencia **lista_sentencias,Funcion **lista_funciones,Syntax_Error **syntax_error_list,CadenaNoReconocida **lista_cadenas_no_reconocidas);
void liberar_memoria_parametros(Parametro **lista_parametros);

#endif