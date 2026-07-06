import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';

class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key});

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Utilities'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.navy800,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.accentBlue.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: AppColors.accentBlue,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Base64'),
                Tab(text: 'URL'),
                Tab(text: 'Binary'),
                Tab(text: 'Hex'),
              ],
            ),
          ),
        ),
      ),
      body: ResponsiveContent(
        child: TabBarView(
          controller: _tabController,
          children: const [
            _Base64Tab(),
            _URLTab(),
            _BinaryTab(),
            _HexTab(),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final Widget child;
  const _ToolCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navy700.withAlpha(80)),
      ),
      child: child,
    );
  }
}

class _OutputField extends StatelessWidget {
  final String label;
  final String text;

  const _OutputField({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
              if (text.isNotEmpty)
              GestureDetector(
                onTap: () => Clipboard.setData(ClipboardData(text: text)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.navy800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Copy',
                    style: GoogleFonts.inter(
                      color: AppColors.accentBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.navy800,
            borderRadius: BorderRadius.circular(10),
          ),
            child: SelectableText(
              text.isNotEmpty ? text : 'Result will appear here',
              style: TextStyle(
                color: text.isNotEmpty ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 13,
                fontFamily: text.length > 50 ? 'monospace' : null,
              ),
            ),
        ),
      ],
    );
  }
}

class _Base64Tab extends StatefulWidget {
  const _Base64Tab();

  @override
  State<_Base64Tab> createState() => _Base64TabState();
}

