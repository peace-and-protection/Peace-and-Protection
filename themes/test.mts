[mts]
; MTS-compatible theme file saved by Peace and Protection 4.20 by pai
Author pai
BaseColors 02,01,14,14
BoldLeft 
BoldRight 
ChannelsLowercase 1
CLineEnemy 02
CLineFriend 05
CLineHOP 14
CLineIrcOP 06
CLineMe 05
CLineOP 14
CLineOwner 14
CLineRegular 01
CLineVoice 01
ColorError 04
Colors 00,06,02,07,12,12,10,04,03,10,10,01,14,04,06,01,03,03,10,05,02,00,01,00,01,15
Description Based off the "test" scheme from PnP 4.06
Email pai@pairc.com
FontChan Arial,12
FontDCC Arial,12
FontDefault Arial,12
FontQuery Arial,12
FontScript Arial,12
ImageScript
LineSep 01········02········12········14········15········
LineSepWhois 1
MTSVersion 1.1
Name PnP "test" theme
ParenText (<text>)
PnPLineSep 40 · 01 02 12 14 15
PnPNickColors 01 05 02 02 06 05 07 03,01 05 02 02 06 05 07 03,14 04 12 12 13 04 07 03,14 04 12 12 13 04 07 10
PnPTheme 1
Prefix 12•2•1•
RGBColors 255,255,255 0,0,0 0,0,127 0,147,0 255,0,0 127,0,0 156,0,156 252,127,0 255,255,0 0,252,0 0,147,147 0,255,255 0,0,252 255,0,255 127,127,127 210,210,210
Scheme1 Alternate nicklist colors 1
Scheme2 Alternate nicklist colors 2
Scheme3 Alternate nicklist colors 3
TimeStamp ON
TimeStampFormat <c1>[HH:nn]

TextChan «<cnick><cmode><nick>» <text>
TextChanOp <lt>*<nick>:<target>*<gt> <text>
TextChanSelf !Script %:echo $iif($_optn(0,23),$+(«,%::cnick,%::cmode,%::me,»),») %::text %:comments
ActionChan ¢ <nick> <text>
ActionChanOp <lt>*<nick>:<target>*<gt> <text>
ActionChanSelf ¢ <me> <text>
Notice ±<nick>± <text>
NoticeChan !Script %:echo $iif(%::target == %::chan,$+(±,%::nick,::,%::target,±),$+(<-,%::nick,:,%::target,->)) %::text %:comments
NoticeSelf -> ±<nick>± <text>
NoticeSelfChan !Script %:echo -> $iif(%::target == %::chan,$+(±,%::target,±),$+(<-,%::target,->)) %::text %:comments
TextQuery «<nick>» <text>
TextQuerySelf !Script %:echo $iif($_optn(0,23),$+(«,%::me,»),») %::text %:comments
ActionQuery ¢ <nick> <text>
ActionQuerySelf ¢ <me> <text>
TextMsg !Script %:echo $iif($event == ACTION,‹¢ $+ %::nick $+ ¢›,‹* $+ %::nick $+ *›) %::text %:comments
TextMsgSelf -> ‹*<nick>*› <text>
Mode *** <nick> -mode- <modes>
Join *** <nick> (<address>) --> <chan>
Join *** --> <chan>
Part *** <nick> (<address>) <-- <chan> <parentext>
Kick *** <nick> -kicked- <knick> <parentext>
KickSelf *** <nick> -kicked- you <parentext>
Quit *** <nick> (<address>) quit <parentext>
Topic *** <nick> -topic- '<text>'
Nick *** <nick> is now <newnick>
NickSelf *** You are now <newnick>
JoinStatus *** <nick> (<address>) --> <chan>
PartStatus *** <nick> (<address>) <-- <chan> <parentext>
KickStatus *** <nick> -kicked- <knick> in <chan> <parentext>
ModeStatus *** <nick> -mode-<chan>- <modes>
TopicStatus *** <nick> -topic-<chan>- '<text>'
TextSelfChanOp -> <*<target>*> <text>

[scheme1]
PnPNickColors 01 02 10 10 07 02 05 06,01 02 10 10 07 02 05 06,14 12 10 10 07 12 04 13,14 12 10 10 07 12 04 13

[scheme2]
PnPNickColors 01 12 10 14 13 05 04 03,01 12 10 14 13 05 04 03,01 12 10 14 13 05 04 03,01 12 10 14 13 05 04 03

[scheme3]
PnPNickColors 02 06 05 05 10 01 07 03,02 06 05 05 10 01 07 03,12 13 04 04 10 14 07 03,12 13 04 04 10 14 07 03
