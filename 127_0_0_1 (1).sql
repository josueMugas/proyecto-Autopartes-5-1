-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 01-11-2026 a las 04:29:31
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `demografia`
--
DROP DATABASE IF EXISTS `demografia`;
CREATE DATABASE IF NOT EXISTS `demografia` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `demografia`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `sp_CargarSaldoCliente`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CargarSaldoCliente` (IN `p_id_cliente` INT, IN `p_monto` DECIMAL(12,2))   BEGIN
    UPDATE cliente
    SET saldo = saldo + p_monto
    WHERE id_cliente = p_id_cliente;
END$$

DROP PROCEDURE IF EXISTS `sp_ConfirmarCompra`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ConfirmarCompra` (IN `p_id_cliente` INT, IN `p_id_usuario` INT, IN `p_detalles` LONGTEXT, OUT `p_id_presupuesto` INT, OUT `p_total` DECIMAL(12,2), OUT `p_saldo_restante` DECIMAL(12,2))   BEGIN
    DECLARE v_indice INT DEFAULT 0;
    DECLARE v_cantidad_detalles INT DEFAULT 0;
    DECLARE v_id_producto INT DEFAULT 0;
    DECLARE v_cantidad INT DEFAULT 0;
    DECLARE v_precio DECIMAL(12,2) DEFAULT 0;
    DECLARE v_saldo DECIMAL(12,2) DEFAULT 0;
    DECLARE v_productos_validos INT DEFAULT 0;
    DECLARE v_cliente_valido INT DEFAULT 0;
    DECLARE v_receta_total INT DEFAULT 0;
    DECLARE v_receta_valida INT DEFAULT 0;
    DECLARE v_posicion INT DEFAULT 0;
    DECLARE v_cantidad_receta INT DEFAULT 0;
    DECLARE v_id_insumo INT DEFAULT 0;
    DECLARE v_requerido DECIMAL(12,2) DEFAULT 0;
    DECLARE v_consumo DECIMAL(12,2) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_id_cliente IS NULL OR p_id_cliente < 1
        OR p_id_usuario IS NULL OR p_id_usuario < 1 OR p_detalles IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud de compra no es válida.';
    END IF;
    IF JSON_VALID(p_detalles) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud de compra no es válida.';
    END IF;
    IF JSON_TYPE(p_detalles) <> 'ARRAY' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud de compra no es válida.';
    END IF;

    SET v_cantidad_detalles = JSON_LENGTH(p_detalles);
    IF v_cantidad_detalles < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El carrito está vacío.';
    END IF;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_productos_validos
    FROM usuario
    WHERE id_usuario = p_id_usuario AND id_cliente = p_id_cliente
        AND id_rol = 4 AND activo = TRUE;
    IF v_productos_validos <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta de cliente no es válida.';
    END IF;

    SELECT COUNT(*) INTO v_cliente_valido
    FROM cliente
    WHERE id_cliente = p_id_cliente AND activo = TRUE;
    IF v_cliente_valido <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta de cliente no es válida.';
    END IF;

    SELECT Saldo INTO v_saldo
    FROM cliente
    WHERE id_cliente = p_id_cliente AND activo = TRUE
    FOR UPDATE;

    SET p_total = 0;
    SET v_indice = 0;
    WHILE v_indice < v_cantidad_detalles DO
        SET v_id_producto = CAST(JSON_UNQUOTE(JSON_EXTRACT(
            p_detalles, CONCAT('$[', v_indice, '].idProducto')
        )) AS UNSIGNED);
        SET v_cantidad = CAST(JSON_UNQUOTE(JSON_EXTRACT(
            p_detalles, CONCAT('$[', v_indice, '].cantidad')
        )) AS UNSIGNED);

        IF v_id_producto IS NULL OR v_id_producto < 1 OR v_cantidad IS NULL OR v_cantidad < 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay un producto o cantidad inválidos.';
        END IF;

        SELECT COUNT(*) INTO v_productos_validos
        FROM producto
        WHERE id_producto = v_id_producto AND activo = TRUE AND precio_venta > 0;
        IF v_productos_validos <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay un producto sin precio o no disponible.';
        END IF;

        SELECT precio_venta INTO v_precio
        FROM producto
        WHERE id_producto = v_id_producto AND activo = TRUE;

        SELECT COUNT(*), SUM(CASE WHEN i.activo = TRUE AND pi.cantidad_requerida > 0
            THEN 1 ELSE 0 END)
        INTO v_receta_total, v_receta_valida
        FROM producto_insumo pi
        LEFT JOIN insumo i ON i.id_insumo = pi.id_insumo
        WHERE pi.id_producto = v_id_producto;
        IF v_receta_total < 1 OR v_receta_valida <> v_receta_total THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no tiene una receta de insumos válida.';
        END IF;

        SET p_total = ROUND(p_total + (v_precio * v_cantidad), 2);
        SET v_indice = v_indice + 1;
    END WHILE;

    IF v_saldo < p_total THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El saldo disponible no alcanza para esta compra.';
    END IF;

    UPDATE cliente
    SET Saldo = Saldo - p_total
    WHERE id_cliente = p_id_cliente AND activo = TRUE AND Saldo >= p_total;
    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo descontar el saldo del cliente.';
    END IF;

    INSERT INTO presupuesto (id_cliente, id_usuario_venta, fecha, total, estado, tipo_factura, es_formal)
    VALUES (p_id_cliente, p_id_usuario, CURDATE(), p_total, 'PAGADO', NULL, FALSE);
    SET p_id_presupuesto = LAST_INSERT_ID();

    SET v_indice = 0;
    WHILE v_indice < v_cantidad_detalles DO
        SET v_id_producto = CAST(JSON_UNQUOTE(JSON_EXTRACT(
            p_detalles, CONCAT('$[', v_indice, '].idProducto')
        )) AS UNSIGNED);
        SET v_cantidad = CAST(JSON_UNQUOTE(JSON_EXTRACT(
            p_detalles, CONCAT('$[', v_indice, '].cantidad')
        )) AS UNSIGNED);

        SELECT precio_venta INTO v_precio
        FROM producto
        WHERE id_producto = v_id_producto AND activo = TRUE;

        INSERT INTO detalle_presupuesto (id_presupuesto, id_producto, cantidad, precio_unitario, subtotal)
        VALUES (p_id_presupuesto, v_id_producto, v_cantidad, v_precio, ROUND(v_precio * v_cantidad, 2));

        SELECT COUNT(*) INTO v_cantidad_receta
        FROM producto_insumo
        WHERE id_producto = v_id_producto;
        SET v_posicion = 0;
        WHILE v_posicion < v_cantidad_receta DO
            SELECT id_insumo, cantidad_requerida
            INTO v_id_insumo, v_requerido
            FROM producto_insumo
            WHERE id_producto = v_id_producto
            ORDER BY id_producto_insumo
            LIMIT v_posicion, 1;

            SET v_consumo = v_requerido * v_cantidad;
            UPDATE insumo
            SET stock_actual = stock_actual - v_consumo
            WHERE id_insumo = v_id_insumo AND activo = TRUE AND stock_actual >= v_consumo;
            IF ROW_COUNT() <> 1 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficientes insumos para completar la compra.';
            END IF;
            SET v_posicion = v_posicion + 1;
        END WHILE;
        SET v_indice = v_indice + 1;
    END WHILE;

    SET p_saldo_restante = v_saldo - p_total;
    COMMIT;
