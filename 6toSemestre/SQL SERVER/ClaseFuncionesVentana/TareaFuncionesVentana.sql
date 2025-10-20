-- Luis Reyes - 2300319

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
GO

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
GO

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
GO

/*
4) Acumulado progresivo (LTV) por cliente
Para cada venta, calcula el acumulado histórico del cliente hasta esa fecha (running
total).
Pistas: SUM(total_venta) OVER(PARTITION BY cliente ORDER BY fecha_venta,
venta_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW).
*/
SELECT
    cliente_id,
    fecha_venta,
    total_venta,
    SUM(total_venta) OVER(
        PARTITION BY cliente_id 
        ORDER BY fecha_venta, 
        venta_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- Desde la primera compra hasta la actual
    ) AS [Acumulado progresivo]
FROM sell.ventas
ORDER BY cliente_id, fecha_venta, venta_id
GO

/*
5) Top por categoría con ranking de productos vendidos
Usando sell.detalle_ventas, sell.productos y sell.categoria, calcula el total
de unidades vendidas por producto y, dentro de cada categoría, asigna un ranking del
1 en adelante (1 = más vendido). Muestra solo los 3 primeros por categoría.
Pistas: SUM(dv.cantidad) + RANK() OVER(PARTITION BY categoria ORDER BY
total DESC); filtra ranking <= 3.
--------
SQL Server no permite usar funciones de ventana en el HAVING directamente.
Por eso debemos usar un CTE
*/

WITH productos_rank AS (
    SELECT 
        c.categoria,
        p.producto_id,
        p.nombre_producto,
        
        -- Total de unidades vendidas por producto
        SUM(dv.cantidad) AS total_unidades_vendidas,
        
        -- Ranking dentro de cada categoría
        RANK() OVER(
            PARTITION BY c.categoria_id
            ORDER BY SUM(dv.cantidad) DESC
        ) AS ranking
    FROM sell.detalle_ventas AS dv
    JOIN sell.productos AS p 
        ON p.producto_id = dv.producto_id
    JOIN sell.categoria AS c 
        ON c.categoria_id = p.categoria_id
    GROUP BY 
        c.categoria_id,
        c.categoria,
        p.producto_id,
        p.nombre_producto
)
-- Solo mostrar los 3 primeros por categoría
SELECT * FROM productos_rank
WHERE ranking <=3
ORDER BY categoria, ranking
GO

/*
6) Cuartiles de ventas individuales
Clasifica cada venta de sell.ventas en cuartiles según total_venta a nivel global (1
= mayores montos, 4 = menores).
Pistas: NTILE(4) OVER(ORDER BY total_venta DESC).
*/

SELECT
    cliente_id,
    fecha_venta,
    total_venta,
    NTILE(4) OVER(ORDER BY total_venta DESC) AS cuartil    
FROM sell.ventas 
GO

/*
7) Análisis de carritos: aporte por línea y total
Para cada línea de sell.detalle_carrito_compras, muestra: carrito_id,
producto_id, cantidad, el total de ítems del carrito y el porcentaje que aporta la
línea respecto al total de ítems del carrito.
Pistas: SUM(cantidad) OVER(PARTITION BY carrito_id) y porcentaje = cantidad
/ SUM(...) OVER(...).
*/
SELECT
    carrito_id,
    producto_id,
    cantidad,
    -- Total de ítems del carrito
    SUM(cantidad) OVER(PARTITION BY carrito_id) total_items_carrito,
    -- Porcentaje que aporta la línea
    CASE
        WHEN SUM(cantidad) OVER(PARTITION BY carrito_id) = 0
            THEN NULL
         ELSE CAST(cantidad AS DECIMAL(10,2)) 
             / CAST(SUM(cantidad) OVER(PARTITION BY carrito_id) AS DECIMAL(10,2)) * 100
    END AS porcentaje
FROM sell.detalle_carrito_compras
ORDER BY carrito_id, producto_id
GO

