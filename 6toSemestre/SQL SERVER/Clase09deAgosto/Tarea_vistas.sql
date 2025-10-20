/*
Genera una vista que liste carritos abandonados (sell.carrito_compras.abandonado = 1)
*/

CREATE VIEW sell.vw_carritos_abandonados_participacion_por_categoria as 
select 
    cc.carrito_id,
    cc.cliente_id,
    c.categoria_id,
    c.categoria,
    SUM(dc.cantidad * p.precio) as Valor_estimado_del_carrito,
    ROUND(
        100.0 * SUM(dc.cantidad * p.precio) / 
        NULLIF(SUM(SUM(dc.cantidad * p.precio)) OVER (PARTITION BY cc.carrito_id), 0), 2
    ) AS porcentaje_categoria -- Porcentaje de esta categoría respecto al total del carrito, redondeado a 2 decimales
from sell.carrito_compras as cc 
join sell.detalle_carrito_compras as dc on dc.carrito_id = cc.carrito_id
join sell.productos as p on p.producto_id = dc.producto_id
join sell.categoria as c on c.categoria_id = p.categoria_id 
where cc.abandonado = 1
group by cc.carrito_id, cc.cliente_id, c.categoria_id, c.categoria
go 

-- verificando
select * from sell.vw_carritos_abandonados_participacion_por_categoria
go

/*
Define una vista determinista de ventas por categoría y fecha 
*/

--Ejecutando primero la vista
CREATE VIEW sell.vw_ventas_por_categoria_dia
WITH SCHEMABINDING
AS
SELECT 
    c.categoria_id,
    v.fecha_venta,
    COUNT_BIG(*) AS cantidad_de_facturas, -- COUNT_BIG() es obligatorio en vistas indexadas para garantizar que el tipo de datos del conteo sea lo suficientemente grande.
    SUM(ISNULL(dv.cantidad * dv.precio_unitario, 0)) AS monto --Se usa ISNULL() para evitar valores NULL en la suma y asegurar determinismo.
FROM sell.ventas AS v 
JOIN sell.detalle_ventas AS dv ON dv.venta_id = v.venta_id
JOIN sell.productos AS p ON p.producto_id = dv.producto_id
JOIN sell.categoria AS c ON c.categoria_id = p.categoria_id
GROUP BY c.categoria_id, v.fecha_venta;
--
GO

-- Se ejecuta después de la vista.
-- Creando Índice único clúster para materializar la vista.
CREATE UNIQUE CLUSTERED INDEX IX_vw_ventas_por_categoria_dia
ON sell.vw_ventas_por_categoria_dia (categoria_id, fecha_venta);
GO

-- verificando
select * from sell.vw_ventas_por_categoria_dia