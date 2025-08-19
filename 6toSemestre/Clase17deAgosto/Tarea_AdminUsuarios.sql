--Tarea

--Usando master
USE master
GO

--Creando Logins para los usuarios
CREATE LOGIN admin_login WITH PASSWORD = 'admin@123!'
GO

CREATE LOGIN hr_login WITH PASSWORD = 'hrLogin@456!'
GO

CREATE LOGIN finance_login WITH PASSWORD = 'finance@789!'
GO 

--Usando la base de datos company_db
USE company_db

--Creando usuarios con sus respectivos Logins en la bd company_db
CREATE USER admin_user FOR LOGIN admin_login
GO 

CREATE USER hr_user FOR LOGIN hr_login
GO

CREATE USER finance_user FOR LOGIN finance_login
GO

--Creando roles
CREATE ROLE rol_admin
GO 

CREATE ROLE rol_hr
GO

CREATE ROLE rol_finance
GO

--Asignandole un rol a cada usuario
EXEC sp_addrolemember rol_admin, admin_user
GO

EXEC sp_addrolemember rol_hr, hr_user
GO

EXEC sp_addrolemember rol_finance, finance_user
GO

--Asignandole permisos especificos a cada Rol
--Para el rol_hr
--Puede leer y modificar datos en el esquema hr
GRANT SELECT, INSERT ON SCHEMA::hr TO rol_hr
GO

--Para el rol_finance
-- Le permite leer (SELECT) cualquier tabla dentro del esquema finance
GRANT SELECT ON SCHEMA::finance TO rol_finance;

--Le permite insertar únicamente en la tabla finance.expenses
GRANT INSERT ON OBJECT::finance.expenses TO rol_finance;


/*
Con esto nos aseguramos que solo pueda leer las tablas del esquema y que solo pueda insertar datos en 
en una tabla especifica del esquema.
*/

--Demostración
EXECUTE AS USER = 'finance_user'

--Permisos concedidos
INSERT INTO finance.expenses ([description],amount,expense_date) VALUES ('Nueva descript',400,CURRENT_TIMESTAMP)

SELECT * FROM finance.expenses

--Permisos denegados
INSERT INTO finance.payroll (employee_id,salary) VALUES (2,2000)

DELETE FROM finance.payroll
WHERE id = 2
