"""
Gemini model
"""

from google.api_core.exceptions import GoogleAPICallError
import google.generativeai as genai
from api.config import config


class Gemini:
    """
    Gemini API interaction model
    """

    @staticmethod
    def configure():
        """
        Configure the Gemini API client
        """
        try:
            genai.configure()
        except Exception as e:
            raise RuntimeError(f"Failed to configure Gemini API client: {str(e)}") from e

    @staticmethod
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
        try:
            gemini_model = genai.GenerativeModel(model)
            response = gemini_model.generate_content(prompt)
            return response.text
        except GoogleAPICallError as e:
            raise GoogleAPICallError(
                f"Error generating prompt with Gemini API: {str(e)}"
            ) from e
        except Exception as e:
            raise RuntimeError(f"Unexpected error: {str(e)}") from e
