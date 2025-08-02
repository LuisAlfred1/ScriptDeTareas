/*Crea un trigger que, después de insertar o actualizar un producto en la tabla inv.producto, 
verifique si el stock actual es menor que el stock mínimo y, si es así, genere una alerta o notificación.
*/

--Tabla de alertas
CREATE TABLE inv.alertas_stock_productos (
    id INT IDENTITY PRIMARY KEY,
    producto_id INT,
    mensaje VARCHAR(250),
    fecha DATETIME DEFAULT GETDATE()
);
GO

--Referenciando el producto a la tabla alertas
ALTER TABLE inv.alertas_stock_productos
ADD CONSTRAINT FK_alertas_stock_productos
FOREIGN KEY (producto_id) REFERENCES inv.producto(producto_id);
GO

--Trigger
CREATE or ALTER TRIGGER inv.tgr_insert_update_producto ON inv.producto
AFTER INSERT, UPDATE AS
BEGIN
	INSERT INTO inv.alertas_stock_productos (producto_id,mensaje)
	SELECT
		P.producto_id,
		CONCAT(
			'Alerta: el producto ', p.nombre_producto, 
			' tiene un stock de ', p.stock, 
			' unidades, por debajo del mínimo requerido: ', p.stock_minimo, 
			' unidades.'
		)
	FROM inserted p
END
GO

--Realizando inserción donde el stock es menor al minimo
insert into inv.producto (nombre_producto, precio_unitario_entrega, codigo_de_barras, stock, stock_minimo)
values ('Agua 20L', 25.00, '9876543210987', 5, 10);

--Realizando update donde el stock es menor al minimo 
update inv.producto
set stock = 2
where producto_id = 1053;

--Verifico si creó la alerta
select * from inv.alertas_stock_productos;


/*Crea un trigger que registre cada vez que se inserta, actualiza o elimina un registro en las tablas inv.encabezado_operacion o inv.detalle_operacion
en una tabla de auditoría, manteniendo un registro histórico de las operaciones realizadas.
*/

--Se crea la tabla auditoria
CREATE TABLE inv.auditoria_operacion(
	id INT IDENTITY(1,1) PRIMARY KEY,
	registros varchar(max),
	fecha DATETIME DEFAULT GETDATE()
)
GO

--Trigger para la tabla inv.encabezado_operacion
CREATE OR ALTER TRIGGER inv.tgr_auditoria_encabezado ON inv.encabezado_operacion
AFTER INSERT, UPDATE, DELETE 
AS BEGIN 
	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO inv.auditoria_operacion (registros)
        VALUES ('Se insertó un registro en la tabla encabezado_operacion');
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO inv.auditoria_operacion (registros)
        VALUES ('Se actualizó un registro en la tabla encabezado_operacion');
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO inv.auditoria_operacion (registros)
        VALUES ('Se eliminó un registro en la tabla encabezado_operacion');
    END
END
GO

--Trigger para la tabla inv.detalle_operacion
CREATE OR ALTER TRIGGER inv.tgr_auditoria_detalle ON inv.detalle_operacion
AFTER INSERT, UPDATE, DELETE
AS BEGIN
	
	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO inv.auditoria_operacion (registros)
        VALUES ('Se insertó un registro en la tabla detalle_operacion');
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO inv.auditoria_operacion (registros)
        VALUES ('Se actualizó un registro en la tabla detalle_operacion');
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO inv.auditoria_operacion (registros)
        VALUES ('Se eliminó un registro en la tabla detalle_operacion');
    END
END 
GO

--Ejecutando insert, update y delete
INSERT INTO inv.encabezado_operacion (
    tipo_operacion_id,
    fecha,
    codigo,
    tipo_documento_id,
    creado_en
)
VALUES (
    6,
    '2025-08-01',
    NULL,
    1,
    GETDATE()
);

UPDATE inv.encabezado_operacion
set tipo_documento_id = 2
where encabezado_operacion_id = 1

DELETE FROM inv.encabezado_operacion
WHERE fecha = '2025-08-01'
GO

/*Crea un trigger que, antes de insertar un registro en la tabla inv.detalle_operacion, verifique si la cantidad solicitada de un producto 
está disponible en el stock y, si no lo está, evite la inserción y genere un mensaje de error. SOLO SI LA OPERACION ES DE SALIDA.
instead of 
*/

CREATE OR ALTER TRIGGER inv.tgr_insert_verificacion
ON inv.detalle_operacion
INSTEAD OF INSERT
AS
BEGIN
    -- Verifica si hay alguna fila con operación de salida y sin suficiente stock
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN inv.encabezado_operacion eo ON eo.encabezado_operacion_id = i.encabezado_operacion_id
        JOIN inv.tipo_operacion tope ON tope.tipo_operacion_id = eo.tipo_operacion_id
        JOIN inv.producto p ON p.producto_id = i.producto_id
        WHERE tope.operacion_ingreso = 0 -- SOLO si es salida
          AND i.cantidad > p.stock
    )
    BEGIN
        RAISERROR('Stock insuficiente para completar la operación de salida.', 16, 1);
        RETURN;
    END

    -- Si hay suficiente stock o es una operación de ingreso, permite insertar
    INSERT INTO inv.detalle_operacion (
        encabezado_operacion_id,
        producto_id,
        cantidad
    )
    SELECT 
        encabezado_operacion_id,
        producto_id,
        cantidad
    FROM inserted;
END
GO