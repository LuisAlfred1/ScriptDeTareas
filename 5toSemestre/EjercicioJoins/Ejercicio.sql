--EJERCICIO

--obtener todas tarjetas de creditos registradas para cada cliente
SELECT TOP 10
    tc.tarjeta_id,
    tc.numero_tarjeta,
    c.nombre,
    c.apellido
FROM cli.tarjetas_credito AS tc
JOIN cli.clientes AS c ON tc.cliente_id = c.cliente_id

--Muestra todos los carritos junto con los productos y sus marcas

SELECT top 10
p.nombre_producto,
p.marca,
car.carrito_id,
car.cliente_id,
car.abandonado
from sell.productos as p
CROSS JOIN sell.carrito_compras as car

--obtener todos los clientes que no tiene tarjeta de credito registrados

SELECT 
    c.nombre,
    c.apellido
FROM cli.clientes as c
LEFT JOIN cli.tarjetas_credito AS tc ON c.cliente_id = tc.cliente_id
WHERE tc.cliente_id IS NULL