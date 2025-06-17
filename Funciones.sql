-- 1. Cacular total pizzas
DELIMITER $$

CREATE FUNCTION fc_calcular_subtotal_pizza(p_pizza_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_precio_base DECIMAL(10,2);
    DECLARE v_total_ingredientes DECIMAL(10,2);

    SELECT MIN(precio)
    INTO v_precio_base
    FROM producto_presentacion
    WHERE producto_id = p_pizza_id;

    SELECT IFNULL(SUM(ingrediente.precio * ingredientes_extra.cantidad), 0)
    INTO v_total_ingredientes
    FROM detalle_pedido_producto
    JOIN ingredientes_extra ON detalle_pedido_producto.detalle_id = ingredientes_extra.detalle_id
    JOIN ingrediente ON ingrediente.id = ingredientes_extra.ingrediente_id
    WHERE detalle_pedido_producto.producto_id = p_pizza_id;

    RETURN v_precio_base + v_total_ingredientes;
END $$

DELIMITER ;

SELECT fc_calcular_subtotal_pizza(1) AS subtotal;

-- 2. Descuento por Cantidad

DELIMITER $$

CREATE FUNCTION fc_descuento_por_cantidad(p_cantidad INT,p_precio_unitario DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_descuento DECIMAL(10,2);

    IF p_cantidad >= 5 THEN
        SET v_descuento = p_precio_unitario * p_cantidad * 0.10;
    ELSE
        SET v_descuento = 0;
    END IF;

    RETURN v_descuento;
END $$

DELIMITER ;

SELECT fc_descuento_por_cantidad(6, 20000) AS descuento;

-- 3.Precio final del pedido

DELIMITER $$
CREATE FUNCTION fc_precio_final_pedido(p_pedido_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;

    SELECT SUM(
        detalle_pedido.cantidad * fc_calcular_subtotal_pizza(detalle_pedido_producto.producto_id)
        - fc_descuento_por_cantidad(detalle_pedido.cantidad, fc_calcular_subtotal_pizza(detalle_pedido_producto.producto_id))
    )
    INTO v_total
    FROM detalle_pedido 
    JOIN detalle_pedido_producto ON detalle_pedido.id = detalle_pedido_producto.detalle_id
    WHERE detalle_pedido.pedido_id = p_pedido_id;

    RETURN IFNULL(v_total, 0);
END $$

DELIMITER ;

SELECT fc_precio_final_pedido(1) AS total_final;

-- 4. Obtener stock ingrediente

DELIMITER $$

CREATE FUNCTION fc_obtener_stock_ingrediente(p_ingrediente_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_stock INT;

    SELECT stock INTO v_stock
    FROM ingrediente
    WHERE id = p_ingrediente_id;

    RETURN IFNULL(v_stock, 0);
END $$

DELIMITER ;

SELECT fc_obtener_stock_ingrediente(2) AS stock_actual;


-- 5. Pizza popular

DELIMITER $$

CREATE FUNCTION fc_es_pizza_popular(p_pizza_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*) INTO v_total
    FROM detalle_pedido_producto
    WHERE producto_id = p_pizza_id;

    RETURN IF(v_total > 50, 1, 0);
END $$

DELIMITER ;

SELECT fc_es_pizza_popular(3) AS es_popular;
