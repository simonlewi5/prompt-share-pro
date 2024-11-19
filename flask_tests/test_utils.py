"""
Tests for the utility functions in the api.utils module
"""

from api.utils.validators import is_valid_usc_email


def test_is_valid_usc_email():
    """
    Tests the is_valid_usc_email function
    """
    assert is_valid_usc_email("student@usc.edu")
    assert not is_valid_usc_email("not-a-usc-email@gmail.com")
