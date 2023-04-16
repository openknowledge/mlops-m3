FROM python:3.10.11-bullseye AS build
RUN apt update && apt install -y python3-dev gcc libffi-dev
RUN pip install poetry
COPY ./ /
RUN poetry install
RUN poetry build

FROM python:3.10.11-bullseye

EXPOSE 80
ENV MODEL_PATH=/model.h5

COPY --from=build /dist/insurance_prediction_app-*.whl /

RUN pip install insurance_prediction_app-*.whl

ENTRYPOINT [ "uvicorn", "insurance_prediction.app.main:app", "--host", "0.0.0.0", "--port", "80"]
