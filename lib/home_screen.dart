import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile/profile_screen.dart';
import 'find_buddy_screen.dart';
import '/chatting/chat_rooms_screen.dart';
import 'services/places_service.dart';
import 'services/attraction_detail_screen.dart';
import 'services/planner_screen.dart'; // <-- new import for More Info screen

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}
class _HomeScreenState extends State<HomeScreen>{
  int _selectedIndex =0;
  List<Map<String, dynamic>> attractions = [];
  bool isLoadingAttractions = true;
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState(){
    super.initState();
    loadAttractions();
  }
  Future<void> loadAttractions() async{
    final service = PlacesService();
    try{
      final results = await service.fetchAttractions(48.8566, 2.3522); //paris
      setState(() {
        attractions = results;
        isLoadingAttractions = false;
      });
      print('attractions loaded: $results');

    } catch(e) {
      print('Error fetching attractions: $e');
      setState(() {
        isLoadingAttractions = false;
      });
    }
  }
  void _onItemTapped(int index){
    if(index == 1){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatRoomsScreen()),
      );
    } else if(index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlannerScreen()),
      );

    
    } else{
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  @override
  Widget build(BuildContext context){
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel buddy home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? SingleChildScrollView(
            child: Column(
              //final TextingEditingController _locationController = TextingEditingController();
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Welcome, ${user?.email ?? 'Guest'}!',
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            hintText: 'Enter city or country',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async{
                          final query = _locationController.text.trim();
                          if (query.isNotEmpty){
                            setState(() => isLoadingAttractions = true);
                            try{
                              final results = await PlacesService().fetchAttractionsByQuery(query);
                              setState(() {
                                attractions = results;
                                isLoadingAttractions = false;
                              });
                            }catch(e){
                              setState(() => isLoadingAttractions = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to fetch attraction')),
                              );
                            }
                          }
                        }, 
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FindBuddyScreen()),
                    );
                  },
                  child: const Text('Find a travel buddy'),              
                ),
                const SizedBox(height: 30),
                const Text(
                  'Popular Attractions Nearby:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                isLoadingAttractions
                  ? const CircularProgressIndicator()
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attractions.length,
                    itemBuilder: (context,index){
                      final attraction = attractions[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(attraction['name']),
                        subtitle: Text('Rating: ${attraction['rating'] ?? 'N/A'}\nAddress: ${attraction['address']}'),
                        isThreeLine: true,
                        onTap: (){
                          final placeId = attraction['place_id'];
                          if(placeId != null && placeId is String){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AttractionDetailScreen(placeId: placeId),
                              ),
                            );
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('cannt open details: Missing place information')),
                            );
                          }
                        },
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          )
          : const SizedBox.shrink(),
        bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Planner',
              ),
            ],
        ),
    );
  }
}
              
                           