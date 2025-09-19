from typing import Any, TypeVar
from sqlalchemy.orm import (
    Mapped,
    RelationshipProperty,
    Session,
    mapped_column as column,
)
from sqlalchemy.sql.functions import now
from sqlalchemy.orm import declarative_base
from .annotated_types import TIME
from .functions import camelToSnake

Base = declarative_base()
BaseModelT = TypeVar("BaseModelT", bound="BaseModel")


class BaseModel(Base):
    __abstract__: bool = True
    __allow_unmapped__: bool = True
    __tablename__: str

    created: Mapped[TIME] = column(server_default=now())
    updated: Mapped[TIME] = column(server_default=now(), onupdate=now())

    @classmethod
    def __init_subclass__(cls, **kwargs: Any) -> None:
        """
        Create tables with names derived from the classes that originated them.
        """
        super().__init_subclass__(**kwargs)  # pyright: ignore[reportUnknownMemberType]
        cls.__tablename__ = camelToSnake(cls.__name__)

    @classmethod
    def _validate_attributes(
        cls: type[BaseModelT], attributes: dict[str, Any]
    ) -> tuple[dict[str, Any], dict[str, Any]]:
        if invalid_descriptors := [
            descriptor
            for descriptor in attributes.keys()
            if descriptor not in {"unique", "defaults"}
        ]:
            raise ValueError(
                f"""
                Invalid top level descriptor(s): {invalid_descriptors}.
                Valid top level descriptors: 'unique' and 'defaults'
                """
            )
        unique = attributes.get("unique", {})
        defaults = attributes.get("defaults", {})
        attrs = unique | defaults
        if invalid_attrs := [attr for attr in attrs.keys() if not hasattr(cls, attr)]:
            raise AttributeError(
                f"""
                Class '{cls.__name__}' has no attribute(s): {invalid_attrs}
                Valid attributes: {list(cls.__mapper__.attrs.keys())}
                """
            )
        return unique, defaults

    @classmethod
    def _resolve_attributes(
        cls: type[BaseModelT], session: Session, attributes: dict[str, Any]
    ) -> dict[str, Any]:
        resolved: dict[str, Any] = {}
        for key, value in attributes.items():
            attr = getattr(cls, key)
            if value and isinstance(attr.property, RelationshipProperty):
                related_cls = attr.property.mapper.class_  # pyright: ignore [reportUnknownVariableType, reportUnknownMemberType]
                if isinstance(value, list):
                    resolved[key] = [
                        related_cls.get_or_create(session, item)[0]  # pyright: ignore [reportUnknownMemberType]
                        for item in value  # pyright: ignore [reportUnknownVariableType]
                    ]
                else:
                    resolved[key] = related_cls.get_or_create(session, value)[0]  # pyright: ignore [reportUnknownMemberType]
            else:
                resolved[key] = value
        return resolved

    @classmethod
    def get_or_create(
        cls: type[BaseModelT], session: Session, attributes: dict[str, Any]
    ) -> tuple[BaseModelT, bool]:
        """
        Recursively get or create an instance of the model, resolving nested relationships.
        """

        # Disable automatic session updates
        with session.no_autoflush:
            # Check attribute validity
            unique, defaults = cls._validate_attributes(attributes)

            # Resolve unique attributes, recursively getting or creating its
            # relationships
            unique = cls._resolve_attributes(session, unique)

            # Return if instance with unique attributes is found
            session.flush()
            if unique and (instance := session.query(cls).filter_by(**unique).first()):
                return instance, False

            # otherwise create instance with its unique and default values
            attr = unique | cls._resolve_attributes(session, defaults)
            instance = cls(**attr)
            session.add(instance)
        return instance, True
