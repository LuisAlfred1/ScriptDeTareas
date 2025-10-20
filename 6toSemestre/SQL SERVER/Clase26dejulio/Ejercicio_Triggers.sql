--Cree la tabla system_logs.insercion
create table system_logs.insercion(
	fecha_creacion datetime not null default CURRENT_TIMESTAMP,
	registros varchar(max)
)
go

--luego la modifiqué para agregar al usuario
alter table system_logs.insercion
add usuario varchar(200)

--Cree la tabla system_logs.modificaciones
create table system_logs.modificaciones(
	usuario varchar(200),
	fecha_modificacion datetime not null default getdate(),
	registros_anteriores varchar(max),
	registros varchar(max)
)

--> Trigger de insert para la tabla inv.producto
create or alter trigger inv.tgr_insercion_productos on inv.producto
after insert
as begin
	insert into system_logs.insercion (usuario,fecha_creacion,registros)
	select
		ORIGINAL_LOGIN(),
		GETDATE(),
		CONCAT(
			'Se agrego el Producto: ', p.nombre_producto, 
			' con un precio unitario de ',p.precio_unitario_entrega,
			' con el Id: ',p.producto_id
		)
	from inserted p
end
go

--Ejecutando una insercion en la tabla productos
insert into inv.producto (nombre_producto,precio_unitario_entrega,codigo_de_barras)
values ('Garrafon',50,'11AB')

--Verificando el registro
select * from system_logs.insercion

--> Trigger de update para la tabla inv.producto
create or alter trigger inv.tgr_update_productos on inv.producto
after update as
begin 
	insert into system_logs.modificaciones(usuario,fecha_modificacion,registros_anteriores,registros)
	select
		ORIGINAL_LOGIN(),
		GETDATE(),
		CONCAT(
			'Antes: Producto: ', d.nombre_producto, 
			' con un precio unitario de ',d.precio_unitario_entrega,
			' con el Id: ',d.producto_id
		),
		CONCAT(
			'Después: Producto: ', p.nombre_producto, 
			' con un precio unitario de ',p.precio_unitario_entrega,
			' con el Id: ',p.producto_id
		)
	from inserted p
	join deleted d on p.producto_id = d.producto_id
end
go

--ejecutando una modificación en la tabla productos
update inv.producto
set nombre_producto ='Garrafon25L', precio_unitario_entrega=75
where producto_id = 54

--verificando la modificación
select * from system_logs.modificaciones