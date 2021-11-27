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
  FirebaseProvider _firebaseProvider = FirebaseProvider();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final fileName =
        file != null ? basename(file!.path) : 'Archivo no seleccionado';

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar producto'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Ingrese un nombre de producto';
                    }
                  },
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
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Ingrese una descipción del producto';
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: (file == null)
                        ? Image.asset('assets/noimage.png')
                        : Image.file(file!),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(fileName),
              ),
              ElevatedButton.icon(
                onPressed: selectFile,
                icon: Icon(Icons.cloud_upload_outlined),
                label: Text('Selecciona imagen'),
              ),
              task != null ? uploadStatus(task!) : Container(),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    (file == null)
                        ? _alertDialog(context, 'Agrega una fotografía')
                        : uploadProduct();
                  } else {
                    _alertDialog(context, 'Ingresa los campos vacios');
                  }
                },
                icon: Icon(Icons.cloud_done_outlined),
                label: Text('Registrar producto'),
              )
            ],
          ),
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

  Future<String?> uploadFile() async {
    if (file == null) return null;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});
    if (task == null) return null;

    final snapshot = await task!.whenComplete(() => {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    return urlDownload;
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
    if (_controllerNombre.text.isEmpty || _controllerDescripcion.text.isEmpty) {
      print('faltan datos');
      return;
    } else {
      final urlImage = await uploadFile();
      if (urlImage == null) {
        print('sin imagen');
        return;
      }

      ProductDAO productDAO = ProductDAO(
          cveprod: _controllerNombre.text,
          descprod: _controllerDescripcion.text,
          imgprod: urlImage);
      print(productDAO.toMap());
      _firebaseProvider.saveProduct(productDAO);
      Get.back();
    }
  }

  Widget? _alertDialog(context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Stack(
              clipBehavior: Clip.none,
              //overflow: Overflow.visible,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 30),
                  height: 200,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 60, 10, 10),
                    child: Column(
                      children: [
                        Text(
                          message,
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.info_outline),
                          label: Text(
                            'Aceptar',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  top: -60.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    radius: 60,
                    child: Icon(
                      Icons.unpublished_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
