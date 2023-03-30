#!/usr/bin/env python3

import sys
import argparse
import logging
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

sys.path.append('../lib')
# print(sys.path)

from data import InsuranceData
from model import create_model, create_normalizer
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
    logging.info("Generate model for dataset %s", data_path)
    data_path = os.path.abspath(data_path)
    model_path = os.path.abspath(model_path)

    data = InsuranceData(data_path)
    X_train, _, _, _ = data.get_split()
    normalizer = create_normalizer(X_train)
    model = create_model(
        num_features=X_train.shape[1], num_categories=3, normalizer=normalizer)

    logging.info("Train model")

    trainableModel = TrainableInsuranceModel(model, data)
    trainableModel.train()
    ((_, train_metric), (_, test_metric)) = trainableModel.evaluate()
    logging.info(
        f"Model trained to train / test accuracy: {train_metric} / {test_metric}")

    logging.info("Save model to %s", model_path)
    trainableModel.save(model_path)

def getArgumentOrEnvAsFallback(argument: any,env_param: str) -> str:
    if argument:
        return argument
    else:
        logging.info(f"Backup to env variable for {env_param}")
        result = os.getenv(env_param)
        
        if not result:
            exit(f"Please set argument data-path or environment variable {env_param}!")
            
        return result

if __name__ == "__main__":
    setup_logger()

    parser = argparse.ArgumentParser(
        description="Training Script"
    )
    parser.add_argument(
        "-d",
        "--data-path",
        type=str,
        help="Path for training data."
    )
    parser.add_argument(
        "-m",
        "--model-path",
        type=str,
        help="Path for saving training model."
    )

    args = parser.parse_args()
    data_path = getArgumentOrEnvAsFallback(args.data_path, "DATASET_PATH")
    model_path = getArgumentOrEnvAsFallback(args.model_path, "CREATE_MODEL_AT_PATH")

    main(data_path, model_path)