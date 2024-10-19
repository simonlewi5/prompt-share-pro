from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return '''
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
    '''

@app.route('/health')
def health():
    return jsonify(status="healthy", message="API is up and running")

if __name__ == '__main__':
    app.run(debug=True)
