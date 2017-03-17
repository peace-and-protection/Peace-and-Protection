[mts]
NAME chelho
AUTHOR CH
EMAIL spam@thehurley.com
DESCRIPTION chelho theme by CH, inspired by elho for irssi, cynatic and a few others.
WEBSITE 
MTSVERSION 1.1
VERSION 1.3
SCRIPT chelho.mrc

TIMESTAMP on
TIMESTAMPFORMAT [HH:nn:ss]

BASECOLORS 10,10,13,12
COLORS 15,6,5,4,2,2,2,2,5,2,2,1,2,2,2,1,3,3,6,2,2,15,1,15,1,14,6,15
RGBCOLORS 255,255,255 0,0,0 0,0,127 0,147,0 255,0,0 127,0,0 156,0,156 252,127,0 255,255,0 0,255,0 0,89,89 0,121,121 0,0,252 255,0,255 127,127,127 210,210,210

FONTDEFAULT Courier New,12
FONTQUERY Courier New,12
FONTCHAN Courier New,12

CLINEME 04

CLINECHAROWNER .
CLINECHAROP @
CLINECHARHOP %
CLINECHARVOICE +
CLINECHARREGULAR

PREFIX |

TEXTCHAN !script %:echo $_padcalc1(%::cmode) $_padcalc2(%::nick) %::pre %::text
TEXTCHANSELF  !script %:echo $_padcalc1(%::cmode)  $+ $_padcalc2(%::me) $+  %::pre %::text
ACTIONCHAN !script %:echo $_padcalc1(* $+ %::cmode) $_padcalc2(<action>) %::pre %::nick %::text
ACTIONCHANSELF !script %:echo $_padcalc1(* $+ %::cmode) $_padcalc2(<action>) %::pre  $+ %::me $+  %::text
NOTICECHAN !script %:echo $_padcalc1(*) $_padcalc2(<notice>) %::pre %::nick $+ @ $+ %::chan %::text
NOTICE !script %:echo $_padcalc1(*) $_padcalc2(<notice>) %::pre %::nick %::text
NOTICESELF !script %:echo $_padcalc1(*) $_padcalc2(<notice>) %::pre %::target %::text
NOTICESELFCHAN !script %:echo $_padcalc1(*) $_padcalc2(<notice>) %::pre %::target %::text
TEXTQUERY !script %:echo $_padcalc1(*) $_padcalc2(%::nick) %::pre %::text  
TEXTQUERYSELF !script %:echo $_padcalc1(*)  $+ $_padcalc2(%::me) $+  %::pre %::text  
ACTIONQUERY !script %:echo $_padcalc1(*) $_padcalc2(<action>) %::pre %::nick %::text
ACTIONQUERYSELF !script %:echo $_padcalc1(*)$_padcalc2(<action>) %::pre  $+ %::me $+  %::text
TEXTMSG !script %:echo $_padcalc1(*) $_padcalc2(<msg>) %::pre %::target %::text
TEXTMSGSELF !script %:echo $_padcalc1(*) $_padcalc2(<msg>) %::pre %::target %::text
MODE !script %:echo $_padcalc1(*) $_padcalc2(<mode>) %::pre %::nick sets mode %::modes
MODEUSER !script %:echo $_padcalc1(*) $_padcalc2(<mode>) %::pre  $+ %::me $+  sets %::modes
JOIN !script %:echo $_padcalc1(*) $_padcalc2(<join>) %::pre %::nick ( $+ %::address $+ ) has joined %::chan
JOINSELF !script %:echo $_padcalc1(*) $_padcalc2(<join>) %::pre  $+ %::me $+  is entering %::chan ...
PART !script %:echo $_padcalc1(*) $_padcalc2(<part>) %::pre %::nick ( $+ %::address $+ ) has left %::chan %::parentext
KICK !script %:echo $_padcalc1(*) $_padcalc2(<kick>) %::pre %::knick kicked by %::nick $+ , reason: %::parentext
KICKSELF !script %:echo $_padcalc1(*) $_padcalc2(<kick>) %::pre  $+ %::me $+  kicked by %::nick $+ , reason: %::parentext
QUIT !script %:echo $_padcalc1(*) $_padcalc2(<quit>) %::pre %::nick ( $+ %::address $+ ) quits %::parentext
TOPIC !script %:echo $_padcalc1(*) $_padcalc2(<topic>) %::pre %::nick sets topic to %::text
NICK !script %:echo $_padcalc1(*) $_padcalc2(<nick>) %::pre %::nick renamed to  $+ %::newnick $+ 
NICKSELF !script %:echo $_padcalc1(*) $_padcalc2(<nick>) %::pre %::me renamed to  $+ %::newnick $+ 
INVITE !script %:echo $_padcalc1(*) $_padcalc2(<invite>) %::pre %::nick invites you to %::chan
SERVERERROR !script %:echo $_padcalc1(*) $_padcalc2(<error>) %::pre error: %::text
REJOIN !script %:echo $_padcalc1(*) $_padcalc2(<rejoin>) %::pre %::chan
CTCP !script %:echo $_padcalc1(*) $_padcalc2(<ctcp>) %::pre %::nick %::ctcp %::text
CTCPCHAN !script %:echo $_padcalc1(*) $_padcalc2(<ctcp>) %::pre %::nick $+ @ $+ %::chan %::ctcp %::text
CTCPSELF !script %:echo $_padcalc1(*) $_padcalc2(<ctcp>) %::pre %::target %::ctcp %::text
CTCPCHANSELF !script %:echo $_padcalc1(*) $_padcalc2(<ctcp>) %::pre %::target %::ctcp %::text
CTCPREPLY !script %:echo $_padcalc1(*) $_padcalc2(<ctcp>) %::pre %::nick %::ctcp %::text
CTCPREPLYSELF !script %:echo $_padcalc1(*) $_padcalc2(<ctcp>) %::pre %::target %::ctcp %::text
NOTIFY !script %:echo $_padcalc1(*) $_padcalc2(<notify>) %::pre %::nick is online!
UNOTIFY !script %:echo $_padcalc1(*) $_padcalc2(<notify>) %::pre %::nick is offline!
WALLOP !script %:echo $_padcalc1(*) $_padcalc2(<wallop>) %::pre %::nick %::text
NOTICESERVER !script %:echo $_padcalc1(*) $_padcalc2(<notice>) %::pre %::nick %::text
DNS !script %:echo $_padcalc1(*) $_padcalc2(<dns>) %::pre checking %::address ...
DNSERROR !script %:echo $_padcalc1(*) $_padcalc2(<dns>) %::pre couldn't resolve %::address
DNSRESOLVE !script %:echo $_padcalc1(*) $_padcalc2(<dns>) %::pre %::address resolved to %::raddress
ECHO !script %:echo $_padcalc1(*) $_padcalc2($chr(160)) %::pre %::text
ECHOTARGET !script %:echo $_padcalc1(*) $_padcalc2($chr(160)) %::pre %::text
ERROR !script %:echo $_padcalc1(*) $_padcalc2(<error>) %::pre %::text
LOAD !script %:echo $_padcalc1(*) $_padcalc2(<load>) %::pre  $+ chelho 1.3 by CH $+ 

