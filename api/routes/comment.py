"""
CRUD routes for comments
"""
from datetime import datetime
from flask import Blueprint, request, jsonify
from google.api_core.exceptions import GoogleAPICallError, NotFound
from api.models.comment import Comment

comment_bp = Blueprint('comments', __name__)

# Add a new comment to a post
@comment_bp.route('/posts/<post_id>/comments', methods=['POST'])
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
            'created_at': datetime.utcnow(),  # Use UTC for consistent timestamps
        }

        # Add logging to check the Firestore path
        print(f"Creating comment at path: {comment_ref.path}")
        print(f"Comment data: {comment_data}")

        comment_ref.set(comment_data)
        return comment_ref.id  # Return the Firestore document ID
    except NotFound as e:
        raise NotFound(str(e)) from e
    except GoogleAPICallError as e:
        raise GoogleAPICallError(f"Firestore error while creating comment: {str(e)}") from e
    except Exception as e:
        raise RuntimeError(f"Unexpected error: {str(e)}") from e

# Get all comments for a specific post
@comment_bp.route('/posts/<post_id>/comments', methods=['GET'])
def get_comments(post_id):
    """
    Get all comments for a specific post
    """
    try:
        comments = Comment.get_by_post(post_id)
        return jsonify(comments), 200
    except NotFound as e:
        return jsonify({'message': str(e)}), 404  # More specific NotFound message
    except GoogleAPICallError as e:
        return jsonify({'message': f"Error retrieving comments: {str(e)}"}), 500
    except RuntimeError as e:
        return jsonify({'message': f"Unexpected error: {str(e)}"}), 500


# Delete a comment by its ID on a specific post
@comment_bp.route('/posts/<post_id>/comments/<comment_id>', methods=['DELETE'])
def delete_comment(post_id, comment_id):
    """
    Delete a comment by its ID
    """
    try:
        Comment.delete(post_id, comment_id)
        return jsonify({'message': 'Comment deleted successfully'}), 200
    except NotFound as e:
        return jsonify({'message': str(e)}), 404  # More specific NotFound message
    except GoogleAPICallError as e:
        return jsonify({'message': f"Error deleting comment: {str(e)}"}), 500
    except RuntimeError as e:
        return jsonify({'message': f"Unexpected error: {str(e)}"}), 500

