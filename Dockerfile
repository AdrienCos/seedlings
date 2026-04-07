ARG PYTHON_VERSION=3.14.3
ARG COPIER_VERSION=9.14.1
ARG USER_UID=1000

FROM ghcr.io/astral-sh/uv:0.10.8 AS uv
FROM ghcr.io/casey/just:1.49.0 AS just

FROM python:${PYTHON_VERSION}@sha256:ffebef43892dd36262fa2b042eddd3320d5510a21f8440dce0a650a3c124b51d AS base
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
ARG USER_UID
COPY --from=uv /uv /usr/local/bin/uv
COPY --from=just /just /usr/local/bin/just
COPY --from=template-hydrate --chown=abc:abc /app/hydrated /app/
RUN --mount=type=cache,target=/home/abc/.cache/uv,uid=${USER_UID} \
    uv sync

FROM template-install AS template-test
RUN just test && just coverage

FROM template-install AS template-lint
RUN just lint && just format

FROM template-install AS template-build
RUN just build

FROM template-install AS template-clean
RUN just clean

FROM template-install AS template-pre-commit
ARG USER_UID
RUN --mount=type=cache,target=/home/abc/.cache/pre-commit/,uid=${USER_UID} \
    git init . && \
    git add . && \
    uv run pre-commit run --all-files

FROM base AS final
# We do not care about the actual results of each stage, we just need to
# artifically create a dependency with them to make Docker build them
COPY --from=template-test --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-lint --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-build --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-clean --chown=abc:abc /app/pyproject.toml /app
COPY --from=template-pre-commit --chown=abc:abc /app/pyproject.toml /app
