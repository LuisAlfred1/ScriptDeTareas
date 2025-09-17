------------------------------------------------------------
-- a) Ingresos por cliente y mes (último año)
------------------------------------------------------------

-- Se declara variables de fecha para el rango de búsqueda SARGable
-- Primer día del año actual
DECLARE @FechaInicio DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);  
 
-- Último día del año actual
DECLARE @FechaFin DATE = DATEADD(DAY, -1, DATEADD(YEAR, 1, @FechaInicio));  

SELECT
    v.cliente_id,
    MONTH(v.fecha_venta) AS mes, -- Devuelve número del mes, más eficiente que DATENAME
    YEAR(v.fecha_venta) AS anio,
    SUM(d.cantidad * d.precio_unitario) AS ingresos
FROM sell.ventas v
JOIN sell.detalle_ventas d 
    ON d.venta_id = v.venta_id
WHERE v.fecha_venta >= @FechaInicio
  AND v.fecha_venta <= @FechaFin -- Filtro SARGable para que se pueda usar índice
GROUP BY 
    v.cliente_id, 
    MONTH(v.fecha_venta),
    YEAR(v.fecha_venta)
ORDER BY ingresos DESC;  
GO
------------------------------------------------------------
-- b) Top-N productos por facturación en rango
------------------------------------------------------------
--Se Usa la variable de tipo DATE para el rango y asi evitar conversiones costosas
DECLARE @ini DATE = '20240101';
DECLARE @fin DATE = '20241231';

SELECT TOP (20)
       d.producto_id,
       SUM(d.cantidad * d.precio_unitario) AS ingresos
FROM sell.detalle_ventas d
JOIN sell.ventas AS v ON v.venta_id = d.venta_id --Se realiza un JOIN remplazando el subquery
WHERE v.fecha_venta >= @ini AND v.fecha_venta <= @fin --Se utiliza el filtro SARGable
GROUP BY d.producto_id
ORDER BY ingresos DESC;
GO
--Resultado de la ejecución: redució el tiempo en elapsed time de 5ms a-> 2ms.

------------------------------------------------------------
-- c) Tasa de conversión carrito → venta (mismo mes)
------------------------------------------------------------
-- Obtener inicio y fin del mes actual para evitar YEAR(), MONTH() y FORMAT()
DECLARE @FechaInicio DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);  
DECLARE @FechaFin DATE = DATEADD(DAY, -1, DATEADD(MONTH, 1, @FechaInicio));  

SELECT
  (SELECT COUNT(DISTINCT v.cliente_id)
   FROM sell.ventas v
   WHERE v.fecha_venta >= @FechaInicio AND v.fecha_venta <= @FechaFin
   ) -- utilzando filtro SARGable
  * 1.0 /
  NULLIF((
    SELECT COUNT(DISTINCT cc.cliente_id)
    FROM sell.carrito_compras cc
    WHERE cc.fecha_creacion >= @FechaInicio
      AND cc.fecha_creacion <= @FechaFin
      AND ISNULL(cc.abandonado, 0) = 0  -- Mejora: trata NULL como "no abandonado"
  ), 0) AS tasa_conversion_mensual;
GO
--Resultado de la ejecución: redució el tiempo en elapsed time: antes: 87ms ahora->5ms
