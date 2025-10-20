import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mango_app/services/mango_service.dart';
import 'package:mango_app/widgets/text_input.dart';

class EditMangoPage extends StatefulWidget {
  final Map<String, dynamic> mango;

  const EditMangoPage({super.key, required this.mango});

  @override
  State<EditMangoPage> createState() => _EditMangoPageState();
}

class _EditMangoPageState extends State<EditMangoPage> {
  final MangoService _mangoService = MangoService();
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController capacityController;

  File? _newImage; // selected new image file
  String? _currentImage; // current Cloudinary image URL
  bool _isUpdating = false; // disable update button while updating

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.mango['typeName'] ?? '',
    );
    priceController = TextEditingController(
      text: widget.mango['price']?.toString() ?? '',
    );
    capacityController = TextEditingController(
      text: widget.mango['buying_capacity']?.toString() ?? '',
    );
    _currentImage = widget.mango['image'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = File(picked.path));
    }
  }

  Future<void> updateMango() async {
    setState(() => _isUpdating = true);

    final success = await _mangoService.updateMangoType(
      id: widget.mango['_id'],
      typeName: nameController.text.trim(),
      price: double.tryParse(priceController.text.trim()) ?? 0,
      capacity: double.tryParse(capacityController.text.trim()) ?? 0,
      imageFile: _newImage,
    );

    if (success && mounted) Navigator.pop(context);

    setState(() => _isUpdating = false);
  }

  Future<void> deleteMango() async {
    final success = await _mangoService.deleteMangoType(widget.mango['_id']);
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        _newImage != null
            ? FileImage(_newImage!)
            : (_currentImage != null && _currentImage!.isNotEmpty
                ? NetworkImage(_currentImage!)
                : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Mango Type"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green[100],
                    backgroundImage: imageProvider as ImageProvider?,
                    child:
                        imageProvider == null
                            ? const Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.green,
                            )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green,
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            TextInput(label: "Mango Type:", controller: nameController),
            TextInput(label: "Price:", controller: priceController),
            TextInput(
              label: "Buying Capacity:",
              controller: capacityController,
            ),
            const SizedBox(height: 25),

            // ✅ Update Button with loading indicator
            ElevatedButton(
              onPressed: _isUpdating ? null : updateMango,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 45),
              ),
              child:
                  _isUpdating
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text("Update"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: deleteMango,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text("Delete"),
            ),
          ],
        ),
      ),
    );
  }
}
