\set  ScriptPath '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/postgreSQL_implementation'
SELECT current_database(), Current_User;

\i :ScriptPath'/COVID19_Define_21_02.sql'
\i :ScriptPath'/COVID19_LoadData_21_02.sql'
SET Search_Path To Todos;
\i :ScriptPath'/COVID19_Corrige_21_02.sql'
\i :ScriptPath'/COVID19_Comments_21_02.sql'
SET Search_Path To D2;
\i :ScriptPath'/COVID19_Corrige_21_02.sql'
\i :ScriptPath'/COVID19_Analise_Covid.sql'
