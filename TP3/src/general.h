#ifndef GENERAL_H
#define GENERAL_H

/* En los archivos de cabecera (header files) (*.h) poner DECLARACIONES (evitar DEFINICIONES) de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#define YYLTYPE YYLTYPE

#define TYP_VAR 0
#define TYP_FNCT 1
#define TYP_STMT 2 // Sentencia

//Lista para manejar errores sintácticos
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

// Manejo de funcion
/* typedef struct Parametro {
    char *tipo_dato;
    char *identificador;
} Parametro;

typedef struct Funcion {
    char *nombre;
    char *tipoRetorno;
    Parametro *parametros;
    int linea;
    bool esDefinicion;
    struct Funcion *siguiente;
} Funcion; */

/* typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;

typedef struct var_t 
{
  char *name;  
  char *type;
  int line;
} var_t;

typedef struct func_t 
{
  char *name;
  int is_definition;
  char **parameters;
  char *type;
  int line;
} func_t;

typedef struct sent_t 
{
  char *type;
  int line;
  int column;
} sent_t;

typedef struct symrec 
{
  char *name;
  int type;
  union 
  {
    var_t *var;
    func_t *fnct;
    sent_t *stmt;
  } value;
  struct symrec *next;
} symrec;

extern symrec *sym_table;

symrec *putsym (char const *, int);

symrec *getsym (char const *); */

#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

//void update_position(const char* text);
void inicializarUbicacion(void);
void agregar_variable_declarada(VariableDeclarada **lista_variables_declaradas, const char *nombre, const char *tipo_dato int linea);
void agregar_sentencia(Sentencia **lista_sentencias, const char *nombre, int linea, int columna);
void agregar_error_sintactico(Syntax_Error **syntax_error_list, const char *cadena, int linea);
void agregar_cadena_no_reconocida(CadenaNoReconocida **lista_cadenas_no_reconocidas, const char *cadena, int linea, int columna);
void imprimir_reporte(VariableDeclarada *lista_variables_declaradas, Funciones *lista_funciones, Sentencia *lista_sentencias, Syntax_Error *lista_errores_sintacticos, CadenaNoReconocida *lista_cadenas_no_reconocidas);
void liberar_memoria(VariableDeclarada **lista_variables_declaradas,Sentencia **lista_sentencias,Funciones **lista_funciones,Syntax_Error **syntax_error_list,CadenaNoReconocida **lista_cadenas_no_reconocidas);
#endif