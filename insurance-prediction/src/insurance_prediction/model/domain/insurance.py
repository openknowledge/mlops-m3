
from dataclasses import dataclass
from enum import StrEnum, auto
from typing import Dict, Optional

@dataclass
class DriverInformation:
    training: bool
    age: int
    miles: float

@dataclass
class VehicleInformation:
    emergency_braking: int
    braking_distance: float
    power: float

@dataclass
class RiskPredictionInput:
    driver: DriverInformation
    vehicle: VehicleInformation

class PredictorType(StrEnum):
    MODEL = auto()
    RULES = auto()

class Risk(StrEnum):
    LOW = auto()
    MEDIUM = auto()
    HIGH = auto()

@dataclass
class Prediction:
    prediction: Risk
    probabilities: Optional[Dict[Risk, float]]
    predictor_type: PredictorType
