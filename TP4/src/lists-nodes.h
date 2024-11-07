#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef struct list {
    void* data;
    struct list* next;
} list;

typedef struct {
    list* lista;
    unsigned int size;
} t_lista;

void aniadir_a_lista(t_lista*,void*);
void* conseguir_de_lista(t_lista, unsigned int);

typedef enum {
    expresion,
    especificadores,
    especificadorTipoDato,
    especificadorTipoSigned,
    especificadorTipoLong,
    especificadorAlmacenamiento,
    calificadorTipo,
    parametros,
    parametro,
    token,
    listaArgumentos,
    expAsignacion
} nodo_tipo;

typedef struct { //estan hechos solo para guardar los tokens, hay que modificar
    char* text;
    nodo_tipo tipo;
    void* data;
    t_lista hijos;
} t_nodo;

t_nodo* crear_nodo(nodo_tipo,char*,void*);
void aniadir_hijo(t_nodo*,t_nodo*);
void aniadir_hijo_nuevo_nodo(char*, t_nodo*);
void recorrer(t_nodo*);