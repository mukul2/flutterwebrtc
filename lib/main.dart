import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

// import 'package:flutter_webrtc/web/rtc_session_description.dart';

import 'package:sdp_transform/sdp_transform.dart';

import 'body.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

}

Future<FirebaseApp>customInitialize(){




  return Firebase.initializeApp();



}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: FutureBuilder(
        // Initialize FlutterFire:
        //  future: Firebase.initializeApp(),
        future: customInitialize(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text("Error"),
              ),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            //  FirebaseFirestore.instance.collection("9feb").add({"data":"data7"});





            return MyApp();


          }

          // Otherwise, show something whilst waiting for initialization to complete
          return const Scaffold(
            body: Center(
              child: Text("Loading..."),
            ),
          );
        },
      ),
    );
  }
}

var ownCandidateID = null ;
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Login( ),
    );
  }
}

class  MyHomePage extends StatefulWidget {
  dynamic ownCandidateID ;

  bool hasCallOffered = false ;

  String callerID = "0" ;

  String ownID = "0";
  String partnerid="0";
  dynamic offer;
   String title = "t";
  MyHomePage(this.ownID,this.partnerid);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _offer = false;
  RTCPeerConnection _peerConnection;
  MediaStream _localStream;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  final sdpController = TextEditingController();

  @override
  dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    sdpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initRenderers();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
     // ownOffer();
    });
    super.initState();




  }


  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _createOffer() async {
    RTCSessionDescription description = await _peerConnection.createOffer({'offerToReceiveVideo': 1,'offerToReceiveAudio':1});

    var session = parse(description.sdp);
    print("cerate off");
    print(json.encode(session));
    _offer = true;

    // print(json.encode({
    //       'sdp': description.sdp.toString(),
    //       'type': description.type.toString(),
    //     }));
    //FirebaseFirestore.instance.collection(widget.ownID).add(session);
   // print("writing my own des");

    _peerConnection.setLocalDescription(description);
    FirebaseFirestore.instance
        .collection("offer")
        .doc(widget.ownID)
        .set({"offer":json.encode(session)});


    FirebaseFirestore.instance.collection("callQue").doc(widget.partnerid).set({
      "caller": widget.ownID,
      "target": widget.partnerid,
      "active": true
    });
    FirebaseFirestore.instance.collection("callQue").doc(widget.ownID).set({
      "caller": widget.ownID,
      "target": widget.partnerid,
      "active": true
    });

    FirebaseFirestore.instance.collection("refresh").doc(widget.partnerid).set({
      "time":new DateTime.now().toString(),
      "status":true,


    });

    setState(() {
      widget.hasCallOffered = true;
    });
   // print("writing my own des end of ");
  }

  void _createAnswer() async {

    RTCSessionDescription description =
    await _peerConnection.createAnswer({'offerToReceiveVideo': 1,'offerToReceiveAudio':1});

    var session = parse(description.sdp);
    print("for "+widget.ownID);
    print(json.encode(session));
    print("for "+widget.ownID+" ends");
    // print(json.encode({
    //       'sdp': description.sdp.toString(),
    //       'type': description.type.toString(),
    //     }));
    FirebaseFirestore.instance
        .collection("offer")
        .doc(widget.ownID)
        .set({"offer":json.encode(session)});
    _peerConnection.setLocalDescription(description);

print("answer done");
    FirebaseFirestore.instance.collection("refresh").doc(widget.partnerid).set({
      "time":new DateTime.now().toString(),
      "status":true,


    });
  }
  void _createAnswerfb(String id) async {


    try{
      RTCSessionDescription description =
      await _peerConnection.createAnswer({'offerToReceiveVideo': 1});

      var session = parse(description.sdp);
      print("what is this");
     // print(json.encode(session));
      print("what is this end ");

      print(json.encode({
            'sdp': description.sdp.toString(),
            'type': description.type.toString(),
          }));
print("trying start");
     // print(description.toMap().toString());






      _peerConnection.setLocalDescription(description);
      print("trying 2");
    //  print(_peerConnection.defaultSdpConstraints.toString());
      print("trying ends");
      // FirebaseFirestore.instance
      //     .collection("offer")
      //     .doc(widget.ownID)
      //     .set({"offer":json.encode(session)});
    }catch(e){
      print("catch her e");
      print(e.toString());
    }


  }

  void _createAnswerFB(String id) async {
    RTCSessionDescription description =
    await _peerConnection.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp);
  //  print(json.encode(session));
    // print(json.encode({
    //       'sdp': description.sdp.toString(),
    //       'type': description.type.toString(),
    //     }));
    FirebaseFirestore.instance
        .collection("candidate")
        .doc(widget.ownID)
        .set({"candidate":json.encode(session) });
    _peerConnection.setLocalDescription(description);

    print("addint candidate info ");

    //FirebaseFirestore.instance.collection("callQue").doc(makeRoomName(int.parse(widget.ownID), int.parse(widget.partnerid))).update({"candidate":session});
  }
  void _setRemoteDescription() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode('$jsonString');

    String sdp = write(session, null);

    // RTCSessionDescription description =
    //     new RTCSessionDescription(session['sdp'], session['type']);
    RTCSessionDescription description =
        new RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');

    print("my suspect");
    print(description.toMap());
    print("my suspect ends");

    await _peerConnection.setRemoteDescription(description);
  }

  void _setRemoteDescriptionFB(String data) async {
    String jsonString = data;
    dynamic session = await jsonDecode('$jsonString');

    String sdp = write(session, null);

    // RTCSessionDescription description =
    //     new RTCSessionDescription(session['sdp'], session['type']);
    RTCSessionDescription description =
        new RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print("my suspect 1");
    print(description.toMap());
    print("my suspect 2 end");

    await _peerConnection.setRemoteDescription(description);

    print("now going for answer");
  //  _createAnswerfb(widget.ownID);

    _createAnswer();
  }
  void _setRemoteDescriptionNoAnswer(String data,String targetid) async {
    String jsonString = data;
    dynamic session = await jsonDecode('$jsonString');

    String sdp = write(session, null);

    // RTCSessionDescription description =
    //     new RTCSessionDescription(session['sdp'], session['type']);
    RTCSessionDescription description =
    new RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print("my suspect 3");
    print(description.toMap());
    print("my suspect 3 ends");

    await _peerConnection.setRemoteDescription(description);
    FirebaseFirestore.instance.collection("candidate").doc(targetid).get().then((value) {
      print("downloaded candidate");
      print(value.data()["candidate"]);
      _addCandidateFB(value.data()["candidate"]);
    });

  }
  void _addCandidate() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode('$jsonString');
   print("my suspect 4");
    print(session['candidate']);
    print("my suspecr 5 ends");
    dynamic candidate = new RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection.addCandidate(candidate);
  }
  void _addCandidateFB(String can) async {
    String jsonString =can;
    dynamic session = await jsonDecode('$jsonString');
    print("my suspect 4");
    print(session['candidate']);
    print("my suspecr 5 ends");
    dynamic candidate = new RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection.addCandidate(candidate);

  }
  _createPeerConnection() async {
    // Map<String, dynamic> configuration = {
    //   "iceServers": [
    //     {"url": "stun:stun.l.google.com:19302"},
    //   ]
    // };
    Map<String, dynamic> configuration2 = {
      'iceServers': [
       // {'urls': 'stun:stun.services.mozilla.com'},
       // {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:numb.viagenie.ca',
          'credential': '01620645499mkl',
          'username': 'saidur.shawon@gmail.com'
        }
      ]
    };
    Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'url': 'stun:global.stun.twilio.com:3478?transport=udp',
          'urls': 'stun:global.stun.twilio.com:3478?transport=udp'
        },
        {
          'url': 'turn:global.turn.twilio.com:3478?transport=udp',
          'username': 'fbb95df4419c3aa74d8c60b82d3b98c58294ba76a0cbde0a60c35ed881508b1c',
          'urls': 'turn:global.turn.twilio.com:3478?transport=udp',
          'credential': 'x2+dCIZX8k5ptT5unE/rzKSaFliLPnqAIKg+AwddYXw='
        },
        {
          'url': 'turn:global.turn.twilio.com:3478?transport=tcp',
          'username': 'fbb95df4419c3aa74d8c60b82d3b98c58294ba76a0cbde0a60c35ed881508b1c',
          'urls': 'turn:global.turn.twilio.com:3478?transport=tcp',
          'credential': 'x2+dCIZX8k5ptT5unE/rzKSaFliLPnqAIKg+AwddYXw='
        },
        {
          'url': 'turn:global.turn.twilio.com:443?transport=tcp',
          'username': 'fbb95df4419c3aa74d8c60b82d3b98c58294ba76a0cbde0a60c35ed881508b1c',
          'urls': 'turn:global.turn.twilio.com:443?transport=tcp',
          'credential': 'x2+dCIZX8k5ptT5unE/rzKSaFliLPnqAIKg+AwddYXw='
        }
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);
    createPeerConnection(configuration, offerSdpConstraints).then((value) {
      print("Done");
     // print(value.iceConnectionState.toString());
    });
    if (pc != null) {
      print(pc);
      print("yess error ");
    }
    pc.addStream(_localStream);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print("supecrt 7");

        dynamic data =({'candidate': e.candidate.toString(), 'sdpMid': e.sdpMid.toString(), 'sdpMlineIndex': e.sdpMlineIndex,});

      if(ownCandidateID==null){
        ownCandidateID = data ;
      }
        FirebaseFirestore.instance.collection("candidate").doc(widget.ownID).set({"candidate":jsonEncode(ownCandidateID)});
        print(json.encode({'candidate': e.candidate.toString(), 'sdpMid': e.sdpMid.toString(), 'sdpMlineIndex': e.sdpMlineIndex,}));
        print("supecrt 7 end");
      }
    };

    pc.onIceConnectionState = (e) {
      print("ICE CONNEC SRAT");
      print(e);
      print("ICE CONN END");
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
    };
   // ownOffer(pc);





    //
    return pc;
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.getUserMedia(mediaConstraints);

    // _localStream = stream;
    _localRenderer.srcObject = stream;
   // _localRenderer.mirror = true;

    // _peerConnection.addStream(stream);

    return stream;
  }

  SizedBox videoRenderers() => SizedBox(
      height: 500,
      child: Row(children: [
        Flexible(
          child: new Container(
              key: new Key("local"),
              margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: new BoxDecoration(color: Colors.black),
              child: new RTCVideoView(_localRenderer)),
        ),
        Flexible(
          child: new Container(
              key: new Key("remote"),
              margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: new BoxDecoration(color: Colors.black),
              child: new RTCVideoView(_remoteRenderer)),
        )
      ]));

  Widget screenView() {
    return Center(
      child: Container(
        color: Colors.grey,

       width:  MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height-110,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.bottomCenter,
                child: new RTCVideoView(_remoteRenderer)),
            Align(
                alignment: Alignment.bottomCenter,
                child:       RaisedButton(
                  onPressed: () {

                    //only for the caller

                    setState(() {
                      widget.callerID = widget.ownID ;
                    });
                    _createOffer();





//makeRoomName(int.parse(widget.ownID), int.parse(widget.partnerid))

                    // FirebaseFirestore.instance.collection("callRequest").add({"target":widget.partnerid,"creator":widget.ownID,"offer":widget.offer});
                  },
                  child: Text("Call"),
                ),),
            Positioned(
              right: 5,
              bottom: 0,
              child: Container(
                height: 200,
                width: 200,
                child: Container(
                    key: new Key("local"),
                    margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    decoration: new BoxDecoration(color: Colors.black),
                    child: new RTCVideoView(_localRenderer)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Row offerAndAnswerButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        new RaisedButton(
          // onPressed: () {
          //   return showDialog(
          //       context: context,
          //       builder: (context) {
          //         return AlertDialog(
          //           content: Text(sdpController.text),
          //         );
          //       });
          // },
          onPressed: _createOffer,
          child: Text('Offer'),
          color: Colors.amber,
        ),
        RaisedButton(
          onPressed: _createAnswer,
          child: Text('Answer'),
          color: Colors.amber,
        ),
      ]);

  Row sdpCandidateButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        RaisedButton(
          onPressed: _setRemoteDescription,
          child: Text('Set Remote Desc'),
          color: Colors.amber,
        ),
        RaisedButton(
          onPressed: _addCandidate,
          child: Text('Add Candidate'),
          color: Colors.amber,
        )
      ]);

  Padding sdpCandidatesTF() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: sdpController,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          maxLength: TextField.noMaxLength,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.ownID),
        ),
        body: Container(
            child: Column(children: [
          // videoRenderers(),
          screenView(),



              Container(
                // onPressed: () {
                //   //for receiver
                //   print("clicked 1");
                //
                //
                //
                //   FirebaseFirestore.instance.collection("callQue").doc(widget.ownID).get().then((value) {
                //     String callerid = value.data()["caller"];
                //     print("clicked 3");
                //     FirebaseFirestore.instance.collection("offer").doc(callerid).get().then((value) {
                //       print("clicked 4");
                //
                //       print("downloaded offer from caller by receiver");
                //       print(callerid);
                //
                //
                //       print("now seting remote desc from caller by receiver");
                //       print(value.data()["offer"]);
                //        _setRemoteDescriptionFB(value.data()["offer"]);
                //        print("should happend everything abothe this");
                //
                //
                //
                //     });
                //   });
                //
                //   // FirebaseFirestore.instance.collection("callRequest").add({"target":widget.partnerid,"creator":widget.ownID,"offer":widget.offer});
                // },
                child:  widget.callerID == widget.ownID?Text("Not applicable",style: TextStyle(color: Colors.white),):   Container(
                  height: 00,
                  child: StreamBuilder(
                    stream:  FirebaseFirestore.instance.collection("refresh").doc(widget.ownID).snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (!snapshot.hasData || snapshot.hasError || snapshot.data == null) {
                          return Text("wait");
                        } else {
                          dynamic data = snapshot.data.data();
                          if(data!=null && data["status"]!=null && data["status"]){
                            FirebaseFirestore.instance.collection("callQue").doc(widget.ownID).get().then((value) {
                              String callerid = value.data()["caller"];
                              print("clicked 3");
                              FirebaseFirestore.instance.collection("offer").doc(callerid).get().then((value) {
                                print("clicked 4");

                                print("downloaded offer from caller by receiver");
                                print(callerid);
                                print("now seting remote desc from caller by receiver");
                                print(value.data()["offer"]);
                              if( widget.callerID == widget.ownID){

                              } else {
                                _setRemoteDescriptionFB(value.data()["offer"]);
                              }
                                print("should happend everything abothe this");

                                //
                                // FirebaseFirestore.instance.collection("refresh").doc(widget.partnerid).set({
                                //   "time":new DateTime.now().toString(),
                                //   "status":true,
                                //
                                //
                                // });


                                // FirebaseFirestore.instance.collection("refresh").doc(widget.ownID).set({
                                //   "time":new DateTime.now().toString(),
                                //   "status":false,
                                //
                                //
                                // });

                              //  FirebaseFirestore.instance.collection("refresh").doc(widget.ownID).delete();

                              });
                            });
                          }
                          return Text(data["status"].toString(),style: TextStyle(color: Colors.white));
                        }
                      } else {
                        return const Center(
                          child: Text("Loading...",style: TextStyle(color: Colors.white)),
                        );
                      }
                    },
                  ),
                ),
              //  child: Text("receive Call only for receiver"),
              ),
              Container(
                //caller again

                child: widget.callerID == widget.ownID? Container(
                  height: 00,
                  child: StreamBuilder(
                    stream:  FirebaseFirestore.instance.collection("refresh").doc(widget.ownID).snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.data == null) {
                          return Text("Remote is not ready",style: TextStyle(color: Colors.white));
                        }

                          if(  snapshot.data!=null && snapshot.data.data()!=null&&  snapshot.data.data()["status"]!=null &&  snapshot.data.data()["status"]==true){

                           FirebaseFirestore.instance.collection("callQue").doc(widget.ownID).get().then((value) {
                              String callerid = value.data()["target"];
                              print("downloading target user");
                              print("target user id "+callerid);
                              FirebaseFirestore.instance.collection("offer").doc(callerid).get().then((value) {
                                print("downloading target users offer des");
                                print("downloaded offer");
                                print(value.data()["offer"]);
                               if( widget.callerID == widget.ownID) {
                                 _setRemoteDescriptionNoAnswer(
                                     value.data()["offer"], callerid);
                               }
                                //

                                return Text("Remote is ready",style: TextStyle(color: Colors.white));



                                //  print("clicked 5");
                                print("ignor now");
                                try{

                                }catch(e){

                                }
                                print("ignor nown ends");

                                // _createAnswerfb(widget.ownID);
                              });
                            });
                        return Text("Remote is ready",style: TextStyle(color: Colors.white));
                          }
                        return Text("Remote is not ready",style: TextStyle(color: Colors.white));

                      } else {
                        return  Center(
                          child: Text("Remote is not ready",style: TextStyle(color: Colors.white)),
                        );
                      }
                    },
                  ),
                ):Text("Non applicable",style: TextStyle(color: Colors.white)),
              //  child: Text("See Response from receiver only for caller"),
              ),
          /*
          Container(
            height: 40,
            child:(widget.ownID != "0" && widget.partnerid != "0")?  StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection("callQue").doc(makeRoomName(int.parse(widget.ownID), int.parse(widget.partnerid))).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                 print("going to set remotdes");

                 if(snapshot.hasData){
                   try{

                     FirebaseFirestore.instance.collection("offer").doc(snapshot.data.data()["caller"]).get().then((value) {
                       _setRemoteDescriptionFB(value.data()["offer"]);
                       print("sownloaded offer start");
                       print(value.data()["offer"]);
                       print("sownloaded offer end");
                     });


                   }catch(e){
                     print("catch 2 " +e.toString());
                   }
                 }




                 print("going to create answer");
                 try{
                   _createAnswer();
                 }catch(e){
                   print("catch 3" +e.toString());
                 }
/*
                  if(snapshot.hasData){
                    if(snapshot.data.data()["candidate"]!=null){
                      print("addint to candidate");
                      try{
                        _addCandidateFB(snapshot.data.data()["candidate"]);
                      }catch(e){
                        print("catch 4");
                      }


                    }
                  }
                  */


                  return Text(snapshot.hasData?snapshot.data.data().toString():"No Data");


                }):Center(
              child: Text("Wait"),
            ),
          ),
          */
          // offerAndAnswerButtons(),
          // sdpCandidatesTF(),
          // sdpCandidateButtons(),
        ])));
  }
}
String makeRoomName(int one,int two){
  if(one>two)return ""+one.toString()+"-"+two.toString();
  else return ""+two.toString()+"-"+one.toString();
}

class Login extends StatefulWidget {
  String ownID,partnerid;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(
      child:
      Card(
        color: Colors.white,
        child: Container(
          height: 250,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Your Name",
                      contentPadding: EdgeInsets.all(10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        widget.ownID = value;
                      });
                    },
                  ),
                ),
              ),
              Container(

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "partner Name",
                      contentPadding: EdgeInsets.all(10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        widget.partnerid = value;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed:(){
                    FirebaseFirestore.instance.collection("refresh").doc(widget.ownID).delete();
                    FirebaseFirestore.instance.collection("refresh").doc(widget.partnerid).delete();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(widget.ownID,widget.partnerid)),
                    );
                  } ,
                  child: Text("Login"),
                ),
              )
            ],
          ),
        ),
      ),
    ),);
  }
}

