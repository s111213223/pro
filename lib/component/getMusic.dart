import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


  Map<String,List> items = {"開心愉悅":["assets/Icons/smily.png","活力pop"]
    ,"專注工作":["assets/Icons/brain.png","輕電子"]
    ,"放鬆療癒":["assets/Icons/lotus.png","LoFi/Acoustic"]
    ,"夜晚靜心":["assets/Icons/moon.png","Ambient"]
    ,"運動激勵":["assets/Icons/heart-rate.png","Workout"]
    ,"療癒低潮":["assets/Icons/heavy-rain.png","chill Balled"]
  };


  // List _result =[];

class getmusic{

  Future<List> searchMusic(String category, String apiKey) async {

    var query = category;

    final url = Uri.parse(
        "https://www.googleapis.com/youtube/v3/search"
            "?part=snippet"
            "&type=video"
            "&videoCategoryId=10"
            "&videoDuration=short"
            "&maxResults=5"
            "&q=$query"
            "&key=$apiKey"
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body);
    List results = [];
    int num =0;
    for (var item in data["items"]) {
      if(results.length>=5) break;
      final videoId = item["id"]["videoId"];
      final title = item["snippet"]["title"];
      final thumbnail = item["snippet"]["thumbnails"]["high"]["url"];
      final creator = item["snippet"]["channelTitle"];
      final link = "https://music.youtube.com/watch?v=$videoId";
      num++;
      print(title);
      print(link);
      results.add([title, thumbnail, link,creator],);
    }

    return results;
  }

}

