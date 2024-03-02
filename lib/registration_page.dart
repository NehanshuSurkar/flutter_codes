import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_codes/login_details.dart";
import "package:flutter_codes/main.dart";

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _Registration();
}

class _Registration extends State<Registration> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  register(String email, String password) async {
    if (email == "" && password == "") {
      LoginDetails.Alertbox(context, 'Enter Required fields');
    } else {
      UserCredential? usercredential;
      try {
        usercredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Home()));
          print(usercredential);
        });
      } on FirebaseAuthException catch (ex) {
        return LoginDetails.Alertbox(context, ex.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Schedulo App"),
          titleTextStyle: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(206, 129, 89, 238),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Image.network(
                'https://cdni.iconscout.com/illustration/premium/thumb/forgot-password-6869766-5628002.png',
                height:
                    250, // Aap apni pasand ke anusaar height aur width set kar sakte hain
                width: double
                    .infinity, // Yeh image ka width screen ke width ke barabar hogi
                fit: BoxFit
                    .cover, // Yeh image ko container ke saath fit karne ke liye hai
              ),
              const Text('Registration',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(206, 129, 89, 238),
                  )),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginDetails.CustomTextField(
                      emailController, 'Email', Icons.email, false),
                  LoginDetails.CustomTextField(
                      passwordController, 'Password', Icons.password, false),
                  const SizedBox(height: 30),
                  LoginDetails.LoginButton(() {
                    register(emailController.text.toString(),
                        passwordController.text.toString());
                  }, 'Register')
                ],
              ),
            ],
          ),
        ));
  }
}
