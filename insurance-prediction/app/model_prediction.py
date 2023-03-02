import os
import logging

from InsuranceModel import InsuranceModel
from BaseLineClassifier import BaseLineClassifier
import tensorflow as tf

# FIXME: this should be configurable
MIN_PROBA_THRESHOLD = 0.5
# os.path.abspath("mydir/myfile.txt")
# model_path = "/home/olli/mlops-data2day/app/classifier"
# model_path = "/python_server/classifier"
model_path = os.getenv('MODEL_PATH', "classifier")

insurance_model = InsuranceModel()
insurance_model.load(model_path, keras_format=True)

baseline_model = BaseLineClassifier()

data_logger = logging.getLogger('DataLogger')

def predict(training, age, emergency_braking, braking_distance, power, miles):
    probas = None
    if insurance_model.check_range(training, age, emergency_braking, braking_distance, power, miles):
        probas = insurance_model.predict(training, age, emergency_braking, braking_distance, power, miles)
        if probas.max() < MIN_PROBA_THRESHOLD:
            probas = None
            data_logger.warning(f'ML model probability {probas.max()} too low - falling back to baseline model')
            source = 'baseline - low probability'
        else:
            result = probas.argmax()
            probas = probas.tolist()
            source = 'ML'
    else:
        data_logger.warning('Input out of range for ML model - falling back to baseline model')
        source = 'baseline - out of range'
    if probas is None:
        result = baseline_model.predict_from_values(training, age, emergency_braking, braking_distance, power, miles)
        probas = tf.keras.utils.to_categorical(result, num_classes=3).tolist()
    return int(result), probas, source