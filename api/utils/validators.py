"""
Validators for API routes
"""

from flask import jsonify


def is_valid_usc_email(email):
    """
    Returns True if email is a USC email,
    False otherwise
    """
    return email.endswith("@usc.edu")


def is_valid_usc_id(usc_id):
    """
    Returns True if USC ID is a 10-digit number,
    False otherwise
    """
    return usc_id.isdigit() and len(usc_id) == 10


def validate_post_data(data, required=True):
    """
    Validator used in post routes
    Returns error message if required fields are missing
    """
    required_fields = ["title", "llm_kind", "content"]

    if required:
        for field in required_fields:
            if field not in data or not data[field]:
                return jsonify({"error": f"{field} is required"}), 400

    return None
