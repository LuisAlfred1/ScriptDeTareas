--Grupo: Walter Mijangos y Luis Reyes

/*
🔹 Reto 1 – Top compradores del año
    Mostrar los 5 clientes que más dinero han gastado en total durante el último año, ordenados del mayor al menor.
*/

SELECT TOP 5
    c.cliente_id,
    CONCAT(c.nombre,' ',c.apellido) as Cliente, --Aqui estoy concatenando el nombre y el apellido
    SUM(V.total_venta) AS Total_De_Gastos  --Obtengo la suma del total de ventas
FROM cli.clientes c 
JOIN sell.ventas v on c.cliente_id = v.cliente_id --Aqui hago un JOIN para unir la tabla de cliente con ventas
WHERE YEAR(V.fecha_venta) = YEAR(GETDATE()) - 4  --Año 2021 // Inge, la BD de Ecommerce tiene registros del año 2021. De 2022 - 2025 no hay registros 
GROUP BY c.cliente_id, CONCAT(c.nombre,' ',c.apellido) --Los agrupo
ORDER BY Total_De_Gastos DESC; --Y los ordeno de mayor a menor

--Aqui verifiqué con el MAX que solo hay registros del 2021.
SELECT MAX(fecha_venta) FROM sell.ventas


/*
🔹 Reto 2 – Categorías sin productos vendidos
    Encontrar las categorías que no han tenido ningún producto vendido.
*/

SELECT 
    c.categoria_id,
    c.categoria
FROM sell.categoria as c 
LEFT JOIN sell.productos as p ON c.categoria_id = p.categoria_id --Aqui hago un left join para mostrar las categorias aunque no tengan productos
LEFT JOIN sell.detalle_ventas dv ON p.producto_id = dv.producto_id --aqui otro left donde si un producto no ha sido vendido, entonces no tendrá coincidencia en detalle_ventas
WHERE dv.producto_id IS NULL; --aqui la condición de que si el producto_id es nulo significará el producto no fue vendido


/*
🔹 Reto 3 – Días con mayor volumen de ventas
   Listar los 3 días con más cantidad de productos vendidos (sumando todas las ventas del día).
*/

SELECT 
	TOP 3
	v.fecha_venta,
	SUM(dv.cantidad) productos_vendidos
FROM sell.detalle_ventas AS dv
JOIN sell.ventas AS v ON dv.venta_id = v.venta_id
GROUP BY v.fecha_venta
ORDER BY productos_vendidos DESC


/*
🔹 Reto 4 – Productos con mejor desempeño en stock
    Mostrar los productos que han vendido más del 50% de su stock actual.
*/

SELECT 
    p.producto_id,
    p.nombre_producto,
    p.stock,
    SUM(dv.cantidad) as Cantidad_Vendida --Realizo la Suma de la cantidad de detalle ventas
FROM sell.productos as p 
JOIN sell.detalle_ventas as dv ON p.producto_id = dv.producto_id -- Hago un Join para unir la tabla detalle ventas con los productos
GROUP BY p.producto_id, p.nombre_producto, p.stock --los Agrupo por producto
HAVING SUM(dv.cantidad) > (p.stock * 0.5); -- Y aqui utilizo el Having despues de aplicar una funcion para filtrar los productos 


/*
🔹 Reto 5 – Clientes sin compras pero con carritos
    Encontrar los clientes que no han realizado ninguna compra, pero tienen al menos un carrito creado.
*/

SELECT 
    c.cliente_id,
    CONCAT(c.nombre,' ',c.apellido) as Cliente
FROM cli.clientes AS c
JOIN sell.carrito_compras AS ca ON c.cliente_id = ca.cliente_id
LEFT JOIN sell.ventas v ON c.cliente_id = v.cliente_id
WHERE v.venta_id IS NULL
GROUP BY c.cliente_id, CONCAT(c.nombre,' ',c.apellido)
Order BY c.cliente_id 