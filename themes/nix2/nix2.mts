[mts]
NAME Nix2
Author Variant
Email Eric@eircweb.com
Website http://eircweb.com
MTSVersion 1.1
Version 1.1
TIMESTAMP OFF
TIMESTAMPFORMAT [hh:nn]
PREFIX *
ParentExt (09<text>03)
Description This is the second version of nix :) Its nice on the eyes.. and sometimes makes you feel cooler (not that this matters or anything :P) (Ported to MTS by Eric^^)
MODE 10· Mode14/09<chan>10 [14<modes>10] by: <nick>
JOIN 3· Join14/09<chan>3 <nick>10!14<address>
JOINSELF 3· Joined 09<CHAN>
PART 3· Part14/09<chan>3 <nick>10!14<address> <parentext>
TEXTCHAN 3/09<cmode>3]14<nick>3<gt> <text>
TEXTQUERY 3/14<nick>3<gt> <text>
TEXTCHANSELF 12/09<cmode>12]09<me>12> <text>
TEXTQUERYSELF 12/09<me>12> <text>
KICK 3· Kick14/09<chan>3 <knick>10!14<kaddress> 3by: <nick> (<text>3)
KICKSELF 3· You were kicked off of 9<chan>3 by: <nick>10!14<address>3 (<text>03)
QUIT 3· Quit 09<nick>10!14<address>03 <parentext>
TOPIC 3· Topic14/09<chan> 14'<text>14'3 by: <nick>
NICK 3· Nick <nick>10!14<address>3 is now known as <newnick>
NICKSELF 3· You're now known as <newnick>
USERMODE 10· Mode14/09<me>10 [14<modes>10] by: <me>
INVITE 10· Invite14/09<chan>10 by: <nick>10!14<address>
RAW.311 03· Whois: 09<nick>10!14<address>03 10<realname>
RAW.319 03· 09<nick>14/03Channels 10<chan>
RAW.312 03· 09<nick>14/03Server 10<wserver>
RAW.317 !script %:echo 03·09 %::nick 03has been idle for:10 $_dur(%::idletime) 
RAW.301 03· 09<nick>14/03Away message: 10<text>
RAW.313 03· 09<nick>03 <ircop> an IRC Operator
RAW.314 03· Whowas: 09<nick>10!14<address>03 10<text>
RAW.401 03· No such nickname 10<nick>
RAW.403 03· No such channel 10<chan>
RAW.404 03· Unable to send message to 10<chan>03 (possible server desynch)
RAW.324 10· Modes14/09<chan>10 [14<modes>10]
RAW.341 03· 09<nick> 03has been invited to 10<chan>
RAW.471 03· Can't join 10<chan> 12(its full +l)
RAW.473 03· Can't join 10<chan> 03(its invite only +i)
RAW.474 03· Can't join 10<chan> 03(you're banned +b)
RAW.467 03· Can't join 10<chan> 12(requires key +k)
RAW.482 03· You're not opped on 10<chan>
RAW.332 3· Topic14/09<chan> is 14'<text>14'
RAW.333 !script %:echo 3· Set by:10 %::nick 3on10 $_datetime(%::value) 03.
RAW.433 03· Nickname14/09&nick 03is already in use
RAW.352 03· 09<cmode>14<nick>10!14<address>03 10<realname>
RAW.315 03· End of /WHO list for 14<value>
FontDefault Lucida Console,12
FontChan Lucida Console,12
FontQuery Lucida Console,12
Colors 1,3,9,5,0,10,3,10,10,12,10,15,5,2,6,0,3,2,12,5,15,1,15,1,15
RAW.001 3· 03<text>
RAW.002 3· 03Host: 09<host> 03running version 09<version>
RAW.003 3· 03Server created on: 09<date>
RAW.005 3· 03Protocols: 09<text> 03are available on this server.
RAW.250 3· 03Total connection(s): 09<value>
RAW.251 3· 03Users: 09<users> 03Invisible: 09<value> 03Servers: 09<text>
RAW.252 3· 03Operator(s) online: 09<value>
RAW.253 3· 03Unknown connection(s): 09<value>
RAW.254 3· 03Number of channels formed: 09<value>
RAW.255 3· 03Local clients: 09<users> 03on 09<value> 03server(s)
RAW.302 3· 03Userhost: 09<nick> 03(10<address>03)
RAW.265 3· 03Local users: 09<users> 03Max: 09<value>
RAW.266 3· 03Global users: 09<users> 03Max: 09<value>
RAW.391 3· 03Date: 09<date>
RAW.375 3· 03Message of the day:
RAW.376 3· 03End of /MOTD command.
RAW.372 14<text>
NAMES 3· 09<chan>: 14<text>
NOTONCHAN 3· 03You're not on a channel.
ACTIONCHAN 06* 03<cmode>06<nick> <text>
ACTIONQUERY 06* 03<cmode>06<nick> <text>
ACTIONCHANSELF 06* 03<cmode>06<nick> <text>
ACTIONQUERYSELF 06* 03<cmode>06<nick> <text>
CTCPSEND 03·> 09<nick> 10<ctcp> 14<text>
CTCPREPLYSEND 03·> 09<nick> 10<ctcp> 14<text>
CTCP 3· 03<nick> 10<ctcp> 14<text>
CTCPCHAN 3· 03<nick>:<chan> 10<ctcp> 14<text>
CTCPREPLY 3· 03<nick> 10<ctcp> reply 14<text>
ERROR 3· 03Error: 09<text>
NOTICESELF 03·> 09-<nick>-03 <text>
NOTICESELFCHAN 03·> 09-<nick>:<chan>-03 <text>
NOTICE 09-<nick>-03 <text>
NOTICECHAN 09-<nick>:<CHAN>-03 <text>
DNS 3· 03Looking up 14<address>03...
DNSERROR 3· 03Unable to resolve 14(<iaddress><naddress>)03.
DNSRESOLVE 3· 03Resolved 14<naddress>14(03<iaddress>14) 03to 14<raddress>
RAW.421 3· 03Invalid command:09 <text>
CLINEOP 15
CLINEVOICE 15
CLINEREGULAR 15
CLINEOWNER 15
CLINEFRIEND 00
CLINEME 09
CLINEENEMY 04
BaseColors 03,09,15,14
