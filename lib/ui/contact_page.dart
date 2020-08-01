import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:agendacontatos/helpers/contact_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ContactPage extends StatefulWidget {
  //quando chamar a funcao os dados virao juntos
  final Contact contact;
  ContactPage({this.contact});//{opcional}

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  Contact _editedContact;
  bool _userEdited=false;

  @override
  void initState() {
    super.initState();

    if(widget.contact == null){//widget.contact é o contact pego da classe acima
      _editedContact= Contact();
    }else{
      _editedContact = Contact.fromMap(widget.contact.toMap());//passar de forma direta iria passar apenas a referencia
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editedContact.name ?? "Novo Contato"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
          onPressed: (){
            if(_editedContact.name != null && _editedContact.name.isNotEmpty){
              Navigator.pop(context,_editedContact);//retornando o contato para a tela anterior
            }else{//se o nome estiver vazio
              FocusScope.of(context).requestFocus(_nameFocus);//caixa de texto do nome ganha foco
            }
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape:BoxShape.circle,
                    image: DecorationImage(
                        image: _editedContact.img != null ? FileImage(File(_editedContact.img)): AssetImage("images/persona.png"),
                        fit: BoxFit.cover
                    ),
                  ),
                ),
                onTap: () {
                  _getSource(context);
                },
              ),
              TextField(decoration: InputDecoration(labelText: "Nome"),
                controller: _nameController,
                focusNode: _nameFocus,
                onChanged:(text){
                  _userEdited=true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(decoration: InputDecoration(labelText: "Email"),
                controller: _emailController,
                onChanged:(text){
                  _userEdited=true;
                  _editedContact.email=text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(decoration: InputDecoration(labelText: "Phone"),
                controller: _phoneController,
                onChanged:(text){
                  _userEdited=true;
                  _editedContact.phone=text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar Alterações?"),
            content: Text("Se sair as alterações serão perdidas"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed:(){
                  Navigator.pop(context);//voltar para edicao do contato
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed:(){
                  Navigator.pop(context);//voltar para edicao do contato
                  Navigator.pop(context);//voltar para a homepage
                },
              )
            ],
          );
        }
      );
      return Future.value(false);//nao deixar sair da tela
    }else{
      return Future.value(true);//deixar sair da tela
    }
  }

  void _getSource(BuildContext context){
    showModalBottomSheet(context: context, builder: (context){
      return BottomSheet(
        onClosing: (){},
        builder: (context){
          return Container(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  child: Text("Camera", style: TextStyle(fontSize: 20.0, color: Colors.red),),
                  onPressed: (){
                    Navigator.pop(context);
                    _selectPhoto(true);
                  },
                ),
                FlatButton(
                  child: Text("Galeria", style: TextStyle(fontSize: 20.0, color: Colors.red),),
                  onPressed: (){
                    Navigator.pop(context);
                    _selectPhoto(false);
                  },
                ),
              ],
            ),
          );
        },
      );
    });
    return null;
  }

  void _selectPhoto(bool choice) async{
    final picker = ImagePicker();
    dynamic pickedfile;

    if(choice){
      pickedfile = await picker.getImage(source: ImageSource.camera);
    }else{
      pickedfile = await picker.getImage(source: ImageSource.gallery);
    }

    File _image = File(pickedfile.path);

    setState((){
      _editedContact.img = _image.path;
    });
  }
}
