#!/bin/sh

#  run.sh
#  SimpResearch
#  自动编译ipa
#  Created by quentin on 16/5/30.
#  Copyright © 2016年 上海美市科技有限公司. All rights reserved.

#使用此脚本需要安装两个工具
#brew install ImageMagick
#brew install ghostscript

#  2016/06/15 不支持打APPStore的包
#  2016/06/16 添加DEV的icon图标转换
#  2016/06/22 支持打APPStore包并自动上传
#  2016/06/23 appstore用户名和密码外部传入以及图标的恢复并把info文件更改上传到svn
#  2017/04/12 Xcode8.3环境下的打包

#  运行命令如下sh run.sh (appleUserName) (applePassword)打包appstore版本需要输入apple用户和密码，如果不输入在后续打包的时候会提醒


echo
#编译条件
DEV=1
UAT=2
APPSTORE=3

userName=$1
password=$2

#工程路径
project_path=$(pwd)
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')

if [ "${project_name}" == "" ]
then
   echo -e "\033[31m 当前目录不是项目根目录，不能进行编译打包，请将 .sh 文件放在根目录运行 \033[0m"
exit
fi

if [ "${userName}" == "" -a "${password}" == "" ]
then
echo "\033[31m如果打包为 AppStore 可以使用命令: sh run.sh username password \033[0m"
fi

#打包工程
build_workspace=${project_name}".xcworkspace"

echo "\033[35m##################  更新 svn 代码  ###################  \033[0m"

svn_diff=$(svn di)     #比较 SVN 是否有更新

if [ "${svn_diff}" != "" ]
then
echo -e "\033[35m 本地代码有更改，是否恢复代码后再打包? 改变如下：  \033[0m"
echo -e "\033[33m ${svn_diff}   \033[0m"

select revert in "Y" "N"
do
case ${revert} in
"Y")
echo "恢复本地修改的代码"
svn revert -R .
break
;;
*)
echo "不恢复本地修改的代码"
break
;;
esac
done

fi
#svn up
echo "\033[33m 更新代码 \033[0m"
svn up
echo "\033[32m 更新完毕 \033[0m"


echo " "
echo "\033[35m###################  设置打包信息  ###################  \033[0m"

#此版本更新内容
echo "\033[33m  ---------------  此版本更新的内容  ----------------  \033[0m"

for line in $(cat ${project_path}/UpdateContent)
    do
    echo ${line}
    content=${content}" "${line}
done

echo "\033[33m  ---------------------------------------------------  \033[0m"
echo
sleep 1

#选择打包类型
echo "\033[36m 请选择打包类型: \033[0m"
select type in "DEV" "UAT" "APPSTORE" "Exit"
do
case ${type} in
"DEV")
echo "\033[33m 您选择了DEV环境 \033[0m"
display_name="${project_name}_DEV"
GCC_PREPROCESSOR_DEFINITIONS=""
type=${DEV}
break
;;
"UAT")
echo "\033[33m 您选择了UAT环境 \033[0m"
display_name="AppName_UAT"
GCC_PREPROCESSOR_DEFINITIONS="GCC_PREPROCESSOR_DEFINITIONS"='"UAT=1"'
type=${UAT}
break
;;
"APPSTORE")
echo "\033[33m 您选择了APPSTORE环境 \033[0m"
GCC_PREPROCESSOR_DEFINITIONS="GCC_PREPROCESSOR_DEFINITIONS"='"APPSTORE=1"'
display_name="AppName"
type=${APPSTORE}
break
;;
"Exit")
echo "\033[32m 退出打包\033[0m"
exit
;;
*)
echo "\033[31m 输入错误，请重新输入打包类型: \033[0m"
;;
esac
done;

#判断apple用户名和密码
function appstore_username_password() {
if [ $1 == ${APPSTORE} ]
    then
    if [ "${userName}" == "" -o "${password}" == "" ]
    then
        echo "\033[36m 请输入AppleID: \033[0m"
        read userName
        echo "\033[36m 请输入密码:  \033[0m"
        read password
        appstore_username_password $1
    else
        echo "\033[35m AppleID:  \033[33m ${userName}  \033[35m 密码: \033[33m ${password}   \033[0m"
        echo "\033[36m 是否确认？(Y(确认)/N(重新输入)/Exit(退出打包))\033[0m"
        select validate in "Y" "N" "Exit"
        do
        case ${validate} in
        "Y")
        break
        ;;
        "N")
        userName=""
        password=""
        appstore_username_password $1
        break
        ;;
        "Exit")
        exit
        ;;
        esac
        done
    fi
