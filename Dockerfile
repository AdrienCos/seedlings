ARG PYTHON_VERSION=3.14.2
ARG PDM_VERSION=2.26.6
ARG COPIER_VERSION=9.11.3
ARG USER_UID=1000

FROM python:${PYTHON_VERSION}@sha256:17bc9f1d032a760546802cc4e406401eb5fe99dbcb4602c91628e73672fa749c AS base
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



FROM base AS template-hydrate
ARG COPIER_VERSION
RUN pip install --user --no-cache-dir copier==${COPIER_VERSION}
COPY --chown=abc:abc ./copier.yml /app/
COPY --chown=abc:abc ./python /app/python
RUN copier copy --defaults . /app/hydrated



FROM base AS template-install
ARG PDM_VERSION
ARG USER_UID
RUN pip install --user --no-cache-dir pdm==${PDM_VERSION}
COPY --from=template-hydrate --chown=abc:abc /app/hydrated /app/
RUN --mount=type=cache,target=/home/abc/.cache/pdm,uid=${USER_UID} \
    pdm install

FROM template-install AS template-test
RUN pdm test && pdm coverage

FROM template-install AS template-lint
RUN pdm lint && pdm format

FROM template-install AS template-build
RUN pdm build

FROM template-install AS template-pex-build
RUN pdm pex-build

FROM template-install AS template-clean
RUN pdm clean

FROM template-install AS template-pre-commit
ARG USER_UID
RUN --mount=type=cache,target=/home/abc/.cache/pre-commit/,uid=${USER_UID} \
    git init . && \
    git add . && \
    pdm run pre-commit run --all-files

FROM base AS final
# We do not care about the actual results of each stage, we just need to
# artifically create a dependency with them to make Docker build them
COPY --from=template-test --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-lint --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-build --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-pex-build --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-clean --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-pre-commit --chown=abc:abc /app/pyproject.toml /app
