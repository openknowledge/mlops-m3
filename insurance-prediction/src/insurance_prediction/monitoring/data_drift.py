import os
from evidently.metrics import DatasetDriftMetric
from evidently.base_metric import InputData, ColumnMapping
from evidently.runner.loader import DataLoader, DataOptions
from collections import deque
from typing import Any, Callable, Dict, MutableMapping, MutableSequence, Sequence

import pandas as pd
from prometheus_client import Gauge
from insurance_prediction.model.domain.insurance import Prediction, RiskPredictionInput

from insurance_prediction.monitoring import collector_registry

reference_path: str = os.getenv('REFERENCE_PATH')
window_size: int = int(os.getenv('METRICS_WINDOW_SIZE', '1500'))


reference_dataset = DataLoader().load(
   filename=reference_path,
   data_options = DataOptions(date_column=None, separator=';'),
)
reference_dataset = reference_dataset.drop(['risk', 'group', 'group_name'], axis='columns')

column_mapping = ColumnMapping(
    categorical_features=['training', 'emergency_braking'],
    numerical_features=['age', 'braking_distance', 'power', 'miles'],
    prediction=None,
    target=None,
)

dataset_drift_metric = DatasetDriftMetric(columns=column_mapping.categorical_features + column_mapping.numerical_features)

window: MutableSequence[RiskPredictionInput] = deque(maxlen=window_size)
gauges: MutableMapping[str, Gauge] = dict()

def _to_dataframe(current_data: Sequence[RiskPredictionInput]) -> pd.DataFrame:
    def _to_dict(risk_input: RiskPredictionInput) -> Dict[str, Any]:
        return {
            'training': int(risk_input.driver.training),
            'emergency_braking': int(risk_input.vehicle.emergency_braking),
            'age': risk_input.driver.age,
            'braking_distance': risk_input.vehicle.braking_distance,
            'power': risk_input.vehicle.power,
            'miles': risk_input.driver.miles
        }

    current_data = map(_to_dict, current_data)
    return pd.DataFrame.from_records(current_data)

def risk_prediction(fun: Callable[[RiskPredictionInput], Prediction]) -> Callable[[RiskPredictionInput], Prediction]:
    def _wrapper(prediction_input: RiskPredictionInput) -> Prediction:
        prediction = fun(prediction_input)
        window.append(prediction_input)
        if len(window) == window_size:
            input_data = InputData(
                reference_data=reference_dataset.copy(),
                current_data=_to_dataframe(window),
                column_mapping=column_mapping,
                current_additional_features=None,
                data_definition=None,
                reference_additional_features=None
            )
            window.clear()
            result = dataset_drift_metric.calculate(input_data)
            for label, metric_value in result.dict().items():
                if label not in gauges:
                    gauges[label] = Gauge(label, '', registry=collector_registry)
                gauges[label].set(metric_value)
        return prediction
    return _wrapper
