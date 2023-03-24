from typing import Callable
from fastapi import APIRouter

from insurance_prediction.app.application.dto import PredictionDto, RiskPredictionInputDto
from insurance_prediction.app.application.mapper import to_dto_mapper
from insurance_prediction.app.usecase.insurance import predict_risk
from insurance_prediction.model.domain.insurance import Prediction, RiskPredictionInput
from insurance_prediction.model.domain.mapper import to_domain_mapper

router = APIRouter(
    prefix='/predict'
)

prediction_input_mapper: Callable[[RiskPredictionInputDto], RiskPredictionInput] = to_domain_mapper(RiskPredictionInput)
prediction_dto_mapper: Callable[[Prediction], PredictionDto] = to_dto_mapper(PredictionDto)

@router.put(path='/', response_model=PredictionDto)
async def put_predict_risk(prediction_input: RiskPredictionInputDto) -> PredictionDto:
    _in = prediction_input_mapper(prediction_input)
    prediction = predict_risk(_in)
    return prediction_dto_mapper(prediction)
