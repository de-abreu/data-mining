from datetime import datetime
from typing_extensions import Annotated
from sqlalchemy import CheckConstraint, DateTime, Numeric, String
from sqlalchemy.orm import mapped_column as column


CNPJ = Annotated[str, column(String(14))]
CPF = Annotated[str, column(String(11))]
GENERIC_STRING = Annotated[str, column(String(255))]
PHONE = Annotated[str, column(String(15))]
CEP = Annotated[str, column(String(8))]
PRICE = Annotated[str, column(Numeric(10, 2))]
REGISTER = Annotated[str, column(String(10))]
STATE = Annotated[
    str,
    column(
        String(2), CheckConstraint("state ~ '^[A-Z]{2}$'", name="check_state")
    ),
]
TIME = Annotated[datetime, column(DateTime(timezone=True))]
