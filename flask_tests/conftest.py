"""
Base configuration for tests for the Flask application
"""

from unittest.mock import MagicMock
import pytest
from flask_jwt_extended import create_access_token
from api.create_app import create_app


@pytest.fixture
def app():
    """
    App fixture for the Flask application
    """
    app = create_app(  # pylint: disable=redefined-outer-name
        config_object="api.config.Config"
    )
    app.config.update(
        {
            "TESTING": True,
            "JWT_SECRET_KEY": "test-secret-key",
        }
    )
    return app


@pytest.fixture
def client(app):  # pylint: disable=redefined-outer-name
    """
    Client fixture for the Flask application
    """
    return app.test_client()


@pytest.fixture
def auth_headers(client):  # pylint: disable=unused-argument, redefined-outer-name
    """
    Auth headers fixture for the Flask application
    """
    token = create_access_token(
        identity={"email": "test@example.com", "username": "test_user"}
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture(autouse=True)
def mock_firestore(monkeypatch):
    """
    Mock Firestore client fixture
    """
    mock_client = MagicMock()
    monkeypatch.setattr("google.cloud.firestore.Client", lambda: mock_client)
    return mock_client
