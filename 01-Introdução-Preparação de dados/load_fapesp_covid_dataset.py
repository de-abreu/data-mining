from datetime import date
import enum
import re
import pandas as pd
from typing import Annotated, Any, final
from sqlalchemy import (
    CheckConstraint as constraint,
    Enum,
    ForeignKey as fk,
    PrimaryKeyConstraint as pkc,
    String,
    create_engine,
)
from sqlalchemy.orm import (
    declarative_base,
    Mapped,
    relationship,
    sessionmaker,
    mapped_column as column,
    validates,
)
from sqlalchemy.ext.hybrid import hybrid_property


# Funções auxiliares e tipos anotados


def backref(back_populates: str) -> Mapped[Any]:
    return relationship(back_populates=back_populates)


def childOf(back_populates: str) -> Mapped[Any]:
    return relationship(
        back_populates=back_populates,
        cascade="all, delete-orphan",
    )


def parse_date(date_string: str) -> date:
    try:
        # Parse da data no formato DD/MM/AAAA
        day, month, year = map(int, date_string.split("/"))
        return date(year, month, day)
    except (ValueError, AttributeError) as e:
        raise ValueError(
            f"Formato de data inválido: {date_string}. Formato esperado: DD/MM/AAAA"
        ) from e


Date = Annotated[date, parse_date]
Base = declarative_base()

# Declaração das tabelas


@final
class EstadoBrasil(enum.Enum):
    AC = "AC"  # Acre
    AL = "AL"  # Alagoas
    AP = "AP"  # Amapá
    AM = "AM"  # Amazonas
    BA = "BA"  # Bahia
    CE = "CE"  # Ceará
    DF = "DF"  # Distrito Federal
    ES = "ES"  # Espírito Santo
    GO = "GO"  # Goiás
    MA = "MA"  # Maranhão
    MT = "MT"  # Mato Grosso
    MS = "MS"  # Mato Grosso do Sul
    MG = "MG"  # Minas Gerais
    PA = "PA"  # Pará
    PB = "PB"  # Paraíba
    PR = "PR"  # Paraná
    PE = "PE"  # Pernambuco
    PI = "PI"  # Piauí
    RJ = "RJ"  # Rio de Janeiro
    RN = "RN"  # Rio Grande do Norte
    RS = "RS"  # Rio Grande do Sul
    RO = "RO"  # Rondônia
    RR = "RR"  # Roraima
    SC = "SC"  # Santa Catarina
    SP = "SP"  # São Paulo
    SE = "SE"  # Sergipe
    TO = "TO"  # Tocantins


class Paciente(Base):
    """
    Tabela de pacientes Covid-19 FAPESP

    Atributos:
        ID_Paciente: Identificação única do paciente (correlaciona com o ID_PACIENTE de todos os arquivos onde aparece). 32 caracteres alfanuméricos
        IC_Sexo: Sexo do Paciente. 1 caracter alfanumérico. F - Feminino; M - Masculino
        AA_Nascimento: Ano de nascimento do Paciente. 4 caracteres alfanuméricos.
            Os 4 dígitos do ano do nascimento; ou
            AAAA - para ano de nascimento igual ou anterior a 1930 (visando anonimização);
            YYYY - quaisquer outros anos, em caso de anonimização do ano
        CD_Pais: Pais de residencia do Paciente. 2 caracteres alfanuméricos. BR ou XX (país estrangeiro)
        CD_UF: Unidade da Federacao de residencia do Paciente. 2
        caracteres alfanuméricos
        CD_Municipio: Municipio de residencia do Paciente. Alfanumérico.
            Nome do município por extenso,
            ou MMMM - quando houver necessidade de anonimização ou estrangeiro
        CD_Reproduzido: [Descrição não encontrada nos comentários]
    """

    __tablename__: str = "Pacientes"

    ID_Paciente: Mapped[str] = column(String(32), primary_key=True)
    IC_Sexo: Mapped[str] = column(
        String(1), constraint("IC_Sexo IN ('M', 'F')", name="check_sexo")
    )
    AA_Nascimento: Mapped[str] = column(
        String(4),
        constraint(
            "AA_Nascimento = 'AAAA' OR  AA_Nascimento = 'YYYY' OR AA_Nascimento ~ '^[0-9]{4}$'",
            name="check_nascimento",
        ),
    )
    CD_Pais: Mapped[str] = column(String(2))
    CD_UF: Mapped[str] = column(Enum(EstadoBrasil))
    CD_Municipio: Mapped[str]
    CD_Reproduzido: Mapped[str]

    # Relações
    exames: Mapped[list["ExamLab"]] = childOf("paciente")
    desfechos: Mapped[list["Desfecho"]] = childOf("paciente")


