ARG PYTHON_VERSION=3.12.1
ARG PDM_VERSION=2.11.2
ARG COPIER_VERSION=9.1.0

FROM python:${PYTHON_VERSION}-slim as base
RUN apt-get update && apt-get install --no-install-recommends -y git && \
    addgroup --system abc && \
    adduser \
    --shell /bin/sh \
    --ingroup abc \
    --disabled-password \
    abc
USER abc
ENV PATH="/home/abc/.local/bin:${PATH}"
WORKDIR /app



FROM base as template-hydrate
ARG COPIER_VERSION
RUN pip install --user --no-cache-dir copier==${COPIER_VERSION}
COPY --chown=abc:abc ./copier.yml /app/
COPY --chown=abc:abc ./python /app/python
RUN copier copy --defaults . /app/hydrated



FROM base as template-install
ARG PDM_VERSION
RUN pip install --user --no-cache-dir pdm==${PDM_VERSION}
COPY --from=template-hydrate --chown=abc:abc /app/hydrated /app/
RUN pdm install

FROM template-install as template-test
RUN pdm test && pdm coverage

FROM template-install as template-lint
RUN pdm lint && pdm format

FROM template-install as template-build
RUN pdm build

FROM template-install as template-pex-build
RUN pdm pex-build

FROM template-install as template-clean
RUN pdm clean

FROM base as final
# We do not care about the actual results of each stage, we just need to
# artifically create a dependency with them to make Docker build them
COPY --from=template-test --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-lint --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-build --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-pex-build --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-clean --chown=abc:abc /app/pyproject.toml /app
