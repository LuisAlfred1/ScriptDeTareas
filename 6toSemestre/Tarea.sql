/*
1. CÁLCULO DEL PRECIO TOTAL EN UNA UNIDAD DE MEDIDA DIFERENTE - ESCALAR

CREA UNA FUNCIÓN ESCALAR QUE RECIBA COMO PARÁMETROS EL ID DE UN PRODUCTO, UNA
CANTIDAD, Y UNA ABREVIATURA DE LA UNIDAD DE MEDIDA DESTINO. LA FUNCIÓN DEBE CALCULAR
EL PRECIO TOTAL DEL PRODUCTO EN LA NUEVA UNIDAD DE MEDIDA (POR EJEMPLO, CONVERTIR DE
LITROS A GALONES). UTILIZA ESTA FUNCIÓN PARA CALCULAR EL PRECIO TOTAL EN DIFERENTES
UNIDADES DE MEDIDA PARA UN CONJUNTO DE PRODUCTOS.
*/

create function inv.CalcularPrecioTotal(@producto_id int, @cantidad float, @Destino varchar(10))
returns float
as 
begin
	declare @umOrigenId int
	declare @umDestinoId int
	declare @factor float
	declare @precioUnitario float
	declare @precioTotal float

	--Obtener la unidad de medida original y el precio unitario del producto
	select
		@umOrigenId = um_recepcion_id,
		@precioUnitario = precio_unitario_entrega
	from inv.producto
	where producto_id = @producto_id

	--obtener el id de la unidad de destino
	select 
		@umDestinoId = um_id
	from inv.unidad_medida
	where abreviatura = @Destino

	--obtener el factor de conversión
	select
		@factor = factor
	from inv.conversion
	where um_origen_id = @umDestinoId and um_destino_id = @umOrigenId

	--Se calcula el precio total
	set @precioTotal = @cantidad * @factor * @precioUnitario
	return @precioTotal
end

--Aquí solo hago un analisis exploratorio para ver que abrevitura tiene los productos
select
	p.producto_id,
	p.nombre_producto,
	u.abreviatura
from inv.producto as p 
join inv.unidad_medida as u on u.um_id = p.um_recepcion_id

--Llamó a la función
select inv.CalcularPrecioTotal(12,5,'gl') as [Precio total]

/*
2. LISTADO DE PRODUCTOS POR UNIDAD DE MEDIDA - MSTVF
CREA UNA FUNCIÓN DE TABLA QUE RECIBA COMO PARÁMETRO UNA UNIDAD DE MEDIDA Y
DEVUELVA UNA LISTA DE PRODUCTOS QUE UTILIZAN ESA UNIDAD, JUNTO CON SU CANTIDAD EN
INVENTARIO Y SU PRECIO UNITARIO. USA ESTA FUNCIÓN PARA MOSTRAR LOS PRODUCTOS QUE USAN
UNA UNIDAD DE MEDIDA ESPECÍFICA.
*/

create function inv.ListadoProductos(@UnidadDeMedida varchar(20))
returns @ListadoProductosPorUnidad table
(
	producto_id int,
	nombre_producto varchar(100),
	stock int,
	precio_unitario_entrega decimal(10,2)
)
as 
begin
	insert into @ListadoProductosPorUnidad (producto_id,nombre_producto,stock,precio_unitario_entrega)
	select 
		p.producto_id,
		p.nombre_producto,
		p.stock,
		p.precio_unitario_entrega
	from inv.producto as p
	join inv.unidad_medida as u on u.um_id = p.um_recepcion_id
	where u.unidad_medida = @UnidadDeMedida

	return;
end;

--Lamando a la función
select * from inv.ListadoProductos('litro')