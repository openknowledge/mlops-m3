from typing import Any, Callable, Type, TypeVar

D = TypeVar('D')
T = TypeVar('T')
def to_domain_mapper(type: Type[D]) -> Callable[[D], T]:
    def map_value(value: Any) -> Any:
        if type(value) in {int, str, bool, float}:
            return value
        return to_domain_mapper(type(value))(value)

    def mapper(obj: D) -> T:
        data = {k: map_value(v) for k, v in obj.__dict__.items() if k != 'uuid'}
        return type(**data)
    return mapper
