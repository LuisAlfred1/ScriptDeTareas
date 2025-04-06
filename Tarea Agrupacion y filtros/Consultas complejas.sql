--Consultas complejas

--Encuentre el número total de ventas realizadas en cada mes durante el último año.
SELECT
    YEAR(v.fecha_venta) AS Año,
    MONTH(v.fecha_venta) AS Mes,
    COUNT(*) AS TotalVentas
FROM sell.ventas AS v
WHERE v.fecha_venta >= DATEADD(YEAR, -1, GETDATE())  -- Filtra solo el último año
GROUP BY YEAR(v.fecha_venta), MONTH(v.fecha_venta)
ORDER BY Año DESC, Mes DESC;


--Seleccione el nombre y el total de compras realizadas por cada cliente, pero solo para aquellos clientes cuyo total de compras supere 100 dolares.
SELECT 
    c.nombre, 
    SUM(v.total_venta) TotalCompras
FROM cli.clientes AS c
JOIN sell.ventas AS v ON c.cliente_id = v.cliente_id
GROUP BY c.cliente_id, c.nombre
HAVING SUM(v.total_venta) > 100;

--Encuentre el producto más vendido en cada categoría.
SELECT 
    p.categoria_id,
    p.nombre_producto,
    SUM(dv.cantidad) TotalVendidos
FROM sell.detalle_ventas AS dv
JOIN sell.productos as p ON dv.producto_id = p.producto_id
GROUP BY p.categoria_id, p.nombre_producto
ORDER BY p.categoria_id, TotalVendidos DESC

--Seleccione el nombre del producto y la cantidad vendida para los productos que hayan sido vendidos más de 20 veces.
SELECT 
    p.nombre_producto,
    SUM(dv.cantidad) CantidadVendida
FROM sell.detalle_ventas AS dv
JOIN sell.productos as p ON dv.producto_id = p.producto_id
GROUP BY p.nombre_producto
HAVING SUM(dv.cantidad) > 20






