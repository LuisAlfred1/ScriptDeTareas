--Operaciones CRUD

--INSERTAR DATOS
--Añadi 4 libros
INSERT INTO inv.clientes(nombre,correo,telefono,direccion) VALUES
('Luis','luis@gmail.com','65544289','Milguas Zona 12'),
('Carlos','carlos@gmail.com','45237412','Milguas Zona 12'),
('Alfredo','alfred@gmail.com','41877889','Milguas Zona 12'),
('Alejandra','ale@gmail.com','46985889','Milguas Zona 12')
GO


--Añadi 6 libros
INSERT INTO inv.libros(titulo,autor,precio,stock) VALUES
('La sombra del viento', 'Carlos Ruiz Zafón', 210.00, 25),
('1984', 'George Orwell', 180.00, 20),
('Cien años de soledad', 'Gabriel García Márquez', 250.00, 15),
('Odisea','Homero',220.00,5),
('El gran Gatsby', 'F. Scott Fitzgerald', 180.00, 30),
('Fahrenheit 451', 'Ray Bradbury', 150.00, 12)
GO


--Añadi 4 pedidos
INSERT INTO inv.pedidos(cliente_id,fecha_pedido,total) VALUES
(1, '2025-03-18', 500.00),
(2, '2025-03-18', 300.00),
(3, '2025-03-18', 450.00),
(4, '2025-03-18', 600.00)


--Añadi 4 detalles de pedidos
INSERT INTO inv.detalle_pedido(pedido_id,libro_id,cantidad,precio_unitario) VALUES
(1,3,4,100),
(2,4,3,200),
(3,5,3,150),
(4,6,3,220)


--CONSULTAR DATOS
--lista de clientes
SELECT * FROM inv.clientes

--lista de libros
SELECT * FROM inv.libros

--Pedidos de un cliente en especifico
SELECT * FROM inv.pedidos WHERE cliente_id = 1
SELECT * FROM inv.pedidos WHERE cliente_id = 4

--Mostrar los detalles de un pedido determinado.
SELECT * FROM inv.detalle_pedido WHERE pedido_id=2
SELECT * FROM inv.detalle_pedido WHERE pedido_id=4

--ACTUALIZAR DATOS
--Modificar la dirección de un cliente.
UPDATE inv.clientes SET direccion = 'San Lucas 4-23' WHERE cliente_id=2
UPDATE inv.clientes SET direccion = 'San Antonio 2-54' WHERE cliente_id=4
UPDATE inv.clientes SET direccion = 'San Pedro 4-30' WHERE cliente_id=1

--Cambiar el precio de un libro.
UPDATE inv.libros SET precio = 145 WHERE libro_id=1

--Actualizar la cantidad de un libro en un pedido.
UPDATE inv.detalle_pedido SET cantidad = 10  -- Nueva cantidad que deseas asignar
WHERE pedido_id = 1  -- El ID del pedido donde quieres hacer la actualización
AND libro_id = 3;  -- El ID del libro cuya cantidad quieres actualizar

--ELIMINAR DATOS
-- Eliminar un cliente específico.
DELETE FROM inv.detalle_pedido
WHERE pedido_id IN (SELECT pedido_id FROM inv.pedidos WHERE cliente_id = 4);
DELETE FROM inv.pedidos WHERE cliente_id = 4;
DELETE FROM inv.clientes WHERE cliente_id = 4; 

--Borrar un libro del inventario.
DELETE FROM inv.detalle_pedido WHERE libro_id = 3;
DELETE FROM inv.libros WHERE libro_id = 3;

--Eliminar un pedido
DELETE FROM inv.detalle_pedido WHERE pedido_id = 3;
DELETE FROM inv.pedidos WHERE pedido_id = 3;

