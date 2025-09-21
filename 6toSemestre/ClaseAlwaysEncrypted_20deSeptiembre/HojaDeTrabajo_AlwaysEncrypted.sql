CREATE DATABASE EmpresaDB
GO

USE EmpresaDB

CREATE TABLE Empleados(
	id_empleado INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(200) NULL,
	apellido VARCHAR(200) NULL,
	direccion VARCHAR(200) NULL,
	/*dpi: Este campo est� protegido con Always Encrypted para garantizar
      que la informaci�n sensible se almacene cifrada.
	*/
	dpi VARCHAR(13) COLLATE Latin1_general_BIN2 -- Collation BIN2 requerido por Always Encrypted
		ENCRYPTED WITH(
			COLUMN_ENCRYPTION_KEY = CEK1, --Es la Llave de encriptaci�n creada previamente
			ENCRYPTION_TYPE = DETERMINISTIC,-- Tipo de encriptaci�n (permite b�squedas exactas)
			ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'-- Algoritmo usado para cifrar los datos
		) NULL
)
GO