#!/bin/bash

# 定义全局临时缓存根目录
DL_CACHE="/tmp/openwrt_pkg_cache"
[ -d "$DL_CACHE" ] || mkdir -p "$DL_CACHE"

svn_export() {
    # 参数说明: $1=分支, $2=子目录, $3=目标目录, $4=仓库地址
    local BRANCH=$1
    local SUB_DIR=$2
    local TARGET_DIR=$3
    local REPO_URL=$4

    # 提取作者名和仓库名 (例如从 https://github.com/immortalwrt/luci 提取 immortalwrt-luci)
    local REPO_IDENTIFIER=$(echo "$REPO_URL" | sed 's|https://github.com/||' | tr '/' '-')
    # 组合成：作者-仓库-分支
    local CACHE_NAME="${REPO_IDENTIFIER}-${BRANCH}"
    local LOCAL_REPO_DIR="$DL_CACHE/$CACHE_NAME"

    # 检查缓存是否存在，不存在则克隆
    if [ ! -d "$LOCAL_REPO_DIR" ]; then
        echo -e "Initial cloning $REPO_URL ($BRANCH) to cache..."
        git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$LOCAL_REPO_DIR" >/dev/null 2>&1
    else
        echo -e "Using cached repo for $REPO_URL ($BRANCH)"
    fi

    # 确保目标目录存在
    [ -d "$TARGET_DIR" ] || mkdir -p "$TARGET_DIR"
    
    # 执行拷贝：只从缓存中提取需要的子目录
    if [ -d "$LOCAL_REPO_DIR/$SUB_DIR" ]; then
        echo -e "Exporting $SUB_DIR to $TARGET_DIR"
        cp -af "$LOCAL_REPO_DIR/$SUB_DIR/." "$TARGET_DIR/"
        # 清除可能带入的 .git 信息（如果有）
        rm -rf "$TARGET_DIR/.git"
    else
        echo -e "Error: Subdirectory $SUB_DIR not found in $REPO_URL"
        return 1
    fi
}

git clone --depth 1 https://github.com/OldCoding/OpenWrt-qBittorrent-Enhanced-Edition package/qbee
mv package/qbee package && rm -rf package/qbee
curl -o feeds/packages/net/aria2/patches/010-increase-max-connections-and-reduce-split-size.patch https://github.com/OldCoding/aria2-patch/raw/refs/heads/main/010-increase-max-connections-and-reduce-split-size.patch

sed -i "s/192.168.1.1/192.168.2.1/g" package/base-files/files/bin/config_generate
# 安装插件
./scripts/feeds update -i
./scripts/feeds install -a