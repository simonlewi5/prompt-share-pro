"""
Initialize the Flask application and other extensions like JWT and Firestore
"""
import os
import logging
from flask import Flask, jsonify
from flask_jwt_extended import JWTManager
from google.cloud import firestore
from dotenv import load_dotenv
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

    return app
