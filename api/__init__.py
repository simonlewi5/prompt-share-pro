"""
Initialize the Flask application and other extensions like JWT and Firestore
"""
import logging
from flask import Flask, jsonify
from flask_jwt_extended import JWTManager
from google.cloud import firestore
from api.routes.auth import auth_bp

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
db = firestore.Client()

def create_app(config_object='api.config.Config'):
    """
    Create a Flask app using the provided configuration object
    """
    app = Flask(__name__)
    app.config.from_object(config_object)

    logger.info("Current app before JWT: %s", app)

    jwt = JWTManager(app)

    logger.info("Current app after JWT, before blueprint registered: %s", app)

    app.register_blueprint(auth_bp)

    logger.info("Current app after blueprint registered: %s", app)

    # Register other blueprints and routes

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
