# Local installation for development


## Prerequisites
 * [poetry](https://python-poetry.org/)


## First setup

```
poetry install
```

## Local development

* Use the python environment created by *poetry*: `source ./venv/bin/activate`.

## Training and validation

```
poetry run train --dataset ../datasets/insurance_prediction/ --model ./model.h5
```

```
poetry run validate --dataset ../datasets/insurance_prediction/ --model ./model.h5
```
