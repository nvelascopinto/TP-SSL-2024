#include "lists-nodes.h"

void aniadir_a_lista(t_lista* lista, void* dato){
    list *nuevo = malloc(sizeof(list));
    nuevo->next = NULL;
    nuevo->data = dato;
    list** iterador = &(lista->lista);
    while((*iterador) != NULL){
            iterador = &((*iterador)->next);
    } 
    *iterador = nuevo;
    lista->size++;
}

void* conseguir_de_lista(t_lista lista, unsigned int posicion){
    if(posicion > lista.size){
        printf("error");
        exit(3);
    }
    list* iterador = lista.lista;
    for(int i = 1;i<posicion;i++){
        iterador = iterador->next;
    }
    return iterador->data;
}

t_nodo* crear_nodo(char* text){
    t_nodo* nodo = malloc(sizeof(t_nodo));
    nodo->text = text;
    nodo->hijos.lista = NULL; nodo->hijos.size = 0;
    return nodo;
}

void aniadir_hijo(t_nodo* hijo,t_nodo* padre){
    aniadir_a_lista(&(padre->hijos), hijo);
}

void aniadir_hijo_nuevo_nodo(char* texto, t_nodo* padre){
    aniadir_a_lista(&(padre->hijos), crear_nodo(texto));
}

void recorrer(t_nodo* nodo){
    list* iterador = nodo->hijos.lista;
    int i = 1;
    if(iterador != NULL){
        recorrer((t_nodo*)conseguir_de_lista(nodo->hijos,i));
        iterador = iterador->next;
        i++;
    }
    while(iterador != NULL){
        printf(" ");
        recorrer((t_nodo*)conseguir_de_lista(nodo->hijos,i));
        iterador = iterador->next;
        i++;
    }
    if(nodo->text != NULL){
        printf("%s", nodo->text);
    }
}