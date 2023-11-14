// enum FileType { photo, video, unsupported }

// class FileModel {
//   String mediaUrl;
//   FileType fileType;
//   int size;
//   DateTime uploaded;

//   FileModel.fromJson(Map<String, dynamic> json)
//       : mediaUrl = json['media_url'],
//         fileType = FileType.unsupported,
//         size = json['size'],
//         uploaded = DateTime.parse(json['uploaded']) {
//     switch (json['file_type']) {
//       case 'photo':
//         fileType = FileType.photo;
//         break;
//       case 'video':
//         fileType = FileType.video;
//         break;
//       default:
//         fileType = FileType.unsupported;
//     }
//   }
// }