@final
class Origem(enum.Enum):
    LAB = "LAB"  # Unidade laboratorial
    HOSP = "HOSP"  # Unidade hospitalar
    UTI = "UTI"  # Unidade de Tratamento Intensivo


class ExamLab(Base):
    """
    Tabela de exames Covid-19 FAPESP

    Atributos:
        ID_Paciente: Identificação única do paciente (correlaciona com o ID_PACIENTE de todos os arquivos onde aparece). 32 caracteres alfanuméricos
        ID_Atendimento: Identificação única do atendimento. Correlaciona com o ID_ATENDIMENTO de todas as tabelas onde aparece. 32 caracteres alfanuméricos
        DT_Coleta: Data em que o material foi coletado do paciente (DD/MM/AAAA)
        DE_Origem: Local de Coleta do exame. 4 caracteres alfanuméricos:
            LAB – Exame realizado por paciente em uma unidade de atendimento laboratorial;
            HOSP – Exame realizado por paciente dentro de uma Unidade Hospitalar;
            UTI - exame realizado na UTI
        DE_Exame: Descrição do exame realizado. Alfanumérico.
            Exemplo: HEMOGRAMA, sangue total / GLICOSE, plasma / SODIO, soro / POTASSIO, soro.
            Um exame é composto por 1 ou mais analitos.
        DE_Analito: Descrição do analito. Alfanumérico. Exemplo: Eritrócitos / Leucócitos / Glicose / Ureia / Creatinina.
            Para o exame Hemograma, tem o resultado de vários analitos: Eritrócitos, Hemoglobina, Leucócitos, Linfócitos, etc.
            A maioria dos exames tem somente 1 analito, por exemplo Glicose, Colesterol Total, Uréia e Creatinina.
        DE_Resultado: Resultado do exame, associado ao DE_ANALITO. Alfanumérico. Se DE_ANALITO exige valor numérico, NNNN se inteiro ou NNNN,NNN se casas decimais;
            Se DE_ANALITO exige qualitativo, String com domínio restrito;
            Se DE_ANALITO por observação microscópica, String conteúdo livre.
            Exemplo de dominio restrito - Positivo, Detectado, Reagente, nâo reagente, etc.
            Exemplo de conteúdo livre - 'não foram observados caracteres tóxico-degenerativos nos neutrófilos, não foram observadas atipias linfocitárias'
        CD_Unidade: Unidade de Medida utilizada na Metodologia do laboratório específico para analisar o exame. Alfanumérico.
            Exemplo: g/dL (gramas por decilitro)
        CD_ValorReferencia: Faixa de valores de referência. Alfanumérico. Resultado ou faixa de resultados considerado normal para este analito.
            Exemplo para Glicose: 75 a 99
    """

    __tablename__: str = "ExamLabs"
    ID_Paciente: Mapped[str] = column(fk("Pacientes.ID_Paciente"))
    ID_Atendimento: Mapped[str] = column(String(32))
    DT_Coleta: Mapped[Date]
    DE_Origem: Mapped[str] = column(Enum(Origem))
    DE_Exame: Mapped[str]
    DE_Analito: Mapped[str]
    DE_Resultado: Mapped[str]
    CD_Unidade: Mapped[str]
    CD_ValorReferencia: Mapped[str]

    @hybrid_property
    def DE_resultNum(self) -> float | None:
        """
        Extrai valor numérico do resultado ou atribui códigos especiais para resultados textuais.
        Baseado na lógica do script COVID19_Corrige_21_02.sql
        """
        if not self.DE_Resultado:
            return None

        # Extrai valor numérico do resultado
        numeric_match = re.search(r"-?\d+[,.]?\d*", self.DE_Resultado)
        if numeric_match:
            numeric_str = numeric_match.group().replace(",", ".")
            try:
                return float(numeric_str)
            except ValueError:
                pass

        # Aplica códigos especiais para exames COVID
        if self.DE_Exame and re.search(
            r"(covid)|(sars.cov.2)|(corona)", self.DE_Exame, re.IGNORECASE
        ):
            resultado_lower = self.DE_Resultado.lower()

            if re.search(r"detectados anticorpos", resultado_lower):
                return -1000.0
            elif re.search(
                r"(n.o detectado)|(n.o reagente)|(negativo)|(aus.ncia de anticorpos)",
                resultado_lower,
            ):
                return -1111.0
            elif re.search(r"(detectado)|(reagente)|(positivo)", resultado_lower):
                return -1000.0
            elif re.search(r"(indetect.avel)|(inconclusivo)", resultado_lower):
                return -1234.0
            else:
                return -2222.0

        return None

    # Relações
    paciente: Mapped["Paciente"] = backref("exames")

    __table_args__: tuple[pkc,] = (pkc("ID_Paciente", "ID_Atendimento"),)


