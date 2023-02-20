#!/usr/bin/env python3

import sys
import pandas as pd
import numpy as np
import argparse
import logging
import os
from tabnanny import verbose
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

sys.path.append('../lib')
# print(sys.path)

from data import InsuranceData
from TrainableInsuranceModel import TrainableInsuranceModel

def setup_logger() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[
            logging.StreamHandler()
        ]
    )


def main(data_path: str, model_path: str) -> None:
    logging.info(f"Validating model {model_path} on dataset {data_path}")
    data_path = os.path.abspath(data_path)
    model_path = os.path.abspath(model_path)

    data = InsuranceData(data_path)
    insurance_model = TrainableInsuranceModel(data=data)
    insurance_model.load(model_path, keras_format=True)

    # basics metrics
    logging.info(f"Checking basic metrics")
    ((_, train_metric), (_, test_metric)) = insurance_model.evaluate()
    logging.info(
        f"Model train / test accuracy: {train_metric} / {test_metric}")

    assert train_metric > .85
    logging.info(f"Model train accuracy of {train_metric} exceeds 85%")
    assert test_metric > .85
    logging.info(f"Model test accuracy of {test_metric} exceeds 85%")
    assert abs(train_metric - test_metric) < .05
    logging.info(
        f"Accuracy spread of {abs(train_metric - test_metric)} is below 5% (checking for overfitting here)")

    # output distributions
    model = insurance_model.model
    logging.info(f"Checking output distribution")
    X = data.get_X()
    y_pred = model.predict(X, verbose=0).argmax(axis=1)
    _, counts = np.unique(y_pred, return_counts=True)
    # equal distribution around classes expected
    tolerance = 0.15
    expected_count = len(X) / 3
    for count in counts:
        assert count in range(
            int(expected_count * (1 - tolerance)), int(expected_count * (1 + tolerance)))
    logging.info(f"Counts {counts} are within {tolerance} of {expected_count}")

    # certainty distribution
    logging.info(f"Checking certainty distribution of outputs")
    y_pred_probas = model.predict(X, verbose=0).max(axis=1)
    logging.info(
        f"Min: {y_pred_probas.min()}, mean: {y_pred_probas.mean()}, max: {y_pred_probas.max()}")
    assert y_pred_probas.min() > .4
    assert y_pred_probas.mean() > 0.7
    assert y_pred_probas.max() > 0.99
    logging.info(
        f"Certainty distribution of outputs is within expected bounds (0.4, 0.7, 0.99)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Validation of invariant properties of model"
    )
    parser.add_argument(
        "-d",
        "--data-path",
        type=str,
        help="Path for training data.",
        required=True
    )
    parser.add_argument(
        "-m",
        "--model-path",
        type=str,
        help="Path for trained model.",
        required=True
    )

    args = parser.parse_args()
    setup_logger()
    main(args.data_path, args.model_path)
