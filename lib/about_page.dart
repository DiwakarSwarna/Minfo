import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Minfo"),
        backgroundColor: Colors.green,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Profile Photo
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(
                'assets/images/Diwakar.jpg',
              ), // 👈 your photo path
            ),
            const SizedBox(height: 12),

            // ✅ Your Name
            const Text(
              "Diwakar Swarna",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 30),

            // ✅ App Info Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Minfo",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Version 1.0.0",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const Divider(height: 25),

                    const Text(
                      "About the App",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Minfo is a smart mango information and trading platform that connects farmers and mandi owners. It provides real-time price insights, location-based market data, and transparent communication for efficient mango distribution.",
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ✅ Contact Section
            Column(
              children: const [
                Text(
                  "Contact & Support",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 6),
                Text(
                  "support@minfoapp.com",
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),

            const Spacer(),

            // ✅ Footer
            Text(
              "© 2025 Minfo | All Rights Reserved",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
