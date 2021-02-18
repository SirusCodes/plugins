// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_web/file_selector_web.dart';
import 'package:file_selector_web/src/dom_helper.dart';

void main() {
  group('FileSelectorWeb', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    group('openFile', () {
      late MockDomHelper mockDomHelper;
      late FileSelectorWeb plugin;
      late XFile mockFile;

      setUp(() {
        mockFile = createXFile('1001', 'identity.png');

        mockDomHelper = MockDomHelper()..setFiles([mockFile]);
        plugin = FileSelectorWeb(domHelper: mockDomHelper);
      });

      testWidgets('works', (WidgetTester _) async {
        final typeGroup = XTypeGroup(
          label: 'images',
          extensions: ['jpg', 'jpeg'],
          mimeTypes: ['image/png'],
          webWildCards: ['image/*'],
        );

        final file = await plugin.openFile(acceptedTypeGroups: [typeGroup]);

        expect(file.name, mockFile.name);
        expect(await file.length(), 4);
        expect(await file.readAsString(), '1001');
        expect(await file.lastModified(), isNotNull);
      });
    });

    group('openFiles', () {
      late MockDomHelper mockDomHelper;
      late FileSelectorWeb plugin;
      late XFile mockFile1, mockFile2;

      setUp(() {
        mockFile1 = createXFile('123456', 'file1.txt');
        mockFile2 = createXFile('', 'file2.txt');

        mockDomHelper = MockDomHelper()..setFiles([mockFile1, mockFile2]);
        plugin = FileSelectorWeb(domHelper: mockDomHelper);
      });

      testWidgets('works', (WidgetTester _) async {
        final typeGroup = XTypeGroup(
          label: 'files',
          extensions: ['.txt'],
        );

        final files = await plugin.openFiles(acceptedTypeGroups: [typeGroup]);

        expect(files.length, 2);

        expect(files[0].name, mockFile1.name);
        expect(await files[0].length(), 6);
        expect(await files[0].readAsString(), '123456');
        expect(await files[0].lastModified(), isNotNull);

        expect(files[1].name, mockFile2.name);
        expect(await files[1].length(), 0);
        expect(await files[1].readAsString(), '');
        expect(await files[1].lastModified(), isNotNull);
      });
    });
  });
}

class MockDomHelper implements DomHelper {
  List<XFile> _files = <XFile>[];

  @override
  Future<List<XFile>> getFiles({
    String accept = '',
    bool multiple = false,
    FileUploadInputElement? input,
  }) {
    return Future.value(_files);
  }

  void setFiles(List<XFile> files) {
    _files = files;
  }
}

XFile createXFile(String content, String name) {
  final data = Uint8List.fromList(content.codeUnits);
  return XFile.fromData(data, name: name, lastModified: DateTime.now());
}
