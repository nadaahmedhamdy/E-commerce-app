import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/cart_item_model.dart';
import '../Models/product_model.dart';
import '../Models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  CollectionReference<Map<String, dynamic>> _cartRef(String uid) =>
      _db.collection('users').doc(uid).collection('cart');

  CollectionReference<Map<String, dynamic>> _favoritesRef(String uid) =>
      _db.collection('users').doc(uid).collection('favorites');

  // Products

  Stream<List<ProductModel>> streamAllProducts() {
    return _products.snapshots().map(
          (snap) => snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .toList(),
    );
  }

  Stream<List<ProductModel>> streamFeatured() {
    return _products
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<ProductModel>> streamPopular() {
    return _products
        .where('isPopular', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList());
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _products.doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.id, doc.data()!);
  }

  Stream<List<ProductModel>> searchProducts(String query) {
    final lower = query.toLowerCase();
    return streamAllProducts().map(
          (products) => products
          .where((p) =>
      p.name.toLowerCase().contains(lower) ||
          p.category.toLowerCase().contains(lower))
          .toList(),
    );
  }

  Future<void> seedProduct(ProductModel product) {
    return _products.doc(product.id).set(product.toMap());
  }

  //User profile

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  Stream<AppUser?> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(uid, doc.data()!) : null,
    );
  }

  // Cart

  Stream<List<CartItemModel>> streamCart(String uid) {
    return _cartRef(uid).snapshots().map(
          (snap) => snap.docs
          .map((d) => CartItemModel.fromMap(d.id, d.data()))
          .toList(),
    );
  }

  Future<void> addOrIncrementCartItem({
    required String uid,
    required ProductModel product,
    required String size,
    int quantity = 1,
  }) async {
    final itemId = '${product.id}_$size';
    final docRef = _cartRef(uid).doc(itemId);

    await _db.runTransaction((txn) async {
      final snapshot = await txn.get(docRef);
      if (snapshot.exists) {
        final current = (snapshot.data()?['quantity'] ?? 0) as int;
        txn.update(docRef, {'quantity': current + quantity});
      } else {
        final item = CartItemModel(
          id: itemId,
          productId: product.id,
          name: product.name,
          imageUrl: product.imageUrl,
          price: product.price,
          size: size,
          quantity: quantity,
        );
        txn.set(docRef, item.toMap());
      }
    });
  }

  Future<void> updateCartItemQuantity({
    required String uid,
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeCartItem(uid: uid, cartItemId: cartItemId);
      return;
    }
    await _cartRef(uid).doc(cartItemId).update({'quantity': quantity});
  }

  Future<void> removeCartItem({
    required String uid,
    required String cartItemId,
  }) {
    return _cartRef(uid).doc(cartItemId).delete();
  }

  Future<void> clearCart(String uid) async {
    final snap = await _cartRef(uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Favorites

  Stream<Set<String>> streamFavoriteIds(String uid) {
    return _favoritesRef(uid).snapshots().map(
          (snap) => snap.docs.map((d) => d.id).toSet(),
    );
  }

  Future<void> addFavorite(String uid, String productId) {
    return _favoritesRef(uid).doc(productId).set({
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String uid, String productId) {
    return _favoritesRef(uid).doc(productId).delete();
  }
}
