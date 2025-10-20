import 'package:flutter/material.dart';
// import 'package:mango_app/add_type.dart';

class MandiDetails extends StatefulWidget {
  const MandiDetails({super.key});

  @override
  State<MandiDetails> createState() => MandiDetailsState();
}

class MandiDetailsState extends State<MandiDetails> {
  final List<Map<String, dynamic>> mangoes = [
    {
      "type": "Bangalore",
      "price": 21,
      "quota": 40,
      "image":
          "https://images.unsplash.com/photo-1703729027853-dfd994ab84b8?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDEyN3x8fGVufDB8fHx8fA%3D%3D",
    },
    {
      "type": "Benisha",
      "price": 21,
      "quota": 40,
      "image":
          "https://images.unsplash.com/photo-1655168339415-fc5a98a7184f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjQ1fHx1bnJpcGVkJTIwbWFuZ29lc3xlbnwwfHwwfHx8MA%3D%3D",
    },
    {
      "type": "Khaadar",
      "price": 21,
      "quota": 40,
      "image":
          "https://media.istockphoto.com/id/534608466/photo/popular-kesar-mangoes-with-light-green-backround-isolated.webp?a=1&b=1&s=612x612&w=0&k=20&c=bgY76s-b93jxJcfWoIi4m3eVTQz1FbY9gkIhJ17YPTY=",
    },
    {
      "type": "Mallika",
      "price": 21,
      "quota": 40,
      "image":
          "https://images.unsplash.com/photo-1602081593819-65e7a8cee0dd?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fG1hbmdvfGVufDB8fDB8fHww",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green.shade100,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    "Mandi Name",
                    style: TextStyle(
                      fontSize: 36,
                      // fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    "Owner: Owner Name",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Supported Buying Types",
                      style: TextStyle(color: Colors.green, fontSize: 30),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3 / 4,
                          children:
                              mangoes.map((mango) {
                                return Stack(
                                  children: [
                                    Card(
                                      elevation: 2,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(12),
                                                  ),
                                              child: Image.network(
                                                mango['image'],
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color: Colors.grey[300],
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey[600],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                              right: 8.0,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Text(
                                                    mango['type'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "Rs ${mango['price']}",
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Text(
                                                  "Capacity: ${mango['quota']}tons",
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
