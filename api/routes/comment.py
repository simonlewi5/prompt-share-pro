"""
CRUD routes for comments
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from google.api_core.exceptions import GoogleAPICallError, NotFound
from api.models.comment import Comment
from api.utils.error_handler import handle_runtime_error

comment_bp = Blueprint("comments", __name__)


@comment_bp.route("/posts/<post_id>/comments", methods=["POST"])
@jwt_required()
def create(post_id):
    """
    Add a comment to a post
    """
    data = request.get_json()
    author = get_jwt_identity()
    content = data.get("content")

    if not content:
        return jsonify({"message": "Content is required"}), 400

    try:
        comment_id = Comment.create(post_id, author, content)
        return (
            jsonify(
                {"message": "Comment added successfully", "comment_id": comment_id}
            ),
            201,
        )
    except NotFound as e:
        return jsonify({"message": str(e)}), 404
    except GoogleAPICallError as e:
        return jsonify({"message": f"Error creating comment: {str(e)}"}), 500
    except RuntimeError as e:
        return handle_runtime_error(e)


@comment_bp.route("/posts/<post_id>/comments", methods=["GET"])
@jwt_required()
def get_comments(post_id):
    """
    Get all comments for a specific post
    """
    try:
        comments = Comment.get_by_post(post_id)
        return jsonify(comments), 200
    except NotFound as e:
        return jsonify({"message": str(e)}), 404
    except GoogleAPICallError as e:
        return jsonify({"message": f"Error retrieving comments: {str(e)}"}), 500
    except RuntimeError as e:
        return handle_runtime_error(e)


@comment_bp.route("/posts/<post_id>/comments/<comment_id>", methods=["DELETE"])
@jwt_required()
def delete_comment(post_id, comment_id):
    """
    Delete a comment by its ID
    """
    try:
        Comment.delete(post_id, comment_id)
        return jsonify({"message": "Comment deleted successfully"}), 200
    except NotFound as e:
        return jsonify({"message": str(e)}), 404
    except GoogleAPICallError as e:
        return jsonify({"message": f"Error deleting comment: {str(e)}"}), 500
    except RuntimeError as e:
<<<<<<< HEAD
        return handle_runtime_error(e)
=======

@comment_bp.route("/posts/<post_id>/comments/<comment_id>", methods=["PUT"])
@jwt_required()
def update_comment(post_id, comment_id):
    """
    Update a comment by its ID
    """
    data = request.get_json()

    content = data.get("content")

    exception_found = None

    # Update the post
    try:
        Comment.update(post_id, comment_id, content=content)
    except NotFound:
        exception_found = jsonify(message="Comment not found"), 404
    except GoogleAPICallError as e:
        exception_found = (
            jsonify(message=f"Error updating comment in Firestore: {str(e)}"),
            500,
        )
    except RuntimeError as e:
        exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

    if exception_found:
        return exception_found

    return jsonify(message="Comment updated"), 200        
>>>>>>> c6631f8 (update comment endpoint)
