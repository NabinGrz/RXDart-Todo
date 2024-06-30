import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:todo_rxdart/comment_model.dart';

// Parsing function to be used with compute
List<CommentResponseModel> parseComments(String responseBody) {
  final l = commentResponseModelFromJson(responseBody);
  return l;
}

class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  // Future<void> getData() async {
  //   final response = await http
  //       .get(Uri.parse("https://jsonplaceholder.typicode.com/comments"));
  //   final commentResponseModel = commentResponseModelFromJson(response.body);
  //   commentsSubject.add(commentResponseModel);
  // }

  Future<void> getData() async {
    try {
      final response = await http
          .get(Uri.parse("https://jsonplaceholder.typicode.com/comments"));

      if (response.statusCode == 200) {
        // Use compute to parse the JSON in a background isolate
        final commentResponseModel =
            await compute(parseComments, response.body);
        commentsSubject.add(commentResponseModel);
      } else {
        // Handle non-200 responses
        print('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or JSON parsing errors
      print('Error occurred: $e');
    }
  }

  final commentsSubject = BehaviorSubject<List<CommentResponseModel>>();

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: commentsSubject,
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              return Text("${snapshot.data?[index].name}");
            },
          );
        },
      ),
    );
  }
}
