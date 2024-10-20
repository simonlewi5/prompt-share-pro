package com.example.android.network.auth.login;

import com.example.android.models.auth.login.LoginRequest;
import com.example.android.models.auth.login.LoginResponse;
import com.example.android.network.retrofit.RetrofitClient;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class LoginRepository {

    private final LoginService loginService;

    public LoginRepository() {
        loginService = RetrofitClient.getClient().create(LoginService.class);
    }

    public void login(LoginRequest loginRequest, final LoginCallback callback) {
        Call<LoginResponse> call = loginService.loginUser(loginRequest);
        call.enqueue(new Callback<LoginResponse>() {
            @Override
            public void onResponse(Call<LoginResponse> call, Response<LoginResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    callback.onSuccess(response.body());
                } else {
                    callback.onError(new Throwable("Login failed"));
                }
            }

            @Override
            public void onFailure(Call<LoginResponse> call, Throwable t) {
                callback.onError(t);
            }
        });
    }

    public interface LoginCallback {
        void onSuccess(LoginResponse loginResponse);

        void onError(Throwable throwable);
    }
}
