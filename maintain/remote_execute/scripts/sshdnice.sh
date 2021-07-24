tomcatId=$(lsof -i :22 | grep "*" | awk '{print $2}')
echo $tomcatId
renice -n -5 $tomcatId
ifconfig
