import random
from flask import Flask, jsonify
from google.cloud import firestore

app = Flask(__name__)
db = firestore.Client()


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
