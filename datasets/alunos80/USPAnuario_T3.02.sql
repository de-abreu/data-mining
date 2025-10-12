-- Caetano Traina Júnior -- Agosto de 2016 ------------------------------------------
-- Ler e preparar a Tabela DeptoUSP -------------------------------------------------
--    Obtido de: https://uspdigital.usp.br/anuario/AnuarioControle#  (formado XLS) --
-------------------------------------------------------------------------------------

DROP TABLE IF EXISTS TempDeptoUSP;
CREATE TABLE TempDeptoUSP(
    TipoUnidade TEXT,
	Unidade TEXT,
	Sigla TEXT,
	Departamento TEXT,
	Métrica TEXT,
	Semestre NUMERIC,
	Total NUMERIC
	);
DROP TABLE IF EXISTS DeptoUSP;
-- CREATE TABLE DeptoUSP(
--     DeptoId NUMERIC,
--     TipoUnidade TEXT,
--     Unidade TEXT,
--     Sigla TEXT,
--     Departamento TEXT,
--     Semestre NUMERIC,
--     TotDiscip NUMERIC,
--     TurmasTeorica NUMERIC,
--     TurmasPratica NUMERIC,
--     NNalunosTeorica NUMERIC,
--     NNalunosPratica NUMERIC
--     );
--===  DeptoId, TipoUnidade, Unidade, Sigla, Departamento, Semestre, TotDiscip, TurmasTeorica, TurmasPratica, NNalunosTeorica, NNalunosPratica

--========Ajustar o caminho do arquivo:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
\copy TempDeptoUSP from '/datasets/alunos80/USPAnuario_T3.02.csv' CSV HEADER;

DROP SEQUENCE IF EXISTS NDiscip;
CREATE SEQUENCE NDiscip START 1;
SELECT NextVal('NDiscip') DeptoId, 
       TipoUnidade, Unidade, Sigla, Departamento, Semestre, 
       SUM(CASE WHEN Métrica='Disciplinas Ministradas' THEN Total END) TotDiscip,
       SUM(CASE WHEN Métrica='Número de Turmas Teóricas' THEN Total END) TurmasTeorica,
       SUM(CASE WHEN Métrica='Número de Turmas Práticas' THEN Total END) TurmasPratica,
       SUM(CASE WHEN Métrica='Dimensão da Turma Teórica' THEN Total END) NNalunosTeorica,
       SUM(CASE WHEN Métrica='Dimensão da Turma Prática' THEN Total END) NNalunosPratica
	INTO DeptoUSP
    FROM TempDeptoUSP
	GROUP BY TipoUnidade, Unidade, Sigla, Departamento, Semestre;

DROP TABLE TempDeptoUSP;
DROP SEQUENCE NDiscip;

-----------------------------------------------------------
-- Total de disciplinas ministradas por semestre
--SELECT Semestre, SUM(TotDiscip) 
--    FROM DeptoUSP
--    GROUP BY Semestre;


--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
CREATE OR REPLACE VIEW Tabelas AS
        SELECT 1::Integer AS Numero, 'Nomes'::Text  AS NomeTab, Count(*)::BIGINT AS NroTuplas FROM Nomes UNION 
        SELECT 2, 'Sobrenomes', Count(*) FROM Sobrenomes UNION 
        SELECT 3, 'Cidades',    Count(*) FROM Cidades UNION 
        SELECT 4, 'UnidadeUSP', Count(*) FROM UnidadeUSP UNION 
        SELECT 5, 'DeptoUSP',   Count(*) FROM DeptoUSP -- -> Deve resultar em 530
    ORDER BY Numero;

TABLE Tabelas;
