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

rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/v2ray-geodata

git clone --depth 1 https://github.com/sirpdboy/netspeedtest package/netspeedtest
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall-packages
svn_export "main" "luci-app-passwall" "package/luci-app-passwall" "https://github.com/xiaorouji/openwrt-passwall"
svn_export "main" "luci-app-passwall2" "package/luci-app-passwall2" "https://github.com/xiaorouji/openwrt-passwall2"


latest_ver=$(curl -sfL https://api.github.com/repos/XGHeaven/homebox/releases/latest |grep -E 'tag_name'|head -n1|cut -d '"' -f4|sed 's/\./\\\./g')
sed -i "s/\$(PKG_VERSION)/${latest_ver:1}/" package/netspeedtest/homebox/Makefile
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=${latest_ver:14}/" package/netspeedtest/homebox/Makefile

#./scripts/feeds update -i
#./scripts/feeds install -a
