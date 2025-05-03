import 'package:flutter/material.dart';
import 'planner_storage.dart';
/////////////////////////////////////////////////
class PlannerScreen extends StatelessWidget{
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("My travel planner")),
      body: FutureBuilder(
        future: PlannerStorage.getSavedItems(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if(items.isEmpty){
            return const Center(child: Text("No saved places yet."));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index){
              final item = items[index];
              return ListTile(
                title: Text(item['name'] ?? 'Unamed place'),
                subtitle: Text(item['address'] ?? 'No address'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => NotesScreen(
                        placeId: item['place_id'],
                        placeName: item['name'] ?? 'Unmaed place',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
class NotesScreen extends StatefulWidget{
  final String placeId;
  final String placeName;
  const NotesScreen({super.key, required this.placeId, required this.placeName});

  @override
  State<NotesScreen> createState() => _NotesScreenState();

}
class _NotesScreenState extends State<NotesScreen>{
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }
  Future<void> loadNotes() async{
    final notes = await PlannerStorage.getNotes(widget.placeId);
    _controller.text = notes;
    setState(() => _loading = false);
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("plans for ${widget.placeName}")),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Write your plans here: ', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16,),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'E.g, visit at 10pm, meet tour group...',

                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async{
                  await PlannerStorage.saveNotes(widget.placeId, _controller.text);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes saved to firebase!')),
                  );
                },
                child: const Text('Save Notes'),
              ),
            ],
          ),
        ),
    );
  }
}