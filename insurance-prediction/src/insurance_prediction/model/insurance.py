import logging
import os
import tensorflow as tf

from insurance_prediction.model import BasePredictor, InfeasiblePredictionError
from insurance_prediction.model.domain.insurance import Prediction, PredictorType, Risk, RiskPredictionInput

class _InsuranceModel(BasePredictor):
    logger = logging.getLogger('insurance_model')

    def __init__(self, model_path: str,
                 min_probability_threshold = .5,
                 age_range = range(10, 150),
                 power_range = range(50, 250)) -> None:
        super().__init__()
        self.age_range = age_range
        self.power_range = power_range
        self.min_probability_threshold = min_probability_threshold

        self.model = tf.saved_model.load(model_path)

    def can_predict(self, prediction_input: RiskPredictionInput) -> bool:
        in_range = prediction_input.age in self.age_range and prediction_input.power in self.power_range
        if not in_range:
            _InsuranceModel.logger.warning('Input out of range for ML model - falling back to baseline model')
        return in_range

    def predict(self, prediction_input: RiskPredictionInput) -> Prediction:
        if not self.can_predict(prediction_input):
            raise InfeasiblePredictionError(f'Prediction input {prediction_input} is \
                out of range age_range={self.age_range}, power_range={self.power_range}.')

        model_input = [
            [prediction_input.driver.training,
             prediction_input.driver.age,
             prediction_input.vehicle.emergency_breaking,
             prediction_input.vehicle.braking_distance,
             prediction_input.vehicle.power,
             prediction_input.driver.miles]
        ]
        result = self.model.predict(model_input, verbose=0)[0]

        if result.max() < self.min_probability_threshold:
            _InsuranceModel.logger.warning('ML model probability %.2f too low - \falling back to baseline model', result.max())
            raise InfeasiblePredictionError(f'Result of model is not confident enough, as it is below {self.min_probability_threshold}')

        return Prediction(
            prediction=Risk[result.argmax()],
            probabilities=result,
            predictor_type=PredictorType.MODEL
        )

model = _InsuranceModel(
    model_path = os.getenv('MODEL_PATH', "classifier")
)
