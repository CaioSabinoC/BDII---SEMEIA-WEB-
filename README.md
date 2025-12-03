<div align="center">
  <h1>Semeia Web – Banco de Dados</h1>
  <h3>Sistema de Controle e Transparência da Distribuição de Sementes em Pernambuco</h3>

  <p><strong>Disciplina:</strong> Banco de Dados |
  <strong>Instituição:</strong> Senac PE</p>

</div>

<hr>

<h2>Sobre o Projeto</h2>
<p>
O <strong>Semeia Web</strong> é um sistema criado para organizar e garantir a transparência no processo de distribuição de sementes em Pernambuco. 
O projeto auxilia no cadastro de municípios, armazéns, sementes, lotes e permite o rastreamento completo das movimentações dos estoques.
</p>


<p>
Este repositório contém toda a <strong>modelagem de banco de dados</strong> do sistema, incluindo Modelagem Entidade-Relacionamento, Modelagem Relacional, scripts SQL, procedures, views e triggers desenvolvidas.
</p>

<hr>

<h2>Tecnologias Utilizadas</h2>
<ul>
  <li><strong>BRModelo</strong> – Modelo Entidade-Relacionamento</li>
  <li><strong>MySQL</strong> – Banco de dados relacional</li>
  <li><strong>MySQL Workbench</strong> – Modelagem e engenharia reversa</li>
  <li><strong>SQL</strong> – Linguagem para criação e manipulação do banco</li>
</ul>

<hr>

<h2>Entidades do Banco de Dados</h2>

<h3>Município</h3>
<p>Registra os municípios atendidos pelo programa, permitindo organizar a distribuição de sementes por região.</p>

<h3>Armazém</h3>
<p>Locais onde as sementes são armazenadas. Cada armazém pertence a um município.</p>

<h3>Endereço</h3>
<p>Registro detalhado da localização de cada armazém.</p>

<h3>Semente</h3>
<p>Tipos de sementes disponibilizadas pelo IPA, com informações para controle e rastreabilidade.</p>

<h3>Lote</h3>
<p>Gerencia entrada, saída e estoque das sementes em cada armazém.</p>

<h3>Distribuição</h3>
<p>Rastreia a movimentação dos lotes entre armazéns e agentes de distribuição.</p>

<h3>Usuário</h3>
<p>Cadastra gestores, operadores e responsáveis pelo processo.</p>

<h3>Telefone</h3>
<p>Guarda contatos dos usuários.</p>

<h3>Relatório</h3>
<p>Armazena os relatórios gerados no sistema.</p>

<h3>Transparência</h3>
<p>Informações públicas para garantir transparência na distribuição.</p>

<hr>

<h2>Modelagem Entidade-Relacionamento</h2>
<img width="1632" height="749" alt="Captura de tela 2025-11-21 191307" src="https://github.com/user-attachments/assets/df2bca0c-e7b6-4b36-8ff8-62592d1080e9" alt="DER" width="600">

<hr>

<h2>Modelagem Relacional</h2>
<img width="1185" height="900" alt="ER_IPA" src="https://github.com/user-attachments/assets/f4d688df-25cd-4c05-ac17-70e5ad6bd6c0" alt="Modelo Relacional" width="600">

<hr>

<h2>Scripts SQL Inclusos</h2>
<ul>
  <li><strong>Criação de tabelas</strong></li>
  <li><strong>Relacionamentos e chaves estrangeiras</strong></li>
  <li><strong>Views</strong> – consultas prontas para o sistema</li>
  <li><strong>Triggers</strong> – automações no banco</li>
  <li><strong>Stored Procedures</strong> – rotinas para operações internas</li>
  <li><strong>Functions</strong> – cálculos e retornos personalizados</li>
</ul>

<hr>

<h2>Autores</h2>
<ul>
  <li><strong>Arthur Vinicius</strong></li>
  <li><strong>Caio Sabino</strong></li>
  <li><strong>Marcos Vinícius</strong></li>
  <li><strong>Thauan Bezerra</strong></li>
</ul>

<hr>

<div align="center">
  <h3>🌱 Semeia Web – 2025</h3>
  <p>Desenvolvido com dedicação para o Senac PE</p>
</div>
