/*
Crear un procedimiento almacenado que inserte un nuevo cliente en la tabla [cli].[clientes] y su tarjeta
de crédito asociada en la tabla [cli].[tarjetas_credito]

Crear el procedimiento almacenado sp_insertar_cliente_y_tarjeta.
El procedimiento debe aceptar los siguientes parámetros de entrada:
*/
CREATE OR ALTER PROCEDURE cli.sp_insertar_cliente_y_tarjeta
(
    @nombre varchar(50),
    @apellido varchar(50),
    @correoElectronico varchar(100),
    @contrasena nvarchar(128),
    @direccion varchar(255),
    @telefono varchar(15),
    @numeroTarjeta nvarchar(50),
    @fechaVencimiento date,
    @cvv nvarchar(10)
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Insertando al cliente
        INSERT INTO cli.clientes (nombre, apellido, correo_electronico, contrasena, direccion, telefono)
        VALUES (@nombre, @apellido, @correoElectronico, @contrasena, @direccion, @telefono);

        --Estoy utilzando la funcion SCOPE_IDENTITY para Obtener el ID
        DECLARE @cliente_id INT = SCOPE_IDENTITY();

        -- Insertando tarjeta de crédito del cliente
        INSERT INTO cli.tarjetas_credito (cliente_id, numero_tarjeta, fecha_vencimiento, cvv)
        VALUES (@cliente_id, @numeroTarjeta, @fechaVencimiento, @cvv);

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK; --Deshace los cambios
        THROW; --Muestra el error
    END CATCH
END
GO

--Ejecutando procedimiento
EXEC cli.sp_insertar_cliente_y_tarjeta
    'Luis',
    'Mendoza',
    'Luismendoza@example.com',
    'Password123!',
    'Av. Las Américas 456, Zona 16',
    '50255551234',
    '4111111111111111',
    '2026-12-31',
    '123';
