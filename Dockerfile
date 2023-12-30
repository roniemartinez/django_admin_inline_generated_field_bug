# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

ARG PYTHON_VERSION=3.12.1
FROM python:${PYTHON_VERSION}-slim as base

RUN apt update && apt install -y build-essential gettext python3-dev postgresql-client

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/app" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# Leverage a bind mount to requirements.txt to avoid having to copy them into
# into this layer.
#RUN --mount=type=cache,target=/root/.cache/pip \
#    --mount=type=bind,source=requirements.txt,target=requirements.txt \
#    python -m pip install -r requirements.txt \
COPY requirements.txt /tmp/requirements.txt
RUN python -m pip install -r /tmp/requirements.txt

# Copy the source code into the container.
COPY . .

## Give ownership of the working directory to the new user
RUN chown -R appuser: /app

## Switch to the non-privileged user to run the application.
USER appuser

ENV DJANGO_PORT=8080

# Expose the port that the application listens on.
EXPOSE ${DJANGO_PORT}

# Run the application.
CMD python manage.py collectstatic --noinput -v 3 && \
    python manage.py migrate -v 3 && \
    python manage.py runserver ${DJANGO_HOST}:${DJANGO_PORT}
