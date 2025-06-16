import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: PasswordGeneratorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PasswordGeneratorScreen extends StatefulWidget {
  @override
  _PasswordGeneratorScreenState createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _includeNumbers = false;
  bool _includeSpecialChars = false;
  bool _isLoading = false;

  // Backend URL - change this to your computer's IP if testing on phone
  static const String BASE_URL = 'http://localhost:8000';

  // Generate password function
  Future<void> _generatePassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/generate-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'length': 12, // Fixed length of 12 characters
          'include_numbers': _includeNumbers,
          'include_special_chars': _includeSpecialChars,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _passwordController.text = data['password'];
        });
      } else {
        _showError('Failed to generate password');
      }
    } catch (e) {
      _showError('Cannot connect to server. Make sure Python backend is running.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Copy password to clipboard
  void _copyToClipboard() {
    if (_passwordController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _passwordController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Password Generator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),

            // Password Display Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _passwordController,
                readOnly: true,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Generated password will appear here',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _copyToClipboard,
                    icon: Icon(
                      Icons.copy,
                      color: Colors.blue[600],
                    ),
                    tooltip: 'Copy password',
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Include Numbers Button
            _buildOptionButton(
              'Include Numbers',
              _includeNumbers,
              Icons.format_list_numbered,
                  () {
                setState(() {
                  _includeNumbers = !_includeNumbers;
                });
              },
            ),

            SizedBox(height: 16),

            // Include Special Characters Button
            _buildOptionButton(
              'Include Special Characters',
              _includeSpecialChars,
              Icons.alternate_email,
                  () {
                setState(() {
                  _includeSpecialChars = !_includeSpecialChars;
                });
              },
            ),

            SizedBox(height: 30),

            // Generate Password Button
            _buildActionButton(
              'Generate Password',
              Icons.security,
              Colors.blue,
              _generatePassword,
            ),

            SizedBox(height: 16),

            // Regenerate Password Button
            _buildActionButton(
              'Regenerate Password',
              Icons.refresh,
              Colors.green,
              _generatePassword,
            ),
          ],
        ),
      ),
    );
  }

  // Option button widget (for include numbers/special chars)
  Widget _buildOptionButton(
      String text,
      bool isSelected,
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue[600] : Colors.grey[600],
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.blue[600] : Colors.grey[700],
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue[600],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // Action button widget (for generate/regenerate)
  Widget _buildActionButton(
      String text,
      IconData icon,
      MaterialColor color,
      VoidCallback onPressed,
      ) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color[600],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}