END$$

DROP PROCEDURE IF EXISTS `sp_Delete`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Delete` (IN `p_tabla` VARCHAR(64), IN `p_campo_id` VARCHAR(64), IN `p_id` INT)   BEGIN
    SET @sql = CONCAT('UPDATE ', p_tabla, ' SET activo = FALSE WHERE ', p_campo_id, ' = ?');
    PREPARE stmt FROM @sql;
    SET @id = p_id;
    EXECUTE stmt USING @id;
    DEALLOCATE PREPARE stmt;
END$$

DROP PROCEDURE IF EXISTS `sp_DeleteFisico`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DeleteFisico` (IN `p_tabla` VARCHAR(64), IN `p_campo_id` VARCHAR(64), IN `p_id` INT)   BEGIN
    SET @sql = CONCAT('DELETE FROM `', p_tabla, '` WHERE `', p_campo_id, '` = ?');
    PREPARE stmt FROM @sql;
    SET @id = p_id;
    EXECUTE stmt USING @id;
    DEALLOCATE PREPARE stmt;
END$$

DROP PROCEDURE IF EXISTS `sp_Insert_Cliente`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insert_Cliente` (IN `p_nom` VARCHAR(100), IN `p_ape` VARCHAR(100), IN `p_dni` VARCHAR(20), IN `p_tel` VARCHAR(50), IN `p_email` VARCHAR(100), OUT `p_id_cliente` INT)   BEGIN
    INSERT INTO cliente (nombre, apellido, dni, telefono, email, activo)
    VALUES (p_nom, p_ape, p_dni, p_tel, p_email, TRUE);
    SET p_id_cliente = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `sp_Insert_HojaDeRuta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insert_HojaDeRuta` (IN `p_codigo` VARCHAR(100), IN `p_id_presupuesto` INT, IN `p_id_producto` INT, IN `p_cantidad` INT, IN `p_linea_trabajo` VARCHAR(100), IN `p_metodo_productivo` VARCHAR(100), IN `p_estado` VARCHAR(50), IN `p_fecha_inicio` DATE, IN `p_fecha_entrega` DATE)   BEGIN
    INSERT INTO hoja_de_ruta (
        codigo_inalterable, id_presupuesto, id_producto, cantidad, linea_trabajo,
        metodo_productivo, estado, fecha_inicio, fecha_estimada_entrega
    )
    VALUES (
        p_codigo, p_id_presupuesto, p_id_producto, p_cantidad, p_linea_trabajo,
        p_metodo_productivo, p_estado, p_fecha_inicio, p_fecha_entrega
    );
END$$

DROP PROCEDURE IF EXISTS `sp_Insert_Insumo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insert_Insumo` (IN `p_cod` VARCHAR(50), IN `p_nom` VARCHAR(150), IN `p_mat` VARCHAR(100), IN `p_stk_act` DECIMAL(12,2), IN `p_stk_min` DECIMAL(12,2), IN `p_unid` VARCHAR(20))   BEGIN
    INSERT INTO insumo (codigo, nombre, tipo_material, stock_actual, stock_minimo, unidad_medida, activo)
    VALUES (p_cod, p_nom, p_mat, p_stk_act, p_stk_min, p_unid, TRUE);
END$$

DROP PROCEDURE IF EXISTS `sp_Insert_Producto`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insert_Producto` (IN `p_cod` VARCHAR(50), IN `p_nom` VARCHAR(150), IN `p_url` VARCHAR(255), IN `p_precio` DECIMAL(12,2))   BEGIN
    INSERT INTO producto (codigo, nombre, plano_tecnico_url, precio_venta, activo)
    VALUES (p_cod, p_nom, p_url, p_precio, TRUE);
