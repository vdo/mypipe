import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.red, brightness: Brightness.dark),
      home: const Home(),
    ));

const home = 'https://m.youtube.com/';
const menu = {
  'Sign in': 'https://accounts.google.com/ServiceLogin?service=youtube&continue=https://m.youtube.com/',
  'Watch later': 'https://m.youtube.com/playlist?list=WL',
  'History': 'https://m.youtube.com/feed/history',
  'YouTube settings': 'https://m.youtube.com/select_site',
};

const native = MethodChannel('newpipe');

bool isVideo(String url) => url.contains('/watch') || url.contains('/shorts/');

// Hides feed ads/promos and sends video taps to the app before YouTube handles them.
// ponytail: CSS selectors break when YouTube renames elements; update the list then.
const inject = r'''
if (!window.__mp) {
  window.__mp = 1;
  const s = document.createElement('style');
  s.textContent = `
    ad-slot-renderer, ytm-promoted-sparkles-web-renderer, ytm-promoted-video-renderer,
    ytm-companion-ad-renderer, ytm-display-ad-renderer, ytm-statement-banner-renderer,
    ytm-mealbar-promo-renderer, ytm-paid-content-overlay-renderer,
    ytm-rich-item-renderer:has(ad-slot-renderer),
    ytm-item-section-renderer:has(ytm-promoted-sparkles-web-renderer)
    { display: none !important; }`;
  document.documentElement.appendChild(s);
  document.addEventListener('click', e => {
    const a = e.target.closest('a[href]');
    if (a && /\/watch|\/shorts\//.test(a.href)) {
      e.preventDefault();
      e.stopImmediatePropagation();
      NewPipe.postMessage(a.href);
    }
  }, true);
}
''';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final WebViewController web = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    // Without the WebView marker Google allows signing in.
    ..setUserAgent('Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36')
    ..addJavaScriptChannel('NewPipe', onMessageReceived: (m) => open(m.message))
    ..setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (r) {
        if (!isVideo(r.url)) return NavigationDecision.navigate;
        open(r.url);
        return NavigationDecision.prevent;
      },
      // Fallback for in-page navigations the click hook missed.
      onUrlChange: (c) {
        if (c.url != null && isVideo(c.url!)) {
          open(c.url!);
          web.goBack();
        }
      },
      onPageStarted: (_) => web.runJavaScript(inject),
      onPageFinished: (_) => web.runJavaScript(inject),
    ))
    ..loadRequest(Uri.parse(home));

  void open(String url) => native.invokeMethod('open', url);

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (await web.canGoBack()) {
            web.goBack();
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 36,
            titleTextStyle: Theme.of(context).textTheme.titleSmall,
            title: const Text('MyPipe'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings, size: 20),
                onSelected: (v) async {
                  if (v == 'Reload') return web.reload();
                  if (v == 'Sign out') await WebViewCookieManager().clearCookies();
                  web.loadRequest(Uri.parse(menu[v] ?? home));
                },
                itemBuilder: (_) => [...menu.keys, 'Sign out', 'Reload']
                    .map((k) => PopupMenuItem(value: k, child: Text(k)))
                    .toList(),
              ),
            ],
          ),
          body: SafeArea(top: false, child: WebViewWidget(controller: web)),
        ),
      );
}
