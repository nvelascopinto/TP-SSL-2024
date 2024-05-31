#include <stdlib.h>
#include <stdio.h>

#define CANT_ESTADOS 7
#define CANT_SIMBOLOS 6

// Definición de los estados del AFD
typedef enum
{
    Q0,
    Q1,
    Q2,
    Q3,
    Q4,
    Q5,
    Qr

} t_estado;

typedef enum
{
    CARACTER_CERO,
    CARACTER_ENTRE_UNO_SIETE,
    CARACTER_ENTRE_OCHO_NUEVE,
    CARACTER_LETRA_ENTRE_A_F,
    CARACTER_X,
    OTRO_CARACTER

} t_tipo_simbolo;

#define ESTADO_INICIAL Q0
#define CENTINELA ','

// Definición de la tabla de transiciones
t_estado tabla_transiciones[CANT_ESTADOS][CANT_SIMBOLOS] = {
    {Q2, Q1, Q1, Qr, Qr, Qr},
    {Q1, Q1, Q1, Qr, Qr, Qr},
    {Q3, Q3, Qr, Qr, Q4, Qr},
    {Q3, Q3, Qr, Qr, Qr, Qr},
    {Q5, Q5, Q5, Q5, Qr, Qr},
    {Q5, Q5, Q5, Q5, Qr, Qr},
    {Qr, Qr, Qr, Qr, Qr, Qr}};

t_tipo_simbolo identificarSimbolo(char caracter)
{

    switch (caracter)
    {
    case '0':
        return CARACTER_CERO;
        break;
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
        return CARACTER_ENTRE_UNO_SIETE;
        break;
    case '8':
    case '9':
        return CARACTER_ENTRE_OCHO_NUEVE;
        break;
    case 'a':
    case 'b':
    case 'c':
    case 'd':
    case 'e':
    case 'f':
    case 'A':
    case 'B':
    case 'C':
    case 'D':
    case 'E':
    case 'F':
        return CARACTER_LETRA_ENTRE_A_F;
        break;
    case 'x':
    case 'X':
        return CARACTER_X;
        break;
    default:
        return OTRO_CARACTER;
        break;
    }
}

void indicarTipoPalabra(t_estado estado, FILE *output)
{
    fputs("    ", output);
    switch (estado)
    {
    case Q1:
        fputs("DECIMAL\n", output);
        break;

    case Q2:
        fputs("OCTAL\n", output);
        break;

    case Q3:
        fputs("OCTAL\n", output);
        break;

    case Q5:
        fputs("HEXADECIMAL\n", output);
        break;

    default:
        fputs("NO RECONOCIDA\n", output);
        break;
    }
}

// Lee caracter a caracter de un archivo de entrada y aplica la funcion de transición hasta encontrar un centinela o EOF, después empieza de nuevo con la siguiente palabra
// y va escribiendo cada una en un archivo de salida hasta finalizar.
void clasificarPalabras (FILE *input, FILE *output)
{
    char c;
    t_estado estado = ESTADO_INICIAL;
    while ((c = fgetc(input)) != EOF)
    {
        if (c != CENTINELA)
        {
            fputc(c, output);
            estado = tabla_transiciones[estado][identificarSimbolo(c)];
        }
        else
        {
            indicarTipoPalabra(estado, output);
            estado = ESTADO_INICIAL;
        }
    }
    indicarTipoPalabra(estado, output);
}

int main(int argc, char *argv[])
{

    FILE *archivoEntrada = fopen("entrada.txt", "r");

    FILE *archivoSalida = fopen("salida.txt", "w");

    clasificarPalabras(archivoEntrada, archivoSalida);

    fclose(archivoEntrada);
    fclose(archivoSalida);

    return EXIT_SUCCESS;
}