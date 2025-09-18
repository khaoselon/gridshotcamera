import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:gridshot_camera/services/settings_service.dart';
import 'package:gridshot_camera/models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final settings = SettingsService.instance.currentSettings;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.settingsTitle,
              style: theme.appBarTheme.titleTextStyle?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => _showResetDialog(l10n, theme, colorScheme),
                tooltip: l10n.resetSettings,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: const CircleBorder(),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return _buildLandscapeLayout(
                    settings,
                    l10n,
                    theme,
                    colorScheme,
                  );
                } else {
                  return _buildPortraitLayout(
                    settings,
                    l10n,
                    theme,
                    colorScheme,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    AppSettings settings,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: _buildAllSections(settings, l10n, theme, colorScheme),
    );
  }

  Widget _buildLandscapeLayout(
    AppSettings settings,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final sections = _buildAllSections(settings, l10n, theme, colorScheme);

    // セクションをより均等に左右に分割
    final leftSections = <Widget>[];
    final rightSections = <Widget>[];

    // 言語設定とグリッド設定を左に、画像品質とアプリ情報を右に配置
    if (sections.length >= 4) {
      leftSections.addAll([
        sections[0], // 言語設定
        const SizedBox(height: 20),
        sections[1], // グリッド境界線設定（完全なセクション）
      ]);

      rightSections.addAll([
        sections[2], // 画像品質設定
        const SizedBox(height: 20),
        sections[3], // アプリ情報
      ]);
    } else {
      // セクション数が少ない場合は交互に配置
      for (int i = 0; i < sections.length; i++) {
        if (i % 2 == 0) {
          leftSections.add(sections[i]);
          if (i + 1 < sections.length)
            leftSections.add(const SizedBox(height: 20));
        } else {
          rightSections.add(sections[i]);
          if (i + 1 < sections.length)
            rightSections.add(const SizedBox(height: 20));
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左側のセクション
          Expanded(child: Column(children: leftSections)),
          const SizedBox(width: 20),
          // 右側のセクション
          Expanded(child: Column(children: rightSections)),
        ],
      ),
    );
  }

  List<Widget> _buildAllSections(
    AppSettings settings,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return [
      // 言語設定セクション
      _buildSectionCard(
        title: l10n.language,
        icon: Icons.language_rounded,
        theme: theme,
        colorScheme: colorScheme,
        children: [_buildLanguageTile(settings, l10n, theme, colorScheme)],
      ),

      const SizedBox(height: 20),

      // グリッド表示設定セクション
      _buildSectionCard(
        title: l10n.gridBorder,
        icon: Icons.grid_on_rounded,
        theme: theme,
        colorScheme: colorScheme,
        children: [
          _buildGridBorderTile(settings, l10n, theme, colorScheme),

          if (settings.showGridBorder) ...[
            const Divider(height: 24),
            _buildBorderColorTile(settings, l10n, theme, colorScheme),
            _buildBorderWidthSlider(settings, l10n, theme, colorScheme),
          ],
        ],
      ),

      const SizedBox(height: 20),

      // 画像品質設定セクション
      _buildSectionCard(
        title: l10n.imageQuality,
        icon: Icons.photo_size_select_actual_rounded,
        theme: theme,
        colorScheme: colorScheme,
        children: [
          _buildImageQualitySection(settings, l10n, theme, colorScheme),
        ],
      ),

      const SizedBox(height: 20),

      // アプリ情報セクション
      _buildSectionCard(
        title: l10n.appInfo,
        icon: Icons.info_rounded,
        theme: theme,
        colorScheme: colorScheme,
        children: [_buildAppInfoTiles(l10n, theme, colorScheme)],
      ),

      const SizedBox(height: 40),
    ];
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.secondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // 修正：すべてのサポート言語を含む完全な多言語ドロップダウン
  Widget _buildLanguageTile(
    AppSettings settings,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        l10n.language,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          _getLanguageDisplayName(settings.languageCode, l10n),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
      trailing: Container(
        constraints: const BoxConstraints(
          minWidth: 140, // 最小幅を確保
          maxWidth: 180, // 最大幅も制限
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: DropdownButton<String>(
          value: settings.languageCode,
          underline: const SizedBox(),
          isExpanded: true, // 追加：幅を最大限に使用
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.primary,
          ),
          dropdownColor: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          items: _buildLanguageDropdownItems(l10n),
          onChanged: (value) async {
            if (value != null) {
              await SettingsService.instance.updateLanguage(value);
            }
          },
        ),
      ),
    );
  }

  // 完全な言語ドロップダウンアイテムリストを構築
  List<DropdownMenuItem<String>> _buildLanguageDropdownItems(
    AppLocalizations l10n,
  ) {
    return [
      // システムデフォルト
      DropdownMenuItem(
        value: 'system',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌍', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              // 追加：テキスト部分を拡張
              child: Text(
                l10n.systemDefault,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis, // 追加：オーバーフロー処理
              ),
            ),
          ],
        ),
      ),

      // 日本語
      DropdownMenuItem(
        value: 'ja',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇯🇵', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.japanese,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // 英語
      DropdownMenuItem(
        value: 'en',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇺🇸', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.english,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // ドイツ語
      DropdownMenuItem(
        value: 'de',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇩🇪', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Deutsch',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // スペイン語
      DropdownMenuItem(
        value: 'es',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇪🇸', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Español',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // イタリア語
      DropdownMenuItem(
        value: 'it',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇮🇹', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Italiano',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // 韓国語
      DropdownMenuItem(
        value: 'ko',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇰🇷', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '한국어',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // ポルトガル語
      DropdownMenuItem(
        value: 'pt',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇵🇹', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Português',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // 中国語簡体字
      DropdownMenuItem(
        value: 'zh',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇨🇳', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '简体中文',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // 中国語繁体字
      DropdownMenuItem(
        value: 'zh-Hant',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇹🇼', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '繁體中文',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildGridBorderTile(
    AppSettings settings,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SwitchListTile(
      title: Text(
        l10n.gridBorder,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        l10n.gridBorderDescription,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      value: settings.showGridBorder,
      activeColor: colorScheme.primary,
      onChanged: (value) {
        SettingsService.instance.updateGridBorderDisplay(value);
      },
    );
  }

  Widget _buildBorderColorTile(
    AppSettings settings,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListTile(
      title: Text(
        l10n.borderColor,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        l10n.currentColor(_getColorName(l10n, settings.borderColor)),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: settings.borderColor,
          border: Border.all(color: colorScheme.outline, width: 2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: settings.borderColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      onTap: () => _showColorPicker(context, l10n, theme, colorScheme),
    );
  }

  Widget _buildBorderWidthSlider(
    AppSettings settings,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.borderWidth}: ${l10n.borderWidthValue(settings.borderWidth.toStringAsFixed(1))}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.primary.withOpacity(0.3),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.2),
              valueIndicatorColor: colorScheme.primary,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: settings.borderWidth,
              min: 0.5,
              max: 10.0,
              divisions: 19,
              label: l10n.borderWidthValue(
                settings.borderWidth.toStringAsFixed(1),
              ),
              onChanged: (value) {
                SettingsService.instance.updateBorderWidth(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageQualitySection(
    AppSettings settings,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text(
            l10n.imageQuality,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            _getQualityDisplayName(l10n, settings.imageQuality),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...ImageQuality.values.map((quality) {
          final isSelected = settings.imageQuality == quality;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: colorScheme.primary.withOpacity(0.3))
                  : null,
            ),
            child: RadioListTile<ImageQuality>(
              title: Text(
                _getQualityDisplayName(l10n, quality),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                _getQualityDescription(l10n, quality),
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              value: quality,
              groupValue: settings.imageQuality,
              activeColor: colorScheme.primary,
              onChanged: (value) {
                if (value != null) {
                  SettingsService.instance.updateImageQuality(value);
                }
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAppInfoTiles(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text(
            l10n.version,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            '1.0.0',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Icon(
            Icons.info_outline_rounded,
            color: colorScheme.primary,
          ),
        ),
        ListTile(
          title: Text(
            l10n.developer,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            l10n.teamName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Icon(Icons.people_rounded, color: colorScheme.primary),
        ),
        ListTile(
          title: Text(
            l10n.aboutAds,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            l10n.appDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Icon(Icons.ads_click_rounded, color: colorScheme.primary),
        ),
      ],
    );
  }

  void _showColorPicker(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final orientation = MediaQuery.of(context).orientation;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectBorderColor),
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: orientation == Orientation.landscape ? 400 : 320,
          height: orientation == Orientation.landscape ? 300 : 480,
          child: _buildColorPicker(l10n, theme, colorScheme),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final colors = [
      // 基本色
      Colors.white, Colors.black, Colors.grey,
      // 暖色系
      Colors.red, Colors.orange, Colors.yellow, Colors.amber,
      // 寒色系
      Colors.blue, Colors.cyan, Colors.lightBlue, Colors.indigo,
      // 自然色
      Colors.green, Colors.lightGreen, Colors.lime, Colors.teal,
      // その他
      Colors.purple, Colors.pink, Colors.brown, Colors.deepOrange,
      // 明るいバリエーション
      Colors.red[300]!,
      Colors.blue[300]!,
      Colors.green[300]!,
      Colors.purple[300]!,
      // 暗いバリエーション
      Colors.red[700]!,
      Colors.blue[700]!,
      Colors.green[700]!,
      Colors.purple[700]!,
    ];

    final currentColor = SettingsService.instance.currentSettings.borderColor;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        final isSelected = color.value == currentColor.value;

        return GestureDetector(
          onTap: () {
            SettingsService.instance.updateBorderColor(color);
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
                width: isSelected ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    color: _getContrastColor(color),
                    size: 28,
                  )
                : null,
          ),
        );
      },
    );
  }

  Color _getContrastColor(Color color) {
    final brightness = color.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  void _showResetDialog(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(l10n.resetConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await SettingsService.instance.resetSettings();
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.settingsReset),
                    backgroundColor: colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              l10n.reset,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 修正：完全な言語表示名対応
  String _getLanguageDisplayName(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'system':
        return l10n.systemDefault;
      case 'ja':
        return '日本語';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Español';
      case 'it':
        return 'Italiano';
      case 'ko':
        return '한국어';
      case 'pt':
        return 'Português';
      case 'zh':
        return '简体中文';
      case 'zh-Hant':
        return '繁體中文';
      default:
        return languageCode;
    }
  }

  String _getColorName(AppLocalizations l10n, Color color) {
    // 多言語化対応の色名
    if (color == Colors.white) return l10n.white;
    if (color == Colors.black) return l10n.black;
    if (color == Colors.red) return l10n.red;
    if (color == Colors.blue) return l10n.blue;
    if (color == Colors.green) return l10n.green;
    if (color == Colors.yellow) return l10n.yellow;
    if (color == Colors.orange) return l10n.orange;
    if (color == Colors.purple) return l10n.purple;
    if (color == Colors.pink) return l10n.pink;
    if (color == Colors.cyan) return l10n.cyan;
    if (color == Colors.grey) return l10n.gray;
    if (color == const Color(0xFFFF00FF)) return l10n.magenta;
    return l10n.custom;
  }

  String _getQualityDisplayName(AppLocalizations l10n, ImageQuality quality) {
    switch (quality) {
      case ImageQuality.high:
        return l10n.high;
      case ImageQuality.medium:
        return l10n.medium;
      case ImageQuality.low:
        return l10n.low;
    }
  }

  String _getQualityDescription(AppLocalizations l10n, ImageQuality quality) {
    switch (quality) {
      case ImageQuality.high:
        return l10n.highQuality;
      case ImageQuality.medium:
        return l10n.mediumQuality;
      case ImageQuality.low:
        return l10n.lowQuality;
    }
  }
}
