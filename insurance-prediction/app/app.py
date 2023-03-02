#!/usr/bin/env python

import sys
sys.path.append('../lib')
# print(sys.path)
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

from model_prediction import predict
import logging
from flask import Flask, request, jsonify
from flask_cors import CORS


app = Flask(__name__)
CORS(app)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    filename='req.log')

data_logger = logging.getLogger('DataLogger')
data_logger.setLevel(logging.INFO)
file_handler = logging.FileHandler('data.log')
data_logger.addHandler(file_handler)


@app.route("/ping")
def ping():
    return "pong"


@app.route('/predict', methods=['GET', 'POST'])
def do_predict():
    training = request.json['training']
    age = request.json['age']
    emergency_braking = request.json['emergency_braking']
    braking_distance = request.json['braking_distance']
    power = request.json['power']
    miles = request.json['miles']

    try:
        predicted_category, probabilities, source = predict(
            training, age, emergency_braking, braking_distance, power, miles)

        response = {
            'category': predicted_category,
            'probabilities': probabilities,
            'source': source
        }

        dataset = {
            'in': {
                'training': training,
                'age': age,
                'emergency_braking': emergency_braking,
                'braking_distance': braking_distance,
                'power': power,
                'miles': miles
            },
            'out': response
        }

        data_logger.info(dataset)
        return jsonify(response)
    except (ValueError):
        return jsonify({'error': 'invalid input'}), 422


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
