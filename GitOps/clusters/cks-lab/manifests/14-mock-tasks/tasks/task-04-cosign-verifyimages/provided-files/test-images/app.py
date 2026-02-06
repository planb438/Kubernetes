#!/usr/bin/env python3
"""Test application for image signing verification."""

from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({
        'app': 'Signed Test Application',
        'version': '1.0.0',
        'purpose': 'Image signing verification test',
        'environment': os.getenv('ENVIRONMENT', 'production')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)