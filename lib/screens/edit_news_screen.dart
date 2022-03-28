import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/screen_arguments.dart';

import '../providers/news_block.dart';

class EditNewsScreen extends StatefulWidget {
  static const routeName = '/edit-news';

  @override
  State<EditNewsScreen> createState() => _EditNewsScreenState();
}

class _EditNewsScreenState extends State<EditNewsScreen> {
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedNews = NewsBlock(
    id: null,
    title: '',
    body: '',
    image: null,
    date: null,
    author: '',
    usersWhoAddToFavorite: [],
    commentUser: [],
  );
  Map<String, dynamic> _initValues = {
    'title': '',
    'body': '',
    'image': null,
    'date': null,
    'author': '',
    'usersWhoAddToFavorite': [],
    'commentUser': [],
  };
  var _isInit = true;
  var _isLoading = false;
  File? _pickedImage;

  Future<void> _takeImageFromDevice(
      ImageSource source, BuildContext context) async {
    final _picker = ImagePicker();
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 700,
        maxHeight: 450,
        imageQuality: 70,
      );
      if (pickedFile == null) return;
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    } catch (e) {
      print('error in pick image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final screenArguments =
        ModalRoute.of(context)?.settings.arguments as ScreenArguments;
    if (_isInit) {
      final newsId = screenArguments.newsId;
      if (newsId != null) {
        _editedNews = Provider.of<NewsBlocks>(context, listen: false)
            .findById(newsId.toString());
        _initValues = {
          'title': _editedNews.title,
          'image': _editedNews.image,
          'body': _editedNews.body,
          'date': _editedNews.date,
          'usersWhoAddToFavorite': _editedNews.usersWhoAddToFavorite,
          'commentUser': _editedNews.commentUser,
        };
        _pickedImage = _editedNews.image;
      }
    }
    _initValues['author'] = screenArguments.email;
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) return;
    if (_pickedImage == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('ERROR'),
          content: const Text('Take a photo!'),
          actions: [
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
      return;
    }
    _form.currentState?.save();
    _editedNews.image = _pickedImage;
    _editedNews.author = _initValues['author'];
    setState(() {
      _isLoading = true;
    });
    if (_editedNews.id != null) {
      await Provider.of<NewsBlocks>(context, listen: false)
          .updateNews(_editedNews.id!, _editedNews);
    } else {
      await Provider.of<NewsBlocks>(context, listen: false)
          .addNews(_editedNews);
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_titleFocusNode);
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedNews = NewsBlock(
                          id: _editedNews.id,
                          title: val!,
                          body: _editedNews.body,
                          image: _editedNews.image,
                          date: _editedNews.date,
                          author: _editedNews.author,
                          usersWhoAddToFavorite:
                              _editedNews.usersWhoAddToFavorite,
                          commentUser: _editedNews.commentUser,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['body'],
                      decoration: const InputDecoration(labelText: 'Body'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (val) {
                        if (val!.isEmpty) return 'Please enter a description.';
                        if (val.length < 10) {
                          return 'Should be at least 10 characters long.';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedNews = NewsBlock(
                          id: _editedNews.id,
                          title: _editedNews.title,
                          body: val!,
                          image: _editedNews.image,
                          date: _editedNews.date,
                          author: _editedNews.author,
                          usersWhoAddToFavorite:
                              _editedNews.usersWhoAddToFavorite,
                          commentUser: _editedNews.commentUser,
                        );
                      },
                    ),
                    Container(
                      width: deviceSize.width * 0.6,
                      height: deviceSize.width * 0.6,
                      margin: const EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: _pickedImage != null
                          ? FittedBox(
                              child: Image.file(_pickedImage!),
                              fit: BoxFit.cover,
                              clipBehavior: Clip.hardEdge,
                            )
                          : const Center(
                              child: Text('Take a photo!'),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.camera),
                          label: const Text('Take a photo'),
                          onPressed: () {
                            _takeImageFromDevice(ImageSource.camera, context);
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.folder),
                          label: const Text(
                            'Take a photo\nfrom device',
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            _takeImageFromDevice(ImageSource.gallery, context);
                          },
                        ),
                      ],
                    ),
                    if (_editedNews.id != null)
                      Center(
                        child: ElevatedButton.icon(
                          label: const Text('Delete'),
                          icon: const Icon(Icons.delete),
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).errorColor,
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
