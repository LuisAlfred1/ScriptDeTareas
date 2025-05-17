-- EJERCICIOS --

--Ejercicio 1: Crear las siguientes tablas
CREATE TABLE sell.proveedores(
    proveedor_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    nombre_proovedor NVARCHAR(100),
    direccion NVARCHAR(255),
    telefono NVARCHAR(15),
    correo_electronico NVARCHAR(100)
)

CREATE TABLE sell.inventarios(
    inventario_id INT IDENTITY(1,1) PRIMARY KEY,
    producto_id INT NOT NULL,
    proveedor_id INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_entrada DATETIME NOT NULL,
    fecha_maxima_almacenaje DATETIME,
    FOREIGN KEY (proveedor_id) REFERENCES sell.proveedores(proveedor_id),
    FOREIGN KEY (producto_id) REFERENCES sell.productos(producto_id)
)

CREATE TABLE sell.ordenes_compra(
    orden_id INT IDENTITY(1,1) PRIMARY KEY,
    proveedor_id INT NOT NULL,
    fecha_orden DATETIME,
    monto_total DECIMAL(10,2)
    FOREIGN KEY (proveedor_id) REFERENCES sell.proveedores(proveedor_id)
)


--Ejercicio 2: Agrega una columna fecha_registro (datetime) a la tabla proveedores.
ALTER TABLE sell.proveedores
ADD fecha_registro DATETIME DEFAULT GETDATE()

--Ejercicio 3: Elimina la columna fecha_maxima_almacenaje de la tabla inventarios.
ALTER TABLE sell.inventarios
DROP COLUMN fecha_maxima_almacenaje

--Ejercicio 4: Inserta nuevos clientes en la tabla clientes.
INSERT INTO cli.clientes (nombre, apellido, correo_electronico, direccion, telefono)
VALUES 
('Juan', 'Pérez', 'juan.perez@example.com', 'Calle Familia 5-23', '555-1234'),
('María', 'López', 'maria.lopez@example.com', 'Avenida Siempre Viva 456', '555-5678'),
('Carlos', 'García', 'carlos.garcia@example.com', 'Plaza Mayor 789', '555-8765'),
('Ana', 'Martínez', 'ana.martinez@example.com', 'Calle Luna 321', '555-4321'),
('Luis', 'Torres', 'luis.torres@example.com', 'Avenida Sol 654', '555-6789');

/* Ejercicio 5: Actualiza la dirección de todos los clientes que viven en 'Calle Familia 5-23' a 'Calle
Estrella 9-64'*/
UPDATE cli.clientes 
SET direccion = 'Estrella 9-64' 
WHERE direccion = 'Calle Familia 5-23'

/*Ejercicio 6: Selecciona todos los productos cuyo precio sea mayor a 100.*/
SELECT * FROM sell.productos
WHERE precio > 100

/*Ejercicio 7: Selecciona todos los clientes cuyo nombre empiece con 'J'.*/
SELECT 
    nombre
FROM cli.clientes
WHERE nombre LIKE 'J%'

/*Ejercicio 8: Selecciona el precio promedio de los productos.*/
SELECT 
    AVG(precio) as precio_promedio
FROM sell.productos

/*Ejercicio 9: Selecciona todos los productos y muestra su precio con un descuento del 10%.*/
SELECT 
    nombre_producto,
    precio,
    precio * 0.9 as [Precio con descuento del 10%]
FROM sell.productos

/*Ejercicio 10: Selecciona el nombre completo de los clientes concatenando el nombre y el apellido.*/
SELECT
    CONCAT(nombre,' ',apellido) as [nombre completo]
FROM cli.clientes

/*Ejercicio 11: Selecciona los detalles de las ventas junto con la información del cliente.*/
SELECT
    CONCAT(c.nombre,' ',c.apellido) as [Nombre cliente],
    dv.producto_id,
    dv.cantidad,
    v.fecha_venta    
FROM sell.detalle_ventas as dv
JOIN sell.ventas as v on v.venta_id=dv.venta_id
JOIN cli.clientes as c on c.cliente_id=v.cliente_id

