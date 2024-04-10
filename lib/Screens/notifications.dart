import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucky_table/models/userModels.dart';
import 'package:lucky_table/services/userService.dart';

bool clicked = true;

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

late Future<List<NotificationListModel>> categories;

class _NotificationPageState extends State<NotificationPage> {
  _NotificationPageState();

  ScrollController? _categoryController;

  @override
  void initState() {
    categories = UserService().getNotifications();
    _categoryController = ScrollController();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 64, 73, 83),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
        title: Text(
          'Bildirimler',
          style: GoogleFonts.poppins(
            fontSize: 25,
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
          // style: Theme.of(context).textTheme.displayLarge,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder<List<NotificationListModel>>(
                  future: Future.delayed(Duration(seconds: 1))
                      .then((_) => categories),
                  // Future.delayed ile categories'yi bir saniye geciktiriyoruz
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData)
                     {
                      if (snapshot.data!.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mobile_friendly_rounded,
                                color: Colors.black45,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Bildirim Yok",
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            controller: _categoryController,
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, i) {
                              var category = snapshot.data?[i];
                              return Dismissible(
                                background: Container(
                                  color: Colors.red[700],
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: 16.0), // Sağdan margin ekleyin
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                key: UniqueKey(),
                                direction: DismissDirection.endToStart,
                                onDismissed:
                                    (DismissDirection direction) async {
                                  await category!.document?.delete();
                                  setState(() {
                                    snapshot.data?.removeAt(i);
                                  });
                                },
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                          backgroundColor:
                                              Colors.green.shade800,
                                          child: Icon(
                                              Icons.notifications_rounded,
                                              color: Colors.white)),
                                      // child: Text(
                                      //   category?.title![0].toUpperCase() ??
                                      //       "A",
                                      //   style: TextStyle(color: Colors.white),
                                      // )),
                                      title: Text(
                                        category?.title ?? "",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(category?.body ?? "",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal)),

                                      // trailing: Icon(Icons.favorite_rounded),
                                    ),
                                    Divider(height: 1),
                                  ],
                                ),
                              );
                            });
                      }
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }
                    return Center(child: CircularProgressIndicator());
                  })),
        ],
      ),
    );
  }
}
