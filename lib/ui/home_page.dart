import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'package:agendacontatos/helpers/contact_helper.dart';
import 'package:agendacontatos/ui/contact_page.dart';


enum OrderOptions {orderaz,orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();
  String nameT,emailT;

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context)=> <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index){
            nameT = _reduzirStrings(contacts[index].name);
            contacts[index].email != null? emailT = _reduzirStrings(contacts[index].email):emailT="";
            return _contactCard(context, index,nameT,emailT);
          }
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index, String nameT, String emailT){
    return GestureDetector(
      onTap: (){
        _showOptions(context,index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape:BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ? FileImage(File(contacts[index].img)): AssetImage("images/persona.png"),
                    fit: BoxFit.cover
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ?? '' se a string estiver vazia
                    Text(nameT ?? "" , style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(emailT ?? "" , style: TextStyle(fontSize: 18.0,)),
                    Text(contacts[index].phone ?? "" , style: TextStyle(fontSize: 18.0))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _reduzirStrings(String texto){//17 -nome 25-email
    if(texto.contains("@")){
      if(texto.length >= 24){
        return texto.substring(0,23)+"...";
      }else{
        return texto;
      }
    }else{
      if(texto.length > 19){
        return texto.substring(0,19)+"...";
      }else{
        return texto;
      }
    }
  }

  void _showContactPage({Contact contact}) async{
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context)=>ContactPage(contact: contact,))
    );
    if(recContact != null){//foi retornado um contato do Navigator
      if(contact != null){//foi enviado um contato para a funcao showContactPage
        await helper.updateContact(recContact);
      }else{
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(context: context, builder: (context){
      return BottomSheet(
        onClosing: (){},
        builder:(context){
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                  onPressed: (){
                    if(contacts[index].phone.isNotEmpty) launch("tel:${contacts[index].phone}");
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                  onPressed: (){
                    Navigator.pop(context);//fechar janela de dialogo
                    _showContactPage(contact: contacts[index]);
                  },
                ),
                FlatButton(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                  onPressed: (){
                    _confirmRemove(index);
                  },
                )
              ],
            ),
          );
        }
      );
    });
  }

  Future<bool> _confirmRemove(index){
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Excluir Contato?"),
              content: Text("Ação não pode ser desfeita"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed:(){
                    Navigator.pop(context);
                    return Future.value(true);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed:(){
                    Navigator.pop(context);
                    helper.deleteContact(contacts[index].id);
                    setState(() {
                      contacts.removeAt(index);
                      Navigator.pop(context);
                    });
                    return Future.value(true);
                  },
                )
              ],
            );
          }
      );
      return Future.value(false);
  }

  void _getAllContacts(){
    helper.getAllContacts().then((value){
      setState(() {
        contacts=value;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a,b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a,b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {
      //atualizar a tela que sera gerada na ordem escolhida
    });
  }
}

