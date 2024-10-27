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

typedef struct { //estan hechos solo para guardar los tokens, hay que modificar
    char* text;
    t_lista hijos;
} t_nodo;


void aniadir_a_lista(t_lista*,void*);
void* conseguir_de_lista(t_lista, unsigned int);
t_nodo* crear_nodo(char*);
void aniadir_hijo(t_nodo*,t_nodo*);
void aniadir_hijo_nuevo_nodo(char*, t_nodo*);
void recorrer(t_nodo*);