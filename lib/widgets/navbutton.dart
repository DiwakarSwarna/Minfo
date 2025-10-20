// import 'package:flutter/material.dart';

// class NavButton extends StatelessWidget {
//   final String label;
//   final Widget destination;
//   final Color color;
//   final Color textColor;

//   const NavButton({
//     super.key,
//     required this.label,
//     required this.destination,
//     this.color = Colors.green,
//     this.textColor = Colors.white,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(
//           context,
//         ).push(MaterialPageRoute(builder: (builder) => destination));
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Center(child: Text(label, style: TextStyle(color: textColor))),
//         ),
//       ),
//     );
//   }
// }
