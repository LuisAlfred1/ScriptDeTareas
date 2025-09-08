use Ecommerce
GO
/*
1) Gasto mensual y ranking por cliente
Para cada venta en sell.ventas, muestra: cliente_id, fecha_venta, total_venta, el
total del mes de ese cliente y el ranking del cliente dentro del mes por su total mensual
(1 = mayor gasto). Mantén el detalle por venta.
*/

--Utilcé un CTE
WITH ventas_con_mes AS (
    SELECT 
        cliente_id,
        fecha_venta,
        total_venta,
        FORMAT(fecha_venta, 'yyyy-MM') AS mes,
        -- Total gastado por cliente en ese mes
        SUM(total_venta) OVER(PARTITION BY cliente_id, FORMAT(fecha_venta, 'yyyy-MM')) AS total_mensual
    FROM sell.ventas
)
SELECT 
    cliente_id,
    fecha_venta,
    total_venta,
    mes,
    total_mensual,
    -- Ranking de clientes por gasto total mensual (1 = mayor gasto) 
    RANK() OVER(PARTITION BY mes ORDER BY total_mensual DESC) AS ranking
FROM ventas_con_mes
ORDER BY mes, ranking, cliente_id, fecha_venta;

/*
2) Primera y última compra por cliente
Para cada venta, agrega columnas con el monto de la primera compra y el monto de la
última compra del mismo cliente.
Pistas: FIRST_VALUE() y LAST_VALUE() con marco explícito ROWS BETWEEN UNBOUNDED
PRECEDING AND UNBOUNDED FOLLOWING.
*/
SELECT 
    cliente_id,
    fecha_venta,
    total_venta,
    --Para obtener el primer valor
    FIRST_VALUE(total_venta) OVER(
        PARTITION BY cliente_id
        ORDER BY fecha_venta
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS primera_compra,
    --Para obetener el último valor
    LAST_VALUE(total_venta) OVER(
        PARTITION BY cliente_id
        ORDER BY fecha_venta
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS ultima_compra
FROM sell.ventas

/*
3) Comparación con compra anterior y variación
Para cada venta, muestra también el monto de la compra anterior del mismo cliente y
la variación porcentual respecto a la anterior. Incluye la cantidad de días
transcurridos desde la compra anterior.
Pistas: LAG(total_venta), DATEDIFF(DAY, LAG(fecha_venta), fecha_venta) y
cálculo de %.
*/
SELECT
    cliente_id,
    fecha_venta,
    --La compra anterior del mismo cliente
    LAG(total_venta) OVER(PARTITION BY cliente_id ORDER BY fecha_venta) AS compra_anterior,
    -- Días entre esta compra y la anterior
    DATEDIFF(
        DAY,
        LAG(fecha_venta) OVER(PARTITION BY cliente_id ORDER BY fecha_venta),
        fecha_venta
    ) AS dias_anteriores,
    -- Variación porcentual respecto a la compra anterior
    CASE
        WHEN LAG(fecha_venta) OVER(PARTITION BY cliente_id ORDER BY fecha_venta) IS NULL
            THEN NULL -- Si no hay compra anterior, entonces se deja el campo en NULL
        ELSE
            ROUND(((total_venta - LAG(total_venta) OVER(PARTITION BY cliente_id ORDER BY fecha_venta)) 
                / LAG(total_venta) OVER(PARTITION BY cliente_id ORDER BY fecha_venta)) * 100,2)
    END AS varicion_total
FROM sell.ventas
ORDER BY cliente_id, fecha_venta

/*
4) Acumulado progresivo (LTV) por cliente
Para cada venta, calcula el acumulado histórico del cliente hasta esa fecha (running
total).
Pistas: SUM(total_venta) OVER(PARTITION BY cliente ORDER BY fecha_venta,
venta_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW).
*/
SELECT
    cliente_id,
    SUM(total_venta) OVER(PARTITION BY cliente_id ORDER BY fecha_venta)
FROM sell.ventas 