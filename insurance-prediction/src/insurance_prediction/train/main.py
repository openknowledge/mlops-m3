import argparse
from collections import namedtuple
from pathlib import Path

import lrcurve
import tensorflow as tf
from insurance_prediction.train.dataset import SplittedDataset, split
from insurance_prediction.train.dataset.insurance import load_dataset
from insurance_prediction.train.model.insurance import (create_insurance_model,
                                                        create_normalization)

# TODO: logging

def train(dataset: SplittedDataset, model: tf.keras.Model, epochs: int = 50, batch_size: int = 32, plot_curve: bool = False) -> None:
    model.compile(loss='sparse_categorical_crossentropy',
                           optimizer='adam',
                           metrics=['accuracy'])

    if plot_curve:
        callbacks = [lrcurve.KerasLearningCurve()]
    else:
        callbacks = []

    model.fit(dataset.train,
              validation_data=dataset.val,
              epochs=epochs,
              batch_size=batch_size,
              callbacks=callbacks,
              verbose=0
              )

Evaluation = namedtuple('Evaluation', (('loss', float), ('metric', float)))
def evaluate(model: tf.keras.Model, dataset: tf.data.Dataset, batch_size: int = 32) -> Evaluation:
    loss, metric = model.evaluate(dataset, batch_size=batch_size, verbose=0)
    return Evaluation(loss, metric)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Training Script"
    )
    parser.add_argument(
        "--data-path",
        type=str,
        help="Path for training data."
    )
    parser.add_argument(
        "--model-path",
        type=str,
        help="Path for saving training model."
    )
    parser.add_argument(
        "--headless",
        type=bool,
        help="Whether or not the training is run in headless mode."
    )

    args = parser.parse_args()

    data_path = Path(args.data_path)
    model_path = Path(args.model_path)
    headless = bool(args.headless)
    
    # TODO: validate arguments
    
    # TODO: load dataset (with tf?)
    full_dataset = load_dataset(data_path)
    dataset = full_dataset.tf.shuffle(seed=42)
    dataset = split(dataset)

    X = dataset.train.map(lambda ds: ds[0]) # TODO: ?

    normalization = create_normalization(
        X
    )
    model = create_insurance_model(
        num_features=full_dataset.num_features,
        num_categories=3,
        normalization=normalization
    )

    train(
        dataset=dataset,
        model=model,
        plot_curve=not headless
    )

    # TODO: evaluate model
    train_evaluation = evaluate(model, dataset.train)
    test_evaluation = evaluate(model, dataset.test)
    
    print(f"Model trained to train / test accuracy: {train_evaluation.metric} / {test_evaluation.metric}")

    # TODO: test trained model

    # TODO: save model

    print("Save model to %s", model_path)
    model.save(model_path)
