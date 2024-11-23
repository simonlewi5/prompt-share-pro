"""
Initialize the Flask application and other extensions like JWT and Firestore
"""

from flask import Flask, jsonify
from flask_jwt_extended import JWTManager
from dotenv import load_dotenv
from api.models.gemini import Gemini
from api.routes.auth import auth_bp
from api.routes.post import post_bp
from api.routes.comment import comment_bp
from api.routes.gemini import gemini_bp

load_dotenv()


def create_app(config_object="api.config.Config"):
    """
    Create a Flask app using the provided configuration object
    """
    app = Flask(__name__)
    app.config.from_object(config_object)

    jwt = JWTManager(app)  # pylint: disable=unused-variable
    try:
        Gemini.configure()
    except RuntimeError as e:
        print(f"Error configuring Gemini API: {str(e)}")

    app.register_blueprint(auth_bp)
    app.register_blueprint(post_bp)
    app.register_blueprint(comment_bp)
    app.register_blueprint(gemini_bp)

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
