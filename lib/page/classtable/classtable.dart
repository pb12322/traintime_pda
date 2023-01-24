/*
Class Table Interface.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

class ClassTable extends StatelessWidget {
  final Classes toUse = classData;
  ClassTable({
    Key? key,
    /*required this.classData*/
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("课程表"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => aboutDialog(context),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => ClassTableWindow(
          constraints: constraints,
          classData: classData,
        ),
      ),
    );
  }

  Widget aboutDialog(context) => AlertDialog(
        title: const Text("不过我还是每次去教室"),
        content: Image.asset("assets/Farnsworth-Class.jpg"),
        actions: <Widget>[
          TextButton(
            child: const Text("确定"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}

class ClassTableWindow extends StatefulWidget {
  final Classes classData;
  final BoxConstraints constraints;
  const ClassTableWindow({
    super.key,
    required this.constraints,
    required this.classData,
  });

  @override
  State<StatefulWidget> createState() => PageState();
}

class PageState extends State<ClassTableWindow> {
  // The height ratio for the top and the middle.
  static const heightRatio = [0.15, 0.08, 0.9];

  // The width ratio for the week column.
  static const leftRow = 40.0;

  // Mark the current week.
  int? currentWeek;

  // Colors for the class information card.
  static const colorList = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
  ];
  // Colors for class information card which not in this week.
  static const uselessColor = Colors.grey;

  // A list as an index of the classtable items.
  late List<List<List<List<int>>>> pretendLayout;

  List<String> weekList = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  // Time arrangements.
  // Even means start, odd means end.
  List<String> time = [
    "8:30",
    "9:15",
    "9:20",
    "10:05",
    "10:25",
    "11:10",
    "11:15",
    "12:00",
    "14:00",
    "14:45",
    "14:50",
    "15:35",
    "15:55",
    "16:40",
    "16:45",
    "17:30",
    "19:00",
    "19:45",
    "19:55",
    "20:30",
  ];

  // The start day of the semester.
  var startDay = DateTime.parse("2022-01-22");

  // The date which shown in the table.
  List<DateTime> dateList = [];

  int currentWeekIndex = 0;

  String pageTitle = "我的课表";

  double aspect = 15;

  // Update the weeklist.
  void dateListUpdate() {
    DateTime firstDay = startDay.add(Duration(days: currentWeekIndex * 7));
    dateList = [firstDay];
    for (int i = 1; i < 7; ++i) {
      dateList.add(dateList.last.add(const Duration(days: 1)));
    }
  }

  @override
  void initState() {
    // Get the start day of the semester.
    startDay = DateTime.parse(widget.classData.termStartDay);

    // Get the current index.
    // If they decide to start the class in the next semester, well...
    if (DateTime.now().millisecondsSinceEpoch >=
        startDay.millisecondsSinceEpoch) {
      currentWeekIndex =
          (Jiffy(DateTime.now()).dayOfYear - Jiffy(startDay).dayOfYear) ~/ 7;
    }

    // Remember the current week.
    if (currentWeekIndex >= 0 &&
        currentWeekIndex < widget.classData.semesterLength) {
      currentWeek = currentWeekIndex;
    }

    // Deal with the minus currentWeekIndex
    if (currentWeekIndex < 0) {
      currentWeekIndex = widget.classData.semesterLength - 1;
    }

    // Update dateList
    dateListUpdate();

    // Init the matrix.
    // 1. prepare the structure, a three-deminision array.
    //    for week-day~class array
    pretendLayout = List.generate(
      widget.classData.semesterLength,
      (week) => List.generate(7, (day) => List.generate(10, (classes) => [])),
    );

    // 2. init each week's array
    for (int week = 0; week < widget.classData.semesterLength; ++week) {
      for (int day = 0; day < 7; ++day) {
        // 2.a. Choice the class in this day.
        List<TimeArrangement> thisDay = [];
        for (var i in widget.classData.timeArrangement) {
          // If the class has ended, skip.
          if (i.weekList.length < week + 1) {
            continue;
          }
          if (i.weekList[week] == "1" && i.day == day + 1) {
            thisDay.add(i);
          }
        }

        // 2.b. The longest class should be solved first.
        thisDay.sort((a, b) => b.step.compareTo(a.step));

        // 2.c Arrange the layout. Solve the conflex.
        for (var i in thisDay) {
          for (int j = i.start - 1; j <= i.stop - 1; ++j) {
            pretendLayout[week][day][j]
                .add(widget.classData.timeArrangement.indexOf(i));
          }
        }

        // 2.d. Deal with the empty space.
        for (var i in pretendLayout[week][day]) {
          if (i.isEmpty) {
            i.add(-1);
          }
        }
      }
    }
    super.initState();
  }

  // For the avaliable weeks in the class information.
  Set<int> weekToShow(String weekList) {
    Set<int> toReturn =
        Set.from(List.generate(weekList.length, (index) => index + 1));
    for (int i = 0; i < weekList.length; ++i) {
      if (weekList[i] == "0") {
        toReturn.remove(i + 1);
      }
    }
    return toReturn;
  }

  // The top row is used to change the weeks.
  Widget _topView() {
    Widget dot(bool isOccupied) => ClipOval(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .primaryColor
                  .withOpacity(isOccupied ? 1 : 0.25),
            ),
          ),
        );

    return SizedBox(
      height: widget.constraints.maxHeight * heightRatio[0],
      child: Container(
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 5,
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.classData.semesterLength,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(
                width: widget.constraints.maxWidth / 6,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .primaryColor
                        .withOpacity(currentWeekIndex == index ? 0.3 : 0.0),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      currentWeekIndex = index;
                      dateListUpdate();
                    });
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AutoSizeText(
                          "第${index + 1}周",
                          group: AutoSizeGroup(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            right: 4,
                            top: 4,
                            bottom: 2,
                          ),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 5,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                            children: [
                              for (int i = 0; i < 10; i += 2)
                                for (int day = 0; day < 5; ++day)
                                  dot(!pretendLayout[index][day][i]
                                      .contains(-1))
                            ],
                          ),
                        ),
                        AutoSizeText(
                          index == currentWeek ? "(本周)" : "",
                          textScaleFactor: 0.8,
                          group: AutoSizeGroup(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // The middle row is used to show the date and week.
  Widget _middleView() {
    Widget leftest = Container(
      color: Colors.white,
      width: leftRow,
      child: Center(
        child: AutoSizeText(
          "课次",
          textAlign: TextAlign.center,
          group: AutoSizeGroup(),
          style: const TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
    );

    Widget weekInformation(int index) {
      var list = [
        AutoSizeText(
          weekList[index - 1],
          group: AutoSizeGroup(),
          textScaleFactor: 1.0,
          style: TextStyle(
            //fontSize: 14,
            color: (dateList[index - 1].month == DateTime.now().month &&
                    dateList[index - 1].day == DateTime.now().day)
                ? Colors.lightBlue
                : Colors.black87,
          ),
        ),
        widget.constraints.maxWidth / widget.constraints.maxHeight > 1
            ? const SizedBox(width: 5)
            : const SizedBox(height: 5),
        AutoSizeText(
          "${dateList[index - 1].month}/${dateList[index - 1].day}",
          group: AutoSizeGroup(),
          textScaleFactor:
              widget.constraints.maxWidth / widget.constraints.maxHeight > 1
                  ? 1.0
                  : 0.8,
          style: TextStyle(
            color: (dateList[index - 1].month == DateTime.now().month &&
                    dateList[index - 1].day == DateTime.now().day)
                ? Colors.lightBlue
                : Colors.black87,
          ),
        ),
      ];
      return Container(
        width: (widget.constraints.maxWidth - leftRow) / 7,
        color: dateList[index - 1].month == DateTime.now().month &&
                dateList[index - 1].day == DateTime.now().day
            ? const Color(0x00f7f7f7)
            : Colors.white,
        child: widget.constraints.maxWidth / widget.constraints.maxHeight > 1
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: list,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: list,
              ),
      );
    }

    return Row(
      children: List.generate(8, (index) {
        if (index > 0) {
          return weekInformation(index);
        } else {
          return leftest;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Top line to show the date
          _topView(),
          // The main class table.
          _middleView(),
          // The rest of the table.
          _classTable(),
        ],
      ),
    );
  }

  Widget _classTable() => Expanded(
        child: SingleChildScrollView(
            child: Row(
          children: List.generate(
              8,
              (i) => SizedBox(
                    width: i > 0
                        ? (widget.constraints.maxWidth - leftRow) / 7
                        : leftRow,
                    child: Column(
                      children: _classSubRow(i),
                    ),
                  )),
        )),
      );

  List<Widget> _classSubRow(int index) {
    Widget classCard(int index, double height, Set<int> conflict) {
      Widget inside = index == -1
          ? const Padding(
              padding: EdgeInsets.all(3),
              // Easter egg, usless you read the code, or reverse engineering...
              child: Center(
                child: Text(
                  "BOCCHI RULES!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            )
          : TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.resolveWith(
                  (status) => EdgeInsets.zero,
                ),
                overlayColor: MaterialStateProperty.resolveWith(
                  (status) => Colors.transparent,
                ),
              ),
              onPressed: () => showModalBottomSheet(
                builder: (((context) {
                  return _buttomInformation(conflict);
                })),
                context: context,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Center(
                  child: Text(
                    widget
                        .classData
                        .classDetail[
                            widget.classData.timeArrangement[index].index]
                        .toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: index != -1
                          ? colorList[widget
                                      .classData.timeArrangement[index].index %
                                  colorList.length]
                              .shade900
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            );
      return SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            // Out
            borderRadius: BorderRadius.circular(7),
            child: Container(
              // Border
              color: index == -1
                  ? const Color(0x00000000)
                  : colorList[widget.classData.timeArrangement[index].index %
                          colorList.length]
                      .shade300,
              padding: conflict.length == 1
                  ? const EdgeInsets.all(1)
                  : const EdgeInsets.fromLTRB(1, 1, 1, 8),
              child: ClipRRect(
                // Inner
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  color: index == -1
                      ? const Color(0x00000000)
                      : colorList[
                              widget.classData.timeArrangement[index].index %
                                  colorList.length]
                          .shade100,
                  child: inside,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (index != 0) {
      List<Widget> thisRow = [];

      // Choice the day and render it!
      for (int i = 0; i < 10; ++i) {
        // Places in the onTable array.
        int places = pretendLayout[currentWeekIndex][index - 1][i].first;

        // The length to render.
        int count = 1;
        Set<int> conflict =
            pretendLayout[currentWeekIndex][index - 1][i].toSet();

        // Decide the length to render. i limit the end.
        while (i < 9 &&
            pretendLayout[currentWeekIndex][index - 1][i + 1].first == places) {
          count++;
          i++;
          conflict
              .addAll(pretendLayout[currentWeekIndex][index - 1][i].toSet());
        }

        // Do not include empty spaces...
        conflict.remove(-1);

        // Generate the row.
        thisRow.add(classCard(
          places,
          count * widget.constraints.maxHeight * heightRatio[2] / 10,
          conflict,
        ));
      }

      return thisRow;
    } else {
      // Leftest side, the index array.
      return List.generate(
        10,
        (index) => SizedBox(
          width: leftRow,
          height: widget.constraints.maxHeight * heightRatio[2] / 10,
          child: Center(
            child: AutoSizeText(
              "${index + 1}",
              group: AutoSizeGroup(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buttomInformation(Set<int> conflict) {
    List<TimeArrangement> information = List.generate(conflict.length,
        (index) => widget.classData.timeArrangement[conflict.elementAt(index)]);

    List<Widget> toShow = [
      _classInfoBox(information.first),
    ];

    if (conflict.length > 1) {
      toShow.addAll([
        for (int i = 1; i < conflict.length; ++i) _classInfoBox(information[i]),
      ]);
    }

    return ListView(
      shrinkWrap: true,
      children: toShow,
    );
  }

  Widget _classInfoBox(TimeArrangement i) {
    ClassDetail toShow = widget.classData.classDetail[i.index];
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.class_),
                const SizedBox(),
                Text(toShow.name),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(),
                Text(toShow.teacher ?? "老师未定"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.room),
                const SizedBox(),
                Text(toShow.place ?? "地点未定"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(),
                Text(
                    "${weekList[i.day - 1]} ${i.start}-${i.stop}节课 ${time[(i.start - 1) * 2]}-${time[(i.stop - 1) * 2 + 1]}"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(),
                Expanded(
                  child: Text(
                    weekToShow(i.weekList).toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
