class MaterialModel {
  final String id;
  final String title;
  final String type; // 'pdf', 'video', etc.
  final String url;

  MaterialModel({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
  });
}
