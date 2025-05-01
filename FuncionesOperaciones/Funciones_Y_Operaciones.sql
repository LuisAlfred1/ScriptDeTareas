--HOJA DE TRABAJO | FUNCIONES Y OPERACIONES
USE Ecommerce

--Ejercicio 1: Concatenación de Nombre Completo.
SELECT 
    CONCAT(nombre,' ',apellido) as [Nombre completo]
FROM cli.clientes

--Ejercicio 2: Longitud de Correo Electrónico
SELECT
    correo_electronico,
    LEN(correo_electronico) as Letras_del_correo
FROM cli.clientes

--Ejercicio 3: Fecha de Vencimiento de la Tarjeta de Crédito
SELECT
    numero_tarjeta,
    fecha_vencimiento,
    DATEDIFF(DAY,GETDATE(),fecha_vencimiento) as [Dias para vencimiento]
FROM cli.tarjetas_credito

--Ejercicio 4: Nombres de Productos en Mayúsculas
SELECT 
    UPPER(nombre_producto) as [Nombre Producto Mayúsculas]
FROM sell.productos

--Ejercicio 5: Cantidad de Caracteres en Descripción de Producto
SELECT
    nombre_producto,
    descripcion,
    LEN(descripcion) as [Longitud de descripcion]
FROM sell.productos

/*Ejercicio 6: Calcula el precio promedio de los productos en cada categoría y muestra el resultado
junto con el nombre de la categoría en una columna llamada "Precio Promedio".*/
SELECT
    c.categoria,
    AVG(p.precio) AS [Precio Promedio]
FROM sell.productos AS p
JOIN sell.categoria AS c ON c.categoria_id = p.categoria_id
GROUP BY c.categoria

/*Ejercicio 8: Encuentra la fecha de la última venta realizada y muestra el resultado en una
columna llamada "Última Venta".*/
SELECT
    MAX(fecha_venta) as [Última Venta]
FROM sell.ventas

/*Ejercicio 9: Cuenta cuántas ventas ha realizado cada cliente y muestra el resultado en una
columna llamada "Número de Ventas".*/
SELECT
    CONCAT(c.nombre,' ',c.apellido) as [Nombre completo],
    COUNT(*) as [Numero de ventas]
FROM sell.ventas as v
JOIN cli.clientes as c ON c.cliente_id = v.cliente_id
GROUP BY CONCAT(c.nombre,' ',c.apellido)

/*Ejercicio 10: Calcula cuántos productos tiene cada cliente en su carrito de compras y muestra el
resultado en una columna llamada "Productos en Carrito".*/
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS Nombre_Completo,
    COUNT(*) AS [Productos en Carrito]
FROM sell.carrito_compras AS ca
JOIN cli.clientes AS c ON c.cliente_id = ca.cliente_id
GROUP BY CONCAT(c.nombre, ' ', c.apellido)

/*Ejercicio 11: Calcula el total de ventas realizado en cada mes y muestra el resultado junto con el
nombre del mes en una columna llamada "Total Ventas".*/
SELECT 
    DATENAME(MONTH, fecha_venta) AS Mes,
    SUM(total_venta) AS [Total Ventas]
FROM sell.ventas
GROUP BY DATENAME(MONTH, fecha_venta), YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY YEAR(fecha_venta), MONTH(fecha_venta)

/*Ejercicio 12: Calcula el porcentaje de productos cuyo stock está agotado (stock = 0) y muestra el
resultado en una columna llamada "Porcentaje Agotado".*/
SELECT
    (CAST(COUNT(CASE WHEN stock = 0 THEN 1 END) AS FLOAT) / COUNT(*) * 100) AS [Porcentaje Agotado]
FROM sell.productos

/*Ejercicio 13: Cuenta cuántos productos de cada categoría se han vendido y muestra el resultado
junto con el nombre de la categoría en una columna llamada "Productos Vendidos".*/
SELECT 
    c.categoria,
    SUM(dv.cantidad) as [Productos vendidos]
FROM sell.detalle_ventas as dv 
JOIN sell.productos as p on p.producto_id = dv.producto_id
JOIN sell.categoria as c on c.categoria_id = p.categoria_id
GROUP BY c.categoria

/*Ejercicio 14: Encuentra la tarjeta de crédito más antigua registrada por cada cliente y muestra el
resultado en una columna llamada "Tarjeta Crédito Antigua".*/
SELECT
    c.cliente_id,
    CONCAT(c.nombre,' ',c.apellido) as [Nombre completo],
    MIN(fecha_vencimiento) AS [Tarjeta Crédito Antigua]
FROM cli.tarjetas_credito as tc
JOIN cli.clientes as c ON c.cliente_id = tc.cliente_id
GROUP BY c.cliente_id, c.nombre, c.apellido

/*Ejercicio 15: Calcula el precio total de todos los productos en el carrito de compras de cada
cliente y muestra el resultado en una columna llamada "Precio Total Carrito".*/
SELECT
    c.cliente_id,
    CONCAT(c.nombre,' ',c.apellido) as [Nombre],
    SUM(p.precio * dcc.cantidad) as [Precio Total Carrito]
FROM sell.carrito_compras as cc 
JOIN cli.clientes as c on c.cliente_id = cc.cliente_id
JOIN sell.detalle_carrito_compras as dcc on dcc.carrito_id=cc.carrito_id 
JOIN sell.productos as p on p.producto_id = dcc.producto_id
GROUP BY c.cliente_id, CONCAT(c.nombre,' ',c.apellido)

/*Ejercicio 16: Cuenta cuántos clientes tienen la misma dirección y muestra el resultado junto con
la dirección en una columna llamada "Clientes por Dirección".*/
SELECT 
    direccion,
    COUNT(*) AS [Clientes por Dirección]
FROM cli.clientes
GROUP BY direccion
SELECT * FROM cli.clientes

/*Ejercicio 17: Muestra los productos cuyo precio es superior al precio promedio de todos los
productos en una columna llamada "Productos Precio Superior Promedio".*/
SELECT 
    nombre_producto AS [Productos Precio Superior Promedio],
    precio
FROM sell.productos
WHERE precio > (
    SELECT AVG(precio) FROM sell.productos
);


/*Ejercicio 18: Encuentra la fecha de la primera venta realizada por cada cliente y muestra el
resultado en una columna llamada "Primera Venta".*/
SELECT
    c.cliente_id,
    CONCAT(c.nombre,' ',c.apellido) AS Nombre,
    MIN(v.fecha_venta) AS [Primera venta]
from sell.ventas as v 
JOIN cli.clientes as c on c.cliente_id = v.cliente_id 
GROUP BY c.cliente_id, c.nombre, c.apellido


/*Ejercicio 19: Cuenta cuántos productos pertenecen a una categoría específica y muestra el
resultado junto con el nombre de la categoría en una columna llamada "Productos
por Categoría".*/
SELECT 
    c.categoria AS [Categoría],
    COUNT(p.producto_id) AS [Productos por Categoría]
FROM sell.productos AS p
JOIN sell.categoria AS c ON p.categoria_id = c.categoria_id
GROUP BY c.categoria;
