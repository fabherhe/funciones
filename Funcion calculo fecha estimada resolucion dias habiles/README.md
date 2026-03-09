# Fecha Estimada de Resolucion de Ordenes (Oracle PL/SQL)

Este proyecto implementa una funcion en PL/SQL para calcular la **fecha estimada de resolucion** de una orden de trabajo en una empresa de comercializacion de energia electrica.

## Problema de negocio

En la operacion de ordenes de trabajo, medir solo la fecha de creacion y cierre no alcanza para gestionar bien el cumplimiento.

Se necesitaba crear un campo que respondiera:

- Cuando deberia estar resuelta cada orden segun dias habiles.
- Cuales ordenes estan en riesgo o vencidas frente al SLA.
- Como monitorear la eficiencia de la operacion en tableros y reportes.

## Solucion implementada

La funcion `F_ESTM_RES(fecha_inicio, dias_habiles_a_agregar)` calcula una fecha objetivo:

- Parte de `fecha_inicio` (por ejemplo, `f_gen` de la orden).
- Avanza dia a dia.
- Excluye sabados y domingos.
- Excluye festivos consultando la tabla `FIESTAS_NAC`.
- Retorna la fecha exacta en que se completan los dias habiles definidos por la politica operativa (ejemplo: 6 dias).

Archivo principal:

- [funcion_f_estimada_resolucion.sql](./funcion_f_estimada_resolucion.sql)

## Logica funcional (resumen)

1. Inicializa la fecha estimada con la fecha de inicio.
2. Recorre dias calendario hasta acumular `N` dias habiles.
3. Cada dia valida:
   - No fin de semana.
   - No festivo nacional.
4. Cuando alcanza los dias habiles requeridos, devuelve la fecha resultante.

## Como crear el campo operativo

Se puede incorporar como campo calculado en consultas, vistas o pipelines:

```sql
SELECT
  o.num_os,
  o.f_gen AS fecha_generacion,
  F_ESTM_RES(o.f_gen, 6) AS fecha_estimada_resolucion
FROM ordenes o;
```

Con ese campo se habilita el seguimiento de SLA:

```sql
SELECT
  o.num_os,
  o.f_gen,
  o.f_cierre,
  F_ESTM_RES(o.f_gen, 6) AS fecha_estimada_resolucion,
  CASE
    WHEN o.f_cierre <= F_ESTM_RES(o.f_gen, 6) THEN 'A TIEMPO'
    ELSE 'ATRASADA'
  END AS estado_sla
FROM ordenes o;
```

## Valor para la operacion

- Estandariza el criterio de vencimiento para todas las ordenes.
- Facilita alertas tempranas de atraso.
- Permite priorizar backlog por criticidad temporal.
- Mejora trazabilidad y conversaciones con areas de negocio y control.

## Indicadores que habilita

- `% de ordenes resueltas a tiempo`.
- `dias de atraso promedio`.
- `ordenes vencidas por zona/cuadrilla/canal`.
- `tendencia semanal de cumplimiento SLA`.

## Consideraciones tecnicas

- La funcion contempla validaciones basicas:
  - Retorna `NULL` si recibe parametros nulos.
  - Lanza error si `dias_habiles_a_agregar` es negativo.
- Requiere que `FIESTAS_NAC` este actualizada.
- Conviene indexar `FIESTAS_NAC(F_FIESTA)` para mejorar rendimiento.

## Resultado profesional para portafolio

Este desarrollo demuestra capacidad para:

- Traducir una necesidad operativa en logica de datos accionable.
- Implementar reglas de negocio de calendario laboral en base de datos.
- Conectar SQL/PLSQL con indicadores reales de desempeno operativo.

En resumen, no es solo una funcion de fechas: es una pieza de control operativo para mejorar cumplimiento en un proceso critico del negocio electrico.
