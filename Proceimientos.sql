-- Active: 1749813797455@@127.0.0.1@3307@Pizzeria
-- 1. Crea un procedimiento que inserte una nueva pizza en la tabla `pizza` 
-- junto con sus ingredientes en `pizza_ingrediente`.

DELIMITER $$
DROP PROCEDURE IF EXISTS `ps_add_pizza_con_ingredientes` $$

CREATE PROCEDURE `ps_add_pizza_con_ingredientes`(IN p_nombre_pizza VARCHAR(100), p_precio DECIMAL(10,2), p_tipo_producto_id INT, p_ingrediente VARCHAR(100), p_stock INT, p_ingrediente_precio INT)
SQL SECURITY INVOKER
BEGIN
    DECLARE nuevo_id INT;
    SET nuevo_id = LAST_INSERT_ID();
    INSERT INTO producto (nombre, tipo_producto_id)VALUES (p_nombre_pizza, p_tipo_producto_id);
    INSERT INTO producto_presentacion (producto_id, presentacion_id, precio)VALUES (nuevo_id, 1, p_precio);
    INSERT INTO ingrediente (nombre,stock,precio) VALUES (p_ingrediente,p_stock,p_ingrediente_precio );
    SELECT CONCAT('Pizza "', p_nombre_pizza, '" agregada con ID ', nuevo_id) AS mensaje;
END $$

DELIMITER ;

CALL `ps_add_pizza_con_ingredientes`('Pizza Chetos',4000, 2, 'Cheso', 10, 200)

-- 2. Actualizar precio Pizza
-- Procedimiento que reciba `p_pizza_id` y `p_nuevo_precio` y actualice el precio.

DELIMITER $$
DROP PROCEDURE IF EXISTS `ps_actualizar_precio_pizza` $$
CREATE PROCEDURE `ps_actualizar_precio_pizza` (IN p_pizza_id INT, IN p_precio DECIMAL(10,2))
BEGIN
    DECLARE existe INT;
    SELECT COUNT(*) INTO existe
    FROM producto
    WHERE id = p_pizza_id AND tipo_producto_id = 2;
    IF existe > 0 THEN
        UPDATE producto_presentacion
        SET precio = p_precio
        WHERE producto_id = p_pizza_id;
        SELECT 'Precios actualizados en todas las presentaciones' AS mensaje;
    ELSE
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Producto no existe o Tipo de producto erroneo';
    END IF;
END $$

DELIMITER ;

CALL `ps_actualizar_precio_pizza`(1,9909)

