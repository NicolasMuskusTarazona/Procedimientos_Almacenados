-- Active: 1750200622805@@127.0.0.1@3307@Pizzeria
-- 1. Insert detalle pedido 

DELIMITER $$

CREATE TRIGGER tg_before_insert_detalle_pedido
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    IF NEW.cantidad < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser al menos 1';
    END IF;
END $$

DELIMITER ;

INSERT INTO detalle_pedido (pedido_id, cantidad)VALUES (1, 0);

-- 2. Disminuir Stock de ingredientes
DELIMITER $$
CREATE TRIGGER tg_after_disminuir_stock_ingrediente
AFTER UPDATE ON ingrediente
FOR EACH ROW 
BEGIN
    IF NEW.stock < OLD.stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El stock a bajao';
    END IF;
END $$

DELIMITER ;
UPDATE ingrediente  SET stock = 19 WHERE id = 1;

-- 3. Actualizar Precio Producto

DELIMITER $$

CREATE TRIGGER tg_validar_cambio_precio
BEFORE UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    IF NEW.precio <> OLD.precio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Precio actualizado correctamente';
    END IF;
END $$

DELIMITER ;

UPDATE producto_presentacion SET precio = 6000 WHERE producto_id = 1 AND presentacion_id = 1;

-- 4. Eliminar Producto
DELIMITER $$

CREATE TRIGGER tg_prevenir_delete_producto
BEFORE DELETE ON producto
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'NO puedes eliminar el producto actulizalo para hacer el "borrado"';
END $$

DELIMITER ;

UPDATE producto SET nombre = 'Eliminado' WHERE id = 1;

-- 5. Actualizar Fecha Factura 

DELIMITER $$

CREATE TRIGGER tg_actualizar_fecha_factura
BEFORE UPDATE ON factura
FOR EACH ROW
BEGIN
    SET NEW.fecha = NOW();
END $$

DELIMITER ;

UPDATE factura SET total = 60000 WHERE id = 1;

-- 6. Eliminar Ingrediente 

DELIMITER $$

CREATE TRIGGER tg_prevenir_delete_ingrediente
BEFORE DELETE ON ingrediente
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'NO puedes eliminar el ingrediente actulizalo para hacer el "borrado"';
END $$

DELIMITER ;

UPDATE ingrediente SET nombre = 'Eliminado', stock = 0, precio = 0.00 WHERE id = 1;