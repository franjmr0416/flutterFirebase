class ProductDAO {
  String? cveprod;
  String? descprod;
  String? imgprod;

  ProductDAO({this.cveprod, this.descprod, this.imgprod});
  //Object -> Map
  Map<String, dynamic> toMap() {
    return {'cveprod': cveprod, 'descprod': descprod, 'imgprod': imgprod};
  }

  //Map -> Object
  factory ProductDAO.fromMap(Map<String, dynamic> map) {
    return ProductDAO(
        cveprod: map['cveprod'],
        descprod: map['descprod'],
        imgprod: map['imgprod']);
  }
}
