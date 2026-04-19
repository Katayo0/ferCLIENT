import 'package:flutter/material.dart';
import 'package:fer_client/services/api_service.dart';

class Contact {
  final String id;
  final String name;
  final bool isOnline;
  Contact({required this.id, required this.name, required this.isOnline});
}

class Msg {
  final String senderId;
  final String text;
  Msg({required this.senderId, required this.text});
}

class ChatScreen extends StatefulWidget {
  final String myLogin; 
  final bool isMockMode;

  const ChatScreen({super.key, required this.myLogin, this.isMockMode = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _api = ApiService();
  List<Contact> contacts = [];
  Contact? selectedContact;
  Map<String, List<Msg>> history = {};
  final TextEditingController _msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupNetwork();

    // mockmode - залипуха на контактах
    if (widget.isMockMode) {
      setState(() {
        contacts = [
          Contact(id: '1', name: 'Fluttershy', isOnline: true),
          Contact(id: '2', name: 'Trixie', isOnline: false),
          Contact(id: '3', name: 'Pinkie Pie', isOnline: true),
        ];
      });
    }
  }

  void _setupNetwork() {
    _api.addListener((json) {
      final type = json['type'];
      if (type == 'contacts') {
        final list = json['data'] as List;
        setState(() {
          contacts = list
              .map(
                (e) => Contact(
                  id: e['id'].toString(),
                  name: e['name'].toString(),
                  isOnline: e['is_online'] == true,
                ),
              )
              .toList();
        });
      } else if (type == 'message') {
        final senderId = json['sender_id'].toString();
        final text = json['text'].toString();
        setState(() {
          history.putIfAbsent(senderId, () => []);
          history[senderId]!.add(Msg(senderId: senderId, text: text));
        });
      }
    });
    _api.requestContacts();
  }

  void _send() {
    if (_msgCtrl.text.isEmpty || selectedContact == null) return;
    final text = _msgCtrl.text;
    setState(() {
      history.putIfAbsent(selectedContact!.id, () => []);
      history[selectedContact!.id]!.add(Msg(senderId: 'me', text: text));
      _msgCtrl.clear();
    });
    _api.send({"type": "message", "to_id": selectedContact!.id, "text": text});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'FER | ${widget.myLogin}',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow
                              .ellipsis, 
                          maxLines: 1,
                        ),
                      ),
                      if (widget.isMockMode)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Chip(
                            label: Text(
                              '🧪 MOCK',
                              style: TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: contacts.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: contacts.length,
                          itemBuilder: (ctx, i) {
                            final c = contacts[i];
                            final isSelected = selectedContact?.id == c.id;
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: const Color(0xFF2C3E50),
                              title: Text(
                                c.name,
                                style: TextStyle(
                                  color: c.isOnline
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                              leading: CircleAvatar(child: Text(c.name[0])),
                              onTap: () => setState(() => selectedContact = c),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedContact == null
                ? const Center(
                    child: Text(
                      'Выбери контакт',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        height: 50,
                        color: const Color(0xFF1F1F1F),
                        child: Center(
                          child: Text(
                            selectedContact!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(10),
                          itemCount:
                              (history[selectedContact!.id]?.length) ?? 0,
                          itemBuilder: (ctx, i) {
                            final msgs = history[selectedContact!.id]!;
                            final msg = msgs[msgs.length - 1 - i];
                            final isMe = msg.senderId == 'me';
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? const Color(0xFF005C4B)
                                      : const Color(0xFF202C33),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  msg.text,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _msgCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Сообщение...',
                                  fillColor: Color(0xFF2C2C2C),
                                  filled: true,
                                ),
                                onSubmitted: (_) => _send(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.teal),
                              onPressed: _send,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
