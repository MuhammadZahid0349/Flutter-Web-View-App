import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocity_x/velocity_x.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  // var initialUrl = "http://3.10.164.95:4001/";
  var initialUrl = "https://www.google.com/";
  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  var urlController = TextEditingController();
  var loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController = PullToRefreshController(
        onRefresh: () {
          webViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: Colors.white,
            backgroundColor: Colors.blue.withOpacity(0.5)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.withOpacity(0.5),
          elevation: 0,
          leading: GestureDetector(
              onTap: () async {
                if (await webViewController!.canGoBack()) {
                  webViewController!.goBack();
                }
              },
              child: Icon(
                Icons.arrow_back_ios,
                size: 20.sp,
              )),
          titleSpacing: 0,
          title: TextField(
            onSubmitted: (value) {
              url = Uri.parse(value);
              if (url.scheme.isEmpty) {
                url = Uri.parse("${initialUrl}search?q=$value");
              }
              webViewController!.loadUrl(urlRequest: URLRequest(url: url));
            },
            controller: urlController,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(0),
              hintText: "e.g Search...",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.h),
              child: GestureDetector(
                  onTap: () {
                    webViewController!.reload();
                  },
                  child: Icon(Icons.refresh)),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: Stack(
              alignment: Alignment.center,
              children: [
                InAppWebView(
                  onLoadStart: (controller, url) {
                    var v = url.toString();
                    setState(() {
                      loading = true;
                      urlController.text = v;
                    });
                  },
                  onLoadStop: (controller, url) {
                    refreshController!.endRefreshing();
                    setState(() {
                      loading = false;
                    });
                  },
                  ////////////////////////// progress laoding optional

                  pullToRefreshController: refreshController,
                  onWebViewCreated: (controller) =>
                      webViewController = controller,
                  initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                ),
                Visibility(
                    visible: loading,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                    ))
              ],
            ))
          ],
        ),
      ),
    );
  }
}
