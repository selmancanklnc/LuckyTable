import 'package:flutter/material.dart';

class MyTool extends StatefulWidget {
  const MyTool({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  final Icon icon;
  final String text;
  final Function()? onPressed;

  @override
  _MyToolState createState() => _MyToolState();
}

class _MyToolState extends State<MyTool> {
  Color backgroundColor = Color.fromARGB(255, 64, 73, 83);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            // Tıklandığında arka plan rengini gri yap
            backgroundColor = Colors.grey;
          });
          widget.onPressed?.call();
        },
        onTapCancel: () {
          setState(() {
            // Elini çektiğinde eski rengine döndür
            backgroundColor =
                Color.fromARGB(255, 64, 73, 83); // Varsayılan renk (şeffaf)
          });
        },
        onTapUp: (_) {
          setState(() {
            // Elini çektiğinde eski rengine döndür
            backgroundColor =
                Color.fromARGB(255, 64, 73, 83); // Varsayılan renk (şeffaf)
          });
        },
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(15),
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            children: [
              Icon(widget.icon.icon, color: Colors.white, size: 30),
              const SizedBox(height: 4),
              Text(
                widget.text,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('My Tool Example')),
      body: Center(
        child: MyTool(
          icon: Icon(Icons.star),
          text: 'My Tool',
          onPressed: () {
            // Burada MyTool tıklandığında yapılacak işlemleri ekleyebilirsiniz
            print('MyTool Tıklandı!');
          },
        ),
      ),
    ),
  ));
}
