package com.pagal101.flutter_esewa_integration;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterMain;

import com.esewa.android.sdk.payment.ESewaConfiguration;
import com.esewa.android.sdk.payment.ESewaPayment;
import com.esewa.android.sdk.payment.ESewaPaymentActivity;

import java.util.HashMap;
import android.content.Intent;
import java.util.UUID;


public class MainActivity extends FlutterActivity {
  private final String CHANNEL = "pagal101/payment";
  private final int REQUEST_CODE_PAYMENT = 1;

  private MethodChannel.Result result;
  private MethodChannel methodChannel;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    methodChannel = new MethodChannel(this.getFlutterView(), CHANNEL);
    methodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      public final void onMethodCall(MethodCall methodCall, MethodChannel.Result _result) {
        result = _result;
        if (methodCall.method.equals("payViaEsewa")) {
          eSewaPaymentPortal((HashMap<String, String>) methodCall.arguments);
        } else {
          _result.notImplemented();
        }
      }
    });
  }

  private void eSewaPaymentPortal(HashMap<String, String> arguments) {
    ESewaConfiguration eSewaConfiguration = PaymentOptionsConfig.getEsewaConfig();
    ESewaPayment eSewaPayment;

    // Generate random pid for eSewa
    String pid = UUID.randomUUID().toString();
    Float amount = Float.valueOf(arguments.get("amount"));
    eSewaPayment = PaymentOptionsConfig.getEsewaPayment(arguments.get("productName"), pid, amount);

    if (arguments.containsKey("callbackUrl")) {
      eSewaPayment = PaymentOptionsConfig.getEsewaPayment(arguments.get("productName"), pid, amount, arguments.get("callbackUrl"));
    }

    Intent intent = new Intent(this, ESewaPaymentActivity.class);
    intent.putExtra(ESewaConfiguration.ESEWA_CONFIGURATION, eSewaConfiguration);
    intent.putExtra(ESewaPayment.ESEWA_PAYMENT, eSewaPayment);
    startActivityForResult(intent, REQUEST_CODE_PAYMENT);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    if (requestCode == REQUEST_CODE_PAYMENT) {
      if (resultCode == RESULT_OK) {
        String s = data.getStringExtra(ESewaPayment.EXTRA_RESULT_MESSAGE);
        this.methodChannel.invokeMethod("eSewa#success", s);
      } else if (resultCode == RESULT_CANCELED) {
        this.methodChannel.invokeMethod("eSewa#cancled", "Cancled by User.");
      } else if (resultCode == ESewaPayment.RESULT_EXTRAS_INVALID) {
        String s = data.getStringExtra(ESewaPayment.EXTRA_RESULT_MESSAGE);
        this.methodChannel.invokeMethod("eSewa#error", s);
      }
    }
  }
}
