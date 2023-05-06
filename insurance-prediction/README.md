# Local installation for development


## Prerequisites
 * [poetry](https://python-poetry.org/)


## Docker
* Start docker
* cd into the insurance_prediction folder
* `docker build -t insurance_prediction -f Dockerfile .`

## Running the interactive docker image
* Start docker
* cd into the insurance_prediction folder
* `docker build -t insurance_prediction_interactive -f interactive.Dockerfile . `
* `docker run -v "$(pwd)/output:/output" --rm -it insurance_prediction_interactive`

## First setup

```
poetry install
```

## Local development

* Use the python environment created by *poetry*: `source ./venv/bin/activate`.

## Training and validation

```
poetry run train --dataset ./datasets/insurance_prediction/ --model ./model.h5
```

```
poetry run validate --dataset ./datasets/insurance_prediction/ --model ./model.h5
```

## Simluate requests in production for k8s cluster

```
poetry run simulate-drift --dataset ./datasets/insurance_prediction/ --base_url http://localhost:30080/
```
