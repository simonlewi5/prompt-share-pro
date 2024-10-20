package com.example.android.network.retrofit;

import com.example.android.network.auth.login.LoginService;
import com.example.android.network.auth.signup.SignupService;

public class ApiService {

    private static ApiService instance;
    private final LoginService loginService;
    private final SignupService signupService;

    private ApiService() {
        loginService = RetrofitClient.getClient().create(LoginService.class);
        signupService = RetrofitClient.getClient().create(SignupService.class);
    }

    public static ApiService getInstance() {
        if (instance == null) {
            instance = new ApiService();
        }
        return instance;
    }

    public LoginService getLoginService() {
        return loginService;
    }

    public SignupService getSignupService() {
        return signupService;
    }
}
