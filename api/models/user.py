"""
User model for handling user creation, retrieval, and password validation in the Firestore database.
"""

from google.api_core.exceptions import AlreadyExists
from werkzeug.security import generate_password_hash, check_password_hash
from api.utils.firestore_helpers import get_db, get_document_or_raise
from api.utils.error_handler import handle_firestore_exceptions


class User:
    """
    User model
    """

    @staticmethod
    @handle_firestore_exceptions
    def create(email, username, usc_id, password, profile_image):
        """
        Create a new user
        Raises:
            AlreadyExists: if user with email already exists
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        hashed_password = generate_password_hash(password)
        db = get_db()
        user_ref = db.collection("users").document(email)
        if user_ref.get().exists:
            raise AlreadyExists(f"User with email {email} already exists.")
        user_ref.set(
            {
                "usc_id": usc_id,
                "username": username,
                "email": email,
                "password": hashed_password,
                "profile_image": profile_image,
            }
        )

    @staticmethod
    @handle_firestore_exceptions
    def get_by_email(email):
        """
        Get user by email
        Raises:
            NotFound: if user with email not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        user = get_document_or_raise("users", email)
        return user.to_dict()

    @staticmethod
    def check_password(stored_password, provided_password):
        """
        Check if provided password matches stored password
        """
        return check_password_hash(stored_password, provided_password)

    @staticmethod
    @handle_firestore_exceptions
    def update(email, username, profile_image):
        """
        Update user
        Updates username under comments
        Raises:
            NotFound: if user with email not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        user = get_document_or_raise("users", email)
        user.reference.update({"username": username, "profile_image": profile_image})
        db = get_db()
        posts_ref = db.collection("posts")
        for post in posts_ref.stream():
            comments_ref = post.reference.collection("comments")
            for comment in comments_ref.stream():
                comment_data = comment.to_dict()
                if comment_data.get("author", {}).get("email") == email:
                    comment.reference.update({"author.username": username})
