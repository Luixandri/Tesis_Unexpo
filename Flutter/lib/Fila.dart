import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'AnimatedLetter.dart';

// Fila es la encargada de la recepcion y envio de todos los datos a la BD, 
//estilo de las imagenes y monitoreo de las variables.

enum SelectionS {
  Temperatura,
  Humedad,
  Movimiento,
  Luces
}
  String valor = "temperatura";
  SelectionS sensorSelec = SelectionS.Temperatura;

 class Item {
  String key;
  String temperatura;
  String humedad;
  String movimiento;
  String lucesroom;
  String lucesbath;
  String luceskitchen;
  String lucesgaraje;

  Item(this.temperatura, this.humedad, this.movimiento, this.lucesroom, this.lucesbath,this.luceskitchen, this.lucesgaraje);
  
  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,       
        temperatura = snapshot.value['temperatura'],
         humedad = snapshot.value['humedad'],
         movimiento = snapshot.value['movimiento'],
         lucesroom = snapshot.value['lucesroom'],
         lucesbath = snapshot.value['lucesbath'],
         luceskitchen = snapshot.value['luceskitchen'],
         lucesgaraje = snapshot.value['lucesgaraje'];

 toJson() {
    return {
      "temperatura": temperatura,
      "humedad" : humedad,
      "lucesroom" : lucesroom,
      "lucesbath" : lucesbath,
      "luceskitchen" : luceskitchen,
      "lucesgaraje" : lucesgaraje,
           
    };
  } 
}


class Fila1 extends StatefulWidget{
  @override
  _Fila1State createState() => _Fila1State();
  }

class _Fila1State extends State<Fila1>{

  final List<bool> isSelected= [false, false, false,false];
  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

