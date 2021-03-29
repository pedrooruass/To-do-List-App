// FEITO - permitir o editar
// FEITO - apagar
// FEITO(Localmente) - banco de dados

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "To do List",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyScreen(),
    );
  }
}

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
// String - Tarefa
// Boll  - Concluido

  final tarefaController = TextEditingController();

// Tarefas
  List<dynamic> tarefas = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final focoCampo = FocusNode();

  int tarefaEmEdicaoIndex;

  /// Buscar o arquivo no sistema operacional
  Future<File> buscarArquivo() async {
    //  Acessando a pasta no sisitema tanto Ios quanto Android
    Directory appDocDir = await getApplicationDocumentsDirectory();

    final file = File("${appDocDir.path}/dados.json");

    if (!file.existsSync()) {
      file.createSync();
    }

    return file;
  }

  /// Salvar dados no arquivo
  Future<void> salvarDados() async {
    String dadosJson = jsonEncode(tarefas);

    File arquivo = await buscarArquivo();

    arquivo.writeAsString(dadosJson);
  }

  /// Lê os dados salvos localmente
  Future<void> leDados() async {
    // Recupera arquivo
    File arquivo = await buscarArquivo();

    String dadosJson = await arquivo.readAsString();
    if (dadosJson != null && dadosJson.isNotEmpty) {
      setState(() {
        // Coloca o json ja transcrito na minha lista "Tarefas"
        tarefas = jsonDecode(dadosJson);
      });
    }
  }

  ///  Método para atualizar os valores e ordenar
  Future<void> atualizar() async {
    // Aplicando um delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      tarefas.sort((a, b) {
        if (a["done"] && !b["done"]) {
          return 1;
        } else if (!a["done"] && b["done"]) {
          return -1;
        } else {
          return 0;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Ler os dados salvos localmente e apresentar na tela
    leDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // App
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.check),
            SizedBox(
              width: 5,
            ),
            Text("To do list"),
          ],
        ),
        centerTitle: true,
      ),

      // Corpo
      body: Column(
        children: [
          //lista
          Expanded(
            child: RefreshIndicator(
              onRefresh: atualizar,
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 10,
                  );
                },
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: tarefas.length,
                itemBuilder: (BuildContext context, int index) {
                  //
                  //
                  //
                  // Tile da Tarefa
                  return tileTarefa(index);
                  //
                  //
                  //
                },
              ),
            ),
          ),

          // Campo de Texto e batão
          Container(
            padding: EdgeInsets.all(5),
            color: Colors.grey,
            child: IntrinsicHeight /* Arrruma erro do stretch*/ (
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo de Texto
                  Expanded(
                    child: TextField(
                      controller: tarefaController,
                      decoration: InputDecoration(
                        hintText: "Digite uma tarefa",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(.7)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 5)),
                      ),
                    ),
                  ),

                  SizedBox(width: 5),

                  RaisedButton(
                    color: Colors.red,
                    onPressed: () {
                      if (tarefaController.text.isEmpty) {
                        // fechando o teclado
                        FocusScope.of(context).unfocus();

                        // Mensagem
                        final snackBar = SnackBar(
                          content: Text(
                            "Digite uma Tarefa Por Favor!!",
                          ),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.red,
                        );

                        scaffoldKey.currentState.showSnackBar(snackBar);
                      } else {
                        setState(() {
                          // Adicionando tarefa na lista
                          tarefas.add(
                              {"text": tarefaController.text, "done": false});

                          // Limpando campo de texto
                          tarefaController.clear();

                          // fechando o teclado
                          FocusScope.of(context).unfocus();

                          // Salvando os dados localmente
                          salvarDados();
                        });
                      }
                    },
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Tile Tarefo
  Widget tileTarefa(int index) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      background: Container(
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(7)),
        child: Row(
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              "Remove",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      // Editar
      secondaryBackground: Container(
        padding: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Editar",
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.edit, color: Colors.white),
          ],
        ),
      ),
      // direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          print("Remover");
          final tarefaParaRemover = tarefas[index];

          setState(() {
            tarefas.removeAt(index);
          });

          // Mensagem
          final snackBar = SnackBar(
            content: Text(
              "Sua Tarefa \"${tarefaParaRemover["text"]}\" foi removida",
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          );

          scaffoldKey.currentState.showSnackBar(snackBar);

          // Salvando os dados localmente
          salvarDados();
        } else {
          /// Atualizar
          // "Editar"
          setState(() {
            tarefaEmEdicaoIndex = index;
          });

          // Requisitando o foco no campo de texto
          FocusScope.of(context).requestFocus(focoCampo);

          // Salvando os dados localmente
          salvarDados();
        }
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: !tarefas[index]["done"]
              ? Colors.grey.withOpacity(.4)
              : Colors.grey,
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        //
        //
        //
        child: CheckboxListTile(
          onChanged: (valor) {
            setState(() {
              tarefas[index]["done"] = valor;
            });
            // Salvando os dados localmente
            salvarDados();
          },
          value: tarefas[index]["done"],
          title: Visibility(
            replacement: TextFormField(
              focusNode: focoCampo,
              onFieldSubmitted: (valor) {
                setState(() {
                  tarefas[index]["text"] = valor;
                  // fazendo com que volte a ser o campo de texto
                  tarefaEmEdicaoIndex = null;

                  // fechando o teclado
                  FocusScope.of(context).unfocus();

                  // Salvando os dados localmente
                  salvarDados();
                });
              },
              autofocus: true,
              controller: TextEditingController(text: tarefas[index]["text"]),
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
            visible: tarefaEmEdicaoIndex != index,
            child: Text(
              tarefas[index]["text"],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                decoration: tarefas[index]["done"]
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          secondary: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
                tarefas[index]["done"]
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}
