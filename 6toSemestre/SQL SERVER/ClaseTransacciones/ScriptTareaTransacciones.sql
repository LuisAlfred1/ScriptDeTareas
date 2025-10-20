/*
================================================================================
  Objetivo: Plantilla inicial para el ejercicio.
  Acciones: crea objetos auxiliares (historial y antifraude), inserta producto
            de pruebas y deja el esqueleto del procedimiento principal con TODOs.
================================================================================
*/

/* ---------- Creando objetos auxiliares:  y antifraude ---------- */
--Tabla precio_historial
IF OBJECT_ID('sell.precio_historial') IS NULL
BEGIN
  CREATE TABLE sell.precio_historial(
    id INT IDENTITY PRIMARY KEY,
    producto_id INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo    DECIMAL(10,2) NOT NULL,
    motivo          VARCHAR(50)    NOT NULL, -- 'STOCK_BAJO'
    fecha_cambio    DATETIME2      NOT NULL DEFAULT SYSDATETIME()
  );
END
GO

--Esquema fraude
IF SCHEMA_ID('fraude') IS NULL EXEC('CREATE SCHEMA fraude');
GO
--Tabla fraude.operaciones
IF OBJECT_ID('fraude.operaciones') IS NULL
BEGIN
  CREATE TABLE fraude.operaciones(
    id INT IDENTITY PRIMARY KEY,
    tarjeta_hash VARBINARY(64) NOT NULL,
    ubicacion    VARCHAR(64)   NOT NULL,   -- ej. 'GT', 'SV', 'HN'
    fecha_hora   DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    venta_id     INT           NULL,
    estado       VARCHAR(16)   NOT NULL DEFAULT 'OK' -- OK | BLOQUEADA
  );
END
GO

-------------------------------Indices----------------------------
-- Índice para ventas por fecha (para reportes y consultas por rango de fecha)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ventas_fecha_venta' AND object_id = OBJECT_ID('sell.ventas'))
BEGIN
    CREATE INDEX IX_ventas_fecha_venta ON sell.ventas(fecha_venta);
    PRINT 'Índice IX_ventas_fecha_venta creado';
END
GO

-- Índice compuesto para antifraude (ventana de tiempo y filtro por ubicación)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_fraude_tarjeta_fecha_ubicacion' AND object_id = OBJECT_ID('fraude.operaciones'))
BEGIN
    CREATE INDEX IX_fraude_tarjeta_fecha_ubicacion 
    ON fraude.operaciones(tarjeta_hash, fecha_hora, ubicacion);
    PRINT 'Índice IX_fraude_tarjeta_fecha_ubicacion creado';
END
GO

/* -------------------- Semillas de prueba para el ejercicio ------------------ */
IF OBJECT_ID('sell.categoria') IS NOT NULL
BEGIN
  IF NOT EXISTS (SELECT 1 FROM sell.categoria WHERE categoria='Electrónica')
    INSERT INTO sell.categoria(categoria) VALUES ('Electrónica');
END

DECLARE @cat INT = (SELECT TOP 1 categoria_id FROM sell.categoria WHERE categoria='Electrónica');

-- Producto de pruebas (stock inicial 12 para forzar precio dinámico al bajar de 10)
IF NOT EXISTS (SELECT 1 FROM sell.productos WHERE codigo_barras='SKU-300')
BEGIN
  INSERT INTO sell.productos(codigo_barras, nombre_producto, descripcion, precio, stock, marca, categoria_id)
  VALUES ('SKU-300','Cargador USB-C','45W', 80.00, 12, 'PowerCo', @cat);
END
ELSE
BEGIN
  -- Reajusta a un estado conocido para el laboratorio
  UPDATE sell.productos SET precio=80.00, stock=12 WHERE codigo_barras='SKU-300';
END
GO

/* ----------------------- Esqueleto del procedimiento ------------------------ */
IF OBJECT_ID('sell.usp_VentaConPrecioDinamico','P') IS NOT NULL
  DROP PROCEDURE sell.usp_VentaConPrecioDinamico;
