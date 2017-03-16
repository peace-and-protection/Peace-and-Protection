[mts]
NAME black ice
AUTHOR removed
SCRIPT blackice.mrc
EMAIL rem0ved@hotmail.com
DESCRIPTION My 2nd theme with MTS.
WEBSITE none
MTSVERSION 1.1
VERSION 1.0

COLORS 01,00,12,12,15,15,12,12,12,12,12,00,00,15,15,00,15,15,12,12,15,01,15,01,15,15
BASECOLORS 00,10,14,15
RGBCOLORS 255,255,255 0,0,0 0,0,128 0,144,0 255,0,0 128,0,0 160,0,160 255,128,0 255,255,0 0,255,0 0,144,144 0,255,255 0,0,255 255,0,255 145,145,145 208,208,208

CLINEOP 15
CLINEHOP 15
CLINEVOICE 14
CLINEREGULAR 00
CLINEOWNER 14
CLINEME 10
CLineCharOwner <c1>.
CLineCharOP <c1>@
CLineCharHOP <c1>%
CLineCharVoice <c1>+
CLineCharRegular

FONTDEFAULT Consolas,12
FONTCHAN Consolas,12
FONTQUERY Consolas,12

PREFIX <c4>Θ
PARENTEXT <c1>(<c4><text><c1>)
TIMESTAMP OFF
TIMESTAMPFORMAT <c1>(h)<c4>:nnt<c1>)
SCHEME1 blueice
SCHEME2 redice
SCHEME3 blueice w/ black bg
SCHEME4 redice w/ black bg

TEXTCHAN «<c1><cmode><c4><nick>» <c2><text>
TEXTCHANSELF «<c1><cmode><c4><me>» <c2><text>
ACTIONCHAN <c1>(<c3><nick><c1>) <c2><text>
ACTIONCHANSELF <c1>(<c3><me><c1>) <c2><text>

NOTICE <c1>(n)<c4>otice <c2><text> <c1>from <c3><nick>
NOTICESELF <c1>(n)<c4>otice <c2><text> <c1>to <c3><nick>
NOTICECHAN  <c1>(n)<c4>otice <c2><text> <c1>from <c3><nick> <c1>: <c3><chan>
NOTICESELFCHAN <c1>(n)<c4>otice <c2><text> <c1>to <c3><chan>
NOTICESERVER <c1>(n)<c4>otice <c2><text>

TEXTQUERY <c1>[<c4><nick><c1>] <c2><text>
TEXTQUERYSELF <c1>[<c4><me><c1>] <c2><text>
ACTIONQUERY <c1>(<c3><nick><c1>) <c2><text>
ACTIONQUERYSELF <c1>(<c3><nick><c1>) <c2><text>
TEXTMSGSELF !script %:echo  $+ %::c1 $+ (p) $+ %::c4 $+ riv $+ %::c1 $+ m $+ %::c4 $+ sg  $+ %::c2 $+ %::text  $+ %::c1 $+ to  $+ %::c3 $+ $1

MODE <pre> <c2><nick> <c1>(s)<c4>ets <c2><chan> <c1>(<modes>)
MODEUSER <pre> <c1>(u)<c4>ser<c1>m<c4>ode <c1>(<modes>)
JOIN <pre> <c1>j<c4>oin <c2><nick><c1>:<c2><address>
PART <pre> <c1>(p)<c4>art <c2><nick><c1>:<c2><address> <parentext>
KICK <pre> <c2><knick><c1> was kicked by <c2><nick> <parentext>
KICKSELF <pre> <c1>you were kicked from <c2><chan> <c1>by <c2><nick> <parentext>
QUIT <pre> <c1>(q)<c4>uit <c2><nick><c1>:<c2><address> <parentext>
TOPIC <pre> <c1>(t)<c4>opic <c2><chan><c1>:<c4><text> <c1>set by <c2><nick>
NICK <pre> <c1>(o)<c4>ld<c1>n<c4>ick<c1>: <c2><nick> <c1>-> <c1>n<c4>ew<c1>(n)<c4>ick<c1>: <c2><newnick>
NICKSELF <pre> <c1>(o)<c4>ld<c1>n<c4>ick<c1>: <c2><nick> <c1>-> <c1>n<c4>ew<c1>(n)<c4>ick<c1>: <c2><newnick>
INVITE <pre> <c1>you were invited to <c2><chan> <c1>by <c2><nick>
SERVERERROR <pre> <c1>(e)<c4>rror<c1>: <c3><text>