class _Base64TabState extends State<_Base64Tab> {
  final _inputController = TextEditingController();
  String _output = '';
  bool _isEncoding = true;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final text = _inputController.text;
    if (text.isEmpty) {
      setState(() { _output = ''; _error = null; });
      return;
    }
    setState(() { _error = null; });
    try {
      if (_isEncoding) {
        _output = base64Encode(utf8.encode(text));
      } else {
        _output = utf8.decode(base64Decode(text));
      }
    } catch (e) {
      _error = 'Invalid Base64 input';
      _output = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ToolCard(
            child: Column(
              children: [
                Row(
                  children: [
                    _modeButton('Encode', _isEncoding, () => setState(() { _isEncoding = true; _output = ''; _error = null; })),
                    const SizedBox(width: 8),
                    _modeButton('Decode', !_isEncoding, () => setState(() { _isEncoding = false; _output = ''; _error = null; })),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _inputController,
                  maxLines: 4,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: _isEncoding ? 'Enter text to encode' : 'Enter Base64 to decode',
                    hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _convert, child: Text(_isEncoding ? 'Encode' : 'Decode')),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 13)),
          ],
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 16),
            _OutputField(label: 'Result', text: _output),
          ],
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.accentBlue.withAlpha(25) : AppColors.navy800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppColors.accentBlue : AppColors.navy700,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: active ? AppColors.accentBlue : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _URLTab extends StatefulWidget {
  const _URLTab();

  @override
  State<_URLTab> createState() => _URLTabState();
}

class _URLTabState extends State<_URLTab> {
  final _inputController = TextEditingController();
  String _output = '';
  bool _isEncoding = true;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final text = _inputController.text;
    if (text.isEmpty) { setState(() => _output = ''); return; }
    try {
      _output = _isEncoding ? Uri.encodeComponent(text) : Uri.decodeComponent(text);
    } catch (_) {
      _output = 'Invalid input';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ToolCard(
            child: Column(
              children: [
                Row(
                  children: [
                    _modeButton('Encode', _isEncoding, () => setState(() { _isEncoding = true; _output = ''; })),
                    const SizedBox(width: 8),
                    _modeButton('Decode', !_isEncoding, () => setState(() { _isEncoding = false; _output = ''; })),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _inputController,
                  maxLines: 4,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: _isEncoding ? 'Enter URL to encode' : 'Enter encoded URL',
                    hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _convert, child: Text(_isEncoding ? 'Encode' : 'Decode')),
                ),
              ],
            ),
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 16),
            _OutputField(label: 'Result', text: _output),
          ],
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.accentBlue.withAlpha(25) : AppColors.navy800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppColors.accentBlue : AppColors.navy700,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: active ? AppColors.accentBlue : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _BinaryTab extends StatefulWidget {
  const _BinaryTab();

  @override
  State<_BinaryTab> createState() => _BinaryTabState();
}

class _BinaryTabState extends State<_BinaryTab> {
  final _inputController = TextEditingController();
  String _output = '';
  bool _isTextToBinary = true;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final text = _inputController.text;
    if (text.isEmpty) { setState(() { _output = ''; _error = null; }); return; }
    setState(() => _error = null);
    try {
      if (_isTextToBinary) {
        _output = text.codeUnits.map((c) => c.toRadixString(2).padLeft(8, '0')).join(' ');
      } else {
        final cleaned = text.replaceAll(RegExp(r'\s+'), '');
        if (!RegExp(r'^[01]+$').hasMatch(cleaned)) {
          _error = 'Invalid binary — only 0 and 1 allowed';
          _output = '';
          return;
        }
        final bytes = Uint8List.fromList(
          List.generate(cleaned.length ~/ 8, (i) {
            final byte = cleaned.substring(i * 8, (i + 1) * 8);
            return int.parse(byte, radix: 2);
          }),
        );
        _output = utf8.decode(bytes, allowMalformed: true);
      }
    } catch (_) {
      _error = 'Conversion failed';
      _output = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ToolCard(
            child: Column(
              children: [
                Row(
                  children: [
                    _modeButton('Text → Binary', _isTextToBinary, () => setState(() { _isTextToBinary = true; _output = ''; _error = null; })),
                    const SizedBox(width: 8),
                    _modeButton('Binary → Text', !_isTextToBinary, () => setState(() { _isTextToBinary = false; _output = ''; _error = null; })),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _inputController,
                  maxLines: 4,
                  style: TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace'),
                decoration: InputDecoration(
                    hintText: _isTextToBinary ? 'Enter text' : 'Enter binary (space-separated)',
                    hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _convert, child: Text(_isTextToBinary ? 'To Binary' : 'To Text')),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 13)),
          ],
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 16),
            _OutputField(label: 'Result', text: _output),
          ],
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.accentBlue.withAlpha(25) : AppColors.navy800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppColors.accentBlue : AppColors.navy700,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: active ? AppColors.accentBlue : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _HexTab extends StatefulWidget {
  const _HexTab();

  @override
  State<_HexTab> createState() => _HexTabState();
}

class _HexTabState extends State<_HexTab> {
  final _inputController = TextEditingController();
  String _output = '';
  bool _isTextToHex = true;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final text = _inputController.text;
    if (text.isEmpty) { setState(() { _output = ''; _error = null; }); return; }
    setState(() => _error = null);
    try {
      if (_isTextToHex) {
        _output = text.codeUnits.map((c) => '0x${c.toRadixString(16).padLeft(2, '0').toUpperCase()}').join(' ');
      } else {
        final cleaned = text.replaceAll('0x', '').replaceAll(RegExp(r'\s+'), '');
        if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleaned)) {
          _error = 'Invalid hex — only 0-9, A-F allowed';
          _output = '';
          return;
        }
        final bytes = Uint8List.fromList(
          List.generate(cleaned.length ~/ 2, (i) {
            final hex = cleaned.substring(i * 2, (i + 1) * 2);
            return int.parse(hex, radix: 16);
          }),
        );
        _output = utf8.decode(bytes, allowMalformed: true);
      }
    } catch (_) {
      _error = 'Conversion failed';
      _output = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ToolCard(
            child: Column(
              children: [
                Row(
                  children: [
                    _modeButton('Text → Hex', _isTextToHex, () => setState(() { _isTextToHex = true; _output = ''; _error = null; })),
                    const SizedBox(width: 8),
                    _modeButton('Hex → Text', !_isTextToHex, () => setState(() { _isTextToHex = false; _output = ''; _error = null; })),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _inputController,
                  maxLines: 4,
                  style: TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: _isTextToHex ? 'Enter text' : 'Enter hex (e.g. 48656C6C6F)',
                    hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _convert, child: Text(_isTextToHex ? 'To Hex' : 'To Text')),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 13)),
          ],
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 16),
            _OutputField(label: 'Result', text: _output),
          ],
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.accentBlue.withAlpha(25) : AppColors.navy800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppColors.accentBlue : AppColors.navy700,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: active ? AppColors.accentBlue : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
