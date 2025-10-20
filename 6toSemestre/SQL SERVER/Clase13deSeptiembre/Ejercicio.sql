SET STATISTICS IO, TIME ON;

------------------------------------------------------------
-- 1) Filtro por fecha NO sargable (funci�n sobre la columna)
------------------------------------------------------------
/*
Se usan rangos de fechas, permitiendo que el motor
aproveche el �ndice en la columna fecha_venta
*/

SELECT COUNT(*) AS ventas_2025
FROM sell.ventas
WHERE fecha_venta >= '2024-01-01' AND fecha_venta < '2024-12-31' --Bien

------------------------------------------------------------
-- 2) Texto NO sargable (funci�n sobre la columna)
------------------------------------------------------------
/*
Se utiliza un rango que busca todos los productos 
que empiezan con 'Prod'. Esto permite aprovechar un �ndice
en la columna nombre_producto.
*/
SELECT producto_id, nombre_producto
FROM sell.productos
WHERE nombre_producto >= 'Prod'
  AND nombre_producto < 'Proe'; -- Bien


------------------------------------------------------------
-- 3) Conversi�n impl�cita (variable NVARCHAR contra columna VARCHAR)
------------------------------------------------------------
/*
Se declara la variable con el mismo tipo de dato que la columna (VARCHAR),
evitando la conversi�n impl�cita y permitiendo usar el �ndice en correo_electronico.
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
-- 5) B�squeda con comod�n al inicio (no usa �ndice) + ordenamiento caro
------------------------------------------------------------
/*
1) Si la b�squeda es "empieza con",se usa 'Pro%' en lugar de '%Pro%' para 
que SQL Server pueda usar un �ndice en nombre_producto.
*/
SELECT TOP (100) producto_id, nombre_producto, precio
FROM sell.productos
WHERE nombre_producto LIKE 'Pro%'  -- ahora SARGable.
ORDER BY nombre_producto;          -- sin funci�n, permite �ndice en el ORDER BY

------------------------------------------------------------
-- 6) Patr�n propenso a Key Lookups (muchas columnas, filtro poco selectivo)
------------------------------------------------------------
/*
se crea un �ndice cubriente usando INCLUDE para que todas las columnas requeridas 
est�n dentro del �ndice y evitar el Lookup.
*/
CREATE NONCLUSTERED INDEX IX_productos_categoria_nombre
ON sell.productos (categoria_id, nombre_producto)
INCLUDE (precio, stock, marca, descripcion);

SELECT TOP (200)
       p.producto_id, p.nombre_producto, p.precio, p.stock, p.marca, p.descripcion
FROM sell.productos p
WHERE p.categoria_id IS NULL
ORDER BY p.nombre_producto; -- ahora puede usar el �ndice para ordenar

------------------------------------------------------------
-- 7) Agregaci�n con JOIN y funci�n sobre la fecha (no sargable)
------------------------------------------------------------
/*
Calcular el inicio y fin del a�o actual una sola vez con variables.
Filtrar usando un rango, lo que permite que SQL Server use un �ndice 
en la columna fecha_venta y evite el escaneo completo.
DECLARE @FechaInicio DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
DECLARE @FechaFin    DATE = DATEADD(YEAR, 1, @FechaInicio); -- primer d�a del siguiente a�o
*/
SELECT SUM(d.cantidad * d.precio_unitario) AS ingresos_2024
FROM sell.detalle_ventas d
JOIN sell.ventas v ON v.venta_id = d.venta_id
WHERE v.fecha_venta >= @FechaInicio
  AND v.fecha_venta < @FechaFin; -- SARGable, usa �ndice

------------------------------------------------------------
-- 8) B�squeda case-insensitive aplicando funci�n a la columna
------------------------------------------------------------
/*
Si la base de datos usa un COLLATION case-insensitive (CI),
no es necesario usar LOWER() en la columna, basta con comparar directamente.
Si no, puedes forzar el COLLATE solo en la comparaci�n para que sea insensible a may�sculas/min�sculas.
DECLARE @q NVARCHAR(100) = N'USER30@MAIL.COM';
*/
SELECT cliente_id, nombre, apellido, correo_electronico
FROM cli.clientes
WHERE correo_electronico = @q COLLATE Latin1_General_CI_AS; -- usa �ndice