"""
Gemini model
"""

import os
import logging
import google.generativeai as genai
from api.utils.error_handler import handle_firestore_exceptions


class Gemini:
    """
    Gemini API interaction model
    """

    @staticmethod
    def configure():
        """
        Configure the Gemini API client
        """
        logging.debug("Starting Gemini API client configuration.")
        if not os.environ.get("GCP_API_KEY"):
            logging.error("GCP_API_KEY is not set. Cannot configure Gemini API.")
            raise RuntimeError("GCP_API_KEY is not set. Cannot configure Gemini API.")
        genai.configure(api_key=os.environ.get("GCP_API_KEY"))

    @staticmethod
    @handle_firestore_exceptions
    def generate_prompt(prompt, model="gemini-1.5-flash"):
        """
        Generate content using the Gemini API.
        Args:
            prompt (str): The prompt to send to the model.
            model (str): The Gemini model to use.
        Raises:
            GoogleAPICallError: If an error occurs while calling the Gemini API.
            RuntimeError: For any other unexpected errors.
        Returns:
            str: The generated content.
        """
        gemini_model = genai.GenerativeModel(model)
        response = gemini_model.generate_content(prompt)
        return response.text
