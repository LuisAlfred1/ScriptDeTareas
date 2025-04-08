/*
Obten una lista de todos los productos junto con sus detalles de ventas, mostrando todos los productos independientemente de si se han vendido o no.
*/

SELECT top 30
    dv.cantidad,
    dv.precio_unitario,
    p.nombre_producto,
    p.descripcion
FROM sell.productos as p
LEFT JOIN sell.detalle_ventas as dv ON p.producto_id = dv.producto_id

/*
Encuentra todos los clientes junto con sus tarjetas de crédito, incluso si algunos clientes no han registrado ninguna tarjeta.
*/

SELECT top 30
    c.nombre,
    c.apellido,
    COALESCE(tc.numero_tarjeta, 'SIN TARJETA') as numero_tarjeta,
    tc.fecha_vencimiento
FROM cli.clientes as c 
LEFT JOIN cli.tarjetas_credito as tc ON c.cliente_id = tc.cliente_id

/*
Encuentra todos los clientes junto con sus direcciones de envío, incluso si algunos clientes no tienen ninguna dirección registrada.
*/

SELECT top 30 
    cliente_id,
    nombre,
    apellido,
    direccion
FROM cli.clientes


/*
Obten una lista de todos los productos en stock junto con sus detalles de ventas, mostrando todos los productos independientemente de si se han vendido o no.
*/

SELECT top 30 
    p.nombre_producto,
    p.stock,
    dv.precio_unitario,
    dv.cantidad
FROM sell.productos as p 
LEFT JOIN sell.detalle_ventas as dv ON p.producto_id = dv.producto_id
WHERE p.stock > 0;


/*
Encuentra todos los clientes junto con sus detalles de ventas, incluso si algunos clientes no han realizado ninguna compra
*/

SELECT top 30 
    c.nombre,
    c.apellido,
    v.venta_id,
    dv.producto_id,
    dv.cantidad,
    dv.precio_unitario
FROM cli.clientes as c
LEFT JOIN sell.ventas as v on c.cliente_id = v.cliente_id
LEFT JOIN sell.detalle_ventas as dv on v.venta_id = dv.venta_id


/*
Obten una lista de todos los productos vendidos junto con sus detalles de ventas, mostrando todos los productos independientemente de si se han vendido o no.
*/

SELECT top 50 
    p.nombre_producto,
    p.descripcion,
    COALESCE(dv.producto_id, 'SIN VENTAS') AS producto_id,
    dv.cantidad,
    dv.precio_unitario
FROM sell.productos as p 
LEFT JOIN sell.detalle_ventas as dv on p.producto_id = dv.producto_id