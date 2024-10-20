"""
Initialize the Flask application and other extensions like JWT and Firestore
"""
import logging
from flask import Flask, jsonify
from flask_jwt_extended import JWTManager
from google.cloud import firestore
from api.routes.auth import auth_bp

db = firestore.Client()

def create_app(config_object='api.config.Config'):
    """
    Create a Flask app using the provided configuration object
    """
    app = Flask(__name__)
    app.config.from_object(config_object)

    # Set up logging
    gunicorn_logger = logging.getLogger('gunicorn.error')
    app.logger.handlers = gunicorn_logger.handlers
    app.logger.setLevel(gunicorn_logger.level)

    app.logger.info("Current app before JWT initialization")
    
    jwt = JWTManager(app)
    
    app.logger.info("Current app after JWT initialization, before blueprint registered")

    app.register_blueprint(auth_bp)
    
    app.logger.info("Current app after blueprint registered")

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
