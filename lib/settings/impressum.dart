import 'package:flutter/material.dart';

class ImpressumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Impresszum'),
      ),
      body: const Center(
        child: Text(
          'Jézus Társasága Magyarországi Rendtartománya\n'
          'Ignáci Pedagógiai Műhely\n\n'
          '1085 Budapest, Horánszky u. 20.\n\n'
          'www.ignacipedagogia.hu\n'
          'www.jezsuita.hu\n\n'
          'Ha támogatni szeretnéd munkánkat, ajánld fel adód 1%-át a Jézus Társasága Alapítványnak.\n\n'
          'Adószám: 18064333-2-42',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}