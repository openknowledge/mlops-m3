# syntax=docker/dockerfile:1

ARG BASE_IMAGE=python:3.10.11-bullseye

FROM --platform=$BUILDPLATFORM $BASE_IMAGE AS base

RUN pip install poetry
RUN <<EOF
    pip install \
    "tensorflow-cpu==2.12.0; platform_machine == 'x86_64' or platform_machine == 'amd64'" \
    "tensorflow-aarch64==2.12.0; platform_machine == 'aarch64'" \
    "tensorflow-macos==2.12.0; platform_machine == 'arm64'"
EOF
RUN poetry config virtualenvs.create false
RUN pip cache purge
