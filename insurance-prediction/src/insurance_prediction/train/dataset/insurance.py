from io import StringIO
import tarfile
from pathlib import Path

import pandas as pd
import tensorflow as tf

from insurance_prediction.train.dataset import Dataset


def load_dataset_from_archive(archive_path: Path, csv_file: str, encoding:str = 'utf-8'):
    with tarfile.open(archive_path, "r:*") as tar:
        csv_path = next(filter(lambda name: name.endswith(f'/{csv_file}'), tar.getnames()))
        with tar.extractfile(csv_path) as f:
            csv = StringIO(f.read().decode(encoding))
            df = pd.read_csv(csv, sep=';')
    return _load_dataset_from_df(df)

def load_dataset(csv_path: Path) -> Dataset:
    df = pd.read_csv(csv_path, sep=';')
    return _load_dataset_from_df(df)

def _load_dataset_from_df(df: pd.DataFrame) -> Dataset:
    features = df.drop(['risk', 'group', 'group_name'], axis='columns').values
    label = df.pop('group')

    feature_dataset = tf.data.Dataset.from_tensor_slices(features)
    label_dataset = tf.data.Dataset.from_tensor_slices(label)

    return Dataset(features.shape[1], tf.data.Dataset.zip((feature_dataset, label_dataset)))
