import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  bool _saving = false;
  bool networkImageFailed = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String?> _uploadImageToServer(File file) async {
    final uri =
        Uri.parse("http://192.168.1.3:8000/upload_profile_image/${user!.uid}");

    final request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("image", file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      return "http://192.168.1.3:8000/profile_image/${user!.uid}";
    } else {
      return null;
    }
  }

  Future<void> _deletePhoto() async {
    if (_imageFile == null && user?.photoURL == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_photo_to_delete'.tr())),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final uri = Uri.parse(
          "http://192.168.1.3:8000/delete_profile_image/${user!.uid}");
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        await user?.updatePhotoURL(null);
        await user?.reload();

        setState(() {
          _imageFile = null;
          networkImageFailed = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('photo_deleted_successfully'.tr())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_delete_photo'.tr())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('save_error_general'.tr(namedArgs: {'error': e.toString()})),
        ),
      );
    }

    setState(() => _saving = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    String? photoUrl = user?.photoURL;

    try {
      // upload new image to Python server
      if (_imageFile != null) {
        final uploadedUrl = await _uploadImageToServer(_imageFile!);
        if (uploadedUrl != null) {
          photoUrl = uploadedUrl;
        }
      }

      // update display name
      await user?.updateDisplayName(_nameController.text);

      // update photo in Firebase Auth
      if (photoUrl != null) {
        await user?.updatePhotoURL(photoUrl);
      }

      await user?.reload();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('save_error_general'.tr(namedArgs: {'error': e.toString()})),
        ),
      );
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _imageFile != null
        ? FileImage(_imageFile!)
        : (user?.photoURL != null
            ? CachedNetworkImageProvider(
                "${user!.photoURL!}?v=${DateTime.now().millisecondsSinceEpoch}")
            : const AssetImage("assets/avatar.png") as ImageProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0AB3A3), Color(0xFF0F766E)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'edit_profile'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: imageProvider,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _pickImage,
                      child: Text(
                        'change_photo'.tr(),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    if (_imageFile != null || user?.photoURL != null)
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                await _deletePhoto(); // Суретті серверден өшіру
                                if (mounted)
                                  Navigator.pop(
                                      context); // ProfilePage қайта көрінеді
                              },
                        child: Text(
                          'delete_photo'.tr(),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'full_name'.tr(),
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.teal),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0AB3A3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'save'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 275),
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
          ),
        ],
      ),
    );
  }
}
