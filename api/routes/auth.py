"""
Authentication routes
/signup: Create a new user
/login: Login user
"""

from datetime import timedelta
from flask import Blueprint, request, jsonify
from google.api_core.exceptions import GoogleAPICallError, NotFound, AlreadyExists
from flask_jwt_extended import create_access_token
from api.models.user import User
from api.utils.validators import is_valid_usc_email, is_valid_usc_id

auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/signup", methods=["POST"])
def signup():
    """
    Create a new user
    """
    data = request.get_json()

    usc_id = data.get("usc_id")
    username = data.get("username")
    email = data.get("email")
    password = data.get("password")
    profile_image = data.get("profile_image")

    exception_found = None

    # Validate input
    if not email or not password or not usc_id:
        exception_found = (
            jsonify(message="USC ID, email, and password are required"),
            400,
        )
    elif not is_valid_usc_email(email):
        exception_found = jsonify(message="Invalid USC email"), 400
    elif not is_valid_usc_id(usc_id):
        exception_found = jsonify(message="Invalid USC ID"), 400

    # Check if user already exists
    try:
        if User.get_by_email(email):
            exception_found = jsonify(message="User already exists"), 400
    except NotFound:
        pass
    except GoogleAPICallError as e:
        exception_found = jsonify(message=f"Error accessing Firestore: {str(e)}"), 500

    # Create user
    try:
        User.create(email, username, usc_id, password, profile_image)
        user = User.get_by_email(email)
    except AlreadyExists:
        exception_found = jsonify(message="User already exists"), 400
    except GoogleAPICallError as e:
        exception_found = (
            jsonify(message=f"Error creating user in Firestore: {str(e)}"),
            500,
        )
    except RuntimeError as e:
        exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

    if exception_found:
        return exception_found

    claims = {
        "username": user["username"],
        "email": user["email"],
    }
    expires = timedelta(days=1)

    access_token = create_access_token(identity=claims, expires_delta=expires)
    return jsonify(access_token=access_token), 200


@auth_bp.route("/login", methods=["POST"])
def login():
    """
    Login user
    """
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    exception_found = None

    if not email or not password:
        exception_found = jsonify(message="Email and password are required"), 400

    try:
        user = User.get_by_email(email)
        if not user or not User.check_password(user["password"], password):
            exception_found = jsonify(message="Invalid credentials"), 401
    except NotFound:
        exception_found = jsonify(message="User not found"), 404
    except GoogleAPICallError as e:
        exception_found = jsonify(message=f"Error accessing Firestore: {str(e)}"), 500
    except RuntimeError as e:
        exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

    if exception_found:
        return exception_found

    # Generate access token
    claims = {
        "username": user["username"],
        "email": user["email"],
    }
    expires = timedelta(days=1)

    access_token = create_access_token(identity=claims, expires_delta=expires)
    return jsonify(access_token=access_token), 200


# Get user by email
@auth_bp.route("/users/<email>", methods=["GET"])
def get_user(email):
    """
    Get user by email
    """
    try:
        user = User.get_by_email(email)
        return jsonify(user), 200
    except NotFound as e:
        return jsonify({"message": str(e)}), 404
    except GoogleAPICallError as e:
        return jsonify({"message": f"Error retrieving user: {str(e)}"}), 500
    except RuntimeError as e:
        return jsonify({"message": f"Unexpected error: {str(e)}"}), 500


# Update user by email
@auth_bp.route("/users/<email>", methods=["PUT"])
def update_user(email):
    """
    Update user by email
    """
    data = request.get_json()

    username = data.get("username")
    profile_image = data.get("profile_image")

    exception_found = None

    if not username:
        exception_found = jsonify(message="Username is required"), 400

    try:
        User.update(email, username=username, profile_image=profile_image)
        user = User.get_by_email(email)
    except NotFound:
        exception_found = jsonify(message="User not found"), 404
    except GoogleAPICallError as e:
        exception_found = (
            jsonify(message=f"Error updating user in Firestore: {str(e)}"),
            500,
        )
    except RuntimeError as e:
        exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

    if exception_found:
        return exception_found

    claims = {
        "username": user["username"],
        "email": user["email"],
    }
    expires = timedelta(days=1)

    access_token = create_access_token(identity=claims, expires_delta=expires)
    return jsonify(access_token=access_token), 200
