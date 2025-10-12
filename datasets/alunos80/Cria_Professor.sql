-------------------------------------------------------------------------------------------------------
-- Caetano Traina Júnior -- Agosto de 2016 ------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--=======================================================================================================--
--==    Roda NomesProprios-Carga.sql  						--==--  Cria a tabela de Nomes próprios    ==--
--==    Roda SobreNomes-Carga.sql                           --==--  Cria a tabela de Sobrenomes        ==--
--==    Roda: CreateInsertTab-Cidades.sql                   --==--  Cria a tabela de Cidades do brasil ==--
--==    Roda Cria-Alunos.sql  -->  Só até o bloco indicado: --==--  Cria a tabela Aluno80K             ==--
--==    Roda Cria-Prof.sql  -->  Só até o bloco indicado:   --==--  Cria a tabela Professor80K         ==--
--=======================================================================================================

-- Preparar a tabela das Cidades
DROP TABLE IF EXISTS Temp_Cidades;
SELECT Municipio||'-'|| Estado Cidade, Populacao, 
    Row_Number() OVER (ORDER BY CASE Estado 
	                       WHEN 'SP' THEN Populacao*5 
	                       WHEN 'PR' THEN Populacao*3 
	                       WHEN 'MT' THEN Populacao*3 
	                       WHEN 'MG' THEN Populacao*3 
	                       WHEN 'RJ' THEN Populacao*2 
						   ELSE Populacao END DESC) Id
    INTO Temp_Cidades
    FROM Cidades;
DELETE FROM Temp_Cidades WHERE ID>300;

--=============================================
-- Criar e popular a tabela PrepProf
DROP TABLE IF EXISTS PrepProf;
CREATE TABLE  PrepProf (
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
	DataNasc    DATE,
	Grau        INTEGER
) ;
--	Id, NUSP, Nome, NomeProprio, Sobrenome, NomeProprioNN, SobrenomeNN, Genero, Idade, Cidade, CidadeNN, DataNasc, CidadeNN, Grau

INSERT INTO PrepProf (Id, NUSP, Nome, NomeProprio, Sobrenome, NomeProprioNN, SobrenomeNN, Genero, Idade, Cidade, DataNasc, CidadeNN, Grau)
    WITH RECURSIVE Data (r) as
         (SELECT 1 Id,  
		         (10000000+89999999*Random()) NUSP, 
				 '' Nome, 
				 '' NomeProprio, 
				 '' Sobrenome, 
				 1+4011*Random() NomeProprioNN, 
				 1+2410*Random() SobrenomeNN, 
				 ' ' Genero, 
				 100000*ABS((2*Random()-1)*(2*Random()-1)) Idade, 
				 '' Cidade, 
				 TO_DATE('1936-01-01', 'YYYY-MM-DD') DataNasc, 
				 720*ABS((2*Random()-1)*(2*Random()-1)) CidadeNN,
				 1+2*Random()+2*Random()+2*Random()+Random() Grau
    UNION ALL
         SELECT r+1,
		         (10000000+89999999*Random()) NUSP, 
				 '' Nome, 
				 '' NomeProprio, 
				 '' Sobrenome, 
				 1+4011*Random() NomeProprioNN, 
				 1+2410*Random() SobrenomeNN, 
				 ' ' Genero, 
				 1000000*ABS((2*Random()-1)*(2*Random()-1)) Idade, 
				 '' Cidade, 
				 TO_DATE('1936-01-01', 'YYYY-MM-DD') DataNasc, 
				 720*ABS((2*Random()-1)*(2*Random()-1)) CidadeNN,
				 1+2*Random()+2*Random()+2*Random()+Random() Grau
		     FROM Data WHERE r+1 <= 6200
         )
    SELECT * FROM Data;

-- Elimina possíveis repetições do NUSP (Não garante unicidade, mas a probabilidade de ocorrer é muito baixa)
UPDATE PrepProf 
    SET NUSP=(10000000+89999999*Random()) 
	WHERE NUSP IN (SELECT NUSP 
	                   FROM PrepProf P 
	                   GROUP BY P.NUSP 
	                   HAVING Count(*)>1);

-- No caso raríssimo de ainda haver dois professores com número usp repetido, elimina um deles.
DROP TABLE IF EXISTS TempProf;
SELECT * INTO TEMPORARY TempProf FROM PrepProf
    GROUP BY Id, NUSP, Nome, NomeProprio, Sobrenome, NomeProprioNN, SobrenomeNN, Genero, Idade, Cidade, CidadeNN, DataNasc, CidadeNN, Grau
    HAVING Count(*)>1;
DELETE FROM PrepProf
    USING TempProf
    WHERE PrepProf.NUSP=TempProf.NUSP;
INSERT INTO PrepProf SELECT * FROM  TempProf;
DROP TABLE TempProf;


--	SELECT Grau, Count(*) FROM PrepProf GROUP BY Grau ORDER BY Grau;

--=============================================
--Preparar as cidades e os graus
UPDATE PrepProf
    SET CidadeNN=CASE WHEN (Random()<.40) THEN 1
                      ELSE CidadeNN+1
                      END,
        Grau=CASE WHEN Grau=4 THEN 3
                  WHEN Grau>6 THEN 6
                      ELSE Grau
                  END;

DROP TABLE IF EXISTS T;
SELECT CidadeNN, Count(*) C, Row_Number() OVER (ORDER BY Count(*)DESC) Id 
    INTO T FROM PrepProf
    GROUP BY CidadeNN
    ORDER By Count(*) DESC;
UPDATE T SET Id=2 WHERE ID>700;
UPDATE PrepProf P
    SET CidadeNN=(SELECT T.Id FROM T WHERE P.CidadeNN=T.CIdadeNN
        );