/*Ejercicio 12: Selecciona todos los clientes y sus tarjetas de crédito, incluyendo clientes sin tarjetas. */
SELECT 
    CONCAT(nombre,' ',apellido) as [Nombre completo],
    tc.numero_tarjeta,
    tc.cvv
FROM cli.clientes as c 
LEFT JOIN cli.tarjetas_credito as tc on tc.cliente_id = c.cliente_id

/*Ejercicio 13: Selecciona todos los productos y sus categorías, incluyendo categorías sin productos.*/
SELECT 
    p.nombre_producto,
    c.categoria
FROM sell.productos as p  
RIGHT JOIN sell.categoria as c on c.categoria_id = p.categoria_id

/*Ejercicio 14: Selecciona todos los productos y las categorías, incluyendo productos sin categoría y
categorías sin productos.*/
SELECT 
    p.nombre_producto,
    c.categoria
FROM sell.productos AS p
FULL OUTER JOIN sell.categoria AS c ON p.categoria_id = c.categoria_id;

/*Ejercicio 15: Selecciona el nombre del cliente y el total de sus ventas.*/
SELECT
    CONCAT(nombre,' ',apellido) as [Nombre del cliente],
    (SELECT SUM(v.total_venta) 
     FROM sell.ventas AS v 
     WHERE v.cliente_id = c.cliente_id) AS [Total de ventas]
FROM cli.clientes as c 

/*Ejercicio 16: Crea una consulta que muestre el nombre completo de los clientes (nombre y
apellido) y una columna adicional llamada tipo_cliente, que muestre "Regular" si no
tienen tarjeta de crédito y "Premium" si tienen.*/
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS [Nombre completo],
    CASE 
        WHEN tc.numero_tarjeta IS NULL THEN 'Regular'
        ELSE 'Premium'
    END AS tipo_cliente
FROM cli.clientes AS c
LEFT JOIN cli.tarjetas_credito AS tc ON tc.cliente_id = c.cliente_id

/*Ejercicio 17: Encuentra las categorías de productos que tienen un precio promedio superior a
$50. Ordena los resultados por precio promedio de forma descendente.*/
SELECT 
    c.categoria,
    AVG(p.precio) AS precio_promedio
FROM sell.productos AS p
JOIN sell.categoria AS c ON p.categoria_id = c.categoria_id
GROUP BY c.categoria
HAVING AVG(p.precio) > 50
ORDER BY precio_promedio DESC;

/*Ejercicio 18: Une los resultados de las tablas clientes y ventas para obtener un listado de clientes y
ventas realizadas. Asegúrate de incluir una columna que indique si el registro
proviene de clientes o ventas.*/
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS [Nombre],
    'Cliente' AS origen
FROM cli.clientes AS c

UNION ALL

SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS [Nombre],
    'Venta' AS origen
FROM cli.clientes AS c
JOIN sell.ventas AS v ON c.cliente_id = v.cliente_id;

/*Ejercicio 19: Encuentra los clientes que han abandonado su carrito de compras (abandonado = 1).
Muestra su nombre, apellido y dirección.*/
SELECT 
    c.nombre,
    c.apellido,
    c.direccion
FROM cli.clientes AS c
JOIN sell.carrito_compras AS cs ON c.cliente_id = cs.cliente_id
WHERE cs.abandonado = 1;

/*Ejercicio 20: Muestra los detalles de los productos en el carrito de compras de los clientes que
tienen carritos abandonados. Incluye el nombre del cliente, nombre del producto,
cantidad y precio unitario.*/
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS [Nombre del cliente],
    p.nombre_producto,
    dc.cantidad,
    p.precio
FROM cli.clientes AS c
JOIN sell.carrito_compras AS ca ON c.cliente_id = ca.cliente_id
JOIN sell.detalle_carrito_compras AS dc ON ca.carrito_id = dc.carrito_id
JOIN sell.productos AS p ON dc.producto_id = p.producto_id
WHERE ca.abandonado = 1;




