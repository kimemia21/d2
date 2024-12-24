import 'package:application/widgets/Firebase/ReqFirebase.dart';
import 'package:application/widgets/commsRepo/commsRepo.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  // Color Palette matching LoginScreen
  final Color primaryColor = const Color(0xFF1A237E);
  final Color secondaryColor = const Color(0xFF4CAF50);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color surfaceColor = Colors.white;
  final Color textColor = const Color(0xFF2C3E50);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> signupBody = {
        "name": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
      };
      // Implement your signup logic here
      // await FirebaseReq.signupEmailPassword(signupBody: signupBody, context: context);
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? 
        (label == 'Confirm Password' ? !_isConfirmPasswordVisible : !_isPasswordVisible) 
        : false,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return "$label can't be empty";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (label == 'Confirm Password' ? _isConfirmPasswordVisible : _isPasswordVisible)
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey[600],
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    if (label == 'Confirm Password') {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    } else {
                      _isPasswordVisible = !_isPasswordVisible;
                    }
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          if (!isSmallScreen)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                    image: AssetImage('images/signup.png'), // Update with your signup image
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          // Signup form
          Expanded(
            flex: isSmallScreen ? 10 : 5,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: ScaleTransition(
                    scale: _animation,
                    child: _buildCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.person_add_outlined,
                                      color: primaryColor),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Create Account',
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        'Sign up to get started',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Name field
                            _buildTextField(
                              label: 'Full Name',
                              controller: _nameController,
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),

                            // Email field
                            _buildTextField(
                              label: 'Email Address',
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            _buildTextField(
                              label: 'Password',
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password field
                            _buildTextField(
                              label: 'Confirm Password',
                              controller: _confirmPasswordController,
                              icon: Icons.lock_outline,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Signup button
                            context.watch<Appbloc>().isloading
                                ? Center(
                                    child: LoadingAnimationWidget.fourRotatingDots(
                                      color: secondaryColor,
                                      size: 50,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _signup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: secondaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                            const SizedBox(height: 16),

                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to login page
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: GoogleFonts.poppins(
                                      color: primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}