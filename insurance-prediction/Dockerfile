FROM python:3.10.11-bullseye AS base
RUN apt update && apt install -y python3-dev gcc libffi-dev
RUN pip install poetry
COPY ./ /
RUN poetry install
RUN poetry build


FROM base AS build
RUN poetry build


FROM base AS training
COPY ./datasets/insurance_prediction/reference.csv.gz /
RUN poetry run train --dataset ./datasets/insurance_prediction/ --model /model.h5
RUN poetry run validate --dataset ./datasets/insurance_prediction/ --model /model.h5


FROM python:3.10.11-bullseye

EXPOSE 80
ENV MODEL_PATH=/model.h5
ENV REFERENCE_PATH=/reference.csv.gz

COPY --from=build /dist/insurance_prediction_app-*.whl /
COPY --from=training /model.h5 /
COPY ./datasets/insurance_prediction/reference.csv.gz /

RUN pip install insurance_prediction_app-*.whl

ENTRYPOINT [ "uvicorn", "insurance_prediction.app.main:app", "--host", "0.0.0.0", "--port", "80"]
