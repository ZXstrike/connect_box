import 'package:connect_box/main_page/connector_widget.dart';
import 'package:connect_box/main_page/main_page_model.dart';
import 'package:flutter/material.dart';

class MainPageController extends ChangeNotifier {
  List<ContainerProperties> leftContainerProperties = [];
  List<ContainerProperties> rightContainerProperties = [];

  BuildContext? context;

  int? selectedLeft;
  int? selectedRight;

  List<List<String>> connectedContainers = [];

  List<Widget> connectors = [];

  GlobalKey? outerContainerKey = GlobalKey();

  double getContainerSize() {
    RenderBox renderBox =
        outerContainerKey?.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.width * 0.2;
  }

  void selectLeft(int id) {
    if (selectedLeft != null) {
      selectedLeft = null;
      for (List<String> connection in connectedContainers) {
        if (connection.contains("left $id")) {
          return;
        }
      }
    } else {
      selectedLeft = id;
      if (selectedRight == null) {
      } else {
        removeConnection();
      }
    }

    notifyListeners();
  }

  void selectRight(int id) {
    selectedRight = id;

    connectContainers();

    notifyListeners();
  }

  void connectContainers() {
    for (List<String> connection in connectedContainers) {
      if (connection.contains("right $selectedRight") ||
          connection.contains("left $selectedLeft")) {
        return;
      }
    }
    if (selectedLeft != null && selectedRight != null) {
      connectedContainers.add(["left $selectedLeft", "right $selectedRight"]);

      RenderBox leftRenderBox = leftContainerProperties[selectedLeft!]
          .key
          .currentContext!
          .findRenderObject() as RenderBox;
      Offset leftPosition = leftRenderBox.localToGlobal(Offset.zero);

      RenderBox rightRenderBox = rightContainerProperties[selectedRight!]
          .key
          .currentContext!
          .findRenderObject() as RenderBox;
      Offset rightPosition = rightRenderBox.localToGlobal(Offset.zero);

      connectors.add(
        SizedBox(
          width: MediaQuery.of(context!).size.width * 0.29,
          height: (leftRenderBox.size.width + 10) * 4,
          child: AnimatedConnector(
              startY: leftPosition.dy,
              endY: rightPosition.dy,
              color: leftContainerProperties[selectedLeft!].color,
              containerHeight: MediaQuery.of(context!).viewPadding.top,
              boxSize: leftRenderBox.size.width),
        ),
      );
    }
    selectedLeft = null;
    selectedRight = null;
    notifyListeners();
  }

  void removeConnection() {
    if (selectedRight != null) {
      for (int i = 0; i < connectedContainers.length; i++) {
        if (connectedContainers[i].contains("right $selectedRight") &&
            connectedContainers[i].contains("left $selectedLeft")) {
          connectedContainers.removeAt(i);
          connectors.removeAt(i);
          break;
        }
      }
    }
    selectedRight = null;
    selectedLeft = null;
    notifyListeners();
  }

  void resetConnections() {
    connectedContainers.clear();
    connectors.clear();
    notifyListeners();
  }
}
