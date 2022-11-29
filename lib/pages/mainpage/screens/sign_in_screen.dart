import 'package:arthurmorgan/providers/auth_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Hi There,",
            style: TextStyle(color: Color.fromARGB(255, 177, 173, 169)),
          ),
          Text(
              "You need to sign-in using your Google Account to connect this app with your GDrive.",
              style: TextStyle(color: Color.fromARGB(255, 177, 173, 169))),
          SizedBox(
            height: 10,
          ),
          FilledButton(
            child: const Text("Sign in with Google Account"),
            onPressed: () => authProvider.initiateLogin(),
          )
        ],
      ),
    );
  }
}