fi
}

appstore_username_password ${type}

#app info.plist
app_infoplist_path=${project_path}/${project_name}/Info.plist
if [ ${type} == ${DEV} ]
then
app_infoplist_path=${project_path}/${project_name}_DEV/Info.plist
fi

echo
#版本号
pre_version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${app_infoplist_path}")
echo "\033[36m 上个版本号为: ${pre_version} \033[0m"
function version() {
    echo "\033[36m 请输入版本号(E.g:1.5.0): \033[0m"
    read VERSION
    if [ "${VERSION}" == "" ]
    then
       echo "\033[31m 输入版本为空，重新输入  \033[0m"
       version
    else
        echo "\033[33m 版本号为: "${VERSION}"  \033[0m"
    fi
}

version
echo

#pod是否更新

echo "\033[36m 是否更新pod，更新将花费一些时间(最好每次打包都更新pod文件)？\033[0m "

select update in "Y" "N"
do
case ${update} in
"Y")
echo "\033[33m pod文件更新... \033[0m"
pod update
pod install
echo "\033[33m pod文件更新完毕 \033[0m"
break
;;
*)
echo "\033[33m 不更新pod文件 \033[0m"
break
;;
esac
break
done;

echo


echo "\033[33m  ---------------  打包基本信息 -----------------  \033[0m"
#时间戳
timeStamp="$(date +"%Y%m%d%H%M%S")"
echo "\033[35m 当前时间:"$(date)" \033[0m"

#设置display name
# display_name=$(/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" "${app_infoplist_path}")

/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${display_name}" "${app_infoplist_path}"
echo "\033[35m APP显示名: "${display_name}" \033[0m"

#设置bundle short version
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "${app_infoplist_path}"
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${app_infoplist_path}")
echo "\033[35m 版本号: "${bundleShortVersion}" \033[0m"

#设置bundle version
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${timeStamp}" "${app_infoplist_path}"
bundleVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${app_infoplist_path}")
echo "\033[35m 编译版本: "${bundleVersion}" \033[0m"


#打包配置(Release|Debug)
build_configuration=Release
build_scheme=${project_name}

if [ ${type} == ${DEV} ]
then
    build_scheme=${project_name}_DEV
#    provisioningProfile="DEV"
    echo "\033[35m 编译环境: DEV \033[0m"
elif [ ${type} == ${UAT} ]
then
#    provisioningProfile="DEV"
    echo "\033[35m 编译环境: UAT \033[0m"
elif [ ${type} == ${APPSTORE} ]
then
#    provisioningProfile="AppStoreDistribution"
    echo "\033[35m 编译环境: APPSTORE \033[0m"
fi

echo "\033[33m  -----------------------------------------------  \033[0m"

echo "\033[36m 以上为本次打包的app基本信息，是否确认？(Y(确认打包)/N(取消退出打包)) \033[0m"
select yes in "Y" "N"
do
case ${yes} in
"Y")
echo "\033[33m 确认打包 \033[0m"
break
;;
"N")
echo "\033[31m 取消退出打包 \033[0m"
svn revert -R ${app_infoplist_path}
exit
;;
esac
done

echo
#打包开始
echo "\033[35m################ 开始打包，耐心等待... ###################\033[0m"

function image_revert() {
    image_name=$1

    target_path=$(find ${project_path}/${project_name} -name ${image_name})

    svn revert -R ${target_path}
}

#图片恢复
image_revert "AppIcon.appiconset"

