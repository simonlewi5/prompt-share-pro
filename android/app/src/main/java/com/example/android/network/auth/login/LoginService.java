package com.example.android.network.auth.login;

import com.example.android.models.auth.login.LoginRequest;
import com.example.android.models.auth.login.LoginResponse;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;

public interface LoginService {
    @POST("/login")
    Call<LoginResponse> loginUser(@Body LoginRequest loginRequest);
}
