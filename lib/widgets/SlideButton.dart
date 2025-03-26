import 'package:flutter/material.dart';

class SlideButton extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const SlideButton({Key? key, required this.onChanged}) : super(key: key);

  @override
  SlideButtonState createState() => SlideButtonState();
}

class SlideButtonState extends State<SlideButton> {
  late bool active;

  @override
  void initState() {
    super.initState();
    active = false;
  }


  void toggleSwitch() {
    setState(() {
      active = !active;
    });
    widget.onChanged(active);
  }

  void setStatus(bool status) {
    setState(() {
      active = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 135,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.grey[400],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: active ? Alignment.centerRight : Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Align(
              alignment: active ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  active ? "Conectado" : "desconectado",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
