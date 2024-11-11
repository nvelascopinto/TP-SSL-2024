#ifndef GENERAL_H
#define GENERAL_H
#include "lists-nodes.h"

/* En los archivos de cabecera (header files) (*.h) poner DECLARACIONES (evitar DEFINICIONES) de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

#define TYP_VAR 0
#define TYP_FNCT_DECL 1
#define TYP_FNCT_DEF 2
#define TYP_FNCT_DEFERROR 3

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
    unsigned int linea;
    unsigned int columna;
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
    unsigned int columna;       // Agrego columna
} t_identificador;

extern VariableDeclarada *lista_variables_declaradas;
extern VariableDeclarada *lista_variables_declaradas_b;
extern Sentencia *lista_sentencias;
extern Syntax_Error *lista_errores_sintacticos ;
extern CadenaNoReconocida *lista_cadenas_no_reconocidas;
extern t_lista lista_errores_semanticos;

typedef enum {
    e_char,
    e_double,
    e_enum,
    e_float,
    e_int,
    e_void,
    e_struct,
    e_union,
    e_cadena //char *
} especificador_tipo_dato;

typedef enum {
    e_signed,
    e_unsigned
} especificador_tipo_signed;

typedef enum {
    e_short,
    e_long
} especificador_tipo_long;

typedef enum {
    e_auto,
    e_extern,
    e_register,
    e_static,
    e_typedef
} especificador_almacenamiento;

typedef enum {
    e_const,
    e_volatile,
    e_const_and_volatile
} calificador_tipo;

typedef struct {
    especificador_tipo_dato especificador_tipo_dato;
    especificador_tipo_signed especificador_tipo_signed;
    especificador_tipo_long especificador_tipo_long;
    especificador_almacenamiento especificador_almacenamiento;
    calificador_tipo calificador_tipo;
    t_lista listaParametros;
    int EsPunteroFuncion;
} t_especificadores;

typedef struct {
    t_especificadores especificadores;
    unsigned int linea;
    unsigned int columna;
    char* identificador;
} t_parametro;

typedef enum {
    CONTROL_TIPO_DATOS, 
    //declaracion simbolos
    NO_DECLARACION_EXPRESION,
    REDECLARACION_SIMBOLO_DIFERENTE, 
    REDECLARACION_TIPO_DIFERENTE,
    REDECLARACION_TIPO_DIFERENTE_DEF_FUNCION,
    REDEFINICION_TIPO_IGUAL_VARIABLE,
    REDEFINICION_TIPO_IGUAL_FUNCION,
    //invocacion funciones
    NO_DECLARACION_FUNCION,
    INVOCACION_INVALIDA, 
    MENOS_ARGUMENTOS,
    MAS_ARGUMENTOS, 
    PARAMETROS_INCOMPATIBLES, //nicole 
    NO_IGNORA_VOID, 
    //validacion de asignacion
    INCOMPATIBILIDAD_TIPOS, 
    SOLO_LECTURA, 
    VALORL_NO_MODIFICABLE, 
    //validacion return
    NO_RETORNA,
    RETORNO_INCOMPATIBLE //exe
} codigo_error_semantico;

typedef struct {
    codigo_error_semantico codigo_error;
    char* identificador;
    t_especificadores espeL;
    t_especificadores espeR;
    unsigned int lineaA;
    unsigned int columnaA;
    unsigned int lineaB;
    unsigned int columnaB;
    unsigned int num_argumento;
} t_error_semantico;

typedef struct {
    unsigned int columnaComienzo;
    int EsModificable;
    t_especificadores especificadores;
} t_nodo_expresion;

typedef struct {
    unsigned int columna;
    unsigned int linea;
    char* valor;
} t_nodo_token;

t_especificadores crear_inicializar_especificador(void);
void conseguir_especificadores(t_nodo* nodo, t_especificadores* espe);

typedef struct symrec
{
  char *name;
  int type; //tres tipos: Variable (TYP_VAR) o Función (TYP_FNCT)
  unsigned int linea;
  unsigned int columna;
  t_especificadores especificadores;   
  struct symrec *next; //Puntero al siguiente nodo de la lista
} symrec;

extern symrec *sym_table;
symrec *putsym (char const *, int,t_especificadores,unsigned int,unsigned int);
symrec *getsym (char const *);
symrec *getsym_definicion(char const *sym_name);
symrec *getsym_declaracion(char const *sym_name);

//Prototipos de funciones

void inicializarUbicacion();
t_especificadores crear_inicializar_especificador(void);
int comparar_especificadores(t_especificadores, t_especificadores);
int contar_argumentos_listaArgumentos(t_nodo *nodo);
void agregar_variable_declarada(const char *nombre, const char*,unsigned int linea, unsigned int columna);
void agregar_variable_declarada_b(const char *nombre, unsigned int linea, unsigned int columna);
void agregar_variables(t_nodo* nodo);
void agregar_sentencia(const char *nombre, int linea, int columna);
void agregar_error_sintactico(t_nodo*cadena, int linea);
void agregar_cadena_no_reconocida(const char *cadena, int linea, int columna);
void imprimir_reporte();
void liberar_memoria(VariableDeclarada **lista_variables_declaradas,Sentencia **lista_sentencias,Syntax_Error **syntax_error_list,CadenaNoReconocida **lista_cadenas_no_reconocidas);
void liberar_memoria_parametros(Parametro **lista_parametros);

#endif