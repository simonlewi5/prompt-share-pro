"""
Post model
"""
from datetime import datetime, timezone
from google.cloud import firestore
from google.api_core.exceptions import GoogleAPICallError, NotFound

class Post:
    """
    Post model
    """
    db = firestore.Client()

    @staticmethod
    def create(author, title, llm_kind, content, author_notes):
        """
        Create a new post
        Raises:
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Post.db.collection('posts').document()
            post_data = {
                'author': author,
                'title': title,
                'llm_kind': llm_kind,
                'content': content,
                'author_notes': author_notes,
                'created_at': datetime.now(timezone.utc),
                'total_points': 0,
                'total_ratings': 0,
                'user_ratings': {}
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
            post = post_ref.to_dict()
            post['id'] = post_ref.id  # Attach the Firestore document ID
            return post
        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while retrieving post: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def update(post_id, title=None, llm_kind=None, content=None, author_notes=None):
        """
        Update a post
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Post.db.collection('posts').document(post_id)
            updates = {}
            if title:
                updates['title'] = title
            if llm_kind:
                updates['llm_kind'] = llm_kind
            if content:
                updates['content'] = content
            if author_notes:
                updates['author_notes'] = author_notes
            if updates:
                updates['updated_at'] = datetime.utcnow()
                post_ref.update(updates)
            return True
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
            return True
        except NotFound as e:
            raise NotFound(f"Post with ID {post_id} not found.") from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while deleting post: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e

    @staticmethod
    def rate_post(post_id, user_email, rating):
        """
        Rate a post, ensuring the user hasn't rated it before.
        Raises:
            NotFound: if post with post_id not found
            GoogleAPICallError: if Firestore error occurs
            Exception: if unexpected error occurs
        """
        try:
            post_ref = Post.db.collection('posts').document(post_id)
            post = post_ref.get()
            if not post.exists:
                raise NotFound(f"Post with ID {post_id} not found.")
            
            post_data = post.to_dict()
            user_ratings = post_data.get('user_ratings', {})
            
            if user_email in user_ratings:
                raise Exception("User has already rated this post.") # pylint: disable=broad-exception-raised

            user_ratings[user_email] = rating
            total_points = post_data.get('total_points', 0) + rating
            total_ratings = post_data.get('total_ratings', 0) + 1

            post_ref.update({
                'user_ratings': user_ratings,
                'total_points': total_points,
                'total_ratings': total_ratings,
                'average_rating': total_points / total_ratings
            })
        except NotFound as e:
            raise NotFound(str(e)) from e
        except GoogleAPICallError as e:
            raise GoogleAPICallError(f"Firestore error while rating post: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e
