# Quantas distribuições cada agente realizou no período de janeiro 2025?
SELECT  u.nome 'Agente',
u.CPF 'CPF',
u.email 'Email',
u.cargo 'Cargo',
COUNT(d.idDistribuicao) 'Distribuições'
FROM Distribuicao d
	INNER JOIN usuario u ON d.usuario_CPF = u.CPF
		WHERE d.dataDistribuicao BETWEEN '2025-01-01' AND '2025-01-31'
			GROUP BY u.CPF
				ORDER BY Distribuições DESC;

# Quantas distribuições cada armazém enviou (origem), ordenando do maior para o menor?
SELECT a.nome 'Armazem de Origem',
m.nome 'Município',
m.regiao 'Região',
COUNT(d.idDistribuicao) 'Total de Envios'
FROM Distribuicao d
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Origem = a.idArmazem
    INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
		GROUP BY a.idArmazem
			ORDER BY 'Total de Envios' DESC;

# Listar agentes que realizaram mais de 3 distribuições.
SELECT u.nome,
u.CPF 'CPF',
u.email 'Email',
u.cargo 'Cargo',
COUNT(d.idDistribuicao) 'Total'
FROM usuario u
	INNER JOIN Distribuicao d ON u.CPF = d.usuario_CPF
		GROUP BY u.CPF
			HAVING COUNT(d.idDistribuicao) > 3;

# Qual o número de distribuições concluídas por mês em 2025?
SELECT 
DATE_FORMAT(d.dataDistribuicao, '%M') 'Mês',
COUNT(*) 'Total'
FROM Distribuicao d
	WHERE d.status = 'Concluída'
		GROUP BY Mês
			ORDER BY MIN(d.dataDistribuicao);

# Distribuições agrupadas por tipo de semente (via lote).
SELECT 
s.tipo 'Semente',
COUNT(d.idDistribuicao) 'Distribuições',
CONCAT(FORMAT(SUM(l.quantidadeKg), 2, 'de_DE'),' kg') 'Quantidade'
FROM Distribuicao d
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
	INNER JOIN Semente s ON l.Semente_idSemente = s.idSemente
		GROUP BY s.tipo
			ORDER BY s.tipo;

# Quantidade de relatórios gerados por cada usuário responsável pela distribuição.
SELECT u.nome, 
u.CPF 'CPF',
u.email 'Email',
u.cargo 'Cargo',
COUNT(r.idRelatorio) 'Relatórios Gerados'
FROM relatorio r
	INNER JOIN Distribuicao d ON r.Distribuicao_idDistribuicao = d.idDistribuicao
	INNER JOIN usuario u ON d.usuario_CPF = u.CPF
		GROUP BY u.CPF
			ORDER BY 'Relatórios Gerados' DESC;

#Listar o total de distribuições registradas na transparência por mês.
SELECT 
DATE_FORMAT(t.dataAtualizacao, '%M') 'Mês',
COUNT(*) 'Total de Registros'
FROM Transparencia t
	INNER JOIN Distribuicao d ON t.Distribuicao_idDistribuicao = d.idDistribuicao
		GROUP BY Mês;

# Quantas distribuições cada armazém recebeu como destino.
SELECT a.nome 'Armazém de Destino', 
COUNT(d.idDistribuicao) 'Distribuições Recebidas'
FROM Distribuicao d
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem
		GROUP BY a.nome;

# Listar agentes de distribuição e a média de distribuições realizadas por mês.
SELECT u.nome,
u.CPF 'CPF',
u.cargo 'Cargo',
COUNT(d.idDistribuicao) / 12 AS mediaMensal
FROM usuario u
	INNER JOIN Distribuicao d ON u.CPF = d.usuario_CPF
		GROUP BY u.CPF;

# Total de movimentações por armazém sejam entradas e saídas
SELECT a.nome,
COUNT(d.idDistribuicao) Movimentacoes
FROM Armazem a
	INNER JOIN Distribuicao d ON a.idArmazem IN (d.Armazem_idArmazem_Origem, d.Armazem_idArmazem_Destino)
		GROUP BY a.nome
			ORDER BY movimentacoes DESC;

