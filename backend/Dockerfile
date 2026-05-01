FROM python:3.11-slim

# Çalışma dizini
WORKDIR /app

# Sistem bağımlılıkları (curl health check için)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Önce requirements'ı kopyala (Docker layer caching için)
COPY requirements.txt .

# Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Uygulama kodunu kopyala
COPY app/ ./app/
COPY run.py .

# Non-root user (security best practice)
RUN useradd --create-home --shell /bin/bash nuveli && \
    chown -R nuveli:nuveli /app
USER nuveli

# Production server: uvicorn + workers
# PORT env variable'ı Render/Fly.io tarafından set edilir
ENV PORT=8000
EXPOSE $PORT

# Health check (her 30 saniyede)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/health || exit 1

# Production komut: gunicorn + uvicorn workers
# 2 worker (free tier için yeterli, scale gerekirse 4+)
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 2"]
