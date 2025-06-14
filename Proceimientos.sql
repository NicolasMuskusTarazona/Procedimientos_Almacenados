-- 1. Crea un procedimiento que inserte una nueva pizza en la tabla `pizza` 
-- junto con sus ingredientes en `pizza_ingrediente`.

DELIMITER $$

CREATE PROCEDURE `ps_add_pizza_con_ingredientes`(IN p_nombre_pizza VARCHAR(100), p_precio DECIMAL(10,2), p_ids_ingredientes INT)
BEGIN
    ciclo : LOOP
    
END $$

DELIMITER ;

CALL `ps_add_pizza_con_ingredientes`('Pizza Carne',5000,10)