-------------------------------------------------------------------------------------------------------
-- Caetano Traina Júnior -- Agosto de 2016 ------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--=======================================================================================================--
--==    Roda NomesProprios-Carga.sql  						--==--  Cria a tabela de Nomes próprios    ==--
--==    Roda SobreNomes-Carga.sql                           --==--  Cria a tabela de Sobrenomes        ==--
--==    A partir do diretório ..\MeusDados\CidadesBR
--==        Roda: CreateInsertTab-Cidades.sql               --==--  Cria a tabela de Cidades do brasil ==--
--==    Roda Cria-Alunos.sql  -->  Só até o bloco indicado: --==--  Cria a tabela Alunos80K            ==--
--==
--=======================================================================================================--

DELETE FROM AcadVarInt WHERE Nome IN ('GeraAlunos', 'GeraProf');
INSERT INTO AcadVarInt VALUES ('GeraAlunos', 80000);  --== Mínimo 3.000
INSERT INTO AcadVarInt VALUES ('GeraProf', 6200); 
-- Exemplo: 
-- SELECT Valor FROM AcadVarInt WHERE Nome='GeraAlunos';

-- Preparar a tabela das Cidades
DROP TABLE IF EXISTS Temp_Cidades;
SELECT Municipio||'-'|| Estado Cidade, Populacao, 
    Row_Number() OVER (ORDER BY CASE Estado 
	                       WHEN 'SP' THEN Populacao*10 
	                       WHEN 'PR' THEN Populacao*3 
	                       WHEN 'MT' THEN Populacao*3 
	                       WHEN 'MG' THEN Populacao*3 
	                       WHEN 'RJ' THEN Populacao*2 
						   ELSE Populacao END DESC) Id
    INTO Temp_Cidades
    FROM Cidades;
DELETE FROM Temp_Cidades WHERE ID>700;


--=============================================
-- Criar e popular a tabela PrepAluno
DROP TABLE IF EXISTS PrepAluno CASCADE;
CREATE TABLE PrepAluno (
	Id          INTEGER,
    NUSP        decimal(8)  NOT NULL,
    Nome        varchar(40),
    NomeProprio   varchar(40),
    Sobrenome     varchar(40),
    NomeProprioNN   INTEGER,
    SobrenomeNN     INTEGER,
	Genero      CHAR,
    Idade       INTEGER,
    Cidade      varchar(30),
	CidadeNN    INTEGER,
	DataNasc    Date
) ;
--	Id, NUSP, Nome, NomeProprio, Sobrenome, NomeProprioNN, SobrenomeNN, Idade, Cidade, DataNasc, CidadeNN

INSERT INTO PrepAluno (Id, NUSP, Nome, NomeProprio, Sobrenome, NomeProprioNN, SobrenomeNN, Genero, Idade, Cidade, DataNasc, CidadeNN)
    WITH RECURSIVE Data (r) as
         (SELECT 1 Id,  
		         (10000000+89999999*Random()) NUSP, 
				 '' Nome, 
				 '' NomeProprio, 
				 '' Sobrenome, 
--				 1+4011*Random() NomeProprioNN, 
--				 1+2435*Random() SobrenomeNN, 
				 1+(SELECT Valor FROM AcadVarInt WHERE Nome='CountNomes')*Random() NomeProprioNN, 
				 1+(SELECT Valor FROM AcadVarInt WHERE Nome='CountSobrenomes')*Random() SobrenomeNN, 
				 ' ' Genero, 
				 100000*ABS((2*Random()-1)*(2*Random()-1)) Idade, 
				 '' Cidade, 
				 TO_DATE('1936-01-01', 'YYYY-MM-DD') DataNasc, 
				 720*ABS((2*Random()-1)*(2*Random()-1)) CidadeNN
    UNION ALL
         SELECT r+1,
		         (10000000+89999999*Random()) NUSP, 
				 '' Nome, 
				 '' NomeProprio, 
				 '' Sobrenome, 
				 1+(SELECT Valor FROM AcadVarInt WHERE Nome='CountNomes')*Random() NomeProprioNN, 
				 1+(SELECT Valor FROM AcadVarInt WHERE Nome='CountSobrenomes')*Random() SobrenomeNN, 
				 ' ' Genero, 
				 1000000*ABS((2*Random()-1)*(2*Random()-1)) Idade, 
				 '' Cidade, 
				 TO_DATE('1936-01-01', 'YYYY-MM-DD') DataNasc, 
				 720*ABS((2*Random()-1)*(2*Random()-1)) CidadeNN
		     FROM Data WHERE r+1 <= (SELECT Valor FROM AcadVarInt WHERE Nome='GeraAlunos')
         )
    SELECT * FROM Data;

