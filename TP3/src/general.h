#ifndef GENERAL_H
#define GENERAL_H

/* En los archivos de cabecera (header files) (*.h) poner DECLARACIONES (evitar DEFINICIONES) de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#define YYLTYPE YYLTYPE

#define TYP_VAR 0
#define TYP_FNCT 1
#define TYP_STMT 2 // Sentencia

typedef struct YYLTYPE
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

symrec *getsym (char const *);

#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

void pausa(void);
void inicializarUbicacion(void);
void reinicializarUbicacion(void);

#endif