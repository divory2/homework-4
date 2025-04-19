import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homework_4/chat_screen.dart';
import 'package:homework_4/splashscreen.dart';
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
        actions: [
          TextButton(
            onPressed: _signOut,
            child: Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RegisterEmailSection(auth: _auth),
              Divider(height: 40),
              EmailPasswordForm(auth: _auth),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterEmailSection extends StatefulWidget {
  final FirebaseAuth auth;
  const RegisterEmailSection({Key? key, required this.auth}) : super(key: key);

  @override
  _RegisterEmailSectionState createState() => _RegisterEmailSectionState();
}

class _RegisterEmailSectionState extends State<RegisterEmailSection> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _role = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _role.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    try {
      final userCredential = await widget.auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': _firstName.text.trim(),
          'lastName': _lastName.text.trim(),
          'role': _role.text.trim(),
          'email': user.email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text("Register", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextFormField(controller: _firstName, decoration: InputDecoration(labelText: "First Name")),
          TextFormField(controller: _lastName, decoration: InputDecoration(labelText: "Last Name")),
          TextFormField(controller: _role, decoration: InputDecoration(labelText: "Role")),
          TextFormField(
            controller: _email,
            decoration: InputDecoration(labelText: "Email"),
            validator: (value) => (value?.isEmpty ?? true) ? "Enter email" : null,
          ),
          TextFormField(
            controller: _password,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (value) => (value?.isEmpty ?? true) ? "Enter password" : null,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) _register();
            },
            child: Text("Register"),
          ),
        ],
      ),
    );
  }
}

class EmailPasswordForm extends StatefulWidget {
  final FirebaseAuth auth;
  const EmailPasswordForm({Key? key, required this.auth}) : super(key: key);

  @override
  _EmailPasswordFormState createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn() async {
    try {
      final userCredential = await widget.auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-in Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text("Login", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _email,
            decoration: InputDecoration(labelText: "Email"),
            validator: (value) => (value?.isEmpty ?? true) ? "Enter email" : null,
          ),
          TextFormField(
            controller: _password,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (value) => (value?.isEmpty ?? true) ? "Enter password" : null,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) _signIn();
            },
            child: Text("Sign In"),
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
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen()),
    );
  },
  child: Text("Go to Chat"),
),

          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MyHomePage(title: 'Firebase Auth Demo')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Email: ${user?.email}", style: TextStyle(fontSize: 16)),
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
    final TextEditingController _newPassword = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change Password"),
        content: TextField(
          controller: _newPassword,
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
                await _auth.currentUser?.updatePassword(_newPassword.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Password updated successfully")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update password")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
