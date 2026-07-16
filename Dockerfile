# --- Build stage: install dependencies into a virtualenv ---
FROM python:3.12-slim AS build

WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir --target=/install -r requirements.txt

# --- Final stage: small runtime image, no build tools ---
FROM python:3.12-slim

# Run as a non-root user — a real security review item, not just a formality
RUN useradd --create-home --shell /bin/bash appuser
WORKDIR /app

COPY --from=build /install /usr/local/lib/python3.12/site-packages
COPY app/ .

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
