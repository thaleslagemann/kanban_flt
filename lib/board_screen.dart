// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_unnecessary_containers, unnecessary_string_interpolations

library config.globals;

// ignore_for_file: unused_field
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanban_flt/config.dart';
import 'package:kanban_flt/db_handler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    required this.board,
  });

  final Board board;

  @override
  BoardScreenState createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  final TextEditingController _headerFieldController = TextEditingController();
  final TextEditingController _taskNameFieldController =
      TextEditingController();
  final TextEditingController _taskDescFieldController =
      TextEditingController();
  final TextEditingController _taskRenameFieldController =
      TextEditingController();
  final TextEditingController _headerRenameFieldController =
      TextEditingController();
  final TextEditingController _boardNameEditFieldController =
      TextEditingController();
  final TextEditingController _boardDescEditFieldController =
      TextEditingController();
  final TextEditingController _taskDescriptionEditController =
      TextEditingController();
  final TextEditingController _taskTitleEditController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    String boardNewName = '';
    String boardNewDesc = '';
    String newHeaderName = '';
    String newTaskName = '';
    String newTaskDesc = '';
    String renameHeaderNewName = '';
    String renameTaskNewName = '';

    int currentReorderOption = reorderType.currentReorderInt();
    bool _isEditing = false;
    bool _isEditingTitle = false;
    FocusNode myFocusNode = FocusNode();

    var configState = context.watch<ConfigState>();

    _displayBoardDeletionAlert(BuildContext context, boardID) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            title: Text('Delete the board?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary),
                child: Text('cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  configState.databaseHelper.deleteBoard(boardID);
                  if (!configState.containsBoard(
                      configState.databaseHelper.boards, boardID)) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Board deleted')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('An error occured on board deletion')),
                    );
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('delete'),
              ),
            ],
          );
        },
      );
    }

    Future<void> _displayHeaderRenameDialog(
        BuildContext context, int headerID) async {
      _headerRenameFieldController.text = configState.databaseHelper
          .headers[configState.findHeaderIndexByID(headerID)].name;
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: const Text('Rename header'),
              content: TextField(
                onChanged: (value) {
                  setState(() {
                    renameHeaderNewName = value;
                  });
                },
                autofocus: true,
                controller: _headerRenameFieldController,
                decoration: const InputDecoration(hintText: "New header name"),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('cancel'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('ok'),
                  onPressed: () {
                    setState(() {
                      renameHeaderNewName = _headerRenameFieldController.text;
                      print(renameHeaderNewName);
                      configState.databaseHelper
                          .updateHeaderName(headerID, renameHeaderNewName);
                      Navigator.pop(context);
                      renameHeaderNewName = '';
                      _headerRenameFieldController.clear();
                    });
                  },
                ),
              ],
            );
          });
    }

    Future<void> _displayTaskRenameDialog(
        BuildContext context, Task task) async {
      _taskRenameFieldController.text = task.name;
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: const Text('Rename task'),
              content: TextField(
                onChanged: (value) {
                  setState(() {
                    renameTaskNewName = value;
                  });
                },
                autofocus: true,
                controller: _taskRenameFieldController,
                decoration: const InputDecoration(hintText: "New task name"),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('cancel'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('ok'),
                  onPressed: () {
                    setState(() {
                      renameTaskNewName = _taskRenameFieldController.text;
                      print(renameTaskNewName);
                      configState.databaseHelper
                          .updateTaskName(task.taskId, renameTaskNewName);
                      Navigator.pop(context);
                      renameTaskNewName = '';
                      _taskRenameFieldController.clear();
                    });
                  },
                ),
              ],
            );
          });
    }

    Future<void> _displayHeaderDeletionConfirmationDialog(
        BuildContext context, Header header) async {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: const Text('Delete header?'),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('cancel'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('delete'),
                  onPressed: () {
                    setState(() {
                      configState.databaseHelper.deleteHeader(header);
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
    }

    Future<void> _displayHeaderInputDialog(BuildContext context) async {
      String newHeaderName;
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: const Text('Create a new header'),
              content: TextField(
                onChanged: (value) {
                  setState(() {
                    newHeaderName = value;
                  });
                },
                autofocus: true,
                controller: _headerFieldController,
                decoration: const InputDecoration(hintText: "Header name"),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('cancel'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('ok'),
                  onPressed: () {
                    setState(() {
                      newHeaderName = _headerFieldController.text;
                      print(newHeaderName);
                      final newHeader = Header(
                          headerId: configState.getSequentialHeaderID(0),
                          boardId: widget.board.boardId,
                          name: newHeaderName,
                          orderIndex: widget.board.headers.length,
                          tasks: []);
                      configState.databaseHelper.createHeader(newHeader);
                      newHeaderName = '';
                      _headerFieldController.clear();
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
    }

    Future<void> _displayTaskDeletionConfirmationDialog(
        BuildContext context, Task task) async {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: const Text('Delete task?'),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('cancel'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('delete'),
                  onPressed: () {
                    setState(() {
                      configState.databaseHelper.deleteTask(task);
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
    }

    Future<void> _displayTaskInputDialog(
        BuildContext context, int headerID) async {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: const Text('Create a new task'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      newTaskName = value;
                    });
                  },
                  autofocus: true,
                  controller: _taskNameFieldController,
                  decoration: const InputDecoration(hintText: "Name"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      newTaskName = value;
                    });
                  },
                  autofocus: true,
                  controller: _taskDescFieldController,
                  decoration: const InputDecoration(hintText: "Description"),
                ),
              ]),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('cancel'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('ok'),
                  onPressed: () {
                    setState(() {
                      newTaskName = _taskNameFieldController.text;
                      newTaskDesc = _taskDescFieldController.text;
                      print("Creating new task: [$newTaskName]");
                      var taskID = configState.getSequentialTaskID(
                          configState.databaseHelper.tasks, 0);
                      var newTask = Task(
                        taskId: taskID,
                        headerId: headerID,
                        name: newTaskName,
                        description: newTaskDesc,
                        assignedUserId: 0,
                        orderIndex: configState
                            .databaseHelper
                            .headers[configState.findHeaderIndexByID(headerID)]
                            .tasks
                            .length,
                      );
                      configState.databaseHelper.createTask(newTask);
                      newTaskName = '';
                      newTaskDesc = '';
                      _taskNameFieldController.clear();
                      _taskDescFieldController.clear();
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
    }

    Future<void> _displayBoardEditDialog(
        BuildContext context, Board board) async {
      _boardNameEditFieldController.text = board.name;
      _boardDescEditFieldController.text = board.description;
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: const Text('Edit board'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        boardNewName = value;
                      });
                    },
                    autofocus: true,
                    controller: _boardNameEditFieldController,
                    decoration: const InputDecoration(hintText: "Board name"),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        boardNewDesc = value;
                      });
                    },
                    autofocus: true,
                    controller: _boardDescEditFieldController,
                    decoration:
                        const InputDecoration(hintText: "Board description"),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('cancel'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('ok'),
                  onPressed: () {
                    setState(() {
                      boardNewName = _boardNameEditFieldController.text;
                      boardNewDesc = _boardDescEditFieldController.text;
                      print(boardNewName);
                      print(boardNewDesc);
                      configState.databaseHelper.updateBoard(Board(
                          boardId: board.boardId,
                          name: boardNewName,
                          description: boardNewDesc,
                          creationDate: board.creationDate,
                          lastUpdate: DateTime.now()));
                      Navigator.pop(context);
                      boardNewName = '';
                      boardNewDesc = '';
                      _boardNameEditFieldController.clear();
                      _boardDescEditFieldController.clear();
                    });
                  },
                ),
              ],
            );
          });
    }

    Future<void> _displayBoardDetailsDialog(
        BuildContext context, int boardID) async {
      var index = configState.findBoardIndexByID(boardID);
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: const Text('Board details'),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Divider(
                        height: 5,
                        thickness: 1.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(text: 'ID: ', children: [
                            TextSpan(
                                text:
                                    '${configState.databaseHelper.boards[index].boardId}',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                          ]),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(text: 'Name: ', children: [
                            TextSpan(
                                text:
                                    '${configState.databaseHelper.boards[index].name}',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                          ]),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text.rich(
                            TextSpan(text: 'Description: ', children: [
                              TextSpan(
                                  text:
                                      '${configState.databaseHelper.boards[index].description}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(text: 'Creation date: ', children: [
                            TextSpan(
                                text:
                                    '${DateFormat('dd-MM-yyyy kk:mm').format(configState.databaseHelper.boards[index].creationDate)}',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                          ]),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(text: 'Last update: ', children: [
                            TextSpan(
                                text:
                                    '${DateFormat('dd-MM-yyyy kk:mm').format(configState.databaseHelper.boards[index].lastUpdate)}',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'ok',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface),
                  ),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
    }

    _toggleEdit() {
      print("Toggle edit");
      _isEditing = !_isEditing;
      print(_isEditing);
    }

    Future<void> _displayTaskScreen(BuildContext context, Task task) {
      return showDialog(
          context: context,
          builder: (context) {
            _taskDescriptionEditController.text = task.description;
            _taskTitleEditController.text = task.name;
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                  scrollable: true,
                  titlePadding: EdgeInsets.only(top: 5, left: 20, right: 5),
                  contentPadding:
                      EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 0),
                  insetPadding: EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_isEditingTitle)
                            IconButton(
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -4),
                              splashRadius: 20,
                              iconSize: 20,
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.check),
                              onPressed: (() {
                                setState(() {
                                  if (_isEditingTitle) {
                                    _isEditingTitle = false;
                                    task.name = _taskTitleEditController.text;
                                    configState.databaseHelper
                                        .updateTaskName(task.taskId, task.name);
                                  }
                                });
                              }),
                            ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            width: MediaQuery.of(context).size.width - 140,
                            child: TextField(
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                              ),
                              maxLines: 3,
                              minLines: 1,
                              readOnly: !_isEditingTitle,
                              textAlign: TextAlign.left,
                              controller:
                                  _taskTitleEditController, //'${task.description.capitalizeFirst}',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontSize: 24),
                              onTap: (() {
                                setState(() {
                                  _isEditingTitle = true;
                                });
                              }),
                              onEditingComplete: (() {
                                setState(() {
                                  _isEditingTitle = false;
                                  task.name = _taskTitleEditController.text;
                                  configState.databaseHelper
                                      .updateTaskName(task.taskId, task.name);
                                });
                              }),
                              onSubmitted: ((value) {
                                setState(() {
                                  _isEditingTitle = false;
                                  task.name = _taskTitleEditController.text;
                                  configState.databaseHelper
                                      .updateTaskName(task.taskId, task.name);
                                });
                              }),
                            ),
                          ),
                          IconButton(
                            visualDensity:
                                VisualDensity(horizontal: 0, vertical: 0),
                            splashRadius: 20,
                            iconSize: 20,
                            padding: EdgeInsets.all(0),
                            icon: Icon(Icons.close),
                            onPressed: (() {
                              setState(() {
                                if (_isEditingTitle) {
                                  _isEditingTitle = false;
                                  _taskTitleEditController.text = task.name;
                                }
                                if (_isEditing) {
                                  _isEditing = false;
                                  _taskDescriptionEditController.text =
                                      task.description;
                                }
                                Navigator.pop(context);
                              });
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                  content: Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(
                            height: 5,
                            thickness: 1.5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Description:'),
                                !_isEditing
                                    ? Row(children: <IconButton>[
                                        IconButton(
                                            visualDensity: VisualDensity(
                                                horizontal: 0, vertical: 0),
                                            padding: EdgeInsets.zero,
                                            splashRadius: 20,
                                            iconSize: 20,
                                            onPressed: (() {
                                              setState(() {
                                                _toggleEdit();
                                                myFocusNode.requestFocus();
                                              });
                                            }),
                                            icon: Icon(Icons.edit_outlined))
                                      ])
                                    : Row(children: <IconButton>[
                                        IconButton(
                                            visualDensity: VisualDensity(
                                                horizontal: 0, vertical: 0),
                                            padding: EdgeInsets.zero,
                                            splashRadius: 20,
                                            iconSize: 20,
                                            onPressed: (() {
                                              setState(() {
                                                _toggleEdit();
                                                _taskDescriptionEditController
                                                    .text = task.description;
                                              });
                                            }),
                                            icon: Icon(Icons.close)),
                                        IconButton(
                                            visualDensity: VisualDensity(
                                                horizontal: 0, vertical: 0),
                                            splashRadius: 20,
                                            iconSize: 20,
                                            onPressed: (() {
                                              setState(() {
                                                _toggleEdit();
                                                var _newDescription =
                                                    _taskDescriptionEditController
                                                        .text;
                                                task.description =
                                                    _newDescription;
                                                configState.databaseHelper
                                                    .updateTaskDescription(
                                                        task.taskId,
                                                        _newDescription);
                                              });
                                            }),
                                            icon: Icon(Icons.check)),
                                      ]),
                              ]),
                          Container(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                            ),
                            child: TextField(
                              textCapitalization: TextCapitalization.sentences,
                              focusNode: myFocusNode,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                              ),
                              maxLines: 20,
                              minLines: 5,
                              readOnly: !_isEditing,
                              textAlign: TextAlign.justify,
                              controller:
                                  _taskDescriptionEditController, //'${task.description.capitalizeFirst}',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('Assigned Users: ',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface)),
                          Text(
                            'unimplemented',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          SizedBox(height: 15.0),
                        ]),
                  ));
            });
          });
    }

    Board getCurrentBoard() {
      return widget.board;
    }

    _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex,
        int newListIndex) {
      Board board = getCurrentBoard();
      int boardIndex = configState.findBoardIndexByID(board.boardId);
      print("Board: [${board.name}]");

      print("oldItemIndex: $oldItemIndex");
      print("oldListIndex: $oldListIndex");
      print("newItemIndex: $newItemIndex");
      print("newListIndex: $newListIndex");

      int oldTaskIndex =
          configState.findTaskIndexByOrderId(oldItemIndex, oldListIndex, board);
      int oldHeaderIndex =
          configState.findHeaderIndexByOrderId(oldListIndex, board);
      int newTaskIndex =
          configState.findTaskIndexByOrderId(newItemIndex, newListIndex, board);
      int newHeaderIndex =
          configState.findHeaderIndexByOrderId(newListIndex, board);

      Task oldTask = board.headers[oldHeaderIndex].tasks[oldTaskIndex];

      setState(() {
        switch (currentReorderOption) {
          case 0:
            configState.databaseHelper.insertReorderTask(oldTask, oldTaskIndex,
                newTaskIndex, boardIndex, oldHeaderIndex, newHeaderIndex);
            configState.databaseHelper.sortHeadersAndTasks();
            configState.databaseHelper.redefineTasksHeaders();
            configState.printTasks();
            break;
          case 1:
            // orderIdBuffer saves the orderIndex of the task that's being moved
            int orderIdBuffer = configState.databaseHelper.boards[boardIndex]
                .headers[oldHeaderIndex].tasks[oldTaskIndex].orderIndex;

            // headerIdBuffer saves the headerId of the task that's being moved
            int headerIdBuffer = configState.databaseHelper.boards[boardIndex]
                .headers[oldHeaderIndex].tasks[oldTaskIndex].headerId;

            // Sets the orderIndex of the task that's being moved to the orderIndex of the taget
            configState.databaseHelper.boards[boardIndex]
                    .headers[oldHeaderIndex].tasks[oldTaskIndex].orderIndex =
                configState.databaseHelper.boards[boardIndex]
                    .headers[newHeaderIndex].tasks[newTaskIndex].orderIndex;
            // Sets the headerId of the task that's being moved to the headerId of the taget
            configState.databaseHelper.boards[boardIndex]
                    .headers[oldHeaderIndex].tasks[oldTaskIndex].headerId =
                configState.databaseHelper.boards[boardIndex]
                    .headers[newHeaderIndex].tasks[newTaskIndex].headerId;
            // Sets the target's orderIndex to the task that's being moved's orderIndex
            configState
                .databaseHelper
                .boards[boardIndex]
                .headers[newHeaderIndex]
                .tasks[newTaskIndex]
                .orderIndex = orderIdBuffer;
            // Sets the target's headerId to the task that's being moved's headerId
            configState
                .databaseHelper
                .boards[boardIndex]
                .headers[newHeaderIndex]
                .tasks[newTaskIndex]
                .headerId = headerIdBuffer;

            configState.databaseHelper.sortHeadersAndTasks();
            configState.databaseHelper.redefineTasksHeaders();

            configState.printTasks();
            break;
        }
      });
    }

    _onListReorder(int oldListIndex, int newListIndex) {
      Board board = getCurrentBoard();
      int oldHeaderIndex =
          configState.findHeaderIndexByOrderId(oldListIndex, board);
      int newHeaderIndex =
          configState.findHeaderIndexByOrderId(newListIndex, board);
      setState(() {
        switch (reorderType.currentReorderInt()) {
          case 0:
            break;
          case 1:
            // orderIdBuffer saves the orderIndex of the task that's being moved
            int orderIdBuffer = configState
                .databaseHelper
                .boards[configState.findBoardIndexByID(board.boardId)]
                .headers[oldHeaderIndex]
                .orderIndex;

            // Sets the orderIndex of the task that's being moved to the orderIndex of the taget
            configState
                    .databaseHelper
                    .boards[configState.findBoardIndexByID(board.boardId)]
                    .headers[oldHeaderIndex]
                    .orderIndex =
                configState
                    .databaseHelper
                    .boards[configState.findBoardIndexByID(board.boardId)]
                    .headers[newHeaderIndex]
                    .orderIndex;

            // Sets the target's orderIndex to the task that's being moved's orderIndex
            configState
                .databaseHelper
                .boards[configState.findBoardIndexByID(board.boardId)]
                .headers[newHeaderIndex]
                .orderIndex = orderIdBuffer;

            configState.databaseHelper.sortHeadersAndTasks();
            configState.databaseHelper.redefineTasksHeaders();

            configState.printTasks();
            break;
        }
      });
    }

    void headerChoiceAction(String choice, Header header) {
      if (choice == Constants.Delete) {
        print(
            'Removing header ${configState.databaseHelper.headers[configState.findHeaderIndexByID(header.headerId)].name}');
        _displayHeaderDeletionConfirmationDialog(context, header);
      } else if (choice == Constants.Rename) {
        _displayHeaderRenameDialog(context, header.headerId);
      } else if (choice == Constants.AddTask) {
        _displayTaskInputDialog(context, header.headerId);
      }
    }

    void taskChoiceAction(String choice, Task task) {
      if (choice == Constants.Delete) {
        print('Removing task ${task.name}');
        _displayTaskDeletionConfirmationDialog(context, task);
      } else if (choice == Constants.Rename) {
        _displayTaskRenameDialog(context, task);
      }
    }

    IconData choiceIcon(String choice) {
      if (choice == 'Delete') {
        return Icons.delete_outline_sharp;
      } else if (choice == 'Edit') {
        return Icons.edit_outlined;
      } else if (choice == 'Details') {
        return Icons.info_outlined;
      }
      return Icons.not_interested_outlined;
    }

    void boardChoiceAction(String choice, Board board) {
      if (choice == Constants.Delete) {
        _displayBoardDeletionAlert(context, board.boardId);
      } else if (choice == Constants.Edit) {
        _displayBoardEditDialog(context, board);
      } else if (choice == Constants.Details) {
        _displayBoardDetailsDialog(context, board.boardId);
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
        ),
        foregroundColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          _displayHeaderInputDialog(context);
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          50,
                      width: MediaQuery.of(context).size.width,
                      child: DragAndDropLists(
                        listDragHandle: DragHandle(
                          verticalAlignment: DragHandleVerticalAlignment.top,
                          child: Icon(Icons.drag_handle),
                        ),
                        children: [
                          for (var header in widget.board.headers)
                            DragAndDropList(
                              contentsWhenEmpty: Text('Empty header'),
                              header: Padding(
                                padding: const EdgeInsets.only(right: 45.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert_sharp),
                                      itemBuilder: (BuildContext context) {
                                        return Constants.headerChoices
                                            .map((String choice) {
                                          return PopupMenuItem<String>(
                                              value: choice,
                                              child: Text(choice),
                                              onTap: () => {
                                                    setState(() {
                                                      headerChoiceAction(
                                                          choice, header);
                                                    })
                                                  });
                                        }).toList();
                                      },
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Divider(
                                        thickness: 1.5,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Text(header.name),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Divider(
                                        thickness: 1.5,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              children: <DragAndDropItem>[
                                for (var task in header.tasks)
                                  DragAndDropItem(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20.0, vertical: 5.0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(7.5)),
                                              border: Border.all(
                                                  width: 1.5,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary)),
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _displayTaskScreen(
                                                    context, task);
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      "${configState.databaseHelper.tasks[configState.findTaskIndexByID(task.taskId)].name}",
                                                      softWrap: true,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .inverseSurface),
                                                    ),
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                  ),
                                                  icon: Icon(
                                                      Icons
                                                          .arrow_drop_down_sharp,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                  itemBuilder:
                                                      (BuildContext context) {
                                                    return Constants.taskChoices
                                                        .map((String choice) {
                                                      return PopupMenuItem<
                                                              String>(
                                                          value: choice,
                                                          child: Text(choice),
                                                          onTap: () => {
                                                                setState(() {
                                                                  taskChoiceAction(
                                                                      choice,
                                                                      task);
                                                                })
                                                              });
                                                    }).toList();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                        ],
                        onItemReorder: _onItemReorder,
                        onListReorder: _onListReorder,
                      )),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(alignment: Alignment.topLeft, child: CloseButton()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 13.0),
                        child: Text(
                          configState
                              .databaseHelper
                              .boards[configState
                                  .findBoardIndexByID(widget.board.boardId)]
                              .name
                              .capitalizeFirst!,
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_sharp),
                      itemBuilder: (BuildContext context) {
                        return Constants.boardChoices.map((String choice) {
                          return PopupMenuItem<String>(
                              value: choice,
                              child: Row(
                                children: [
                                  Icon(choiceIcon(choice)),
                                  Text(' $choice'),
                                ],
                              ),
                              onTap: () => {
                                    setState(() {
                                      boardChoiceAction(choice, widget.board);
                                    })
                                  });
                        }).toList();
                      },
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
