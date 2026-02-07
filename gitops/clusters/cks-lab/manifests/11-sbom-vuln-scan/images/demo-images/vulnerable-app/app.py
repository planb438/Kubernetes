#!/usr/bin/env python
"""
Vulnerable Flask application for security scanning demo.
Contains known vulnerable dependencies for testing purposes.
"""

from flask import Flask, request, jsonify
import requests
import yaml
import os
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
    """Root endpoint showing app info."""
    return jsonify({
        'app': 'Vulnerable Demo App',
        'version': '1.0.0',
        'purpose': 'Security scanning demonstration',
        'warning': 'This app contains known vulnerabilities for testing'
    })

@app.route('/health')
def health():
    """Health check endpoint."""
    return jsonify({'status': 'healthy'}), 200

@app.route('/echo', methods=['POST'])
def echo():
    """Echo endpoint with potential injection vulnerability."""
    data = request.json
    if not data:
        return jsonify({'error': 'No JSON data provided'}), 400
    
    # Potential insecure deserialization
    if 'yaml' in data:
        try:
            parsed = yaml.load(data['yaml'], Loader=yaml.Loader)
            return jsonify({'parsed': str(parsed)})
        except Exception as e:
            return jsonify({'error': str(e)}), 400
    
    return jsonify({'echo': data})

@app.route('/fetch')
def fetch():
    """Fetch external content with potential SSRF."""
    url = request.args.get('url')
    if url:
        try:
            response = requests.get(url, timeout=5)
            return response.text[:500]
        except Exception as e:
            return jsonify({'error': str(e)}), 400
    return jsonify({'message': 'Provide URL parameter'}), 400

@app.route('/execute')
def execute():
    """Command execution endpoint (DANGEROUS - for demo only)."""
    cmd = request.args.get('cmd')
    if cmd:
        try:
            result = subprocess.check_output(cmd, shell=True, timeout=5)
            return result.decode('utf-8')
        except Exception as e:
            return jsonify({'error': str(e)}), 400
    return jsonify({'message': 'Provide cmd parameter'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)