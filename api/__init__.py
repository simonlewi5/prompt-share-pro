"""
Initialize the Flask application and other extensions like JWT and Firestore
"""
from flask import Flask, jsonify
from flask_jwt_extended import JWTManager
from google.cloud import firestore

jwt = JWTManager()
db = firestore.Client()

def create_app(config_object='api.config.Config'):
    """
    Create a Flask app using the provided configuration object
    """
    app = Flask(__name__)
    app.config.from_object(config_object)

    jwt.init_app(app)

    from api.routes.auth import auth_bp # pylint: disable=C0415
    app.register_blueprint(auth_bp)

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