#图片转换
if [ ${type} == ${DEV} ]
then

    temp_convert_image_dir=${project_path}/temp_convert_image_dir
    rm -rf ${temp_convert_image_dir}
    mkdir ${temp_convert_image_dir}

    function image_convert() {
        image_name=$1

#target_path=$(find ${project_path}/${project_name} -name ${image_name})
        target_path=${project_path}/${project_name}/Images.xcassets/AppIcon.appiconset/${image_name}
        
        cp ${target_path} ${temp_convert_image_dir}

        convert_path=${temp_convert_image_dir}/${image_name}
        convert ${convert_path} -fill white -font Times-Bold -pointsize 40 -gravity south -annotate 0 "${bundleShortVersion}" ${convert_path}


        cp ${convert_path} ${target_path}
    }

    #转换图片
    image_convert "AppIcon29x29@2x.png"
    image_convert "AppIcon29x29@3x.png"
    image_convert "AppIcon40x40@2x.png"
    image_convert "AppIcon40x40@3x.png"
    image_convert "AppIcon60x60@2x.png"
    image_convert "AppIcon60x60@3x.png"

    rm -rf ${temp_convert_image_dir}
fi

startDate=$(date +%Y%m%d%H%M%S)

#build clean
echo "\033[37m build clean... \033[0m"
build_clean="xcodebuild clean -workspace ${build_workspace} -scheme ${build_scheme} -configuration ${build_configuration}"
echo ${build_clean}
${build_clean} > /dev/null
echo "\033[37m build clean finished \033[0m"

#build archive
echo "\033[37m build archive... \033[0m"
archive_name=${build_scheme}_${bundleShortVersion}_${bundleVersion}.xcarchive
archive_path=${project_path}/Archive/${archive_name}

build_workspace="xcodebuild -workspace ${build_workspace} -scheme ${build_scheme} -configuration ${build_configuration} -destination generic/platform=iOS archive ONLY_ACTIVE_ARCH=NO -archivePath ${archive_path} ${GCC_PREPROCESSOR_DEFINITIONS}"
echo ${build_workspace}
${build_workspace} > /dev/null

echo
echo "\033[35m### ${archive_name}生成完成，请保留此文件，以后查找BUG使用!!!!################### \033[0m"
echo

#图片转换
if [ ${type} == ${DEV} ]
then

    image_revert "AppIcon.appiconset"

fi

echo
echo "\033[35m################ 开始导出ipa文件... ###################\033[0m"

#export ipa

if [ ${type} == ${DEV} ]
then
    ipa_path=${project_path}/DEV
    type_name="DEV"

elif [ ${type} == ${UAT} ]
then
    ipa_path=${project_path}/UAT
    type_name="UAT"
elif [ ${type} == ${APPSTORE} ]
then
    ipa_path=${project_path}/APPSTORE
    type_name="APPSTORE"
fi
rm -rf ${ipa_path}
mkdir ${ipa_path}

ipa_path=${ipa_path}
ipa_name=${build_scheme}.ipa

echo "\033[33m ipa_name:"${ipa_name}" \033[0m"
echo

exportOptionsPlist=${project_path}/SimpResearch-ExportOptions.plist

#build_ipa="xcodebuild -exportArchive -exportFormat ipa -archivePath ${archive_path} -exportPath ${ipa_path} -exportProvisioningProfile ${provisioningProfile} "
build_ipa="xcodebuild -exportArchive -archivePath ${archive_path} -exportPath ${ipa_path} -exportOptionsPlist ${exportOptionsPlist} "
echo ${build_ipa}

#log path
log_path=${project_path}/Log
rm -rf ${log_path}
mkdir ${log_path}

build_ipa_log=${log_path}/build_ipa.log
rm -rf ${project_path}/Log
mkdir ${project_path}/Log

${build_ipa} > ${build_ipa_log}


if [ ! -f "${ipa_path}/${ipa_name}" ]
then
    echo "\033[31m################ 打包失败 查看错误结果:${ipa_log} ###################\033[0m"
exit
else
    rm -rf ${log_path}
    echo "\033[32m 导出ipa文件完成 所在地址:${ipa_path} \033[0m"
    echo "\033[32m### 导出ipa文件完成 所在地址:${ipa_path} \033[0m"
fi

echo
echo
echo
endDate=$(date +%Y%m%d%H%M%S)
let date=${endDate}-${startDate}
echo "\033[33m################ 打包共用时:"${date}"秒 ################ \033[0m"


#svn commit
echo "是否提交打包版本信息(正常打包应该都选择Y)？(Y(提交)/N(跳过不提交))"
select commit in "Y" "N"
do
case ${commit} in
"Y")
echo "提交本地版本修改..."
svn ci ${app_infoplist_path} -m "自动打包上传version:${bundleShortVersion} buildversion:${bundleVersion} 类型:${type_name} 内容:${content}"
echo "提交完毕"
break
;;
*)
echo "未提交本地修改"
break
;;
esac
done

