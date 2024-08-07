#ifndef ANALIZADOR_H
#define ANALIZADOR_H

// Estructuras de datos

typedef struct Identificador {
    char *identificador;
    int count;
    struct Identificador *next;
} Identificador;

typedef struct LiteralCadena {
    char *literal;
    int length;
    struct LiteralCadena *next;
} LiteralCadena;

typedef struct PalabraReservada {
    char *palabra;
    int linea;
    int columna;
    char *tipo; //REVISAR
    struct PalabraReservada *next;
} PalabraReservada;

typedef struct ConstanteDecimal {
    int valor;
    struct ConstanteDecimal *next;
} ConstanteDecimal;

typedef struct ConstanteHexadecimal {
    char *valor_hex;
    int valor_decimal;
    struct ConstanteHexadecimal *next;
} ConstanteHexadecimal;

typedef struct ConstanteOctal {
    char *valor_octal;
    int valor_decimal;
    struct ConstanteOctal *next;
} ConstanteOctal;

typedef struct ConstanteReal {
    char *valor_real;
    double parte_entera;
    double mantisa;
    struct ConstanteReal *next;
} ConstanteReal;

typedef struct ConstanteCaracter {
    char *valor_caracter;
    struct ConstanteCaracter *next;
} ConstanteCaracter;

typedef struct Operador {
    char *operador;
    int count;
    struct Operador *next;
} Operador;

typedef struct CadenaNoReconocida {
    char *cadena;
    int linea;
    int columna;
    struct CadenaNoReconocida *next;
} CadenaNoReconocida;

// Declaración de funciones

void agregar_identificador(Identificador **lista_identificadores, const char *identificador);
void agregar_literal_cadena(LiteralCadena **lista_literales_cadena, const char *literal, int length);
void agregar_palabra_reservada(PalabraReservada **lista_palabras_reservadas, const char *palabra, int linea, int columna, const char *tipo);
void agregar_constante_decimal(ConstanteDecimal **lista_constantes_decimales, int valor);
void agregar_constante_hexadecimal(ConstanteHexadecimal **lista_constantes_hexadecimales, const char *valor_hex, int valor_decimal);
void agregar_constante_octal(ConstanteOctal **lista_constantes_octales, const char *valor_octal, int valor_decimal);
void agregar_constante_real(ConstanteReal **lista_constantes_reales, const char *valor_real);
void agregar_constante_caracter(ConstanteCaracter **lista_constantes_caracter, const char *valor_caracter);
void agregar_operador(Operador **lista_operadores, const char *operador);
void agregar_cadena_no_reconocida(CadenaNoReconocida **lista_cadenas_no_reconocidas, const char *cadena, int linea, int columna);
void insertar_ordenado(Identificador **lista_identificadores, Identificador *nuevo);
void ordenar_listado_identificadores(Identificador **lista_identificadores);
void ordenar_listado_literales_cadena(LiteralCadena **lista_literales_cadena);
void liberar_memoria(Identificador **lista_identificadores,LiteralCadena **lista_literales_cadena,PalabraReservada **lista_palabras_reservadas,ConstanteDecimal **lista_constantes_decimales,ConstanteHexadecimal **lista_constantes_hexadecimales,ConstanteOctal **lista_constantes_octales,ConstanteReal **lista_constantes_reales,ConstanteCaracter **lista_constantes_caracter,Operador **lista_operadores,CadenaNoReconocida **lista_cadenas_no_reconocidas);
void imprimir_reporte(Identificador *lista_identificadores,LiteralCadena *lista_literales_cadena,PalabraReservada *lista_palabras_reservadas,ConstanteDecimal *lista_constantes_decimales,ConstanteHexadecimal *lista_constantes_hexadecimales,ConstanteOctal *lista_constantes_octales,ConstanteReal *lista_constantes_reales,ConstanteCaracter *lista_constantes_caracter,Operador *lista_operadores,CadenaNoReconocida *lista_cadenas_no_reconocidas);

#endif // ANALIZADOR_H