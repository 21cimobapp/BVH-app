import 'package:civideoconnectadmin/utils/Database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectadmin/globals.dart' as globals;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final TextEditingController _controllerTitle = new TextEditingController();
final TextEditingController _controllerDate = new TextEditingController();
final TextEditingController _controllerURL = new TextEditingController();
DateTime convertToDate(String input) {
  try {
    var d = new DateFormat.yMd().parseStrict(input);
    return d;
  } catch (e) {
    return null;
  }
}

class UploadFile extends StatefulWidget {
  final String userType;
  final int imageID;

  /// Creates a call page with given channel name.
  const UploadFile({Key key, this.userType, this.imageID}) : super(key: key);

  final String title = 'Upload Documents';

  @override
  UploadFileState createState() => UploadFileState();
}

class UploadFileState extends State<UploadFile> {
  //
  String _path;
  Map<String, String> _paths;
  String _extension;
  FileType _pickType;
  bool _multiPick = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  String fileName;
  String filePath;
  File _document;
  bool _isUpload = false;

  bool downloading = false;
  double download = 0.0;
  File downloadFileName;
  String downloadingStr = "";
  String progressString = '0';
  var uuid = Uuid();
  int imageSource = 0;

  final ImagePicker picker = ImagePicker();

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now());

    if (result == null) return;

    setState(() {
      _controllerDate.text = new DateFormat.yMd().format(result);
    });
  }

  void initState() {
    super.initState();
    _pickType = FileType.media;
    // _pickType = widget.fileType;
    // _controllerDate.text = new DateFormat.yMd().format(DateTime.now());
    // if (_pickType == FileType.image) {
    //   getImage();
    // } else if (_pickType == FileType.media) {
    //   getCameraImage();
    // } else {
    //   openFileExplorer();
    // }
  }

  Future getImage() async {
    //final pickedFile = await picker.getImage(source: imageSource);

    String fileName;

    _path = await FilePicker.getFilePath(
        type: FileType.custom, allowedExtensions: ['jpg', 'png']);
    if (_path == null) {
      //Navigator.pop(context);
    } else {
      setState(() {
        _document = File(_path);
        fileName = "${uuid.v4()}.${_document.path.split('.').last}";
      });
    }
  }

  uploadFileToFB() {
    _isUpload = true;
    fileName = _document.path.split('/').last;
    filePath = _document.path;

    uploadToFirebase(fileName, filePath);
  }

  uploadToFirebase(fileName, filePath) {
    if (_multiPick) {
      _paths.forEach((fileName, filePath) => {upload(fileName, filePath)});
    } else {
      upload(fileName, filePath);
    }
  }

  upload(fileName, filePath) {
    _extension = fileName.toString().split('.').last;
    // StorageReference storageRef = FirebaseStorage.instance.ref().child(
    //     "21ci/Appointments/" + widget.resourceAllocNumber + "/" + fileName);

    StorageReference storageRef = FirebaseStorage.instance
        .ref()
        .child("SliderImages")
        .child(widget.userType)
        .child(fileName);

    final StorageUploadTask uploadTask = storageRef.putFile(
      File(filePath),
      StorageMetadata(
        contentType: '$_pickType/$_extension',
      ),
    );
    setState(() {
      _tasks.add(uploadTask);
    });
  }

  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';
  }

  getFileType() {
    String fileType;
    fileType = _pickType.toString().split('.').last;
    if (fileType == "media") {
      return "image";
    } else {
      return fileType;
    }
  }

  _onUploadSuccess() async {
    //_showSnackBar("File Uploaded");

    Navigator.pop(context);
  }

  _onUploadFailed() async {
    //_showSnackBar("Upload Failed");
    Navigator.pop(context);
  }

  _showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
    );
