#!/bin/bash

echo "Start Radxa E25 RGB"
color=(ffffff ff00ff 00ffff ffff00)

rgbinit()
{
echo "RGB init"
path="/sys/class/pwm/pwmchip0/pwm0"
if [ ! -d "$path" ]; then
    for i in 0 1 2
    do
    echo 0 > /sys/class/pwm/pwmchip${i}/export
    echo 255000 > /sys/class/pwm/pwmchip${i}/pwm0/period
    echo normal  > /sys/class/pwm/pwmchip${i}/pwm0/polarity
    echo 0 > /sys/class/pwm/pwmchip${i}/pwm0/duty_cycle
    echo 1 > /sys/class/pwm/pwmchip${i}/pwm0/enable
    done
fi
}

colorful(){

while true ;
do

    local s=0.1
    #Start with blue. This gives a better transition from the original green.
    #Switching from green to red is usually indication there is a problem.
    local r=0
    local g=0
    local b=255000
    for ((i=0;i<255;i++))
        do
        let r=$r+1000
        let b=$b-1000
        echo $r  > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
        echo $g  > /sys/class/pwm/pwmchip1/pwm0/duty_cycle
        echo $b  > /sys/class/pwm/pwmchip2/pwm0/duty_cycle
        sleep $s
        done
    r=255000
    g=0
    b=0
    for ((i=0;i<255;i++))
        do
        let r=$r-1000
        let g=$g+1000
        echo $r  > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
        echo $g  > /sys/class/pwm/pwmchip1/pwm0/duty_cycle
        echo $b  > /sys/class/pwm/pwmchip2/pwm0/duty_cycle
        sleep $s
        done
    r=0
    g=255000
    b=0
    for ((i=0;i<255;i++))
        do
        let g=$g-1000
        let b=$b+1000
        echo $r  > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
        echo $g  > /sys/class/pwm/pwmchip1/pwm0/duty_cycle
        echo $b  > /sys/class/pwm/pwmchip2/pwm0/duty_cycle
        sleep $s
        done
done

}

blink()
{
while true ;
do

    for ((i=0;i<${#color[*]};i++))
        do
        r=`echo ${color[$i]:0:2}`
        g=`echo ${color[$i]:2:2}`
        b=`echo ${color[$i]:4:2}`
        r=`echo $((16#$r))`
        g=`echo $((16#$g))`
        b=`echo $((16#$b))`
        echo `expr ${r} \* 1000`  > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
        echo `expr ${g} \* 1000` > /sys/class/pwm/pwmchip1/pwm0/duty_cycle
        echo `expr ${b} \* 1000` > /sys/class/pwm/pwmchip2/pwm0/duty_cycle
        sleep 1
  done
done
}

tricolor()
{
while true ;
do
    echo 255000 >  /sys/class/pwm/pwmchip0/pwm0/duty_cycle
    echo 0 >  /sys/class/pwm/pwmchip1/pwm0/duty_cycle
    echo 0 >  /sys/class/pwm/pwmchip2/pwm0/duty_cycle
    sleep 0.5
    echo 235000 >  /sys/class/pwm/pwmchip0/pwm0/duty_cycle
    echo 20000 >  /sys/class/pwm/pwmchip1/pwm0/duty_cycle
    echo 0 >  /sys/class/pwm/pwmchip2/pwm0/duty_cycle
    sleep 0.5
    echo 0 >  /sys/class/pwm/pwmchip0/pwm0/duty_cycle
    echo 255000 >  /sys/class/pwm/pwmchip1/pwm0/duty_cycle
    echo 0 >  /sys/class/pwm/pwmchip2/pwm0/duty_cycle
    sleep 0.5    
    echo 235000 >  /sys/class/pwm/pwmchip0/pwm0/duty_cycle
    echo 20000 >  /sys/class/pwm/pwmchip1/pwm0/duty_cycle
    echo 0 >  /sys/class/pwm/pwmchip2/pwm0/duty_cycle
    sleep 0.5
done
}


rgb_breathe(){
while true ;
do
for ((x=0;x<3;x++))
do
    for ((i=1000;i<255000;i+=1000))
    do
    echo ${i} > /sys/class/pwm/pwmchip${x}/pwm0/duty_cycle
    sleep 0.0002
    done
    sleep 0.5
    for ((i=255000;i>1000;i-=1000))
    do
    echo ${i} > /sys/class/pwm/pwmchip${x}/pwm0/duty_cycle
    sleep 0.0001
    done
done
done
}

none(){
    for i in 0 1 2
    do
    echo 0 > /sys/class/pwm/pwmchip${i}/pwm0/duty_cycle
    done
}

disable(){
    for i in 0 1 2
    do
    echo 0 > /sys/class/pwm/pwmchip${i}/pwm0/enable
    echo 0 > /sys/class/pwm/pwmchip${i}/unexport
    done
}


case "$1" in
start)
killall -o 3s radxa-e25-led.sh >/dev/null 2>&1
rgbinit
rgb_mode=colorful
if [ -n "$2" ]; then
  rgb_mode="$2"
fi
if [ $rgb_mode = "colorful" ];then
    echo "RGB Start colorful"
    colorful &
elif [ $rgb_mode = "blink" ];then
    echo "RGB Start blink"
    blink &
elif [ $rgb_mode = "rgb_breathe" ];then
    echo "RGB Start rgb_breathe"
    rgb_breathe &
elif [ $rgb_mode = "tricolor" ];then
    echo "RGB Start tricolor"
    tricolor &
elif [ $rgb_mode = "none" ];then
    echo "RGB none"
    none
fi
    ;;
suspend)
    echo "RGB suspend"
    killall -o 3s radxa-e25-led.sh >/dev/null 2>&1
    none
    ;;
stop)
    echo "RGB stopped"
    killall -o 3s radxa-e25-led.sh >/dev/null 2>&1
    none
    disable
    ;;
*)
    echo "Usage: $0 {start|stop|suspend} <colorful|blink|rgb_breathe|tricolor|none>"
    exit 1
esac

exit 0
