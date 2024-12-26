// Collection names

import 'package:application/main.dart';
import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String kCategoriesCollection = 'categories';
const String kBrandsCollection = 'brands';
const String kProductsCollection = 'products';
const String kStockCollection = 'stock';
const String kCustomersCollection = 'customers';
const String kSalesCollection = 'sales';
const String kReportsCollection = 'reports';

// Models
class Category {
  final String id;
  final String name;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Category fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class Brand {
  final String id;
  final String name;
  final String categoryId;

  Brand({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
    };
  }

  static Brand fromMap(Map<String, dynamic> map, String id) {
    return Brand(
      id: id,
      name: map['name'],
      categoryId: map['categoryId'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String categoryId;
  final String brandId;
  final String? barcode;
  final double buyingPrice;
  final double sellingPrice;
  final bool isActive;
  final DateTime lastUpdated;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.brandId,
    this.barcode,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.isActive,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'brandId': brandId,
      'barcode': barcode,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'isActive': isActive,
      'lastUpdated': lastUpdated.toIso8601String(),
      'priceHistory': [], // Embedded array for price history
    };
  }

  static Product fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'],
      categoryId: map['categoryId'],
      brandId: map['brandId'],
      barcode: map['barcode'],
      buyingPrice: map['buyingPrice'],
      sellingPrice: map['sellingPrice'],
      isActive: map['isActive'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}

class Stock {
  final String productId;
  final int quantity;
  final int reorderLevel;
  final DateTime lastRestocked;
  final List<StockMovement> movements;

  Stock({
    required this.productId,
    required this.quantity,
    required this.reorderLevel,
    required this.lastRestocked,
    required this.movements,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'reorderLevel': reorderLevel,
      'lastRestocked': lastRestocked.toIso8601String(),
      'movements': movements.map((m) => m.toMap()).toList(),
    };
  }

  static Stock fromMap(Map<String, dynamic> map) {
    return Stock(
      productId: map['productId'],
      quantity: map['quantity'],
      reorderLevel: map['reorderLevel'],
      lastRestocked: DateTime.parse(map['lastRestocked']),
      movements: (map['movements'] as List)
          .map((m) => StockMovement.fromMap(m))
          .toList(),
    );
  }
}

class StockMovement {
  final String type;
  final int quantityChange;
  final DateTime createdAt;

  StockMovement({
    required this.type,
    required this.quantityChange,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'quantityChange': quantityChange,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static StockMovement fromMap(Map<String, dynamic> map) {
    return StockMovement(
      type: map['type'],
      quantityChange: map['quantityChange'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// Helper functions for Firebase operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Product operations
  Future<void> addProduct(Product product) async {
    await _firestore.collection(kProductsCollection).doc(product.id).set(
          product.toMap(),
        );

    // Initialize stock for the product
    await _firestore.collection(kStockCollection).doc(product.id).set({
      'productId': product.id,
      'quantity': 0,
      'reorderLevel': 5,
      'lastRestocked': DateTime.now().toIso8601String(),
      'movements': [],
    });
  }

  Future<void> createCollection(
      {required bool isCategory,
      required BuildContext context,
      required bool isBrand,
      Category? category,
      Brand? brand}) async {
    String id = isCategory ? category!.id : brand!.id;
    String collectName = isCategory ? kCategoriesCollection : kBrandsCollection;
    dynamic model = isCategory ? category : brand;
    Appbloc bloc = context.read<Appbloc>();
    try {
      bloc.changeLoading(true);
      await _firestore.collection(collectName).doc(id).set(
            model.toMap(),
          );
      Navigator.pop(context);
      Globals().snackbar(context: context, isError: false, message:"Category with name ${model.name} Was Created Successfully");

      bloc.changeLoading(false);
    } on FirebaseFirestore catch (e) {
      bloc.changeLoading(false);
           Globals().snackbar(context: context, isError:true, message:"Error $e");
      print("error");
      throw Exception('Error creating collection: $e');
    }
  }

  Future<void> updateProductPrice(
    String productId,
    double newBuyingPrice,
    double newSellingPrice,
  ) async {
    final productRef =
        _firestore.collection(kProductsCollection).doc(productId);

    await _firestore.runTransaction((transaction) async {
      final productDoc = await transaction.get(productRef);
      final product = Product.fromMap(productDoc.data()!, productDoc.id);

      // Add to price history
      transaction.update(productRef, {
        'buyingPrice': newBuyingPrice,
        'sellingPrice': newSellingPrice,
        'lastUpdated': DateTime.now().toIso8601String(),
        'priceHistory': FieldValue.arrayUnion([
          {
            'oldBuyingPrice': product.buyingPrice,
            'oldSellingPrice': product.sellingPrice,
            'newBuyingPrice': newBuyingPrice,
            'newSellingPrice': newSellingPrice,
            'updatedAt': DateTime.now().toIso8601String(),
          }
        ]),
      });
    });
  }

  // Stock operations
  Future<void> updateStock(
    String productId,
    int quantityChange,
    String movementType,
  ) async {
    final stockRef = _firestore.collection(kStockCollection).doc(productId);

    await _firestore.runTransaction((transaction) async {
      final stockDoc = await transaction.get(stockRef);
      final currentStock = Stock.fromMap(stockDoc.data()!);

      final newQuantity = currentStock.quantity + quantityChange;
      if (newQuantity < 0) {
        throw Exception('Insufficient stock');
      }

      transaction.update(stockRef, {
        'quantity': newQuantity,
        'lastRestocked': movementType == 'RESTOCK'
            ? DateTime.now().toIso8601String()
            : currentStock.lastRestocked.toIso8601String(),
        'movements': FieldValue.arrayUnion([
          {
            'type': movementType,
            'quantityChange': quantityChange,
            'createdAt': DateTime.now().toIso8601String(),
          }
        ]),
      });
    });
  }

  // Sale operations
  Future<String> createSale(
    List<Map<String, dynamic>> items,
    String? customerId,
    String paymentMethod,
  ) async {
    final batch = _firestore.batch();
    final saleRef = _firestore.collection(kSalesCollection).doc();

    double totalAmount = 0;
    for (final item in items) {
      totalAmount += (item['price'] as double) * (item['quantity'] as int);
    }

    final saleData = {
      'customerId': customerId,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': 'COMPLETED',
      'createdAt': DateTime.now().toIso8601String(),
      'items': items,
    };

    batch.set(saleRef, saleData);

    // Update stock for each item
    for (final item in items) {
      final stockRef =
          _firestore.collection(kStockCollection).doc(item['productId']);
      batch.update(stockRef, {
        'quantity': FieldValue.increment(-(item['quantity'] as int)),
        'movements': FieldValue.arrayUnion([
          {
            'type': 'SALE',
            'quantityChange': -(item['quantity'] as int),
            'createdAt': DateTime.now().toIso8601String(),
          }
        ]),
      });
    }

    // Update customer loyalty points if customer exists
    if (customerId != null) {
      final customerRef =
          _firestore.collection(kCustomersCollection).doc(customerId);
      batch.update(customerRef, {
        'loyaltyPoints': FieldValue.increment((totalAmount / 100).floor()),
      });
    }

    await batch.commit();
    return saleRef.id;
  }

  // Report generation
  Future<void> generateReport(
    String reportType,
    DateTime startDate,
    DateTime endDate,
    String userId,
  ) async {
    final reportRef = _firestore.collection(kReportsCollection).doc();

    Query query;
    if (reportType == 'STOCK') {
      query = _firestore
          .collection(kStockCollection)
          .where('lastRestocked',
              isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('lastRestocked',
              isLessThanOrEqualTo: endDate.toIso8601String());
    } else {
      query = _firestore
          .collection(kSalesCollection)
          .where('createdAt',
              isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final querySnapshot = await query.get();
    final data = querySnapshot.docs.map((doc) => doc.data()).toList();

    await reportRef.set({
      'reportType': reportType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'generatedBy': userId,
      'createdAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }
  //     Future<Map<String, dynamic>> getAllDataFromCollection(String collectionName) async {
  //   try {
  //     // Fetch all documents in the collection
  //     QuerySnapshot snapshot = await _firestore.collection(collectionName).get();

  //     List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
  //       return doc.data() as Map<String, dynamic>;
  //     }).toList();

  //     return data;

  //   } catch (e) {
  //     // Handle errors
  //     print('Error fetching data from Firestore: $e');
  //     return [];
  //   }
  // }

  Future<List<Map<String, dynamic>>> getAllDataFromCollection(
      String collectionName) async {
    try {
      // Fetch all documents in the collection
      QuerySnapshot snapshot =
          await _firestore.collection(collectionName).get();

      // Convert the documents into a list of maps
      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      return data;
    } catch (e) {
      // Handle errors
      print('Error fetching data from Firestore: $e');
      return [];
    }
  }
}
