# Registrar novo lote
DELIMITER $$
CREATE PROCEDURE sp_registrar_lote(
    IN p_idLote INT,
    IN p_status VARCHAR(45),
    IN p_dataEntrada DATE,
    IN p_quantidadeKg INT,
    IN p_idArmazem INT,
    IN p_idSemente INT)
	BEGIN
		INSERT INTO Lote(idLote, status, dataEntrada, quantidadeKg, Armazem_idArmazem, Semente_idSemente) VALUES (p_idLote, p_status, p_dataEntrada, p_quantidadeKg, p_idArmazem, p_idSemente);
	END $$ DELIMITER ;
    
CALL sp_registrar_lote(
    101,                -- p_idLote
    'DISPONÍVEL',       -- p_status
    '2025-01-10',       -- p_dataEntrada
    500,                -- p_quantidadeKg
    3,                  -- p_idArmazem
    5                  -- p_idSemente
);

# Registrar distribuição
DELIMITER $$
CREATE PROCEDURE sp_registrar_distribuicao(
    IN p_idDistribuicao INT,
    IN p_data DATE,
    IN p_status VARCHAR(45),
    IN p_origem INT,
    IN p_destino INT,
    IN p_usuario VARCHAR(11),
    IN p_lote INT)
BEGIN
    INSERT INTO Distribuicao(idDistribuicao, dataDistribuicao, status, Armazem_idArmazem_Origem, Armazem_idArmazem_Destino, usuario_CPF, Lote_idLote) VALUES (p_idDistribuicao, p_data, p_status, p_origem, p_destino, p_usuario, p_lote);

    UPDATE Lote
    SET status = 'EM MOVIMENTAÇÃO'
    WHERE idLote = p_lote;
END $$ DELIMITER ;

CALL sp_registrar_distribuicao(
    25,                         -- idDistribuicao
    '2025-01-15',              -- data
    'ENVIADO',                 -- status
    3,                         -- armazém origem
    5,                         -- armazém destino
    '10101010101',             -- CPF do usuário
    10                         -- id do lote
);


# Finalizar distribuição
DELIMITER $$
CREATE PROCEDURE sp_finalizar_distribuicao(
    IN p_lote INT,
    IN p_dataSaida DATE)
BEGIN
    UPDATE Lote
    SET status = 'DISTRIBUÍDO',
        dataSaida = p_dataSaida
    WHERE idLote = p_lote;
END $$ DELIMITER ;

CALL sp_finalizar_distribuicao(
    10,             -- id do lote
    '2025-01-20'    -- data de saída
    );

# Troca o armazém do lote
DELIMITER $$
CREATE PROCEDURE sp_mover_lote(IN p_lote INT,IN p_novoArmazem INT)
BEGIN
    UPDATE Lote
    SET Armazem_idArmazem = p_novoArmazem
    WHERE idLote = p_lote;
END $$ DELIMITER ;

CALL sp_mover_lote(  
    10,
    3 
);

# Gera um relatório da distribuição
DELIMITER $$
CREATE PROCEDURE sp_gerar_relatorio(
    IN p_id INT,
    IN p_inicio DATE,
    IN p_fim DATE,
    IN p_tipo VARCHAR(45),
    IN p_titulo VARCHAR(60),
    IN p_arquivo VARCHAR(45),
    IN p_distribuicao INT)
BEGIN
    INSERT INTO relatorio(idRelatorio, dataInicio, dataFim, tipo, dataGeracao, titulo, arquivoPDF, Distribuicao_idDistribuicao) VALUES (p_id, p_inicio, p_fim, p_tipo, CURDATE(), p_titulo, p_arquivo, p_distribuicao);
END $$ DELIMITER ;

CALL sp_gerar_relatorio(
    25,                      -- id do relatório
    '2025-01-01',           -- data início
    '2025-01-31',           -- data fim
    'DISTRIBUICAO',         -- tipo
    'Relatório de Janeiro', -- título
    'jan2025.pdf',          -- arquivo PDF
    10                      -- id da distribuição
);


# Gera um entrada no portal da transparência
DELIMITER $$
CREATE PROCEDURE sp_atualizar_transparencia(
    IN p_id INT,
    IN p_distribuicao INT)
BEGIN
    INSERT INTO Transparencia(idTransparencia, dataAtualizacao, Distribuicao_idDistribuicao) VALUES (p_id, DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), p_distribuicao);
END $$ DELIMITER ;

CALL sp_atualizar_transparencia(
    25,      -- idTransparencia
    15      -- idDistribuicao
    );


# Registro de usuário
DELIMITER $$
CREATE PROCEDURE sp_registrar_usuario(
    IN p_cpf VARCHAR(11),
    IN p_nome VARCHAR(60),
    IN p_email VARCHAR(60),
    IN p_senha VARCHAR(32),
    IN p_cargo VARCHAR(45),
    IN p_tipo VARCHAR(45))
