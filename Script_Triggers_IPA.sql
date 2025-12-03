DELIMITER $$
CREATE TRIGGER trg_distribuicao_move_lote
AFTER INSERT ON Distribuicao
FOR EACH ROW
BEGIN
    UPDATE Lote 
    SET Armazem_idArmazem = NEW.Armazem_idArmazem_Destino
    WHERE idLote = NEW.Lote_idLote;
END $$ DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_distribuicao_origem_destino_validacao
BEFORE INSERT ON Distribuicao
FOR EACH ROW
BEGIN
    IF NEW.Armazem_idArmazem_Origem = NEW.Armazem_idArmazem_Destino THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Origem e destino não podem ser o mesmo armazém.';
    END IF;
END $$ DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_usuario_definir_data_cadastro
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
    IF NEW.dataCadastro IS NULL THEN
        SET NEW.dataCadastro = CURDATE();
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_usuario_senha_tamanho
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(NEW.senhaHash) < 8 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A senha deve ter pelo menos 8 caracteres.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_bloquear_distribuicao_vencida
BEFORE INSERT ON Distribuicao
FOR EACH ROW
BEGIN
    DECLARE validade DATE;

    SELECT s.dataValidade 
      INTO validade
      FROM Semente s
      JOIN Lote l ON l.Semente_idSemente = s.idSemente
     WHERE l.idLote = NEW.Lote_idLote;

    IF validade < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Distribuição bloqueada: lote contém semente vencida.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_aviso_validade_proxima
BEFORE INSERT ON Distribuicao
FOR EACH ROW
BEGIN
    DECLARE validade DATE;

    SELECT dataValidade INTO validade
    FROM Semente s
    JOIN Lote l ON l.Semente_idSemente = s.idSemente
    WHERE idLote = NEW.Lote_idLote;

    IF DATEDIFF(validade, NEW.dataDistribuicao) < 30 THEN
        SIGNAL SQLSTATE '01000'
            SET MESSAGE_TEXT = 'Aviso: o lote está com menos de 30 dias para vencer.';
        -- IMPORTANTE: SQLSTATE '01000' = WARNING → NÃO impede o INSERT
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tg_limite_capacidade_armazem
BEFORE INSERT ON Lote
FOR EACH ROW
BEGIN
    DECLARE capacidade INT;
    DECLARE ocupado INT;

    SELECT capacidadeKg INTO capacidade
    FROM Armazem
    WHERE idArmazem = NEW.Armazem_idArmazem;

    SELECT COALESCE(SUM(quantidadeKg), 0) INTO ocupado
    FROM Lote
    WHERE Armazem_idArmazem = NEW.Armazem_idArmazem;

    IF (ocupado + NEW.quantidadeKg) > capacidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Capacidade do armazém excedida.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tg_no_municipio_duplicado
BEFORE INSERT ON Municipio
FOR EACH ROW
BEGIN
    IF EXISTS(SELECT 1 FROM Municipio WHERE nome = NEW.nome) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Já existe um município cadastrado com este nome.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_atualizar_transparencia
AFTER UPDATE ON Distribuicao
FOR EACH ROW
BEGIN
    UPDATE Transparencia
    SET dataAtualizacao = CURDATE()
    WHERE Distribuicao_idDistribuicao = NEW.idDistribuicao;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_definir_data_entrada_lote
BEFORE INSERT ON Lote
FOR EACH ROW
BEGIN
    IF NEW.dataEntrada IS NULL THEN
        SET NEW.dataEntrada = CURDATE();
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_impedir_delete_armazem_com_lotes
BEFORE DELETE ON Armazem
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) 
        FROM Lote 
        WHERE Armazem_idArmazem = OLD.idArmazem
          AND dataSaida IS NULL) > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Não é possível excluir o armazém: existem lotes ativos.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_auto_data_geracao_relatorio
BEFORE INSERT ON relatorio
FOR EACH ROW
BEGIN
    IF NEW.dataGeracao IS NULL THEN
        SET NEW.dataGeracao = CURDATE();
    END IF;
END$$
DELIMITER ;









