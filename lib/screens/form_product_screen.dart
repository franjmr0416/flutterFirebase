import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase/providers/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:firebase/models/product_dao.dart';
import 'package:firebase/providers/firebase_provider.dart';
import 'package:get/get.dart';

class FormProductScreen extends StatefulWidget {
  FormProductScreen({Key? key}) : super(key: key);

  @override
  _FormProductScreenState createState() => _FormProductScreenState();
}

class _FormProductScreenState extends State<FormProductScreen> {
  TextEditingController _controllerNombre = TextEditingController();
  TextEditingController _controllerDescripcion = TextEditingController();

  UploadTask? task;
  File? file;
  FirebaseProvider? _firebaseProvider;
  String? urlImage;

  @override
  Widget build(BuildContext context) {
    final fileName =
        file != null ? basename(file!.path) : 'Archivo no seleccionado';

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar producto'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    'Nombre',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                controller: _controllerNombre,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: TextFormField(
                controller: _controllerDescripcion,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    'Imagen',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Text(fileName),
            GestureDetector(
              onTap: selectFile,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: FadeInImage(
                    placeholder: NetworkImage(
                        'https://cdn.dribbble.com/users/93860/screenshots/6619359/file.png'),
                    image: NetworkImage(
                        'https://cdn.dribbble.com/users/93860/screenshots/6619359/file.png')),
              ),
            ),
            ElevatedButton.icon(
              onPressed: uploadFile,
              icon: Icon(Icons.cloud_upload_outlined),
              label: Text('Subir imagen'),
            ),
            task != null ? uploadStatus(task!) : Container(),
            ElevatedButton.icon(
              onPressed: uploadProduct,
              icon: Icon(Icons.cloud_done_outlined),
              label: Text('Registrar producto'),
            )
          ],
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});
    if (task == null) return;

    final snapshot = await task!.whenComplete(() => {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    setState(() {
      urlImage = urlDownload;
    });

    print('Download-link: $urlDownload');
  }

  Widget uploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: TextStyle(fontSize: 15),
            );
          } else {
            return Container();
          }
        },
      );

  Future uploadProduct() async {
    if (urlImage == null) return;
    ProductDAO productDAO = ProductDAO(
        cveprod: _controllerNombre.text,
        descprod: _controllerDescripcion.text,
        imgprod: urlImage);
    _firebaseProvider?.saveProduct(productDAO);
    Get.back();
  }
}
