import 'package:flutter/material.dart';
import 'dbHelper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DBHelper.instance;

  await dbHelper.deleteDatabase();

  await dbHelper
      .insertAuthor(const Author(id: 1, name: 'Franz Kafka', age: 40));
  await dbHelper
      .insertAuthor(const Author(id: 2, name: 'Hermann Hesse', age: 85));
  await dbHelper
      .insertAuthor(const Author(id: 3, name: 'Maxim Gorki', age: 68));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DBHelper.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text('Authors Database'),
      ),
      body: FutureBuilder<List<Author>>(
        future: dbHelper.authors(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final authors = snapshot.data!;
            return ListView.separated(
              itemCount: authors.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.black),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      'Author: ${authors[index].id}, ${authors[index].name}, ${authors[index].age}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteAuthor(authors[index].id);
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton.extended(
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => AddAuthorDialog(dbHelper: dbHelper),
            );
            setState(() {});
          },
          label: const Text('Add Author'),
          backgroundColor: const Color.fromARGB(255, 189, 245, 125),
        ),
      ),
    );
  }

  void deleteAuthor(int id) async {
    await dbHelper.deleteAuthor(id);
    setState(() {});
  }
}

class AddAuthorDialog extends StatefulWidget {
  final DBHelper dbHelper;

  const AddAuthorDialog({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _AddAuthorDialogState createState() => _AddAuthorDialogState();
}

class _AddAuthorDialogState extends State<AddAuthorDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Author'),
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: ageController,
            decoration: const InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
            maxLength: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            String name = nameController.text.trim();
            int age = int.tryParse(ageController.text) ?? 0;

            if (name.isNotEmpty && age > 0) {
              List<Author> existingAuthors = await widget.dbHelper.authors();
              int nextId = existingAuthors.length + 1;

              await widget.dbHelper
                  .insertAuthor(Author(id: nextId, name: name, age: age));
              Navigator.pop(context);
            }
          },
          child: const Text('Add Author'),
        ),
      ],
    );
  }
}
