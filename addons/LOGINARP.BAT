@echo off
cls
echo This window is collecting info on TCP/UDP connections via netstat.
echo If you close it, PnP may not display your connections correctly.
netstat -a -n >%1
del %2 >nul
exit
