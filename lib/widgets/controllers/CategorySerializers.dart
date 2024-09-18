class CategoryController {
  final String categoryName;
  final int id;

  CategoryController({required this.categoryName, required this.id});

  // Factory method to handle a single JSON object
  factory CategoryController.fromJson(Map<String, dynamic> json) {
    print(json);
    final requiredKeys = ["category_name", "id"];
    if (requiredKeys.every(json.containsKey)) {
      return CategoryController(
        categoryName: json["category_name"],
        id: json["id"],
      );
    } else {
      throw FormatException("Missing required keys for CategoryController");
    }
  }

  // Factory method to handle a list of JSON objects
  static List<CategoryController> fromJsonList(List<dynamic> jsonList) {
    print(jsonList);
    return jsonList.map((json) {
      return CategoryController.fromJson(json);
    }).toList();
  }
}


