import argparse
from pathlib import Path

import numpy as np
import tensorflow as tf

from insurance_prediction.train.dataset.insurance import \
    load_dataset
from insurance_prediction.train.evaluation import evaluate


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Training Script'
    )
    parser.add_argument(
        '--dataset',
        type=str,
        metavar='DIRECTORY',
        required=True,
        help='Path to the dataset directory'
    )
    parser.add_argument(
        '--model',
        type=str,
        required=True,
        help='Path to the trained model'
    )


    args = parser.parse_args()

    dataset_path = Path(args.dataset)
    model_path = Path(args.model)


    dataset = load_dataset(
        train_csv_path = dataset_path / 'train.csv',
        test_csv_path = dataset_path / 'test.csv'
    )
    model = tf.keras.models.load_model(model_path)

    # Basic metrics
    print('Checking basic metrics')

    train_evaluation = evaluate(model, dataset.train)
    test_evaluation = evaluate(model, dataset.test)

    train_metric = train_evaluation.accuracy
    test_metric = test_evaluation.accuracy

    print(
        f'Model train / test accuracy: {train_metric} / {test_metric}')

    assert train_metric > .85
    print(f'Model train accuracy of {train_metric} exceeds 85%')
    assert test_metric > .85
    print(f'Model test accuracy of {test_metric} exceeds 85%')
    assert abs(train_metric - test_metric) < .05
    print(
        f'Accuracy spread of {abs(train_metric - test_metric)} is below 5% (checking or overfitting here)')

    # Output distributions
    print('Checking output distribution')
    # TODO: train + test?
    X = dataset.test.map(lambda x, y: x)
    y_pred = model.predict(X, verbose=0).argmax(axis=1)
    _, counts = np.unique(y_pred, return_counts=True)

    # Equal distribution around classes expected
    tolerance = 0.15
    expected_count = len(X) / 3
    for count in counts:
        assert count in range(
int(expected_count * (1 - tolerance)), int(expected_count * (1 + tolerance)))
    print(f'Counts {counts} are within {tolerance} of {expected_count}')

    # Certainty distribution
    print('Checking certainty distribution of outputs')
    y_pred_probas = model.predict(X, verbose=0).max(axis=1)
    print(
        f'Min: {y_pred_probas.min()}, mean: {y_pred_probas.mean()}, max: {y_pred_probas.max()}')
    assert y_pred_probas.min() > .4
    assert y_pred_probas.mean() > 0.7
    assert y_pred_probas.max() > 0.99
    print('Certainty distribution of outputs is within expected bounds')
