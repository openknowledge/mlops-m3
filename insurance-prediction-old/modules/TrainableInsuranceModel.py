# https://github.com/AndreasMadsen/python-lrcurve
from lrcurve import KerasLearningCurve
from InsuranceModel import InsuranceModel

class TrainableInsuranceModel(InsuranceModel):
    def __init__(self, model=None, data=None, batch_size=32, **kwargs):
        InsuranceModel.__init__(self, model, **kwargs)
        self.model = model
        self.data = data
        self.batch_size = batch_size
        self.history = None

    def train(self, epochs=50, plot_curve=False):
        if not self.keras_format:
            # https://docs.python.org/3/library/exceptions.html#exception-hierarchy
            raise RuntimeError('Keras format is required for training')
        self.model.compile(loss='sparse_categorical_crossentropy',
                           optimizer='adam',
                           metrics=['accuracy'])

        if plot_curve:
            callbacks = [KerasLearningCurve()]
        else:
            callbacks = []

        X_train, X_val, y_train, y_val = self.data.get_split()
        history = self.model.fit(X_train, y_train,
                                 validation_data=(X_val, y_val),
                                 epochs=epochs,
                                 batch_size=self.batch_size,
                                 callbacks=callbacks,
                                 verbose=0)
        if not self.history:
            self.history = history
        else:
            self.history.history['val_loss'] += history.history['val_loss']
            self.history.history['val_acc'] += history.history['val_acc']
            self.history.history['loss'] += history.history['loss']
            self.history.history['acc'] += history.history['acc']
        return self.history

    def evaluate(self):
        X_train, X_val, y_train, y_val = self.data.get_split()
        train_loss, train_metric = self.model.evaluate(
            X_train, y_train, batch_size=self.batch_size, verbose=0)
        test_loss, test_metric = self.model.evaluate(
            X_val, y_val, batch_size=self.batch_size, verbose=0)
        return ((train_loss, train_metric), (test_loss, test_metric))

    def save(self, model_path='classifier', keras_format=None):
        if keras_format is None:
            keras_format = self.keras_format

        if keras_format:
            self.model.save(f'{model_path}.h5', save_format='h5')
        else:
            self.model.save(model_path, save_format='tf')

        