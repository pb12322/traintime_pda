import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_info_card.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BookDetailCard extends StatelessWidget {
  final BookInfo toUse;
  const BookDetailCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
          ),
          child: SizedBox(
            height: 20,
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(top: 7, bottom: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toUse.bookName,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Divider(color: Colors.transparent),
                        Text(
                          "作者：${toUse.author}\n"
                          "出版社：${toUse.publisherHouse}\n"
                          "ISBN: ${toUse.isbn}\n"
                          "发行时间: ${toUse.publicationDate} 索书号: ${toUse.searchCode}",
                        ),
                        const Divider(color: Colors.transparent),
                      ],
                    ),
                  ),
                  CachedNetworkImage(
                    imageUrl: LibrarySession.bookCover(toUse.isbn ?? ""),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        Image.asset("assets/Empty-Cover.jpg"),
                    width: 90,
                    height: 120,
                  ),
                ],
              ),
              Text(
                toUse.description ?? "这本书没有提供描述",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
