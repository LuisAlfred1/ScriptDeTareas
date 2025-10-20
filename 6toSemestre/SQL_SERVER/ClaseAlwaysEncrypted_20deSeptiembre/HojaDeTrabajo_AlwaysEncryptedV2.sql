CREATE DATABASE EmpresaDB
GO

USE EmpresaDB
GO

CREATE TABLE Empleados(
	id_empleado INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(100),
	apellido VARCHAR(100),
	direccion VARCHAR(100),
	dpi NVARCHAR(50) COLLATE Latin1_General_BIN2 ENCRYPTED WITH(
		ENCRYPTION_TYPE = DETERMINISTIC, -- Tipo de encriptación
		ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256',-- Algoritmo usado para cifrar los datos
		COLUMN_ENCRYPTION_KEY = CEK_empleado --Es la Llave de encriptación creada previamente
	)
)
GO

--Insertando datos, declarandolo como parametros
DECLARE @nombre VARCHAR(100) = 'Carlos'
DECLARE @dpi NVARCHAR(50) = '223134666'

INSERT INTO Empleados (nombre,dpi)
VALUES (@nombre,@dpi)

--Visualizacion de la encriptación
SELECT * FROM Empleados