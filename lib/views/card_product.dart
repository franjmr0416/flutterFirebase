import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CardProduct extends StatelessWidget {
  const CardProduct({Key? key, required this.productDocument})
      : super(key: key);

  final DocumentSnapshot productDocument;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      Container(
          width: MediaQuery.of(context).size.width,
          child: FadeInImage(
            placeholder: AssetImage('assetName'),
            image: NetworkImage('url'),
            fit: BoxFit.cover,
            fadeInDuration: Duration(milliseconds: 100),
            height: 230.0,
          )),
      Opacity(
        opacity: .6,
        child: Container(
          height: 55.0,
          color: Colors.black,
          child: Row(
            children: [
              Text(
                productDocument['cveprod'],
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      )
    ]);
  }
}
