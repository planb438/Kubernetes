# Vulnerable demo image
FROM python:3.8-slim

# Install vulnerable packages
RUN pip install \
    flask==0.12.1 \
    django==1.11.29 \
    requests==2.20.0 \
    urllib3==1.24.3 \
    cryptography==2.5 \
    pyyaml==5.1 \
    pillow==6.2.1

# Add vulnerable script
COPY app.py /app.py

# Run as non-root
USER 1000

CMD ["python", "/app.py"]