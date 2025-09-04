import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Flag para mostrar/ocultar password en front
  bool _obscureTextFlag = true;

  // Cerebro de la logica de animaciones
  StateMachineController? controller;

  // StateMachineInput
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess; // Se emociona
  SMITrigger? trigFail; // Se pone sad
  SMINumber? numLook;
  
  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la pantalla del dispositivo
    final Size size = MediaQuery.of(context).size;

    return Scaffold( //Widget para crear la estructura basica de una pantalla
      //SafeArea para evitar que los elementos se superpongan con la barra de estado o la barra de navegación
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 200),
          child: Column(
            //Axis o eje vertical
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animacion
              SizedBox(
                //Ancho de la pantalla calculado por MediaQuery
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(artboard, "Login Machine");
                    // Verifica si hay un controlador
                    if (controller == null) return;

                    // Agregar el controlador al tablero
                    artboard.addController(controller!);

                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('isChecktrigFailking');
                  },
                  ),
                ),
              // Separacion
              const SizedBox( 
                height: 10,
              ),
              // Email
              TextField(
                onChanged: (value) {
                  if (isHandsUp != null) {
                    isHandsUp!.change(false); // no subir manos en email
                  }
                  if (isChecking != null) {
                    isChecking!.change(true); // activar osito chismoso
                  }

                  // mover ojos según cantidad de letras
                  if (numLook != null) {
                    numLook!.value = value.length.toDouble();
                  }
                },
                keyboardType: TextInputType.emailAddress, // Para mostrar opciones de correo electronico
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
              ),
              // Separacion
              const SizedBox(height: 10),
              // Password
              TextField(
                onChanged: (value) {
                  if (isChecking != null) {
                    isChecking!.change(false);
                  }

                  if (isHandsUp == null) return;
                  isHandsUp!.change(true);
                },
                obscureText: _obscureTextFlag,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.password),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureTextFlag = !_obscureTextFlag;
                      });
                    },
                    icon: Icon (
                      _obscureTextFlag ? Icons.visibility : Icons.visibility_off
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: size.width, 
                child: const Text(
                  "Forgot your password?",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    decoration: TextDecoration.underline
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Boton de log-in
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                onPressed: () {},
                child: const Text(
                  "login",
                  style: TextStyle(color: Colors.white),
                  )
              ),

              const SizedBox(height: 10),
              
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                      )
                    )
                ],
                ),
              )
             ],
          ),
        ),
      ),
    );
  }
}