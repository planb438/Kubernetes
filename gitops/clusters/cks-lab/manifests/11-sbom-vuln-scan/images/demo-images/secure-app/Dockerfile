# Secure demo image
FROM python:3.11-slim

# Install secure versions
RUN pip install \
    flask==2.3.3 \
    requests==2.31.0 \
    cryptography==41.0.3 \
    pyyaml==6.0.1 \
    pillow==10.0.0

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
WORKDIR /app

# Copy application
COPY app.py /app/app.py
COPY requirements.txt /app/requirements.txt

# Set permissions
RUN chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8080/health', timeout=2)"

CMD ["python", "/app/app.py"]