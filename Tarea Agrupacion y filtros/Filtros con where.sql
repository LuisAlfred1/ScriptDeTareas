--FILTROS CON WHERE EJERCICIOS


--Listar todos los productos con un precio mayor a 500.
SELECT * FROM sell.productos
WHERE precio > 500

--Mostrar los clientes cuyo nombre empieza con la letra 'J'.
SELECT * FROM cli.clientes
WHERE nombre LIKE 'J%'

--Obtener todas las ventas realizadas en el año 2024. (Tip: usa YEAR() para extraer el año de fecha_venta)
SELECT * FROM sell.ventas
WHERE YEAR(fecha_venta) = 2024

--Listar productos de la marca 'LG' o 'Sony'.
SELECT * FROM sell.productos
WHERE marca IN('LG','Sony')

--Mostrar los productos que no tienen categoría asignada.
SELECT * FROM sell.productos
WHERE categoria_id IS NULL

--Obtener los carritos que están abandonados.
SELECT * FROM sell.carrito_compras
WHERE abandonado = 1

--Listar los clientes que tienen correo electrónico registrado (no nulo).
SELECT * FROM cli.clientes
WHERE correo_electronico IS NOT NULL

--Mostrar las tarjetas de crédito que vencen en el año actual.  (Tip: usa YEAR(fecha_vencimiento) = YEAR(GETDATE())) 
SELECT * FROM cli.tarjetas_credito
WHERE YEAR(fecha_vencimiento) = YEAR(GETDATE())

--Listar productos con stock entre 10 y 50 unidades.
SELECT * FROM sell.productos
WHERE stock BETWEEN 10 AND 50

--Obtener clientes cuyo apellido contiene la letra “z” (sin importar posición).
SELECT * FROM cli.clientes
WHERE apellido LIKE '%z%'

--Listar los productos cuyo nombre no contiene la palabra “Cable”.
SELECT * FROM sell.productos
WHERE nombre_producto NOT LIKE '%Cable%'

--Obtener las ventas con total_venta entre 1000 y 5000, excluyendo exactamente 3000.
SELECT * FROM sell.ventas
WHERE total_venta BETWEEN 1000 AND 5000
AND total_venta != 3000

--Mostrar los productos con stock menor a 5 o nulo.
SELECT * FROM sell.productos
WHERE stock < 5 OR stock is NULL

--Listar las ventas que no tienen cliente asignado.
SELECT * FROM sell.ventas
WHERE cliente_id IS NULL

--Mostrar todos los clientes cuyo nombre no empieza con vocal. (Tip: usa NOT LIKE 'A%' AND NOT LIKE 'E%'...)  
SELECT * 
FROM cli.clientes
WHERE nombre NOT LIKE 'A%' 
  AND nombre NOT LIKE 'E%' 
  AND nombre NOT LIKE 'I%' 
  AND nombre NOT LIKE 'O%' 
  AND nombre NOT LIKE 'U%'