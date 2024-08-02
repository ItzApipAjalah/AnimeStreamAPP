class Anime {
  final String title;
  final String thumb;
  final String totalEpisode;
  final String updatedOn;
  final String updatedDay;
  final String endpoint;

  Anime({
    required this.title,
    required this.thumb,
    required this.totalEpisode,
    required this.updatedOn,
    required this.updatedDay,
    required this.endpoint,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      title: json['title'] ?? '',
      thumb: json['thumb'] ?? '',
      totalEpisode: json['total_episode'] ?? '',
      updatedOn: json['updated_on'] ?? '',
      updatedDay: json['updated_day'] ?? '',
      endpoint: json['endpoint'] ?? '',
    );
  }
}

class AnimeDetail {
  final String thumb;
  final List<String> sinopsis;
  final List<String> detail;
  final String title;
  final List<Episode>? episodeList;

  AnimeDetail({
    required this.thumb,
    required this.sinopsis,
    required this.detail,
    required this.title,
    this.episodeList,
  });

  factory AnimeDetail.fromJson(Map<String, dynamic> json) {
    return AnimeDetail(
      thumb: json['thumb'] ?? '',
      sinopsis:
          json['sinopsis'] != null ? List<String>.from(json['sinopsis']) : [],
      detail: json['detail'] != null ? List<String>.from(json['detail']) : [],
      title: json['title'] ?? '',
      episodeList: json['episode_list'] != null
          ? (json['episode_list'] as List)
              .map((e) => Episode.fromJson(e))
              .toList()
          : null,
    );
  }

  AnimeDetail copyWith({
    String? thumb,
    List<String>? sinopsis,
    List<String>? detail,
    String? title,
    List<Episode>? episodeList,
  }) {
    return AnimeDetail(
      thumb: thumb ?? this.thumb,
      sinopsis: sinopsis ?? this.sinopsis,
      detail: detail ?? this.detail,
      title: title ?? this.title,
      episodeList: episodeList ?? this.episodeList,
    );
  }
}

class Episode {
  final String episodeTitle;
  final String episodeEndpoint;
  final String episodeDate;

  Episode({
    required this.episodeTitle,
    required this.episodeEndpoint,
    required this.episodeDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeTitle: json['episode_title'] ?? '',
      episodeEndpoint: json['episode_endpoint'] ?? '',
      episodeDate: json['episode_date'] ?? '',
    );
  }
}

class EpisodeDetail {
  final String title;
  final Map<String, Quality> qualityList;

  EpisodeDetail({
    required this.title,
    required this.qualityList,
  });

  factory EpisodeDetail.fromJson(Map<String, dynamic> json) {
    var qualityMap = json['quality_list'] as Map<String, dynamic>;
    var qualities = qualityMap.map((key, value) => MapEntry(
          key,
          Quality.fromJson(value),
        ));

    return EpisodeDetail(
      title: json['title'],
      qualityList: qualities,
    );
  }

  List<DownloadLink> getDownloadLinks(String qualityKey) {
    var quality = qualityList[qualityKey];
    return quality?.downloadLinks ?? [];
  }
}

class Quality {
  final String quality;
  final String size;
  final List<DownloadLink> downloadLinks;

  Quality({
    required this.quality,
    required this.size,
    required this.downloadLinks,
  });

  factory Quality.fromJson(Map<String, dynamic> json) {
    var downloadLinks = (json['download_links'] as List)
        .map((link) => DownloadLink.fromJson({'link': link}))
        .toList();

    return Quality(
      quality: json['quality'],
      size: json['size'],
      downloadLinks: downloadLinks,
    );
  }
}

class DownloadLink {
  final String link;

  DownloadLink({
    required this.link,
  });

  factory DownloadLink.fromJson(Map<String, dynamic> json) {
    return DownloadLink(
      link: json['link'],
    );
  }
}

class AnimeSearchResult {
  final String title;
  final String thumb;
  final List<String> genres;
  final List<String> status;
  final String rating;
  final String endpoint;

  AnimeSearchResult({
    required this.title,
    required this.thumb,
    required this.genres,
    required this.status,
    required this.rating,
    required this.endpoint,
  });

  factory AnimeSearchResult.fromJson(Map<String, dynamic> json) {
    return AnimeSearchResult(
      title: json['title'] ?? '',
      thumb: json['thumb'] ?? '',
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      status: json['status'] != null ? List<String>.from(json['status']) : [],
      rating: json['rating'] ?? '',
      endpoint: json['endpoint'] ?? '',
    );
  }
}
