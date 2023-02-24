import tensorflow as tf 

from tensorflow.keras.layers import InputLayer, Dense, Dropout, \
                                    BatchNormalization, Activation

def create_normalizer(X):
    normalizer = tf.keras.layers.Normalization(axis=-1)
    normalizer.adapt(X)
    return normalizer

def create_model(num_features, num_categories, normalizer=None, dropout = 0.7):

    model = tf.keras.Sequential()

    model.add(InputLayer(name='input', input_shape=(num_features,)))
    if normalizer:
        model.add(normalizer)

    model.add(Dense(100, name='hidden1'))
    model.add(Activation('relu'))
    model.add(BatchNormalization())
    model.add(Dropout(dropout))

    model.add(Dense(100, name='hidden2'))
    model.add(Activation('relu'))
    model.add(BatchNormalization())
    model.add(Dropout(dropout))

    model.add(Dense(100, name='hidden3'))
    model.add(Activation('relu'))
    model.add(BatchNormalization())
    model.add(Dropout(dropout))

    model.add(Dense(name='output', units=num_categories, activation='softmax'))

    return model

