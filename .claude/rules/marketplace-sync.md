# Marketplace Sync Rule

`plugins/` 配下にプラグインを追加・削除したときは、必ず `.claude-plugin/marketplace.json` の `plugins` 配列も同期すること。

- プラグイン追加時: `marketplace.json` にエントリを追加する（name, description, source, version, author, keywords）
- プラグイン削除時: `marketplace.json` から該当エントリを削除する
- プラグインのメタデータ変更時: `marketplace.json` の該当フィールドも更新する
