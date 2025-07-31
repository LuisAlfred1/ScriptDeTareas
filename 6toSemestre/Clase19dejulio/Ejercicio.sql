/*
CONVERSION DE UNIDADES DE MEDIDA - ESCALAR
ESCRIBE UNA FUNCIÓN QUE RECIBA COMO PARÁMETRO LA ABREVIATURA DE LA UNIDAD DE
MEDIDA ORIGEN, DESTINO Y LAS UNIDADES A CONVERTIR. Y CALCULE EL RESULTADO.
*/

create function inv.ConvertirUnidad
(	@origen varchar(5),
	@destino varchar(5),
	@cantidad float
)
returns float
as
begin
	declare @umOrigenId int
	declare @umDestinoId int
	declare @factor float
 	declare @resultado float
	
	--Obtengo los ids de origen y destino
	select @umOrigenId = um_id 
	from inv.unidad_medida
	where abreviatura = @origen 

	select @umDestinoId = um_id
	from inv.unidad_medida 
	where abreviatura = @destino

	--busca el factor directo
	select @factor = factor 
	from inv.conversion
	where um_origen_id = @umOrigenId
	and um_destino_id = @umDestinoId

	--Calculando el resultado
	set @resultado = @cantidad * @factor

	return @resultado
end;

--Convirtiendo 5 kilogramos a libras
select inv.ConvertirUnidad('kg','lb',5)

--Convirtiendo 2 galones a mililitros
select inv.ConvertirUnidad('gl','ml',2)


/*
UNIDADES DE MEDIDA MÁS UTILIZADAS - MSTVF
ENCUENTRA LAS UNIDADES DE MEDIDA MÁS UTILIZADAS EN LA TABLA UNIDAD_MEDIDA. MUESTRA
LAS UNIDADES DE MEDIDA Y LA CANTIDAD DE PRODUCTOS QUE LAS UTILIZAN.
*/

create function inv.ObtenerUnidadesMasUtilizadas()
returns @UnidadMasUtilizada table
(
	um_id int,
	unidad_medida varchar(100),
	cantidad_productos int
)
as 
begin
	insert into @UnidadMasUtilizada (um_id,unidad_medida,cantidad_productos)
	select top 5
		u.um_id,
		u.unidad_medida,
		COUNT(p.producto_id)
	from inv.unidad_medida as u
	join inv.producto as p on u.um_id = p.um_recepcion_id --Utilicé el um_id de recepción
	group by u.um_id, u.unidad_medida
	order by COUNT(p.producto_id) desc
	return;
end;

--Llamo a la función
select * from inv.ObtenerUnidadesMasUtilizadas()