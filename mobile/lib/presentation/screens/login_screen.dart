
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: controller),
            SizedBox(height: 20),
            auth.loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      await auth.login(controller.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                    child: Text("Login"),
                  )
          ],
        ),
      ),
    );
  }
}
