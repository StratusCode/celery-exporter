ARG PYTHON_VERSION=
ARG DEBIAN_VERSION=
ARG DATE=
ARG REPO_URL=us.gcr.io/stunning-base-208718/base-images

# this multi-stage build compiles the python dependencies
FROM ${REPO_URL}/python-dev:${PYTHON_VERSION}-${DEBIAN_VERSION}-${DATE} as builder

RUN mkdir __pypackages__

COPY pyproject.toml pdm.lock /app/

RUN --mount=type=ssh pdm sync --prod --no-editable --clean -vv --no-isolation

RUN python -m compileall /app/__pypackages__/

COPY . /app
RUN --mount=type=ssh pdm sync --prod --clean -vv --no-isolation

RUN python -m compileall /app/__pypackages__/

FROM ${REPO_URL}/python:${PYTHON_VERSION}-${DEBIAN_VERSION}-${DATE}

ARG PYTHON_VERSION

# install all the python dependencies from the builder container
COPY --from=builder --chown=1000 /app /app

# set up the python path so that the app can be imported
RUN echo "/app/__pypackages__/${PYTHON_VERSION}/lib\n/app/src" > /usr/local/lib/python${PYTHON_VERSION}/site-packages/app.pth
ENV PATH=/app/__pypackages__/${PYTHON_VERSION}/bin:$PATH


EXPOSE 9808

ENTRYPOINT [ "celery-exporter" ]
