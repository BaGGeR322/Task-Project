import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/screens/news_screen.dart';

import '../pickers/user_image_picker.dart';
import '../../helpers/dbhelper.dart';
import '../../providers/user.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
    'userName': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  File? _userImageFile;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occured!'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _isLoadingIsFalse() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    final dbUsers = await DBHelper.getData(DataBase.users);
    if (_authMode == AuthMode.Login) {
      // Log user in
      if (dbUsers == null ||
          dbUsers
              .firstWhere(
                (elem) => elem['email'] == _authData['email']!,
                orElse: () => {},
              )
              .isEmpty) {
        _isLoadingIsFalse();
        _showErrorDialog('Could not find a user with that email.');
        return;
      } // DONE
      if (dbUsers.firstWhere(
            (elem) => elem['email'] == _authData['email']!,
            orElse: () => {},
          )['password'] !=
          _authData['password']!) {
        _isLoadingIsFalse();
        _showErrorDialog('Invalid password.');
        return;
      } // DONE
    } else {
      // Sign user up
      if (dbUsers != null && dbUsers
          .firstWhere(
            (elem) => elem['email'] == _authData['email']!,
            orElse: () => {},
          )
          .isNotEmpty) {
        _isLoadingIsFalse();
        _showErrorDialog('This email address is already in use.');
        return;
      } // DONE
      if (_userImageFile == null) {
        _isLoadingIsFalse();
        _showErrorDialog('Please, take a photo!');
        return;
      } //DONE

      await Provider.of<UserLogInOrSignUp>(context, listen: false).signup(
        _authData['email']!,
        _authData['password']!,
        _authData['userName']!,
        _userImageFile!,
      );
    }
    _isLoadingIsFalse();
    Navigator.pushReplacementNamed(context, NewsScreen.routeName,
        arguments: _authData['email']);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                  maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: UserImagePicker(
                      _pickedImage,
                    ),
                  ),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['email'] = value!;
                },
              ),
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                  maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration: const InputDecoration(labelText: 'Username'),
                      keyboardType: TextInputType.name,
                      autocorrect: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value!.isEmpty) {
                                return 'Enter username!';
                              }
                              return null;
                            }
                          : null,
                      onSaved: (value) {
                        _authData['userName'] = value!;
                      },
                    ),
                  ),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value!.isEmpty || value.length < 5) {
                    return 'Password is too short!';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['password'] = value!;
                },
              ),
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                  maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  child:
                      Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8.0),
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Theme.of(context).primaryTextTheme.button?.color,
                  ),
                ),
              TextButton(
                child: Text(
                    '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                onPressed: _switchAuthMode,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  primary: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
