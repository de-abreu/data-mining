-------------------------------------------------------------------------------------------------------
-- Caetano Traina Júnior -- Junho de 2022  ------------------------------------------------------------
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
-->> -->> Ajustar Limit na linha 49

--===============================================================================================---
--===============================================================================================---
-- Gerar as TurmaASs --============================================================================---
--===============================================================================================---
-- Criar e popular a tabela: PrepTurmaAS
DROP TABLE IF EXISTS PrepTurmaAS CASCADE;
-- CREATE TABLE PrepTurmaAS (
--     Codigo      DECIMAL(5),
--     Sigla       CHAR(7),
--     Ano         Integer,
--     Semestre    Integer,
--     NTurmas     DECIMAL(2),
--     NNalunos    DECIMAL(3),
-- 	DiscipId    INTEGER,
-- 	DeptoId     INTEGER,
-- 	Unidade     TEXT
-- 	);
--	Codigo, Sigla, Ano, Semestre, NTurmas, NNalunos, DiscipId, DeptoId, Unidade

SELECT PrepDiscip.Sigla Sigla,
       A Ano, 
       S Semestre, 
       CAST(ABS(4-4*(Random()+Random()+Random())+Random()+Random()) AS INTEGER) NTurmas, 
       10*CAST((DeptoUSP.NNAlunosTeorica+DeptoUSP.NNAlunosPratica)/20 AS INTEGER)+20 NNAlunos, 
       PrepDiscip.DiscipId, 
       PrepDiscip.DeptoId, 
       PrepDiscip.Unidade
    INTO PrepTurmaAS
    FROM PrepDiscip, DeptoUSP,
         Generate_Series(1,2) S,
         Generate_Series(2018,2022) A
    WHERE PrepDiscip.DiscipDeptoID=DeptoUSP.DeptoId AND Random()>.6
    LIMIT 2000;
-- Sigla, Ano, Semestre, NTurmas, NNAlunos, DiscipID, DeptoId, Unidade

UPDATE PrepTurmaAS
    SET NTurmas=1
    WHERE NTurmas<1;

-- SELECT * FROM PrepTurmaAS Order by DiscipId;

-- SELECT NTurmas, Count(*) FROM PrepTurmaAS GROUP BY NTurmas ORDER BY NTurmas

--=================================================
-- Criar e popular a tabela: TurmaAS e TurmaExtendidaAS
DROP TABLE IF EXISTS TurmaEAS;
DROP TABLE IF EXISTS TurmaAS;
--CREATE TABLE TurmaEAS (
--    Sigla       CHAR(7),
--    Ano         INTEGER,
--    Semestre    INTEGER,
--    Numero      DECIMAL(2),
--    Codigo      DECIMAL(5),
--    NNalunos    DECIMAL(3),
--    DiscipId    INTEGER,    --E
--    DeptoId     INTEGER,    --E
--    Unidade     TEXT        --E
--    );

DROP SEQUENCE IF EXISTS NTurmaAS;
CREATE SEQUENCE NTurmaAS START 1000;
SELECT PrepTurmaAS.Sigla,
       PrepTurmaAS.Ano,
       PrepTurmaAS.Semestre,
       generate_series(1,NTurmas) Numero, 
       NextVal('NTurmaAS') Codigo,
       PrepTurmaAS.NNAlunos, 
       PrepTurmaAS.DiscipId, 
       PrepTurmaAS.DeptoId, 
       PrepTurmaAS.Unidade
    INTO TurmaEAS
    FROM PrepTurmaAS;

SELECT TurmaEAS.Sigla,
       TurmaEAS.Numero, 
       TurmaEAS.Ano, 
       TurmaEAS.Semestre, 
       TurmaEAS.Codigo,
       TurmaEAS.NNAlunos 
    INTO TurmaAS
    FROM TurmaEAS;

DROP SEQUENCE NTurmaAS;
	
-- SELECT Numero, Count(*) FROM TurmaEAS WHERE Unidade='ICMC' GROUP BY Numero ORDER BY Numero

--===============================================================================================---
--===============================================================================================---
-- Gerar as Matrículas --========================================================================---
--===============================================================================================---
DROP TABLE IF EXISTS MatriculaAS;
DROP TABLE IF EXISTS PrepMatriculaAS;
--CREATE TABLE MatriculaAS (
--    CodigoTurma DECIMAL(4),
--    Sigla       CHAR(7),
--    Ano,        INTEGER,
--    Semestre,   INTEGER,
--    NUSP        DECIMAL(8),
--    NotaP1      DECIMAL(3,1),
--    NotaP2      DECIMAL(3,1),
--    NotaSub     DECIMAL(3,1),
--    MediaT      DECIMAL(3,1),
--    Frequencia  DECIMAL(3)
--	);