-- Elimina possíveis repetições do NUSP (Não garante unicidade, mas a probabilidade de ocorrer é muito baixa)
UPDATE PrepAluno 
    SET NUSP=(10000000+89999999*Random()) 
	WHERE NUSP IN (SELECT NUSP 
	                   FROM PrepAluno P 
	                   GROUP BY P.NUSP 
	                   HAVING Count(*)>1);

-- No caso raríssimo de ainda haver dois alunos com número usp repetido, elimina um deles. A tabela Ficará com menos do que 80.000 alunos...
DROP TABLE IF EXISTS TempAluno;
SELECT * INTO TEMPORARY TempAluno FROM PrepAluno
    GROUP BY Id, NUSP, Nome, NomeProprio, Sobrenome, NomeProprioNN, SobrenomeNN, Genero, Idade, Cidade, CidadeNN, DataNasc
    HAVING Count(*)>1;
DELETE FROM PrepAluno
    USING TempAluno
    WHERE PrepAluno.NUSP=TempAluno.NUSP;
INSERT INTO PrepAluno SELECT * FROM  TempAluno;
DROP TABLE TempAluno;


--=============================================
--Preparar as cidades
UPDATE PrepAluno
    SET CidadeNN=CASE WHEN (Random()<.40) THEN 1
                      ELSE CidadeNN+1
                      END;
DROP TABLE IF EXISTS T;
SELECT CidadeNN, Count(*) C, Row_Number() OVER (ORDER BY Count(*)DESC) Id 
    INTO T FROM PrepAluno
    GROUP BY CidadeNN
    ORDER By Count(*) DESC;
UPDATE T SET Id=2 WHERE ID>700;
UPDATE PrepAluno P
    SET CidadeNN=(SELECT T.Id FROM T WHERE P.CidadeNN=T.CIdadeNN
        );
DROP TABLE T;

--Acertar os campos textuais
DROP INDEX IF EXISTS Nomes_PK;
CREATE INDEX Nomes_PK ON Nomes(Id);
UPDATE PrepAluno P SET NomeProprio=(SELECT Nome FROM Nomes N WHERE P.NomeProprioNN=N.Id),
                       Genero=     (SELECT Genero FROM Nomes N WHERE P.NomeProprioNN=N.Id),
                       Sobrenome=  (SELECT Nome FROM SobreNomes S WHERE P.SobrenomeNN=S.Id),
                       Idade=CASE WHEN (Random()<.2) THEN 23-(Idade/150000)
                                  WHEN (Random()<.95) Then 21+Idade/50000
                                  ELSE 20+Idade/20000
                             END,
                       Cidade=     (SELECT Cidade FROM Temp_Cidades N WHERE P.CidadeNN=N.Id);
UPDATE PrepAluno P 
    SET Nome=NomeProprio||' '||Sobrenome;

--Gerar 10 "Josés da Silva"
UPDATE PrepAluno 
        SET Nome='José da Silva',
        NomeProprio='José',
        Sobrenome='da Silva',
		Genero='M'
	WHERE (SELECT Valor/10 FROM AcadVarInt WHERE Nome='GeraAlunos')*TRUNC((Id-100)/(SELECT Valor/10 FROM AcadVarInt WHERE Nome='GeraAlunos'))=ID-100;
UPDATE PrepAluno SET 
        Nome='José Lucena',
        NomeProprio='José',
        Sobrenome='Lucena',
		Genero='M',
		Idade=21,
		Cidade='São Paulo',
		NUSP=1234567
	WHERE ID=1234;
