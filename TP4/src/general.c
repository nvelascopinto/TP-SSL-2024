/* En los archivos (*.c) se pueden poner tanto DECLARACIONES como DEFINICIONES de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "general.h"
#include <string.h>

symrec *sym_table = NULL;
symrec *putsym (char const *sym_name, int sym_type, t_especificadores especificadores,unsigned int linea, unsigned int columna)
{
  symrec *ptr = (symrec *) malloc (sizeof (symrec));
  ptr->name = (char *) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name,sym_name);
  ptr->type = sym_type;
  ptr->especificadores = especificadores;
  ptr->linea = linea;
  ptr->columna = columna;
  ptr->next = NULL;
  symrec** iterador = &sym_table;
  while((*iterador)!=NULL){
    iterador = &((*iterador)->next);
  }
  *iterador = ptr;
  return ptr;
}

symrec *getsym (char const *sym_name)
{
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *) 0;
       ptr = (symrec *)ptr->next){
    if (strcmp (ptr->name, sym_name) == 0)
      return ptr;
    list* aux_lista = ptr->especificadores.listaParametros.lista;
    t_parametro* aux_parametro;
    while(aux_lista != NULL){
        aux_parametro = (t_parametro*)aux_lista->data;
        if(aux_parametro->identificador != NULL)
        if(strcmp (aux_parametro->identificador, sym_name) == 0)
            return aux_parametro;
        aux_lista = aux_lista->next;
    }
   }
  return 0;
}

symrec *getsym_definicion(char const *sym_name)
{
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *) 0;
       ptr = (symrec *)ptr->next)
    if ((strcmp (ptr->name, sym_name) == 0) && (ptr->type == TYP_FNCT_DEF))
      return ptr;
  return 0;

}

t_especificadores crear_inicializar_especificador(void){
    t_especificadores aux1;
    aux1.listaParametros.size = 0;
    aux1.listaParametros.lista = NULL;
    aux1.calificador_tipo = -1;
    aux1.especificador_almacenamiento = -1;
    aux1.especificador_tipo_dato = -1;
    aux1.especificador_tipo_long = -1;
    aux1.especificador_tipo_signed = -1;
    aux1.EsPunteroFuncion = -1;
    return aux1;
}

int comparar_especificadores(t_especificadores aux1, t_especificadores aux2){ //faltaria comparar parametros
    return (
    (aux1.listaParametros.size == aux2.listaParametros.size) && 
    (aux1.calificador_tipo == aux2.calificador_tipo) && 
    (aux1.especificador_almacenamiento == aux2.especificador_almacenamiento) &&
    (aux1.especificador_tipo_dato == aux2.especificador_tipo_dato) &&
    (aux1.especificador_tipo_long == aux2.especificador_tipo_long) &&
    (aux1.especificador_tipo_signed == aux2.especificador_tipo_signed)
    );
}

void conseguir_especificadores(t_nodo* nodo, t_especificadores* espe){
    int i = 1;
    while(i <= nodo->hijos.size){
        t_nodo* aux = (t_nodo*)conseguir_de_lista(nodo->hijos,i);
        switch(aux->tipo){
            case especificadores:
                conseguir_especificadores(aux, espe);
            break;
            case especificadorTipoDato:
                espe->especificador_tipo_dato = *(int*)(aux->data);
            break;
            case especificadorTipoSigned:
                espe->especificador_tipo_signed = *(int*)(aux->data);
            break;
            case especificadorTipoLong:
                espe->especificador_tipo_long = *(int*)(aux->data);
            break;
            case especificadorAlmacenamiento:
                espe->especificador_almacenamiento = *(int*)(aux->data);
            break;
            case calificadorTipo:
                espe->calificador_tipo = *(int*)(aux->data);
            break;
            case parametros:
                conseguir_especificadores(aux, espe);
            break;
            case parametro:
                t_parametro* para = malloc(sizeof(t_parametro));
                para->identificador = aux->text;
                para->especificadores = crear_inicializar_especificador();
                conseguir_especificadores(aux,&(para->especificadores));
                aniadir_a_lista(&(espe->listaParametros), para);
            break;
            case listaArgumentos:
                conseguir_especificadores(aux, espe);
            break;
            case expresion:
                t_nodo_expresion* aux_nodo = (t_nodo_expresion*)(aux->data);
                t_parametro* argumento = malloc(sizeof(t_parametro));
                argumento->especificadores = aux_nodo->especificadores;
                aniadir_a_lista(&(espe->listaParametros), argumento);
            break;
        }
        i++;
    }
}

int contar_hijos_postorden(t_nodo *nodo) {
    int cantidad_hijos = 0;
    list *iterador = nodo->hijos.lista;
    while (iterador != NULL) {
        t_nodo *hijo = (t_nodo *) iterador->data;
        cantidad_hijos += contar_hijos_postorden(hijo);
        iterador = iterador->next;
    }
    if (nodo->hijos.lista != NULL) {
        cantidad_hijos += 1; 
    }
    return cantidad_hijos;
}

VariableDeclarada *lista_variables_declaradas = NULL;
VariableDeclarada *lista_variables_declaradas_b = NULL;
Sentencia *lista_sentencias = NULL;
Syntax_Error *lista_errores_sintacticos = NULL;
t_lista lista_errores_semanticos;

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

void imprimir_tipo_dato(t_especificadores espe){ // seria mejor usar una matriz, uso este metodo porque ya lo tenia para testear
    switch(espe.especificador_tipo_signed){
        case e_unsigned:
        printf("unsigned ");
        break;
    }
    switch (espe.especificador_tipo_long){
        case e_long:
        printf("long");
        if(espe.especificador_tipo_dato!=-1) printf(" ");
        break;
    }
    switch(espe.calificador_tipo){
        case e_const:
        printf("const ");
        break;
        case e_volatile:
        printf("volatile ");
        break;
    }
    switch(espe.especificador_tipo_dato){
        case e_void:
        printf("void");
        break;
        case e_char:
        printf("char");
        break;
        case e_double:
        printf("double");
        break;
        case e_enum:
        printf("enum");
        break;
        case e_float:
        printf("float");
        break;
        case e_int:
        printf("int");
        break;
        case e_struct:
        printf("struct");
        break;
        case e_union:
        printf("union");
        break;
        case e_cadena:
        printf("char *");
        break;
    }
}

void imprimir_parametros(t_lista lista, int bool_identificador){ // seria mejor usar una matriz, uso este metodo porque ya lo tenia para testear
        list* iterador = lista.lista;
        t_parametro aux = *(t_parametro*)iterador->data;
        imprimir_tipo_dato(aux.especificadores);
        if(aux.identificador && bool_identificador)
        printf(" %s", aux.identificador);
        iterador = iterador->next;
        if(iterador)
        aux = *(t_parametro*)iterador->data;
        while(iterador!=NULL){
            printf(", ");
            imprimir_tipo_dato(aux.especificadores);
            if(aux.identificador && bool_identificador)
            printf(" %s", aux.identificador);
            iterador = iterador->next;
            if(iterador)
            aux = *(t_parametro*)iterador->data;
        }
}

void imprimir_parametros_sin_id(t_lista lista, int bool_identificador) {
        list* iterador = lista.lista;
        t_parametro aux = *(t_parametro*)iterador->data;
        imprimir_tipo_dato(aux.especificadores);
        if(aux.identificador && bool_identificador)
        iterador = iterador->next;
        if(iterador)
        aux = *(t_parametro*)iterador->data;
        while(iterador!=NULL){
            printf(", ");
            imprimir_tipo_dato(aux.especificadores);
            if(aux.identificador && bool_identificador)
            iterador = iterador->next;
            if(iterador)
            aux = *(t_parametro*)iterador->data;
        }
}

void imprimir_variable(t_especificadores especificador){
    imprimir_tipo_dato(especificador);
    if(especificador.listaParametros.size > 0){
        printf(" (*)(");
        imprimir_parametros(especificador.listaParametros, 1);
        printf(")");
    }
}

void imprimir_variable_sin_id(t_especificadores especificador){
    imprimir_tipo_dato(especificador);
    if(especificador.listaParametros.size > 0) {
        printf(" (*)(");
        imprimir_parametros_sin_id(especificador.listaParametros, 1);
        printf(")");
    }
}

void imprimir_declaracion(t_especificadores especificador){
    imprimir_tipo_dato(especificador);
    if(especificador.listaParametros.size > 0){
        printf("(");
        imprimir_parametros(especificador.listaParametros, 0);
        printf(")");
    }
}

void imprimir_solo_tipo_dato(t_especificadores espe){ 
    switch(espe.especificador_tipo_signed){
        case e_unsigned:
        printf("unsigned ");
        break;
    }
    switch (espe.especificador_tipo_long){
        case e_long:
        printf("long");
        if(espe.especificador_tipo_dato!=-1) printf(" ");
        break;
    }
    switch(espe.especificador_tipo_dato){
        case e_void:
        printf("void");
        break;
        case e_char:
        printf("char");
        break;
        case e_double:
        printf("double");
        break;
        case e_enum:
        printf("enum");
        break;
        case e_float:
        printf("float");
        break;
        case e_int:
        printf("int");
        break;
        case e_struct:
        printf("struct");
        break;
        case e_union:
        printf("union");
        break;
        case e_cadena:
        printf("char *");
        break;
    }
}


void agregar_variables(t_nodo* nodo){
    t_especificadores espe = crear_inicializar_especificador();
    conseguir_especificadores(nodo,&espe);
    VariableDeclarada *actual_variable_declarada = lista_variables_declaradas_b;
        while (actual_variable_declarada){
            if(!(getsym(actual_variable_declarada->nombre))){
                putsym(actual_variable_declarada->nombre,TYP_VAR,espe,actual_variable_declarada->linea, actual_variable_declarada->columna);
            }
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

void imprimir_error_semantico(t_error_semantico error){
    switch(error.codigo_error){
        case CONTROL_TIPO_DATOS:
        printf("%d:%d: Operandos invalidos del operador binario * (tienen '", error.lineaA, error.columnaA);imprimir_variable(error.espeL);printf("' y '");imprimir_variable(error.espeR);printf("')\n");
        break;
        case NO_DECLARACION_EXPRESION:
        printf("%d:%d: '%s' sin declarar\n", error.lineaA, error.columnaA,error.identificador);
        break;
        case REDECLARACION_SIMBOLO_DIFERENTE:
        printf("%d:%d: '%s' redeclarado como un tipo diferente de simbolo\nNota: la declaracion previa de '%s' es de tipo '", error.lineaA, error.columnaA, error.identificador, error.identificador); imprimir_declaracion(error.espeL);printf("': %d:%d\n",error.lineaB, error.columnaB);
        break;
        case REDECLARACION_TIPO_DIFERENTE:
        printf("%d:%d: conflicto de tipos para '%s'; la ultima es de tipo '",error.lineaA, error.columnaA, error.identificador); imprimir_declaracion(error.espeL);printf("'\nNota: la declaracion previa de '%s' es de tipo '", error.identificador); imprimir_declaracion(error.espeR);printf("': %d:%d\n", error.lineaB, error.columnaB);
        break;
        case REDEFINICION_TIPO_IGUAL_VARIABLE:
        printf("%d:%d: Redeclaracion de '%s'\n", error.lineaA, error.columnaA, error.identificador);
        printf("Nota: la declaracion previa de '%s' es de tipo '",error.identificador);
        imprimir_tipo_dato(error.espeL);
        printf("': %d:%d\n",error.lineaB, error.columnaB);
        break;
        case REDEFINICION_TIPO_IGUAL_FUNCION:
        printf("%d:%d: Redefinicion de '%s'\n", error.lineaA, error.columnaA, error.identificador);
        printf("Nota: la definicion previa de '%s' es de tipo '",error.identificador);
        imprimir_declaracion(error.espeL);
        printf("': %d:%d\n",error.lineaB, error.columnaB);
        break;
        case NO_DECLARACION_FUNCION:
        printf("%d:%d: Funcion '%s' sin declarar\n", error.lineaA, error.columnaA, error.identificador);
        break;
        case INVOCACION_INVALIDA:
        printf("%d:%d: El objeto invocado '%s' no es una funcion o un puntero a una funcion\n", error.lineaA, error.columnaA,error.identificador);
        printf("Nota: declarado aqui: %d:%d\n", error.lineaB, error.columnaB);
        break;
        case MENOS_ARGUMENTOS:
        printf("%d:%d: Insuficientes argumentos para la funcion '%s'\nNota: declarado aqui: %d:%d\n", error.lineaA, error.columnaA, error.identificador, error.lineaB, error.columnaB);
        break;
        case MAS_ARGUMENTOS:
        printf("%d:%d: Demasiados argumentos para la funcion '%s'\nNota: declarado aqui: %d:%d\n", error.lineaA, error.columnaA, error.identificador, error.lineaB, error.columnaB);
        break;
        case PARAMETROS_INCOMPATIBLES:
        printf("%d:%d: Incompatibilidad de tipos para el argumento %d", error.lineaA, error.columnaA, error.num_argumento);
        printf(" de '%s'\nNota: se esperaba '", error.identificador);
        imprimir_tipo_dato(error.espeL);
        printf("' pero el argumento es de tipo '");
        if(error.espeR.EsPunteroFuncion) {
            imprimir_variable_sin_id(error.espeR); 
        } else {
            imprimir_tipo_dato(error.espeR);  
        }
        printf("': %d:%d\n", error.lineaB, error.columnaB);
        break;
        case NO_IGNORA_VOID:
        printf("%d:%d: No se ignora el valor de retorno void como deberia ser\n", error.lineaA, error.columnaA);
        break;
        case INCOMPATIBILIDAD_TIPOS:
        printf("%d:%d: Incompatibilidad de tipos al inicializar el tipo '",error.lineaA,error.columnaA);
        imprimir_solo_tipo_dato(error.espeL);
        printf("' usando el tipo '");
        imprimir_variable(error.espeR);
        printf("'\n");
        break;
        case SOLO_LECTURA:
        printf("%d:%d: Asignacion de la variable de solo lectura '%s'\n", error.lineaA, error.columnaA, error.identificador);
        break;
        case VALORL_NO_MODIFICABLE:
        printf("%d:%d: Se requiere un valor-L modificable como operando izquierdo de la asignacion\n", error.lineaA, error.columnaA);        
        break;
        case NO_RETORNA:
        printf("%d:%d: La funcion debe devolver un valor\n", error.lineaA, error.columnaA);        
        break;
        case RETORNO_INCOMPATIBLE:
        printf("%d:%d: Incompatibilidad de tipos al retornar el tipo '",error.lineaA, error.columnaA);
        if(error.espeL.EsPunteroFuncion != 1){
            imprimir_tipo_dato(error.espeL);
        }
        else {
            imprimir_variable(error.espeL);
        }
        printf("' pero se esperaba '");
        imprimir_tipo_dato(error.espeR);
        printf("'\n");     
        break;
    }
}

void imprimir_reporte() {

    printf("* Listado de variables declaradas (tipo de dato y numero de linea):\n");
    symrec *iterador = sym_table;
    while (iterador!=NULL){
         if(iterador->type == TYP_VAR){
            printf("%s: ", iterador->name);imprimir_tipo_dato(iterador->especificadores);printf(", linea %d, columna %d\n", iterador->linea,iterador->columna);
         }
        iterador = iterador -> next; 
    }
    printf("\n* Listado de funciones declaradas y definidas:\n");
    iterador = sym_table;
    while (iterador!=NULL){
        if(iterador->type == TYP_FNCT_DECL || iterador->type == TYP_FNCT_DEF){
            printf("%s: ", iterador->name);
            if(iterador->type == TYP_FNCT_DEF){
                printf("definicion, input: ");
            }else{
                printf("declaracion, input: ");
            }
            imprimir_parametros(iterador->especificadores.listaParametros, 1);
            printf(", retorna: "); imprimir_tipo_dato(iterador->especificadores);
            printf(", linea %d\n", iterador->linea);
        }
        iterador = iterador -> next; 
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

    list* actual_error_semantico = lista_errores_semanticos.lista;
    while(actual_error_semantico!=NULL){
        imprimir_error_semantico(*(t_error_semantico*)actual_error_semantico->data);
        actual_error_semantico = actual_error_semantico->next;
    }

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

void liberar_memoria(VariableDeclarada **lista_variables_declaradas,Sentencia **lista_sentencias,Syntax_Error **syntax_error_list,CadenaNoReconocida **lista_cadenas_no_reconocidas){
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