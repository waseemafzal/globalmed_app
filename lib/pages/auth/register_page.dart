// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../helpers/global_helpers.dart';

// import '../../config/theme.dart';
// import '../widgets/app_button.dart';
// import '../widgets/app_text_field.dart';

// class RegisterPage extends StatelessWidget {
//   RegisterPage({super.key});

//   final TextEditingController _fullNameEditingController = TextEditingController();
//   final TextEditingController _emailEditingController = TextEditingController();
//   final TextEditingController _passwordEditingController = TextEditingController();
//   final TextEditingController _passwordConfirmationEditingController = TextEditingController();
//   final TextEditingController _contactNumberEditingController = TextEditingController();

//   final RxBool _policyAccepted = false.obs;

//   final GlobalKey<FormState> _form = GlobalKey();

//   final AuthController _authController = Get.find();

//   Rx<Country?> _selectedCountry = Rx(null);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(gradient: kcGradient),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.only(bottom: 20, top: 40),
//               physics: const BouncingScrollPhysics(),
//               child: Form(
//                 key: _form,
//                 child: Column(
//                   children: [
//                     Image.asset(
//                       'assets/images/app_logo.png',
//                       width: MediaQuery.of(context).size.width * 0.6,
//                     ),
//                     // Image.asset(
//                     //   'assets/images/app_text_logo.png',
//                     //   width: MediaQuery.of(context).size.width * 0.5,
//                     // ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     Text(
//                       "Sign Up",
//                       style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     SizedBox(height: 20),
//                     AppTextField(
//                       placeHolder: "Full Name",
//                       controller: _fullNameEditingController,
//                       validator: (value) => value == null || value.length == 0 ? 'Please enter your full name.' : null,
//                       withBottomPadding: false,
//                     ),
//                     SizedBox(height: 20),
//                     GestureDetector(
//                       onTap: () async {
//                         showCountryPicker(
//                           context: context,
//                           onSelect: (Country country) {
//                             _selectedCountry.value = country;
//                           },
//                           showSearch: false,
//                           useSafeArea: true,
//                           countryListTheme: CountryListThemeData(
//                             backgroundColor: kcPrimaryColor,
//                             textStyle: TextStyle(color: Colors.white, fontSize: 14),
//                           ),
//                         );
//                       },
//                       child: Obx(() {
//                         return Padding(
//                           padding: const EdgeInsets.only(left: kdPadding * 2, right: kdPadding * 2, bottom: 20),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               _selectedCountry.value == null ? Icon(Icons.flag, color: Colors.white) : Text(_selectedCountry.value!.flagEmoji),
//                               SizedBox(width: kdPadding),
//                               Text(
//                                 _selectedCountry.value == null ? "Please select a country" : _selectedCountry.value!.name,
//                                 style: Theme.of(context).textTheme.displaySmall,
//                               ),
//                               Spacer(),
//                               Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
//                             ],
//                           ),
//                         );
//                       }),
//                     ),
//                     AppTextField(
//                       placeHolder: "Contact Number",
//                       controller: _contactNumberEditingController,
//                       validator: (value) => value == null || value.trim().length == 0 ? 'Please enter your contact number.' : null,
//                     ),
//                     AppTextField(
//                       placeHolder: "Email or username",
//                       controller: _emailEditingController,
//                       // validator: (value) => GetUtils.isEmail(value ?? '') ? null : "Enter a valid email address.",
//                       validator: (value) => value == null || value.trim().length == 0 ? 'Please enter your email or username.' : null,
//                     ),
//                     AppTextField(
//                       placeHolder: "Password",
//                       controller: _passwordEditingController,
//                       validator: (value) => value == null || value.length < 8 ? 'Password must be at least 8 characters.' : null,
//                     ),
//                     AppTextField(
//                       placeHolder: "Confirm Password",
//                       controller: _passwordConfirmationEditingController,
//                       validator: (value) => _passwordEditingController.text.trim() == _passwordConfirmationEditingController.text.trim() ? null : "Passwords do not match.",
//                       withBottomPadding: false,
//                     ),
//                     SizedBox(height: 10),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: kdPadding),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Obx(() {
//                             return Checkbox(
//                               value: _policyAccepted.value,
//                               onChanged: (value) => _policyAccepted.value = !_policyAccepted.value,
//                               visualDensity: VisualDensity.compact,
//                               fillColor: MaterialStateProperty.resolveWith((states) => white),
//                               checkColor: kcPrimaryColor,
//                             );
//                           }),
//                           Expanded(
//                             child: Text(
//                               'By signing up you are agreeing to our Terms and Conditions.',
//                               style: Theme.of(context).textTheme.bodySmall?.copyWith(color: white),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: kdPadding),
//                       child: Obx(() {
//                         return _authController.isLoading.value
//                             ? getLoading(color: Colors.white)
//                             : AppButton(
//                                 text: "Sign up",
//                                 onTap: () {
//                                   if (!_policyAccepted.value) return showMightySnackBar(message: "Please accept the privacy policy.");
//                                   if (_selectedCountry.value == null) return showMightySnackBar(message: "Please select your country first.");

//                                   if (_form.currentState!.validate()) {
//                                     _authController.register(
//                                       name: _fullNameEditingController.text.trim(),
//                                       email: _emailEditingController.text.trim(),
//                                       password: _passwordConfirmationEditingController.text.trim(),
//                                       country: _selectedCountry.value!.name,
//                                       phone: _contactNumberEditingController.text.trim(),
//                                     );
//                                   }
//                                 },
//                               );
//                       }),
//                     ),
//                     SizedBox(height: 50),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Already have an account?",
//                           style: Theme.of(context).textTheme.bodySmall?.copyWith(color: white),
//                         ),
//                         SizedBox(width: 5),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             "Login",
//                             style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Color(0xffACF0F2)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