WHOIS !script c.whois
WHOWAS !script c.whowas

raw.001 !script %:echo $_padcalc1(*) $_padcalc2(<welcome>) %::pre 
raw.002 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre %::server version: %::value
raw.003 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre server created: %::value
raw.005 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre protocols supported: %::text
raw.221 !script %:echo $_padcalc1(*) $_padcalc2(<mode>) %::pre %::nick mode(s): %::modes
raw.229 !script %:echo $_padcalc1(*) $_padcalc2(<channel>) %::pre created: $asctime(%::text)
raw.250 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre total connections: %::value 
raw.251 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre users: %::users $+ , invisible: %::text $+ , servers: %::value 
raw.252 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre operators online: %::value 
raw.253 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre unknown connections: %::value 
raw.254 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre channels formed: %::value 
raw.255 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre local clients: %::users on %::value server(s) 
raw.265 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre local users: %::users $+ , max: %::value 
raw.266 !script %:echo $_padcalc1(*) $_padcalc2(<server>) %::pre global users: %::users $+ , max: %::value 
raw.301 !script %:echo $_padcalc1(*) $_padcalc2(<away>) %::pre %::text
raw.307 !script %:echo $_padcalc1(*) $_padcalc2(<nick>) %::pre registered nick: %::isregd
raw.313 !script ;%:echo $_padcalc1(*) $_padcalc2(<ircop>) %::pre %::isoper %::operline
raw.315 !script %:echo $_padcalc1(*) $_padcalc2(<who>) %::pre end of /who
raw.317 !script ;%:echo $_padcalc1(*) $_padcalc2(<idle/signon>) %::pre %::idletime $+ / $+ %::signontime
raw.324 !script %:echo $_padcalc1(*) $_padcalc2(<mode>) %::pre %::chan mode(s): %::modes
raw.329 !script ;%:echo $_padcalc1(*) $_padcalc2(<mode>) %::pre %::text
raw.330 !script set -u4 %::cwhois.auth $iif($gettok(%::text,4,32) != as,$ifmatch,$gettok(%::text,1,32))
raw.332 !script %:echo $_padcalc1(*) $_padcalc2(<topic>) %::pre %::text
raw.333 !script %:echo $_padcalc1(*) $_padcalc2(<topic>) %::pre set by %::nick on $_datetime(%::value)
raw.341 !script %:echo $_padcalc1(*) $_padcalc2(<invite>) %::pre %::nick has been invited to join %::chan 
raw.352 !script %:echo $_padcalc1(*) $_padcalc2(<who>) %::pre %::nick $+ , %::address $+ , %::away $+ , %::isoper an IRCop
raw.353 !script %:echo $_padcalc1(*) $_padcalc2(<names>) %::pre %::text
raw.366 !script %:echo $_padcalc1(*) $_padcalc2(<names>) %::pre end of /names
raw.372 !script %:echo $_padcalc1(*) $_padcalc2(<motd>) %::pre %::text
raw.375 !script ;%:echo $_padcalc1(*) $_padcalc2(<motd>) %::pre /motd
raw.376 !script %:echo $_padcalc1(*) $_padcalc2(<motd>) %::pre end of /motd 
raw.391 !script %:echo $_padcalc1(*) $_padcalc2(<time>) %::pre server date/time: %::text (local time: $time $+ )
raw.401 !script %:echo $_padcalc1(*) $_padcalc2(<nick>) %::pre no such nickname: %::nick 
raw.403 !script %:echo $_padcalc1(*) $_padcalc2(<channel>) %::pre no such channel: %::chan 
raw.404 !script %:echo $_padcalc1(*) $_padcalc2(<channel>) %::pre unable to send message to %::chan 
raw.421 !script %:echo $_padcalc1(*) $_padcalc2(<error>) %::pre invalid command: %::value 
raw.433 !script %:echo $_padcalc1(*) $_padcalc2(<nick>) %::pre nickname in use: %::nick 
raw.442 !script %:echo $_padcalc1(*) $_padcalc2(<channel>) %::pre not on that channel: %::chan 
raw.443 !script %:echo $_padcalc1(*) $_padcalc2(<nick>) %::pre user %::nick already in channel: %::chan 
raw.461 !script %:echo $_padcalc1(*) $_padcalc2(<error>) %::pre not enough parameters: %::value 
raw.471 !script %:echo $_padcalc1(*) $_padcalc2(<channel>) %::pre %::chan full (+l)  
raw.473 !script %:echo $_padcalc1(*) $_padcalc2(<channel>) %::pre %::chan invite only (+i)
raw.474 !script %:echo $_padcalc1(*) $_padcalc2(<channel>) %::pre %::chan you're banned (+b)
raw.475 !script %:echo $_padcalc1(*) $_padcalc2(<channel>) %::pre %::chan requires key (+k) 
raw.482 !script %:echo $_padcalc1(*) $_padcalc2(<channel>) %::pre not opped on %::chan
raw.486 !script %:echo $_padcalc1(*) $_padcalc2(<auth>) %::pre %::text

raw.other !script %:echo $_padcalc1(*) $_padcalc2($chr(160)) %::pre %::text


scheme1 spacer

[scheme1]
COLORS 1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,1,9,1,9,9,9,1
RGBCOLORS 0,0,0 0,0,0 0,0,0 0,255,0 0,0,0 0,225,0 0,0,0 0,0,0 0,0,0 0,255,0 0,0,0 0,0,0 0,0,0 0,0,0 0,0,0 0,0,0
BASECOLORS 03,03,03,03

CLINEME 09
