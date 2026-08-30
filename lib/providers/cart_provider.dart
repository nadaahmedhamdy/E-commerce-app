import 'dart:async';

import 'package:flutter/foundation.dart';

import '../Models/cart_item_model.dart';
import '../Models/product_model.dart';
import '../Services/firestore_services.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription<List<CartItemModel>>? _cartSub;
  List<CartItemModel> items = [];
  String? _uid;
  bool isLoading = false;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get shipping => items.isEmpty ? 0 : 15.0;

  double get total => subtotal + shipping;

  void bindToUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _cartSub?.cancel();
    items = [];

    if (uid == null) {
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    _cartSub = _firestoreService.streamCart(uid).listen((cartItems) {
      items = cartItems;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addToCart(ProductModel product, String size,
      {int quantity = 1}) async {
    if (_uid == null) return;
    await _firestoreService.addOrIncrementCartItem(
      uid: _uid!,
      product: product,
      size: size,
      quantity: quantity,
    );
  }

  Future<void> incrementQuantity(CartItemModel item) async {
    if (_uid == null) return;
    await _firestoreService.updateCartItemQuantity(
      uid: _uid!,
      cartItemId: item.id,
      quantity: item.quantity + 1,
    );
  }

  Future<void> decrementQuantity(CartItemModel item) async {
    if (_uid == null) return;
    await _firestoreService.updateCartItemQuantity(
      uid: _uid!,
      cartItemId: item.id,
      quantity: item.quantity - 1,
    );
  }

  Future<void> removeItem(CartItemModel item) async {
    if (_uid == null) return;
    await _firestoreService.removeCartItem(uid: _uid!, cartItemId: item.id);
  }

  Future<void> clearCart() async {
    if (_uid == null) return;
    await _firestoreService.clearCart(_uid!);
  }

  @override
  void dispose() {
    _cartSub?.cancel();
    super.dispose();
  }
}
