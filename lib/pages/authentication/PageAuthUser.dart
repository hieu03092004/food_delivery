
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:food_delivery/helpers/supabase_helper.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/widget/dialog.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:get/get.dart';
AuthResponse? response;
class PageAuthUser extends StatelessWidget {
  const PageAuthUser({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();

    return Scaffold(
        appBar: AppBar(
          title: Text("Sign in"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SupaEmailAuth(
                  onSignInComplete: (res) async{
                    response = res;

                    // Gọi handleSignIn nếu có session và user
                    final session = Supabase.instance.client.auth.currentSession;
                    if (session != null && session.user != null) {
                      await auth.handleSignIn(session.user.id);
                    }
                  },
                  onSignUpComplete: (response) {
                    if(response.user != null)
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => PageVerifyOTP(email: response.user!.email!),)
                      );
                  },

                  showConfirmPasswordField: true,

                  metadataFields: [
                    MetaDataField(
                      prefixIcon: const Icon(Icons.person),
                      label: 'Username',
                      key: 'username',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter something';
                        }
                        return null;
                      },
                    ),

                    BooleanMetaDataField(
                      label: 'I wish to receive marketing emails',
                      key: 'marketing_consent',
                      checkboxPosition: ListTileControlAffinity.leading,
                    ),
                    // Supports interactive text. Fields can be marked as required, blocking form
                    // submission unless the checkbox is checked.
                    BooleanMetaDataField(
                      key: 'terms_agreement',
                      isRequired: true,
                      checkboxPosition: ListTileControlAffinity.leading,
                      richLabelSpans: [
                        const TextSpan(
                            text: 'I have read and agree to the '),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // do something, for example: navigate("terms_and_conditions");
                            },
                        ),
                      ],
                    ),
                  ]),
            ],
          ),
        )
    );
  }
}
class PageVerifyOTP extends StatelessWidget {
  const PageVerifyOTP({
    super.key,
    required this.email,
  });
  final String email;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Xác thực OTP"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OtpTextField(
            numberOfFields: 6,
            borderColor: Color(0xFF512DA8),
            //set to true to show as box or false to show as dash
            showFieldAsBox: true,
            //runs when a code is typed in
            onCodeChanged: (String code) {
              //handle validation or checks here
            },
            //runs when every textfield is filled
            onSubmit: (String verificationCode) async{
              response = await Supabase.instance.client.auth.verifyOTP(
                type: OtpType.email,
                email: email,
                token: verificationCode,
              );
              if(response?.session != null && response?.user != null){
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => PageInfoCustomer()),(route) => false
                );
              }
              ;}, // end onSubmit
          ),
          SizedBox(height: 50,),
          ElevatedButton(
              onPressed: () async{
                showSnackBar(context, messages: "Đang gửi mã OTP", second: 600);
                final response = await supabase.auth.signInWithOtp(
                  email: email,
                );
                showSnackBar(context, messages: "Mã OTP đã gửi vào ${email} của banj", second: 3);
              },
              child: Text("Gửi lại mã OTP")),
        ],
      ),
    );
  }
}



class PageInfoCustomer extends StatefulWidget {
  const PageInfoCustomer({super.key});

  @override
  State<PageInfoCustomer> createState() => _PageInfoCustomerState();
}

class _PageInfoCustomerState extends State<PageInfoCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông tin khách hàng"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
    );
  }
}
