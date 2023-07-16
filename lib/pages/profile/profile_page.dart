import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/global_helpers.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: kcPrimaryColor),
        ),
        backgroundColor: kcScaffoldBG,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: kcScaffoldBG,
      body: ListView(
        children: [
          SizedBox(height: kdPadding),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 120,
              width: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 5,
                ),
              ),
              child: Icon(
                LineIcons.user,
                size: 60,
              ),
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Text(_authController.user.value!.name, style: Theme.of(context).textTheme.displayLarge?.copyWith(color: kcPrimaryColor, fontWeight: FontWeight.w600)),
          ),
          SizedBox(height: kdPadding),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                Get.to(() => EditProfilePage());
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(color: kcPrimaryColor, borderRadius: BorderRadius.circular(kdBorderRadius)),
                child: Text(
                  "Edit Profile",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          SizedBox(height: kdPadding),
          _buildProfileMenuOption(
            icon: Icons.email_outlined,
            onTap: () {},
            text: _authController.user.value!.email,
          ),
          SizedBox(height: kdPadding),
          _buildProfileMenuOption(
            icon: Icons.location_on_outlined,
            onTap: () {},
            text: _authController.user.value!.address.length == 0 ? 'Unknown' : _authController.user.value!.address,
          ),
          SizedBox(height: kdPadding),
          _buildProfileMenuOption(
            icon: Icons.power_settings_new_rounded,
            onTap: () {
              _authController.logOut();
            },
            text: "Logout",
          ),
          SizedBox(height: kdPadding),
          _buildProfileMenuOption(
            icon: Icons.forum_outlined,
            onTap: () async {
              final String email = await showEmailDialog(context: context, type: DialogType.ContactUs);
              // if (!GetUtils.isEmail(email)) return;

              _authController.contactUs(email: email);
            },
            text: "Contact Us",
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuOption({required String text, required IconData icon, required void Function() onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kdPadding),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Color.fromARGB(255, 223, 222, 222), spreadRadius: 0.8, blurRadius: 5, offset: Offset(0, 3))],
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: kcPrimaryColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
