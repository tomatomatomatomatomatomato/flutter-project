import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadAppData();
  runApp(const OddyRoomApp());
}

const Color bg = Color(0xFFFFF7E8);
const Color topBar = Color(0xFFFFDFA3);
const Color card = Color(0xFFFFE8BD);
const Color floor = Color(0xFFE9B77E);
const Color lavender = Color(0xFFD8C7FF);
const Color pink = Color(0xFFFFB6C1);
const Color yellow = Color(0xFFFFD45C);

class OddyRoomApp extends StatelessWidget {
  const OddyRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OddyRoom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: 390,
            child: child,
          ),
        );
      },
      home: const StartScreen(),
    );
  }
}

class CharacterModel {
  final String name;
  final String personality;
  final List<List<Color?>> pixels;

  CharacterModel({
    required this.name,
    required this.personality,
    required this.pixels,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'personality': personality,
      'pixels': pixels
          .map((row) => row.map((color) => color?.value).toList())
          .toList(),
    };
  }

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      name: json['name'],
      personality: json['personality'],
      pixels: (json['pixels'] as List).map<List<Color?>>((row) {
        return (row as List).map<Color?>((value) {
          if (value == null) return null;
          return Color(value);
        }).toList();
      }).toList(),
    );
  }
}


class SnackItem {
  final String id;
  final String emoji;
  final String name;
  final int price;
  final int hungerGain;
  final int happinessGain;

  const SnackItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.price,
    required this.hungerGain,
    required this.happinessGain,
  });
}

class ToyItem {
  final String id;
  final String emoji;
  final String name;
  final int price;
  final int happinessBonus;

  const ToyItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.price,
    required this.happinessBonus,
  });
}

const List<SnackItem> snackItems = [
  SnackItem(id: 'cookie', emoji: '🍪', name: '쿠키', price: 5, hungerGain: 22, happinessGain: 5),
  SnackItem(id: 'milk', emoji: '🥛', name: '우유', price: 7, hungerGain: 30, happinessGain: 4),
  SnackItem(id: 'cake', emoji: '🍰', name: '케이크', price: 12, hungerGain: 38, happinessGain: 12),
  SnackItem(id: 'bento', emoji: '🍱', name: '도시락', price: 18, hungerGain: 60, happinessGain: 8),
];

const List<ToyItem> toyItems = [
  ToyItem(id: 'gamepad', emoji: '🎮', name: '기본 게임기', price: 0, happinessBonus: 10),
  ToyItem(id: 'doll', emoji: '🧸', name: '곰 인형', price: 20, happinessBonus: 10),
  ToyItem(id: 'blocks', emoji: '🧱', name: '블록 장난감', price: 35, happinessBonus: 15),
  ToyItem(id: 'robot', emoji: '🤖', name: '삐걱 로봇', price: 80, happinessBonus: 30),
  ToyItem(id: 'musicBox', emoji: '🎵', name: '멜로디 상자', price: 120, happinessBonus: 45),
];

Map<String, int> snackInventory = {
  'cookie': 3,
  'milk': 0,
  'cake': 0,
  'bento': 0,
};

Map<String, int> toyInventory = {
  'doll': 0,
  'blocks': 0,
  'robot': 0,
  'musicBox': 0,
};

int get totalSnackCount => snackInventory.values.fold(0, (sum, count) => sum + count);
int get totalToyCount => toyInventory.values.fold(0, (sum, count) => sum + count);

SnackItem snackById(String id) {
  return snackItems.firstWhere((item) => item.id == id, orElse: () => snackItems.first);
}

ToyItem toyById(String id) {
  return toyItems.firstWhere((item) => item.id == id, orElse: () => toyItems.first);
}

List<CharacterModel?> apartmentRooms = List.generate(6, (_) => null);
List<String> roomMessages = List.generate(6, (_) => '아직 아무도 살지 않아요.');
int coin = 0;

Future<void> saveAppData() async {
  final prefs = await SharedPreferences.getInstance();

  final roomData = apartmentRooms.map((character) {
    return character?.toJson();
  }).toList();

  await prefs.setString('apartmentRooms', jsonEncode(roomData));
  await prefs.setStringList('roomMessages', roomMessages);
  await prefs.setInt('coin', coin);
  await prefs.setString('snackInventory', jsonEncode(snackInventory));
  await prefs.setString('toyInventory', jsonEncode(toyInventory));
}

