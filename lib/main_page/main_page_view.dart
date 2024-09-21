import 'package:connect_box/main_page/main_page_controller.dart';
import 'package:connect_box/main_page/main_page_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainPageController controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<MainPageController>(context, listen: false);
    controller.context = context;
  }

  @override
  Widget build(BuildContext context) {
    final double containerSize = MediaQuery.of(context).size.width * 0.3;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Consumer<MainPageController>(
            builder: (context, value, child) => Container(
              key: controller.outerContainerKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          List<Color> colorList = [
                            Colors.red,
                            Colors.green,
                            Colors.yellow,
                            Colors.purple
                          ];

                          value.leftContainerProperties.add(ContainerProperties(
                              color: colorList[index], key: GlobalKey()));

                          bool connected = false;

                          for (List<String> connection
                              in value.connectedContainers) {
                            if (connection.contains("left $index")) {
                              connected = true;
                              break;
                            }
                            connected = false;
                          }

                          return GestureDetector(
                            onTap: () {
                              controller.selectLeft(index);
                            },
                            child: Container(
                              key: value.leftContainerProperties[index].key,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: connected
                                        ? value.leftContainerProperties[index]
                                            .color
                                        : Colors.black,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: containerSize,
                              height: containerSize,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                            ),
                          );
                        }),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.29,
                          height: containerSize * 4,
                          child: Stack(children: value.connectors)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          value.rightContainerProperties.add(
                              ContainerProperties(
                                  color: Colors.black, key: GlobalKey()));

                          int? connectedIndex;

                          for (List<String> connection
                              in value.connectedContainers) {
                            if (connection.contains("right $index")) {
                              connectedIndex =
                                  int.parse(connection[0].split(" ")[1]);
                              break;
                            }
                            connectedIndex = null;
                          }

                          return GestureDetector(
                            onTap: () {
                              controller.selectRight(index);
                            },
                            child: Container(
                              key: value.rightContainerProperties[index].key,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: connectedIndex != null
                                        ? value
                                            .leftContainerProperties[
                                                connectedIndex]
                                            .color
                                        : Colors.black,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: containerSize,
                              height: containerSize,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        controller.resetConnections();
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
