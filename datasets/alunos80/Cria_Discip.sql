-------------------------------------------------------------------------------------------------------
-- Caetano Traina Júnior -- Agosto de 2016 ------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--=======================================================================================================--
--==    Roda NomesProprios-Carga.sql  						--==--  Cria a tabela de Nomes próprios    ==--
--==    Roda SobreNomes-Carga.sql                           --==--  Cria a tabela de Sobrenomes        ==--
--==    Roda: CreateInsertTab-Cidades.sql                   --==--  Cria a tabela de Cidades do brasil ==--
--==    Roda Cria-Alunos.sql  -->  Só até o bloco indicado: --==--  Cria a tabela Aluno80K             ==--
--==    Roda Cria-Prof.sql    -->  Só até o bloco indicado: --==--  Cria a tabela Professor80K         ==--
--==    Roda USPAnuario-Q1.04.sql  --  Usa USPAnuario-Q1.04.csv  --  Gera UnidadeUSP                   ==--
--==    Roda USPAnuario-T3.02.sql  --  Usa USPAnuario-T3.02.csv  --  Gera DeptoUSP                     ==--
--==    Roda Cria-Discip.sql  -->  Só até o bloco indicado: --==--  Cria a tabela Discip80K            ==--
--==================================================================================================

--=============================================
-- Criar e popular a tabela objetivo: PrepDiscip
DROP TABLE IF EXISTS PrepDiscip;
CREATE TABLE PrepDiscip (
	DiscipId    INTEGER,
	DeptoId     INTEGER,
	DiscipDeptoID INTEGER,
	Unidade     TEXT,
    SiglaDepto  CHAR(3),
    Sigla       CHAR(7),
    Nome        TEXT,
    SiglaPreReq CHAR(7),
    IdSiglaPreReq INTEGER,
    NNcred      DECIMAL(2)
) ;
--	Id, Unidade, SiglaDepto, Sigla, Nome, Siglaprereq, NNcred --


--==================================================---
-- Tabela com as quantidades: DeptoUSP
--    DeptoId, TipoUnidade, Unidade, Sigla, Departamento, Semestre, TotDiscip, TurmasTeorica, TurmasPratica, NNalunosTeorica, NNalunosPratica
--    DeptoId,              Unidade, SiglaDepto,
--													DiscipId, Sigla, Nome, Siglaprereq, NNcred

--==================================================---
DROP SEQUENCE IF EXISTS NDiscip;
CREATE SEQUENCE NDiscip START 1;
INSERT INTO PrepDiscip (DiscipId, DeptoId, DiscipDeptoID, Unidade, SiglaDepto)
    WITH RECURSIVE Data (r) as
         (SELECT 0, 0, 0, NULL, NULL
    UNION ALL
         SELECT NextVal('NDiscip') DiscipId,
		         DeptoUSP.DeptoId,
                 -- generate_series(1,CAST(DeptoUSP.TotDiscip/10 AS INTEGER)), -- Resumo
                 generate_series(1,CAST((DeptoUSP.TotDiscip*(.9+.5*Random())) AS INTEGER)),
		         DeptoUSP.Unidade,
	             DeptoUSP.Sigla
        FROM DeptoUSP 
        WHERE DeptoUSP.DeptoId <= 550
        )
    SELECT * FROM Data;

DELETE FROM PrepDiscip WHERE DiscipId=0;
DROP SEQUENCE NDiscip;


--=============================================
--Preparar as Disciplinas
UPDATE PrepDiscip
    SET Sigla=SiglaDepto || '-' || CAST(DeptoID+DiscipDeptoID+100 AS CHAR(4)),
	    Nome='Disciplina ' || CAST(DeptoID+DiscipDeptoID+100 AS CHAR(4)) || ' do ' || Unidade || ' Departamento ' || SiglaDepto,
		IdSiglaprereq= CASE WHEN Random()>.5 THEN ABS(DiscipId+200*(Random()-.5)) END,
		NNcred=2*Random()+3*Random()+2*Random()+1
	;

CREATE INDEX PrepDiscip_PK ON PrepDiscip(DiscipId);	
UPDATE PrepDiscip P
    SET SiglaPreReq=(SELECT T.Sigla FROM PrepDiscip T WHERE P.IdSiglaPreReq=T.DiscipId
        );

