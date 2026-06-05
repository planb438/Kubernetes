#!/usr/bin/env python3
"""Production application for SBOM scanning demonstration."""

from flask import Flask, jsonify
import psycopg2
import redis
import requests
import yaml
import json
import os

app = Flask(__name__)

# Application dependencies for SBOM demonstration
# Flask: Web framework
# psycopg2: PostgreSQL adapter  
# redis: Redis client
# requests: HTTP library
# PyYAML: YAML parsing
# These will appear in SBOM

@app.route('/')
def index():
    """Main endpoint showing application info."""
    return jsonify({
        'application': 'SBOM Demo Application',
        'version': '2.1.0',
        'purpose': 'SBOM generation and vulnerability scanning demo',
        'dependencies': {
            'flask': '2.3.3',
            'psycopg2': '2.9.7',
            'redis': '4.6.0',
            'requests': '2.31.0',
            'pyyaml': '6.0.1'
        }
    })

@app.route('/health')
def health():
    """Health check endpoint."""
    return jsonify({'status': 'healthy'}), 200

@app.route('/sbom')
def sbom():
    """Endpoint to return generated SBOM (simulated)."""
    return jsonify({
        'sbom_format': 'SPDX-2.3',
        'packages': [
            {'name': 'flask', 'version': '2.3.3', 'license': 'BSD-3-Clause'},
            {'name': 'psycopg2', 'version': '2.9.7', 'license': 'LGPL-3.0'},
            {'name': 'redis', 'version': '4.6.0', 'license': 'MIT'},
            {'name': 'requests', 'version': '2.31.0', 'license': 'Apache-2.0'},
            {'name': 'pyyaml', 'version': '6.0.1', 'license': 'MIT'},
            {'name': 'python', 'version': '3.11.4', 'license': 'Python-2.0'}
        ]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)