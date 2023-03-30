from dataclasses import dataclass
from pathlib import Path
from insurance_prediction.train.dataset import Dataset
import tensorflow as tf
import pandas as pd

def load_dataset(path: Path) -> Dataset:
    df = pd.read_csv(path, sep=';')

    features = df.drop(['risk', 'group_name'], axis='columns').values
    label = features.pop('group')

    feature_dataset = tf.data.Dataset.from_tensor_slices(features)
    label_dataset = tf.data.Dataset.from_tensor_slices(label)
    
    return Dataset(features.shape[1], feature_dataset.zip(label_dataset))
