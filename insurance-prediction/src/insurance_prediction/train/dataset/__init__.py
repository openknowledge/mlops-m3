from collections import namedtuple
from pydantic import BaseModel, root_validator
import tensorflow as tf

Dataset = namedtuple('Dataset', [('num_features', int), ('tf', tf.data.Dataset)])

class Split(BaseModel):
    # pylint: disable=E0213
    train: int
    test: int

    @root_validator
    def check_split(cls, values):
        train, test = values.get('train'), values.get('test')
        if train + test != 100:
            raise ValueError("Split does not add up to 100%")
        return values

SplittedDataset = namedtuple('SplittedDataset', [('train', tf.data.Dataset), ('test', tf.data.Dataset)])

def split(dataset: tf.data.Dataset, split: Split = Split(80, 20)) -> SplittedDataset:
    # TODO: write unit test (0-X, every number unique)
    shift = split.train + split.test
    return SplittedDataset(
        train=dataset.window(split.train, shift).flat_map(lambda ds: ds),
        test=dataset.skip(split.train).window(split.test, shift).flat_map(lambda ds: ds)
    )