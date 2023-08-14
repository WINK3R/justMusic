import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:justmusic/model/Comment.dart';

import '../values/constants.dart';

class CommentComponent extends StatelessWidget {
  final Comment comment;

  const CommentComponent({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(comment.date);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: bgComment.withOpacity(0.6), borderRadius: BorderRadius.circular(15)),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      margin: EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              height: 40,
              width: 40,
              // Image radius
              child: FadeInImage.assetNetwork(
                image: comment.user.pp,
                fadeInDuration: const Duration(milliseconds: 100),
                placeholder: "assets/images/loadingPlaceholder.gif",
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      comment.user.pseudo,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 6, left: 10),
                      child: Text(
                        "il y a ${difference.inHours > 0 ? difference.inHours : difference.inMinutes}${difference.inHours > 0 ? "h" : "m"}",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w400, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    comment.text,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 15),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
