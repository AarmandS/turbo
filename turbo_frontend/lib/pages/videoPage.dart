// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:turbo/widgets/video.dart';
// import 'package:video_player/video_player.dart';

// import '../cubit/media_cubit.dart';
// import '../network_service.dart';

// class VideoPage extends StatefulWidget {
//   const VideoPage({super.key});

//   @override
//   _VideoPageState createState() => _VideoPageState();
// }

// class _VideoPageState extends State<VideoPage> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     var mediaCubit = context.read<MediaCubit>();
//     var mediaState = mediaCubit.state as MediaVideoPlaying;
//     _controller = VideoPlayerController.networkUrl(
//         Uri.parse('http://$baseUrl/media/${mediaState.mediaUrl}'))
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//         _controller.play();
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<MediaCubit, MediaState>(builder: (context, state) {
//       if (state is! MediaVideoPlaying) {
//         return Text('State should not be possible.');
//       }
//       // remove uneceseray blockbuilder

//       return Container(
//         color: Color.fromARGB(0, 0, 0, 0),
//         child: Stack(
//           children: [
//             Center(
//               child: _controller.value.isInitialized
//                   ? AspectRatio(
//                       aspectRatio: 1.7,
//                       child: VideoPlayer(_controller),
//                     )
//                   : Container(),
//             ),
//             IconButton(
//                 onPressed: () {
//                   context.read<MediaCubit>().closeVideoPlayer();
//                 },
//                 icon: Icon(Icons.arrow_back))
//           ],
//         ),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
// }
