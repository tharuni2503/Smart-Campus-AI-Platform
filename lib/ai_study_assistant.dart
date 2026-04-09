import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'groq_service.dart';
import 'package:flutter/services.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String,String>> messages = [];

  List<Map<String,dynamic>> quiz = [];

  String pdfText = "";

  bool loading = false;

  @override
  void initState() {
    super.initState();

    messages.add({
      "role": "ai",
      "text": "Hello 👋\nI am your AI Assistant. How can I help you today?"
    });
  }
  void renameChat(String docId,String currentTitle){

    TextEditingController renameController =
    TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder:(context){

        return AlertDialog(

          title: const Text("Rename Chat"),

          content: TextField(
            controller: renameController,
          ),

          actions: [

            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: (){

                FirebaseFirestore.instance
                    .collection("ai_chat")
                    .doc(docId)
                    .update({
                  "user":renameController.text
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            )

          ],
        );
      },
    );
  }

  /// Upload PDF
  Future<void> uploadPDF() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if(result == null) return;

    File file = File(result.files.single.path!);

    final bytes = file.readAsBytesSync();

    PdfDocument document = PdfDocument(inputBytes: bytes);

    pdfText = PdfTextExtractor(document).extractText();

    document.dispose();

    if(pdfText.length > 5000){
      pdfText = pdfText.substring(0,5000);
    }

    setState(() {
      messages.add({
        "role":"system",
        "text":"📄 PDF uploaded: ${result.files.single.name}"
      });
    });
  }

  /// Send Message
  Future<void> sendMessage() async {

    String text = controller.text.trim();

    if(text.isEmpty) return;

    setState(() {
      messages.add({"role":"user","text":text});
      loading = true;
    });

    controller.clear();

    String prompt;

    if(pdfText.isNotEmpty){

      prompt = """
You are a helpful AI assistant for students.

If the question relates to lecture notes, use them.
Otherwise answer normally.

User Question:
$text

Lecture Notes:
$pdfText
""";

    } else {

      prompt = text;
    }

    String reply = await GroqService.askAI(prompt);

    setState(() {
      messages.add({"role":"ai","text":reply});
      loading = false;
    });

    saveChat(text,reply);

    scrollDown();
  }

  /// Generate Quiz
  Future<void> generateQuiz() async {

    if(pdfText.isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First Upload PDF")),
      );

      return;
    }

    setState(()=>loading=true);

    String response = await GroqService.askAI(
        """
Generate 5 MCQ questions from the lecture notes.

Format:

Question: ...
A) ...
B) ...
C) ...
D) ...
Answer: A/B/C/D

$pdfText
"""
    );

    quiz = parseQuiz(response);

    setState(()=>loading=false);
  }

  /// Parse Quiz
  List<Map<String,dynamic>> parseQuiz(String text){

    List<Map<String,dynamic>> list = [];

    List<String> parts = text.split("Question:");

    for(int i=1;i<parts.length;i++){

      List<String> lines = parts[i].split("\n");

      String question = lines[0];

      List<String> options = [];
      String answer = "";

      for(String l in lines){

        if(l.startsWith("A)")||l.startsWith("B)")||l.startsWith("C)")||l.startsWith("D)")){
          options.add(l);
        }

        if(l.startsWith("Answer")){
          answer = l.replaceAll("Answer:", "").trim();
        }
      }

      list.add({
        "question":question,
        "options":options,
        "answer":answer
      });
    }

    return list;
  }

  /// Save Chat
  void saveChat(String user,String ai){

    FirebaseFirestore.instance.collection("ai_chat").add({
      "user":user,
      "ai":ai,
      "time":Timestamp.now()
    });
  }

  /// New Chat
  void newChat(){

    setState(() {
      messages.clear();
      quiz.clear();
    });
  }

  /// Scroll Down
  void scrollDown(){

    Future.delayed(const Duration(milliseconds:200),(){

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds:300),
        curve: Curves.easeOut,
      );

    });
  }

  /// Chat Bubble
  Widget bubble(String text,bool user){

    return GestureDetector(
      onLongPress: (){

        Clipboard.setData(ClipboardData(text: text));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message copied")),
        );
      },

      child: Align(
        alignment:user?Alignment.centerRight:Alignment.centerLeft,
        child:Container(
          constraints: const BoxConstraints(maxWidth: 320),
          margin:const EdgeInsets.all(8),
          padding:const EdgeInsets.all(12),
          decoration:BoxDecoration(
            color:user?Colors.blue:Colors.grey[300],
            borderRadius:BorderRadius.circular(12),
          ),
          child:Text(
            text,
            style:TextStyle(
              color:user?Colors.white:Colors.black,
              fontSize:15,
            ),
          ),
        ),
      ),
    );
  }
  /// Quiz Card
  Widget quizCard(Map<String,dynamic> q){

    String? selected;

    return StatefulBuilder(
        builder:(context,setState){

          return Card(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    q["question"],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
                ),

                ...q["options"].map<Widget>((opt){

                  bool correct = opt.startsWith(q["answer"]);

                  return RadioListTile(
                    value: opt,
                    groupValue: selected,
                    title: Text(opt),
                    tileColor: selected == opt
                        ? (correct ? Colors.green[200] : Colors.red[200])
                        : null,
                    onChanged: (val){
                      setState(()=>selected = val.toString());
                    },
                  );

                }).toList()

              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      drawer: Drawer(
        child: Column(
          children: [

            const DrawerHeader(
              child: Text(
                "Chat History",
                style: TextStyle(fontSize:20,fontWeight:FontWeight.bold),
              ),
            ),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("ai_chat")
                    .orderBy("time",descending:true)
                    .snapshots(),
                builder:(context,snapshot){

                  if(!snapshot.hasData){
                    return const Center(child:CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder:(context,index){

                      return ListTile(
                        title: Text(
                          docs[index]["user"],
                          maxLines:1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        onTap: (){

                          setState(() {

                            messages = [
                              {"role":"user","text":docs[index]["user"]},
                              {"role":"ai","text":docs[index]["ai"]}
                            ];

                          });

                          Navigator.pop(context);
                        },

                        trailing: PopupMenuButton(

                          itemBuilder: (context)=>[

                            const PopupMenuItem(
                              value:"rename",
                              child:Text("Rename Chat"),
                            ),

                            const PopupMenuItem(
                              value:"delete",
                              child:Text("Delete Chat"),
                            )

                          ],

                          onSelected:(value){

                            if(value=="rename"){
                              renameChat(docs[index].id, docs[index]["user"]);
                            }

                            if(value=="delete"){
                              FirebaseFirestore.instance
                                  .collection("ai_chat")
                                  .doc(docs[index].id)
                                  .delete();
                            }

                          },
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text("AI Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: newChat,
          )
        ],
      ),

      body: Column(

        children: [

          /// Chat Area
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [

                ...messages.map((m)=>bubble(m["text"]!,m["role"]=="user")),

                if(quiz.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Practice Quiz",
                      style: TextStyle(fontSize:18,fontWeight:FontWeight.bold),
                    ),
                  ),

                ...quiz.map((q)=>quizCard(q))

              ],
            ),
          ),

          if(loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),

          /// Quiz Button
          Container(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity,45),
              ),
              onPressed: generateQuiz,
              child: const Text(
                "Generate Practice Quiz",
                style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),
              ),
            ),
          ),

          /// Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal:10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey)),
            ),

            child: Row(

              children: [

                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: uploadPDF,
                ),

                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => sendMessage(),
                    decoration: const InputDecoration(
                      hintText: "Ask anything...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                )

              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: scrollDown,
          )
        ],
      ),
    );
  }
}