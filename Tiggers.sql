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
