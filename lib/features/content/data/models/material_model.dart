class MaterialModel {
  final int id;
  final String fileName;
  final String fileType;
  final String uploadStatus;
  final DateTime createdAt;

  MaterialModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.uploadStatus,
    required this.createdAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      fileName: json['file_name'],
      fileType: json['file_type'],
      uploadStatus: json['upload_status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
