import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:sanshipt/models/user.dart' as model;
import '../resources/firestore_methods.dart';
import '../resources/sanshipt_api.dart';
import '../utils/utils.dart';

class Summaryy extends StatefulWidget {
  String text;
  String type;
  Summaryy({super.key,required this.text,required this.type});

  @override
  State<Summaryy> createState() => _SummaryyState();
}

class _SummaryyState extends State<Summaryy> {
  @override
  bool isload=true;
  String summ="";
  bool save=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final List l = widget.text.split(' ');
    print(l.length);

    if(widget.text=='')
    {summ="Cannot summarize empty text!!!";isload=false;save=false;}
    else if(l.length<10 && widget.type=='text')
    {summ="Enter atleast 40 words";isload=false;save=false;}
    else {
      sendLongText(widget.text);
    }

  }

  Future<void> sendLongText(String input_text) async {
    String url = apiUrl;
    print('res start');
    try{
      final response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          // body: {}
          body: jsonEncode({
            'input_text': input_text,
            'model': 'T5',
            'min_length': 10,
            'max_length': 80,
            'input_type': widget.type,
            //'input_type': 'text',
          }));

      summ=('${jsonDecode(response.body)['output_text']}');
      print(summ);
      setState(() {
        isload=false;
      });
    }
    catch(e)
    {

      summ="Sorry could not summarize the given text.";
      setState(() {
        isload=false;
      });
      print(summ);
      print(e);
    }

    print('res end');
  }

  void uploadSummary(String title, String summary, String uid, String username) async {
    try {
      String res = "error";
      res = await FirestoreMethods().uploadPost(
        title: title,
        summary: summary,
        uid: uid,
        username: username,
      );
      if (res == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Posted"),
            )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("res"),
            )
        );
      }
      print('$res + LOLOLOL');
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
        backgroundColor:  const Color.fromARGB(255, 131, 198, 156),
        body:isload ? const Center(
            child: CircularProgressIndicator(),
        )
            : SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: save?MainAxisAlignment.spaceAround:MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Here is your summary ",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900
                      ),
                    ),
                    // Opacity(opacity: save?1:0, child: GestureDetector(onTap: () {
                    // }, child: Text("Save",style: TextStyle(color: Colors.blue, fontSize: 20),)) )
                  ],
                ),
              ),
              // SizedBox(height: 20,),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: 700,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:
                    [
                      Column(
                        children: [
                          SelectableText(
                            summ,
                            style: TextStyle(
                                fontSize: summ=="Cannot summarize empty text!!!" || summ=="Enter atleast 40 words" || summ=="Sorry could not summarize the given url. Try entering a valid url."?20:20,color: summ=="Cannot summarize empty text!!!" || summ=="Sorry could not summarize the given text."||summ=="Enter atleast 40 words"?Colors.red:Colors.black
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              save ? GestureDetector(
                child: const Text(
                  "Save",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20
                  ),
                ),
                onTap: () {
                uploadSummary("test_title", summ, user!.uid, user.username);
              })
                  : Container(),
            ],
          ),
        )
    );

  }
}