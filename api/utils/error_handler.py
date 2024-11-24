"""
Utility functions for handling errors
"""

from flask import jsonify
from google.api_core.exceptions import GoogleAPICallError, NotFound


def handle_firestore_exceptions(func):
    """
    Decorator to handle Firestore exceptions
    """

    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    return wrapper


def handle_runtime_error(e):
    """
    A generic error handler for unexpected errors
    """
    return jsonify(message=f"Unexpected error: {str(e)}"), 500
