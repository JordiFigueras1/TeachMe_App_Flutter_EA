import 'package:flutter/material.dart';
import '../models/userModel.dart';

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user.mail,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.info, color: Colors.blueAccent),
              onPressed: () {
                // Acción al presionar el botón (puedes personalizarlo)
                print("Detalles del usuario: ${user.name}");
              },
            ),
          ],
        ),
      ),
    );
  }
}
