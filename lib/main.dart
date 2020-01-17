import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const url = "";

main(List<String> args) async {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Color(0xFFFFDB71),
      ),
    )
  );
}


/* função para pegar os dados da API */
Future<Map> getData() async {
  /* faz uma requisição de forma assincrona */
  http.Response response = await http.get(url);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _realController = TextEditingController();
  final _dolarController = TextEditingController(); 
  final _euroController = TextEditingController();

  double _dolar;
  double _euro;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    
    double real = double.parse(text);

    _dolarController.text = (real/_dolar).toStringAsFixed(2);
    _euroController.text = (real/_euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    
    double dolar = double.parse(text);

    _realController.text = (dolar * _dolar).toStringAsFixed(2);
    _euroController.text = (dolar * _dolar / _euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
  
    double euro = double.parse(text);

    _realController.text = (euro * _euro).toStringAsFixed(2);
    _dolarController.text = (euro * _euro / _dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    _realController.text = "";
    _dolarController.text = "";
    _euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F4EB),
      appBar: AppBar(
        title: Text("Conversor de Moedas"),
        backgroundColor: Color(0xFFFFDB71),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando...",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                  ),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "API não disponível",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                    ),
                  ),
                );
              }
              else {

                _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding:EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on, 
                        size: 150.0, 
                        color: Color(0xFFFFDB71),
                      ),
                      buildTextField("Reais", "R\$ ", _realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "U\$ ", _dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€ ", _euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String text, String prefix, TextEditingController c, Function converterValores) {
  return TextField(
    keyboardType: TextInputType.number,
    onChanged: converterValores,
    controller: c,
    decoration: InputDecoration(
      labelText: text,
      labelStyle: TextStyle(
        color: Color(0x44000000),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      prefixText: prefix
    ),
    style: TextStyle(
      color: Color(0xFF000000),
      fontSize: 18.0
    ),
  );
}