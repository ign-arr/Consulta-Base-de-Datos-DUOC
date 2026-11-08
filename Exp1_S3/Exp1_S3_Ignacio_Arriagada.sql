-- Caso 1
SELECT id_tipo_propiedad AS TIPO,
       COUNT(*) AS TOTAL_PROPIEDADES,
       TO_CHAR(MAX(valor_arriendo), '$9G999G990',
               'NLS_NUMERIC_CHARACTERS = '',.''') AS MAX_ARRIENDO,
       TO_CHAR(ROUND(AVG(valor_arriendo)), '$9G999G990',
               'NLS_NUMERIC_CHARACTERS = '',.''') AS PROMEDIO_ARRIENDO,
       TO_CHAR(MIN(valor_arriendo), '$9G999G990',
               'NLS_NUMERIC_CHARACTERS = '',.''') AS MIN_ARRIENDO,
       CASE
           WHEN MAX(valor_arriendo) > 1000000 THEN 'PREMIUM'
           ELSE 'ESTÁNDAR'
       END AS CLASIFICACION,
       TO_CHAR(SUM(NVL(valor_gasto_comun, 0)), '$999G999G999G990',
               'NLS_NUMERIC_CHARACTERS = '',.''') AS TOTAL_GASTOS_COMUNES
FROM propiedad
GROUP BY id_tipo_propiedad
HAVING SUM(NVL(valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(valor_gasto_comun, 0)) DESC;

-- Caso 2
SELECT UPPER(nombre_emp || ' ' || appaterno_emp) AS "Nombre Empleado",
       TO_CHAR(sueldo_emp, '$9G999G990',
               'NLS_NUMERIC_CHARACTERS = '',.''') AS "Sueldo con Formato",
       CASE
           WHEN sueldo_emp > 2000000 THEN 'ALTO'
           ELSE 'MEDIO'
       END AS "Clasificación Sueldo",
       antiguedad AS "Años Antigüedad",
       'Corresponde bono ' ||
       CASE
           WHEN antiguedad <= 10 THEN ' 5%'
           WHEN antiguedad <= 20 THEN '10%'
           ELSE '15%'
       END || ': ' ||
       TO_CHAR(
           ROUND(sueldo_emp * CASE
               WHEN antiguedad <= 10 THEN 0.05
               WHEN antiguedad <= 20 THEN 0.10
               ELSE 0.15
           END),
           '$9G999G990', 'NLS_NUMERIC_CHARACTERS = '',.'''
       ) AS BONO
FROM (
    SELECT nombre_emp, appaterno_emp, sueldo_emp,
           TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), fecing_emp) / 12) AS antiguedad
    FROM empleado
    WHERE id_categoria_emp = 3
      AND id_sucursal <> &CODIGO_SUCURSAL
      AND fecing_emp < ADD_MONTHS(TRUNC(SYSDATE), -60)
)
ORDER BY sueldo_emp DESC;

-- Caso 3
SELECT clasificacion_renta,
       COUNT(*) AS CANTIDAD_CLIENTES,
       TO_CHAR(ROUND(AVG(renta_cli)), '$9G999G990',
               'NLS_NUMERIC_CHARACTERS = '',.''') AS RENTA_PROMEDIO,
       CASE
           WHEN COUNT(celular_cli) = 0 THEN 'Clientes Sin Teléfono'
           ELSE 'Clientes con Teléfono'
       END AS ESTADO_TELEFONO
FROM (
    SELECT renta_cli, celular_cli,
           CASE
               WHEN renta_cli >= 1000000 THEN 'PREMIUM'
               WHEN renta_cli >= 600000 THEN 'ALTA'
               WHEN renta_cli >= 300000 THEN 'MEDIA'
               ELSE 'BAJA'
           END AS clasificacion_renta
    FROM cliente
)
GROUP BY clasificacion_renta
HAVING AVG(renta_cli) > 200000;
