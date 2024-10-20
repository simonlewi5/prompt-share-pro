"""
User model for handling user creation, retrieval, and password validation in the Firestore database.
"""

from google.cloud import firestore
from google.api_core.exceptions import GoogleAPICallError, NotFound, AlreadyExists
from werkzeug.security import generate_password_hash, check_password_hash

class User:
    """
    User model
    """
    db = firestore.Client()

    @staticmethod
    def create(email, usc_id, password):
        """
        Create a new user
        Raises:
            AlreadyExists: if user with email already exists
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """

        hashed_password = generate_password_hash(password)
        try:
            user_ref = User.db.collection('users').document(email)
            if user_ref.get().exists:
                raise AlreadyExists(f"User with email {email} already exists.")
            user_ref.set({
                'usc_id': usc_id,
                'email': email,
                'password': hashed_password
            })
        except AlreadyExists as e:
            raise AlreadyExists(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while creating user: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def get_by_email(email):
        """
        Get user by email
        Raises:
            NotFound: if user with email not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            user_ref = User.db.collection('users').document(email).get()
            if not user_ref.exists:
                raise NotFound(f"User with email {email} not found.")
            return user_ref.to_dict()
        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while retrieving user: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def check_password(stored_password, provided_password):
        """
        Check if provided password matches stored password
        """
        return check_password_hash(stored_password, provided_password)
