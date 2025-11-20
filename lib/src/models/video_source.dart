enum VideoSourceType { local, network }

class VideoSource {
  final String pathOrUrl;
  final VideoSourceType type;

  VideoSource({required this.pathOrUrl, required this.type});
}