//    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    _tasks.forEach((StorageUploadTask task) {
      final Widget tile = UploadTaskListTile(
        userType: widget.userType,
        fileName: fileName,
        fileType: getFileType(),
        imageID: widget.imageID,
        task: task,
        onDismissed: () => setState(() => _tasks.remove(task)),
        onUploadSuccess: () => {_onUploadSuccess()},
        onUploadFailed: () => {_onUploadFailed()},
      );
      children.add(tile);
    });
    Color accentColor = Theme.of(context).accentColor;

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Radio(
                        value: 0,
                        groupValue: imageSource,
                        onChanged: changeImageSource,
                      ),
                      new Text(
                        'Upload from Device',
                        style:
                            new TextStyle(fontSize: 16.0, color: accentColor),
                      ),
                      new Radio(
                        value: 1,
                        groupValue: imageSource,
                        onChanged: changeImageSource,
                      ),
                      new Text(
                        'Upload from URL',
                        style:
                            new TextStyle(fontSize: 16.0, color: accentColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: _document == null
                        ? Text('No image selected.')
                        : Container(
                            height: MediaQuery.of(context).size.height / 4,
                            child: Image.file(_document)),
                  ),
                  imageSource == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () {
                                getImage();
                              },
                              child: Text("Load Image"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              elevation: 2.0,
                              //fillColor: Theme.of(context).accentColor,
                              padding: const EdgeInsets.all(5.0),
                            ),
                          ],
                        )
                      : imageSource == 1
                          ? Container(
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      icon: const Icon(Icons.image),
                                      hintText: '',
                                      labelText: 'Enter URL',
                                    ),
                                    controller: _controllerURL,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      RawMaterialButton(
                                        onPressed: () {
                                          downloadFile(_controllerURL.text);
                                        },
                                        child: Text("Load Image"),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        elevation: 2.0,
                                        //fillColor: Theme.of(context).accentColor,
                                        padding: const EdgeInsets.all(5.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.image),
                      hintText: '',
                      labelText: 'Image Title',
                    ),
                    controller: _controllerTitle,
                  ),
                  Row(children: <Widget>[
                    new Expanded(
                        child: new TextFormField(
                      decoration: new InputDecoration(
                        icon: const Icon(Icons.calendar_today),
                        hintText: '',
                        labelText: 'Effective Date',
                      ),
                      controller: _controllerDate,
                      keyboardType: TextInputType.datetime,
                    )),
                    new IconButton(
                      icon: new Icon(Icons.more_horiz),
                      tooltip: 'Choose date',
                      onPressed: (() {
                        _chooseDate(context, _controllerDate.text);
                      }),
                    )
                  ]),
                  SizedBox(
                    height: 20.0,
                  ),
                  _document == null || _isUpload
                      ? Center()
                      : Center(
                          child: Container(
                              width: 100,
                              child: RawMaterialButton(
                                onPressed: () => {uploadFileToFB()},
                                child: Icon(
                                  Icons.file_upload,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: Theme.of(context).accentColor)),
                                elevation: 2.0,
                                fillColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.all(15.0),
                              )),
                        ),
                  Flexible(
                    child: ListView(
                      children: children,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  changeImageSource(int value) {
    setState(() {
      imageSource = value;
    });
  }

  Future<void> downloadFile(url) async {
    Dio dio = Dio();
    Response response;
    String filename;
    try {
      var dir = await getApplicationDocumentsDirectory();
      if (_document != null)
        filename =
            "${dir.path}/" + "${uuid.v4()}.${_document.path.split('.').last}";
      else
        filename = "${dir.path}/" + "${uuid.v4()}}";

      response =
          await dio.download(url, filename, onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");

        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e);
    }
    print(response.data.toString());
    setState(() {
      downloading = false;
      progressString = "Completed";
    });

    setState(() {
      _document = File(filename);
    });

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PDFScreen(path: filename),
    //   ),
    // );
    print("Download completed");
  }
}

class UploadTaskListTile extends StatelessWidget {
  const UploadTaskListTile(
      {Key key,
      this.userType,
      this.fileName,
      this.task,
      this.fileType,
      this.imageID,
      this.onDismissed,
      this.onUploadSuccess,
      this.onUploadFailed})
      : super(key: key);
  final String userType;
  final String fileName;
  final String fileType;
  final int imageID;
  final StorageUploadTask task;
  final VoidCallback onDismissed;
  final VoidCallback onUploadSuccess;
  final VoidCallback onUploadFailed;

  String get status {
    String result = "";

    if (task.isComplete) {
      if (task.isSuccessful) {
        result = 'Complete';
        saveToDatabase();
      } else if (task.isCanceled) {
        result = 'Canceled';

        onUploadFailed();
      } else {
        result = 'Failed ERROR: ${task.lastSnapshot.error}';

        onUploadFailed();
      }
    } else if (task.isInProgress) {
      result = 'Uploading';
    } else if (task.isPaused) {
      result = 'Paused';
    }

    return result;
  }

  saveToDatabase() async {
    String url = await task.lastSnapshot.ref.getDownloadURL();

    Map<String, dynamic> document = {
      "documentName": task.lastSnapshot.storageMetadata.name,
      "documentURL": url,
      "documentType": fileType,
      "documentTitle": _controllerTitle.text,
      "effectiveDate": convertToDate(_controllerDate.text),
      "uploadedDate": DateTime.now(),
      "userType": userType,
      "imageID": imageID
    };

    await DatabaseMethods().addSliderImages(document, userType, imageID);

    onUploadSuccess();
  }

  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageTaskEvent>(
      stream: task.events,
      builder: (BuildContext context,
          AsyncSnapshot<StorageTaskEvent> asyncSnapshot) {
        Widget subtitle;
        if (asyncSnapshot.hasData) {
          final StorageTaskEvent event = asyncSnapshot.data;
          final StorageTaskSnapshot snapshot = event.snapshot;
          subtitle = Text('$status: ${_bytesTransferred(snapshot)} bytes sent');
        } else {
          subtitle = const Text('Starting...');
        }
        return Dismissible(
          key: Key(task.hashCode.toString()),
          onDismissed: (_) => onDismissed(),
          child: ListTile(
            title: Text(fileName),
            subtitle: subtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Offstage(
                  offstage: !task.isInProgress,
                  child: IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => task.pause(),
                  ),
                ),
                Offstage(
                  offstage: !task.isPaused,
                  child: IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: () => task.resume(),
                  ),
                ),
                Offstage(
                  offstage: task.isComplete,
                  child: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => task.cancel(),
                  ),
                ),
                // Offstage(
                //   offstage: !(task.isComplete && task.isSuccessful),
                //   child: IconButton(
                //     icon: const Icon(Icons.file_download),
                //     onPressed: onDownload,
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
