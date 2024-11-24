"""
Utility functions for handling errors
"""

from flask import jsonify


def handle_runtime_error(e):
    """
    A generic error handler for unexpected errors
    """
    return jsonify(message=f"Unexpected error: {str(e)}"), 500
