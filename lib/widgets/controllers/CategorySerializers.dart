class CategoryController {
  final String name;
  final int id;

  CategoryController({required this.name, required this.id});

  // Factory method to handle a single JSON object
  factory CategoryController.fromJson(Map<String, dynamic> json) {
    print(json);
    final requiredKeys = ["name", "id"];
    if (requiredKeys.every(json.containsKey)) {
      return CategoryController(
        name: json["name"],
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


