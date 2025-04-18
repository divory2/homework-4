import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      home: MyHomePage(title: 'Firebase Auth Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;




  void _signOut() async {
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed out successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          ElevatedButton(
            onPressed: _signOut,
            child: Text('Sign Out'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RegisterEmailSection(auth: _auth),
            EmailPasswordForm(auth: _auth),
          ],
        ),
      ),
    );
  }
}

class RegisterEmailSection extends StatefulWidget {
  RegisterEmailSection({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
  _RegisterEmailSectionState createState() => _RegisterEmailSectionState();
}

class _RegisterEmailSectionState extends State<RegisterEmailSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}


  bool _success = false;
  bool _initialState = true;
  String? _userEmail;

  void _register() async {
  try {
    final userCredential = await widget.auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _success = true;
      _userEmail = userCredential.user?.email;
      _initialState = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  } catch (e) {
    setState(() {
      _success = false;
      _initialState = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration failed: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _register();
                }
              },
              child: Text('Submit'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              _initialState
                  ? 'Please Register'
                  : _success
                      ? 'Successfully registered $_userEmail'
                      : 'Registration failed',
              style: TextStyle(
                color: _success ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmailPasswordForm extends StatefulWidget {
  EmailPasswordForm({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
  _EmailPasswordFormState createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _success = false;
  bool _initialState = true;
  String _userEmail = '';

  void _signInWithEmailAndPassword() async {
  try {
    final userCredential = await widget.auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() {
      _success = true;
      _userEmail = userCredential.user?.email ?? '';
      _initialState = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  } catch (e) {
    setState(() {
      _success = false;
      _initialState = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign in failed: ${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text('Test sign in with email and password'),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signInWithEmailAndPassword();
                }
              },
              child: Text('Submit'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _initialState
                  ? 'Please sign in'
                  : _success
                      ? 'Successfully signed in $_userEmail'
                      : 'Sign in failed',
              style: TextStyle(
                color: _success ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage(title: 'Firebase Auth Demo')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome!", style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Text("Email: ${user?.email ?? 'Not logged in'}", style: TextStyle(fontSize: 16)),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _showChangePasswordDialog(context),
                child: Text("Change Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController _newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change Password"),
        content: TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(labelText: "New Password"),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Update"),
            onPressed: () async {
              try {
                await _auth.currentUser?.updatePassword(_newPasswordController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password updated successfully")));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update password")));
              }
            },
          ),
        ],
      ),
    );
  }
}

