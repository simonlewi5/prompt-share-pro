"""
Authentication routes
/signup: Create a new user
/login: Login user
"""

# from flask import Blueprint, request, jsonify, current_app
from flask import Blueprint, request, jsonify
from google.cloud import firestore
from google.api_core.exceptions import GoogleAPICallError, NotFound, AlreadyExists
# from flask_jwt_extended import create_access_token
from api.models.user import User
from api.utils.validators import is_valid_usc_email, is_valid_usc_id

auth_bp = Blueprint('auth', __name__)
db = firestore.Client()

@auth_bp.route('/signup', methods=['POST'])
def signup():
    """
    Create a new user
    """
    data = request.get_json()

    usc_id = data.get('usc_id')
    email = data.get('email')
    password = data.get('password')

    exception_found = None

    # Validate input
    if not email or not password or not usc_id:
        exception_found = jsonify(message="USC ID, email, and password are required"), 400
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
        User.create(email, usc_id, password)
    except AlreadyExists:
        exception_found = jsonify(message="User already exists"), 400
    except GoogleAPICallError as e:
        exception_found = jsonify(message=f"Error creating user in Firestore: {str(e)}"), 500
    except RuntimeError as e:
        exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

    if exception_found:
        return exception_found

    return jsonify(message="User created successfully"), 201

# @auth_bp.route('/login', methods=['POST'])
# def login():
#     """
#     Login user
#     """
#     print(f"JWT Secret Key: {current_app.config.get('JWT_SECRET_KEY')}")
#     print(f"JWT Initialized: {'JWTManager' in current_app.extensions}")
#     print(f"Current app extensions: {current_app.extensions}")

#     data = request.get_json()
#     email = data.get('email')
#     password = data.get('password')

#     exception_found = None

#     # Validate input
#     if not email or not password:
#         exception_found = jsonify(message="Email and password are required"), 400

#     # Check if user exists and validate password
#     try:
#         user = User.get_by_email(email)
#         if not user or not User.check_password(user['password'], password):
#             exception_found = jsonify(message="Invalid credentials"), 401
#     except NotFound:
#         exception_found = jsonify(message="User not found"), 404
#     except GoogleAPICallError as e:
#         exception_found = jsonify(message=f"Error accessing Firestore: {str(e)}"), 500
#     except RuntimeError as e:
#         exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

#     if exception_found:
#         return exception_found

    # Generate access token
    # access_token = create_access_token(identity=user['email'])
    # return jsonify(access_token=access_token), 200
