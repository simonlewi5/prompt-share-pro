"""
This module contains the routes for the Post model
"""
from flask import Blueprint, request, jsonify
from google.api_core.exceptions import GoogleAPICallError, NotFound
from api.models.post import Post
from api.utils.validators import validate_post_data

post_bp = Blueprint('post', __name__)

# Create a new post
@post_bp.route('/posts', methods=['POST'])
def create_post():
    """
    Create a new post
    """
    data = request.get_json()

    author_email = data.get('author_email')
    title = data.get('title')
    llm_kind = data.get('llm_kind')
    content = data.get('content')

    exception_found = None

    # Validate input
    exception = validate_post_data(data)
    if exception:
        return exception

    # Create the post
    try:
        post_id = Post.create(author_email, title, llm_kind, content)
    except GoogleAPICallError as e:
        exception_found = jsonify(message=f"Error creating post in Firestore: {str(e)}"), 500
    except RuntimeError as e:
        exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

    if exception_found:
        return exception_found

    return jsonify(message="Post created", post_id=post_id), 201

# Get a post by its ID
@post_bp.route('/posts/<post_id>', methods=['GET'])
def get_post(post_id):
    """
    Get a post by its ID
    """
    exception_found = None

    try:
        post = Post.get_by_id(post_id)
    except NotFound:
        exception_found = jsonify(message="Post not found"), 404
    except GoogleAPICallError as e:
        exception_found = jsonify(message=f"Error accessing Firestore: {str(e)}"), 500
    except RuntimeError as e:
        exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

    if exception_found:
        return exception_found

    return jsonify(post), 200

# Update a post by its ID
@post_bp.route('/posts/<post_id>', methods=['PUT'])
def update_post(post_id):
    """
    Update a post by its ID
    """
    data = request.get_json()

    title = data.get('title')
    llm_kind = data.get('llm_kind')
    content = data.get('content')

    exception_found = None

    # Validate input
    exception = validate_post_data(data, required=False)
    if exception:
        return exception

    # Update the post
    try:
        Post.update(post_id, title=title, llm_kind=llm_kind, content=content)
    except NotFound:
        exception_found = jsonify(message="Post not found"), 404
    except GoogleAPICallError as e:
        exception_found = jsonify(message=f"Error updating post in Firestore: {str(e)}"), 500
    except RuntimeError as e:
        exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

    if exception_found:
        return exception_found

    return jsonify(message="Post updated"), 200

# Delete a post by its ID
@post_bp.route('/posts/<post_id>', methods=['DELETE'])
def delete_post(post_id):
    """
    Delete a post by its ID
    """
    exception_found = None

    try:
        Post.delete(post_id)
    except NotFound:
        exception_found = jsonify(message="Post not found"), 404
    except GoogleAPICallError as e:
        exception_found = jsonify(message=f"Error deleting post in Firestore: {str(e)}"), 500
    except RuntimeError as e:
        exception_found = jsonify(message=f"Unexpected error: {str(e)}"), 500

    if exception_found:
        return exception_found

    return jsonify(message="Post deleted"), 200