DROP SEQUENCE IF EXISTS NMatricAS;
CREATE SEQUENCE NMatricAS START 1;
SELECT TurmaEAS.Codigo CodigoTurma,
       TurmaEAS.Sigla Sigla,
       TurmaEAS.Ano Ano,
       TurmaEAS.Semestre Semestre,
       CAST(((SELECT Valor FROM AcadVarInt WHERE Nome='GeraAlunos')-1)*Random()+1 AS INTEGER) IdAluno,  --<==> CAST(79999*Random()+1 AS INTEGER) IdAluno,
	   CAST(0 as DECIMAL(8))   NUSP,
       NextVal('NMatricAS') MatricId,
       generate_series(1,CAST(10+((NNAlunos-10)*Random()) AS INTEGER)) Numero,
	   NNAlunos
    INTO PrepMatriculaAS
    FROM TurmaEAS;
DROP SEQUENCE NMatricAS;

--Select Min(IdAluno), Max(IdAluno) from PrepMatricula;

DROP TABLE TurmaEAS;

DROP INDEX IF EXISTS PrepAluno_IX;
CREATE INDEX PrepAluno_IX ON PrepAluno(ID);
UPDATE PrepMatriculaAS M
    SET NUSP=(SELECT A.NUSP FROM PrepAluno A WHERE M.IdAluno=A.ID
        );

-- Remove (NUSP, Sigla, Ano, Semestre) duplicados
DROP TABLE IF EXISTS UNIMATR;
WITH Dup AS (SELECT NUSP, Sigla, Ano, Semestre, Count(*)
         FROM PrepMatriculaAS
         GROUP BY NUSP, Sigla, Ano, Semestre
         HAVING Count(*)>1 ),
     Fica AS (SELECT Row_Number() OVER(Partition BY T.NUSP, T.Sigla, T.Ano, T.Semestre) AS N, T.*
         FROM PrepMatriculaAS T JOIN Dup ON (T.NUSP, T.Sigla, T.Ano, T.Semestre)=(Dup.NUSP, Dup.Sigla, Dup.Ano, Dup.Semestre) )
    SELECT * INTO TEMPORARY UniMatr FROM Fica WHERE N=1;
DELETE FROM PrepMatriculaAS M
    USING UniMatr
    WHERE (UniMatr.NUSP, UniMatr.Sigla, UniMatr.Ano, UniMatr.Semestre)=(M.NUSP, M.Sigla, M.Ano, M.Semestre);
INSERT INTO PrepMatriculaAS(CodigoTurma, Sigla, NUSP, Ano, Semestre)
    SELECT CodigoTurma, Sigla, NUSP, Ano, Semestre
        FROM UniMatr;


SELECT CodigoTurma, 
       Sigla,
       NUSP, 
       Ano,
       Semestre,
       CAST(0 as DECIMAL(3,1)) NotaP1,
       CAST(0 as DECIMAL(3,1)) NotaP2,
       CAST(0 as DECIMAL(3,1)) NotaSub,
       CAST(0 as DECIMAL(3,1)) MediaP,
       CAST(0 as DECIMAL(3,1)) MediaT,
       CAST(0 as DECIMAL(3,1)) NF,
       CAST(0 as DECIMAL(3))   Frequencia
    INTO MatriculaAS
    FROM PrepMatriculaAS;

---- Preencher notas de provas e Médias de trabalho
UPDATE MatriculaAS 
    SET NotaP1=CASE WHEN Random() >.1  THEN (5*Random()+3*Random()+2*Random()+.01)::Numeric(3,1) END,
        NotaP2=CASE WHEN Random() >.15 THEN (2*NotaP1/3+8*(Random()-.5))/1.4+4. END,
        NotaSub=CASE WHEN Random() >.6 THEN ((NotaP1+NotaP2)/3+6*(Random()-.5))/1.3+3. END,
        MediaT=CASE WHEN Random() >.05 THEN 40*(.25-(Random()-.5)^2) END;

UPDATE MatriculaAS 
    SET NotaSub=(5*Random()+3*Random()+2*Random()+.01)::Numeric(3,1)
    WHERE NotaP1+NotaP2<10 AND Random()>.1;

UPDATE MatriculaAS 
    SET NotaP2=(5*Random()+3*Random()+2*Random()+.01)::Numeric(3,1)
    WHERE NotaP2 NOT Between 0. AND 10.;

UPDATE MatriculaAS 
    SET NotaSub=(5*Random()+3*Random()+2*Random()+.01)::Numeric(3,1)
    WHERE NotaSub NOT Between 0. AND 10.;

---- Calcular a média das provas: Sub do mal!
UPDATE MatriculaAS 
    SET MediaP=CASE WHEN NotaSub IS NOT NULL AND COALESCE(NotaP1,0)>=COALESCE(NotaP2,0) AND NotaSub>COALESCE(NotaP2,0) THEN (COALESCE(NotaP2,0)+NotaSub)/2 
                    WHEN NotaSub IS NOT NULL AND COALESCE(NotaP2,0)>COALESCE(NotaP1,0) AND NotaSub>COALESCE(NotaP1,0) THEN (COALESCE(NotaP1,0)+NotaSub)/2 
					ELSE (COALESCE(NotaP1,0)+COALESCE(NotaP2,0))/2
                    END;

