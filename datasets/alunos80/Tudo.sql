\set  ScriptPath '/datasets/alunos80/'

DROP DATABASE IF EXISTS alunos80;
CREATE DATABASE alunos80 WITH OWNER = postgres;
\c "host=postgres port=5432 user=postgres dbname=postgres password=postgres sslmode=disable"
SELECT current_database(), Current_User;

\i :ScriptPath'NomesProprios_Carga.sql'
\i :ScriptPath'SobreNomes_Carga.sql'
\i :ScriptPath'CreateInsertTab_Cidades.sql'
\i :ScriptPath'USPAnuario_Q1.04.sql'
\i :ScriptPath'USPAnuario_T3.02.sql'
\i :ScriptPath'Cria_Alunos.sql'
\i :ScriptPath'Cria_Professor.sql'
\i :ScriptPath'Cria_Discip.sql'
\i :ScriptPath'Cria_MatrTurma.sql'
\i :ScriptPath'Cria-MatrTurmaAnoSemestre.sql'
