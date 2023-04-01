from collections import namedtuple
from dataclasses import dataclass
import tensorflow as tf

@dataclass
class Dataset:
    num_features: int
    tf: tf.data.Dataset

@dataclass
class Split:
    train: int = 80
    test: int = 20

    def __post_init__(self):
        if self.train + self.test != 100:
            raise ValueError("Split does not add up to 100%")

    def dataset(self, dataset: tf.data.Dataset):
        length = dataset.reduce(0, lambda x,_: x+1).numpy()

        take = length*self.train/100.
        return SplittedDataset(
            train=dataset.take(take),
            test=dataset.skip(take)
        )

@dataclass
class SplittedDataset:
    train: tf.data.Dataset
    test: tf.data.Dataset
