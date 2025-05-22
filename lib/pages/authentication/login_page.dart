import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/pages/authentication/bloc/login_cubit.dart';
import 'package:food_delivery/domains/authentication_respository/authentication_respository.dart';

import 'authenticaion_state/authenticationCubit.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      //backgroundColor: const Color(0xffef2b39),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);

            },
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              size: 18,
              color: Colors.white,
            )
        ),
      ),
      body: BlocProvider(
        create: (context) {
          // 1. Lấy đúng repository từ context
          final authRepo = context.read<AuthenticationRepository>();
          // 2. Lấy AuthenticationCubit từ context
          final authCubit = context.read<AuthenticationCubit>();
          // 3. Khởi tạo LoginCubit với cả hai tham số cần thiết
          return LoginCubit(
            authenticationRepository: authRepo,
            authenticationCubit: authCubit,
          );
        },
        child: const LoginView(),
      )
    );
  }
}
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final  _formKey=GlobalKey<FormState>();
  var _emailTextController=TextEditingController();
  var _passwordTextController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          print('Đăng nhập thành công với roleName: ${state.roleName}, storeId: ${state.storeId}');
          switch (state.roleName) {
            case 'admin':
              Navigator.pushReplacementNamed(
                context,
                '/adminHome',
                arguments: state.storeId,
              );
              break;
            case 'shipper':
              Navigator.pushReplacementNamed(
                context,
                '/shipperHome',
                arguments: state.storeId,
              );
              break;
            case 'customer':
            default:
              Navigator.pushReplacementNamed(context, '/customerHome');
          }
        }

        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message))
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageTitle(),
              const SizedBox(height: 53),
              _buildLoginForm(),
              _buildOrdSplitDivider(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPageTitle(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(top:40),
      child:
      Text("Login",
        style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoginForm(){
    return Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserNameField(),
              SizedBox(height: 20,),
              _buildPasswordField(),
              _buildLoginButton(),
            ],
          ),
        )
    );
  }

  Widget _buildUserNameField(){
    return Container(
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Username",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Lato",
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: _emailTextController,
                  decoration: InputDecoration(
                      hintText: "Enter your Username",
                      hintStyle: TextStyle(
                        color: Color(0xFF535353),
                        fontSize: 16,
                        fontFamily: "Lato",
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      )
                  ),
                  validator: (String ?value){
                    if(value==null || value.isEmpty)
                      return "Email is required";//Yeu cau nhap email
                    return null;
                  },
                ),
              )
            ],
          )

        ],
      ),
    );
  }

  Widget _buildPasswordField(){
    return Container(
      child: Column(

        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Password",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Lato",
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: _passwordTextController,
                  decoration: InputDecoration(
                      hintText: "********",
                      hintStyle: TextStyle(
                        color: Color(0xFF535353),
                        fontSize: 16,
                        fontFamily: "Lato",
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      )
                  ),
                  validator: (String ?value){
                    if(value==null || value.isEmpty)
                      return "Password không thể trống";
                    if(value.length<6)
                      return "Password phải có 6 kí tự trở lên";
                    return null;
                  },
                  style: const TextStyle(
                    fontFamily:"Lato",
                    fontSize: 16,
                  ),
                  obscureText: true,
                ),

              )
            ],
          )

        ],
      ),
    );
  }

  Widget _buildLoginButton(){
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(top: 70),
      child: ElevatedButton(
        onPressed: _onHandleLoginSubmit,
        style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffef2b39),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            disabledBackgroundColor: Color(0xFF8687E7).withOpacity(0.5)
        ),
        child: Text("Login",style: TextStyle(fontSize: 16,fontFamily: "Lato",color: Colors.white),),

      ),
    );
  }

  Widget _buildOrdSplitDivider(){
    return Container(
      margin: const EdgeInsets.only(top: 45,bottom: 40),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              width: double.infinity,
              color:Color(0xFF979797),

            ),
          ),
          Text("or",
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Lato",
              color: Color(0xFF979797),

            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              width: double.infinity,
              color:Color(0xFF979797),

            ),
          ),
        ],
      ),
    );
  }
  void _onHandleLoginSubmit(){
    final loginCubit=BlocProvider.of<LoginCubit>(context);
    final email=_emailTextController.text;
    final password=_passwordTextController.text;
    loginCubit.login(email, password);
    return;
    final isValid=_formKey.currentState?.validate()??false;
    if(isValid){
      //Call API login,Call fireBaseLogin
    }
    else{
      //khong lam gi
    }

  }
}

