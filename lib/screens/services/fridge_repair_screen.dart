import 'package:flutter/material.dart';
import 'fridge_repair_request_screen.dart';

/// Entry screen for Fridge Repair flow that directly navigates to the request screen.
class FridgeRepairScreen extends StatelessWidget {
  const FridgeRepairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Automatically navigate to the request screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const FridgeRepairRequestScreen(),
        ),
      );
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
