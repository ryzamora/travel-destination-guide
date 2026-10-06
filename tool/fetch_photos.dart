// Downloads freely licensed (CC / public domain) photos from Wikimedia Commons
// into assets/images/places/ and writes the attribution list to
// lib/data/photo_credits.dart.
//
// Run with: dart run tool/fetch_photos.dart
import 'dart:convert';
import 'dart:io';

/// destination id -> search phrase
const Map<String, String> targets = <String, String>{
  'el_nido': 'El Nido Palawan lagoon Big Lagoon',
  'banaue': 'Banaue Rice Terraces Ifugao',
  'chocolate_hills': 'Chocolate Hills Bohol',
  'boracay': 'Boracay White Beach Aklan',
  'mayon': 'Mayon Volcano Albay',
  'hundred_islands': 'Hundred Islands National Park Pangasinan',
  'intramuros': 'Intramuros Manila',
};

/// Titles containing any of these words are skipped (maps, logos, diagrams).
const List<String> blocked = <String>[
  'map', 'logo', 'flag', 'coat of arms', 'diagram', 'chart', 'seal',
  'plan of', 'locator', 'globe', 'icon', 'poster', 'plaque', 'stamp',
  'drawing', 'painting', 'engraving', 'sketch', 'signage', 'sign ',
  'airport', 'terminal', 'station', 'road sign', 'traffic',
];

/// Words that make a title more likely to be a real photo.
const List<String> preferred = <String>[
  'beach', 'terrace', 'volcano', 'lagoon', 'island', 'waterfall',
  'river', 'bay', 'hill', 'church', 'wall', 'sunset', 'view',
  'landscape', 'coast', 'sea', 'mountain', 'tourism',
];

const String api = 'https://commons.wikimedia.org/w/api.php';

Future<Map<String, dynamic>> _search(String phrase) async {
  final Map<String, String> params = <String, String>{
    'action': 'query',
    'format': 'json',
    'generator': 'search',
    'gsrsearch': 'filetype:bitmap $phrase',
    'gsrnamespace': '6',
    'gsrlimit': '20',
    'prop': 'imageinfo',
    'iiprop': 'url|mime|size|extmetadata',
    'iiurlwidth': '1400',
  };
  final Uri uri = Uri.parse('$api?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}');

  final HttpClient client = HttpClient();
  client.userAgent =
      'TravelDestinationGuide-FlutterClassProject/1.0 (student project; contact: student@example.com)';
  try {
    final HttpClientRequest request = await client.getUrl(uri);
    final HttpClientResponse response = await request.close();
    final String body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode} for $phrase');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}

String _cleanHtml(String raw) {
  return raw
      .replaceAll(RegExp('<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&nbsp;', ' ')
      .trim();
}

Future<void> _download(String url, String path) async {
  final HttpClient client = HttpClient();
  client.userAgent = 'TravelDestinationGuide-FlutterClassProject/1.0 (student project)';
  try {
    final HttpClientRequest request = await client.getUrl(Uri.parse(url));
    final HttpClientResponse response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode} for $url');
    }
    final List<int> bytes = <int>[];
    await for (final List<int> chunk in response) {
      bytes.addAll(chunk);
    }
    File(path).writeAsBytesSync(bytes);
  } finally {
    client.close();
  }
}

