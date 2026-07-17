# Single-stage build: Flask/gunicorn are pure-Python, no compilation needed,
# so a multi-stage build adds complexity without benefit here — and the
# previous `pip install --target=...` approach silently dropped console
# script entry points (like the `gunicorn` executable), causing:
#   exec: "gunicorn": executable file not found in $PATH
FROM python:3.12-slim

# Run as a non-root user — a real security review item, not just a formality
RUN useradd --create-home --shell /bin/bash appuser
WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]