END$$

DROP PROCEDURE IF EXISTS `sp_Insert_Rol`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insert_Rol` (IN `p_nombre` VARCHAR(50), IN `p_descripcion` VARCHAR(255))   BEGIN
    INSERT INTO rol (nombre_rol, descripcion)
    VALUES (p_nombre, p_descripcion);
END$$

DROP PROCEDURE IF EXISTS `sp_Insert_Usuario`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Insert_Usuario` (IN `p_nom` VARCHAR(50), IN `p_clave` VARCHAR(255), IN `p_rol` INT, IN `p_id_cliente` INT)   BEGIN
    INSERT INTO usuario (nombre_usuario, clave, id_rol, id_cliente)
    VALUES (p_nom, p_clave, p_rol, p_id_cliente);
END$$

DROP PROCEDURE IF EXISTS `sp_ListAll`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListAll` (IN `p_tabla` VARCHAR(64))   BEGIN
    IF p_tabla = 'presupuesto' THEN
        SET @sql = 'SELECT * FROM presupuesto ORDER BY fecha DESC, id_presupuesto DESC';
    ELSEIF p_tabla = 'rol' THEN
        SET @sql = 'SELECT * FROM rol ORDER BY id_rol';
    ELSEIF p_tabla = 'hoja_de_ruta' THEN
        SET @sql = 'SELECT * FROM hoja_de_ruta ORDER BY id_hoja_ruta';
    ELSE
        SET @sql = CONCAT('SELECT * FROM ', p_tabla, ' WHERE activo = TRUE');
    END IF;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DROP PROCEDURE IF EXISTS `sp_ListById`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ListById` (IN `p_tabla` VARCHAR(64), IN `p_campo_id` VARCHAR(64), IN `p_id` INT)   BEGIN
    SET @sql = CONCAT('SELECT * FROM ', p_tabla, ' WHERE ', p_campo_id, ' = ?');
    PREPARE stmt FROM @sql;
    SET @id = p_id;
    EXECUTE stmt USING @id;
    DEALLOCATE PREPARE stmt;
