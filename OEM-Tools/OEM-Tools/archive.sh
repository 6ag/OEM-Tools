#!/bin/bash

#################################################
#####       配置（config）     ################
#################################################

# 生成ipa文件的名称
IPA_NAME="difu2.0.6"

# 生成ipa的目录
APP_DIR="/Users/paychina-ios02/Desktop/"

# 项目的目录
PROJECT_DIR="/Users/paychina-ios02/PayChinaPospIOS/PayChinaPospIOS/"

# keychain登陆密码
LOGIN_PASSWORD="ws168"

# 描述文件的名字
PROFILE_NAME="aiarm_distribution"

# 电脑用户名
USER_NAME="paychina-ios02"

# 电脑密码
PASS_WORD="ws168"

# 发布渠道
CHANNEL=U_CHANNEL_DONGBENBEN_CONFIG

# bundle id
PRODUCT_BUNDLE_IDENTIFIER="com.aiarm.www"

# workplace的名字
PROJECT_NAME="PayChinaPospIOS"

# scheme的名字
SCHEME_NAME="PayChinaPospIOS"

# 分发或者发布
CONFIGURATION="Release"

# ipa的名字
if [ `echo ${ISTEST} |wc -c` -ge "2" ] ;then ISTEST_STR="_test"; else ISTEST_STR=""; fi;
IPA_PREFIX_NAME=${PROFILE_NAME}${ISTEST_STR}

# 老id
OLD_PRODUCT_BUNDLE_IDENTIFIER1="com.aiarm.www"
OLD_PRODUCT_BUNDLE_IDENTIFIER2="com.aiarm.jumi"
OLD_PRODUCT_BUNDLE_IDENTIFIER3="com.aiarm.kakale"
OLD_PRODUCT_BUNDLE_IDENTIFIER4="com.aiarm.chengqiaobao"
OLD_PRODUCT_BUNDLE_IDENTIFIER5="com.aiarm.syt"
OLD_PRODUCT_BUNDLE_IDENTIFIER6="com.aiarm.yunfutong"
OLD_PRODUCT_BUNDLE_IDENTIFIER7="com.aiarm.shishua"
OLD_PRODUCT_BUNDLE_IDENTIFIER8="com.aiarm.aofu"
OLD_PRODUCT_BUNDLE_IDENTIFIER9="com.aiarm.yinyuan"

#################################################
#####       执行代码（execute）     ################
#################################################

function failed() {
echo "Failed: $@" >&2
exit 1
}
LOGIN_KEYCHAIN=~/Library/Keychains/login.keychain

# timestamp=`date "+%Y%m%d%H%M%S"`
script_dir_relative=`dirname $0`
script_dir=`cd ${script_dir_relative}; pwd`
echo "script_dir = ${script_dir}"

# 解锁钥匙串
security unlock-keychain -p ${LOGIN_PASSWORD} ${LOGIN_KEYCHAIN} || failed "unlock-keygen"

# 获取描述文件
cd ~/Library/MobileDevice/Provisioning\ Profiles
find .|xargs grep -ri ${PROFILE_NAME} || failed "mobileprovision not found!!"
MOBILE_PROVISION_FILE_NAME=`find .|xargs grep -ri "${PROFILE_NAME}"|head -1|sed 's/Binary\ file\ .\/\(.*\)\.mobileprovision\ matches/\1/g'`

# 创建ipa包存放目录
mkdir -pv ${APP_DIR} || failed "mkdir ${APP_DIR}"

# 切换到ipa包存放目录
cd ${PROJECT_DIR} || failed "cd ${PROJECT_DIR}"

# 清空bin目录并重新创建
rm -rf bin/*
mkdir -pv bin

# 清理xcodebuild
sudo -u${USER_NAME} -p${PASS_WORD} xcodebuild clean -workspace ${PROJECT_NAME}.xcworkspace \
-scheme ${SCHEME_NAME} \
|| failed "xcodebuild clean"

# 修改build setting 里的product bundle identifier
sed -i "" "s/${OLD_PRODUCT_BUNDLE_IDENTIFIER1}/${PRODUCT_BUNDLE_IDENTIFIER}/g" ${PROJECT_NAME}.xcodeproj/project.pbxproj
sed -i "" "s/${OLD_PRODUCT_BUNDLE_IDENTIFIER2}/${PRODUCT_BUNDLE_IDENTIFIER}/g" ${PROJECT_NAME}.xcodeproj/project.pbxproj
sed -i "" "s/${OLD_PRODUCT_BUNDLE_IDENTIFIER3}/${PRODUCT_BUNDLE_IDENTIFIER}/g" ${PROJECT_NAME}.xcodeproj/project.pbxproj
sed -i "" "s/${OLD_PRODUCT_BUNDLE_IDENTIFIER4}/${PRODUCT_BUNDLE_IDENTIFIER}/g" ${PROJECT_NAME}.xcodeproj/project.pbxproj
sed -i "" "s/${OLD_PRODUCT_BUNDLE_IDENTIFIER5}/${PRODUCT_BUNDLE_IDENTIFIER}/g" ${PROJECT_NAME}.xcodeproj/project.pbxproj
sed -i "" "s/${OLD_PRODUCT_BUNDLE_IDENTIFIER6}/${PRODUCT_BUNDLE_IDENTIFIER}/g" ${PROJECT_NAME}.xcodeproj/project.pbxproj
sed -i "" "s/${OLD_PRODUCT_BUNDLE_IDENTIFIER7}/${PRODUCT_BUNDLE_IDENTIFIER}/g" ${PROJECT_NAME}.xcodeproj/project.pbxproj
sed -i "" "s/${OLD_PRODUCT_BUNDLE_IDENTIFIER8}/${PRODUCT_BUNDLE_IDENTIFIER}/g" ${PROJECT_NAME}.xcodeproj/project.pbxproj
sed -i "" "s/${OLD_PRODUCT_BUNDLE_IDENTIFIER9}/${PRODUCT_BUNDLE_IDENTIFIER}/g" ${PROJECT_NAME}.xcodeproj/project.pbxproj

# 归档
sudo -u${USER_NAME} -p${PASS_WORD} xcodebuild archive -workspace ${PROJECT_NAME}.xcworkspace \
-scheme ${SCHEME_NAME} \
-destination generic/platform=iOS \
-archivePath bin/${PROJECT_NAME}.xcarchive \
GCC_PREPROCESSOR_DEFINITIONS="COCOAPODS=1 `if [ ${ISTEST} ];then echo "ISTEST_CONFIG=1";else  echo "ISTEST_CONFIG=2"; fi;` `echo ${CHANNEL}`=YES" \
PRODUCT_BUNDLE_IDENTIFIER=`echo ${PRODUCT_BUNDLE_IDENTIFIER};` \
PROVISIONING_PROFILE=${MOBILE_PROVISION_FILE_NAME} \
|| failed "xcodebuild archive"

# 导出ipa包
sudo -u${USER_NAME} -p${PASS_WORD} xcodebuild -exportArchive -archivePath bin/${PROJECT_NAME}.xcarchive \
-exportPath bin/${PROJECT_NAME} \
-exportFormat ipa \
-exportProvisioningProfile ${PROFILE_NAME} \
-verbose \
|| failed "xcodebuild export archive"

# 移动ipa包到指定目录
echo "mv ipa files ..."
mv bin/${PROJECT_NAME}.ipa ${APP_DIR}/${IPA_NAME}.ipa || failed "mv ipa"

# 清理bin目录
echo "clean bin files ..."
rm -rf bin/*
rm -fr bin

echo "Done."
