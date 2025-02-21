import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImpressumPage extends StatelessWidget {
  const ImpressumPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Impresszum'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 32,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.titleLarge,
              children: const [
                TextSpan(
                  text: 'Jézus Társasága Magyarországi Rendtartománya\n'
                      'Ignáci Pedagógiai Műhely\n\n'
                      '1085 Budapest, Horánszky u. 20.\n\n',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: LinkButton(
                    urlLabel: 'ignacipedagogia.hu',
                    url: 'https://ignacipedagogia.hu',
                  ),
                ),
                TextSpan(text: '\n'),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: LinkButton(
                    urlLabel: 'jezsuita.hu',
                    url: 'https://jezsuita.hu',
                  ),
                ),
                TextSpan(
                  text: '\n\n'
                      'Ha támogatni szeretnéd munkánkat, ajánld fel adód 1%-át a Jézus Társasága Alapítványnak.\n\n'
                      'Adószám: 18064333-2-42\n\n\n',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: LinkButton(
                    urlLabel: 'ignacipedagogia.hu',
                    url: 'https://ignacipedagogia.hu',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class LinkButton extends StatelessWidget {
  const LinkButton({super.key, required this.urlLabel, required this.url});

  final String urlLabel;
  final String url;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) => TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          overlayColor: Colors.transparent,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          minimumSize: Size.zero,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        ),
        onPressed: () => _launchUrl(url),
        child: Text(urlLabel),
      );
}
