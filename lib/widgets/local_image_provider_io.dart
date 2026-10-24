import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider<Object> localImageProvider(String path) => FileImage(File(path));