class Desfecho(Base):
    """
    Tabela de desfechos Covid-19 FAPESP

    Atributos:
        ID_Paciente: Identificação única do paciente (correlaciona com o ID_PACIENTE de todos os arquivos onde aparece. 32 caracteres alfanuméricos)
        ID_Atendimento: Identificação única do atendimento. Cada atendimento tem um desfecho. Correlaciona com ID_ATENDIMENTO de todas as tabelas onde aparece
        DT_Atendimento: Data de realização do atendimento - (DD/MM/AAAA)
        DE_TipoAtendimento: Descrição do tipo de atendimento realizado. Texto livre. Exemplo: Pronto atendimento.
        ID_Clinica: Identificação da clínica onde o evento aconteceu. Numérico. Exemplo: 1013
        DE_Clinica: Descrição da clínica onde o evento aconteceu. Texto livre. Exemplo: Cardiologia
        DT_Desfecho: Data do desfecho - (DD/MM/YYYY) ou string DDMMAA se DE_DESFECHO for óbito
        DE_Desfecho: Descriçao do desfecho. Texto livre. Exemplo: Alta médica melhorado
    """

    __tablename__: str = "Desfechos"

    ID_Paciente: Mapped[str] = column(fk("Pacientes.ID_Paciente"))
    ID_Atendimento: Mapped[str] = column(String(32))
    DT_Atendimento: Mapped[Date]
    DE_TipoAtendimento: Mapped[str]
    ID_Clinica: Mapped[int]
    DE_Clinica: Mapped[str]
    DT_Desfecho: Mapped[Date | None]
    DE_Desfecho: Mapped[str]

    @validates("DT_Desfecho")
    def validate_dt_desfecho(self, _key: str, value: str) -> str | None:
        return None if value == "DDMMAA" else value

    # Relações
    paciente: Mapped["Paciente"] = backref("desfechos")

    __table_args: tuple[pkc,] = (pkc("ID_Paciente", "ID_Atendimento"),)


# Load each Hospital datasets into its own database
for hospital in ["BPSP", "Einstein", "GrupoFleury", "HC", "HSL"]:
    print(f"Processing {hospital} data ...")
    engine = create_engine(f"sqlite:///../fapcov2103/{hospital}.db")
    Session = sessionmaker(bind=engine)
    session = Session()

    Base.metadata.drop_all(engine)
    Base.metadata.clear()
    Base.metadata.create_all(engine)
    for data in ["Pacientes", "ExamLabs", "Desfechos"]:
        try:
            df = pd.read_csv(
                f"datasets/{hospital}/{hospital}_{data}.csv",
                delimiter="|",
                encoding="utf-8",
                low_memory=False,
            )
            df.to_sql(data, engine, if_exists="append", index=False)

        except Exception:
            pass
