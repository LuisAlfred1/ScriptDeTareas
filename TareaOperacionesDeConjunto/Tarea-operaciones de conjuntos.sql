/*Ejercicio 1: ¿Clientes duplicados?
Enunciado:
Extrae una lista de nombres y apellidos de clientes registrados tanto en la tabla operativa como en la tabla de
análisis (cli.clientes y dim.cliente). Elimina duplicados para obtener una lista limpia.
*/

SELECT TOP 200 nombre,apellido FROM cli.clientes
UNION 
SELECT TOP 200 nombre,apellido FROM dim.cliente

/*
Ejercicio 2: Todos los nombres, incluso si se repiten
Enunciado:
Genera una consulta que muestre todos los nombres de clientes registrados en ambas tablas (cli.clientes y
dim.cliente), incluyendo los nombres que se repiten.
*/

SELECT TOP 200 nombre FROM cli.clientes
UNION ALL
SELECT TOP 200 nombre FROM dim.cliente

/*
Ejercicio 3: ¿Clientes sincronizados?
Enunciado:
Obtén los nombres y apellidos de los clientes que aparecen en ambas tablas (cli.clientes y dim.cliente)
exactamente iguales. Esto puede ayudarte a verificar si el sistema está sincronizado correctamente.
*/

SELECT TOP 200 nombre,apellido FROM cli.clientes
INTERSECT
SELECT TOP 200 nombre,apellido FROM dim.cliente

/*
Ejercicio 4: Clientes sin tarjeta de crédito
Enunciado:
Identifica los clientes registrados en cli.clientes que no tienen una tarjeta de crédito asociada en
cli.tarjetas_credito.
*/

SELECT cliente_id FROM cli.clientes
EXCEPT
SELECT cliente_id FROM cli.tarjetas_credito;

/*
Ejercicio 5: Clientes que nunca han comprado
Enunciado:
Encuentra a todos los clientes que están en cli.clientes pero no aparecen en la tabla de ventas (sell.ventas). ¿Se
habrán registrado solo para curiosear?
*/

SELECT cliente_id FROM cli.clientes
EXCEPT
SELECT cliente_id FROM sell.ventas

/*
Ejercicio 6: Productos en venta o en carrito
Enunciado:
Obtén una lista de productos que han sido vendidos o que se encuentran en al menos un carrito de compras. Evita
los duplicados.
*/

SELECT producto_id FROM sell.detalle_ventas
UNION
SELECT producto_id FROM sell.detalle_carrito_compras

/*
Ejercicio 7: ¿Qué productos llaman la atención?
Enunciado:
Identifica los productos que están tanto en carritos de compra como en ventas realizadas. Podrían ser
productos populares o en tendencia.
*/

SELECT producto_id FROM sell.detalle_ventas
INTERSECT
SELECT producto_id FROM sell.detalle_carrito_compras

/*
Ejercicio 8: Productos ignorados por los compradores
Enunciado:
Muestra los productos que se encuentran en el catálogo (sell.productos) pero no han sido vendidos. ¿Deberían
promocionarse más?
*/

SELECT producto_id FROM sell.productos
EXCEPT
SELECT producto_id FROM sell.detalle_ventas

/*
Ejercicio 9: Del carrito... pero nunca comprados
Enunciado:
Identifica los productos que aparecen en carritos de compra pero que nunca han sido vendidos. Puede indicar
interés sin conversión.
*/

SELECT producto_id FROM sell.detalle_carrito_compras
EXCEPT
SELECT producto_id FROM sell.detalle_ventas

/*
Ejercicio 10: Productos vendidos, pero no visibles
Enunciado:
Muestra los productos que han sido vendidos, pero que ya no existen en el catálogo actual (sell.productos).
¿Será un problema de inventario o de actualización?
*/

SELECT producto_id FROM sell.detalle_ventas
EXCEPT
SELECT producto_id FROM sell.productos