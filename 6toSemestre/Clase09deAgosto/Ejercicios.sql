---Primer ejercicio

CREATE VIEW sell.vw_RFM_por_cliente AS
SELECT 
    c.cliente_id,
    c.nombre,
    c.apellido,
    DATEDIFF(DAY,MAX(v.fecha_venta),GETDATE()) recencia_dias,
    COUNT(DISTINCT v.venta_id) as frecuencia_ventas,
    SUM(dv.cantidad * dv.precio_unitario) as [Monto total]
FROM sell.detalle_ventas as dv
JOIN sell.ventas AS v on v.venta_id = dv.venta_id
JOIN cli.clientes as c on c.cliente_id = v.cliente_id
GROUP BY c.cliente_id, c.nombre, c.apellido
GO

--Segundo ejercicio

CREATE VIEW sell.vw_rotacion_inventario_por_producto as
select 
    p.producto_id,
    p.nombre_producto,
    p.marca,
    c.categoria,
    SUM(dv.cantidad) as [Unidades vendidas en los últimos 30 días],
    SUM(dv.cantidad * dv.precio_unitario) as Monto_vendido_ultimos_30_días,
    (p.stock * p.precio) as Valor_inventario,
    (p.stock * p.precio)/(SUM(dv.cantidad * dv.precio_unitario)/30) as [Dias de cobertura]
from sell.productos as p 
join sell.categoria as c on c.categoria_id = p.categoria_id
join sell.detalle_ventas as dv on dv.producto_id = p.producto_id
join sell.ventas as v on v.venta_id = dv.venta_id
where v.fecha_venta >= DATEADD(DAY,-30,GETDATE()) --Filtra solo las ventas realizadas en los últimos 30 días desde la fecha actual
group by 
    p.producto_id,
    p.nombre_producto,
    p.marca,
    c.categoria,
    p.stock,
    p.precio
GO