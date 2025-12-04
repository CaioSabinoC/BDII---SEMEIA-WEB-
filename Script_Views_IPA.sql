# Situação do estoque por armazém
CREATE VIEW vw_estoque_armazem AS
SELECT a.idArmazem,
	a.nome 'Armazém',
    m.nome 'Municipio',
    m.regiao 'Região',
    SUM(l.quantidadeKg) 'Estoque Atual'
FROM Lote l
	INNER JOIN Armazem a ON l.Armazem_idArmazem = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
		WHERE l.status = 'DISPONÍVEL'
			GROUP BY a.idArmazem, a.nome, m.nome, m.regiao;

# Distribuições realizadas para determinada região
CREATE VIEW vw_distribuicoes_por_regiao AS
SELECT m.regiao 'Região',
    COUNT(*) 'Distribuições'
FROM Distribuicao d
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
		GROUP BY m.regiao;

# Informações do lote
CREATE VIEW vw_rastreabilidade_lote AS
SELECT l.idLote 'ID Lote',
    s.tipo 'Tipo Semente',
    l.dataEntrada 'Entrada',
    l.dataSaida 'Saída',
    l.status 'Status',
    a.nome 'Armazém',
    m.nome 'Município',
    m.regiao 'Região'
FROM Lote l
	INNER JOIN Semente s ON l.Semente_idSemente = s.idSemente
	INNER JOIN Armazem a ON l.Armazem_idArmazem = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio;

# Sementes com prazo de validade curto
CREATE VIEW vw_sementes_proximas_validade AS
SELECT idSemente 'ID Semente',
    tipo 'Semente',
    dataValidade 'Validade',
    DATEDIFF(dataValidade, CURDATE()) 'Dias para Vencer'
FROM Semente
	WHERE dataValidade <= DATE_ADD(CURDATE(), INTERVAL 60 DAY);

# Distribuições por usuário
CREATE VIEW vw_distribuicoes_por_usuario AS
SELECT u.nome 'Nome',
    u.cargo 'Cargo',
    u.email 'Email',
    COUNT(d.idDistribuicao) 'Total Distribuições'
FROM Distribuicao d
	INNER JOIN usuario u ON d.usuario_CPF = u.CPF
		GROUP BY u.CPF;

# Armazém de destino e origem de todas as distribuições
CREATE VIEW vw_fluxo_armazens AS
SELECT d.idDistribuicao 'ID Distribuição',
    d.dataDistribuicao 'Data',
    a1.nome 'Origem',
    a2.nome 'Destino',
    d.status 'Status'
FROM Distribuicao d
	INNER JOIN Armazem a1 ON d.Armazem_idArmazem_Origem = a1.idArmazem
	INNER JOIN Armazem a2 ON d.Armazem_idArmazem_Destino = a2.idArmazem;

#Capacidade x Ocupação dos armazéns
CREATE VIEW vw_ocupacao_armazens AS
SELECT a.idArmazem 'ID Armazém',
    a.nome 'Armazém',
    a.capacidadeKg 'Capacidade' ,
    IFNULL(SUM(l.quantidadeKg), 0) 'Ocupação',
    ROUND((SUM(l.quantidadeKg) / a.capacidadeKg) * 100, 2) 'Percentual de Ocupação'
FROM Armazem a
	LEFT JOIN Lote l ON l.Armazem_idArmazem = a.idArmazem AND l.status = 'DISPONÍVEL'
		GROUP BY a.idArmazem;

#Quantidade de vezes que um lote foi distribuído
CREATE VIEW vw_historico_distribuicao_por_lote AS
SELECT d.Lote_idLote 'ID Lote',
    d.idDistribuicao 'ID Distribuição',
    d.dataDistribuicao 'Data',
    a1.nome 'Origem',
    a2.nome 'Destino',
    d.status 'Status'
FROM Distribuicao d
	INNER JOIN Armazem a1 ON d.Armazem_idArmazem_Origem = a1.idArmazem
	INNER JOIN Armazem a2 ON d.Armazem_idArmazem_Destino = a2.idArmazem;

#Relação dos relatórios gerados
CREATE VIEW vw_relatorios_completos AS
SELECT r.idRelatorio 'ID Relatório',
    r.titulo 'Título',
    r.tipo 'Tipo',
    r.dataGeracao 'Gerado em',
    d.idDistribuicao 'ID Distribuição',
    d.dataDistribuicao 'Data Distribuição',
    a.nome 'Destino'
FROM relatorio r
	INNER JOIN Distribuicao d ON r.Distribuicao_idDistribuicao = d.idDistribuicao
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem;

#Visão geral das movimentações do Programa
CREATE VIEW vw_transparencia_publica AS
SELECT t.idTransparencia 'ID Transparência',
    t.dataAtualizacao 'Ultima Atualização',
    d.idDistribuicao 'ID Distribuição',
    d.dataDistribuicao 'Data Distribuição',
    s.tipo 'Semente',
    l.quantidadeKg 'Quantidade',
    a1.nome 'Origem',
    a2.nome 'Destino'
FROM Transparencia t
	INNER JOIN Distribuicao d ON t.Distribuicao_idDistribuicao = d.idDistribuicao
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
	INNER JOIN Semente s ON l.Semente_idSemente = s.idSemente
	INNER JOIN Armazem a1 ON d.Armazem_idArmazem_Origem = a1.idArmazem
	INNER JOIN Armazem a2 ON d.Armazem_idArmazem_Destino = a2.idArmazem;






