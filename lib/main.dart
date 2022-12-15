import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final DownloadStatus downloadStatus = DownloadStatus.fetchingDownload;
  final double progress = 0.0;

  void startDownload() {}
  void stopDownload() {}
  void openDownload() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Store'),
            elevation: 0.0,
          ),
          body: Column(
            children: [
              SizedBox(
                width: 100.0,
                child: DownloadButton(
                  status: DownloadStatus.notDownloaded,
                  downloadProgress: progress,
                  onDownload: startDownload,
                  onCancel: stopDownload,
                  onOpen: openDownload,
                ),
              ),
              DownloadButton(
                status: DownloadStatus.fetchingDownload,
                downloadProgress: progress,
                onDownload: startDownload,
                onCancel: stopDownload,
                onOpen: openDownload,
              ),
              DownloadButton(
                status: DownloadStatus.downloading,
                downloadProgress: progress,
                onDownload: startDownload,
                onCancel: stopDownload,
                onOpen: openDownload,
              ),
              SizedBox(
                width: 100.0,
                child: DownloadButton(
                  status: DownloadStatus.downloaded,
                  downloadProgress: progress,
                  onDownload: startDownload,
                  onCancel: stopDownload,
                  onOpen: openDownload,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DownloadStatus {
  notDownloaded,
  fetchingDownload,
  downloading,
  downloaded,
}

@immutable
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.status,
    this.transitionDuration = const Duration(
      milliseconds: 500,
    ),
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
    this.downloadProgress = 0.0,
  });

  // arguments passed from the parent
  final DownloadStatus status;
  final Duration transitionDuration;
  final double downloadProgress;

  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onOpen;

  bool get _isDownloading => status == DownloadStatus.downloading;

  bool get _isFetching => status == DownloadStatus.fetchingDownload;

  bool get _isDownloaded => status == DownloadStatus.downloaded;

  void _onPressed() {
    switch (status) {
      case DownloadStatus.notDownloaded:
        onDownload();
        break;
      case DownloadStatus.fetchingDownload:
        // do nothing.
        break;
      case DownloadStatus.downloading:
        onCancel();
        break;
      case DownloadStatus.downloaded:
        onOpen();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Stack(
        children: [
          ButtonShapeWidget(
            transitionDuration: transitionDuration,
            isDownloaded: _isDownloaded,
            isDownloading: _isDownloading,
            isFetching: _isFetching,
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: transitionDuration,
              opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
              curve: Curves.ease,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ProgressIndicatorWidget(
                    downloadProgress: downloadProgress,
                    isDownloading: _isDownloading,
                    isFetching: _isFetching,
                  ),
                  if (_isDownloading)
                    const Icon(
                      Icons.stop,
                      size: 14.0,
                      color: CupertinoColors.activeBlue,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget(
      {super.key,
      required this.transitionDuration,
      required this.isDownloaded,
      required this.isDownloading,
      required this.isFetching});

  final Duration transitionDuration;
  final bool isDownloaded;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    // define shapes
    var shape = const ShapeDecoration(
        shape: StadiumBorder(), color: CupertinoColors.lightBackgroundGray);

    // if downloading, overwrite shape
    if (isDownloading || isFetching) {
      shape = ShapeDecoration(
          shape: const CircleBorder(), color: Colors.white.withOpacity(0.0));
    }

    return AnimatedContainer(
      duration: transitionDuration,
      curve: Curves.ease,
      width: double.infinity,
      decoration: shape,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: AnimatedOpacity(
          opacity: isDownloading || isFetching ? 0.0 : 1.0,
          curve: Curves.ease,
          duration: transitionDuration,
          child: Text(
            isDownloaded ? 'OPEN' : 'GET',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button?.copyWith(
                fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
          ),
        ),
      ),
    );
  }
}

@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.downloadProgress,
    required this.isDownloading,
    required this.isFetching,
  });

  final double downloadProgress;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: downloadProgress),
        duration: const Duration(milliseconds: 200),
        builder: (context, progress, child) {
          return CircularProgressIndicator(
            backgroundColor: isDownloading
                ? CupertinoColors.lightBackgroundGray
                : Colors.white.withOpacity(0),
            valueColor: AlwaysStoppedAnimation(isFetching
                ? CupertinoColors.lightBackgroundGray
                : CupertinoColors.activeBlue),
            strokeWidth: 2,
            value: isFetching ? null : progress,
          );
        },
      ),
    );
  }
}
