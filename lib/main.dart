import 'package:flutter/material.dart';
import 'file_explorer/screens/file_explorer_screen.dart';
import 'util.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Ubuntu", "Ubuntu");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme.light(),
      home: FileExplorerScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../restricted_directories/fetch_restricted_directories.dart';
import '../../restricted_directories/check_restricted_folder_by_user.dart';

class RestrictedFoldersScreen extends StatefulWidget {
  const RestrictedFoldersScreen({super.key});

  @override
  State<RestrictedFoldersScreen> createState() => _RestrictedFoldersScreenState();
}

class _RestrictedFoldersScreenState extends State<RestrictedFoldersScreen> {
  @override
  void initState() {
    super.initState();
    loadRestrictedFolders().then((_) {
      setState(() {});
    });
  }

  void _removeFolder(String path) async {
    await removeRestrictedFolder(path);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restricted Folders'),
      ),
      body: restrictedFoldersByUser.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Lottie.asset('assets/empty_ani.json', width: 400),
                const SizedBox(height: 16),
                const Text(
                  'No restricted folders yet!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            )
          : ListView.builder(
        itemCount: restrictedFoldersByUser.length,
        itemBuilder: (context, index) {
          final path = restrictedFoldersByUser[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(path),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFolder(path),
              ),
            ),
          );
        },
      ),
    );
  }
}

