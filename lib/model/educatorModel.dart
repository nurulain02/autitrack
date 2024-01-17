import 'package:cloud_firestore/cloud_firestore.dart';

class EducatorModel {
  String? id;
  final String educatorFullName;
  final String educatorName;
  String educatorProfilePicture;
  final String educatorExpertise;
  final String educatorPhoneNumber;
  final String educatorEmail;
  final String educatorPassword;
  final String educatorRePassword;
  final String role;
  final String status;

  EducatorModel({
    this.id,
    required this.educatorFullName,
    required this.educatorName,
    required this.educatorProfilePicture,
    required this.educatorExpertise,
    required this.educatorPhoneNumber,
    required this.educatorEmail,
    required this.educatorPassword,
    required this.educatorRePassword,
    required this.role,
    required this.status,
  });

  factory EducatorModel.fromDoc(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return EducatorModel(
      id: doc.id,
      educatorFullName: data?['educatorFullName'] ?? '',
      educatorName: data?['educatorName'] ?? '',
      educatorProfilePicture: data?['educatorProfilePicture'] ?? '',
      educatorExpertise: data?['educatorExpertise'] ?? '',
      educatorPhoneNumber: data?['educatorPhoneNumber'] ?? '',
      educatorEmail: data?['educatorEmail'] ?? '',
      educatorPassword: data?['educatorPassword'] ?? '',
      educatorRePassword: data?['educatorRePassword'] ?? '',
      role: data?['role'] ?? '',
      status: data?['status'] ?? '',
    );
  }
}