BEGIN
    INSERT INTO usuario(CPF, nome, email, senhaHash, cargo, dataCadastro, tipoUsuario) VALUES (p_cpf, p_nome, p_email, p_senha, p_cargo, CURDATE(), p_tipo);
END $$ DELIMITER ;

CALL sp_registrar_usuario(
    '12345678902',
    'Maria Silva',
    'maria.silva@gmail.com',
    'senha123',
    'Gestor',
    'ADMIN'
);






# Idade das sementes
DELIMITER $$
CREATE FUNCTION fn_idade_semente(p_dataEntrada DATE)
RETURNS INT DETERMINISTIC
BEGIN
    RETURN DATEDIFF(CURDATE(), p_dataEntrada);
END $$ DELIMITER ;

SELECT 
    idLote 'ID',
    dataEntrada 'Entrada',
    fn_idade_semente(dataEntrada) 'Idade em Dias'
FROM Lote;

# Sementes Vencidas
DELIMITER $$
CREATE FUNCTION fn_semente_vencida(p_dataValidade DATE)
RETURNS TINYINT DETERMINISTIC
BEGIN
    RETURN p_dataValidade < CURDATE();
END $$ DELIMITER ;

SELECT 
    idSemente 'ID',
    tipo 'Semente',
    fn_semente_vencida(dataValidade) 'Vencimento'
FROM Semente;


# Dias para o vencimento da semente
DELIMITER $$
CREATE FUNCTION fn_dias_para_vencer(p_dataValidade DATE)
RETURNS INT DETERMINISTIC
BEGIN
    RETURN DATEDIFF(p_dataValidade, CURDATE());
END $$ DELIMITER ;

SELECT 
    idSemente 'ID',
    tipo 'Semente',
    dataValidade 'Validade',
    fn_dias_para_vencer(dataValidade) 'Prazo de Vencimento'
FROM Semente;

# Armazém de um lote
DELIMITER $$
CREATE FUNCTION fn_armazem_lote(p_lote INT)
RETURNS VARCHAR(45) DETERMINISTIC
BEGIN
    DECLARE resultado VARCHAR(45);

    SELECT a.nome INTO resultado
    FROM Lote l
    INNER JOIN Armazem a ON l.Armazem_idArmazem = a.idArmazem
    WHERE l.idLote = p_lote;

    RETURN resultado;
END $$ DELIMITER ;

SELECT 
    idLote 'ID',
    fn_armazem_lote(idLote) 'Armazém'
FROM Lote;

# Total distribuído para um armazém
DELIMITER $$
CREATE FUNCTION fn_total_distribuido_destino(p_armazem INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE total INT;

    SELECT SUM(l.quantidadeKg) INTO total
    FROM Distribuicao d
    INNER JOIN Lote l ON d.Lote_idLote = l.idLote
    WHERE d.Armazem_idArmazem_Destino = p_armazem;

	RETURN IFNULL(total, 0);
END $$ DELIMITER ;

SELECT 
    idArmazem 'ID',
    nome 'Nome',
    fn_total_distribuido_destino(idArmazem) 'Total Distribuído'
FROM Armazem;


# Percentual de ocupação de um armazém
DELIMITER $$
CREATE FUNCTION fn_percentual_ocupacao(p_armazem INT)
RETURNS DECIMAL(5,2) DETERMINISTIC
BEGIN
    DECLARE capacidade INT;
    DECLARE ocupado INT;

    SELECT capacidadeKg INTO capacidade FROM Armazem WHERE idArmazem = p_armazem;

    SELECT SUM(quantidadeKg) INTO ocupado
    FROM Lote
    WHERE Armazem_idArmazem = p_armazem AND status = 'DISPONÍVEL';

    RETURN ROUND((IFNULL(ocupado,0) / capacidade) * 100, 2);
END $$ DELIMITER ;

SELECT 
    idArmazem 'ID',
    nome 'Nome',
    capacidadeKg,
   CONCAT(FORMAT(fn_percentual_ocupacao(idArmazem), 2), '%') `Taxa de Ocupação`
FROM Armazem;

# Responsável pela distribuição
DELIMITER $$
CREATE FUNCTION fn_nome_responsavel(p_idDistribuicao INT)
RETURNS VARCHAR(60) DETERMINISTIC
BEGIN
    DECLARE nomeUser VARCHAR(60);

    SELECT u.nome INTO nomeUser
    FROM Distribuicao d
    INNER JOIN usuario u ON d.usuario_CPF = u.CPF
    WHERE d.idDistribuicao = p_idDistribuicao;

    RETURN nomeUser;
END $$ DELIMITER ;

SELECT 
    d.idDistribuicao 'ID',
    d.dataDistribuicao 'Data',
    fn_nome_responsavel(d.idDistribuicao) 'Responsável'
FROM Distribuicao d;












