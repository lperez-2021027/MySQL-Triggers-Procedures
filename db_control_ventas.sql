/* 	
	Nombre:	Luis Carlos Pérez
*/


-- -----------------------------------------------------
-- Nombre de la base de datos: db_control_ventas
-- -----------------------------------------------------
DROP DATABASE IF EXISTS db_control_ventas;
CREATE DATABASE IF NOT EXISTS db_control_ventas;
USE db_control_ventas;


-- -----------------------------------------------------
-- Tabla: productos
-- -----------------------------------------------------
DROP TABLE IF EXISTS productos;

CREATE TABLE IF NOT EXISTS productos (
  id INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  existencia INT NULL DEFAULT '0',
  precio_unitario DECIMAL(10,2) NULL DEFAULT '0.00',
  precio_docena DECIMAL(10,2) NULL DEFAULT '0.00',
  precio_mayor DECIMAL(10,2) NULL DEFAULT '0.00',
  PRIMARY KEY (id)
);


-- -----------------------------------------------------
-- Tabla: compras
-- -----------------------------------------------------
DROP TABLE IF EXISTS compras;

CREATE TABLE IF NOT EXISTS compras (
  id INT NOT NULL AUTO_INCREMENT,
  fecha DATE NOT NULL,
  PRIMARY KEY (id)
);


-- -----------------------------------------------------
-- Tabla: ventas
-- -----------------------------------------------------
DROP TABLE IF EXISTS ventas;

CREATE TABLE IF NOT EXISTS ventas (
  id INT NOT NULL AUTO_INCREMENT,
  fecha DATE NOT NULL,
  PRIMARY KEY (id)
);


-- -----------------------------------------------------
-- Tabla: detalle_compras
-- -----------------------------------------------------
DROP TABLE IF EXISTS detalle_compras;

CREATE TABLE IF NOT EXISTS detalle_compras (
  id INT NOT NULL AUTO_INCREMENT,
  compra_id INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL,
  total DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (id),
  CONSTRAINT fk_productos_detalle_compras
    FOREIGN KEY (producto_id)
    REFERENCES productos (id),
  CONSTRAINT fk_compras_detalle_compras
    FOREIGN KEY (compra_id)
    REFERENCES compras (id)
);


-- -----------------------------------------------------
-- Tabla: detalle_ventas
-- -----------------------------------------------------
DROP TABLE IF EXISTS detalle_ventas;

CREATE TABLE IF NOT EXISTS detalle_ventas (
  id INT NOT NULL AUTO_INCREMENT,
  venta_id INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_productos_detalle_ventas
    FOREIGN KEY (producto_id)
    REFERENCES productos (id),
  CONSTRAINT fk_ventas_detalle_ventas
    FOREIGN KEY (venta_id)
    REFERENCES ventas (id)
);

-- SERIE I:

-- -----------------------------------------------------
-- 1. Procedimiento almacenado para insertar ventas
-- -----------------------------------------------------
DELIMITER $$
drop procedure if exists sp_ventas_create$$
create procedure sp_ventas_create (in _fecha date)
begin
	insert into ventas (
    fecha
    ) values(
		_fecha
    );
end$$
DELIMITER ;

-- -----------------------------------------------------
-- 2. Procedimiento almacenado para insertar compras
-- -----------------------------------------------------
DELIMITER $$
drop procedure if exists sp_compras_create$$
create procedure sp_compras_create(in _fecha date)
begin
	insert into compras (
    fecha
    ) values(
		_fecha
    );
end$$
DELIMITER $$


-- -------------------------------------------------------------
-- 3. Procedimiento almacenado para insertar detalles de compras
-- -------------------------------------------------------------
DELIMITER $$
drop procedure if exists sp_detalle_compras_create$$
create procedure sp_detalle_compras_create(
	in _compra_id int, 
    in _producto_id int,
    in _cantidad int,
    in _total decimal (10,2))
begin
	insert into detalle_compras (
    compra_id,
    producto_id,
    cantidad,
    total
    )values (
    _compra_id, 
    _producto_id,
	_cantidad,
	_total
    );
end $$
DELIMITER ;



-- -----------------------------------------------------
-- 4. Procedimiento almacenado para insertar productos
-- -----------------------------------------------------
DELIMITER $$
drop procedure if exists sp_productos_create$$
create procedure sp_productos_create(in _nombre varchar(50))
begin
	insert into productos (
    nombre
    ) values(
		_nombre
    );
end$$
DELIMITER $$



