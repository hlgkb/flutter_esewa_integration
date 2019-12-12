package com.pagal101.flutter_esewa_integration;

import com.esewa.android.sdk.payment.ESewaConfiguration;
import com.esewa.android.sdk.payment.ESewaPayment;


class PaymentOptionsConfig {

    // Esewa Test
    private static final String CONFIG_ENVIRONMENT = ESewaConfiguration.ENVIRONMENT_TEST;
    private static final String MERCHANT_ID = "BxwRAw0WGEUMFUkrJ0w2OEg8KyUgOTU=";
    private static final String MERCHANT_SECRET_KEY = "BhwIWQQdHQAXEV0HGBUHBwAKEANLBxMc";

    // Esewa Production
    //private static final String CONFIG_ENVIRONMENT = ESewaConfiguration.ENVIRONMENT_PRODUCTION;
    //private static final String MERCHANT_ID = "production_key";
    //private static final String MERCHANT_SECRET_KEY = "production_secret_key";


    static ESewaConfiguration getEsewaConfig() {
        return new ESewaConfiguration()
                .clientId(MERCHANT_ID)
                .secretKey(MERCHANT_SECRET_KEY)
                .environment(CONFIG_ENVIRONMENT);
    }

    static  ESewaPayment getEsewaPayment(String productName, String pid, float amount) {
        return new ESewaPayment(String.valueOf(amount), productName, pid, "");
    }

    static ESewaPayment getEsewaPayment(String productName, String pid, float amount, String callbackUrl) {
        return new ESewaPayment(String.valueOf(amount),
                productName,
                pid,
                callbackUrl
                );
    }




}