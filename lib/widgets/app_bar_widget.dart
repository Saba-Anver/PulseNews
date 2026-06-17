import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:portal_news/service/user_provider.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

AppBar buildAppBar(BuildContext context) {
  final user = Provider.of<UserProvider>(context).user;
  return AppBar(
    backgroundColor: Colors.black,
    elevation: 0,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        // CircleAvatar(radius: 20, child: Icon(Icons.person_3_outlined)),
        StreamBuilder(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .snapshots(),
          builder: (context, snapshot) {
            String? imageBase64;

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;

              imageBase64 = data['profileImage'];
            }

            return CircleAvatar(
              radius: 20,
              backgroundColor: Colors.teal,
              backgroundImage:
                  imageBase64 != null
                      ? MemoryImage(base64Decode(imageBase64))
                      : null,
              child:
                  imageBase64 == null
                      ? const Icon(Icons.person_3_outlined)
                      : null,
            );
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Welcome back",
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text("👋", style: TextStyle(fontSize: 14)),
                ],
              ),
              Text(
                "${user?.displayName}",
                style: GoogleFonts.playfair(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