UPDATE PrepAluno SET 
        Nome='Maria da Silva',
        NomeProprio='Maria',
        Sobrenome='da Silva',
		Genero='F'
	WHERE ID BETWEEN 2345 AND 2354;
UPDATE PrepAluno SET Idade=15 WHERE Id=1000;
UPDATE PrepAluno SET Idade=81 WHERE Id=2000;

DROP TABLE Temp_Cidades;
DROP INDEX Nomes_PK;

--=============================================
-- Gera a Tabela ALUNOS
DROP TABLE IF EXISTS Alunos;
CREATE TABLE Alunos (
    NUSP        decimal(8)  NOT NULL,
    Nome        varchar(40),
    Idade       INTEGER,
    Cidade      varchar(30)
    );

INSERT INTO Alunos 
    SELECT NUSP, Nome, Idade, CIdade FROM PrepAluno ORDER BY ID;


--==================================================================================================
--==================================================================================================
--ATÉ AQUI       ===================================================================================
--==================================================================================================
--==================================================================================================


--==================================================================================================
-- -- Estatísticas sobre a distribuição dos alunos
-- 
-- SELECT Genero, Count(*) FROM PrepAluno GROUP BY Genero;
-- 
-- SELECT Idade, Count(*) FROM PrepAluno
--     GROUP BY Idade
--     Order By Idade;
-- 
-- SELECT Cidade, Count(*) FROM PrepAluno
--     GROUP BY Cidade
--     Order By Count(*) DESC;
-- 
-- -- Quantos são do estado de SP?
-- SELECT Cidade, Count(*) FROM PrepAluno WHERE Cidade LIKE '%-SP'
--     GROUP BY Cidade
--     Order By Count(*) DESC;
-- 
-- -- Quantos Têm nomes repetidos
-- SELECT Nome, count(nome) From prepaluno group by Nome having count(*)>1 order by count(*) DESC;
-- SELECT SUM(C) FROM (SELECT Nome, count(*) C From prepaluno group by Nome having count(*)>1 order by count(*) DESC) Repet;
-- 
-- --==================================================================================================
-- --Controle:
-- SELECT Idade, Count(*) FROM Alunos
--     GROUP BY Idade
--     Order By Idade;
-- 
-- SELECT Cidade, Count(*) FROM Alunos
--     GROUP BY Cidade
--     Order By Count(*) DESC;
-- 
-- --Quantos são do estado de SP?
-- SELECT Cidade, Count(*) FROM Alunos WHERE Cidade LIKE '%-SP'
--     GROUP BY Cidade
--     Order By Count(*) DESC;
-- SELECT Count(*) FROM Alunos WHERE Cidade LIKE '%-SP';
-- 
-- -- Quantos Têm nomes repetidos
-- SELECT Nome, count(nome) From Alunos group by Nome having count(*)>1 order by count(*) DESC;
-- SELECT SUM(C) FROM (SELECT Nome, count(*) C From Alunos group by Nome having count(*)>1 order by count(*) DESC) Repet;

------================--------------
-- Criar índices
CREATE INDEX Alunos_PK ON Alunos(NUSP);


--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
CREATE OR REPLACE VIEW Tabelas AS
        SELECT 1::Integer AS Numero, 'Nomes'::Text  AS NomeTab, Count(*)::Integer AS NroTuplas FROM Nomes UNION 
        SELECT 2, 'Sobrenomes', Count(*) FROM Sobrenomes UNION 
        SELECT 3, 'Cidades',    Count(*) FROM Cidades UNION 
        SELECT 4, 'UnidadeUSP', Count(*) FROM UnidadeUSP UNION 
        SELECT 5, 'DeptoUSP',   Count(*) FROM DeptoUSP UNION 
        SELECT 51, 'Alunos',     Count(*) FROM Alunos UNION 
        SELECT 11, 'PrepAluno',   Count(*) FROM PrepAluno 
    ORDER BY Numero;

TABLE Tabelas;

