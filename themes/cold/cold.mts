[mts]
; MTS-compatible theme file saved by Peace and Protection 4.22.6 by pai
Author acvxqs
BaseColors 14,00,14,11
BoldLeft 
BoldRight 
ChannelsLowercase 1
CLineHOP 00
CLineMe 11
CLineOP 00
CLineOwner 00
CLineRegular 14
CLineVoice 15
ColorError 04
Colors 01,00,15,15,14,14,15,14,14,14,14,00,15,14,14,00,14,14,00,14,00,01,00,01,00,15
Description Based off nbs-irc's cold.
Error <pre> <text>
FontChan Tahoma,11
FontDCC Tahoma,11
FontDefault Tahoma,11
FontQuery Tahoma,11
FontScript Tahoma,11
ImageScript
Invite <pre> <nick> (<address>) invited you to <chan>
Join !Script %:echo %::pre Join: %::nick  $+ %::c4 $+ ( $+ %::address $+  $+ %::c4 $+ ) %:comments
JoinSelf <pre> Now talking in <chan>
JoinStatus !Script %:echo %::pre Join: %::nick ( $+ %::address $+ ) %:comments
Kick <pre> <knick> was kicked by <nick> <parentext>
KickSelf <pre> You were kicked from <chan> by <nick> <parentext>
KickStatus <pre> <knick> was kicked from <chan> by <nick> <parentext>
LineSep OFF
LineSepWhois 0
Mode <pre> <nick> sets mode: <modes>
ModeStatus <pre> <nick> sets <chan> mode: <modes>
ModeUser <pre> <nick> sets mode: <modes>
MTSVersion 1.1
Name nbs-irc cold
Nick <pre> <nick> is now known as <newnick>
NickSelf <pre> Nick changed to: <newnick>
Notice <pre> [notice from <nick>]: <text>
NoticeChan <pre> <c4>(<nick>: <target><c4>) <text>
NoticeSelf <pre> [notice: <nick>]: <text>
NoticeSelfChan <pre> [notice: <target>]: <text>
ParenText <c4>(<text><c4>)
Part !Script %:echo %::pre Part: %::nick  $+ %::c4 $+ ( $+ %::address $+  $+ %::c4 $+ ) %::parentext %:comments
PartStatus !Script %:echo %::pre Part: %::nick ( $+ %::address $+ ) %::parentext %:comments
PnPNickColors 14 ? ? ? ? 11 ? ?,15 ? ? ? ? 11 ? ?,00 ? ? ? ? 11 ? ?,00 ? ? ? ? 11 ? ?
PnPTheme 1
Prefix <c4>-›
Quit !Script %:echo %::pre Quit: %::nick  $+ %::c4 $+ ( $+ %::address $+  $+ %::c4 $+ ) %::parentext %:comments
RAW.324 !Script %:echo %::pre Mode- $:s($iif(%::modes == +,(none),%::modes)) %:comments
RAW.329 !Script %:echo %::pre Channel created: $_datetime(%::value) $+(,%::c4,$chr(40),,$_dur($calc($ctime - %::value)) ago,,%::c4,$chr(41),)
RAW.331 !Script %:echo %::pre Topic: $:s((none)) %:comments
RAW.332 !Script %:echo %::pre Topic: %::text %:comments
RAW.333 !Script %:echo %::pre Set by $:t(%::nick) on $:h($_datetime(%::value)) $+(,%::c4,$chr(40),,$_dur($calc($ctime - %::value)) ago,,%::c4,$chr(41),) %:comments
RAW.353 !Script _pnpnbs-irc.names353
RAW.366 !Script return
RAW.366uc !Script _pnpnbs-irc.names366uc
Rejoin <pre> Attempting to rejoin...
RGBColors 255,255,255 0,0,0 0,0,127 0,147,0 255,0,0 127,0,0 156,0,156 252,127,0 255,255,0 0,252,0 0,147,147 10,140,255 0,0,252 255,0,255 127,127,127 200,200,200
Scheme1 nbs-irc cold/green
Scheme2 nbs-irc cold/orange
Scheme3 nbs-irc cold/red
Script cold.mrc
TextChan (<c4><cmode><cnick><nick>) <text>
TextChanSelf (<c4><cmode><cnick><nick>) <text> <comments>
TimeStamp ON
TimeStampFormat 14(HH<c4>:nn<c4>:ss14)
Topic <pre> <nick> changes topic to: <text>
TopicStatus <pre> <nick> changes <chan> topic to '<text>'
Version 1.0

[scheme1]
BaseColors 14,00,14,03
PnPNickColors 14 ? ? ? ? 03 ? ?,15 ? ? ? ? 03 ? ?,00 ? ? ? ? 03 ? ?,00 ? ? ? ? 03 ? ?

[scheme2]
BaseColors 14,00,14,07
PnPNickColors 14 ? ? ? ? 07 ? ?,15 ? ? ? ? 07 ? ?,00 ? ? ? ? 07 ? ?,00 ? ? ? ? 07 ? ?

[scheme3]
BaseColors 14,00,14,04
PnPNickColors 14 ? ? ? ? 04 ? ?,15 ? ? ? ? 04 ? ?,00 ? ? ? ? 04 ? ?,00 ? ? ? ? 04 ? ?