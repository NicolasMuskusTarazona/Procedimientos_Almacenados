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
