"""
Post model
"""
from datetime import datetime
from google.cloud import firestore
from google.api_core.exceptions import GoogleAPICallError, NotFound

class Post:
    """
    Post model
    """
    db = firestore.Client()

    @staticmethod
    def create(author_email, title, llm_kind, content):
        """
        Create a new post
        Raises:
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Post.db.collection('posts').document()
            post_data = {
                'author_email': author_email,
                'title': title,
                'llm_kind': llm_kind,
                'content': content,
                'created_at': datetime.utcnow(),
            }
            post_ref.set(post_data)
            return post_ref.id
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while creating post: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def get_by_id(post_id):
        """
        Get a post by its ID
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Post.db.collection('posts').document(post_id).get()
            if not post_ref.exists:
                raise NotFound(f"Post with ID {post_id} not found.")
            return post_ref.to_dict()
        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while retrieving post: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def update(post_id, title=None, llm_kind=None, content=None):
        """
        Update a post
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Post.db.collection('posts').document(post_id)
            post_ref.update({
                'title': title,
                'llm_kind': llm_kind,
                'content': content,
                'updated_at': datetime.utcnow(),
            })
        except NotFound as e:
            raise NotFound(f"Post with ID {post_id} not found.") from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while updating post: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def delete(post_id):
        """
        Delete a post by its ID
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Post.db.collection('posts').document(post_id)
            post_ref.delete()
        except NotFound as e:
            raise NotFound(f"Post with ID {post_id} not found.") from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while deleting post: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e