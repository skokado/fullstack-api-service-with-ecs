# ref. https://future-architect.github.io/articles/20250602a/

FROM python:3.13 AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN python -m venv /.venv
ENV VIRTUAL_ENV=/.venv

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync --locked --no-dev


FROM python:3.13-slim AS runner

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /opt/app
ENV VIRTUAL_ENV=/opt/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

COPY --from=builder /.venv /opt/app/.venv
COPY ./app /opt/app/app

USER appuser

CMD ["python", "-m", "fastapi", "run", "--port", "8000"]
EXPOSE 8000
