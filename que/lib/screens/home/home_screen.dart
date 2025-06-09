import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/screens/home/home_view_model.dart';
import 'package:que/services/notification_service.dart';
import 'package:que/models/que_user.dart';
import 'package:que/models/task.dart';
import 'package:que/providers/connection_provider.dart';
import 'package:que/providers/task_provider.dart';
import 'package:que/resources/string_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/screens/edit_task/edit_task_screen.dart';
import 'package:que/screens/sign_in_screen.dart';
import 'package:que/screens/task/task_screen.dart';
import 'package:que/widgets/filter_checklist_widget.dart';
import 'package:que/widgets/function_widgets.dart';
import 'package:que/widgets/no_wifi_widget.dart';
import 'package:que/widgets/task_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool willAccept = false;
  late SharedPreferences _preferences;
  late final NotificationService notificationService;
  StreamSubscription<QuerySnapshot<QueUser>>? _userStream;
  late TabController _tabController;
  int? _priority;
  Task? showTask;
  List<String> users = [];
  bool _isLoading = true;
  bool _isInit = false;
  final HomeViewModel _viewModel = HomeViewModel();

  void _editTask(BuildContext context, Task task) {
    setState(() {
      showTask = null;
    });
    Navigator.of(context).pushNamed(EditTaskScreen.routeName, arguments: task);
  }

  void listenToNotification() {
    notificationService.onNotificationClick.stream.listen((payload) {
      if (payload != null && payload.isNotEmpty) {
        AppLogs().writeLog(Constants.HOME_SCREEN_TAG, '------------------------------${payload}');
      }
    });
  }

  @override
  void initState() {
    notificationService = NotificationService();
    notificationService.init();
    listenToNotification();

    _viewModel.start();

    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      RemoteNotification? notification = remoteMessage.notification;
      AndroidNotification? androidNotification = remoteMessage.notification?.android;
      if (notification != null && androidNotification != null) {
        notificationService.showNotification(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      RemoteNotification? notification = remoteMessage.notification;
      AndroidNotification? androidNotification = remoteMessage.notification?.android;
      if (notification != null && androidNotification != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(notification.title ?? 'Que'),
            content: Text(notification.body ?? 'Que'),
          ),
        );
      }
    });

    // FirebaseAuth.instance.currentUser!.reload();
    _tabController = TabController(length: 5, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SignInScreen(),
          ),
        );
        return;
      }
      _tabController.addListener(() {
        if (_tabController.index >= 0) {
          Provider.of<TaskProvider>(context, listen: false).getUpdates();
        }
      });
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _viewModel.initProviders(context);
      _isInit = true;
    }
  }

  Future<bool> _onBackPress({required BuildContext context, required bool isExit}) async {
    print('_onBackPress : $isExit');
    if (!isExit) {
      setState(() {});
      if (showTask != null) {
        showTask = null;
        return false;
      }
      else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit the App!', style: getSemiBoldFont(color: Colors.black),),
            content: Text('Do you want to exit the app?', style: getRegularFont(color: Colors.black),),
            actions: [
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  }
                  else {
                    exit(0);
                  }
                },
                child: Text('Yes'),
                // style: ButtonStyle(
                //     padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0,))
                // ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No'),
                // style: ButtonStyle(
                //     padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0,))
                // ),
              ),
            ],
          ),
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final isConnected = Provider.of<ConnectionProvider>(context).isConnected;

    if (!isConnected) {
      return const NoWifiWidget();
    }

    _preferences = taskProvider.sharedPreferences;
    _priority = _preferences.getInt(PrefStrings.TASK_PRIORITY) ?? PriorityEnum.Latest.index;

    return WillPopScope(
      onWillPop: () => _onBackPress(context: context, isExit: false),
      child: Scaffold(
        appBar: AppBar(
          title: showTask == null ? const Text('Tasks') : Text(showTask!.title),
          centerTitle: false,
          leading: showTask == null
              ? null
              : IconButton(onPressed: () => _onBackPress(context: context, isExit: false), icon: const Icon(Icons.arrow_back),),
          actions: [
            DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.only(right: 10.0),
                child: DropdownButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  items: [
                    DropdownMenuItem<int>(
                      value: HomeScreenEnums.LOGOUT.value,
                      child: Row(
                        children: [
                          Icon(Icons.logout,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8.0),
                          Text(
                            'Logout',
                            style: getRegularFont(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem<int>(
                      value: HomeScreenEnums.DELETE.value,
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8.0),
                          Text(
                            'Delete Account',
                            style: getRegularFont(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (itemIdentifier) async {
                    if (itemIdentifier == HomeScreenEnums.LOGOUT.value) {
                      await FirebaseAuth.instance.signOut();
                    }
                    else if (itemIdentifier == HomeScreenEnums.DELETE.value) {
                      try {
                        await FirebaseAuth.instance.currentUser!.delete();
                        await FirebaseAuth.instance.signOut();
                        SystemNavigator.pop();
                      }
                      catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Re-login to delete account'),
                          ),
                        );
                        AppLogs().writeLog(Constants.HOME_SCREEN_TAG, 'Delete Account Error: ${e.toString()}');
                        await FirebaseAuth.instance.signOut();
                      }
                    }
                    Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
                  },
                ),
              ),
            ),
          ],
        ),
        // drawer: const AppDrawer(),
        body: _isLoading ? const Center(child: CircularProgressIndicator(),) : showTask != null
            ? TaskWidget(
                key: ValueKey(showTask!.taskId),
                homeViewModel: _viewModel,
                task: showTask!, editTask: _editTask, isExpand: true
              )
            : Column(children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(children: [
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.black54,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor, width: 3.0))
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: 'All',),
                      Tab(text: 'Start',),
                      Tab(text: 'In Progress',),
                      Tab(text: 'On Hold',),
                      Tab(text: 'Complete',),
                    ],
                  ),
                ),
              ),
              if (_tabController.index == 0)
                rearrangeByPriority(context, taskProvider),
              if (_tabController.index == 0)
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () => _showModalSheet(context, taskProvider),
                    icon: Icon(
                      Icons.filter_list, color: Theme.of(context).primaryColor,
                      size: 44.0,
                    ),
                  ),
                ),
              const SizedBox(width: 8.0,),
            ],),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _tabController.index == 0 ?
                _allTasksTab(taskProvider) : _tasks(taskProvider, taskProvider.tasks),
                _tabController.index == 1 ?
                _startTasksTab(taskProvider) : _tasks(taskProvider, taskProvider.startTasks),
                _tabController.index == 2 ?
                _inProgressTasksTab(taskProvider) : _tasks(taskProvider, taskProvider.inProgressTasks),
                _tabController.index == 3 ?
                _onHoldTasksTab(taskProvider) : _tasks(taskProvider, taskProvider.onHoldTasks),
                _tabController.index == 4 ?
                _completeTasksTab(taskProvider) : _tasks(taskProvider, taskProvider.completedTasks),
              ],
            ),
          ),
          ],),
        floatingActionButton: showTask == null ? FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(EditTaskScreen.routeName);
          },
          child: const Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
        ) : null,
      ),
    );
  }

  Widget _startTasksTab(TaskProvider taskProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: StreamBuilder<List<Task>>(
        stream: _viewModel.streamStartTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }
          if (!snapshot.hasData) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }

          final tasks = snapshot.data!;
          return _tasks(taskProvider, tasks);
        },
      ),
    );
  }

  Widget _inProgressTasksTab(TaskProvider taskProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: StreamBuilder<List<Task>>(
        stream: _viewModel.streamInProgressTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }
          if (!snapshot.hasData) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }

          final tasks = snapshot.data!;
          return _tasks(taskProvider, tasks);
        },
      ),
    );
  }

  Widget _onHoldTasksTab(TaskProvider taskProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: StreamBuilder<List<Task>>(
        stream: _viewModel.streamOnHoldTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }
          if (!snapshot.hasData) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }

          final tasks = snapshot.data!;
          return _tasks(taskProvider, tasks);
        },
      ),
    );
  }

  Widget _completeTasksTab(TaskProvider taskProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: StreamBuilder<List<Task>>(
        stream: _viewModel.streamCompleteTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }
          if (!snapshot.hasData) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }

          final tasks = snapshot.data!;
          return _tasks(taskProvider, tasks);
        },
      ),
    );
  }

  Widget _allTasksTab(TaskProvider taskProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: StreamBuilder<List<Task>>(
        stream: _viewModel.streamGetTasks(_priority ?? PriorityEnum.Latest.index),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }
          if (!snapshot.hasData) {
            return Center(child: Container(child: CircularProgressIndicator(),));
          }

          final tasks = snapshot.data!;
          return _tasks(taskProvider, tasks);
        },
      ),
    );
  }

  Widget _tasks(TaskProvider taskProvider, List<Task> tasks) {
    List<String> names = [];
    taskProvider.filters.forEach((key, value) {
      if (value) {
        names.add(key);
      }
    });
    List<Task> filterTasks = [];
    names.forEach((name) {
      final task = tasks.where((element) => element.assignedTo == name);
      filterTasks.addAll(task);
    });
    if (names.isEmpty) {
      filterTasks = tasks;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, right: 8.0, left: 8.0, top: 8.0),
      child: ReorderableListView(
        onReorder: (oldIndex, newIndex) => _reorderTasks(oldIndex, newIndex, taskProvider),
        children: filterTasks.map((task) {
          return GestureDetector(
            key: ValueKey(task.taskId),
            onTap: () {
              setState(() {
                Navigator.of(context).pushNamed(TaskScreen.routeName, arguments: task);
              });
            },
            child: TaskWidget(
              key: ValueKey(task.taskId),
              homeViewModel: _viewModel,
              task: task, editTask: _editTask,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showModalSheet(BuildContext context, TaskProvider taskProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), topLeft: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.40,
          child: Column(children: [
            Row(children: [
              TextButton(
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false).allFilter();
                },
                child: Text(
                  'Select All',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontStyle: FontStyle.normal,
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false).clearFilter();
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontStyle: FontStyle.normal,
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: taskProvider.filters.length,
                    itemBuilder: (context, index) {
                      final filter = taskProvider.filters.entries.elementAt(index);
                      final queUser = taskProvider.queUsers.elementAt(index);
                      return FilterCheckListWidget(
                        key: ValueKey(filter.key), filterName: filter.key,
                        isChecked: filter.value, queUser: queUser,
                      );
                    }
                  ),
                );
              },
            ),
          ],),
        );
      },
    );
  }

  Widget rearrangeByPriority(BuildContext context, TaskProvider taskProvider) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            color: Colors.white,
          ),
          child: DropdownButton(
            value: _priority == null ? 5 : _priority,
            underline: Container(),
            alignment: Alignment.center,
            style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
            items: [
              DropdownMenuItem(
                value: PriorityEnum.Blocker.index,
                child: priorityDropDownItemWidget(context, PriorityEnum.Blocker.name),
              ),
              DropdownMenuItem(
                value: PriorityEnum.Highest.index,
                child: priorityDropDownItemWidget(context, PriorityEnum.Highest.name),
              ),
              DropdownMenuItem(
                value: PriorityEnum.High.index,
                child: priorityDropDownItemWidget(context, PriorityEnum.High.name),
              ),
              DropdownMenuItem(
                value: PriorityEnum.Medium.index,
                child: priorityDropDownItemWidget(context, PriorityEnum.Medium.name),
              ),
              DropdownMenuItem(
                value: PriorityEnum.Normal.index,
                child: priorityDropDownItemWidget(context, PriorityEnum.Normal.name),
              ),
              DropdownMenuItem(
                value: PriorityEnum.Latest.index,
                child: priorityDropDownItemWidget(context, PriorityEnum.Latest.name),
              ),
              DropdownMenuItem(
                value: PriorityEnum.Oldest.index,
                child: priorityDropDownItemWidget(context, PriorityEnum.Oldest.name),
              ),
            ],
            onChanged: (itemIdentifier) {
              setState(() {
                if (itemIdentifier == PriorityEnum.Blocker.index) {
                  _priority = PriorityEnum.Blocker.index;
                  _preferences.setInt(PrefStrings.TASK_PRIORITY, PriorityEnum.Blocker.index);
                }
                else if (itemIdentifier == PriorityEnum.Highest.index) {
                  _priority = PriorityEnum.Highest.index;
                  _preferences.setInt(PrefStrings.TASK_PRIORITY, PriorityEnum.Highest.index);
                }
                else if (itemIdentifier == PriorityEnum.High.index) {
                  _priority = PriorityEnum.High.index;
                  _preferences.setInt(PrefStrings.TASK_PRIORITY, PriorityEnum.High.index);
                }
                else if (itemIdentifier == PriorityEnum.Medium.index) {
                  _priority = PriorityEnum.Medium.index;
                  _preferences.setInt(PrefStrings.TASK_PRIORITY, PriorityEnum.Medium.index);
                }
                else if (itemIdentifier == PriorityEnum.Normal.index) {
                  _priority = PriorityEnum.Normal.index;
                  _preferences.setInt(PrefStrings.TASK_PRIORITY, PriorityEnum.Normal.index);
                }
                else if (itemIdentifier == PriorityEnum.Latest.index) {
                  _priority = PriorityEnum.Latest.index;
                  _preferences.setInt(PrefStrings.TASK_PRIORITY, PriorityEnum.Latest.index);
                }
                else if (itemIdentifier == PriorityEnum.Oldest.index) {
                  _priority = PriorityEnum.Oldest.index;
                  _preferences.setInt(PrefStrings.TASK_PRIORITY, PriorityEnum.Oldest.index);
                }
                taskProvider.getUpdates();
              });
            },
          ),
        ),
      ),
    );
  }

  void _reorderTasks(int oldIndex, int newIndex, TaskProvider taskProvider){
    taskProvider.reorderTasks(oldIndex, newIndex);
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
    _tabController.dispose();
    if (_userStream != null) {
      _userStream!.cancel();
    }
  }
}