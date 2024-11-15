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

git clone --depth 1 https://github.com/sirpdboy/netspeedtest package/netspeedtest

homever=
latest_ver=$(curl -sfL https://api.github.com/repos/XGHeaven/homebox/releases/latest |grep -E 'tag_name'|head -n1|cut -d '"' -f4|sed 's/\./\\\./g')
echo -e "$latest_ver"
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$latest_ver/" package/netspeedtest/homebox/Makefile

echo "*********"
echo -e "$(cat package/netspeedtest/homebox/Makefile) \n"
echo "*********"

# 汉化
curl -sfL -o ./convert_translation.sh https://github.com/kenzok8/small-package/raw/main/.github/diy/convert_translation.sh
chmod +x ./convert_translation.sh && bash ./convert_translation.sh
