COMMENT ON TABLE Pacientes IS 'Tabela de pacientes Covid-19 FAPESP';
COMMENT ON COLUMN Pacientes.ID_Paciente  IS 'Identificação única do paciente (correlaciona com o ID_PACIENTE de todos os arquivos onde aparece). 32 caracteres alfanuméricos';
COMMENT ON COLUMN Pacientes.IC_Sexo      IS 'Sexo do Paciente. 1 caracter alfanumérico. F - Feminino; M - Masculino';
COMMENT ON COLUMN Pacientes.AA_Nascimento IS E'Ano de nascimento do Paciente. 4 caracteres alfanuméricos.\n Os 4 dígitos do ano do nascimento; ou\n AAAA - para ano de nascimento igual ou anterior a 1930 (visando anonimização);\n YYYY - quaisquer outros anos, em caso de anonimização do ano';
COMMENT ON COLUMN Pacientes.CD_Pais      IS 'Pais de residencia do Paciente.	2 caracteres alfanuméricos. BR ou XX (país estrangeiro)';
COMMENT ON COLUMN Pacientes.CD_UF        IS E'Unidade da Federacao de residencia do Paciente. 2 caracteres alfanumérico\n AC - Acre, AL - Alagoas, AM - Amazonas, AP - Amapá, BA - Bahia, CE - Ceará, DF - Distrito Federal, ES - Espírito Santo, GO - Goiás, MA - Maranhão, MG - Minas Gerais, MS - Mato Grosso do Sul, MT - Mato Grosso, PA - Pará, PB - Paraíba, PE - Pernambuco, PI - Piauí, PR - Paraná, RJ - Rio de Janeiro, RN - Rio Grande do Norte, RO - Rondônia, RR - Roraima, RS - Rio Grande do Sul, SC - Santa Catarina, SE - Sergipe, SP - São Paulo, TO - Tocantins, UU -  quando houver necessidade de  anonimização/estrangeiro';
COMMENT ON COLUMN Pacientes.CD_Municipio IS E'Municipio de residencia do Paciente. Alfanumérico.\n Nome do município por extenso,\n ou MMMM - quando houver necessidade de  anonimização ou estrangeiro';
COMMENT ON COLUMN Pacientes.CD_Distrito  IS E'CEP parcial da residencia do Paciente. 5 caracteres alfanuméricos. Os primeiros cinco dígitos do CEP (Código de Endereçamento Postal Brasileiro).\n CCCC - quando houver necessidade de  anonimização ou estrangeiro';

COMMENT ON TABLE ExamLabs IS 'Tabela de exames Covid-19 FAPESP';
COMMENT ON COLUMN ExamLabs.ID_Paciente        IS 'Identificação única do paciente (correlaciona com o ID_PACIENTE de todos os arquivos onde aparece). 32 caracteres alfanuméricos';
COMMENT ON COLUMN ExamLabs.ID_Atendimento     IS 'Identificação única do atendimento. Correlaciona com o ID_ATENDIMENTO de todas as tabelas onde aparece. 32 caracteres alfanuméricos';
COMMENT ON COLUMN ExamLabs.DT_Coleta          IS 'Data em que o material foi coletado do paciente (DD/MM/AAAA)';
COMMENT ON COLUMN ExamLabs.DE_Origem          IS E'Local de Coleta do exame. 4 caracteres alfanuméricos:\n  LAB – Exame realizado por paciente em uma  unidade de atendimento laboratorial;\n  HOSP – Exame realizado por paciente dentro de uma Unidade Hospitalar;\n  UTI - exame realizado na UTI';
COMMENT ON COLUMN ExamLabs.DE_Exame           IS E'Descrição do exame realizado. Alfanumérico.\n  Exemplo: HEMOGRAMA, sangue total / GLICOSE, plasma / SODIO, soro / POTASSIO, soro.\n Um exame é composto por 1 ou mais analitos.';
COMMENT ON COLUMN ExamLabs.DE_Analito         IS E'Descrição do analito. Alfanumérico. Exemplo: Eritrócitos / Leucócitos / Glicose / Ureia / Creatinina.\n Para o exame Hemograma, tem o resultado de vários analitos: Eritrócitos, Hemoglobina, Leucócitos, Linfócitos, etc.\n A maioria dos exames tem somente 1 analito, por exemplo  Glicose, Colesterol Total, Uréia e Creatinina.';
COMMENT ON COLUMN ExamLabs.DE_Resultado       IS E'Resultado do exame, associado ao DE_ANALITO. Alfanumérico. Se DE_ANALITO exige valor numérico, NNNN se inteiro ou NNNN,NNN se casas decimais;\n  Se DE_ANALITO exige qualitativo, String com domínio restrito;\n  Se DE_ANALITO por observação microscópica, String conteúdo livre.\n Exemplo de dominio restrito - Positivo, Detectado, Reagente, nâo reagente, etc.\n Exemplo de conteúdo livre - ''não foram observados caracteres tóxico-degenerativos nos neutrófilos, não foram observadas atipias linfocitárias''';
COMMENT ON COLUMN ExamLabs.CD_Unidade         IS E'Unidade de Medida utilizada na Metodologia do laboratório específico para analisar o exame. Alfanumérico. \n Exemplo: g/dL (gramas por decilitro)';
COMMENT ON COLUMN ExamLabs.CD_ValorReferencia IS E'Faixa de valores de referência. Alfanumérico. Resultado ou faixa de resultados considerado normal para este analito.\n  Exemplo para Glicose: 75 a 99';


COMMENT ON TABLE Desfechos IS E'Tabela de desfechos  Covid-19 FAPESP\n (só tem dados do Hospital São Luiz)';
COMMENT ON COLUMN Desfechos.ID_Paciente        IS 'Identificação única do paciente (correlaciona com o ID_PACIENTE de todos os arquivos onde aparece. 32 caracteres alfanuméricos)';
COMMENT ON COLUMN Desfechos.ID_Atendimento     IS 'Identificação única do atendimento. Cada atendimento tem um desfecho. Correlaciona com ID_ATENDIMENTO de todas as tabelas onde aparece';
COMMENT ON COLUMN Desfechos.DT_Atendimento     IS 'Data de realização do atendimento - (DD/MM/AAAA)';
COMMENT ON COLUMN Desfechos.DE_TipoAtendimento IS 'Descrição do tipo de atendimento realizado.	Texto livre. Exemplo: Pronto atendimento.';
COMMENT ON COLUMN Desfechos.ID_Clinica         IS 'Identificação da clínica onde o evento aconteceu. Numérico. Exemplo: 1013';
COMMENT ON COLUMN Desfechos.DE_Clinica         IS 'Descrição da clínica onde o evento aconteceu. Texto livre. Exemplo: Cardiologia';
COMMENT ON COLUMN Desfechos.DT_Desfecho        IS 'Data do desfecho - (DD/MM/YYYY) ou string DDMMAA se DE_DESFECHO for óbito';
COMMENT ON COLUMN Desfechos.DE_Desfecho        IS 'Descriçao do desfecho. Texto livre. Exemplo: Alta médica melhorado';
