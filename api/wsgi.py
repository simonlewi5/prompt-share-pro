"""
Load the Flask app and run it
This is the entry point for the Flask app using WSGI
"""

from api import create_app

app = create_app()

if __name__ == "__main__":
    app.run()
