FROM python:3.11-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /api

COPY pyproject.toml uv.lock ./

RUN uv sync --frozen --no-dev

COPY app ./app

EXPOSE 8000

# ---- Run the app using the venv uv created ----
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "localhost", "--port", "8000"]