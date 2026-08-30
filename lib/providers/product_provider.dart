import 'dart:async';

import 'package:flutter/foundation.dart';

import '../Models/product_model.dart';
import '../Services/firestore_services.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> allProducts = [];
  List<ProductModel> featured = [];
  List<ProductModel> popular = [];
  List<ProductModel> searchResults = [];
  bool isLoading = true;
  bool isSearching = false;

  StreamSubscription? _allSub;
  StreamSubscription? _featuredSub;
  StreamSubscription? _popularSub;
  StreamSubscription? _searchSub;

  ProductProvider() {
    _allSub = _firestoreService.streamAllProducts().listen((products) {
      allProducts = products;
      isLoading = false;
      notifyListeners();
    });
    _featuredSub = _firestoreService.streamFeatured().listen((products) {
      featured = products;
      notifyListeners();
    });
    _popularSub = _firestoreService.streamPopular().listen((products) {
      popular = products;
      notifyListeners();
    });
  }

  void search(String query) {
    _searchSub?.cancel();
    if (query.trim().isEmpty) {
      searchResults = [];
      isSearching = false;
      notifyListeners();
      return;
    }
    isSearching = true;
    notifyListeners();
    _searchSub = _firestoreService.searchProducts(query).listen((results) {
      searchResults = results;
      notifyListeners();
    });
  }

  ProductModel? byId(String id) {
    try {
      return allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _allSub?.cancel();
    _featuredSub?.cancel();
    _popularSub?.cancel();
    _searchSub?.cancel();
    super.dispose();
  }
}