END$$

DROP PROCEDURE IF EXISTS `sp_ProductosMasVendidos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ProductosMasVendidos` ()   BEGIN
    SELECT p.id_producto, p.codigo, p.nombre, SUM(dp.cantidad) AS total_vendido
    FROM detalle_presupuesto dp
    JOIN producto p ON dp.id_producto = p.id_producto
    GROUP BY p.id_producto, p.codigo, p.nombre
    ORDER BY total_vendido DESC
    LIMIT 5;
END$$

DROP PROCEDURE IF EXISTS `sp_Update_Cliente`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Update_Cliente` (IN `p_id` INT, IN `p_nom` VARCHAR(100), IN `p_ape` VARCHAR(100), IN `p_dni` VARCHAR(20), IN `p_tel` VARCHAR(50), IN `p_email` VARCHAR(100))   BEGIN
    UPDATE cliente
    SET nombre = p_nom, apellido = p_ape, dni = p_dni,
        telefono = p_tel, email = p_email
    WHERE id_cliente = p_id;
END$$

DROP PROCEDURE IF EXISTS `sp_Update_HojaDeRuta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Update_HojaDeRuta` (IN `p_codigo` VARCHAR(100), IN `p_id_presupuesto` INT, IN `p_id_producto` INT, IN `p_cantidad` INT, IN `p_linea_trabajo` VARCHAR(100), IN `p_metodo_productivo` VARCHAR(100), IN `p_estado` VARCHAR(50), IN `p_fecha_inicio` DATE, IN `p_fecha_entrega` DATE, IN `p_id` INT, OUT `p_filas` INT)   BEGIN
    UPDATE hoja_de_ruta
    SET codigo_inalterable = p_codigo,
        id_presupuesto = p_id_presupuesto,
        id_producto = p_id_producto,
        cantidad = p_cantidad,
        linea_trabajo = p_linea_trabajo,
        metodo_productivo = p_metodo_productivo,
        estado = p_estado,
        fecha_inicio = p_fecha_inicio,
        fecha_estimada_entrega = p_fecha_entrega
    WHERE id_hoja_ruta = p_id;
    SET p_filas = ROW_COUNT();
END$$

DROP PROCEDURE IF EXISTS `sp_Update_Insumo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Update_Insumo` (IN `p_id` INT, IN `p_cod` VARCHAR(50), IN `p_nom` VARCHAR(150), IN `p_mat` VARCHAR(100), IN `p_stk_act` DECIMAL(12,2), IN `p_stk_min` DECIMAL(12,2), IN `p_unid` VARCHAR(20))   BEGIN
    UPDATE insumo
    SET codigo = p_cod, nombre = p_nom, tipo_material = p_mat,
        stock_actual = p_stk_act, stock_minimo = p_stk_min, unidad_medida = p_unid
    WHERE id_insumo = p_id;
END$$

DROP PROCEDURE IF EXISTS `sp_Update_Producto`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Update_Producto` (IN `p_id` INT, IN `p_cod` VARCHAR(50), IN `p_nom` VARCHAR(150), IN `p_url` VARCHAR(255), IN `p_precio` DECIMAL(12,2))   BEGIN
    UPDATE producto
    SET codigo = p_cod, nombre = p_nom, plano_tecnico_url = p_url, precio_venta = p_precio
    WHERE id_producto = p_id;
END$$

