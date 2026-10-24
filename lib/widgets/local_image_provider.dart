import 'package:flutter/widgets.dart';

import 'local_image_provider_stub.dart'
    if (dart.library.io) 'local_image_provider_io.dart'
    if (dart.library.js_interop) 'local_image_provider_web.dart'
    as provider;

ImageProvider<Object> localImageProvider(String path) =>
    provider.localImageProvider(path);