Future<void> loadAppData() async {
  final prefs = await SharedPreferences.getInstance();

  final roomString = prefs.getString('apartmentRooms');
  final messageList = prefs.getStringList('roomMessages');
  coin = prefs.getInt('coin') ?? 0;
  final snackInventoryString = prefs.getString('snackInventory');
  final toyInventoryString = prefs.getString('toyInventory');
  final savedToyIds = prefs.getStringList('ownedToyIds');

  if (snackInventoryString != null) {
    final decodedSnacks = Map<String, dynamic>.from(jsonDecode(snackInventoryString));
    snackInventory = {
      for (final item in snackItems)
        item.id: (decodedSnacks[item.id] as int?) ?? 0,
    };
  } else {
    final oldSnackCount = prefs.getInt('snackCount');
    snackInventory = {
      for (final item in snackItems) item.id: 0,
    };
    snackInventory['cookie'] = oldSnackCount ?? 3;
  }

  if (toyInventoryString != null) {
    final decodedToys = Map<String, dynamic>.from(jsonDecode(toyInventoryString));
    toyInventory = {
      for (final item in toyItems.where((toy) => toy.id != 'gamepad'))
        item.id: (decodedToys[item.id] as int?) ?? 0,
    };
  } else {
    toyInventory = {
      for (final item in toyItems.where((toy) => toy.id != 'gamepad'))
        item.id: 0,
    };

    // 예전 저장 방식(보유/미보유)으로 저장된 장난감이 있으면 1개 보유로 옮겨줍니다.
    if (savedToyIds != null && savedToyIds.isNotEmpty) {
      for (final id in savedToyIds) {
        if (id != 'paperBall' && id != 'gamepad' && toyInventory.containsKey(id)) {
          toyInventory[id] = 1;
        }
      }
    }
  }

  if (roomString != null) {
    final decoded = jsonDecode(roomString) as List;

    apartmentRooms = decoded.map<CharacterModel?>((data) {
      if (data == null) return null;
      return CharacterModel.fromJson(Map<String, dynamic>.from(data));
    }).toList();
  }

  if (messageList != null && messageList.length == 6) {
    roomMessages = messageList;
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void goStart(BuildContext context) {
    final firstRoom = apartmentRooms.indexWhere((room) => room != null);

    if (firstRoom != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            character: apartmentRooms[firstRoom]!,
            roomIndex: firstRoom,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomizeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // 은은한 배경 장식
            Positioned.fill(
              child: CustomPaint(
                painter: StartBackgroundPainter(),
              ),
            ),

            const Positioned(
              top: 90,
              right: 60,
              child: Text('☁️', style: TextStyle(fontSize: 34)),
            ),
            const Positioned(
              top: 170,
              left: 44,
              child: Text('✦', style: TextStyle(fontSize: 28, color: Colors.amber)),
            ),
            const Positioned(
              bottom: 255,
              left: 48,
              child: Text('☁️', style: TextStyle(fontSize: 32)),
            ),
            const Positioned(
              bottom: 310,
              right: 72,
              child: Text('💗', style: TextStyle(fontSize: 34)),
            ),

            // 아래 마을 장식
            Positioned(
              left: 0,
              right: 0,
              bottom: 145,
              child: SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: TinyTownPainter(),
                ),
              ),
            ),

            // 작은 캐릭터 마스코트
            Positioned(
              left: 0,
              right: 0,
              bottom: 245,
              child: Center(
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: CustomPaint(
                    painter: StartMascotPainter(),
                  ),
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'OddyRoom',
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2B2018),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '내가 그린 친구들이\n사는 작은 방',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 245),
                    _button('시작하기', pink, () => goStart(context)),
                    const SizedBox(height: 14),
                    _button('방 구경하기', yellow, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SelectRoomScreen()),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text('© 2026 OddyRoom', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 230,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.brown.shade300, width: 1.4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  double redValue = 0;
  double greenValue = 0;
  double blueValue = 0;
  bool eraserMode = false;

  void updateSelectedColor() {
    setState(() {
      selectedColor = Color.fromARGB(
        255,
        redValue.round(),
        greenValue.round(),
        blueValue.round(),
      );
    });
  }

  static const int gridSize = 24;
  static const double editorSize = 286;

  final TextEditingController nameController = TextEditingController();

  String personality = '멍함';
  Color selectedColor = Colors.black;
  bool bucketMode = false;

  final personalities = ['멍함', '예민함', '활발함', '이상함', '소심함', '장난꾸러기', '철학적임'];

  final colorPalette = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
  ];

  late List<List<Color?>> pixels;

  @override
  void initState() {
    super.initState();
    clearPixels();
  }

  void clearPixels() {
    pixels = List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));
  }

  void paintAt(Offset pos) {
    final cell = editorSize / gridSize;
    final col = (pos.dx / cell).floor();
    final row = (pos.dy / cell).floor();

    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) return;

    setState(() {
      if (eraserMode) {
        pixels[row][col] = null;
      } else if (bucketMode) {
        fillBucket(row, col, pixels[row][col], selectedColor);
      } else {
        pixels[row][col] = selectedColor;
      }
    });
  }

  void fillBucket(int row, int col, Color? target, Color newColor) {
    if (target == newColor) return;

    final queue = <Point<int>>[Point(row, col)];
    while (queue.isNotEmpty) {
      final p = queue.removeLast();
      final r = p.x;
      final c = p.y;

      if (r < 0 || r >= gridSize || c < 0 || c >= gridSize) continue;
      if (pixels[r][c] != target) continue;

      pixels[r][c] = newColor;

      queue.add(Point(r + 1, c));
      queue.add(Point(r - 1, c));
      queue.add(Point(r, c + 1));
      queue.add(Point(r, c - 1));
    }
  }

  bool hasDrawing() {
    return pixels.any((row) => row.any((pixel) => pixel != null));
  }

  void goNext() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해 주세요!')),
      );
      return;
    }

    if (!hasDrawing()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('도트 얼굴을 그려 주세요!')),
      );
      return;
    }

    final character = CharacterModel(
      name: nameController.text.trim(),
      personality: personality,
      pixels: pixels.map((row) => List<Color?>.from(row)).toList(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SelectRoomScreen(character: character)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('캐릭터 만들기', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: bg,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: const Text(
                '도트 얼굴을 그려주세요!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: editorSize,
                    height: editorSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.brown.shade300, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (d) => paintAt(d.localPosition),
                      onPanUpdate: (d) => paintAt(d.localPosition),
                      onTapDown: (d) => paintAt(d.localPosition),
                      child: CustomPaint(painter: PixelEditorPainter(pixels)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    _toolButton(Icons.brush, !bucketMode && !eraserMode, () {
                      setState(() {
                        bucketMode = false;
                        eraserMode = false;
                      });
                    }),
                    const SizedBox(height: 10),
                    _toolButton(Icons.format_paint, bucketMode, () {
                      setState(() {
                        bucketMode = true;
                        eraserMode = false;
                      });
                    }),
                    const SizedBox(height: 10),
                    _toolButton(Icons.cleaning_services, eraserMode, () {
                      setState(() {
                        bucketMode = false;
                        eraserMode = true;
                      });
                    }),
                    const SizedBox(height: 10),
                    _toolButton(Icons.delete_outline, false, () {
                      setState(clearPixels);
                    }),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colorPalette.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                      redValue = color.red.toDouble();
                      greenValue = color.green.toDouble();
                      blueValue = color.blue.toDouble();
                    });
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color ? Colors.deepPurple : Colors.black26,
                        width: selectedColor == color ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('현재 색'),
                      const SizedBox(width: 10),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: redValue,
                    min: 0,
                    max: 255,
                    activeColor: Colors.red,
                    label: 'R ${redValue.round()}',
                    onChanged: (v) {
                      redValue = v;
                      updateSelectedColor();
                    },
                  ),
                  Slider(
                    value: greenValue,
                    min: 0,
                    max: 255,
                    activeColor: Colors.green,
                    label: 'G ${greenValue.round()}',
                    onChanged: (v) {
                      greenValue = v;
                      updateSelectedColor();
                    },
                  ),
                  Slider(
                    value: blueValue,
                    min: 0,
                    max: 255,
                    activeColor: Colors.blue,
                    label: 'B ${blueValue.round()}',
                    onChanged: (v) {
                      blueValue = v;
                      updateSelectedColor();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _inputRow('이름', TextField(
              controller: nameController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            )),
            const SizedBox(height: 10),
            _inputRow('성격', DropdownButtonFormField<String>(
              value: personality,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: personalities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => personality = v!),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: goNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: lavender,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('다음', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon, bool selected, VoidCallback onTap) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: selected ? yellow : Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.brown.shade300),
          ),
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget _inputRow(String label, Widget child) {
    return Row(
      children: [
        SizedBox(
          width: 46,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class SelectRoomScreen extends StatelessWidget {
  final CharacterModel? character;

  const SelectRoomScreen({super.key, this.character});

  @override
  Widget build(BuildContext context) {
    final isMoveInMode = character != null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(isMoveInMode ? '입주할 방 선택' : '방 선택', style: const TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: bg,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const StartScreen()),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final roomCharacter = apartmentRooms[index];
                final isEmpty = roomCharacter == null;

                return GestureDetector(
                  onTap: () {
                    if (isEmpty) {
                      if (isMoveInMode) {
                        apartmentRooms[index] = character;
                        roomMessages[index] = '기분이 좋아요!';
                        saveAppData();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(
                              character: apartmentRooms[index]!,
                              roomIndex: index,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('아직 아무도 살지 않는 빈 방이에요.')),
                        );
                      }
                      return;
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(character: roomCharacter, roomIndex: index),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 260,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isEmpty ? const Color(0xFFF7EEFF) : const Color(0xFFFFEFEF),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isEmpty ? const Color(0xFFB9A4D8) : const Color(0xFFF19A9A),
                              width: 2,
                            ),
                          ),
                          child: isEmpty
                              ? Center(
                            child: Container(
                              width: 105,
                              height: 125,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2E8FF),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFB9A4D8),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '+\n빈 방',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          )
                              : Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 50,
                                left: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.brown.shade100),
                                  ),
                                  child: Text(
                                    roomMessages[index],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 105,
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: CharacterBody(character: roomCharacter),
                                  ),
                                ),
                              ),

                              const Positioned(
                                bottom: 44,
                                child: Text('🪴', style: TextStyle(fontSize: 20)),
                              ),

                              Positioned(
                                bottom: 18,
                                left: 8,
                                right: 8,
                                child: Text(
                                  roomCharacter.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          top: -1,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            decoration: BoxDecoration(
                              color: isEmpty ? lavender : pink,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              border: Border.all(
                                color: isEmpty ? const Color(0xFFB9A4D8) : const Color(0xFFF19A9A),
                              ),
                            ),
                            child: Text(
                              '방 ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const StartScreen()),
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('종료하기'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomizeScreen()));
                    },
                    icon: const Icon(Icons.face),
                    label: const Text('새 캐릭터 만들기'),
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

class HomeScreen extends StatefulWidget {
  final CharacterModel character;
  final int roomIndex;

  const HomeScreen({
    super.key,
    required this.character,
    required this.roomIndex,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random random = Random();

  double characterX = 0;
  bool isJumping = false;
  bool isJumpingNow = false;
  bool visitorJumping = false;
  bool isSleeping = false;
  bool facingRight = true;

  int hunger = 60;
  int happiness = 65;

  CharacterModel? visitor;
  String currentMessage = '오늘 날씨가 좋네요!';

  final Map<String, List<String>> personalityMessages = {
    '멍함': ['멍하니 서 있어요.', '왜 여기 왔는지 까먹은 것 같아요.', '벽지를 보고 있어요.'],
    '예민함': ['문 쪽을 신경 쓰고 있어요.', '작은 소리에도 깜짝 놀라요.', '물건 위치가 마음에 안 드는 듯해요.'],
    '활발함': ['신나게 돌아다니고 있어요.', '러그 위에서 폴짝거려요.', '놀고 싶어 보여요!'],
    '이상함': ['벽지 무늬와 대화 중이에요.', '아무도 없는 곳에 인사했어요.', '뭔가 중요한 척하고 있어요.'],
    '소심함': ['조용히 눈치를 보고 있어요.', '살짝 기뻐 보여요.', '구석이 마음에 드는 듯해요.'],
    '장난꾸러기': ['뭔가 숨기고 있어요.', '아무 일도 없던 척해요.', '침대 밑에 장난감을 숨겼어요.'],
    '철학적임': ['왜 방은 방인지 고민해요.', '존재에 대해 생각 중이에요.', '창밖을 보며 사색해요.'],
  };

  @override
  void initState() {
    super.initState();

    currentMessage = roomMessages[widget.roomIndex] == '아직 아무도 살지 않아요.'
        ? '오늘 날씨가 좋네요!'
        : roomMessages[widget.roomIndex];

    moveCharacter();
    checkVisitorOccasionally();
  }

  void setMessageOnly(String msg) {
    currentMessage = msg;
    roomMessages[widget.roomIndex] = msg;
    saveAppData();
  }

  void moveCharacter() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 8000 + random.nextInt(8000)));
      if (!mounted) return;

      setState(() {
        final step = random.nextInt(31) - 15;

        if (step > 0) {
          facingRight = true;
        } else if (step < 0) {
          facingRight = false;
        }

        characterX += step;
        characterX = characterX.clamp(-45, 45);

        // 예전보다 훨씬 천천히 닳도록 조정했습니다. 약 1/5 속도 느낌입니다.
        if (random.nextInt(100) < 70) {
          hunger = (hunger - 1).clamp(0, 100);
        }
        if (random.nextInt(100) < 55) {
          happiness = (happiness - 1).clamp(0, 100);
        }

        if (hunger < 25 && random.nextInt(3) == 0) {
          setMessageOnly('배고파요... 간식 주세요!');
        } else if (happiness < 25 && random.nextInt(4) == 0) {
          setMessageOnly('조금 심심해요... 놀아줄래요?');
        } else if (random.nextBool()) {
          final list = personalityMessages[widget.character.personality] ??
              personalityMessages['멍함']!;
          setMessageOnly(list[random.nextInt(list.length)]);
        }
      });
    }
  }

  void checkVisitorOccasionally() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 15000 + random.nextInt(15000)));
      if (!mounted || visitor != null) continue;

      final others = apartmentRooms
          .where((r) => r != null && r != widget.character)
          .cast<CharacterModel>()
          .toList();

      if (others.isNotEmpty && random.nextInt(3) == 0) {
        setState(() {
          visitor = others[random.nextInt(others.length)];
          setMessageOnly('${visitor!.name}이/가 놀러왔어요!');
        });
      }
    }
  }

  void showRandomMessage() {
    final list = personalityMessages[widget.character.personality] ??
        personalityMessages['멍함']!;
    setState(() {
      setMessageOnly(list[random.nextInt(list.length)]);
    });
  }

  Future<void> jumpCharacter() async {
    if (isJumpingNow) return;
    isJumpingNow = true;

    for (int i = 0; i < 2; i++) {
      if (!mounted) return;
      setState(() => isJumping = true);
      await Future.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      setState(() => isJumping = false);
      await Future.delayed(const Duration(milliseconds: 120));
    }

    isJumpingNow = false;
  }

  Future<void> jumpTogether() async {
    if (isJumpingNow) return;
    isJumpingNow = true;

    for (int i = 0; i < 2; i++) {
      if (!mounted) return;
      setState(() {
        isJumping = true;
        visitorJumping = visitor != null;
      });
      await Future.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      setState(() {
        isJumping = false;
        visitorJumping = false;
      });
      await Future.delayed(const Duration(milliseconds: 120));
    }

    isJumpingNow = false;
  }

  void interactWithVisitor() {
    if (visitor == null) return;

    final playMessages = [
      '${widget.character.name}와 ${visitor!.name}이/가 같이 놀고 있어요!',
      '${visitor!.name}이/가 비밀 이야기를 들려줬어요.',
      '둘이 나란히 서서 같은 곳을 보고 있어요.',
      '${widget.character.name}와 ${visitor!.name}이/가 러그 위에서 놀고 있어요.',
    ];

    setState(() {
      happiness = (happiness + 12).clamp(0, 100);
      setMessageOnly(playMessages[random.nextInt(playMessages.length)]);
    });

    jumpTogether();
  }


  void openSnackShopDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('간식 상점', style: TextStyle(fontWeight: FontWeight.w900)),
              content: SizedBox(
                width: 320,
                height: MediaQuery.of(context).size.height * 0.42,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: snackItems.map((item) {
                      final count = snackInventory[item.id] ?? 0;
                      final canBuy = coin >= item.price;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.brown.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.emoji} ${item.name}  보유 $count개',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '가격 🪙 ${item.price} | 포만도 +${item.hungerGain} | 행복도 +${item.happinessGain}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: count <= 0
                                        ? null
                                        : () {
                                      Navigator.pop(dialogContext);
                                      useSnackItem(item);
                                    },
                                    child: const Text('먹기'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: !canBuy
                                        ? null
                                        : () {
                                      setState(() {
                                        coin -= item.price;
                                        snackInventory[item.id] = (snackInventory[item.id] ?? 0) + 1;
                                      });
                                      setDialogState(() {});
                                      saveAppData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: yellow,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('구매'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('닫기'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void useSnackItem(SnackItem item) {
    final count = snackInventory[item.id] ?? 0;
    if (count <= 0) {
      openSnackShopDialog();
      return;
    }

    setState(() {
      snackInventory[item.id] = count - 1;
      isSleeping = false;
      hunger = (hunger + item.hungerGain).clamp(0, 100);
      happiness = (happiness + item.happinessGain).clamp(0, 100);
      setMessageOnly('${item.emoji} ${item.name}을/를 먹고 기분이 좋아졌어요!');
    });

    saveAppData();
    jumpCharacter();
  }

  void openToyShopDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final shopToys = toyItems.where((toy) => toy.id != 'gamepad').toList();

            return AlertDialog(
              backgroundColor: bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('장난감 상점', style: TextStyle(fontWeight: FontWeight.w900)),
              content: SizedBox(
                width: 320,
                height: MediaQuery.of(context).size.height * 0.52,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4C7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.brown.shade200),
                        ),
                        child: const Text(
                          '🎮 기본 게임기는 항상 사용할 수 있어요.\n아래 장난감은 구매 후 1회 사용하면 행복도가 올라가요!',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, height: 1.35),
                        ),
                      ),
                      ...shopToys.map((toy) {
                        final count = toyInventory[toy.id] ?? 0;
                        final canBuy = coin >= toy.price;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: count > 0 ? const Color(0xFFFFF4C7) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.brown.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${toy.emoji} ${toy.name}  보유 $count개',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '가격 🪙 ${toy.price} | 행복도 +${toy.happinessBonus}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: count <= 0
                                          ? null
                                          : () {
                                        Navigator.pop(dialogContext);
                                        useToyItem(toy);
                                      },
                                      child: const Text('사용'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: !canBuy
                                          ? null
                                          : () {
                                        setState(() {
                                          coin -= toy.price;
                                          toyInventory[toy.id] = (toyInventory[toy.id] ?? 0) + 1;
                                        });
                                        setDialogState(() {});
                                        saveAppData();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: yellow,
                                        foregroundColor: Colors.black,
                                      ),
                                      child: const Text('구매'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('닫기'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void useToyItem(ToyItem toy) {
    final count = toyInventory[toy.id] ?? 0;
    if (count <= 0) {
      openToyShopDialog();
      return;
    }

    setState(() {
      toyInventory[toy.id] = count - 1;
      isSleeping = false;
      happiness = (happiness + toy.happinessBonus).clamp(0, 100);
      setMessageOnly('${toy.emoji} ${toy.name}으로 놀고 행복해졌어요! 행복도 +${toy.happinessBonus}');
    });

    saveAppData();
    visitor != null ? jumpTogether() : jumpCharacter();
  }

  Future<void> startPlayMiniGame(ToyItem toy) async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => StairMiniGameScreen(
          character: widget.character,
          toy: toy,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      isSleeping = false;
      happiness = (happiness + result).clamp(0, 100);
      hunger = (hunger - 6).clamp(0, 100);
      setMessageOnly('${toy.emoji} ${toy.name}으로 신나게 놀았어요! 행복도 +$result');
    });

    saveAppData();
    visitor != null ? jumpTogether() : jumpCharacter();
  }

  Widget statusBar(String label, int value, IconData icon) {
    final safe = value.clamp(0, 100);

    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        SizedBox(width: 55, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: safe / 100,
              minHeight: 12,
              backgroundColor: Colors.white,
              color: const Color(0xFFFFC83D),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$safe%'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('방 ${widget.roomIndex + 1}', style: const TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SelectRoomScreen()),
            );
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Text(
                '🪙 $coin',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: Container(color: const Color(0xFFFFF1D6))),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 235,
                  child: Container(color: floor),
                ),

                Positioned(
                  top: 15,
                  left: 22,
                  right: 22,
                  child: Image.asset(
                    'assets/ui/oddyroom_window.png',
                    fit: BoxFit.contain,
                  ),
                ),

                Positioned(
                  left: 86,
                  right: 86,
                  bottom: 95,
                  child: Image.asset(
                    'assets/ui/oddyroom_rug.png',
                    fit: BoxFit.contain,
                  ),
                ),

                Positioned(
                  left: 14,
                  bottom: 120,
                  child: Image.asset(
                    'assets/ui/oddyroom_bed.png',
                    width: 145,
                    fit: BoxFit.contain,
                  ),
                ),

                Positioned(
                  right: 16,
                  bottom: 118,
                  child: Image.asset(
                    'assets/ui/oddyroom_object.png',
                    width: 104,
                    fit: BoxFit.contain,
                  ),
                ),

                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  left: 58 + characterX,
                  right: 58 - characterX,
                  bottom: isJumping ? 270 : 230,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.brown.shade200),
                    ),
                    child: Text(
                      currentMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                if (isSleeping)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    left: 235 + characterX,
                    bottom: 225,
                    child: const Text(
                      'Zzz',
                      style: TextStyle(fontSize: 24, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                  ),

                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  left: 135 + characterX,
                  bottom: isJumping ? 110 : 72,
                  child: GestureDetector(
                    onTap: showRandomMessage,
                    child: Column(
                      children: [
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(facingRight ? 0 : 3.14159),
                          child: CharacterBody(character: widget.character),
                        ),
                        Text(widget.character.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                if (visitor != null)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    right: 50,
                    bottom: visitorJumping ? 110 : 72,
                    child: GestureDetector(
                      onTap: interactWithVisitor,
                      child: Column(
                        children: [
                          CharacterBody(character: visitor!),
                          Text(visitor!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE8BD),
              border: Border(top: BorderSide(color: Colors.brown, width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                statusBar('행복도', happiness, Icons.sentiment_satisfied_alt),
                const SizedBox(height: 8),
                statusBar('배고픔', hunger, Icons.restaurant),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _actionButton('🍪\n간식($totalSnackCount)', pink, openSnackShopDialog),
                    const SizedBox(width: 8),
                    _actionButton('🎮\n놀기', yellow, () {
                      startPlayMiniGame(toyById('gamepad'));
                    }),
                    const SizedBox(width: 8),
                    _actionButton('🧸\n장난감($totalToyCount)', card, openToyShopDialog),
                    const SizedBox(width: 8),
                    _actionButton('🌙\n재우기', lavender, () {
                      setState(() {
                        isSleeping = true;
                        happiness = (happiness + 12).clamp(0, 100);
                        setMessageOnly('졸려서 꾸벅꾸벅해요...');
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 74,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.brown.shade300, width: 1.5),
            ),
          ),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }
}

class CharacterBody extends StatelessWidget {
  final CharacterModel character;

  const CharacterBody({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: PixelFace(pixels: character.pixels),
    );
  }
}

class CharacterLineBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(30, 64), const Offset(10, 68), paint);
    canvas.drawLine(const Offset(90, 64), const Offset(110, 68), paint);
    canvas.drawLine(const Offset(50, 74), const Offset(48, 104), paint);
    canvas.drawLine(const Offset(70, 74), const Offset(72, 104), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PixelFace extends StatelessWidget {
  final List<List<Color?>> pixels;
  const PixelFace({super.key, required this.pixels});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: PixelPainter(pixels));
  }
}

class PixelPainter extends CustomPainter {
  final List<List<Color?>> pixels;
  PixelPainter(this.pixels);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = pixels.length;
    final cell = size.width / grid;

    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        final color = pixels[r][c];
        if (color != null) {
          canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), Paint()..color = color);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PixelPainter oldDelegate) => true;
}

class PixelEditorPainter extends CustomPainter {
  final List<List<Color?>> pixels;
  PixelEditorPainter(this.pixels);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = pixels.length;
    final cell = size.width / grid;

    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        final color = pixels[r][c];
        if (color != null) {
          canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), Paint()..color = color);
        }
      }
    }

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    for (int i = 0; i <= grid; i++) {
      final p = i * cell;
      canvas.drawLine(Offset(p, 0), Offset(p, size.height), gridPaint);
      canvas.drawLine(Offset(0, p), Offset(size.width, p), gridPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class StartBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFFFFE7B8).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 18; i++) {
      final x = (i * 47) % size.width;
      final y = (i * 83) % size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    final glowPaint = Paint()
      ..color = const Color(0xFFFFDFA3).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), 150, glowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TinyTownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final groundPaint = Paint()
      ..color = const Color(0xFFA7D987)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(25, size.height - 12),
      Offset(size.width - 25, size.height - 12),
      groundPaint,
    );

    final colors = [
      const Color(0xFFECC7A1),
      const Color(0xFFD9B49B),
      const Color(0xFFCFC3E8),
      const Color(0xFFE8B7A7),
      const Color(0xFFD7C59B),
    ];

    final xs = [18.0, 75.0, 135.0, 205.0, 270.0, 330.0];

    for (int i = 0; i < xs.length; i++) {
      final w = 46.0;
      final h = 45.0 + (i % 2) * 18;
      final left = xs[i];
      final top = size.height - 14 - h;

      final housePaint = Paint()..color = colors[i % colors.length];
      final roofPaint = Paint()..color = const Color(0xFFB98560);
      final linePaint = Paint()
        ..color = Colors.brown
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;

      final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, w, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(body, housePaint);
      canvas.drawRRect(body, linePaint);

      final roof = Path()
        ..moveTo(left - 4, top)
        ..lineTo(left + w / 2, top - 22)
        ..lineTo(left + w + 4, top)
        ..close();

      canvas.drawPath(roof, roofPaint);
      canvas.drawPath(roof, linePaint);

      final doorPaint = Paint()..color = const Color(0xFF8F5A3D);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + 18, top + h - 23, 12, 23),
          const Radius.circular(2),
        ),
        doorPaint,
      );

      final windowPaint = Paint()..color = const Color(0xFFBDE7FF);
      canvas.drawRect(Rect.fromLTWH(left + 7, top + 14, 10, 10), windowPaint);
      canvas.drawRect(Rect.fromLTWH(left + 29, top + 14, 10, 10), windowPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StartMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final body = Paint()
      ..color = const Color(0xFFFFD45C)
      ..style = PaintingStyle.fill;

    final blush = Paint()
      ..color = const Color(0xFFFF8F8F)
      ..style = PaintingStyle.fill;

    final leaf = Paint()
      ..color = const Color(0xFF57B65A)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(17, 18, 48, 50),
      const Radius.circular(16),
    );

    canvas.drawRRect(rect, body);
    canvas.drawRRect(rect, outline);

    canvas.drawCircle(const Offset(33, 42), 3, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(51, 42), 3, Paint()..color = Colors.black);

    final mouth = Path()
      ..moveTo(37, 50)
      ..quadraticBezierTo(42, 55, 47, 50);
    canvas.drawPath(mouth, outline);

    canvas.drawCircle(const Offset(27, 50), 4, blush);
    canvas.drawCircle(const Offset(57, 50), 4, blush);

    final stemPaint = Paint()
      ..color = const Color(0xFF3E8D3E)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(42, 18), const Offset(42, 8), stemPaint);
    canvas.drawOval(Rect.fromLTWH(28, 6, 16, 10), leaf);
    canvas.drawOval(Rect.fromLTWH(42, 6, 16, 10), leaf);

    canvas.drawLine(const Offset(23, 66), const Offset(23, 76), outline);
    canvas.drawLine(const Offset(59, 66), const Offset(59, 76), outline);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StairMiniGameScreen extends StatefulWidget {
  final CharacterModel character;
  final ToyItem toy;

  const StairMiniGameScreen({
    super.key,
    required this.character,
    required this.toy,
  });

  @override
  State<StairMiniGameScreen> createState() => _StairMiniGameScreenState();
}

class _StairMiniGameScreenState extends State<StairMiniGameScreen> {
  final Random random = Random();

  int score = 0;
  int playerLane = 1;
  int bonusCoin = 0;
  int timeLeft = 15;
  bool isGameOver = false;
  bool rewardApplied = false;
  Timer? gameTimer;

  // 0 = 왼쪽(<), 1 = 오른쪽(>)
  late List<int> nextDirections;
  late List<int> nextLanes;
  late List<int> nextItems;

  // 0 = 아이템 없음, 1 = 시계, 2 = 보너스 코인
  static const int noItem = 0;
  static const int timeItem = 1;
  static const int coinItem = 2;

  static const int laneCount = 4;
  static const int visibleStairCount = 19;
  static const int startTime = 15;

  int get stairCoin => score ~/ 5;
  int get earnedCoin => stairCoin + bonusCoin;
  int get scoreHappiness => (score ~/ 2).clamp(0, 40).toInt();
  int get earnedHappiness => (widget.toy.happinessBonus + scoreHappiness).clamp(0, 100).toInt();

  @override
  void initState() {
    super.initState();
    makeNewStairs();
    startTimer();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || isGameOver) return;

      setState(() {
        timeLeft--;
      });

      if (timeLeft <= 0) {
        gameOver();
      }
    });
  }

  void makeNewStairs() {
    playerLane = 1;
    nextDirections = [];
    nextLanes = [];
    nextItems = [];

    int lane = playerLane;
    for (int i = 0; i < visibleStairCount; i++) {
      final direction = makeDirection(lane);
      lane = moveLane(lane, direction);
      nextDirections.add(direction);
      nextLanes.add(lane);
      nextItems.add(makeItem(i));
    }
  }

  int makeItem(int index) {
    if (index < 3) return noItem;

    final chance = random.nextInt(100);
    if (chance < 8) return timeItem;
    if (chance < 18) return coinItem;
    return noItem;
  }

  int makeDirection(int lane) {
    if (lane <= 0) return 1;
    if (lane >= laneCount - 1) return 0;
    return random.nextBool() ? 0 : 1;
  }

  int moveLane(int lane, int direction) {
    final next = direction == 0 ? lane - 1 : lane + 1;
    return next.clamp(0, laneCount - 1);
  }

  void step(int direction) {
    if (isGameOver) return;

    if (direction == nextDirections.first) {
      setState(() {
        playerLane = nextLanes.removeAt(0);
        nextDirections.removeAt(0);
        final item = nextItems.removeAt(0);
        score++;

        if (item == timeItem) {
          timeLeft = (timeLeft + 5).clamp(0, 30).toInt();
        } else if (item == coinItem) {
          bonusCoin += 2;
        }

        final lastLane = nextLanes.isEmpty ? playerLane : nextLanes.last;
        final newDirection = makeDirection(lastLane);
        nextDirections.add(newDirection);
        nextLanes.add(moveLane(lastLane, newDirection));
        nextItems.add(makeItem(visibleStairCount));
      });
    } else {
      gameOver();
    }
  }

  Future<void> gameOver() async {
    if (isGameOver) return;

    gameTimer?.cancel();
    setState(() {
      isGameOver = true;
      if (!rewardApplied) {
        rewardApplied = true;
        coin += earnedCoin;
      }
    });

    await saveAppData();
  }

  void restart() {
    setState(() {
      score = 0;
      bonusCoin = 0;
      timeLeft = startTime;
      isGameOver = false;
      rewardApplied = false;
      makeNewStairs();
    });
    startTimer();
  }

  void exitWithReward() {
    Navigator.pop(context, earnedHappiness);
  }

  double laneLeft(double width, int lane, double stairWidth) {
    final sidePadding = 26.0;
    final usableWidth = width - sidePadding * 2 - stairWidth;
    final gap = usableWidth / (laneCount - 1);
    return sidePadding + gap * lane;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('${widget.toy.emoji} ${widget.toy.name} 놀이', style: const TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: bg,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Text(
                '🪙 $coin',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.brown.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '점수 $score',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '획득 예정 🪙 $earnedCoin',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '행복도 +$earnedHappiness',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '⏰ $timeLeft초',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (timeLeft / 30).clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: const Color(0xFFFFE8BD),
                          color: const Color(0xFFFFC83D),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const stairWidth = 78.0;
                const stairHeight = 27.0;
                const stairGap = 32.0;
                const playerSize = 62.0;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Container(color: const Color(0xFFFFF1D6)),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 110,
                      child: Container(color: floor),
                    ),

                    Positioned(
                      bottom: 31,
                      left: laneLeft(constraints.maxWidth, playerLane, stairWidth),
                      child: _stairBlock(stairWidth, stairHeight, true),
                    ),

                    for (int i = 0; i < nextLanes.length; i++)
                      Positioned(
                        bottom: 31 + (i + 1) * stairGap,
                        left: laneLeft(constraints.maxWidth, nextLanes[i], stairWidth),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            _stairBlock(stairWidth, stairHeight, false),
                            if (nextItems[i] != noItem)
                              Positioned(
                                top: -22,
                                child: Text(
                                  nextItems[i] == timeItem ? '⏰' : '🪙',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                          ],
                        ),
                      ),

                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      bottom: 55,
                      left: laneLeft(constraints.maxWidth, playerLane, stairWidth) + 8,
                      child: SizedBox(
                        width: playerSize,
                        height: playerSize,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: CharacterBody(character: widget.character),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 118,
                      right: 26,
                      child: Text(widget.toy.emoji, style: const TextStyle(fontSize: 34)),
                    ),

                    if (isGameOver)
                      Container(
                        width: 292,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.brown, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '놀이 끝!',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$score층까지 올라갔어요.\n기본 코인: 🪙 $stairCoin\n보너스 코인: 🪙 $bonusCoin\n총 🪙 $earnedCoin 코인\n행복도 +$earnedHappiness',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 17, height: 1.4),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: restart,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: yellow,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('다시 하기'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: exitWithReward,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: lavender,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('나가기'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () => step(0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pink,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.brown.shade300, width: 1.5),
                        ),
                      ),
                      child: const Text(
                        '<',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () => step(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.brown.shade300, width: 1.5),
                        ),
                      ),
                      child: const Text(
                        '>',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stairBlock(double width, double height, bool current) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: current ? const Color(0xFFFFDFA3) : card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}
