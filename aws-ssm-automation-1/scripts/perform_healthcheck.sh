avg_cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print int(usage)+1}')
if ((avg_cpu > 90)); then
    echo "Instance is unhealthy - Linux"
    exit 1
fi
echo "Instance is healthy - Linux"
