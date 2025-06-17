-- Active: 1748978904024@@127.0.0.1@3307@Pizzeria
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
    SELECT CONCAT('Pizza "', p_nombre_pizza, '" agregada con ID ', nuevo_id, ' Ingrediente: ', p_ingrediente) AS mensaje;
END $$

DELIMITER ;

CALL `ps_add_pizza_con_ingredientes`('Pizza Chetos',4000, 2, 'Cheso', 10, 200)

-- 2. Actualizar precio Pizza
-- Procedimiento que reciba `p_pizza_id` y `p_nuevo_precio` y actualice el precio.

DELIMITER $$
DROP PROCEDURE IF EXISTS `ps_actualizar_precio_pizza` $$
CREATE PROCEDURE `ps_actualizar_precio_pizza` (IN p_pizza_id INT, IN p_precio DECIMAL(10,2))
SQL SECURITY INVOKER
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

CALL `ps_actualizar_precio_pizza`(2,9909)


-- 3. Insertar un pedido
-- Para cada ítem, inserta en `detalle_pedido` y en `detalle_pedido_pizza`.
-- Si todo va bien, hace `COMMIT`; si falla, `ROLLBACK` y devuelve un mensaje de error.

DELIMITER $$
DROP PROCEDURE IF EXISTS ps_generar_pedido $$
CREATE PROCEDURE ps_generar_pedido(IN p_cliente_id INT, IN p_metodo_pago_id INT, IN p_producto_id INT, IN p_cantidad INT)
BEGIN
    DECLARE v_pedido_id INT;
    DECLARE v_detalle_id INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SELECT 'RollBack' AS mensaje;
    END;

    START TRANSACTION;
    INSERT INTO pedido(fecha_recogida, total, cliente_id, metodo_pago_id) VALUES (NOW(), 0.00, p_cliente_id, p_metodo_pago_id);

    SET v_pedido_id = LAST_INSERT_ID();

    INSERT INTO detalle_pedido(pedido_id, cantidad) VALUES (v_pedido_id, p_cantidad);

    SET v_detalle_id = LAST_INSERT_ID();

    INSERT INTO detalle_pedido_producto(detalle_id, producto_id) VALUES (v_detalle_id, p_producto_id);

    SELECT MIN(producto_presentacion.precio)
    INTO v_precio
    FROM producto_presentacion
    WHERE producto_presentacion.producto_id = p_producto_id;

    UPDATE pedido
    SET total = v_precio * p_cantidad
    WHERE id = v_pedido_id;

    COMMIT;
    SELECT 'Pedido realizado' AS mensaje, v_pedido_id AS pedido_id;
END $$
DELIMITER ;


CALL ps_generar_pedido(1, 1, 1, 1);

-- 4. Cancelar Pedido

DELIMITER $$
DROP PROCEDURE IF EXISTS ps_cancelar_pedido $$
CREATE PROCEDURE ps_cancelar_pedido(IN p_pedido_id INT)
BEGIN
    DECLARE existe INT;

    SELECT COUNT(*) INTO existe
    FROM pedido
    WHERE id = p_pedido_id;

    IF existe > 0 THEN
        UPDATE pedido
        SET 
            fecha_recogida = '1900-01-01 00:00:00',
            total = 0
        WHERE id = p_pedido_id;

        SELECT CONCAT('Pedido cancelado: ', p_pedido_id) AS Resultado;
    ELSE
        SELECT 'No existe' AS Resultado;
    END IF;
END $$
DELIMITER ;

CALL ps_cancelar_pedido(1);

-- 5. Generar Facturar
DELIMITER $$

DROP PROCEDURE IF EXISTS ps_facturar_pedido $$
CREATE PROCEDURE ps_facturar_pedido(IN p_pedido_id INT)
BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0;
    DECLARE cliente_id_aux INT;
    DECLARE factura_id INT;

    -- Obtener el ID del cliente del pedido
    SELECT cliente_id INTO cliente_id_aux
    FROM pedido
    WHERE id = p_pedido_id;

    SELECT SUM(dp.cantidad * pp.precio) INTO total
    FROM detalle_pedido dp
    JOIN detalle_pedido_producto dpp ON dp.id = dpp.detalle_id
    JOIN producto_presentacion pp ON dpp.producto_id = pp.producto_id
    WHERE dp.pedido_id = p_pedido_id;

    IF total IS NULL THEN
        SET total = 0;
    END IF;

    INSERT INTO factura (total, fecha, pedido_id, cliente_id)
    VALUES (total, NOW(), p_pedido_id, cliente_id_aux);

    SET factura_id = LAST_INSERT_ID();

    SELECT factura_id AS id_generado;
END $$
DELIMITER ;

CALL ps_facturar_pedido(1);