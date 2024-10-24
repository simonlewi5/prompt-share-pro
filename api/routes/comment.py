"""
CRUD routes for comments
"""
from flask import Blueprint, request, jsonify
from google.api_core.exceptions import GoogleAPICallError, NotFound
from api.models.comment import Comment

comment_bp = Blueprint('comments', __name__)

# Add a new comment to a post
@comment_bp.route('/posts/<post_id>/comments', methods=['POST'])
def create(post_id):
    """
    Add a comment to a post
    """
    data = request.get_json()

    author_email = data.get('author_email')
    content = data.get('content')

    if not content or not author_email:
        return jsonify({'message': 'Author email and content are required'}), 400

    try:
        comment_id = Comment.create(post_id, author_email, content)
        return jsonify({
            'message': 'Comment added successfully',
            'comment_id': comment_id
            }), 201
    except NotFound as e:
        return jsonify({'message': str(e)}), 404
    except GoogleAPICallError as e:
        return jsonify({'message': f"Error creating comment: {str(e)}"}), 500
    except RuntimeError as e:
        return jsonify({'message': f"Unexpected error: {str(e)}"}), 500

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
        return jsonify({'message': str(e)}), 404 
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
        return jsonify({'message': str(e)}), 404 
    except GoogleAPICallError as e:
        return jsonify({'message': f"Error deleting comment: {str(e)}"}), 500
    except RuntimeError as e:
        return jsonify({'message': f"Unexpected error: {str(e)}"}), 500
