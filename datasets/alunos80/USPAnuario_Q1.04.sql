-------------------------------------------------------
-- Caetano Traina Júnior -- Agosto de 2016 ------------
-- Ler e preparar a Tabela UnidadeUSP -----------------
-------------------------------------------------------

DROP TABLE IF EXISTS UnidadeUSP;
CREATE TABLE UnidadeUSP(
    Tipo TEXT,
	Sigla TEXT, 
	Nome TEXT, 
	Campus TEXT, 
	Criacao TEXT
	);

--========Ajustar o caminho do arquivo:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
\copy UnidadeUSP from '/datasets/alunos80/USPAnuario_Q1.04.csv' CSV HEADER;

ALTER TABLE UnidadeUSP ADD Incorporacao TEXT;

UPDATE UnidadeUSP 
    SET Incorporacao=substring(Criacao from '/(.*$)'),
	Criacao=substring(Criacao from '[^/]*'),
	Tipo=regexp_replace(Tipo, ' - ', '-');

--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
CREATE OR REPLACE VIEW Tabelas AS
        SELECT 1::Integer AS Numero, 'Nomes'::Text  AS NomeTab, Count(*)::BIGINT AS NroTuplas FROM Nomes UNION 
        SELECT 2, 'Sobrenomes', Count(*) FROM Sobrenomes UNION 
        SELECT 3, 'Cidades',    Count(*) FROM Cidades UNION 
        SELECT 4, 'UnidadeUSP', Count(*) FROM UnidadeUSP -- -> Deve resultar em 88
    ORDER BY Numero;

TABLE Tabelas;

