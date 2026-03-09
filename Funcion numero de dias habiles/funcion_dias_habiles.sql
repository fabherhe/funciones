/**
 * ============================================================================
 * FUNCIÓN: DIAS_HABILES
 * ============================================================================
 * 
 * DESCRIPCIÓN:
 *   Calcula el número de días hábiles (laborales) entre dos fechas, 
 *   excluyendo fines de semana (sábados y domingos) y festivos nacionales.
 *
 * PARÁMETROS:
 *   fecha_inicio (IN DATE): Fecha inicial del rango a evaluar (inclusive)
 *   fecha_fin    (IN DATE): Fecha final del rango a evaluar (inclusive)
 *
 * RETORNA:
 *   NUMBER: Cantidad de días hábiles en el rango especificado
 *           Retorna 0 si fecha_fin es anterior a fecha_inicio
 *
 * DEPENDENCIAS:
 *   - Tabla FIESTAS_NAC: Contiene los festivos nacionales
 *     Columna: f_fiesta (DATE) - Data del festivo
 *
 * EJEMPLO DE USO:
 *   SELECT DIAS_HABILES(
 *       TO_DATE('01/01/2024', 'DD/MM/YYYY'),
 *       TO_DATE('31/01/2024', 'DD/MM/YYYY')
 *   ) AS dias_laborales FROM DUAL;
 *
 * NOTAS:
 *   - La validación de sábados/domingos se realiza comparando contra 
 *     códigos de día tanto en español (SAB, DOM) como en inglés (SAT, SUN)
 *   - El rendimiento depende del tamaño y del índice en la tabla FIESTAS_NAC
 *   - Recomendación: Crear índice en FIESTAS_NAC.F_FIESTA para optimizar
 *
 * HISTORIAL:
 *   01/01/2024 - Creación inicial de la función
 *
 * ============================================================================
 */
CREATE OR REPLACE FUNCTION "OPEN".DIAS_HABILES
(
    fecha_inicio IN DATE, 
    fecha_fin    IN DATE
)
RETURN NUMBER IS
    
    -- Variables locales
    numero_dias NUMBER := 0;          -- Acumulador de días hábiles
    es_festivo  NUMBER := 0;          -- Flag para identificar festivos (1=festivo, 0=no festivo)
    fecha_actual DATE;                -- Iterador para recorrer el rango de fechas

BEGIN
    
    -- Validación: La fecha de inicio debe ser menor o igual a la de fin
    IF fecha_fin >= fecha_inicio THEN
        
        -- Inicializar el iterador con la fecha de inicio
        fecha_actual := fecha_inicio;
        
        -- Recorrer cada día del rango
        WHILE fecha_actual <= fecha_fin LOOP
            
            -- Reiniciar el flag de festivo para cada iteración
            es_festivo := 0;
            
            /**
             * VALIDACIÓN 1: Verificar que NO sea fin de semana (sábado o domingo)
             * TO_CHAR(fecha_actual, 'DY') retorna el día en forma corta:
             *   - SAB/SAT: Sábado
             *   - DOM/SUN: Domingo
             * Se incluyen ambas variantes por compatibilidad de idioma
             */
            IF TO_CHAR(fecha_actual, 'DY') NOT IN ('SAB', 'DOM', 'SAT', 'SUN') THEN
                
                /**
                 * VALIDACIÓN 2: Verificar que NO sea festivo nacional
                 * Consulta la tabla de festivos nacionales para confirmar
                 * si la fecha actual está registrada como festivo
                 */
                SELECT COUNT(1)
                INTO   es_festivo
                FROM   fiestas_nac
                WHERE  f_fiesta = fecha_actual;
                
                /**
                 * Si no es festivo (es_festivo = 0), incrementar el contador
                 * de días hábiles
                 */
                IF es_festivo = 0 THEN
                    numero_dias := numero_dias + 1;
                END IF;
                
            END IF;
            
            -- Avanzar al siguiente día
            fecha_actual := fecha_actual + 1;
            
        END LOOP;
        
        -- Retornar la cantidad total de días hábiles encontrados
        RETURN numero_dias;
        
    ELSE
        
        /**
         * Caso de error: La fecha de fin es anterior a la de inicio
         * Se retorna 0 como indicador de rango inválido
         */
        RETURN 0;
        
    END IF;

END DIAS_HABILES;
/