-- --------------------------------------------------------
-- 5. Procedimiento almacenado para insertar detalle ventas
-- --------------------------------------------------------
DELIMITER $$
drop procedure if exists sp_detalle_ventas_create$$
create procedure sp_detalle_ventas_create(
	in _venta_id int, 
    in _producto_id int,
    in _cantidad int)
begin
	insert into detalle_ventas (
    venta_id,
    producto_id,
    cantidad
    )values (
    _venta_id, 
    _producto_id,
	_cantidad
    );
end $$
DELIMITER ;


-- SERIE II:
-- Las instrucciones específicas se encuentran en el documento PDF proporcionado.


-- -------------------------------------------------------------------------
-- 1. Trigger para actualizar existencias (agregando la cantidad comprada).
-- -------------------------------------------------------------------------
DELIMITER $$
drop trigger if exists tr_detalle_compras_after_insert1 $$
create trigger tr_detalle_compras_after_insert1
after insert 
on detalle_compras
for each row
begin
	update 
		productos 
	set 
		existencia = existencia + new.cantidad
    where id = new.producto_id;
end $$
DELIMITER ;



-- -------------------------------------------------------------------------
-- 2. Trigger para actualizar existencias (restando la cantidad vendida)
-- -------------------------------------------------------------------------
DELIMITER $$
drop trigger if exists tr_detalle_ventas_after_insert $$
create trigger tr_detalle_ventas_after_insert
after insert 
on detalle_ventas
for each row
begin
	update 
		productos 
	set 
		existencia = existencia - new.cantidad
    where id = new.producto_id;
end $$
DELIMITER ;


-- -----------------------------------------------------
-- 3. Trigger para actualizar precios de productos
-- -----------------------------------------------------
/*DELIMITER $$
drop trigger if exists tr_detalle_compras_after_insert$$
create trigger tr_detalle_compras_after_insert
after insert
on detalle_compras
for each row
begin
	update
		productos
	set 
		precio_unitario = (new.total/new.cantidad) + ((new.total/new.cantidad)*0.35),
        precio_docena = (new.total/new.cantidad) + ((new.total/new.cantidad)*0.25),
        precio_mayor = (new.total/new.cantidad) + ((new.total/new.cantidad)*0.15)
	where 
		id = new.producto_id;
end $$
DELIMITER ;*/

-- mi forma:

DELIMITER $$
drop trigger if exists tr_detalle_compras_after_insert2 $$
create trigger tr_detalle_compras_after_insert2
after insert
on detalle_compras
for each row
begin
	update productos set precio_unitario = ((new.total/new.cantidad) * 0.40) + 
    (new.total/new.cantidad)
    where id = new.producto_id;
    
    update productos set precio_docena = ((new.total/new.cantidad) * 0.30) + 
    (new.total/new.cantidad)
    where id = new.producto_id;
    
    update productos set precio_mayor = ((new.total/new.cantidad) * 0.18) + 
    (new.total/new.cantidad)
    where id = new.producto_id;
end $$
DELIMITER ;



-- -------------------------------------------------------------------------
-- Al finalizar se ejecutar lo siguiente:
-- -------------------------------------------------------------------------

call sp_ventas_create(now());
call sp_ventas_create('2019-12-01');
call sp_ventas_create('2010-09-11');
call sp_ventas_create('2020-01-01');
call sp_ventas_create('2003-03-01');

call sp_compras_create('2012-12-02');
call sp_compras_create('2010-12-02');
call sp_compras_create('2009-09-12');
call sp_compras_create('2009-01-02');
call sp_compras_create('2003-03-02');

call sp_productos_create('Televisores 65 Curve LG');
call sp_productos_create('Laptop AlienWare i9');
call sp_productos_create('Lavadoras ');
call sp_productos_create('Equipo de Sonido AIWA');
call sp_productos_create('Walkman Sony Antishok');

call sp_detalle_compras_create(1, 1, 10, 100000);
call sp_detalle_compras_create(2, 2, 5, 100000);
call sp_detalle_compras_create(3, 3, 20, 50000);
call sp_detalle_compras_create(4, 4, 10, 250000);
call sp_detalle_compras_create(5, 5, 10, 456666);

call sp_detalle_ventas_create(1, 1, 6);
call sp_detalle_ventas_create(2, 2, 4);
call sp_detalle_ventas_create(3, 3, 4);
call sp_detalle_ventas_create(4, 5, 2);
call sp_detalle_ventas_create(5, 5, 5);

select * from ventas;
select * from productos;
select * from detalle_ventas;
