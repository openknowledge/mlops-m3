import argparse
from pathlib import Path

from insurance_prediction.train.dataset import Split
from insurance_prediction.train.dataset.insurance import load_dataset, load_dataset_from_archive
from insurance_prediction.train.evaluation import evaluate
from insurance_prediction.train.model.insurance import (create_insurance_model,
                                                        create_normalization, train)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Training Script"
    )
    parser.add_argument(
        "--dataset",
        type=str,
        metavar='ARCHIVE',
        required=True,
        help="Path to the dataset archive"
    )
    parser.add_argument(
        "--csv_file",
        type=str,
        metavar='CSV',
        required=True,
        help="Name of the csv file file to use from the archive"
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

    args = parser.parse_args()

    dataset_archive_path = Path(args.dataset)
    csv_file_name = args.csv_file
    model_path = Path(args.model)
    headless = bool(args.headless)

    full_dataset = load_dataset_from_archive(archive_path=dataset_archive_path, csv_file=csv_file_name)
    dataset = full_dataset.tf.shuffle(buffer_size=10_000, seed=42)
    dataset = Split().dataset(dataset)

    X = dataset.train.map(lambda x, y: x)

    normalization = create_normalization(
        X
    )

    model = create_insurance_model(
        num_features=full_dataset.num_features,
        num_categories=3,
        normalization=normalization,
        # TODO: uncomment to make model capacity smaller and quality gate fail
        # neurons_per_layer = 50
    )

    train(
        dataset=dataset,
        model=model,
        plot_curve=not headless
    )

    train_evaluation = evaluate(model, dataset.train)
    test_evaluation = evaluate(model, dataset.test)

    print(f"Model trained to train / test accuracy: {train_evaluation.accuracy} / {test_evaluation.accuracy}")

    # TODO: test trained model

    print("Save model to ", model_path)
    model.save(model_path)
