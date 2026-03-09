/*
  Proyecto: Calculo de fecha estimada de resolucion para ordenes de trabajo
  Motor: Oracle PL/SQL

  Objetivo de negocio:
  Calcular la fecha en la que una orden deberia estar resuelta, considerando
  solo dias habiles (excluye sabados, domingos y festivos nacionales).

  Esto permite:
  - Construir el campo operativo "fecha_estimada_resolucion".
  - Medir cumplimiento de SLA por orden.
  - Monitorear atrasos y priorizar la operacion.
*/

CREATE OR REPLACE FUNCTION F_ESTM_RES (
  fecha_inicio DATE,
  dias_habiles_a_agregar INTEGER
) RETURN DATE AS
  fecha_estimada DATE;
  dias_habiles_acumulados INTEGER := 0;
  es_festivo INTEGER;
BEGIN
  IF fecha_inicio IS NULL OR dias_habiles_a_agregar IS NULL THEN
    RETURN NULL;
  END IF;

  IF dias_habiles_a_agregar < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'dias_habiles_a_agregar no puede ser negativo');
  END IF;

  fecha_estimada := fecha_inicio;

  WHILE dias_habiles_acumulados < dias_habiles_a_agregar LOOP
    fecha_estimada := fecha_estimada + 1;

    IF TO_CHAR(fecha_estimada, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') NOT IN ('SAT', 'SUN') THEN
      SELECT COUNT(*)
        INTO es_festivo
        FROM FIESTAS_NAC
       WHERE F_FIESTA = fecha_estimada;

      IF es_festivo = 0 THEN
        dias_habiles_acumulados := dias_habiles_acumulados + 1;
      END IF;
    END IF;
  END LOOP;

  RETURN fecha_estimada;
END F_ESTM_RES;
/

/*
  Ejemplo 1: usar la funcion en una consulta para crear un campo calculado

  SELECT
    o.num_os,
    o.f_gen AS fecha_generacion,
    F_ESTM_RES(o.f_gen, 6) AS fecha_estimada_resolucion
  FROM ordenes o;
*/

/*
  Ejemplo 2: monitoreo de cumplimiento (a tiempo vs atrasada)

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
*/
