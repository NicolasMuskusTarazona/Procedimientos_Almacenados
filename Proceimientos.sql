-- Active: 1749813797455@@127.0.0.1@3307@Pizzeria
-- 1. Crea un procedimiento que inserte una nueva pizza en la tabla `pizza` 
-- junto con sus ingredientes en `pizza_ingrediente`.

DELIMITER $$

CREATE PROCEDURE `ps_add_pizza_con_ingredientes`(IN p_nombre_pizza VARCHAR(100), p_precio DECIMAL(10,2), p_ids_ingredientes INT)
BEGIN
    ciclo : LOOP
    
END $$

DELIMITER ;

CALL `ps_add_pizza_con_ingredientes`('Pizza Carne',5000,10)

-- 2. Actualizar precio Pizza
-- Procedimiento que reciba `p_pizza_id` y `p_nuevo_precio` y actualice el precio.

DELIMITER $$

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
        SELECT 'El producto no existe o no es una pizza' AS mensaje;
    END IF;
END $$

DELIMITER ;

CALL `ps_actualizar_precio_pizza`(2,9909)

