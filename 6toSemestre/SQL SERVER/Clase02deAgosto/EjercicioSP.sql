--Eliminando el cliente sin el uso de una transaccion
CREATE OR ALTER PROCEDURE cli.sp_eliminar_cliente(@cliente_id INT)
AS
BEGIN
    -- Eliminó todas las referencias del cliente_id que estan asociadas en estas tablas:
    --Eliminando sus detalles_carrito_compras
    DELETE FROM sell.detalle_carrito_compras
    WHERE carrito_id IN (
        SELECT carrito_id FROM sell.carrito_compras
        WHERE cliente_id = @cliente_id
    );

    -- Eliminando sus carrito
    DELETE FROM sell.carrito_compras
    WHERE cliente_id = @cliente_id;

    -- Eliminando sus detalles de ventas
    DELETE FROM sell.detalle_ventas
    WHERE venta_id IN (
        SELECT venta_id FROM sell.ventas
        WHERE cliente_id = @cliente_id
    );

    -- Eliminando sus ventas
    DELETE FROM sell.ventas
    WHERE cliente_id = @cliente_id;

    -- Eliminando sus tarjetas de crédito
    DELETE FROM cli.tarjetas_credito
    WHERE cliente_id = @cliente_id;

    -- Eliminando cliente
    DELETE FROM cli.clientes
    WHERE cliente_id = @cliente_id;
END;
GO



EXEC cli.sp_eliminar_cliente 3
GO

--LIstando los clientes restantes
CREATE OR ALTER PROCEDURE cli.sp_listar_clientes
AS BEGIN
    SELECT * FROM cli.clientes
END
GO

EXEC cli.sp_listar_clientes
GO