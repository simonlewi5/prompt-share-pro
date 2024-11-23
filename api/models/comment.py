"""
Comment model
"""

from datetime import datetime, timezone
from google.api_core.exceptions import NotFound
from api.utils.firestore_helpers import get_document_or_raise, fetch_collection_items
from api.utils.error_handler import handle_firestore_exceptions


class Comment:
    """
    Comment model
    """

    @staticmethod
    @handle_firestore_exceptions
    def create(post_id, author, content):
        """
        Create a new comment on a post
        Raises:
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        post = get_document_or_raise("posts", post_id)
        comment_ref = post.reference.collection("comments").document()
        comment_data = {
            "author": author,
            "content": content,
            "created_at": datetime.now(timezone.utc),
        }
        comment_ref.set(comment_data)
        return comment_ref.id

    @staticmethod
    @handle_firestore_exceptions
    def get_by_post(post_id):
        """
        Get all comments for a specific post
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        post = get_document_or_raise("posts", post_id)
        return fetch_collection_items(post, "comments")

    @staticmethod
    @handle_firestore_exceptions
    def delete(post_id, comment_id):
        """
        Delete a comment by its ID on a specific post
        Raises:
            NotFound: if post or comment with given IDs not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
<<<<<<< HEAD
        post = get_document_or_raise("posts", post_id)
        comment_ref = post.reference.collection("comments").document(comment_id)
        comment = comment_ref.get()
        if not comment.exists:
            raise NotFound(f"Comment with ID {comment_id} not found.")
        comment_ref.delete()
=======
>>>>>>> c6631f8 (update comment endpoint)
