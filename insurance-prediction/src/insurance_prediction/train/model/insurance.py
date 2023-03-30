from typing import Any
import tensorflow as tf

def create_normalization(X: tf.data.Dataset) -> tf.keras.layers.Normalization:
    normalizer = tf.keras.layers.Normalization(axis=-1)
    normalizer.adapt(X)
    return normalizer

def create_insurance_model(
    num_features: int,
    num_categories: int,
    normalization: tf.keras.layers.Normalization = None,
    dropout: float = 0.7
    ) -> tf.keras.Model:

    model = tf.keras.Sequential()

    model.add(tf.keras.layers.InputLayer(name='input', input_shape=(num_features,)))

    if normalization:
        model.add(normalization)

    model.add(tf.keras.layers.Dense(100, name='hidden1'))
    model.add(tf.keras.layers.Activation('relu'))
    model.add(tf.keras.layers.BatchNormalization())
    model.add(tf.keras.layers.Dropout(dropout))

    model.add(tf.keras.layers.Dense(100, name='hidden2'))
    model.add(tf.keras.layers.Activation('relu'))
    model.add(tf.keras.layers.BatchNormalization())
    model.add(tf.keras.layers.Dropout(dropout))

    model.add(tf.keras.layers.Dense(100, name='hidden3'))
    model.add(tf.keras.layers.Activation('relu'))
    model.add(tf.keras.layers.BatchNormalization())
    model.add(tf.keras.layers.Dropout(dropout))

    model.add(tf.keras.layers.Dense(name='output', units=num_categories, activation='softmax'))

    return model
