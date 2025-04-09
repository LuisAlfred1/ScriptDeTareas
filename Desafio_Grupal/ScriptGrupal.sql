--Grupo: Walter Mijangos y Luis Reyes

/*
🔹 Reto 1 – Top compradores del año
    Mostrar los 5 clientes que más dinero han gastado en total durante el último año, ordenados del mayor al menor.
*/

SELECT TOP 5
    c.cliente_id,
    CONCAT(c.nombre,' ',c.apellido) as Cliente,
    SUM(V.total_venta) AS Total_De_Gastos
FROM cli.clientes c 
JOIN sell.ventas v on c.cliente_id = v.cliente_id
WHERE YEAR(V.fecha_venta) = YEAR(GETDATE()) - 4  --Año 2021 // La BD de Ecommerce tiene registros del año 2021 
GROUP BY c.cliente_id, CONCAT(c.nombre,' ',c.apellido)
ORDER BY Total_De_Gastos DESC;


/*
🔹 Reto 2 – Categorías sin productos vendidos
    Encontrar las categorías que no han tenido ningún producto vendido.
*/

SELECT 
    c.categoria_id,
    c.categoria
FROM sell.categoria as c 
LEFT JOIN sell.productos as p ON c.categoria_id = p.categoria_id
LEFT JOIN sell.detalle_ventas dv ON p.producto_id = dv.producto_id
WHERE dv.producto_id IS NULL;

/*
🔹 Reto 3 – Días con mayor volumen de ventas
   Listar los 3 días con más cantidad de productos vendidos (sumando todas las ventas del día).
*/




/*
🔹 Reto 4 – Productos con mejor desempeño en stock
    Mostrar los productos que han vendido más del 50% de su stock actual.
*/



/*
🔹 Reto 5 – Clientes sin compras pero con carritos
    Encontrar los clientes que no han realizado ninguna compra, pero tienen al menos un carrito creado.
*/