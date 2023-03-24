from enum import StrEnum, auto
from typing import Optional, Dict
from pydantic import BaseModel

class PredictorTypeDto(StrEnum):
    MODEL = auto()
    RULES = auto()

class RiskDto(StrEnum):
    LOW = auto()
    MEDIUM = auto()
    HIGH = auto()

class PredictionDto(BaseModel):
    prediction: RiskDto
    probabilities: Optional[Dict[RiskDto, float]]
    predictor_type: PredictorTypeDto

class DriverInformationDto(BaseModel):
    training: bool
    age: int
    miles: float

class VehicleInformationDto(BaseModel):
    emergency_braking: int
    braking_distance: float
    power: float

class RiskPredictionInputDto(BaseModel):
    driver: DriverInformationDto
    vehicle: VehicleInformationDto
