"""
Load the Flask app and run it
This is the entry point for the Flask app using WSGI
"""

from api.app import app

if __name__ == "__main__":
    app.run()
