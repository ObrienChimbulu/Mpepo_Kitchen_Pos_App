import 'package:flutter/material.dart';
import 'package:mpepo_kitchen_pos_app/utils/constants/colors.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'products_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TColors.primary.withOpacity(0.1),
              Colors.white,
              TColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  SizedBox(height: 48),
                  _buildLoginCard(),
                  SizedBox(height: 24),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: TColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.restaurant,
            size: 60,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Mpepo Kitchen POS',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: TColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 8,
        shadowColor: TColors.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  _buildError(),
                  SizedBox(height: 24),
                ],
                _buildUsernameField(),
                SizedBox(height: 20),
                _buildPasswordField(),
                SizedBox(height: 32),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.person, color: TColors.primary, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.lock, color: TColors.primary, size: 20),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildError() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: _isLoading
              ? [Colors.grey[400]!, Colors.grey[400]!]
              : [TColors.primary, TColors.primary.withOpacity(0.8)],
        ),
        boxShadow: _isLoading
            ? []
            : [
          BoxShadow(
            color: TColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : Text(
          'SIGN IN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(
            'Sign up',
            style: TextStyle(
              color: TColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final authController = Provider.of<AuthController>(context, listen: false);
        await authController.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductsScreen()),
        );
      } catch (e) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }
}