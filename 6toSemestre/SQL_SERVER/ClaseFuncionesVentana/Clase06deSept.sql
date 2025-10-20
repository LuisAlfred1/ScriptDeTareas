USE Ecommerce
/*
    EJERCICIO 1:
    Mostrar el total de compras por cliente (sin detalle), incluyendo el total histórico gastado por ese cliente.
*/
SELECT
    v.venta_id,
    CONCAT(c.nombre,' ',c.apellido) Nombre_completo,
    v.fecha_venta,
    v.total_venta,
    SUM(v.total_venta) OVER(PARTITION BY v.cliente_id ORDER BY v.fecha_venta) as Historico_cliente
FROM sell.ventas as v 
JOIN cli.clientes as c on c.cliente_id=v.cliente_id
WHERE v.cliente_id = 1

--Ejercicio 2:
--Asigne un ranking a las ventas en un periodo de tiempo segun su venta total
SELECT 
    venta_id,
    cliente_id,
    fecha_venta, 
    total_venta,
    RANK() OVER (ORDER BY total_venta DESC) as ranking_venta,
    DENSE_RANK() OVER (ORDER BY total_venta DESC) as ranking_venta_denso
FROM sell.ventas
WHERE fecha_venta BETWEEN '2021-01-01' and '2021-01-31' and cliente_id IN (200, 275)



--Ejercicio 3:
--En base al promedio de compras de un cliente, determine si su comportamiento esta fuera de los usual
SELECT 
    venta_id,
    cliente_id,
    fecha_venta, 
    total_venta,
    AVG(total_venta) OVER (PARTITION BY cliente_id) AS promedio_compras,
    CASE 
        WHEN total_venta > AVG(total_venta) OVER (PARTITION BY cliente_id) AND  ((total_venta / AVG(total_venta) OVER (PARTITION BY cliente_id))-1) > 0.3 THEN 'Posiblemente Fraudulento'
        ELSE 'Normal'
    END AS es_fraudulento,
    1 - (total_venta / AVG(total_venta) OVER (PARTITION BY cliente_id)) porcentaje_diferencia
FROM sell.ventas
WHERE fecha_venta BETWEEN '2021-01-01' and '2021-01-31' and cliente_id IN (178, 275)
ORDER BY fecha_venta ASC