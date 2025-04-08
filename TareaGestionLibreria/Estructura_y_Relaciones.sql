CREATE SCHEMA inv

CREATE TABLE inv.clientes(
    cliente_id INT IDENTITY NOT NULL,
    nombre VARCHAR(100),
    correo VARCHAR(100),
    telefono VARCHAR(15),
    direccion VARCHAR(255)
)
GO

ALTER TABLE inv.clientes
ADD CONSTRAINT Pk_clientes PRIMARY KEY(cliente_id)

CREATE TABLE inv.libros(
    libro_id INT IDENTITY NOT NULL,
    titulo VARCHAR(150),
    autor VARCHAR(100),
    precio DECIMAL(10,2),
    stock int
)
GO

ALTER TABLE inv.libros
ADD CONSTRAINT Pk_libros PRIMARY KEY(libro_id)

CREATE TABLE inv.pedidos(
    pedido_id INT IDENTITY NOT NULL,
    cliente_id INT,
    fecha_pedido DATETIME,
    total DECIMAL(10,2)
)
GO
ALTER TABLE inv.pedidos
ADD CONSTRAINT Pk_pedidos PRIMARY KEY(pedido_id)

ALTER TABLE inv.pedidos ADD CONSTRAINT FK_pedidos_cliente FOREIGN KEY (cliente_id) REFERENCES inv.clientes(cliente_id);

CREATE TABLE inv.detalle_pedido(
    detalle_id INT IDENTITY NOT NULL,
    pedido_id INT,
    libro_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2)
)
GO

ALTER TABLE inv.detalle_pedido ADD CONSTRAINT Fk_detalle_pedido FOREIGN KEY (pedido_id) REFERENCES inv.pedidos(pedido_id);

ALTER TABLE inv.detalle_pedido ADD CONSTRAINT Fk_detalle_libro
FOREIGN KEY (libro_id) REFERENCES inv.libros(libro_id);