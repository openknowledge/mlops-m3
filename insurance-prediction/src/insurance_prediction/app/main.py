import uvicorn

from fastapi import FastAPI
from insurance_prediction.app.application import router as prediction_router

app = FastAPI()

app.include_router(prediction_router)

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
