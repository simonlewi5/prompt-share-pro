"""
Application configuration
"""
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Base configuration."""
    def __init__(self):
        pass

    def __str__(self):
        return "Config()"

    def __repr__(self):
        return "Config()"

    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'secret-key')
    DEBUG = False
    TESTING = False

config = Config()
