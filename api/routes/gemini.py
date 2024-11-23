"""
Gemini API routes
"""

from flask import Blueprint, request, jsonify
# from flask_jwt_extended import jwt_required
from google.api_core.exceptions import GoogleAPICallError
from api.models.gemini import Gemini

gemini_bp = Blueprint("gemini", __name__)


# @jwt_required()
@gemini_bp.route("/gemini/generate", methods=["POST"])
def generate_content():
    """
    Generate content using the Gemini API.
    """
    print("Received request at /gemini/generate")

    data = request.get_json()
    if not data:
        print("Request body is empty")
        return jsonify(message="Request body is required"), 400

    prompt = data.get("prompt")
    model = data.get("model", "gemini-1.5-flash")

    print(f"Extracted data - Prompt: {prompt}, Model: {model}")

    if not prompt:
        print("Prompt is missing from the request")
        return jsonify(message="Prompt is required"), 400

    try:
        print(f"Calling Gemini.generate_prompt with prompt: {prompt} and model: {model}")
        result = Gemini.generate_prompt(prompt, model=model)
        print(f"Generated content successfully: {result[:100]}")  # Log the first 100 characters
        return jsonify({"generated_content": result}), 200
    except GoogleAPICallError as e:
        print(f"GoogleAPICallError occurred: {str(e)}")
        return jsonify(message=f"Error interacting with Gemini API: {str(e)}"), 500
    except RuntimeError as e:
        print(f"RuntimeError occurred: {str(e)}")
        return jsonify(message=f"Unexpected error: {str(e)}"), 500

