import argparse
from pathlib import Path
import numpy as np

import tensorflow as tf

from insurance_prediction.train.dataset.insurance import load_dataset
from insurance_prediction.train.evaluation import evaluate
from insurance_prediction.train.model.insurance import (create_insurance_model,
                                                        create_normalization, train)

tf.random.set_seed(42)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Training Script"
    )
    parser.add_argument(
        "--dataset",
        type=str,
        required=True,
        help="Path to the dataset folder"
    )
    parser.add_argument(
        "--model",
        type=str,
        required=True,
        help="Path for saving training model"
    )
    parser.add_argument(
        "--headless",
        default=False,
        action='store_true',
        help="Whether or not the training is run in headless mode"
    )
    parser.add_argument(
        "--no-gpu",
        default=False,
        action='store_true',
        help="Disables the usage of gpus"
    )

    args = parser.parse_args()

    dataset_path = Path(args.dataset)
    model_path = Path(args.model)
    no_gpu = bool(args.no_gpu)

    if no_gpu:
        tf.config.set_visible_devices([], 'GPU')

    dataset = load_dataset(
        train_csv_path = dataset_path / 'train.csv',
        test_csv_path = dataset_path / 'test.csv'
    )

    X = dataset.train.map(lambda x, y: x)

    normalization = create_normalization(
        X
    )

    model = create_insurance_model(
        num_features=dataset.num_features,
        num_categories=3,
        normalization=normalization,
        # TODO: uncomment to make model capacity smaller and quality gate fail
        # neurons_per_layer = 50
    )

    train(
        dataset=dataset,
        model=model,
    )

    train_evaluation = evaluate(model, dataset.train)
    test_evaluation = evaluate(model, dataset.test)

    print(f"Model trained to train / test accuracy: {train_evaluation.accuracy} / {test_evaluation.accuracy}")

    print("Save model to ", model_path)
    model.save(model_path)
