@echo off
cls
echo This window is collecting your ICMP, TCP, and UDP statistics via netstat.
echo If you close it, PnP may not display your statistics correctly.
netstat -s >%1
del %2 >nul
exit
