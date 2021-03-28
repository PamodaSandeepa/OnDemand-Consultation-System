import 'package:firebaseapp/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';

class ViewPdf extends StatefulWidget {
  @override
  _ViewPdfState createState() => _ViewPdfState();
}

class _ViewPdfState extends State<ViewPdf> {
  PDFDocument doc;
  @override
  Widget build(BuildContext context) {
    //get data from first class
    String data = ModalRoute.of(context).settings.arguments;
    ViewNow() async {
      doc = await PDFDocument.fromURL(data);
      setState(() {});
    }

    Widget _loading() {
      ViewNow();
      if (doc == null) {
        Loading();
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("PDF Viewer"),
      ),
      body: doc == null ? _loading() : PDFViewer(document: doc),
    );
  }
}
