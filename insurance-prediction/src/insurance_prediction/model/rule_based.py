
from insurance_prediction.model import BasePredictor
from insurance_prediction.model.domain.insurance import Prediction, PredictorType, Risk, RiskPredictionInput


class _RulesBasedPredictor(BasePredictor):
    def can_predict(self, prediction_input: RiskPredictionInput) -> bool:
        return True

    def __predict_risk(self, prediction_input: RiskPredictionInput) -> Risk:
        driver = prediction_input.driver
        vehicle = prediction_input.vehicle

        if driver.training: 
            return Risk.LOW
        if driver.age < 30:
            if vehicle.power > 130:
                return Risk.HIGH
            else:
                return Risk.MEDIUM
        if driver.age > 50:
            return Risk.HIGH
        if vehicle.emergency_breaking:
            return Risk.LOW
        if driver.miles > 50:
            return Risk.HIGH
        if driver.miles > 30:
            return Risk.MEDIUM
        # default
        return Risk.LOW

    def predict(self, prediction_input: RiskPredictionInput) -> Prediction:
        return Prediction(
            prediction=self.__predict_risk(prediction_input),
            probabilities = None,
            predictor_type=PredictorType.RULES
        )

model = _RulesBasedPredictor()
