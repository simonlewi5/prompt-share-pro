package com.example.android.models.auth.signup;

public class SignupRequest {
    private String uscId;
    private String email;
    private String password;

    public SignupRequest(String uscId, String email, String password) {
        this.uscId = uscId;
        this.email = email;
        this.password = password;
    }

    public String getUscId() {
        return uscId;
    }

    public void setUscId(String uscId) {
        this.uscId = uscId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
