import 'dart:io';
import 'package:algobotix_inventory/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../widgets/glass_card.dart';

class AddEditScreen extends StatefulWidget {
  final Product? product; // If null, we are in "Add Mode"
  final String? scannedId; // Optional ID passed from QR Scanner

  const AddEditScreen({super.key, this.product, this.scannedId});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _stockController;

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Default values
    String initialId = widget.product?.id ?? '';
    String initialDesc = widget.product?.description ?? '';

    if (widget.scannedId != null) {
      String rawCode = widget.scannedId!;

      if (rawCode.length > 5) {
        // Truncate to last 5 characters
        initialId = rawCode.substring(rawCode.length - 5);
      } else {
        // Use as is
        initialId = rawCode;
      }
    }

    _idController = TextEditingController(text: initialId);
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(text: initialDesc);
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _imagePath = widget.product?.imagePath;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Image selection from Gallery or Camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);

      try {
        if (widget.product == null) {
          // ADD MODE
          final newProduct = Product(
            id: _idController.text,
            name: _nameController.text,
            description: _descController.text,
            stock: int.parse(_stockController.text),
            imagePath: _imagePath,
            dateAdded: DateTime.now(),
            addedBy: provider.currentUsername,
          );
          provider.addProduct(newProduct);
        } else {
          // EDIT MODE
          // We modify the existing object directly for Hive to track it easily
          widget.product!.name = _nameController.text;
          widget.product!.description = _descController.text;
          widget.product!.stock = int.parse(_stockController.text);
          widget.product!.imagePath = _imagePath;
          widget.product!.save(); // HiveObject save method
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: myWhiteColor,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Product" : "New Inventory"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              myImagePicker(),
              const SizedBox(height: 24),

              // Product ID (5 alphanumeric chars)
              myTextField(
                controller: _idController,
                label: "Product ID",
                icon: LucideIcons.qrCode,

                enabled: !isEditing && widget.scannedId == null,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  if (value.length != 5) return "Must be exactly 5 characters";
                  // Simple Alphanumeric Regex
                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return "Alphanumeric only";
                  }
                  return null;
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
              ),

              const SizedBox(height: 16),

              // Name
              myTextField(
                controller: _nameController,
                label: "Product Name",
                icon: LucideIcons.tag,
                validator: (v) => v!.isEmpty ? "Name is required" : null,
              ),

              const SizedBox(height: 16),

              // Description
              myTextField(
                controller: _descController,
                label: "Description",
                icon: LucideIcons.fileText,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Description is required" : null,
              ),

              const SizedBox(height: 16),

              // Stock
              myTextField(
                controller: _stockController,
                label: "Initial Stock",
                icon: LucideIcons.boxes,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  if (int.tryParse(v) == null) return "Must be a number";
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              GestureDetector(
                onTap: _saveProduct,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: myPurpleColor,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: myPurpleColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    isEditing ? "Update Product" : "Save to Inventory",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget myTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 20,
      opacity: enabled ? 0.6 : 0.3,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          icon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget myImagePicker() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.camera),
                  title: const Text("Camera"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.image),
                  title: const Text("Gallery"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: myPurpleColor.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            image: _imagePath != null
                ? DecorationImage(
              image: FileImage(File(_imagePath!)),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: _imagePath == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.camera, size: 32, color: myPurpleColor),
              SizedBox(height: 8),
              Text("Add Photo", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
              : null,
        ),
      ),
    );
  }
}