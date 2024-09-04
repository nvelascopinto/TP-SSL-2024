# TP2
## FLEX para reconocimiento de categorías léxicas de C

### Comentarios a considerar para la corrección del trabajo

- Se definió utilizar estructuras con almacenamiento dinámico (listas enlazadas) para poder cargar la información a medida que son leídas por el analizador.

Se define una lista enlazada para cada categoría léxica, la misma es actualizada a medida que se identifica un token. Las categorías léxicas reconocidas por el programa son:

- Constantes enteras con y sin sufijo:
  - Decimales
  - Octales
  - Hexadecimales
- Constantes reales con y sin sufijo
- Constantes caracter simples
- Constantes caracter con secuencia de escape:
  - Simples
  - Octales
  - Hexadecimales
- Literales cadena
- Palabras reservadas:
  - Tipos de datos
  - Estructuras de control
  - Otras (especificadas por enunciado)
- Identificadores
- Caracteres de puntuación/operadores.

Para las estructuras que almacenan la información de los tokens se reserva memoria en tiempo de ejecución al momento de identificación de un token y es liberada una vez realizada la impresión por pantalla del reporte solicitado.