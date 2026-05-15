import 'plugin_card.dart';

/// 插件注册表
/// v0.2+ 用于管理已安装的插件卡片
class PluginRegistry {
  final List<IPluginCard> _plugins = [];

  void register(IPluginCard plugin) {
    _plugins.add(plugin);
  }

  void unregister(String pluginId) {
    _plugins.removeWhere((p) => p.pluginId == pluginId);
  }

  List<IPluginCard> get all => List.unmodifiable(_plugins);

  IPluginCard? findById(String pluginId) {
    try {
      return _plugins.firstWhere((p) => p.pluginId == pluginId);
    } catch (_) {
      return null;
    }
  }
}
