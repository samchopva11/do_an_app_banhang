import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../services/product_service.dart';
import '../../services/storage_service.dart';
import '../../models/product_model.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _visible = true;
  File? _pickedImage;
  bool _loading = false;

  final ProductService _productService = ProductService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _descCtrl.text = widget.product!.description;
      _priceCtrl.text = widget.product!.price.toString();
      _visible = widget.product!.visible;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() {
        _pickedImage = File(file.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String? imageUrl = widget.product?.imageUrl;
      // nếu pick ảnh mới -> upload
      if (_pickedImage != null) {
        final filename = '${_uuid.v4()}.jpg';
        imageUrl = await _storage_service_upload(_pickedImage!, filename);
      }

      final data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': int.tryParse(_priceCtrl.text.trim()) ?? 0,
        'imageUrl': imageUrl,
        'visible': _visible,
      };

      if (widget.product == null) {
        await _productService.addProduct(data);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm sản phẩm')));
      } else {
        await _productService.updateProduct(widget.product!.id, data, oldImageUrl: widget.product!.imageUrl);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật sản phẩm')));
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  // wrapper to handle upload + small delay if needed
  Future<String> _storage_service_upload(File file, String filename) async {
    return await _storageService.uploadProductImage(file, filename: filename);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(children: [
              GestureDetector(
                onTap: _pickImage,
                child: _pickedImage != null
                    ? Image.file(_pickedImage!, width: double.infinity, height: 180, fit: BoxFit.cover)
                    : (widget.product?.imageUrl != null && widget.product!.imageUrl!.isNotEmpty
                    ? Image.network(widget.product!.imageUrl!, width: double.infinity, height: 180, fit: BoxFit.cover)
                    : Container(width: double.infinity, height: 180, color: Colors.grey[200], child: const Icon(Icons.add_a_photo, size: 48))),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Tên sản phẩm'), validator: (v) => v == null || v.isEmpty ? 'Nhập tên' : null),
              const SizedBox(height: 8),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 3),
              const SizedBox(height: 8),
              TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Giá (VND)'), keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Nhập giá' : null),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Hiển thị sản phẩm'),
                value: _visible,
                onChanged: (v) => setState(() => _visible = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : Text(isEdit ? 'Cập nhật' : 'Thêm sản phẩm'),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
