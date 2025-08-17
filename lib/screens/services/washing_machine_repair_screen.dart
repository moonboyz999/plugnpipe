import 'package:flutter/material.dart';
import 'washing_machine_repair_request_screen.dart';

/// Entry screen for Washing Machine Repair flow that directly shows the request screen.
class WashingMachineRepairScreen extends StatelessWidget {
  const WashingMachineRepairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly navigate to the request screen instead of showing intermediate screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WashingMachineRepairRequestScreen(),
        ),
      );
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
