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

    @staticmethod
    def get_db():
        """
        Get Firestore client
        """
        return firestore.Client()

    @staticmethod
    def create(email, username, usc_id, password, profile_image):
        """
        Create a new user
        Raises:
            AlreadyExists: if user with email already exists
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """

        hashed_password = generate_password_hash(password)
        db = User.get_db()
        try:
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
        except AlreadyExists as e:
            raise AlreadyExists(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(
                f"Firestore error while creating user: {str(e)}"
            ) from e
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
        db = User.get_db()
        try:
            user_ref = db.collection("users").document(email).get()
            if not user_ref.exists:
                raise NotFound(f"User with email {email} not found.")
            return user_ref.to_dict()
        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(
                f"Firestore error while retrieving user: {str(e)}"
            ) from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def check_password(stored_password, provided_password):
        """
        Check if provided password matches stored password
        """
        return check_password_hash(stored_password, provided_password)

    @staticmethod
    def update(email, username, profile_image):
        """
        Update user
        Updates username under comments
        Raises:
            NotFound: if user with email not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        db = User.get_db()
        try:
            user_ref = db.collection("users").document(email)
            if not user_ref.get().exists:
                raise NotFound(f"User with email {email} not found.")
            user_ref.update({"username": username, "profile_image": profile_image})

            posts_ref = db.collection("posts")
            posts = posts_ref.stream()

            for post in posts:
                comments_ref = post.reference.collection("comments")
                comments = comments_ref.stream()

                for comment in comments:
                    comment_data = comment.to_dict()
                    if comment_data.get("author", {}).get("email") == email:
                        comment.reference.update({"author.username": username})

        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(
                f"Firestore error while updating user: {str(e)}"
            ) from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e
