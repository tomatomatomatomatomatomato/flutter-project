import 'package:flutter/material.dart';

void main() {
  runApp(const OddyRoomApp());
}

class OddyRoomApp extends StatelessWidget {
  const OddyRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OddyRoom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class CharacterModel {
  final String id;
  final String name;
  final String personality;
  final Color color;
  String currentActivity;

  CharacterModel({
    required this.id,
    required this.name,
    required this.personality,
    required this.color,
    required this.currentActivity,
  });
}

final List<String> randomActivities = [
  '냉장고 앞에서 17분째 고민 중입니다.',
  '벽지 무늬와 대화하고 있습니다.',
  '침대 밑에 보물을 숨겼습니다.',
  '아무도 없는 복도에 인사했습니다.',
  '컵라면 뚜껑을 다시 닫았습니다.',
  '화분에게 비밀을 털어놓고 있습니다.',
  '방 한가운데서 중요한 척 서 있습니다.',
  '갑자기 청소하는 척을 시작했습니다.',
  '창밖을 보며 인생을 고민하고 있습니다.',
  '자기 이름을 까먹은 것 같습니다.',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CharacterModel?> rooms = List.generate(6, (index) => null);

  void addCharacter(int roomIndex) async {
    final newCharacter = await Navigator.push<CharacterModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCharacterScreen(),
      ),
    );

    if (newCharacter != null) {
      setState(() {
        rooms[roomIndex] = newCharacter;
      });
    }
  }

  void openCharacterDetail(CharacterModel character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterDetailScreen(character: character),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      appBar: AppBar(
        title: const Text('OddyRoom'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFDFA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: rooms.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final character = rooms[index];

            return GestureDetector(
              onTap: () {
                if (character == null) {
                  addCharacter(index);
                } else {
                  openCharacterDetail(character);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8BD),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.brown.shade200,
                    width: 3,
                  ),
                ),
                child: character == null
                    ? const Center(
                  child: Text(
                    '+ 빈 방',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CharacterAvatar(character: character, size: 80),
                    const SizedBox(height: 12),
                    Text(
                      character.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(character.personality),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final TextEditingController nameController = TextEditingController();

  String selectedPersonality = '멍함';
  Color selectedColor = Colors.pinkAccent;

  final List<String> personalities = ['멍함', '예민함', '활발함', '이상함'];

  final List<Color> colors = [
    Colors.pinkAccent,
    Colors.lightBlueAccent,
    Colors.greenAccent,
    Colors.amberAccent,
    Colors.deepPurpleAccent,
  ];

  void saveCharacter() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캐릭터 이름을 입력해 주세요!')),
      );
      return;
    }

    final character = CharacterModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      personality: selectedPersonality,
      color: selectedColor,
      currentActivity: '방에 막 입주했습니다.',
    );

    Navigator.pop(context, character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      appBar: AppBar(
        title: const Text('캐릭터 만들기'),
        backgroundColor: const Color(0xFFFFDFA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: selectedColor,
              child: const Text(
                '•ᴗ•',
                style: TextStyle(fontSize: 34),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '캐릭터 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedPersonality,
              decoration: const InputDecoration(
                labelText: '성격',
                border: OutlineInputBorder(),
              ),
              items: personalities.map((personality) {
                return DropdownMenuItem(
                  value: personality,
                  child: Text(personality),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPersonality = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              '색상 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: color,
                    child: selectedColor == color
                        ? const Icon(Icons.check, color: Colors.black)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saveCharacter,
                child: const Text(
                  '입주시키기',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterDetailScreen extends StatefulWidget {
  final CharacterModel character;

  const CharacterDetailScreen({
    super.key,
    required this.character,
  });

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  int activityIndex = 0;

  void observeCharacter() {
    setState(() {
      activityIndex = (activityIndex + 1) % randomActivities.length;
      widget.character.currentActivity = randomActivities[activityIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      appBar: AppBar(
        title: Text(character.name),
        backgroundColor: const Color(0xFFFFDFA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CharacterAvatar(character: character, size: 140),
            const SizedBox(height: 24),
            Text(
              character.name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${character.personality} 성격의 방친구',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8BD),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                character.currentActivity,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: observeCharacter,
                child: const Text(
                  '관찰하기',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterAvatar extends StatelessWidget {
  final CharacterModel character;
  final double size;

  const CharacterAvatar({
    super.key,
    required this.character,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: character.color,
      child: Text(
        '•ᴗ•',
        style: TextStyle(fontSize: size * 0.32),
      ),
    );
  }
}