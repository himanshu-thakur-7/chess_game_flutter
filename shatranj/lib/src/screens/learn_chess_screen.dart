import 'package:chess_ui/models/video_model.dart';
import 'package:chess_ui/services/api_service.dart';
import 'package:flutter/material.dart';

import 'video_screen.dart';

class LearnChessScreen extends StatefulWidget {
  const LearnChessScreen({Key? key}) : super(key: key);

  @override
  _LearnChessScreenState createState() => _LearnChessScreenState();
}

class _LearnChessScreenState extends State<LearnChessScreen> {
  List<Video> _videos = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _renderPlaylist();
  }

  _renderPlaylist() async {
    _videos = await APIService.instance.fetchVideosFromPlaylist();
    print("from _render playlist");
    _videos.forEach((video) => print(video.title));
    setState(() {
      isLoading = false;
    });
  }

  _buildVideo(Video video) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoScreen(id: video.id),
          ),
        )
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7.0),
        padding: const EdgeInsets.all(10.0),
        height: 140.0,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(16.0),
          color: Color.fromRGBO(155, 26, 228, 1.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 1),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromRGBO(251, 209, 76, 1.0)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image(
                image: NetworkImage(video.thumbnailUrl),
                width: 150.0,
              ),
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: 10.0),
              child: Text(
                video.title,
                style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ))
          ],
        ),
      ),
    );
  }

  _loadMoreVideos() async {
    isLoading = true;
    List<Video> moreVideos =
        await APIService.instance.fetchVideosFromPlaylist();
    List<Video> allVideos = _videos..addAll(moreVideos);
    setState(() {
      _videos = allVideos;
    });
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(0, 210, 211, 0.9),
          title: const Center(child: Text('Let\'s Learn Chess')),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: _videos.isNotEmpty
            ? NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollDetails) {
                  if (!isLoading &&
                      _videos.length != 15 &&
                      scrollDetails.metrics.pixels ==
                          scrollDetails.metrics.maxScrollExtent) {
                    _loadMoreVideos();
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: _videos.length,
                  itemBuilder: (BuildContext context, int index) {
                    Video video = _videos[index];
                    return _buildVideo(video);
                  },
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(251, 209, 76, 1.0),
                ),
              ));
  }
}
