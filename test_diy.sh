
@@ -1,196 +1,23 @@
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


# 下载插件

git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
svn_export "main" "luci-app-amlogic" "package/luci-app-amlogic" "https://github.com/ophub/luci-app-amlogic"


# 编译 po2lmo (如果有po2lmo可跳过)
#pushd package/luci-app-openclash/tools/po2lmo
#make && sudo make install
#popd

# 安装插件
./scripts/feeds update -i
./scripts/feeds install -a



# 微信推送&全能推送
sed -i "s|qidian|bilibili|g" feeds/luci/applications/luci-app-pushbot/root/usr/bin/pushbot/pushbot
# 个性化设置
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Wing build $(TZ=UTC-8 date "+%Y.%m.%d")')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
sed -i "s|breakings|OldCoding|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|OpenWrt|openwrt_packit_arm|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|s9xxx_lede|ARMv8-le|g" package/luci-app-amlogic/root/etc/config/amlogic
