import 'package:air/Pages/dash_board_page.dart';
import 'package:air/Pages/home_page.dart';
import 'package:air/auth/sign_up_page.dart';
import 'package:air/services/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isEmailForm = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _duration = const Duration(milliseconds: 300);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Future<void> _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       final user = await FirebaseAuthMethod.signIn(
  //         email: emailController.text.trim(),
  //         password: passwordController.text.trim(),
  //       );

  //       if (user != null) {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => const DashBoardPage()),
  //         );
  //       } else {
  //         _showError("Invalid credentials");
  //       }
  //     } catch (e) {
  //       _showError(e.toString());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            // height: MediaQuery.sizeOf(context).height * 0.3,
            decoration: const BoxDecoration(
              // Add const
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/pexels-alexander-dummer-37646-1919030.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height *
                0.5, // Use .of(context).size instead of sizeOf
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20.0), // Add const
            decoration: BoxDecoration(
              // Add const
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Form(
              // Wrap with Form widget
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    // Add const
                    child: Icon(
                      Boxicons.bxl_google,
                      size: 50.0,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      // Add const
                      Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Continue to Google',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  AnimatedSwitcher(
                    duration: _duration,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: TextFormField(
                      key: ValueKey(isEmailForm),
                      controller:
                          isEmailForm ? emailController : passwordController,
                      obscureText: !isEmailForm,
                      decoration: InputDecoration(
                        labelText: isEmailForm
                            ? 'Email Address'
                            : 'Password', // Use labelText instead of label
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: isEmailForm
                          ? TextInputType.emailAddress
                          : TextInputType.text, // Add conditional keyboard type
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isEmailForm
                              ? 'Please enter your email'
                              : 'Please enter your password';
                        }
                        if (isEmailForm &&
                            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        if (!isEmailForm && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: _duration,
                    child: Center(
                      key: ValueKey(isEmailForm), // Important for animation
                      child: TextButton(
                        onPressed: () {},
                        child: Text(isEmailForm
                            ? 'Forget Account?'
                            : 'Forget Password?'),
                      ),
                    ),
                  ),
                  FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40.0),
                      ),
                      onPressed: () {
                        if (isEmailForm) {
                          setState(() {
                            isEmailForm = false;
                          });
                        } else {
                          _login(); // Properly call the _login function
                        }
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white70,
                            ) // Added const
                          : Text(isEmailForm ? 'Next' : 'Login')),
                  const SizedBox(
                    height: 20.00,
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(color: Colors.teal),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SignUpPage(), // Your SignUpPage widget
                                  ),
                                );
                              },
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuthMethod.auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashBoardPage()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred during login';
        isEmailForm = true;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                       .hasMatch(value)) {
//                     return 'Please enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 24),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _login,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 32, vertical: 12),
//                         child: Text('Login'),
//                       ),
//                     ),
//               SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/signup');
//                 },
//                 child: Text('New user? Sign up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//         );
//         Navigator.pushReplacementNamed(context, '/home');
//       } on FirebaseAuthException catch (e) {
//         String errorMessage = 'An error occurred during login';
//         if (e.code == 'user-not-found') {
//           errorMessage = 'No user found with this email';
//         } else if (e.code == 'wrong-password') {
//           errorMessage = 'Incorrect password';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login failed: $e')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
// }
