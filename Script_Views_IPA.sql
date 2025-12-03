# Situação do estoque por armazém
CREATE VIEW vw_estoque_armazem AS
SELECT a.idArmazem,
	a.nome AS nomeArmazem,
    m.nome AS municipio,
    m.regiao,
    SUM(l.quantidadeKg) AS estoqueAtualKg
FROM Lote l
	INNER JOIN Armazem a ON l.Armazem_idArmazem = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
		WHERE l.status = 'DISPONÍVEL'
			GROUP BY a.idArmazem, a.nome, m.nome, m.regiao;

# Distribuições realizadas para determinada região
CREATE VIEW vw_distribuicoes_por_regiao AS
SELECT m.regiao,
    COUNT(*) AS totalDistribuicoes
FROM Distribuicao d
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
		GROUP BY m.regiao;

# Informações do lote
CREATE VIEW vw_rastreabilidade_lote AS
SELECT l.idLote,
    s.tipo AS tipoSemente,
    l.dataEntrada,
    l.dataSaida,
    l.status,
    a.nome AS armazemAtual,
    m.nome AS municipio,
    m.regiao
FROM Lote l
	INNER JOIN Semente s ON l.Semente_idSemente = s.idSemente
	INNER JOIN Armazem a ON l.Armazem_idArmazem = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio;

# Sementes com prazo de validade curto
CREATE VIEW vw_sementes_proximas_validade AS
SELECT idSemente,
    tipo,
    dataValidade,
    DATEDIFF(dataValidade, CURDATE()) AS diasParaVencer
FROM Semente
	WHERE dataValidade <= DATE_ADD(CURDATE(), INTERVAL 60 DAY);

# Distribuições por usuário
CREATE VIEW vw_distribuicoes_por_usuario AS
SELECT u.nome,
    u.cargo,
    u.email,
    COUNT(d.idDistribuicao) AS totalDistribuicoes
FROM Distribuicao d
	INNER JOIN usuario u ON d.usuario_CPF = u.CPF
		GROUP BY u.CPF;

# Armazém de destino e origem de todas as distribuições
CREATE VIEW vw_fluxo_armazens AS
SELECT d.idDistribuicao,
    d.dataDistribuicao,
    a1.nome AS armazemOrigem,
    a2.nome AS armazemDestino,
    d.status
FROM Distribuicao d
	INNER JOIN Armazem a1 ON d.Armazem_idArmazem_Origem = a1.idArmazem
	INNER JOIN Armazem a2 ON d.Armazem_idArmazem_Destino = a2.idArmazem;

#Capacidade x Ocupação dos armazéns
CREATE VIEW vw_ocupacao_armazens AS
SELECT a.idArmazem,
    a.nome,
    a.capacidadeKg,
    IFNULL(SUM(l.quantidadeKg), 0) AS ocupacaoKg,
    ROUND((SUM(l.quantidadeKg) / a.capacidadeKg) * 100, 2) AS percentualOcupacao
FROM Armazem a
	LEFT JOIN Lote l ON l.Armazem_idArmazem = a.idArmazem AND l.status = 'DISPONÍVEL'
		GROUP BY a.idArmazem;

#Quantidade de vezes que um lote foi distribuído
CREATE VIEW vw_historico_distribuicao_por_lote AS
SELECT d.Lote_idLote,
    d.idDistribuicao,
    d.dataDistribuicao,
    a1.nome AS origem,
    a2.nome AS destino,
    d.status
FROM Distribuicao d
	INNER JOIN Armazem a1 ON d.Armazem_idArmazem_Origem = a1.idArmazem
	INNER JOIN Armazem a2 ON d.Armazem_idArmazem_Destino = a2.idArmazem;

#Relação dos relatórios gerados
CREATE VIEW vw_relatorios_completos AS
SELECT r.idRelatorio,
    r.titulo,
    r.tipo,
    r.dataGeracao,
    d.idDistribuicao,
    d.dataDistribuicao,
    a.nome AS armazemDestino
FROM relatorio r
	INNER JOIN Distribuicao d ON r.Distribuicao_idDistribuicao = d.idDistribuicao
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem;

#Visão geral das movimentações do Programa
CREATE VIEW vw_transparencia_publica AS
SELECT t.idTransparencia,
    t.dataAtualizacao,
    d.idDistribuicao,
    d.dataDistribuicao,
    s.tipo AS semente,
    l.quantidadeKg,
    a1.nome AS origem,
    a2.nome AS destino
FROM Transparencia t
	INNER JOIN Distribuicao d ON t.Distribuicao_idDistribuicao = d.idDistribuicao
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
	INNER JOIN Semente s ON l.Semente_idSemente = s.idSemente
	INNER JOIN Armazem a1 ON d.Armazem_idArmazem_Origem = a1.idArmazem
	INNER JOIN Armazem a2 ON d.Armazem_idArmazem_Destino = a2.idArmazem;