DROP PROCEDURE IF EXISTS `sp_Update_Rol`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Update_Rol` (IN `p_nombre` VARCHAR(50), IN `p_descripcion` VARCHAR(255), IN `p_id` INT, OUT `p_filas` INT)   BEGIN
    UPDATE rol
    SET nombre_rol = p_nombre, descripcion = p_descripcion
    WHERE id_rol = p_id;
    SET p_filas = ROW_COUNT();
END$$

DROP PROCEDURE IF EXISTS `sp_Update_Usuario`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Update_Usuario` (IN `p_id` INT, IN `p_nom` VARCHAR(50), IN `p_clave` VARCHAR(255), IN `p_act` BOOLEAN, IN `p_rol` INT)   BEGIN UPDATE usuario SET nombre_usuario=p_nom, clave=p_clave, activo=p_act, id_rol=p_rol WHERE id_usuario=p_id; END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

DROP TABLE IF EXISTS `cliente`;
CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `dni` varchar(20) DEFAULT NULL,
  `telefono` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `Saldo` decimal(12,2) NOT NULL DEFAULT 0.00,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`id_cliente`, `nombre`, `apellido`, `dni`, `telefono`, `email`, `Saldo`, `activo`) VALUES
(1, 'Josue', 'Mugas', NULL, '112223123', 'josue.mugaset@gmail.com', 198045200.00, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `consumo_insumo`
--

DROP TABLE IF EXISTS `consumo_insumo`;
CREATE TABLE `consumo_insumo` (
  `id_consumo` int(11) NOT NULL,
  `id_hoja_ruta` int(11) DEFAULT NULL,
  `id_insumo` int(11) DEFAULT NULL,
  `cantidad_usada` decimal(12,2) NOT NULL,
  `fecha_registro` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `consumo_insumo`
--
DROP TRIGGER IF EXISTS `trg_actualizar_stock_insumo`;
DELIMITER $$
CREATE TRIGGER `trg_actualizar_stock_insumo` AFTER INSERT ON `consumo_insumo` FOR EACH ROW BEGIN
    UPDATE insumo 
    SET stock_actual = stock_actual - NEW.cantidad_usada
    WHERE id_insumo = NEW.id_insumo;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_presupuesto`
--

DROP TABLE IF EXISTS `detalle_presupuesto`;
CREATE TABLE `detalle_presupuesto` (
  `id_detalle_presupuesto` int(11) NOT NULL,
  `id_presupuesto` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalle_presupuesto`
--

INSERT INTO `detalle_presupuesto` (`id_detalle_presupuesto`, `id_presupuesto`, `id_producto`, `cantidad`, `precio_unitario`, `subtotal`) VALUES
(1, 1, 3, 12, 120000.00, 1440000.00),
(2, 2, 3, 88, 120000.00, 10560000.00);

--
-- Disparadores `detalle_presupuesto`
--
DROP TRIGGER IF EXISTS `trg_verificar_stock_insumos`;
DELIMITER $$
CREATE TRIGGER `trg_verificar_stock_insumos` BEFORE INSERT ON `detalle_presupuesto` FOR EACH ROW BEGIN
    DECLARE v_faltantes INT DEFAULT 0;

    SELECT COUNT(*) INTO v_faltantes
    FROM producto_insumo pi
    JOIN insumo i ON pi.id_insumo = i.id_insumo
    WHERE pi.id_producto = NEW.id_producto
      AND (i.activo <> TRUE OR i.stock_actual < (pi.cantidad_requerida * NEW.cantidad));

    IF v_faltantes > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Stock: No hay suficientes insumos en la fábrica para fabricar este producto.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_hoja_ruta`
--

DROP TABLE IF EXISTS `historial_hoja_ruta`;
CREATE TABLE `historial_hoja_ruta` (
  `id_historial` int(11) NOT NULL,
  `id_hoja_ruta` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `estado_anterior` varchar(50) DEFAULT NULL,
  `estado_nuevo` varchar(50) DEFAULT NULL,
  `fecha_cambio` datetime NOT NULL,
  `observacion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `hoja_de_ruta`
--

DROP TABLE IF EXISTS `hoja_de_ruta`;
CREATE TABLE `hoja_de_ruta` (
  `id_hoja_ruta` int(11) NOT NULL,
  `codigo_inalterable` varchar(100) NOT NULL,
  `id_presupuesto` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL,
  `linea_trabajo` varchar(100) DEFAULT NULL,
  `metodo_productivo` varchar(100) DEFAULT NULL,
  `estado` varchar(50) NOT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_estimada_entrega` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `hoja_de_ruta`
--
DROP TRIGGER IF EXISTS `trg_auditar_hoja_ruta`;
DELIMITER $$
CREATE TRIGGER `trg_auditar_hoja_ruta` AFTER UPDATE ON `hoja_de_ruta` FOR EACH ROW BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO historial_hoja_ruta (id_hoja_ruta, id_usuario, estado_anterior, estado_nuevo, fecha_cambio, observacion)
        VALUES (NEW.id_hoja_ruta, NULL, OLD.estado, NEW.estado, NOW(), 'Cambio de estado automático por trigger');
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `insumo`
--

DROP TABLE IF EXISTS `insumo`;
CREATE TABLE `insumo` (
  `id_insumo` int(11) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `tipo_material` varchar(100) DEFAULT NULL,
  `stock_actual` decimal(12,2) NOT NULL DEFAULT 0.00,
  `stock_minimo` decimal(12,2) NOT NULL DEFAULT 0.00,
  `unidad_medida` varchar(20) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `insumo`
--

INSERT INTO `insumo` (`id_insumo`, `codigo`, `nombre`, `tipo_material`, `stock_actual`, `stock_minimo`, `unidad_medida`, `activo`) VALUES
(1, 'INS-001', 'Acero Inoxidable 316', 'Metal', 500.00, 50.00, 'kg', 1),
(2, 'INS-002', 'Aluminio Fundido A380', 'Metal', 0.00, 30.00, 'kg', 1),
(3, 'INS-003', 'Goma Nitrilo NBR', 'Caucho', 150.00, 20.00, 'mts', 1),
(4, 'INS-004', 'Resorte de Acero Templado', 'Metal', 1000.00, 100.00, 'un', 1),
(5, 'INS-005', 'Pintura Epoxi Negra', 'Químico', 80.00, 10.00, 'litros', 1),
(6, 'INS-006', 'Fibra de Freno Sin Asbesto', 'Compuesto', 250.00, 40.00, 'kg', 1),
(7, 'INS-007', 'Cobre en Rollo 2mm', 'Metal', 120.00, 15.00, 'kg', 1),
(8, 'INS-008', 'Tornillos M8 Hexagonales', 'Fijación', 5000.00, 500.00, 'un', 1),
(9, 'INS-009', 'Aceite Hidráulico ISO 68', 'Lubricante', 400.00, 50.00, 'litros', 1),
(10, 'INS-010', 'Plástico ABS Industrial', 'Polímero', 600.00, 80.00, 'kg', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `presupuesto`
--

DROP TABLE IF EXISTS `presupuesto`;
CREATE TABLE `presupuesto` (
  `id_presupuesto` int(11) NOT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `id_usuario_venta` int(11) DEFAULT NULL,
  `fecha` date NOT NULL,
  `total` decimal(12,2) DEFAULT 0.00,
  `estado` varchar(50) NOT NULL,
  `tipo_factura` varchar(10) DEFAULT NULL,
  `es_formal` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `presupuesto`
--

INSERT INTO `presupuesto` (`id_presupuesto`, `id_cliente`, `id_usuario_venta`, `fecha`, `total`, `estado`, `tipo_factura`, `es_formal`) VALUES
(1, 1, 9, '2026-11-01', 1440000.00, 'PAGADO', NULL, 0),
(2, 1, 9, '2026-11-01', 10560000.00, 'PAGADO', NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

DROP TABLE IF EXISTS `producto`;
CREATE TABLE `producto` (
  `id_producto` int(11) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `plano_tecnico_url` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `precio_venta` decimal(12,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`id_producto`, `codigo`, `nombre`, `plano_tecnico_url`, `activo`, `precio_venta`) VALUES
(1, 'PRD-001', 'Amortiguador Delantero', '/planos/amortiguador_del.pdf', 0, 0.00),
(2, 'PRD-002', 'Pastillas de Freno Cerámicas', '/planos/frenos_ceramicos.pdf', 1, 0.00),
(3, 'PRD-003', 'Bomba de Agua Motor', '/planos/bomba_agua.pdf', 1, 120000.00),
(4, 'PRD-004', 'Alternador 12V 90A', '/planos/alternador.pdf', 1, 0.00),
(5, 'PRD-005', 'Discos de Freno Ventilados', '/planos/discos_freno.pdf', 1, 0.00),
(6, 'PRD-006', 'Filtro de Aceite Blindado', '/planos/filtro_aceite.pdf', 1, 0.00),
(7, 'PRD-007', 'Kit de Embrague Completo', '/planos/embrague.pdf', 1, 0.00),
(8, 'PRD-008', 'Culata de Cilindros', '/planos/culata.pdf', 1, 0.00),
(9, 'PRD-009', 'Radiador de Refrigeración', '/planos/radiador.pdf', 1, 0.00),
(10, 'PRD-010', 'Biela de Motor Forjada', '/planos/biela.pdf', 1, 0.00),
(11, 'wdaefaf', 'asd', 'sadasd', 0, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_insumo`
--

DROP TABLE IF EXISTS `producto_insumo`;
CREATE TABLE `producto_insumo` (
  `id_producto_insumo` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `id_insumo` int(11) DEFAULT NULL,
  `cantidad_requerida` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto_insumo`
--

INSERT INTO `producto_insumo` (`id_producto_insumo`, `id_producto`, `id_insumo`, `cantidad_requerida`) VALUES
(1, 1, 1, 2.50),
(2, 1, 4, 4.00),
(3, 2, 6, 1.20),
(4, 3, 2, 3.00),
(5, 4, 7, 0.80),
(6, 5, 1, 5.00),
(7, 6, 3, 0.50),
(8, 7, 4, 6.00),
(9, 8, 1, 12.00),
(10, 10, 1, 8.50);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

DROP TABLE IF EXISTS `rol`;
CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nombre_rol` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `nombre_rol`, `descripcion`) VALUES
(1, 'ADMIN', 'Administrador general y control total del sistema'),
(2, 'VENDEDOR', 'Gestión de clientes, presupuestos y ventas'),
(3, 'OPERARIO', 'Control de producción, insumos y hojas de ruta'),
(4, 'CLIENTE', 'Acceso externo para consulta de presupuestos y estados');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

DROP TABLE IF EXISTS `usuario`;
CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nombre_usuario` varchar(50) NOT NULL,
  `clave` varchar(255) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `id_rol` int(11) DEFAULT 4,
  `id_cliente` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombre_usuario`, `clave`, `activo`, `id_rol`, `id_cliente`) VALUES
(1, 'admin', '1234', 1, 1, NULL),
(3, 'pep', 'asdasd', 1, 2, NULL),
(4, 'asd', 'asdasd', 0, 3, NULL),
(5, 'asd', 'asdasd', 0, 2, NULL),
(7, 'josue.mugaset32@gmail.com', '$2a$10$Mrlz/trc5HDXZH2AjLMn8OMl1ZJJ/A5thQRBU2ENgV5zu1amEytza', 1, 1, NULL),
(8, 'josue.mugaset32@gmail.com', '$2a$10$AD7cWTqHhs/dmyJKshyMXuTA2L2vUr6PfMVDf3qOHb.QYXwYQh4qS', 1, 2, NULL),
(9, 'josue.mugaset@gmail.com', '$2a$10$7tDMVljpabgwhWzr0yNW7.576jb5PwNGh/8fCm40nzBN3Pq5gvmR.', 1, 4, 1),
(10, 'pedro', '$2a$10$fu2PjwV5gC5APHGzWp4eXeSFxO5gIoiYpqQSglgaaJXm8L7vWhAJS', 1, 2, NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`);

--
-- Indices de la tabla `consumo_insumo`
--
ALTER TABLE `consumo_insumo`
  ADD PRIMARY KEY (`id_consumo`),
  ADD KEY `id_hoja_ruta` (`id_hoja_ruta`),
  ADD KEY `id_insumo` (`id_insumo`);

--
-- Indices de la tabla `detalle_presupuesto`
--
ALTER TABLE `detalle_presupuesto`
  ADD PRIMARY KEY (`id_detalle_presupuesto`),
  ADD KEY `id_presupuesto` (`id_presupuesto`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `historial_hoja_ruta`
--
ALTER TABLE `historial_hoja_ruta`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `id_hoja_ruta` (`id_hoja_ruta`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `hoja_de_ruta`
--
ALTER TABLE `hoja_de_ruta`
  ADD PRIMARY KEY (`id_hoja_ruta`),
  ADD KEY `id_presupuesto` (`id_presupuesto`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `insumo`
--
ALTER TABLE `insumo`
  ADD PRIMARY KEY (`id_insumo`);

--
-- Indices de la tabla `presupuesto`
--
ALTER TABLE `presupuesto`
  ADD PRIMARY KEY (`id_presupuesto`),
  ADD KEY `id_cliente` (`id_cliente`),
  ADD KEY `id_usuario_venta` (`id_usuario_venta`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`id_producto`);

--
-- Indices de la tabla `producto_insumo`
--
ALTER TABLE `producto_insumo`
  ADD PRIMARY KEY (`id_producto_insumo`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_insumo` (`id_insumo`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `uq_usuario_cliente` (`id_cliente`),
  ADD KEY `id_rol` (`id_rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `consumo_insumo`
--
ALTER TABLE `consumo_insumo`
  MODIFY `id_consumo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_presupuesto`
--
ALTER TABLE `detalle_presupuesto`
  MODIFY `id_detalle_presupuesto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `historial_hoja_ruta`
--
ALTER TABLE `historial_hoja_ruta`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `hoja_de_ruta`
--
ALTER TABLE `hoja_de_ruta`
  MODIFY `id_hoja_ruta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `insumo`
--
ALTER TABLE `insumo`
  MODIFY `id_insumo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `presupuesto`
--
ALTER TABLE `presupuesto`
  MODIFY `id_presupuesto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `producto_insumo`
--
ALTER TABLE `producto_insumo`
  MODIFY `id_producto_insumo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `consumo_insumo`
--
ALTER TABLE `consumo_insumo`
  ADD CONSTRAINT `consumo_insumo_ibfk_1` FOREIGN KEY (`id_hoja_ruta`) REFERENCES `hoja_de_ruta` (`id_hoja_ruta`),
  ADD CONSTRAINT `consumo_insumo_ibfk_2` FOREIGN KEY (`id_insumo`) REFERENCES `insumo` (`id_insumo`);

--
-- Filtros para la tabla `detalle_presupuesto`
--
ALTER TABLE `detalle_presupuesto`
  ADD CONSTRAINT `detalle_presupuesto_ibfk_1` FOREIGN KEY (`id_presupuesto`) REFERENCES `presupuesto` (`id_presupuesto`),
  ADD CONSTRAINT `detalle_presupuesto_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`);

--
-- Filtros para la tabla `historial_hoja_ruta`
--
ALTER TABLE `historial_hoja_ruta`
  ADD CONSTRAINT `historial_hoja_ruta_ibfk_1` FOREIGN KEY (`id_hoja_ruta`) REFERENCES `hoja_de_ruta` (`id_hoja_ruta`),
  ADD CONSTRAINT `historial_hoja_ruta_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `hoja_de_ruta`
--
ALTER TABLE `hoja_de_ruta`
  ADD CONSTRAINT `hoja_de_ruta_ibfk_1` FOREIGN KEY (`id_presupuesto`) REFERENCES `presupuesto` (`id_presupuesto`),
  ADD CONSTRAINT `hoja_de_ruta_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`);

--
-- Filtros para la tabla `presupuesto`
--
ALTER TABLE `presupuesto`
  ADD CONSTRAINT `presupuesto_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`),
  ADD CONSTRAINT `presupuesto_ibfk_2` FOREIGN KEY (`id_usuario_venta`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `producto_insumo`
--
ALTER TABLE `producto_insumo`
  ADD CONSTRAINT `producto_insumo_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  ADD CONSTRAINT `producto_insumo_ibfk_2` FOREIGN KEY (`id_insumo`) REFERENCES `insumo` (`id_insumo`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`),
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
