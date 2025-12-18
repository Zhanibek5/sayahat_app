import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

class AboutMePage extends StatefulWidget {
  final String initialText;
  final String userId; // серверге жіберу үшін қолданушының uid сияқты id

  const AboutMePage({Key? key, required this.initialText, required this.userId})
      : super(key: key);

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  late TextEditingController _controller;
  bool _isSaving = false;

  final String serverIp = "http://192.168.1.3:8000"; // осында сервер IP

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _loadAboutMe(); // серверден мәтінді жүктеу
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveAboutMe() async {
    setState(() {
      _isSaving = true;
    });

    final text = _controller.text.trim();

    try {
      final url = Uri.parse("$serverIp/about_me/${widget.userId}");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"aboutMe": text}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('save_success'.tr())),
        );
        Navigator.pop(context, text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('save_error_status'
                .tr(namedArgs: {'status': response.statusCode.toString()})),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('save_error_general'.tr(namedArgs: {'error': e.toString()})),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _loadAboutMe() async {
    try {
      final url = Uri.parse("$serverIp/about_me/${widget.userId}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data["aboutMe"] ?? "";
        _controller.text = text;
      }
    } catch (e) {
      // Егер серверге қосыла алмаса, ештеңе жасама
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'edit_about_me'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'tell_about_yourself'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                maxLines: 10,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'write_something_about_yourself'.tr(),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAboutMe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'save'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 250),
            Center(
              child: Text(
                "Sayahat App",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
