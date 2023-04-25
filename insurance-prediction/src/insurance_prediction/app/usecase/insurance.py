from insurance_prediction.model import InfeasiblePredictionError
from insurance_prediction.model.domain.insurance import Prediction, RiskPredictionInput
from insurance_prediction.model.insurance import model as insurance_model
from insurance_prediction.model.rule_based import model as rule_based_model
import insurance_prediction.monitoring.data_drift as data_drift

@data_drift.risk_prediction
def predict_risk(prediction_input: RiskPredictionInput) -> Prediction:
    try:
        if insurance_model.can_predict(prediction_input):
            return insurance_model.predict(prediction_input)
        else:
            return rule_based_model.predict(prediction_input)
    except InfeasiblePredictionError:
        return rule_based_model.predict(prediction_input)
