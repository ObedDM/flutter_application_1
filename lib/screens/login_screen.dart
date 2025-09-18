import 'dart:async'; // 👈 Necesario para Timer
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StateMachineController? controller;
  SMIBool? isChecking; // Oso mirando/bajando ojos
  SMIBool? isHandsUp; // Oso tapándose los ojos
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  SMIInput? numLook;

  bool isPasswordVisible = false;

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final TextEditingController passwordController = TextEditingController();

  Timer? _debounce; // 👈 Timer para debounce

  String password = '1234';

  @override
  void initState() {
    super.initState();
    // Al iniciar, poner foco en email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(emailFocus);
    });

     // 👇 Listener para passwordFocus
    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) {
        // Al entrar al password se tapa los ojos
        if (isChecking != null) isChecking!.change(false);
        if (isHandsUp != null) isHandsUp!.change(true);
      } else {
        // Al salir del password destapa los ojos
        if (isHandsUp != null) isHandsUp!.change(false);
      }
    });
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // 👇 Función debounce genérica
  void _onEmailTyping(String value) {
    // mover los ojos según el largo del texto
    if (numLook != null) {
      numLook!.value = value.length.toDouble();
    }

    // 👀 mientras escribe, activa checking
    if (isChecking != null) isChecking!.change(true);
    if (isHandsUp != null) isHandsUp!.change(false);

    // Reiniciar el timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 1), () {
      // ⏳ Después de 1s sin escribir → ojos arriba
      if (isChecking != null) isChecking!.change(false);
    });
  }

  bool checkPassword(String passwordInput) {
    if (passwordInput == password) {
      return true;
    }

    else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    if (controller == null) return;
                    artboard.addController(controller!);
                    numLook = controller!.findSMI("numLook");
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                  },
                ),
              ),
              const SizedBox(height: 10),

              // EMAIL FIELD
              TextField(
                focusNode: emailFocus,
                onTap: () {
                  FocusScope.of(context).requestFocus(emailFocus);
                  // 👀 Al tocar email, baja los ojos
                  if (isHandsUp != null) isHandsUp!.change(false);
                  if (isChecking != null) isChecking!.change(true);
                },
                onChanged: _onEmailTyping, // 👈 debounce aquí
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // PASSWORD FIELD
              TextField(
                controller: passwordController,
                focusNode: passwordFocus,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: size.width,
                child: const Text(
                  "Forgot your Password?",
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 10),

              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus(); // Cierra teclado

                  bool isValid = checkPassword(passwordController.text);

                  if (isValid) {
                    trigSuccess?.fire();
                  }

                  else {
                    trigFail?.fire();
                  }
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}