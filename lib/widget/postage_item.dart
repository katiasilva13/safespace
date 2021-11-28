import 'package:flutter/material.dart';
import 'package:safespace/models/postage.dart';
import 'package:safespace/models/user.dart';

class PostageItem extends StatelessWidget {
  Postage postages;
  User user;
  VoidCallback onTapItem;
  VoidCallback onPreddedRemover;

  PostageItem({@required this.postages, this.onTapItem, this.onPreddedRemover});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTapItem,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  postages.images[0],
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${postages.message}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (this.onPreddedRemover != null)
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    padding: EdgeInsets.all(10),
                    onPressed: this.onPreddedRemover,
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
