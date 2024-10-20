"""
Initialize the Flask application and other extensions like JWT and Firestore
"""
import os
import logging
from flask import Flask, current_app, jsonify, request
from flask_jwt_extended import JWTManager, create_access_token
from google.cloud import firestore
from google.api_core.exceptions import GoogleAPICallError, NotFound
from dotenv import load_dotenv
from api.models.user import User
from api.routes.auth import auth_bp

load_dotenv()
db = firestore.Client()

def create_app():
    """
    Create a Flask app and configure it directly.
    """
    app = Flask(__name__)

    # Directly configure the JWT secret key
    app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'secret-key')

    # Set up logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    logger.info("Current app before JWT initialization")

    jwt = JWTManager(app)

    logger.info("Current app after JWT initialization, before blueprint registered")

    app.register_blueprint(auth_bp)

    logger.info("Current app after blueprint registered")

    @app.route("/")
    def home():
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Welcome</title>
        </head>
        <body>
            <h1>Welcome to PromptSharePro24 API</h1>
            <p>This is the root endpoint of the Flask API.</p>
        </body>
        </html>
        """

    @app.route("/health")
    def health():
        return jsonify(status="healthy", message="API is up and running")

    @app.route("/login2", methods=['POST'])
    def login2():
        """
        Login user
        """
        print(f"JWT Secret Key: {current_app.config.get('JWT_SECRET_KEY')}")
        print(f"JWT Initialized: {'JWTManager' in current_app.extensions}")
        print(f"Current app extensions: {current_app.extensions}")

        data = request.get_json()
        email = data.get('email')
        password = data.get('password')

        exception_found = None

        # Validate input
        if not email or not password:
            exception_found = jsonify(message="Email and password are required"), 400

        # Check if user exists and validate password
        try:
            user = User.get_by_email(email)
            if not user or not User.check_password(user['password'], password):
                exception_found = jsonify(message="Invalid credentials"), 401
        except NotFound:
            exception_found = jsonify(message="User not found"), 404
        except GoogleAPICallError as e:
            exception_found = jsonify(message=f"Error accessing Firestore: {str(e)}"), 500
        except RuntimeError as e:
            exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

        if exception_found:
            return exception_found

        access_token = create_access_token(identity=user['email'])
        return jsonify(access_token=access_token), 200

    return app
