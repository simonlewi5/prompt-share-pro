"""
Comment model
"""
from datetime import datetime
from google.cloud import firestore
from google.api_core.exceptions import GoogleAPICallError, NotFound

class Comment:
    """
    Comment model
    """
    db = firestore.Client()

    @staticmethod
    def create(post_id, author_email, content):
        """
        Create a new comment on a post
        Raises:
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Comment.db.collection('posts').document(post_id)
            post = post_ref.get()
            if not post.exists:
                raise NotFound(f"Post with ID {post_id} not found.")
            
            comment_ref = post_ref.collection('comments').document()
            comment_data = {
                'author_email': author_email,
                'content': content,
                'created_at': datetime.utcnow(),
            }
            comment_ref.set(comment_data)
            return comment_ref.id
        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while creating comment: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def get_by_post(post_id):
        """
        Get all comments for a specific post
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Comment.db.collection('posts').document(post_id)
            post = post_ref.get()
            if not post.exists:
                raise NotFound(f"Post with ID {post_id} not found.")

            comments_ref = post_ref.collection('comments').stream()
            comments = [comment.to_dict() for comment in comments_ref]
            return comments
        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while retrieving comments: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def delete(post_id, comment_id):
        """
        Delete a comment by its ID on a specific post
        Raises:
            NotFound: if post or comment with given IDs not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Comment.db.collection('posts').document(post_id)
            comment_ref = post_ref.collection('comments').document(comment_id)
            comment = comment_ref.get()
            if not comment.exists:
                raise NotFound(f"Comment with ID {comment_id} not found.")

            comment_ref.delete()
        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while deleting comment: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e
