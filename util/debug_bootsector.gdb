set pagination off
target remote localhost:1234
#break *0x00008800
#continue
#watch $bp==0x1234
continue
info registers

#to get past an infinite loop after the execution has been paused:
#set $pc += 2
#si