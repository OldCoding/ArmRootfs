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

# 删除冲突软件和依赖
curl -sfL https://github.com/immortalwrt/luci/raw/master/modules/luci-base/root/usr/share/luci/menu.d/luci-base.json > feeds/luci/modules/luci-base/root/usr/share/luci/menu.d/luci-base.json


# 下载插件

git clone --depth 1 https://github.com/sirpdboy/netspeedtest package/netspeedtest

# 编译 po2lmo (如果有po2lmo可跳过)
#pushd package/luci-app-openclash/tools/po2lmo
#make && sudo make install
#popd

# 安装插件
./scripts/feeds update -i
./scripts/feeds install -a

latest_ver=$(wget-ssl --no-check-certificate -t 2 -T 20 -O - https://api.github.com/repos/XGHeaven/homebox/releases/latest 2>/dev/null|grep -E 'tag_name'|head -n1|cut -d '"' -f4|sed 's/\./\\\./g' 2>/dev/null)
echo $latest_ver
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$latest_ver/" package/netspeedtest/homebox/Makefile

echo "*********"
echo -e "$(cat package/netspeedtest/homebox/Makefile | grep PKG_VERSION) \n"
echo "*********"

# 汉化
curl -sfL -o ./convert_translation.sh https://github.com/kenzok8/small-package/raw/main/.github/diy/convert_translation.sh
chmod +x ./convert_translation.sh && bash ./convert_translation.sh