 @override
  void initState() {
    super.initState();
    item = Item("", "", "", "","","","");
    final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.  
    itemRef = database.reference().child('items');
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  } 
  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());
    }
  }
  @override
    Widget build(BuildContext context){

      if( sensorSelec == SelectionS.Temperatura){
         valor = 'temperatura';         
      }
      else {
        if ( sensorSelec == SelectionS.Humedad) {
          valor = 'humedad';
            }  
         
        else {
         if ( sensorSelec == SelectionS.Movimiento) {
          valor = 'movimiento';
         } 
        if ( sensorSelec == SelectionS.Luces) {
          valor = 'luces';
         }        
        }
      }
      return new Stack(
        children : <Widget> [
         new FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {

                //Comprobacion para mostrar los valores de temperatura, almacenados en DB
                if(valor == 'temperatura'){
                 return new Row(
                   children:  <Widget>[
                     //Widget para mostrar valor de temperatura
                      new InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 120, 
                            left: 60,
                          ),
                          child: Text(
                            items[index].temperatura  != null? items[index].temperatura: 'Default',
                            style: const TextStyle(
                            fontSize: 60.0,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w900
                            )
                          ),
                        ),
                      ), 
                      //Widget para la imagen.
                      new InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 100, 
                              left: 20,
                              ),
                          child: Image.asset("assets/images/temperatura1.png", width: 120, height: 230),
                          ),
                      ),                  
                   ],
                 );
                 
                //Comprobacion para mostrar los valores de humedad, almacenados en DB                
                }
                else if (valor== 'humedad'){
                 return new Row(
                   children:  <Widget>[
                      new InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 120, 
                            left: 60,
                          ),
                          child: Text(
                            items[index].humedad  != null? items[index].humedad: 'Default',
                            style: const TextStyle(
                            fontSize: 60.0,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w900
                            )
                          ),
                        ),
                      ), 

                        new InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 100, 
                              left: 20,
                              ),
                          child: Image.asset("assets/images/humedad3.png", width: 120, height: 230),
                          ),
                      ),                  
                   ],
                 );                  
                }
                //Comprobacion para mostrar los valores de movimiento, almacenados en DB
                 else if (valor== 'movimiento'){
                    if (items[index].movimiento=='AMBIENTE SEGURO'){
                        return new Stack(
                          children:  <Widget>[
                              new InkWell(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 90, 
                                    left: 10,
                                  ),
                                  child: Text(
                                    items[index].movimiento  != null? items[index].movimiento: 'Default',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                    fontSize: 50.0,
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w900,
                                    ),                           
                                  ),
                                ),
                              ), 

                                new InkWell(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 220, 
                                      left: 126,
                                      ),
                                  child: Image.asset("assets/images/casa segura1.png", width: 140, height: 140),
                                  ),
                              ), 
                          ],
                         );
                     }
                  else {
                    return new Stack(
                      children:  <Widget>[
                        new InkWell(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 130, 
                              left: 85,
                            ),
                            child: Text(
                              items[index].movimiento  != null? items[index].movimiento: 'Default',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                              fontSize: 50.0,
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w900,
                              ),                           
                            ),
                          ),
                        ), 

                          new InkWell(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 200, 
                                left: 115,
                                ),
                            child: Image.asset("assets/images/alarma.png", width: 140, height: 140),
                            ),
                        ), 
                    ],
                    );
                  }            
                } 
                  else {
                    //Diseño de botones para el encendido y apagado de luces
                    return new Stack(
                      children: <Widget>[
                        new Padding(
                          padding: EdgeInsets.only(
                            top: 140,
                            left: 50
                          ),
                           child: Letter(), 
                        ),
                        Center (
                          widthFactor: 10,
                          heightFactor: 4,
                          child: ToggleButtons(
                              children: <Widget>[
                                Icon(Icons.bed, size: 50),
                                Icon(Icons.bathtub, size: 50),
                                Icon(Icons.kitchen, size: 50),
                                Icon(Icons.garage, size: 50),
                              ],
                                onPressed: (int index) {
                                  setState(() {
                                    isSelected[index] = !isSelected[index];
                                    },
                                  );
                                  //Comprobacion del boton seleccionado para el envio de data a DB
                                  if (isSelected[0] == true){
                                      itemRef.child("-M1cg_B703splmfUU15i/lucesroom").set("ON");
                                  }
                                  else
                                    itemRef.child("-M1cg_B703splmfUU15i/lucesroom").set("OFF");

                                  if (isSelected[1] == true){
                                      itemRef.child("-M1cg_B703splmfUU15i/lucesbath").set("ON");
                                  }
                                  else
                                    itemRef.child("-M1cg_B703splmfUU15i/lucesbath").set("OFF");

                                  if (isSelected[2] == true){
                                      itemRef.child("-M1cg_B703splmfUU15i/luceskitchen").set("ON");
                                  }
                                  else
                                    itemRef.child("-M1cg_B703splmfUU15i/luceskitchen").set("OFF"); 
                                    
                                  if (isSelected[3] == true){
                                      itemRef.child("-M1cg_B703splmfUU15i/lucesgaraje").set("ON");
                                  }
                                  else { 
                                      itemRef.child("-M1cg_B703splmfUU15i/lucesgaraje").set("OFF");

                                    }                     
                                },
                                //Estilo y diseño de los botones
                                isSelected: isSelected,
                                selectedColor: Colors.green,
                                color: Colors.black,
                                fillColor: Colors.white,
                                borderWidth: 10,
                                constraints: BoxConstraints(
                                  minHeight: 100,
                                  minWidth: 60
                                )
                            )
                        ),
                      ],
                    );
                }                           
              },
        ),
        
        // Diseño de botones inferiores 
        new Container(
          margin:  new EdgeInsets.only(
            top: 500, 
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              
              InkWell(                
                child: new Column(
                  children: <Widget> [         
                    GestureDetector(
                      onTap: (){
                        setState(() {
                        sensorSelec = SelectionS.Temperatura; 
                        valor = 'temperatura';
                        });                  
                      },
                      child:  Padding(                 
                        padding: EdgeInsets.all(12.0), 
                          child: Image.asset(
                            "assets/images/temperatura2.png",
                            width: 60,
                            height: 60,
                            ),
                            ),
                    ), 
                    Text ("Temperatura",
                      style: TextStyle(
                        color: Color(0xFF973CD7),
                        fontWeight: sensorSelec == SelectionS.Temperatura ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15,                 
                        ),
                      ),                 
                    ]              
                  ) 
                ),                           

              InkWell(
              child: new Column(
                  children: <Widget> [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                        sensorSelec = SelectionS.Humedad;  
                        });
                      },
                      child:  Padding(
                        padding: EdgeInsets.all(12.0), 
                          child: Image.asset(
                            "assets/images/humedad.png",
                            width: 60,
                            height: 60,
                            ),
                            ),
                    ),
                    Text("Humedad",
                    style: TextStyle(
                      color: Color(0xFF973CD7),
                      fontWeight: sensorSelec == SelectionS.Humedad ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,                 
                      ),
                    ),                 
                  ],
                )             
                ),

              InkWell(
              child: new Column(
                  children: <Widget> [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                        sensorSelec = SelectionS.Movimiento;  
                        });
                      },
                        child:  Padding(
                            padding: EdgeInsets.all(12.0), 
                              child: Image.asset(
                                "assets/images/movimiento2.png",
                                width: 60,
                                height: 60,
                                ),
                                ),
                    ),
                    Text("Movimiento",
                    style: TextStyle(
                      color: Color(0xFF973CD7),
                      fontWeight: sensorSelec == SelectionS.Movimiento ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,                 
                      ),
                    ),                 
                  ],
                )             
                ),
              
              InkWell(
              child: new Column(
                  children: <Widget> [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                        sensorSelec = SelectionS.Luces;  
                        });                  },
                        child: Padding(
                          padding: EdgeInsets.all(12.0), 
                            child: Image.asset(
                              "assets/images/luz.png",
                              width: 60,
                              height: 60,
                              ),
                            ),
                      ),
                    Text("Luces",
                    style: TextStyle(
                      color: Color(0xFF973CD7),
                      fontWeight: sensorSelec == SelectionS.Luces ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,                 
                      ),
                    ),                 
                  ],
                )            
                ),
            ],
            )
          ),  
        ]
      );     
    }
  }