GO
CREATE PROCEDURE sell.usp_VentaConPrecioDinamico
  @cliente_id   INT,
  @producto_id  INT,
  @cantidad     INT,
  @tarjeta_hash VARBINARY(64),
  @ubicacion    VARCHAR(64),
  @n INT = 3,     -- umbral de intentos
  @t_min INT = 5  -- ventana (minutos)
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  BEGIN TRY
    BEGIN TRAN;

    /* TODO(1): Antifraude — si existen >= @n operaciones previas
       en los últimos @t_min minutos con la MISMA tarjeta y en
       ubicaciones distintas a @ubicacion, registrar intento BLOQUEADA
       en fraude.operaciones y lanzar error 50090.
    */
    DECLARE @intentos_sospechosos INT;

    SELECT @intentos_sospechosos = COUNT(*)
    FROM fraude.operaciones 
    WHERE tarjeta_hash = @tarjeta_hash
      AND fecha_hora >= DATEADD(MINUTE, -@t_min, SYSDATETIME())
      AND ubicacion <> @ubicacion
      AND estado = 'OK';

    IF @intentos_sospechosos >= @n
    BEGIN
        INSERT INTO fraude.operaciones(tarjeta_hash, ubicacion, fecha_hora, venta_id, estado)
        VALUES (@tarjeta_hash, @ubicacion, SYSDATETIME(), NULL, 'BLOQUEADA');
        
        THROW 50090, 'Operación bloqueada por actividad fraudulenta', 1;
    END

    /* TODO(2): Evitar lost updates — leer precio/stock con UPDLOCK, ROWLOCK */
    DECLARE @stock INT, @precio DECIMAL(10,2);
    SELECT @stock = p.stock, @precio = p.precio
    FROM sell.productos AS p WITH (UPDLOCK, ROWLOCK)
    WHERE p.producto_id=@producto_id;

    IF @stock IS NULL     THROW 50020, 'Producto inexistente', 1;
    IF @stock < @cantidad THROW 50021, 'Stock insuficiente', 1;

    /* TODO(3): Insertar venta y detalle con @precio unitario */
    INSERT INTO sell.ventas(cliente_id, fecha_venta, total_venta)
    VALUES (@cliente_id, SYSDATETIME(), 0.00);
    DECLARE @venta_id INT = SCOPE_IDENTITY();

    INSERT INTO sell.detalle_ventas(venta_id, producto_id, cantidad, precio_unitario)
    VALUES (@venta_id, @producto_id, @cantidad, @precio);

    /* TODO(4): Descontar stock del producto */
    UPDATE sell.productos SET stock = stock - @cantidad WHERE producto_id=@producto_id;

    /* TODO(5): Precio dinámico — si stock final < 10, subir 10% y registrar en historial */
    DECLARE @stock_final INT = (SELECT stock FROM sell.productos WHERE producto_id=@producto_id);
    IF @stock_final < 10
    BEGIN
      DECLARE @nuevo DECIMAL(10,2) = ROUND(@precio * 1.10, 2);
      UPDATE sell.productos SET precio = @nuevo WHERE producto_id=@producto_id;
      INSERT INTO sell.precio_historial(producto_id, precio_anterior, precio_nuevo, motivo)
      VALUES (@producto_id, @precio, @nuevo, 'STOCK_BAJO');
    END

    /* TODO(6): Actualizar total_venta (sumatoria del detalle) */
    UPDATE v
      SET total_venta = (
        SELECT SUM(cantidad*precio_unitario) FROM sell.detalle_ventas WHERE venta_id=v.venta_id
      )
    FROM sell.ventas v WHERE v.venta_id=@venta_id;

    /* TODO(7): Registrar operación antifraude como OK */
    INSERT INTO fraude.operaciones(tarjeta_hash, ubicacion, fecha_hora, venta_id, estado)
    VALUES (@tarjeta_hash, @ubicacion, SYSDATETIME(), @venta_id, 'OK');

    COMMIT;
  END TRY
  BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    THROW;
  END CATCH
END
GO

/* --------------------------------- Pruebas ---------------------------------- */

-- 1) Variables de prueba
DECLARE @cliente_id INT = (SELECT TOP 1 cliente_id FROM cli.clientes);
DECLARE @producto_id INT = (SELECT TOP 1 producto_id FROM sell.productos WHERE codigo_barras='SKU-300');

-- Usar hash con sal (solo demo). NO almacenar PAN real.
DECLARE @tarjeta_hash VARBINARY(64) = HASHBYTES('SHA2_256', '411111******1111|demo_salt');

-- 2) Ejecutar varias ventas para forzar stock < 10 y disparar el precio dinámico
EXEC sell.usp_VentaConPrecioDinamico @cliente_id, @producto_id, 3, @tarjeta_hash, 'GT'; -- stock 12->9
SELECT precio, stock FROM sell.productos WHERE producto_id=@producto_id; -- precio debe subir 10% al caer <10
SELECT TOP(5) * FROM sell.precio_historial WHERE producto_id=@producto_id ORDER BY fecha_cambio DESC;

-- 3) Ventana antifraude (simular múltiples ubicaciones en pocos minutos)
EXEC sell.usp_VentaConPrecioDinamico @cliente_id, @producto_id, 1, @tarjeta_hash, 'SV';
EXEC sell.usp_VentaConPrecioDinamico @cliente_id, @producto_id, 1, @tarjeta_hash, 'HN';
-- La siguiente debería BLOQUEARSE si @n=3 y @t_min=5 (ajuste según tiempos del laboratorio)
BEGIN TRY
  EXEC sell.usp_VentaConPrecioDinamico @cliente_id, @producto_id, 1, @tarjeta_hash, 'CR';
END TRY
BEGIN CATCH
  SELECT ERROR_NUMBER() AS Err, ERROR_MESSAGE() AS Msg;
END CATCH

SELECT TOP(10) * FROM fraude.operaciones ORDER BY fecha_hora DESC;

-- 4) (Guía) Concurrencia y lost update
--   Abrir otra ventana y ejecutar lecturas/escrituras simultáneas para observar
--   el patrón inseguro vs. seguro con UPDLOCK, como se vio en clase.