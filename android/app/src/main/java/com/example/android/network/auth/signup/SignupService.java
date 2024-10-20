package com.example.android.network.auth.signup;

import com.example.android.models.auth.signup.SignupRequest;
import com.example.android.models.auth.signup.SignupResponse;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;

public interface SignupService {
    @POST("/signup")
    Call<SignupResponse> signupUser(@Body SignupRequest signupRequest);
}
