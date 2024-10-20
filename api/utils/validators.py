def is_valid_usc_email(email):
    return email.endswith('@usc.edu')

def is_valid_usc_id(usc_id):
    return usc_id.isdigit() and len(usc_id) == 10