/*
8) Carritos abandonados con valor estimado
Para carritos sell.carrito_compras abandonados (abandonado=1), estima el valor
total del carrito sumando cantidad * precio (unir con sell.productos) y muéstralo
junto con el porcentaje que aporta cada línea al valor total del carrito. Mantén el detalle
por línea.
Pistas: SUM(cantidad*precio) OVER(PARTITION BY carrito_id) y proporción por
línea.
*/
SELECT
    cc.carrito_id,
    dcc.producto_id,
    --Valor total del carrito
    SUM(dcc.cantidad * p.precio) OVER(PARTITION BY cc.carrito_id) total_carrito,
    -- Porcentaje que aporta esta línea al valor total
    CASE
        WHEN SUM(dcc.cantidad * p.precio) OVER(PARTITION BY cc.carrito_id) = 0 THEN NULL
        ELSE CAST(dcc.cantidad * p.precio AS DECIMAL(10,2)) 
             / CAST(SUM(dcc.cantidad * p.precio) OVER(PARTITION BY cc.carrito_id) AS DECIMAL(10,2)) * 100
    END AS porcentaje_linea
FROM sell.carrito_compras as cc 
JOIN sell.detalle_carrito_compras as dcc on dcc.carrito_id = cc.carrito_id
JOIN sell.productos as p on p.producto_id = dcc.producto_id
WHERE cc.abandonado = 1
ORDER BY cc.carrito_id, dcc.producto_id
GO

/*
9) Rendimiento mensual por región y ranking de vendedores (stg.sales)
En stg.sales, calcula por cada SalesRegion y mes el total mensual por vendedor
(SalesPersonName). Luego, dentro de cada región y mes, asigna el ranking del
vendedor por ese total y su percentil cuartil. Mantén las filas originales y añade
columnas de totales/posiciones.
Pistas: SUM(SalesAmount) OVER(PARTITION BY SalesRegion, mes,
SalesPersonName) y luego DENSE_RANK() OVER(PARTITION BY SalesRegion, mes
ORDER BY total DESC) + NTILE(4).
*/

--Como no tenía la tabla correspondiente, la cree
CREATE TABLE stg.sales (
    SalesID INT IDENTITY(1,1) PRIMARY KEY,
    SalesRegion NVARCHAR(50),
    SalesPersonName NVARCHAR(100),
    SalesAmount DECIMAL(10,2),
    SalesDate DATE
);
GO

--Inserté datos de prueba
INSERT INTO stg.sales (SalesRegion, SalesPersonName, SalesAmount, SalesDate)
VALUES
('Norte', 'Juan', 500, '2025-01-05'),
('Norte', 'Ana', 700, '2025-01-10'),
('Sur', 'Luis', 800, '2025-01-07'),
('Sur', 'Marta', 600, '2025-01-20');
GO

--Query
WITH ventas_mensuales AS (
    SELECT
        SalesRegion,
        SalesPersonName,
        FORMAT(SalesDate,'yyyy-MM') AS mes,
        SUM(SalesAmount) OVER(PARTITION BY SalesRegion, FORMAT(SalesDate,'yyyy-MM'), SalesPersonName) AS total_mensual
    FROM stg.sales
)
SELECT
    SalesRegion,
    SalesPersonName,
    mes,
    total_mensual,
    
    -- Ranking por total mensual dentro de cada región y mes
    DENSE_RANK() OVER(PARTITION BY SalesRegion, mes ORDER BY total_mensual DESC) AS ranking_vendedor,
    
    -- Cuartil (percentil) dentro de cada región y mes
    NTILE(4) OVER(PARTITION BY SalesRegion, mes ORDER BY total_mensual DESC) AS cuartil
FROM ventas_mensuales
ORDER BY SalesRegion, mes, ranking_vendedor;
GO

/*
10) Promedio móvil de 3 compras por cliente
Para cada venta, calcula el promedio de las últimas 3 compras del mismo cliente
(incluyendo la actual).
Pistas: AVG(total_venta) OVER(PARTITION BY cliente ORDER BY fecha_venta,
venta_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).
*/

SELECT
    v.cliente_id,
    v.fecha_venta,
    v.total_venta,
    AVG(v.total_venta) OVER(
        PARTITION BY c.cliente_id
        ORDER BY v.fecha_venta, v.venta_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_movil_3_compras
FROM sell.ventas as v
JOIN cli.clientes as c on c.cliente_id = v.cliente_id
ORDER BY v.cliente_id, v.fecha_venta
GO
