import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/models/product_dao.dart';

class FirebaseProvider {
  late FirebaseFirestore _firestore;
  late CollectionReference _productCollection;

  FirebaseProvider() {
    _firestore = FirebaseFirestore.instance;
    _productCollection = _firestore.collection('products');
  }

  Future<void> saveProduct(ProductDAO objPDAO) {
    return _productCollection.add(objPDAO.toMap());
  }

  Future<void> updateProduct(ProductDAO objPDAO, String DocumentID) {
    return _productCollection.doc(DocumentID).update(objPDAO.toMap());
  }

  Future<void> deleteProduct(String DocumentID) {
    return _productCollection.doc(DocumentID).delete();
  }

  Stream<QuerySnapshot> getAllProducts() {
    return _productCollection.snapshots();
  }
}
