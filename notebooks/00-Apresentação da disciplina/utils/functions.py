from re import sub
from typing import Any
from sqlalchemy.orm import (
    Mapped,
    MappedColumn,
    mapped_column as column,
    relationship,
)
from sqlalchemy import CheckConstraint as constraint, ForeignKey as fk, Integer


def defaultPrimaryKey() -> Mapped[int]:
    return column(Integer, autoincrement=True, primary_key=True)


def parentPrimaryKey(parent: str) -> Mapped[Any]:
    return column(fk(f"{parent}.id"), primary_key=True)


def positive(column_name: str) -> constraint:
    name = column_name
    return constraint(f"{name} > 0", name=f"check_{name}")


def after(before: str, after: str) -> constraint:
    return constraint(
        f"{after} > {before}", name=f"check_{before}_after_{after}"
    )


def digits(name: str) -> constraint:
    return constraint(f"{name} ~ '^[0-9]+$'", name=f"check_{name}")


def camelToSnake(string: str) -> str:
    return sub(r"(?<!^)(?=[A-Z])", "_", string).lower()


def backref(back_populates: str) -> Mapped[Any]:
    return relationship(back_populates=back_populates)


def childOf(back_populates: str) -> Mapped[Any]:
    return relationship(
        back_populates=back_populates,
        cascade="all, delete-orphan",
    )


def foreignKeyCascade(foreign_key: str) -> MappedColumn[Any]:
    return column(fk(foreign_key, ondelete="CASCADE"))
