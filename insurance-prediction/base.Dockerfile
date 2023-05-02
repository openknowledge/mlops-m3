# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM python:3.10.11-bullseye AS base
RUN apt update && apt install -y python3-dev gcc libffi-dev
RUN pip install poetry
COPY ./ /
RUN <<EOF
    pip install \
    "tensorflow==2.12.0; platform_machine == 'x86_64' or platform_machine == 'amd64'" \
    "tensorflow-aarch64==2.12.0; platform_machine == 'aarch64'" \
    "tensorflow-macos==2.12.0; platform_machine == 'arm64'" 
EOF