-- Média de provas e trabalhos não variam muito, e trabalhos tendem a ter notas maiores:
UPDATE MatriculaAS 
    SET MediaT=(MediaT+MediaP+10)/3
    WHERE Abs(MediaT-MediaP)>4 AND MediaT IS NOT NULL AND MediaP IS NOT NULL;

UPDATE MatriculaAS 
    SET NF=(COALESCE(MediaT,0)+MediaP)/2;


-- Medias de provas Finais:
-- SELECT MediaP::INT, COUNT(*) from MatriculaAS GROUP BY MediaP::INT ORDER BY 1;
-- SELECT NF::INT, COUNT(*) from MatriculaAS GROUP BY NF::INT ORDER BY 1;

--Distribuições das notas 
-- SELECT NotaP1::INT, COUNT(*) from MatriculaAS GROUP BY NotaP1::INT ORDER BY 1;
-- 
-- SELECT NotaP1::INT, NotaP2::INT, COUNT(*) from MatriculaAS 
--     where NotaP1::INT=5
-- GROUP BY NotaP1::INT, NotaP2::INT ORDER BY 1, 2;


-----------------------------------------------------------
---- Para calcular medias (tal como definido em SCC640)
-- Alter table MatriculaAS add MediaP numeric(3,1)
-- Alter table MatriculaAS add MediaT numeric(3,1)
-- Alter table MatriculaAS add NF numeric(3,1)
-- 
-- select *, 
--      CASE WHEN MediaP>=5 AND MediaT>=5 THEN NF=(.6*MediaP+.4*MediaT)/2
--           WHEN MediaP>=5 AND MediaT<5  THEN NF=(.3*MediaP+.4*MediaT)/2
--           WHEN MediaP<5  AND MediaT>=5 THEN NF=(.6*MediaP+.2*MediaT)/2
--           WHEN MediaP<5  AND MediaT<5  THEN NF=(.3*MediaP+.2*MediaT)/2
--                              END final
--     FROM MatriculaAS limit 10


--==================================================================================================
--==================================================================================================
--ATÉ AQUI       ===================================================================================
--==================================================================================================
--==================================================================================================

-- -- Numero de turmas por número de alunos por turma
-- SELECT Cnt AlunoPTurma, Count(*) Turmas
--         FROM (Select CodigoTurma, Count(Codigoturma) Cnt from MatriculaAS 
--         GROUP BY CodigoTurma) AS T
--     GROUP BY Cnt
--     ORDER BY Cnt;
-- 
-- -- Numero de Matriculas por Aluno
-- SELECT NMAT MatrPAluno, Count(*) Turmas
--         FROM (Select NUSP, Count(*) NMat from MatriculaAS 
--         GROUP BY NUSP) AS T
--     GROUP BY NMat
--     ORDER BY NMat;


--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
CREATE OR REPLACE VIEW Tabelas AS
        SELECT 1::Integer AS Numero, 'Nomes'::Text  AS NomeTab, Count(*)::Integer AS NroTuplas FROM Nomes UNION 
        SELECT 2, 'Sobrenomes',     Count(*) FROM Sobrenomes    UNION 
        SELECT 3, 'Cidades',        Count(*) FROM Cidades       UNION 
        SELECT 4, 'UnidadeUSP',     Count(*) FROM UnidadeUSP    UNION 
        SELECT 5, 'DeptoUSP',       Count(*) FROM DeptoUSP      UNION 
        SELECT 51, 'Alunos',        Count(*) FROM Alunos        UNION 
        SELECT 11, 'PrepAluno',     Count(*) FROM PrepAluno     UNION 
        SELECT 52, 'Professor',     Count(*) FROM Professor     UNION 
        SELECT 21, 'Niveis',        Count(*) FROM Niveis        UNION 
        SELECT 12, 'PrepProf',      Count(*) FROM PrepProf      UNION 
        SELECT 53, 'Discip',        Count(*) FROM Discip        UNION 
        SELECT 13, 'PrepDiscip',    Count(*) FROM PrepDiscip    UNION 
        SELECT 54, 'Matricula',     Count(*) FROM Matricula     UNION 
        SELECT 14, 'PrepMatricula', Count(*) FROM PrepMatricula UNION 
        SELECT 55, 'Turma',         Count(*) FROM Turma         UNION 
        SELECT 15, 'PrepTurma',     Count(*) FROM PrepTurma     UNION
        SELECT 541, 'MatriculaAS',     Count(*) FROM MatriculaAS     UNION 
        SELECT 141, 'PrepMatriculaAS', Count(*) FROM PrepMatriculaAS UNION 
        SELECT 551, 'TurmaAS',         Count(*) FROM TurmaAS         UNION 
        SELECT 151, 'PrepTurmaAS',     Count(*) FROM PrepTurmaAS     -----
    ORDER BY Numero;

DELETE FROM AcadVarInt WHERE Nome='CountTurma';
INSERT INTO AcadVarInt 
    SELECT 'CountTurma' Nome, NroTuplas Valor FROM Tabelas WHERE NomeTab='Turma';

TABLE Tabelas;


--==================================================================================================
-- FALTA: Implementar tabela Ministra ==============================================================
--==================================================================================================