Future<void> main() async {
  Directory('assets/images/places').createSync(recursive: true);

  final List<Map<String, String>> credits = <Map<String, String>>[];

  for (final MapEntry<String, String> entry in targets.entries) {
    final String id = entry.key;
    final String phrase = entry.value;
    stdout.writeln('\n== $id  (search: "$phrase")');

    Map<String, dynamic> data;
    try {
      data = await _search(phrase);
    } catch (e) {
      stdout.writeln('  search failed: $e');
      continue;
    }

    final Map<String, dynamic>? pages = data['query']?['pages'] as Map<String, dynamic>?;
    if (pages == null || pages.isEmpty) {
      stdout.writeln('  no results');
      continue;
    }

    final List<Map<String, dynamic>> candidates = pages.values
        .whereType<Map<String, dynamic>>()
        .where((Map<String, dynamic> p) => p['imageinfo'] is List)
        .toList();

    // Best first: not blocked, landscape, wide enough, preferred keywords.
    candidates.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      int score(Map<String, dynamic> p) {
        final String title = (p['title'] as String).toLowerCase();
        final Map<String, dynamic> info =
            (p['imageinfo'] as List).first as Map<String, dynamic>;
        final int w = (info['width'] as num?)?.toInt() ?? 0;
        final int h = (info['height'] as num?)?.toInt() ?? 1;
        int s = 0;
        if (blocked.any((String w2) => title.contains(w2))) s -= 50;
        if (preferred.any((String w2) => title.contains(w2))) s += 10;
        if (w >= 1600) s += 8;
        if (w >= 1200) s += 4;
        if (w > h) s += 5;
        if ((info['mime'] as String) == 'image/jpeg') s += 2;
        return s;
      }

      return score(b).compareTo(score(a));
    });

    bool saved = false;
    for (final Map<String, dynamic> page in candidates.take(6)) {
      if (saved) break;
      final String title = page['title'] as String;
      final Map<String, dynamic> info =
          (page['imageinfo'] as List).first as Map<String, dynamic>;
      final String mime = (info['mime'] as String?) ?? '';
      if (mime != 'image/jpeg' && mime != 'image/png') continue;
      final int w = (info['width'] as num?)?.toInt() ?? 0;
      final int h = (info['height'] as num?)?.toInt() ?? 0;
      if (w < 1000 || w <= h) continue;

      final String url = (info['thumburl'] ?? info['url']) as String;
      final String ext = mime == 'image/png' ? 'png' : 'jpg';
      final String path = 'assets/images/places/$id.$ext';

      try {
        await _download(url, path);
      } catch (e) {
        stdout.writeln('  download failed: $e');
        continue;
      }

      final int size = File(path).lengthSync();
      if (size < 40000) {
        File(path).deleteSync();
        stdout.writeln('  too small, skipped');
        continue;
      }

      final Map<String, dynamic> meta =
          (info['extmetadata'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      String val(String key) =>
          _cleanHtml('${meta[key]?['value'] ?? ''}'.trim());

      credits.add(<String, String>{
        'id': id,
        'title': title.replaceFirst('File:', ''),
        'author': val('Artist').isEmpty ? 'Unknown author' : val('Artist'),
        'license': val('LicenseShortName').isEmpty
            ? 'Creative Commons'
            : val('LicenseShortName'),
        'licenseUrl': val('LicenseUrl'),
        'page': 'https://commons.wikimedia.org/wiki/$title',
      });

      stdout.writeln('  OK  $title  (${w}x$h, ${(size / 1024).toStringAsFixed(0)} KB)');
      saved = true;
    }

    if (!saved) stdout.writeln('  !! nothing usable found');
  }

  final StringBuffer out = StringBuffer();
  out.writeln('// GENERATED FILE - do not edit by hand.');
  out.writeln('//');
  out.writeln('// Photo credits for the images in assets/images/places/.');
  out.writeln('// All photos come from Wikimedia Commons and are used under a');
  out.writeln('// Creative Commons or public domain license.');
  out.writeln();
  out.writeln('class PhotoCredit {');
  out.writeln('  const PhotoCredit({');
  out.writeln('    required this.id,');
  out.writeln('    required this.title,');
  out.writeln('    required this.author,');
  out.writeln('    required this.license,');
  out.writeln('    required this.licenseUrl,');
  out.writeln('    required this.page,');
  out.writeln('  });');
  out.writeln();
  out.writeln('  final String id;');
  out.writeln('  final String title;');
  out.writeln('  final String author;');
  out.writeln('  final String license;');
  out.writeln('  final String licenseUrl;');
  out.writeln('  final String page;');
  out.writeln('}');
  out.writeln();
  out.writeln('const List<PhotoCredit> photoCredits = <PhotoCredit>[');
  for (final Map<String, String> c in credits) {
    String q(String v) => "'${v.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$')}'";
    out.writeln('  PhotoCredit(');
    out.writeln('    id: ${q(c['id']!)},');
    out.writeln('    title: ${q(c['title']!)},');
    out.writeln('    author: ${q(c['author']!)},');
    out.writeln('    license: ${q(c['license']!)},');
    out.writeln('    licenseUrl: ${q(c['licenseUrl']!)},');
    out.writeln('    page: ${q(c['page']!)},');
    out.writeln('  ),');
  }
  out.writeln('];');

  File('lib/data/photo_credits.dart').writeAsStringSync(out.toString());
  stdout.writeln('\nWrote lib/data/photo_credits.dart with ${credits.length} credits.');
}
