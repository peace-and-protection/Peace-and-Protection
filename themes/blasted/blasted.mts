[mts]
NAME Blasted
AUTHOR Brain
EMAIL brain@iol.pt
DESCRIPTION The perfect thm.
MTSVERSION 1.1
VERSION 2.1

SCRIPT blasted.mrc

PREFIX  12·14×13·15·12
PARENTEXT 13/12 '<text>'
TIMESTAMP on
TIMESTAMPFORMAT  14HH:nn:ss 13/

COLORS 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,15,12,0,1,15 
BASECOLORS 14,13,14,14
RGBCOLORS 242,242,242 0,0,0 0,0,128 0,144,0 255,0,0 128,0,0 160,0,160 255,128,0 255,255,0 0,255,0 0,144,144 0,255,255 81,81,81 187,187,187 128,128,128 208,208,208
CLINEOP 1
CLINEHOP 1
CLINEVOICE 1
CLINEREGULAR 1
CLINEOWNER 1
CLINEENEMY 2
CLINEFRIEND 12
CLINEME 14
CLineCharOwner .
CLineCharOP @
CLineCharHOP %
CLineCharVoice +
CLineCharRegular

FONTDEFAULT Courier new,11
FONTCHAN Courier new,11
FONTQUERY Courier new,11

LOAD !script blasted.intro

MODE !script %:echo %::pre mode   15:12 %::nick 13/12 $gettok(%::modes,1,32) $iif($gettok(%::modes,2-,32),13·12 $ifmatch $+ ) %:comments
JOIN <pre> joins  15:12 <nick> 13·12 <address>
JOINSELF <pre> now in 15:12 <chan>
PART !script %:echo %::pre parts  15:12 %::nick 13·12 %::address $+  $iif(%::text,13/12 ' $+ %::text $+ ') %:comments
TEXTCHAN    12<cmode><nick> 13:12 <text>
TEXTQUERY    12<cmode><nick> 13:12 <text>
KICK !script %:echo %::pre kicks  15:12 %::knick 13·12 %::chan 13by12 %::nick $+  $iif(%::text,13/12 ' $+ %::text $+ ') %:comments
KICKSELF !script %:echo %::pre kicks  15:12 you 13·12 %::chan 13by12 %::nick $+  $iif(%::text,13/12 ' $+ %::text $+ ') %:comments
QUIT !script %:echo %::pre quits  15:12 %::nick 13·12 %::address $+  $iif(%::text,$iif($gettok(%::text,1,32) == Quit: && $gettok(%::text,2-,32),13/12 ' $+ $gettok(%::text,2-,32) $+ ',$iif($gettok(%::text,1,32) != Quit:,%::parentext))) %:comments
TOPIC <pre> topic  15:12 <nick> 13·12 '<text>'
NICK <pre> nick   15:12 <nick> 13·12 <newnick>
NICKSELF <pre> nick   15:12 <nick> 13·12 <newnick>
TEXTCHANSELF  12·14 <cmode><me> 14:12 <text>
TEXTQUERYSELF  12·14 <me> 13:14 <text>
MODEUSER <pre> mode   15:12 <modes>
INVITE <pre> invite 15:13 to12 <chan> 13· by12 <nick>
ACTIONCHAN    13!12<cmode><nick> 12<text>
ACTIONQUERY    13!12<nick> 12<text>
ACTIONCHANSELF  12· 13!14<cmode><me> 14<text>
ACTIONQUERYSELF  12· 13!14<me> 14<text>
CTCP !script %:echo %::pre ctcp   15:12 $lower(%::ctcp) 13· requested by12 %::nick $+  $iif(%::text,13/12 ' $+ %::text $+ ') %:comments
CTCPCHAN !script %:echo %::pre ctcp   15:12 $lower(%::ctcp) 13· requested at 12%::chan by12 %::nick $+  $iif(%::text,13/12 ' $+ %::text $+ ') %:comments
CTCPREPLY !script %:echo %::pre ctcp   15:12 $lower(%::ctcp) 13· from12 %::nick $+  $iif(%::text,13/12 ' $+ %::text $+ ') %:comments
CTCPSELF !script %:echo %::pre ctcp   15:12 $lower(%::ctcp) 13· to12 %::nick $+  $iif(%::text,13/12 ' $+ %::text $+ ') %:comments
CTCPREPLYSELF !script %:echo %::pre reply  15:12 $lower(%::ctcp) 13· to12 %::nick $+  $iif(%::text,13/12 ' $+ %::text $+ ') %:comments
NOTICESERVER <pre> server 15:12 <text>
NOTICE <pre> 12<nick> 13:12 <text>
NOTICECHAN <pre> 12<cmode><nick> 13·12 <target> 13:12 <text>
NOTICESELF <pre> notice 15: 13to12 <target> 13/12 <text>
NOTICESELFCHAN <pre> notice 15: 13to12 <target> 13/12 <text>
NOTIFY <pre> notify 15:12 <nick>14 is online <parentext>
UNOTIFY <pre> notify 15:12 <nick>14 is offline <parentext>