CTCP <pre> <c1>(c)<c4>tcp<c1>: <c3><ctcp> <c1>from <c2><nick>
CTCPCHAN <pre> <c1>(c)<c4>tcp<c1>:<c4><ctcp> <c1>from <c2><chan>
CTCPREPLY <pre> <c1>(c)<c4>tcp<c1>r<c4>eply: <c2><parentext> <c1>from <c2><nick>
CTCPSELF <pre> <c1>(c)<c4>tcp<c1>: <c3><ctcp> <c1>to <c2><nick>
CTCPCHANSELF <pre> <c1>(c)<c4>tcp<c1>:<c4><ctcp> <c1>to <c2><chan>
CTCPREPLYSELF <pre> <c1>(c)<c4>tcp<c1>r<c4>eply: <c2><text>

NOTIFY <pre> <c1>(n)<c4>otify <c2><nick> <c1>is online
UNOTIFY <pre> <c1>n<c4>otify <c2><nick> <c1>is offline
WALLOP <pre> <c1>wallop<c1>:<c3><text>
NOTICESERVER <pre> <c1>(s)<c4>erv<c1>n<c4>otice<c1>: <c2><text> <c1>from <c2><nick>

DNS <pre> <c1>(l)<c4>ookup<c1>: <c2><address>
DNSERROR <pre> <c1>(d)<c4>ns<c1>e<c4>rror<c1>: <c2><iaddress><naddress>
DNSRESOLVE <pre> <c1>d<c4>ns<c1>(r)<c4>esolved<c1>: <c2><raddress>

ECHO <pre> <c4><text>
ECHOTARGET <pre> <c4><text>
ERROR <pre> <c4><text>
LOAD <pre> <c1>(b)<c3>lack<c1>i<c3>ce <c1>(l)<c3>oaded

raw.251 <pre> <c1>(G)<c3>lobal: <c1>u<c4>sers[<c2><users><c1>] <c1>(i)<c4>nvisible[<c2><text><c1>] <c1>s<c4>ervers[<c2><value><c1>]
raw.252 <pre> <c1>(G)<c3>lobal: <c1>o<c4>pers[<c2><value><c1>]
raw.253 <pre> <c1>(G)<c3>lobal: <c1>u<c4>nknown[<c2><value><c1>]
raw.254 <pre> <c1>(G)<c3>lobal: <c1>c<c4>hannels[<c2><value><c1>]
raw.255 <pre> <c1>(L)<c3>ocal: <c1>c<c4>lients[<c2><users><c1>] <c1>(s)<c4>ervers[<c2><value><c1>]
raw.other <pre> <c4><text>
raw.311 !script bi.whoisinit
raw.319 !script bi.whoischan
raw.312 !script bi.whoisserv
raw.301 !script bi.whoisaway
raw.307 !script bi.whoisreg
raw.317 !script bi.whoisidle
raw.313 !script bi.whoisoper
raw.318 !script bi.whoisend
raw.314 <c1>(w)<c3>ho<c1>w<c4>as <c1>: <c2><nick><c1>-<c2><address><c1>-<c2><realname>
raw.332 <pre> <c1>(t)<c3>opic<c1>: <c2><text>
raw.324 <pre> <c1>m<c3>odes<c1>: <c2><modes>
raw.352 <pre> <c1>w<c3>ho<c1>:<c2><chan><c1>: <c3><cmode><c2><nick><c1>:<c2><address> (<realname>)
raw.305 <pre> <c1>(u)<c4>ser<c1>s<c4>tatus<c1>: <c2>back
raw.306 <pre> <c1>(u)<c4>ser<c1>s<c4>tatus<c1>: <c2>away
raw.401 <pre> <c1>(e)<c4>rror<c1>: <c2><nick> <c2>no such nick
raw.403 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>no such channel
raw.404 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>cannot send data to channel
raw.405 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>you are on too many channels
raw.406 <pre> <c1>(e)<c4>rror<c1>: <c2><nick> <c2>there was no such nick
raw.421 <pre> <c1>(e)<c4>rror<c1>: <c2>/<value> <c2>no such command
raw.432 <pre> <c1>(e)<c4>rror<c1>: <c2><nick> <c2>invalid nickname
raw.433 <pre> <c1>(e)<c4>rror<c1>: <c2><nick> <c2>nickname in use
raw.436 <pre> <c1>(e)<c4>rror<c1>: <c2><nick> <c2>nickname collision
raw.438 <pre> <c1>(e)<c4>rror<c1>: <c2>nick change too fast, try again later
raw.439 <pre> <c1>(e)<c4>rror<c1>: <c2>target changed too fast, try again later
raw.441 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2><nick> is not in that channel
raw.442 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>you are not in that channel
raw.443 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2><nick> is already in that channel
raw.461 <pre> <c1>(e)<c4>rror<c1>: <c2><text> <c2>more paramaters needed
raw.465 <pre> <c1>(e)<c4>rror<c1>: <c2>you are banned from this server
raw.467 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>no key given
raw.471 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>full
raw.472 <pre> <c1>(e)<c4>rror<c1>: <c2><text> <c2>invalid character
raw.473 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>invite only
raw.474 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>you're banned
raw.475 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>incorrect key
raw.478 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>cannot ban <text>, banlist is full
raw.482 <pre> <c1>(e)<c4>rror<c1>: <c2><chan> <c2>you are not an op
raw.511 <pre> <c1>(e)<c4>rror<c1>: <c2>You're ignore list is full

