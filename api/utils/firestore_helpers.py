"""
Firestore helper functions.
"""

from google.cloud import firestore
from google.api_core.exceptions import NotFound


@staticmethod
def get_db():
    """
    Get Firestore client
    """
    return firestore.Client()


def get_document_or_raise(collection_name, doc_id):
    """
    Get a document from Firestore or raise a NotFound error if it doesn't exist
    """
    db = get_db()
    doc_ref = db.collection(collection_name).document(doc_id)
    doc = doc_ref.get()
    if not doc.exists:
        raise NotFound(f"404 {collection_name[:-1].capitalize()} not found")
    return doc


def fetch_collection_items(parent_doc, collection_name):
    """
    Fetch all items in a Firestore collection
    """
    items_ref = parent_doc.reference.collection(collection_name).stream()
    return [{"id": item.id, **item.to_dict()} for item in items_ref]
