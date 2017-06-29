[mts]
Name Ultra
Author Variant
Email variant@variantrealities.com
Description Ultra is a lightweight, sleek, dark, blue theme.
Version 1.1
MTSVersion 1.1
Website http://www.variantrealities.com
Script Ultra.mrc

Load <pre> <c1>Ultra theme loaded.

Prefix 2∙12x2∙
ParenText (<c3><text><c1>)

Mode <pre> <c1>Mode(<c2><chan><c1>) [<c3><modes><c1>] by: <nick>
ModeUser <pre> <c1>Mode(<c2><nick><c1>) [<c3><modes><c1>]
Join <pre> <c1>Join(<c2><chan><c1>) <nick>[<c3><address><c1>]
JoinSelf <pre> <c1>Joined <c2><chan>
Part <pre> <c1>Part(<c2><chan><c1>) <nick>[<c3><address><c1>] <parentext>
Kick <pre> <c1>Kick(<c2><chan><c1>) <knick>[<c3><kaddress><c1>] by: <nick> <parentext>
KickSelf <pre> <c1>You were kicked by: <nick>[<c3><address><c1>] on <c2><chan><c1> <parentext>
Quit <pre> <c1>Quit <nick>[<c3><address><c1>] <parentext>
Topic <pre> <c1>Topic(<c2><chan><c1>) [<c3><text><c1>] by: <nick>
Nick <pre> <c1>Nick <nick>[<c3><address><c1>] is now known as <newnick>
NickSelf <pre> <c1>You're now known as <newnick>
Invite <pre> <c1>Invite(<c2><chan><c1>) by: <nick>
ServerError <pre> <c1>Error: <c2><text>
Notice <c2>-<nick>-<c1> <text>
NoticeSelf <c1>∙<gt> <c2>-<nick>-<c1> <text>
Rejoin <pre> <c1>Rejoining <c2><chan><c1>...
TextChan <c4>[<c1><cmode><c3><nick><c4><gt> <text>
TextChanSelf 12[<c2><cmode><c2><me>12<gt> <text>
ActionChan 03* <cmode><nick> <text>
ActionChanSelf 03* <cmode><me> <text>

DNS <pre> <c1>Looking up <c3><nick><address><c1>...
DNSError <pre> <c1>Unable to resolve <c3>(<address>)<c1>.
DNSResolve <pre> <c1>Resolved <c3><address> <c1>to <c3><raddress>

TextQuery <c4>[<c3><nick><c4><gt> <text>
TextQuerySelf 12[<c2><me>12<gt> <text>
ActionQuery 03* <nick> <text>
ActionQuerySelf 03* <me> <text>
TextMsg <c4>*<c3><nick><c4>* <text>
TextMsgSend 12-<gt> <c4>*<c3><nick><c4>* <text>

CTCP <pre> <c2>[<nick>] <c1><ctcp> <c3><text>
CTCPSelf <c1>∙<gt> <c2><nick> 12<ctcp> <c3><text>
CTCPChan <pre> <c2>[<nick>/<chan>] <c1><ctcp> <c3><text>
CTCPChanSelf <c1>∙<gt> <c2><chan> 12<ctcp> <c3><text>
CTCPReply <pre> <c2>[<nick><chan>] <c1><ctcp> reply <c3><text>
CTCPReplySelf <c1>∙<gt> <c2><nick> 12<ctcp> [REPLY] <c3><text>

Whowas <pre> <c1>Whowas: <nick>[<c3><address><c1>] <realname>
Whois !Script ultra.whois

Echo <pre> <text>
EchoTarget <pre> [<target>] <text>
Error <pre> <text>

RAW.001 <pre> <c1><text>
RAW.002 <pre> <c1>Host: <c2><server> <c1>running version <c2><value>
RAW.003 <pre> <c1>Server created on: <c2><value>
RAW.005 <pre> <c1>Protocols supported by this server: <c2><text>
RAW.250 <pre> <c1>Total connection(s): <c2><value>
RAW.251 <pre> <c1>Users: <c2><users> <c1>Invisible: <c2><text> <c1>Servers: <c2><value>
RAW.252 <pre> <c1>Operator(s) online: <c2><value>
RAW.253 <pre> <c1>Unknown connection(s): <c2><value>
RAW.254 <pre> <c1>Number of channels formed: <c2><value>
RAW.255 <pre> <c1>Local clients: <c2><users> <c1>on <c2><value> <c1>server(s)
RAW.265 <pre> <c1>Local users: <c2><users> <c1>Max: <c2><value>
RAW.266 <pre> <c1>Global users: <c2><users> <c1>Max: <c2><value>
RAW.302 <pre> <c1>Userhost: <c2><nick><c1>[<c3><address><c1>]
RAW.315 <pre> <c1>End of /WHO list for <c2><chan>
RAW.324 <pre> <c1>Modes(<c2><chan><c1>) [<c3><modes><c1>]
RAW.332 <pre> <c1>Topic<c3>(<c2><chan><c1>) is <c3>'<text><c3>'
RAW.333 !Script %:echo %::pre  $+ %::c1 $+ Set by:  $+ %::c2 $+ %::nick $+  $+ %::c1 on  $+ %::c2 $+ $_datetime(%::text) $+  $+ %::c1 $+ .
RAW.341 <pre> <c2><nick> <c1>has been invited to <c2><chan>
RAW.352 <pre> <c1><cmode><c2><nick>[<c3><address><c1>] <c1><realname>
RAW.353 <pre> <c2><chan>: <c3><text>
RAW.366 <pre> <c1>End of /NAMES list for <c2><chan>
RAW.375 <pre> <c1>Message of the day:
RAW.372 <c3><text>
RAW.376 <pre> <c1>End of /MOTD command.
RAW.391 <pre> <c1>Date: <c2><value>
RAW.401 <pre> <c1>No such nickname <c2><nick>
RAW.403 <pre> <c1>No such channel <c2><chan>
RAW.404 <pre> <c1>Unable to send message to <c2><chan>
RAW.421 <pre> <c1>Invalid command:<c2> <value>
RAW.433 <pre> <c1>Nickname<c1>(<c2><nick><c1>) is already in use.
RAW.471 <pre> <c1>Can't join <c2><chan> <c3>(its full +l)
RAW.473 <pre> <c1>Can't join <c2><chan> <c3>(its invite only +i)
RAW.474 <pre> <c1>Can't join <c2><chan> <c3>(you're banned +b)
RAW.475 <pre> <c1>Can't join <c2><chan> <c3>(requires key +k)
RAW.482 <pre> <c1>You're not opped on <c2><chan>

RAW.Other <pre> <text>

Colors 1,3,9,5,0,10,3,10,10,12,10,15,5,2,6,0,3,2,12,5,15,1,15,1,15,15
RGBColors 255,255,255 28,29,89 0,0,168 0,147,0 255,0,0 127,0,0 156,0,156 252,127,0 255,255,0 0,252,0 4,107,191 61,165,250 52,55,170 255,0,255 127,127,127 210,210,210
BaseColors 10,11,14,2

CLineOwner 16
CLineOP 16
CLineHOP 15
CLineVoice 15
CLineRegular 46
CLineMe 16
ClineCharOwner 12.
ClineCharOP 12@
ClineCharHOP 18%
ClineCharVoice 34+ 
FontDefault Consolas,11
FontChan Consolas,11
FontQuery Consolas,11