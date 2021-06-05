metricbeatId=$(ps aux | grep /data0/metricbeat | awk '/yml/ {print $2}') 
kill -9 $metricbeatId