raw.001 
raw.002 <pre> host      15:12 <server>13 runnning12 <value>
raw.003 <pre> created   15:12 <value>
raw.004 !script %:echo %::pre usermodes 15:12 $gettok(%::text,3,32) 13/ chanmodes 15:12 $gettok(%::text,4,32)
raw.005 <pre> protocols 15:12 <text>

raw.311 !script blasted.whoisstart
raw.319    1• chans   15:12 <chan>
raw.312 !script %:echo    1• server  15:12 %::wserver 13·14 %::serverinfo
raw.301    1• away    15:14 <text>
raw.317 !script %:echo    1• idle    15:14 $blasted.st(%::idletime) 13/ sign on 15:14 $asctime($ctime(%::signontime),HH:nn:ss - dd/mmm/yyyy 13·12 ddd) 13/ online time 15:14 $blasted.st($calc($ctime - $ctime(%::signontime)))
raw.307 !script %:echo    1• status  15:12 is $iif(%::isregd != is,not) a registered nick
raw.378    1• real hostname 15:12 <text>
raw.313 !script %:echo    1• ircop   15:12 $iif(%::isoper == is,yes,no) $iif($gettok(%::text,3-,32),13·12 $ifmatch)
raw.318 1 —————12————14———13—————————————15————————————————————— 

raw.314 !script blasted.whowasstart
raw.369 1 —————12————14———13—————————————15————————————————————— 

raw.251 !script blasted.lusersstart
raw.252    1• opers   15:14 <value>
raw.253    1• unknown 15:12 <value> 
raw.254    1• chans   15:12 <value>
raw.255    1• clients 15:12 <users> 13/ servers 15:14 <value>
raw.265 !script %:echo    1• local   15:12 %::users 13/ max 15:14 %::value 13·12 $round($calc($calc(%::users / %::value) * 100),1) $+ %
raw.266 !script blasted.lusersend

raw.315 <pre> end of 12/who13 for 12<value>
raw.352 !script %:echo %::pre  $+ %::cmode $+ %::nick $+  $+ $str($chr(160),$calc(16 - $len(%::cmode $+ %::nick))) 15:12 %::address 13·12 %::realname 13·12 %::wserver $iif(g isin $gettok(%::text,5,32),13/12 away) $iif(* isin $gettok(%::text,5,32),$iif(H isin $gettok(%::text,5,32),13/12 ircop,13·12 ircop)) 13/12 %::value hops

raw.302 !script %:echo %::pre userhost 15:12 $+($iif(%::value != +,),%::nick $+ ! $+ %::address,$iif(%::value != +,)) $iif(* isin %::value,13·12 ircop) $iif(- isin %::value,13·12 away)
raw.324 <pre> modes  15:12 <chan> 13·12 <modes>
raw.329 !script %:echo %::pre created 15:12 $asctime(%::text,dd/mmm/yyyy - HH:nn:ss 13·12 ddd)
raw.341 <pre> invite 15:13 to 12<nick>13 to join 12<chan>
raw.372        <text>
raw.375 <pre> message of the day...
raw.376 <pre> end of 12/motd
raw.391 !script %:echo %::pre server time 15:12 %::text $+  %:comments
raw.401 <pre> error  15:12 <nick> 13·12 no such nick <comments>
raw.403 <pre> error  15:12 <chan> 13·12 no such channel <comments>
raw.404 <pre> error  15:12 <chan> 13·12 cannot send to channel <comments>
raw.406 <pre> error  15:12 <nick> 13·12 there was no such nick <comments>
raw.421 !script %:echo %::pre error 15:12 $+(/,$lower(%::value)) 13·12 unknown command %:comments
raw.432 <pre> error  15:12 <nick> 13·12 erroneus nickname <comments>
raw.433 <pre> error  15:12 <nick> 13·12 nick already in use <comments>
raw.441 <pre> error  15:12 <nick>14 is not on 12<chan> <comments>
raw.442 <pre> error  15:12 you14 are not on12 <chan> <comments>
raw.443 <pre> error  15:12 <nick>14 is already on 12<chan> <comments>
raw.467 <pre> error  15:12 cannot join <chan>, key required <comments>
raw.471 <pre> error  15:12 cannot join <chan>, channel is full <comments>
raw.473 <pre> error  15:12 cannot join <chan>, invite required <comments>
raw.474 <pre> error  15:12 cannot join <chan>, you're banned <comments>
raw.475 <pre> error  15:12 cannot join <chan>, incorrect key <comments>

raw.332 !script blasted.topic
raw.333 !script blasted.endtopic

raw.353 !script blasted.names
raw.366 !script blasted.endnames

raw.other !script %:echo %::pre $iif(%::nick != $gettok(%::text,1,32), $+ $ifmatch 15:12) %::text %:comments
ECHO <pre> 12<text>
ECHOTARGET <pre> 12<text>
ERROR <pre> error 14: <text>

