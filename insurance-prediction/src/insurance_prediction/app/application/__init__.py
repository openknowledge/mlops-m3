from fastapi import APIRouter

from insurance_prediction.app.application.dto import PredictionDto, RiskPredictionInputDto
from insurance_prediction.app.usecase.insurance import predict_risk
import insurance_prediction.monitoring.data_drift as data_drift

router = APIRouter(
    prefix='/predict'
)

@router.put(path='/', response_model=PredictionDto)
async def put_predict_risk(prediction_input: RiskPredictionInputDto) -> PredictionDto:
    prediction = predict_risk(prediction_input.to_domain())
    return PredictionDto.from_domain(prediction)
