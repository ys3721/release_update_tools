#!/usr/bin bash
<<!
 **********************************************************
 * Author        : Yao Shuai
 * *******************************************************
!

declare -A param_map

function init_param() {
    param_map["timestamp"]=$(date '+%s')
    param_map["gameid"]=5632
    param_map["serverid"]=0
    param_map["logintype"]=1
    param_map["device"]="devicexxxx"
    param_map["devicetype"]="devicetypexxxx"
    param_map["deviceversion"]="deviceversionxxxx"
    param_map["deviceudid"]="deviceidxxxx"
    param_map["devicemac"]="devicemacxxxx"
    param_map["deviceidfa"]="deviceidfaxxxx"
    param_map["appversion"]="appversionxxxxxx"
    param_map["appsflyerid"]="appsflyeridxxxxxx"
    param_map["sdktitle"]="sdktitlexxxxx"
    param_map["sdkversion"]="sdkversionxxxx"
    param_map["username"]=ys3721@hotmail.com
    param_map["password"]=fei474747
    param_map["ip"]="127.0.0.1"
    param_map["sign"]="idonotcare"
}

result_str=""
function build_req_param() {
    echo $param_map

    for pk in ${!param_map[*]}
    do
      if [ -z "$result_str" ]; then
        result_str=${pk}"="${param_map[$pk]}
      else
        result_str=${result_str}\&${pk}"="${param_map[$pk]}
      fi
    done
    echo "param=> "$result_str
}

sign_str=""
#md5(timestamp+username+ip+gameid+serverid+password+logintype+key)
function buildMd5Sign() {
    target_str=${param_map[timestamp]}${param_map[username]}${param_map[ip]}${param_map[gameid]}${param_map[serverid]}${param_map[password]}${param_map[logintype]}${key}
    echo "need sign srt = "$target_str
    sign=$(echo -n $target_str | md5sum | awk '{print $1}')
    param_map["sign"]=$sign
}

function asyncSend() {
    for ((i=1;i<=$1;i++)); do
      echo "REQUEST=> http://api.feidou.com/local.logincheck.php?${result_str}"
      curl --header "Connection: keep-alive" -d '' "http://api.feidou.com/local.logincheck.php?${result_str}" &
    done
}

key=""
case "$1" in
    go)
      key=$2
      init_param
      buildMd5Sign
      build_req_param
      asyncSend $3
      ;;
    *)
      echo $"Usage: {go [secretKey] [count]}"
      ;;
esac
