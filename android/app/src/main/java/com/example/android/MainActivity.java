package com.example.android;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.example.android.models.auth.login.LoginRequest;
import com.example.android.models.auth.signup.SignupRequest;
import com.example.android.network.auth.login.LoginRepository;
import com.example.android.network.auth.signup.SignupRepository;

public class MainActivity extends AppCompatActivity {

    private EditText emailEditText, passwordEditText, uscIdEditText;
    private Button loginButton, signupButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        emailEditText = findViewById(R.id.emailEditText);
        passwordEditText = findViewById(R.id.passwordEditText);
        uscIdEditText = findViewById(R.id.uscIdEditText); // Only used for signup
        loginButton = findViewById(R.id.loginButton);
        signupButton = findViewById(R.id.signupButton);

        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                login();
            }
        });

        signupButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                signup();
            }
        });
    }

    private void login() {
        String email = emailEditText.getText().toString();
        String password = passwordEditText.getText().toString();

        LoginRequest loginRequest = new LoginRequest(email, password);
        LoginRepository loginRepository = new LoginRepository();
        loginRepository.login(loginRequest, new LoginRepository.LoginCallback() {
            @Override
            public void onSuccess(com.example.android.models.auth.login.LoginResponse loginResponse) {
                Toast.makeText(MainActivity.this, "Login successful!", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onError(Throwable throwable) {
                Log.e("MainActivity", "Login error: ", throwable);
                Toast.makeText(MainActivity.this, "Login failed: " + throwable.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void signup() {
        String email = emailEditText.getText().toString();
        String password = passwordEditText.getText().toString();
        String uscId = uscIdEditText.getText().toString();

        SignupRequest signupRequest = new SignupRequest(uscId, email, password);
        SignupRepository signupRepository = new SignupRepository();
        signupRepository.signup(signupRequest, new SignupRepository.SignupCallback() {
            @Override
            public void onSuccess(com.example.android.models.auth.signup.SignupResponse signupResponse) {
                Toast.makeText(MainActivity.this, "Signup successful!", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onError(Throwable throwable) {
                Log.e("MainActivity", "Signup error: ", throwable);
                Toast.makeText(MainActivity.this, "Signup failed: " + throwable.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }
}