DROP TABLE T;

--Acertar os campos textuais
UPDATE PrepProf P SET NomeProprio=(SELECT Nome FROM Nomes N WHERE P.NomeProprioNN=N.Id),
                       Genero=    (SELECT Genero FROM Nomes N WHERE P.NomeProprioNN=N.Id),
                       Sobrenome= (SELECT Nome FROM SobreNomes S WHERE P.SobrenomeNN=S.Id),
                       Idade=CASE WHEN (Random()<.2) THEN 40-(Idade/150000)
                                  WHEN (Random()<.95) Then 32+Idade/50000
                                  ELSE 50+Idade/20000
                             END,
                       Cidade=    (SELECT Cidade FROM Temp_Cidades N WHERE P.CidadeNN=N.Id);

UPDATE PrepProf P 
    SET Nome=NomeProprio||' '||Sobrenome,
	    Idade=CASE WHEN Idade>70 THEN 140-Idade
		           ELSE Idade
			  END;
--Gerar 10 "Josés da Silva"
UPDATE PrepProf 
        SET Nome='José da Silva',
	    NomeProprio='José',
		Sobrenome='da Silva',
		Genero='M'
	WHERE 2000*TRUNC((Id-100)/2000)=ID-100;

DROP TABLE Temp_Cidades;

--=============================================
-- Gera a Tabela PROFESSOR
DROP TABLE IF EXISTS Professor;
CREATE TABLE Professor (
    Nome        VARCHAR(40) NOT NULL,
    NNfuncional NUMERIC(8)  NOT NULL,
    Grau        CHAR(7),
    Idade       NUMERIC(2),
    Cidade      VARCHAR(30)
	);

INSERT INTO Professor 
    SELECT Nome, NUSP NNfuncional, 'MS-'||Grau, Idade, CIdade FROM PrepProf  ORDER BY ID;




--==================================================================================================
--==================================================================================================
--ATÉ AQUI       ===================================================================================
--==================================================================================================
--==================================================================================================


-- SELECT Genero, Count(*) FROM PrepProf GROUP BY Genero;

-- SELECT Idade, Count(*) FROM PrepProf
--     GROUP BY Idade
--     Order BY Idade;
-- 
-- SELECT Cidade, Count(*) FROM PrepProf
--     GROUP BY Cidade
--     ORDER BY Count(*) DESC;
-- 
-- --Quantos são do estado de SP?
-- SELECT Cidade, Count(*) FROM PrepProf WHERE Cidade LIKE '%-SP'
--     GROUP BY Cidade
--     ORDER BY Count(*) DESC;
-- 
-- -- Quantos Têm nomes repetidos
-- SELECT Nome, Count(nome) FROM PrepProf GROUP BY Nome HAVING Count(*)>1 ORDER BY Count(*) DESC;
-- SELECT SUM(C) FROM (SELECT Nome, Count(*) C FROM PrepProf GROUP BY Nome HAVING Count(*)>1 ORDER BY Count(*) DESC) Repet;
-- 
-- --==================================================================================================
-- --Controle:
-- SELECT Idade, Count(*) FROM Professor
--     GROUP BY Idade
--     ORDER BY Idade;
-- 
-- SELECT Cidade, Count(*) FROM Professor
--     GROUP BY Cidade
--     ORDER BY Count(*) DESC;
-- 
-- --Quantos são do estado de SP?
-- SELECT Cidade, Count(*) FROM Professor WHERE Cidade LIKE '%-SP'
--     GROUP BY Cidade
--     ORDER BY Count(*) DESC;
-- SELECT Count(*) FROM Professor WHERE Cidade LIKE '%-SP';
-- 
-- -- Quantos Têm nomes repetidos
-- SELECT Nome, count(nome) FROM Professor GROUP BY Nome HAVING Count(*)>1 ORDER BY Count(*) DESC;
-- SELECT SUM(C) FROM (SELECT Nome, Count(*) C FROM Professor GROUP BY Nome HAVING Count(*)>1 ORDER BY Count(*) DESC) Repet;


--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
--------------------------------------------------
-- Criar índices                                --
--------------------------------------------------
CREATE INDEX Aluno_CP ON Professor(NNfuncional);

--------------------------------------------------
--Criar tabela de explicação de Professor.Nivel --
--------------------------------------------------
DROP VIEW IF EXISTS Niveis;
CREATE VIEW Niveis (Nivel, Titulo) AS
VALUES ('MS-1', 'Auxiliar'), ('MS_2', 'Mestre'),
('MS-3', 'Doutor'), ('MS-5', 'Livre docente'),
('MS-6', 'Titular');

--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
CREATE OR REPLACE VIEW Tabelas AS
        SELECT 1::Integer AS Numero, 'Nomes'::Text  AS NomeTab, Count(*)::Integer AS NroTuplas FROM Nomes UNION 
        SELECT 2, 'Sobrenomes', Count(*) FROM Sobrenomes UNION 
        SELECT 3, 'Cidades',    Count(*) FROM Cidades    UNION 
        SELECT 4, 'UnidadeUSP', Count(*) FROM UnidadeUSP UNION 
        SELECT 5, 'DeptoUSP',   Count(*) FROM DeptoUSP   UNION 
        SELECT 21, 'Niveis',    Count(*) FROM Niveis     UNION 
        SELECT 51, 'Alunos',    Count(*) FROM Alunos     UNION 
        SELECT 11, 'PrepAluno', Count(*) FROM PrepAluno  UNION 
        SELECT 52, 'Professor', Count(*) FROM Professor  UNION 
        SELECT 12, 'PrepProf',  Count(*) FROM PrepProf   -----
    ORDER BY Numero;

TABLE Tabelas;

