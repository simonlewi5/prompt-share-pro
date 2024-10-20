package com.example.android.network.auth.signup;

import com.example.android.models.auth.signup.SignupRequest;
import com.example.android.models.auth.signup.SignupResponse;
import com.example.android.network.retrofit.RetrofitClient;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class SignupRepository {

    private final SignupService signupService;

    public SignupRepository() {
        signupService = RetrofitClient.getClient().create(SignupService.class);
    }

    public void signup(SignupRequest signupRequest, final SignupCallback callback) {
        Call<SignupResponse> call = signupService.signupUser(signupRequest);
        call.enqueue(new Callback<SignupResponse>() {
            @Override
            public void onResponse(Call<SignupResponse> call, Response<SignupResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    callback.onSuccess(response.body());
                } else {
                    callback.onError(new Throwable("Signup failed"));
                }
            }

            @Override
            public void onFailure(Call<SignupResponse> call, Throwable t) {
                callback.onError(t);
            }
        });
    }

    public interface SignupCallback {
        void onSuccess(SignupResponse signupResponse);

        void onError(Throwable throwable);
    }
}
