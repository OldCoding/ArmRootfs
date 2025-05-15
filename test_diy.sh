#!/bin/bash
svn_export() {
	# 参数1是分支名, 参数2是子目录, 参数3是目标目录, 参数4仓库地址
 	echo -e "clone $4/$2 to $3"
	TMP_DIR="$(mktemp -d)" || exit 1
 	ORI_DIR="$PWD"
	[ -d "$3" ] || mkdir -p "$3"
	TGT_DIR="$(cd "$3"; pwd)"
	git clone --depth 1 -b "$1" "$4" "$TMP_DIR" >/dev/null 2>&1 && \
	cd "$TMP_DIR/$2" && rm -rf .git >/dev/null 2>&1 && \
	cp -af . "$TGT_DIR/" && cd "$ORI_DIR"
	rm -rf "$TMP_DIR"
}

sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Wing build $(TZ=UTC-8 date "+%Y.%m.%d")')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
sed -i "s|openwrt_luci|openwrt_core|g" package/lean/default-settings/files/zzz-default-settings
sed -i "s|snapshots|armvirt\\\/64|g"  package/lean/default-settings/files/zzz-default-settings
sed -i "s|releases\\\/18.06.9|armsr\\\/armv8|g"  package/lean/default-settings/files/zzz-default-settings
sed -i "/openwrt_release/d" package/lean/default-settings/files/zzz-default-settings
sed -i "s|99-default-settings|99-default-settings-chinese|g" package/lean/default-settings/Makefile
cp ./feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js ./