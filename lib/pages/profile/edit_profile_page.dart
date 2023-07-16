import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/global_helpers.dart';
import '../../models/user.dart';
import '../widgets/app_button.dart';

import '../../config/theme.dart';
import '../widgets/app_text_field_with_label.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthController _authController = Get.find();

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _addressEditingController = TextEditingController();
  final TextEditingController _specialtyEditingController = TextEditingController();
  final TextEditingController _clinicNameEditingController = TextEditingController();

  Rx<XFile?> _selectedImage = Rx(null);

  @override
  void initState() {
    super.initState();
    final User user = _authController.user.value!;
    _nameEditingController.text = user.name;
    _emailEditingController.text = user.email;
    _phoneEditingController.text = user.phone;
    _addressEditingController.text = user.address;
    _clinicNameEditingController.text = user.clinic_name;
    _specialtyEditingController.text = user.specialty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(color: kcPrimaryColor),
        ),
        backgroundColor: kcScaffoldBG,
        elevation: 0,
        iconTheme: IconThemeData(color: kcPrimaryColor),
      ),
      backgroundColor: kcScaffoldBG,
      body: ListView(
        children: [
          SizedBox(height: kdPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kdPadding),
            child: GestureDetector(
              onTap: () async {
                ImagePicker picker = ImagePicker();
                _selectedImage.value = await picker.pickImage(source: ImageSource.gallery);
              },
              child: Row(
                children: [
                  Obx(() {
                    return Container(
                      height: 80,
                      width: 80,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: _selectedImage.value == null
                          ? Image.network(
                              _authController.user.value!.profilePic,
                            )
                          : Image.file(File(_selectedImage.value!.path)),
                    );
                  }),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "Change Profile Photo",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: inActiveBottomBarColor,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: kdPadding),
          AppTextFieldWithLabel(
            icon: Icons.person_2_outlined,
            label: "Full Name",
            controller: _nameEditingController,
          ),
          SizedBox(height: kdPadding),
          AppTextFieldWithLabel(
            icon: Icons.email_outlined,
            label: "Email",
            controller: _emailEditingController,
          ),
          SizedBox(height: kdPadding),
          AppTextFieldWithLabel(
            icon: Icons.call_outlined,
            label: "Phone",
            controller: _phoneEditingController,
          ),
          SizedBox(height: kdPadding),
          AppTextFieldWithLabel(
            icon: Icons.location_on_outlined,
            label: "Address",
            controller: _addressEditingController,
          ),
          SizedBox(height: kdPadding),
          AppTextFieldWithLabel(
            icon: Icons.location_on_outlined,
            label: "Specialty",
            controller: _specialtyEditingController,
          ),
          SizedBox(height: kdPadding),
          AppTextFieldWithLabel(
            label: "Clinic name",
            controller: _clinicNameEditingController,
          ),
          SizedBox(height: kdPadding * 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kdPadding),
            child: Obx(() {
              return _authController.isLoading.value
                  ? getLoading()
                  : AppButton(
                      text: "Save",
                      onTap: () {
                        if (!GetUtils.isEmail(_emailEditingController.text)) return showMightySnackBar(message: "Please enter a valid email address.");
                        if (_nameEditingController.text.trim().length == 0) return showMightySnackBar(message: "Please enter your full name.");
                        if (_phoneEditingController.text.trim().length == 0) return showMightySnackBar(message: "Please enter your phone number.");
                        if (_addressEditingController.text.trim().length == 0) return showMightySnackBar(message: "Please enter your address.");
                        if (_clinicNameEditingController.text.trim().length == 0) return showMightySnackBar(message: "Please enter your Clinic Name.");

                        _authController.updateProfile(
                          name: _nameEditingController.text.trim(),
                          phone: _phoneEditingController.text.trim(),
                          address: _addressEditingController.text.trim(),
                          clinic_name: _clinicNameEditingController.text.trim(),
                          specialty: _specialtyEditingController.text.trim(),
                          image: _selectedImage.value,
                        );
                      },
                    );
            }),
          ),
        ],
      ),
    );
  }
}
