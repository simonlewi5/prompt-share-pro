"""
Launch the Flask API, register any blueprints
"""
import random
from flask import Flask, jsonify
from flask_jwt_extended import JWTManager
from google.cloud import firestore
from api.config import config

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = config.JWT_SECRET_KEY

db = firestore.Client()
jwt = JWTManager(app)

from api.routes.auth import auth_bp
app.register_blueprint(auth_bp)

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

@app.route("/test_db")
def test_db():
    random_number = random.randint(1, 100)

    doc_ref = db.collection("test_collection").document()
    doc_ref.set({"random_number": random_number})

    return jsonify(
        status="success", message=f"Inserted record with random number: {random_number}"
    )

if __name__ == "__main__":
    app.run(debug=True)
