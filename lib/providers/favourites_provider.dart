import 'dart:async';

import 'package:flutter/foundation.dart';

import '../Models/product_model.dart';
import '../Services/firestore_services.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription<Set<String>>? _sub;
  Set<String> favoriteIds = {};
  String? _uid;
  bool isLoading = false;

  bool isFavorite(String productId) => favoriteIds.contains(productId);

  void bindToUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _sub?.cancel();
    favoriteIds = {};

    if (uid == null) {
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    _sub = _firestoreService.streamFavoriteIds(uid).listen((ids) {
      favoriteIds = ids;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> toggleFavorite(ProductModel product) async {
    if (_uid == null) return;
    if (isFavorite(product.id)) {
      await _firestoreService.removeFavorite(_uid!, product.id);
    } else {
      await _firestoreService.addFavorite(_uid!, product.id);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