-- Apagar tuplas repetidas
SELECT Sigla, Min(DiscipDeptoID) DMin INTO TEMPORARY Temp_Discip
    FROM PrepDiscip
    WHERE Sigla IN (
    SELECT Sigla FROM PrepDiscip
        GROUP By Sigla
        HAVING Count(*)>1 )
        GROUP BY Sigla;
DELETE FROM PrepDiscip PP
    USING Temp_Discip F
    WHERE F.Sigla=pp.Sigla AND F.DMin<>PP.DiscipDeptoID;
DROP TABLE Temp_Discip;


--SELECT * FROM PrepDiscip;

--=============================================
-- Gera a Tabela Discip
DROP TABLE IF EXISTS Discip;
CREATE TABLE Discip (
	Unidade     TEXT,
    SiglaDepto  char(3),
    Sigla       char(7),
    Nome        TEXT,
    Siglaprereq char(7),
    NNcred      decimal(2)
);

INSERT INTO Discip
    SELECT Unidade, SiglaDepto, Sigla, Nome, SiglaPreReq, NNCred FROM PrepDiscip;


--==================================================================================================
--==================================================================================================
--ATÉ AQUI       ===================================================================================
--==================================================================================================
--==================================================================================================

-- SELECT * FROM Discip;

-- SELECT Unidade, Count(*)
--     FROM Discip
--     GROUP BY Unidade
--     ORDER BY Unidade;

-- SELECT Unidade, SiglaDepto, Count(*)
--     FROM Discip
--     GROUP BY Unidade, SiglaDepto
--     ORDER BY Unidade, SiglaDepto;


------================--------------
-- Criar índices
CREATE INDEX Discip_CP ON Discip(Sigla);
DROP INDEX PrepDiscip_PK;

--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
CREATE OR REPLACE VIEW Tabelas AS
        SELECT 1::Integer AS Numero, 'Nomes'::Text  AS NomeTab, Count(*)::Integer AS NroTuplas FROM Nomes UNION 
        SELECT 2, 'Sobrenomes',  Count(*) FROM Sobrenomes UNION 
        SELECT 3, 'Cidades',     Count(*) FROM Cidades    UNION 
        SELECT 4, 'UnidadeUSP',  Count(*) FROM UnidadeUSP UNION 
        SELECT 5, 'DeptoUSP',    Count(*) FROM DeptoUSP   UNION 
        SELECT 51, 'Alunos',     Count(*) FROM Alunos     UNION 
        SELECT 11, 'PrepAluno',  Count(*) FROM PrepAluno  UNION 
        SELECT 52, 'Professor',  Count(*) FROM Professor  UNION 
        SELECT 21, 'Niveis',     Count(*) FROM Niveis     UNION 
        SELECT 12, 'PrepProf',   Count(*) FROM PrepProf   UNION 
        SELECT 53, 'Discip',     Count(*) FROM Discip     UNION 
        SELECT 13, 'PrepDiscip', Count(*) FROM PrepDiscip -----
    ORDER BY Numero;

TABLE Tabelas;





-- --==================================================================================================
-- --==    Criar uma tabela com tuplas em quantidades definida em outra tabela  =======================
-- --==
-- --==================================================================================================

-- --==================================================---
-- -- Criar e popular a tabela com as quantidades: Aux1 --
-- DROP TABLE IF EXISTS Aux1;
-- CREATE TABLE Aux1( 
--     id  serial,
--     xx  int4,
--     reg  int4,
-- 	Num int2
-- );

-- INSERT INTO Aux1 (xx, reg, Num)
--     SELECT generate_series(1,10,1),
-- 	    9999*Random(),
--         1+5*Random();

-- --==================================================---
-- -- Criar e popular a tabela objetivo: Aux2           --
-- DROP TABLE IF EXISTS Aux2;
-- CREATE TABLE Aux2( 
--     id  serial,
--     xx  int4,
--     reg  int4,
-- 	regreg int4
-- );

-- INSERT INTO Aux2 (Id, xx, reg, regreg)
--     WITH RECURSIVE Data (r) as
--          (SELECT 1,0,0,0
--     UNION ALL
--          SELECT Aux1.Id,
--                  generate_series(1,Aux1.Num),
-- 	             Aux1.reg,
-- 	             1+5*Random()
--         FROM Aux1 
--         WHERE Aux1.Id <= 12
--          )
--     SELECT * FROM Data;

-- DROP TABLE Aux1;
-- DROP TABLE Aux2;
																	
																	