import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  // এখানে নেটলিফাইয়ের বদলে গিটহাবের Raw লিঙ্ক বসানো হলো
  static const String jsonUrl = "https://raw.githubusercontent.com/Jafor1913025/job-mastery-app/main/version.json";

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentBuildNumber = int.parse(packageInfo.buildNumber);

      final response = await http.get(Uri.parse(jsonUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        int latestVersionCode = data['latestVersionCode'];
        String latestVersionName = data['latestVersionName'];
        String updateUrl = data['updateUrl'];
        String releaseNotes = data['releaseNotes'] ?? '';
        bool forceUpdate = data['forceUpdate'] ?? false;

        if (latestVersionCode > currentBuildNumber) {
          if (context.mounted) {
            _showUpdateDialog(
              context,
              latestVersionName,
              releaseNotes,
              updateUrl,
              forceUpdate,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }

  static void _showUpdateDialog(
    BuildContext context,
    String versionName,
    String notes,
    String downloadUrl,
    bool forceUpdate,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (BuildContext context) {
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.system_update_rounded, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "নতুন আপডেট উপলব্ধ! ($versionName)",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "আরও ভালো অভিজ্ঞতার জন্য এখনই অ্যাপটি আপডেট করে নিন।",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    "নতুন যা যুক্ত হয়েছে:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notes,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ],
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("পরে করবো", style: TextStyle(color: Colors.grey)),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final Uri url = Uri.parse(downloadUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text("এখনই আপডেট করুন", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}