ARG PYTHON_VERSION=3.12.4
ARG PDM_VERSION=2.16.1
ARG COPIER_VERSION=9.3.0
ARG USER_UID=1000

FROM python:${PYTHON_VERSION}@sha256:2eedc86b81f2336841f4eed06dff14937d37ec172eec655434fd478eacb1ea49 as base
ARG USER_UID
RUN addgroup --system abc && \
    adduser \
    --shell /bin/sh \
    --ingroup abc \
    --uid ${USER_UID} \
    abc
USER abc
RUN mkdir -p /home/abc/.cache
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
ARG USER_UID
RUN pip install --user --no-cache-dir pdm==${PDM_VERSION}
COPY --from=template-hydrate --chown=abc:abc /app/hydrated /app/
RUN --mount=type=cache,target=/home/abc/.cache/pdm,uid=${USER_UID} \
    pdm install

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

FROM template-install as template-pre-commit
ARG USER_UID
RUN --mount=type=cache,target=/home/abc/.cache/pre-commit/,uid=${USER_UID} \
    git init . && \
    git add . && \
    pdm run pre-commit run --all-files

FROM base as final
# We do not care about the actual results of each stage, we just need to
# artifically create a dependency with them to make Docker build them
COPY --from=template-test --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-lint --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-build --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-pex-build --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-clean --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-pre-commit --chown=abc:abc /app/pyproject.toml /app
