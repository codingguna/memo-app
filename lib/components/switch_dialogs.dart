import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../services/api_service.dart';

class BlocksRawViewerDialog extends StatefulWidget {
  final dynamic data;

  const BlocksRawViewerDialog({super.key, required this.data});

  @override
  State<BlocksRawViewerDialog> createState() => _BlocksRawViewerDialogState();
}

class _BlocksRawViewerDialogState extends State<BlocksRawViewerDialog> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Direct JSON encoding without type checking
    final jsonString = jsonEncode(widget.data);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { 
              font-family: Arial, sans-serif; 
              margin: 10px; 
              background-color: #f5f5f5; 
            }
            pre { 
              white-space: pre-wrap; 
              word-wrap: break-word; 
              background-color: #fff;
              padding: 15px;
              border: 1px solid #ddd;
              border-radius: 5px;
              font-size: 14px;
              line-height: 1.4;
            }
            h3 { 
              color: #333; 
              margin-bottom: 10px; 
            }
          </style>
        </head>
        <body>
          <h3>Raw Response</h3>
          <pre>${_escapeHtml(jsonString)}</pre>
        </body>
        </html>
      ''');
  }

  String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('API Response'),
      content: SizedBox(
        width: double.maxFinite, 
        height: 400, 
        child: WebViewWidget(controller: _controller)
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Close')
        )
      ],
    );
  }
}

class BlockSwitchingDialog extends StatefulWidget {
  final ApiService apiService;
  final String hospitalId;

  const BlockSwitchingDialog({
    super.key,
    required this.apiService,
    required this.hospitalId,
  });

  @override
  State<BlockSwitchingDialog> createState() => _BlockSwitchingDialogState();
}

class _BlockSwitchingDialogState extends State<BlockSwitchingDialog> {
  bool isLoading = true;
  String? errorMessage;
  dynamic blocksData;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    try {
      // Get raw response - whatever type it is
      final response = await widget.apiService.getBlocks(int.parse(widget.hospitalId));
      print('Raw blocks response: $response');
      
      setState(() {
        blocksData = response; // Store as-is, no type checking
        isLoading = false;
      });

      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => BlocksRawViewerDialog(data: blocksData),
        );
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Loading Blocks...'),
      content: isLoading
          ? const CircularProgressIndicator()
          : Text(errorMessage ?? 'Done'),
    );
  }
}

class WardRawViewerDialog extends StatefulWidget {
  final dynamic data;

  const WardRawViewerDialog({super.key, required this.data});

  @override
  State<WardRawViewerDialog> createState() => _WardRawViewerDialogState();
}

class _WardRawViewerDialogState extends State<WardRawViewerDialog> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Direct JSON encoding without type checking
    final jsonString = jsonEncode(widget.data);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { 
              font-family: Arial, sans-serif; 
              margin: 10px; 
              background-color: #f5f5f5; 
            }
            pre { 
              white-space: pre-wrap; 
              word-wrap: break-word; 
              background-color: #fff;
              padding: 15px;
              border: 1px solid #ddd;
              border-radius: 5px;
              font-size: 14px;
              line-height: 1.4;
            }
            h3 { 
              color: #333; 
              margin-bottom: 10px; 
            }
          </style>
        </head>
        <body>
          <h3>Ward Data</h3>
          <pre>${_escapeHtml(jsonString)}</pre>
        </body>
        </html>
      ''');
  }

  String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Raw Ward Data'),
      content: SizedBox(
        width: double.maxFinite, 
        height: 400, 
        child: WebViewWidget(controller: _controller)
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Close')
        )
      ],
    );
  }
}

class WardSwitchingDialog extends StatefulWidget {
  final ApiService apiService;
  final String hospitalId;

  const WardSwitchingDialog({
    super.key,
    required this.apiService,
    required this.hospitalId,
  });

  @override
  State<WardSwitchingDialog> createState() => _WardSwitchingDialogState();
}

class _WardSwitchingDialogState extends State<WardSwitchingDialog> {
  bool isLoading = true;
  String? errorMessage;
  dynamic wardData;

  @override
  void initState() {
    super.initState();
    _loadWards();
  }

  Future<void> _loadWards() async {
    try {
      // Get raw response - whatever type it is
      final response = await widget.apiService.getWards(int.parse(widget.hospitalId));
      print('Raw ward data: $response');
      
      setState(() {
        wardData = response; // Store as-is, no type checking
        isLoading = false;
      });

      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => WardRawViewerDialog(data: wardData),
        );
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Loading Wards...'),
      content: isLoading
          ? const CircularProgressIndicator()
          : Text(errorMessage ?? 'Done'),
    );
  }
}