# Total de semente distribuída por tipo (via soma do peso dos lotes).
SELECT s.tipo 'Semente',
CONCAT(FORMAT(SUM(l.quantidadeKg), 2, 'de_DE'),' kg') 'Total Distribuído'
FROM Distribuicao d
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
	INNER JOIN Semente s ON l.Semente_idSemente = s.idSemente
		GROUP BY s.tipo;

#Distribuições feitas por cada agente.
SELECT u.nome 'Agente',
u.CPF 'CPF',
u.cargo 'Cargo',
COUNT(d.idDistribuicao) 'Total'
FROM usuario u
	INNER JOIN Distribuicao d ON u.CPF = d.usuario_CPF
		GROUP BY u.CPF
			ORDER BY total DESC;

# Total de kg distribuídos por tipo de semente em janeiro
SELECT 
s.tipo 'Semente',
CONCAT(FORMAT(SUM(l.quantidadeKg), 2, 'de_DE'),' kg') 'Total Distribuído'
FROM Distribuicao d
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
	INNER JOIN Semente s ON l.Semente_idSemente = s.idSemente
		WHERE d.dataDistribuicao BETWEEN '2025-01-01' AND '2025-01-31'
			GROUP BY s.tipo
				ORDER BY 'Total Distribuído' DESC;

# Total KG distribuído por município
SELECT m.nome Município,
CONCAT(FORMAT(SUM(l.quantidadeKg), 2, 'de_DE'),' kg') 'Total Distribuído'
FROM Distribuicao d
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
		GROUP BY m.nome
			ORDER BY 'Total Distribuído' DESC;

#Total de distribuições por região em determinado ano
SELECT m.regiao 'Região',
CONCAT(FORMAT(SUM(l.quantidadeKg), 2, 'de_DE'),' kg') 'Total Distribuído'
FROM Distribuicao d INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
		WHERE YEAR(d.dataDistribuicao) = 2025
			GROUP BY m.regiao
				ORDER BY 'Total Distribuído' DESC;

# Quantidade distribuída por agente
SELECT u.nome 'Agente',
CONCAT(FORMAT(SUM(l.quantidadeKg), 2, 'de_DE'),' kg') 'Total Distribuído'
FROM Distribuicao d
	INNER JOIN Usuario u ON d.Usuario_CPF = u.CPF
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
		WHERE u.tipoUsuario = 'Agente de Distribuicao'
			GROUP BY u.nome
				ORDER BY 'Total Distribuído' DESC;

# Total KG distribuído por armazém
SELECT a.nome 'Armazém',
CONCAT(FORMAT(SUM(l.quantidadeKg), 2, 'de_DE'),' kg') 'Total Distribuído'
FROM Distribuicao d
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Origem = a.idArmazem
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
		GROUP BY a.nome
			ORDER BY 'Total Distribuído' DESC;

# Média de KG por distribuição por região
SELECT m.regiao 'Região',
CONCAT(FORMAT(AVG(l.quantidadeKg), 2, 'de_DE'),' kg')'Média Por Região'
FROM Distribuicao d
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
		GROUP BY m.regiao;

# KG distribuídos por região em um intervalo (dinâmico)
SELECT m.regiao,
CONCAT(FORMAT(SUM(l.quantidadeKg), 2, 'de_DE'),' kg') 'Total Distribuído'
FROM Distribuicao d
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
		WHERE d.dataDistribuicao BETWEEN '2025-01-01' AND '2025-01-31'
			GROUP BY m.regiao;

# Quantidade total de KG distribuídos por município(Concluidas)
SELECT 
m.nome 'Município Destino',
CONCAT(FORMAT(SUM(l.quantidadeKg), 2, 'de_DE'),' kg') 'Total Distribuído'
FROM Distribuicao d
	INNER JOIN Lote l ON d.Lote_idLote = l.idLote
	INNER JOIN Armazem a ON d.Armazem_idArmazem_Destino = a.idArmazem
	INNER JOIN Municipio m ON a.Municipio_idMunicipio1 = m.idMunicipio
	WHERE d.idDistribuicao IN (
		SELECT idDistribuicao
		FROM Distribuicao
			WHERE status = 'Concluída')
		GROUP BY m.nome
			ORDER BY 'Total Distribuído' DESC;




















