/* EJERCICIO:
Crear un login en SQL Server llamado dev_login con la siguiente contraseña: SecurePass123!
Crear un usuario en la base de datos ecommerce asociado a ese login. El nombre del usuario será dev_user
Crear un rol personalizado en la base de datos ecommerce llamado reporting_role.
Asignar al rol reporting_role permisos para SELECT en todas las tablas del esquema cli.
Agregar al usuario dev_user al rol reporting_role.
Verificar los permisos del usuario dev_user al intentar realizar consultas SELECT en las tablas cli.clientes y sell.detalle_ventas.
Documentar el resultado y explicar por qué el usuario pudo o no pudo realizar la consulta.
*/

--Usando master para crear el login desde ahí
USE master
GO

--Creando login
CREATE LOGIN dev_login WITH PASSWORD = 'SecurePass123!'
GO

--Usando Ecommerce
USE EcommerceAdmin --Es una copia que le hice a la base de datos Ecommerce
GO

--Creando usuario
CREATE USER dev_user FOR LOGIN dev_login
GO

--Creando rol
CREATE ROLE reporting_role
GO

--Asignando permisos al rol reporting_role
GRANT SELECT ON SCHEMA::cli TO reporting_role
GO

--Agregando el user al role
EXEC sp_addrolemember reporting_role, dev_user
GO

--Entrando como usuario dev_user
EXECUTE AS USER = 'dev_user'
GO

--Verificando los permisos del usuario dev_user
--Realizando SELECT a cli.clientes
/*
En este caso si nos dejará visualizar la tabla, ya que el rol que tiene el usuario(dev_user) se le concedió
los permisos para hacer SELECT a todas las tablas que estén dentro del esquema 'cli'.
Por lo tanto, además de clientes, el usuario también puede ver las tarjetas de crédito.
*/
SELECT * FROM cli.clientes
SELECT * FROM cli.tarjetas_credito


--Relizando SELECT a sell.detalle_ventas
/*
Para este caso el usuario(dev_user) no puede visualizar la tabla porque esta dentro de otro esquema(sell) al que no
se le concedió el permiso para visualizarlo.
*/
SELECT * FROM sell.detalle_ventas