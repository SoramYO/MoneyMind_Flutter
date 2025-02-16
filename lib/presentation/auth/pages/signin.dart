import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/core/constants/app_colors.dart';
import '../../../common/bloc/button/button_state.dart';
import '../../../common/bloc/button/button_state_cubit.dart';
import '../../../common/widgets/button/basic_app_button.dart';
import '../../../data/models/signin_req_params.dart';
import '../../../domain/usecases/signin.dart';
import '../../../service_locator.dart';
import '../../home/pages/home.dart';
import 'signup.dart';
import '../../../presentation/auth/bloc/auth_state_cubit.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCon = TextEditingController();
  final _passwordCon = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCon.dispose();
    _passwordCon.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => ButtonStateCubit(),
        child: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonSuccessState) {
              context.read<AuthStateCubit>().loggedIn();
              Navigator.pushReplacementNamed(context, '/main');
            }
            if (state is ButtonFailureState) {
              var snackBar = SnackBar(content: Text(state.errorMessage));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 100, right: 16, left: 16),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png',
                          height: 120, width: 120),
                      const SizedBox(height: 16),
                      Text('MoneyMind',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                      const SizedBox(height: 32),
                      _textField(controller: _emailCon, label: 'Email'),
                      const SizedBox(
                        height: 16,
                      ),
                      _passwordField(),
                      const SizedBox(
                        height: 24,
                      ),
                      _loginButton(context),
                      const SizedBox(
                        height: 16,
                      ),
                      _signupText(context),
                      const SizedBox(height: 24),
                      _divider(),
                      const SizedBox(height: 24),
                      _socialButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(
      {required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Vui lòng nhập $label' : null,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordCon,
      decoration: InputDecoration(
        labelText: 'Mật khẩu',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColor),
          onPressed: _togglePasswordVisibility,
        ),
      ),
      obscureText: _obscurePassword,
      validator: (value) =>
          value == null || value.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
    );
  }

  Widget _loginButton(BuildContext context) {
    return Builder(builder: (context) {
      return BasicAppButton(
          title: 'Đăng nhập',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: Xử lý điều hướng sau khi đăng nhập thành công
              context.read<ButtonStateCubit>().excute(
                  usecase: sl<SigninUseCase>(),
                  params: SigninReqParams(
                      email: _emailCon.text, password: _passwordCon.text));
            }
          });
    });
  }

  Widget _divider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Hoặc đăng ký với',
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _signupText(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        const TextSpan(
            text: "Chưa có tài khoản?",
            style:
                TextStyle(color: AppColors.text, fontWeight: FontWeight.w500)),
        TextSpan(
            text: ' Đăng ký ngay',
            style: const TextStyle(
                color: AppColors.success, fontWeight: FontWeight.w500),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupPage(),
                    ));
              })
      ]),
    );
  }

  Widget _socialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton('assets/images/google.png', () {}),
        const SizedBox(width: 24),
        _buildSocialButton('assets/images/facebook.png', () {}),
      ],
    );
  }

  Widget _buildSocialButton(String iconPath, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(iconPath, height: 24, width: 24),
      ),
    );
  }
}
