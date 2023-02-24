import tensorflow as tf

class InsuranceModel:
    """Class for model execution.
    
    Args:
        model: can be passed or loaded later
    """
    def __init__(self, model=None, age_range=range(10, 150), power_range=range(50, 250), keras_format=True):
        self.model = model
        self.keras_format = keras_format
        self.age_range = age_range
        self.power_range = power_range

    # https://keras.io/guides/serialization_and_saving/
    def load(self, model_path='classifier', keras_format=None):
        if keras_format is None:
            keras_format = self.keras_format

        if keras_format:
            self.model = tf.keras.models.load_model(f'{model_path}.h5')
        else:
            self.model = tf.saved_model.load(model_path)
        return self.model

    def check_range(self, training, age, emergency_braking, braking_distance, power, miles):
        valid = age in self.age_range and power in self.power_range
        return valid

    def predict(self, training, age, emergency_braking, braking_distance, power, miles):
        """Predicts probabilities and category

        Returns:
            List[float]: list of probabilities per category
            int: predicted category
        """

        X = [[training, age, emergency_braking, braking_distance, power, miles]]
        probas = self.model.predict(X, verbose=0)[0]
        return probas