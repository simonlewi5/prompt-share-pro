// Have to turn off SSL verification even though the api is using a valid
// cert, possible because the emulator is using an old version of the Android
// API
//package com.example.android.network.retrofit;
//
//import retrofit2.Retrofit;
//import retrofit2.converter.gson.GsonConverterFactory;
//
//public class RetrofitClient {
//
//    private static Retrofit retrofit = null;
//    private static final String BASE_URL = "https://www.promptsharepro24.com";
//
//    public static Retrofit getClient() {
//        if (retrofit == null) {
//            retrofit = new Retrofit.Builder()
//                    .baseUrl(BASE_URL)
//                    .addConverterFactory(GsonConverterFactory.create())
//                    .build();
//        }
//        return retrofit;
//    }
//}

package com.example.android.network.retrofit;

import android.annotation.SuppressLint;

import java.security.cert.X509Certificate;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import okhttp3.OkHttpClient;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class RetrofitClient {

    private static Retrofit retrofit = null;
    private static final String BASE_URL = "https://www.promptsharepro24.com";

    public static Retrofit getClient() {
        if (retrofit == null) {
            try {
                @SuppressLint("CustomX509TrustManager") TrustManager[] trustAllCerts = new TrustManager[]{
                        new X509TrustManager() {
                            @SuppressLint("TrustAllX509TrustManager")
                            @Override
                            public void checkClientTrusted(X509Certificate[] chain, String authType) {}

                            @SuppressLint("TrustAllX509TrustManager")
                            @Override
                            public void checkServerTrusted(X509Certificate[] chain, String authType) {}

                            @Override
                            public X509Certificate[] getAcceptedIssuers() {
                                return new X509Certificate[]{};
                            }
                        }
                };

                SSLContext sslContext = SSLContext.getInstance("SSL");
                sslContext.init(null, trustAllCerts, new java.security.SecureRandom());

                OkHttpClient.Builder clientBuilder = new OkHttpClient.Builder();
                clientBuilder.sslSocketFactory(sslContext.getSocketFactory(), (X509TrustManager) trustAllCerts[0]);

                clientBuilder.hostnameVerifier((hostname, session) -> true);

                OkHttpClient okHttpClient = clientBuilder.build();

                retrofit = new Retrofit.Builder()
                        .baseUrl(BASE_URL)
                        .client(okHttpClient)
                        .addConverterFactory(GsonConverterFactory.create())
                        .build();
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        return retrofit;
    }
}