"""
Gemini API routes
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from google.api_core.exceptions import GoogleAPICallError
from api.models.gemini import Gemini
from api.utils.error_handler import handle_runtime_error

gemini_bp = Blueprint("gemini", __name__)


@jwt_required()
@gemini_bp.route("/gemini/generate", methods=["POST"])
def generate_content():
    """
    Generate content using the Gemini API.
    """
    data = request.get_json()
    prompt = data.get("prompt")
    model = data.get("model", "gemini-1.5-flash")

    if not prompt:
        return jsonify(message="Prompt is required"), 400

    try:
        result = Gemini.generate_prompt(prompt, model=model)
        return jsonify({"generated_content": result}), 200
    except GoogleAPICallError as e:
        return jsonify(message=f"Error interacting with Gemini API: {str(e)}"), 500
    except RuntimeError as e:
        return handle_runtime_error(e)
