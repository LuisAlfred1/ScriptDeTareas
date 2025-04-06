--Agrupaciones (GROUP BY) y filtros (HAVING)--

--Contar cuántos productos hay por cada categoría.
SELECT
    categoria_id,
    COUNT(*) cantidadProductosCategoria
FROM sell.productos
GROUP BY categoria_id

--Obtener el total de ventas por cliente.
SELECT 
    c.nombre,
    SUM(v.total_venta) TotalVentasCliente 
FROM sell.ventas as v 
JOIN cli.clientes as c ON v.cliente_id = c.cliente_id
GROUP BY c.nombre


--Listar los clientes que han realizado más de 3 ventas.
SELECT 
    c.nombre,
    COUNT(v.venta_id) cantidadVentas 
FROM sell.ventas as v 
JOIN cli.clientes as c ON v.cliente_id = c.cliente_id
GROUP BY c.nombre
HAVING COUNT(V.venta_id) > 3
ORDER BY cantidadVentas ASC

--Mostrar la cantidad de productos por marca.
SELECT
    marca,
    COUNT(*) cantidadProductos
FROM sell.productos
GROUP BY marca


--Obtener el promedio de precios por categoría.
SELECT 
    c.categoria,
    AVG(p.precio) as PromedioPreciosCategoria
FROM sell.productos as p 
JOIN sell.categoria as c on p.categoria_id = c.categoria_id
GROUP BY c.categoria 

--Mostrar las fechas en que se realizaron más de 2 ventas. (Tip: agrupar por fecha_venta)
SELECT
    fecha_venta,
    COUNT(*) cantidadVentas
FROM sell.ventas
GROUP BY fecha_venta
HAVING COUNT(*) > 2


--Listar los productos vendidos (por producto_id) junto con la cantidad total vendida.
SELECT 
    producto_id,
    COUNT(*) cantidadVentas,
    SUM(cantidad) cantidadTotalVendida
FROM sell.detalle_ventas
GROUP BY producto_id
ORDER BY cantidadTotalVendida DESC


--Listar los productos con un promedio de precio unitario en ventas mayor a 300. (Tip: usar detalle_ventas)
SELECT 
    p.nombre_producto,
    AVG(dv.precio_unitario) PromedioPrecio
FROM sell.detalle_ventas as dv 
JOIN sell.productos as p ON dv.producto_id = p.producto_id
GROUP BY p.nombre_producto
HAVING AVG(dv.precio_unitario) > 300
ORDER BY PromedioPrecio DESC


--Mostrar cuántos carritos hay por cliente.
SELECT
    c.nombre,
    COUNT(*) CantidadCarritos
FROM sell.carrito_compras as cs 
JOIN cli.clientes as c on cs.cliente_id = c.cliente_id
GROUP BY c.nombre


--Obtener el total de unidades vendidas por producto. Mostrar solo los productos que se han vendido más de 100 unidades.
SELECT 
    p.nombre_producto,
    SUM(dv.cantidad) totalUnidades
FROM sell.detalle_ventas as dv
JOIN sell.productos as p on dv.producto_id = p.producto_id
GROUP BY p.nombre_producto
HAVING SUM(dv.cantidad) > 100
ORDER BY totalUnidades DESC;
 
--Listar los clientes con un monto total de compras superior a Q5000.
SELECT
    c.nombre,
    SUM(v.total_venta) TotalCompras
FROM sell.ventas as v 
JOIN cli.clientes as c ON c.cliente_id = v.cliente_id
GROUP BY c.nombre
HAVING SUM(v.total_venta) > 5000
ORDER BY TotalCompras DESC

--Mostrar el número de tarjetas de crédito registradas por cliente.
SELECT
    c.nombre,
    COUNT(tc.numero_tarjeta) tarjetasCliente
FROM cli.tarjetas_credito as tc 
JOIN cli.clientes as c on c.cliente_id=tc.cliente_id
GROUP BY c.nombre


--Listar categorías con más de 3 productos.
SELECT
    c.categoria,
    COUNT(p.producto_id) as totalProductos
FROM sell.productos as p 
JOIN sell.categoria as c on c.categoria_id = p.categoria_id
GROUP BY c.categoria
HAVING COUNT(p.producto_id) > 3
ORDER BY totalProductos DESC


--Obtener las marcas con un stock total (sumado entre productos) mayor a 500.
SELECT
    marca,
    SUM(stock) stockTotal 
FROM sell.productos as p 
GROUP BY marca
HAVING SUM(stock) > 500
ORDER BY stockTotal DESC

--Listar los días con ventas totales superiores a Q2000.
SELECT 
    v.fecha_venta,
    SUM(v.total_venta) AS ventasTotales
FROM sell.ventas AS v
GROUP BY v.fecha_venta
HAVING SUM(v.total_venta) > 2000
