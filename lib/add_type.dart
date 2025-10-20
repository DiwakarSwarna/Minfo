import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mango_app/mandi.dart';
import 'package:mango_app/services/mango_service.dart';
import 'package:mango_app/widgets/app_snack_bar.dart';
import 'package:mango_app/widgets/text_input.dart';

class AddType extends StatefulWidget {
  const AddType({super.key});

  @override
  State<AddType> createState() => AddTypeState();
}

class AddTypeState extends State<AddType> {
  final MangoService _mangoService = MangoService();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _addMangoType() async {
    if (_imageFile == null) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Please select an image")));
      AppSnackBar.show(
        context,
        message: "Please select an image",
        type: SnackBarType.error,
      );
      return;
    }
    final response = await _mangoService.addMangoType(
      type: typeController.text,
      price: priceController.text,
      capacity: capacityController.text,
      imageFile: _imageFile!,
    );

    if (response["success"] == true) {
      // Go back to Mandi page and refresh list
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => const Mandi()));
    } else {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(response["message"] ?? "Error")));
      AppSnackBar.show(
        context,
        message: response["message"] ?? "Error",
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInput(
                  controller: typeController,
                  label: "Type:",
                  hint: "Enter mango type",
                ),
                SizedBox(height: 20),
                TextInput(
                  controller: priceController,
                  label: "Price:",
                  hint: "Enter price per kg",
                ),
                SizedBox(height: 20),
                TextInput(
                  controller: capacityController,
                  label: "Buying Capacity:",
                  hint: "Enter capacity in tons",
                ),
                SizedBox(height: 20),
                Text(
                  "Upload Image:",
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child:
                        _imageFile == null
                            ? DottedBorder(
                              color: Colors.green,
                              strokeWidth: 1,
                              dashPattern: [6, 3],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(8),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.white38,
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.green,
                                    size: 50,
                                  ),
                                ),
                              ),
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageFile!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: _addMangoType,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: Text(
                          "Add new mango type",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
