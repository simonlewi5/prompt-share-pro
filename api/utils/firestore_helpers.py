"""
Firestore helper functions.
"""

from google.cloud import firestore
from google.api_core.exceptions import NotFound


def get_document_or_raise(collection_name, doc_id):
    """
    Get a document from Firestore or raise a NotFound error if it doesn't exist
    """
    db = firestore.Client()
    doc_ref = db.collection(collection_name).document(doc_id)
    doc = doc_ref.get()
    if not doc.exists:
        raise NotFound(
            f"Document with ID {doc_id} not found in collection {collection_name}."
        )
    return doc
