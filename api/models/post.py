"""
Contains the Post model
"""
from datetime import datetime, timezone
from api.utils.firestore_helpers import get_db, get_document_or_raise
from api.utils.error_handler import handle_firestore_exceptions


class Post:
    """
    Post model
    """

    @staticmethod
    @handle_firestore_exceptions
    def create(author, title, llm_kind, content, author_notes):
        """
        Create a new post
        Raises:
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        db = get_db()
        post_ref = db.collection("posts").document()
        post_data = {
            "author": author,
            "title": title,
            "llm_kind": llm_kind,
            "content": content,
            "author_notes": author_notes,
            "created_at": datetime.now(timezone.utc),
            "total_points": 0,
            "total_ratings": 0,
            "user_ratings": {},
        }
        post_ref.set(post_data)
        return post_ref.id

    @staticmethod
    @handle_firestore_exceptions
    def get_by_id(post_id):
        """
        Get a post by its ID
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        post = get_document_or_raise("posts", post_id)
        post_data = post.to_dict()
        post_data["id"] = post.id
        return post_data

    @staticmethod
    @handle_firestore_exceptions
    def get_all():
        """
        Retrieve all posts
        Raises:
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        db = get_db()
        posts_ref = db.collection("posts").stream()
        return [{"id": post.id, **post.to_dict()} for post in posts_ref]

    @staticmethod
    @handle_firestore_exceptions
    def get_by_user(user_email):
        """
        Retrieve all posts by a specific user
        Raises:
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        db = get_db()
        posts_ref = (
            db.collection("posts").where("author", "==", user_email).stream()
        )
        return [{"id": post.id, **post.to_dict()} for post in posts_ref]

    @staticmethod
    @handle_firestore_exceptions
    def update(post_id, title=None, llm_kind=None, content=None, author_notes=None):
        """
        Update a post
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        post = get_document_or_raise("posts", post_id)
        updates = {}
        if title:
            updates["title"] = title
        if llm_kind:
            updates["llm_kind"] = llm_kind
        if content:
            updates["content"] = content
        if author_notes:
            updates["author_notes"] = author_notes
        if updates:
            updates["updated_at"] = datetime.now(timezone.utc)
            post.reference.update(updates)
        return True

    @staticmethod
    @handle_firestore_exceptions
    def delete(post_id):
        """
        Delete a post by its ID
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        post = get_document_or_raise("posts", post_id)
        post.reference.delete()
        return True

    @staticmethod
    @handle_firestore_exceptions
    def rate_post(post_id, user_email, rating):
        """
        Rate a post, ensuring the user hasn't rated it before.
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        post = get_document_or_raise("posts", post_id)
        post_data = post.to_dict()
        user_ratings = post_data.get("user_ratings", {})
        if user_email in user_ratings:
            raise ValueError("User has already rated this post.")
        user_ratings[user_email] = rating
        total_points = post_data.get("total_points", 0) + rating
        total_ratings = post_data.get("total_ratings", 0) + 1
        post.reference.update(
            {
                "user_ratings": user_ratings,
                "total_points": total_points,
                "total_ratings": total_ratings,
                "average_rating": total_points / total_ratings,
            }
        )
