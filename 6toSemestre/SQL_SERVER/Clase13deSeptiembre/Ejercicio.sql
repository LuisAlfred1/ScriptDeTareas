SET STATISTICS IO, TIME ON;

------------------------------------------------------------
-- 1) Filtro por fecha NO sargable (función sobre la columna)
------------------------------------------------------------
/*
Se usan rangos de fechas, permitiendo que el motor
aproveche el índice en la columna fecha_venta
*/

SELECT COUNT(*) AS ventas_2025
FROM sell.ventas
WHERE fecha_venta >= '2024-01-01' AND fecha_venta < '2024-12-31' --Bien

------------------------------------------------------------
-- 2) Texto NO sargable (función sobre la columna)
------------------------------------------------------------
/*
Se utiliza un rango que busca todos los productos 
que empiezan con 'Prod'. Esto permite aprovechar un índice
en la columna nombre_producto.
*/
SELECT producto_id, nombre_producto
FROM sell.productos
WHERE nombre_producto >= 'Prod'
  AND nombre_producto < 'Proe'; -- Bien


------------------------------------------------------------
-- 3) Conversión implícita (variable NVARCHAR contra columna VARCHAR)
------------------------------------------------------------
/*
Se declara la variable con el mismo tipo de dato que la columna (VARCHAR),
evitando la conversión implícita y permitiendo usar el índice en correo_electronico.
*/
DECLARE @mail VARCHAR(100) = 'user10@mail.com';
SELECT cliente_id, nombre, apellido
FROM cli.clientes
WHERE correo_electronico = @mail;--Bien

------------------------------------------------------------
-- 4) JOIN que duplica filas y obliga a DISTINCT
------------------------------------------------------------
/*usamos EXISTS para devolver verdadero en cuanto encuentra una coincidencia,
evitando filas duplicadas sin necesidad de usar DISTINCT.
*/
SELECT c.cliente_id
FROM cli.clientes c
WHERE EXISTS (
    SELECT 1
    FROM sell.ventas v
    JOIN sell.detalle_ventas d ON d.venta_id = v.venta_id
    WHERE v.cliente_id = c.cliente_id
);

------------------------------------------------------------
-- 5) Búsqueda con comodín al inicio (no usa índice) + ordenamiento caro
------------------------------------------------------------
/*
1) Si la búsqueda es "empieza con",se usa 'Pro%' en lugar de '%Pro%' para 
que SQL Server pueda usar un índice en nombre_producto.
*/
SELECT TOP (100) producto_id, nombre_producto, precio
FROM sell.productos
WHERE nombre_producto LIKE 'Pro%'  -- ahora SARGable.
ORDER BY nombre_producto;          -- sin función, permite índice en el ORDER BY

------------------------------------------------------------
-- 6) Patrón propenso a Key Lookups (muchas columnas, filtro poco selectivo)
------------------------------------------------------------
/*
se crea un índice cubriente usando INCLUDE para que todas las columnas requeridas 
estén dentro del índice y evitar el Lookup.
*/
CREATE NONCLUSTERED INDEX IX_productos_categoria_nombre
ON sell.productos (categoria_id, nombre_producto)
INCLUDE (precio, stock, marca, descripcion);

SELECT TOP (200)
       p.producto_id, p.nombre_producto, p.precio, p.stock, p.marca, p.descripcion
FROM sell.productos p
WHERE p.categoria_id IS NULL
ORDER BY p.nombre_producto; -- ahora puede usar el índice para ordenar

------------------------------------------------------------
-- 7) Agregación con JOIN y función sobre la fecha (no sargable)
------------------------------------------------------------
/*
Calcular el inicio y fin del año actual una sola vez con variables.
Filtrar usando un rango, lo que permite que SQL Server use un índice 
en la columna fecha_venta y evite el escaneo completo.
DECLARE @FechaInicio DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
DECLARE @FechaFin    DATE = DATEADD(YEAR, 1, @FechaInicio); -- primer día del siguiente año
*/
SELECT SUM(d.cantidad * d.precio_unitario) AS ingresos_2024
FROM sell.detalle_ventas d
JOIN sell.ventas v ON v.venta_id = d.venta_id
WHERE v.fecha_venta >= @FechaInicio
  AND v.fecha_venta < @FechaFin; -- SARGable, usa índice

------------------------------------------------------------
-- 8) Búsqueda case-insensitive aplicando función a la columna
------------------------------------------------------------
/*
Si la base de datos usa un COLLATION case-insensitive (CI),
no es necesario usar LOWER() en la columna, basta con comparar directamente.
Si no, puedes forzar el COLLATE solo en la comparación para que sea insensible a mayúsculas/minúsculas.
DECLARE @q NVARCHAR(100) = N'USER30@MAIL.COM';
*/
SELECT cliente_id, nombre, apellido, correo_electronico
FROM cli.clientes
WHERE correo_electronico = @q COLLATE Latin1_General_CI_AS; -- usa índice