[scheme1]
LOAD <pre> <c1>(b)<c3>lue<c1>i<c3>ce <c1>s<c3>cheme <c1>(l)<c3>oaded
COLORS 01,00,12,12,11,11,12,12,12,12,12,00,00,11,11,00,11,11,12,12,11,01,11,01,11,11
BASECOLORS 02,11,12,00
RGBCOLORS 255,255,255 0,0,113 0,128,255 0,144,0 255,0,0 128,0,0 160,0,160 255,128,0 255,255,0 0,255,0 0,144,144 0,200,255 0,0,225 255,0,255 145,145,145 208,208,208

CLINEOP 00
CLINEHOP 00
CLINEME 11
CLINEVOICE 12
CLINEREGULAR 02
CLINEOWNER 12

[scheme2]
LOAD <pre> <c1>(r)<c3>ed<c1>i<c3>ce <c1>s<c3>cheme <c1>(l)<c3>oaded
COLORS 01,00,11,11,04,04,11,11,11,11,11,00,00,04,04,00,04,04,11,11,04,01,04,01,04,04
BASECOLORS 02,04,11,00
RGBCOLORS 255,255,255 145,0,0 226,0,123 0,144,0 255,0,0 128,0,0 160,0,160 255,128,0 255,255,0 0,255,0 0,144,144 255,100,100 0,0,225 255,0,255 145,145,145 208,208,208

CLINEOP 00
CLINEHOP 00
CLINEME 04
CLINEVOICE 11
CLINEREGULAR 02
CLINEOWNER 11

[scheme3]
LOAD <pre> <c1>(b)<c3>lue<c1>i<c3>ce <c1>s<c3>cheme <c1>(l)<c3>oaded
COLORS 01,00,12,12,11,11,12,12,12,12,12,00,00,11,11,00,11,11,12,12,11,01,11,01,11,11
BASECOLORS 02,11,12,00
RGBCOLORS 255,255,255 0,0,0 0,128,255 0,144,0 255,0,0 128,0,0 160,0,160 255,128,0 255,255,0 0,255,0 0,144,144 0,200,255 0,0,225 255,0,255 145,145,145 208,208,208

CLINEOP 00
CLINEHOP 00
CLINEME 11
CLINEVOICE 12
CLINEREGULAR 02
CLINEOWNER 12

[scheme4]
LOAD <pre> <c1>(r)<c3>ed<c1>i<c3>ce <c1>s<c3>cheme <c1>(l)<c3>oaded
COLORS 01,00,11,11,04,04,11,11,11,11,11,00,00,04,04,00,04,04,11,11,04,01,04,01,04,04
BASECOLORS 02,04,11,00
RGBCOLORS 255,255,255 0,0,0 226,0,123 0,144,0 255,0,0 128,0,0 160,0,160 255,128,0 255,255,0 0,255,0 0,144,144 255,100,100 0,0,225 255,0,255 145,145,145 208,208,208

CLINEOP 00
CLINEHOP 00
CLINEME 04
CLINEVOICE 11
CLINEREGULAR 02
CLINEOWNER 11