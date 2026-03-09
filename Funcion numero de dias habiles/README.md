# Función DIAS_HABILES

## Descripción
Calcula el número de días hábiles entre dos fechas, excluyendo fines de semana y festivos nacionales.

## Sintaxis
```sql
DIAS_HABILES(fecha_inicio IN DATE, fecha_fin IN DATE)
```

## Parámetros
- **fecha_inicio** (DATE): Fecha de inicio del período a calcular
- **fecha_fin** (DATE): Fecha de fin del período a calcular

## Retorno
- **NUMBER**: Número de días hábiles entre las fechas especificadas
  - Retorna 0 si `fecha_fin` es anterior a `fecha_inicio`

## Reglas
- Excluye sábados y domingos
- Excluye días festivos registrados en la tabla `fiestas_nac`
- Incluye el día de inicio y el día de fin (ambos inclusive) si son hábiles

## Ejemplo de Uso
```sql
-- Calcular días hábiles del 1 al 31 de enero
SELECT DIAS_HABILES(TO_DATE('01/01/2024','DD/MM/YYYY'), 
                    TO_DATE('31/01/2024','DD/MM/YYYY')) as dias_habiles
FROM DUAL;
-- Resultado: Número de días hábiles en ese período
```

## Dependencias
- Tabla: `fiestas_nac` - Debe contener los festivos nacionales con la columna `f_fiesta` (DATE)

## Notas
- La función está definida en el esquema **OPEN**
- Compatible con Oracle Database
- El rendimiento depende del tamaño de la tabla `fiestas_nac`

## Historial
- Versión 1.0: Creación de la función