#上传APPSTORE平台
#成功后返回的内容包括<key>success-message</key>，失败其他消息

altool_path=/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool

function validateApp () {
    echo "验证ipa正确性..."
    validate=$("${altool_path}" --validate-app -f ${ipa_path}/${ipa_name} -u ${userName} -p ${password} --output-format xml > out)
    echo "validateApp:${validate}"
    ${validate}

    message=$(cat out | grep "<key>success-message</key>")
    if [ "${message}" == "" ]
    then
        echo "验证失败，具体失败内容如下:$(cat out)"
        rm out
        echo "重新验证、不管错误跳过验证还是退出?(Y(重新验证)/J(跳过验证)/Exit(退出))"

        select validate in "Y" "J" "Exit"
        do
        case ${validate} in
        "Y")
        echo "重新验证"
        validateApp
        break
        ;;
        "J")
        echo "跳过验证"
        break
        ;;
        "Exit")
        echo "退出"
        exit
        ;;
        esac
        done
    else
       rm out
       echo "验证完毕"
    fi

}

function uploadApp () {
    upload=$("${altool_path}" --upload-app -f ${ipa_path}/${ipa_name} -u ${userName} -p ${password} --output-format xml > out)
    echo "uploadApp:${upload}"
    ${upload}

    message=$(cat out | grep "<key>success-message</key>")

    if [ "${message}" == "" ]
    then
        echo "上传失败，具体失败内容如下:$(cat out)"
        rm out
        echo "重新上传或者退出?(Y(重新验证)/Exit(退出))"

        select validate in "Y" "Exit"
        do
        case ${validate} in
        "Y")
        echo "开始重新上传"
        validateApp
        break
        ;;
        "Exit")
        echo "上传完毕"
        exit
        ;;
        esac
        done
    else
        rm out
        echo "上传成功"
    fi
}

echo
echo

if [ ${type} == ${APPSTORE} ]
then
echo "################发布到APPSTORE###################"
if [ ! -d "/usr/local/itms" ]
then
echo "创建超链接"
ln -s /Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/itms /usr/local/itms
echo "超链接创建成功"
fi

#验证ipa
validateApp

#上传ipa文件
echo "上传appStore..."
uploadApp
exit
fi

#上传蒲公英平台
echo
echo
echo "################发布到蒲公英分发平台###################"
#蒲公英设置
echo "################蒲公英key设置###################"
uKey="72fe6f200ec2e265a4c3e7e7617d85ee"
api_key="8405779020dbaac517e316b3898e8ba5"
echo "\033[37m uKey:"${uKey}" \033[0m"
echo "\033[37m api_key:"${api_key}" \033[0m"
echo "\033[37m updateDescription:"${content}" \033[0m"
echo
echo "是否上传到蒲公英分发平台上?"
select confirm in "Y" "N"
do
case ${confirm} in
"Y")
echo "\033[37m 正在上传... \033[0m"
#curl_upload="curl -F 'file=@${ipa_path}' -F 'updateDescription=${content}' -F 'uKey=${uKey}' -F '_api_key=${api_key}' http://www.pgyer.com/apiv1/app/upload"
#echo ${curl_upload}
#${curl_upload} > curl.json
curl -F "file=@${ipa_path}/${ipa_name}" -F "updateDescription=${content}" -F "uKey=${uKey}" -F "_api_key=${api_key}" http://www.pgyer.com/apiv1/app/upload
echo
echo "\033[37m 上传完成,请至蒲公英平台查看 \033[0m"
echo "请将下面信息发布到qq群中，提醒大家进行更新安装,首先自己测试下下载地址是否可用"

#app_url=$(cat curl.json | grep '"appShortcutUrl":"*"' | awk -F ':"' '{print $2}' | awk -F '"' '{print $1}')
if [ ${type} == ${DEV} ]
then
app_url="8fIr"
elif [ ${type} == ${UAT} ]
then
app_url="8fIr"
fi

echo "IOS ${type_name}版本:${VERSION} buildversion:${bundleVersion} 下载地址：http://www.pgyer.com/${app_url} 更新内容见网页"
exit
;;
*)
echo "################运行完毕###################"
exit
;;
esac
done



