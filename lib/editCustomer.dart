import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'API.dart';
import 'apiHelper.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class EditCustomerPage extends StatefulWidget {
  const EditCustomerPage({
    super.key,
    required this.customerId,
    this.name,
    this.phoneNumber,
    this.email,
    this.homePage,
    this.latitude,
    this.longitude,
  });

  final String customerId;
  final String? name;
  final String? phoneNumber;
  final String? email;
  final String? homePage;
  final double? latitude;
  final double? longitude;

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final Helper helper = Helper();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController homePageController;
  late final TextEditingController latitudeController;
  late final TextEditingController longitudeController;

  bool _saving = false;
  bool _locating = false;

  // Values arrive from the customer list as `.toString()` of possibly-null fields.
  static String _clean(String? value) =>
      (value == null || value == "null") ? "" : value;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: _clean(widget.name));
    phoneController = TextEditingController(text: _clean(widget.phoneNumber));
    emailController = TextEditingController(text: _clean(widget.email));
    homePageController = TextEditingController(text: _clean(widget.homePage));
    latitudeController =
        TextEditingController(text: widget.latitude?.toString() ?? "");
    longitudeController =
        TextEditingController(text: widget.longitude?.toString() ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    homePageController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  double? get _latitude => double.tryParse(latitudeController.text.trim());
  double? get _longitude => double.tryParse(longitudeController.text.trim());

  Map<String, dynamic> _currentValues() => {
        "Name": nameController.text.trim(),
        "Phone_No": phoneController.text.trim(),
        "E_Mail": emailController.text.trim(),
        "Home_Page": homePageController.text.trim(),
        "Latitude": _latitude ?? widget.latitude,
        "Longitude": _longitude ?? widget.longitude,
      };

  Map<String, dynamic> _changedFields() {
    final original = {
      "Name": _clean(widget.name),
      "Phone_No": _clean(widget.phoneNumber),
      "E_Mail": _clean(widget.email),
      "Home_Page": _clean(widget.homePage),
      "Latitude": widget.latitude,
      "Longitude": widget.longitude,
    };
    return Map.fromEntries(_currentValues()
        .entries
        .where((e) => e.value != null && e.value != original[e.key]));
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          helper.snackBarNotification(
              "Location permission is required", context);
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitudeController.text = position.latitude.toString();
      longitudeController.text = position.longitude.toString();
    } catch (e) {
      if (mounted) {
        helper.snackBarNotification("Could not get location: $e", context);
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  String? _validateCoordinate(String? value, double limit, String name) {
    final text = (value ?? "").trim();
    if (text.isEmpty) return null;
    final number = double.tryParse(text);
    if (number == null) return "Enter a valid $name";
    if (number < -limit || number > limit) {
      return "$name must be between -$limit and $limit";
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final changes = _changedFields();
    if (changes.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _saving = true);

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));

    try {
      final response = await http.patch(
        Uri.parse(ApiUrl.customerById(widget.customerId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': basicAuth,
          'If-Match': '*',
        },
        body: jsonEncode(changes),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        Navigator.pop(context, _currentValues());
      } else {
        setState(() => _saving = false);
        helper.alertDialogTitle("Update failed", _errorMessage(response), context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    }
  }

  String _errorMessage(http.Response response) {
    try {
      final message = jsonDecode(response.body)["error"]["message"];
      if (message != null) return message.toString();
    } catch (_) {}
    return response.body.isEmpty
        ? "Server returned status ${response.statusCode}"
        : response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Customer"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            AppCard(
              child: Row(
                children: [
                  InitialsAvatar(
                    name: nameController.text.isEmpty
                        ? widget.customerId
                        : nameController.text,
                    size: 48,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Customer No.",
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.customerId,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SmallCapsLabel("Business"),
            AppCard(
              child: _field(
                controller: nameController,
                label: "Name",
                hint: "Customer name",
                icon: Icons.storefront_outlined,
                last: true,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Please provide a name"
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            const SmallCapsLabel("Contact"),
            AppCard(
              child: Column(
                children: [
                  _field(
                    controller: phoneController,
                    label: "Phone No.",
                    hint: "e.g. 0241234567",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Please provide a phone number"
                        : null,
                  ),
                  _field(
                    controller: emailController,
                    label: "E-mail",
                    hint: "name@example.com",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final value = (v ?? "").trim();
                      if (value.isEmpty) return null;
                      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(value)
                          ? null
                          : "Enter a valid email, e.g. test@gmail.com";
                    },
                  ),
                  _field(
                    controller: homePageController,
                    label: "Home Page",
                    hint: "www.example.com",
                    icon: Icons.language,
                    keyboardType: TextInputType.url,
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SmallCapsLabel("Location"),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _field(
                          controller: latitudeController,
                          label: "Latitude",
                          hint: "0.000000",
                          icon: Icons.my_location,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          validator: (v) =>
                              _validateCoordinate(v, 90, "Latitude"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          controller: longitudeController,
                          label: "Longitude",
                          hint: "0.000000",
                          icon: Icons.explore_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          validator: (v) =>
                              _validateCoordinate(v, 180, "Longitude"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _locating ? null : _useCurrentLocation,
                      icon: _locating
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: AppLoader(strokeWidth: 2),
                            )
                          : const Icon(Icons.gps_fixed),
                      label: const Text("Use my current location"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: AppLoader(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text("Save Changes"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool last = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint ?? label,
              prefixIcon: Icon(icon),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}
