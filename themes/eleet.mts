[mts]
; MTS-compatible theme file saved by Peace and Protection 4.20 by pai
Author pai
BaseColors 02,01,10,14
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
Description Fixed-width, aligned nicknames theme, shows user addresses in notices
Email pai@pairc.com
FontChan FixedSys,12
FontDCC FixedSys,12
FontDefault FixedSys,12
FontQuery FixedSys,12
FontScript FixedSys,12
ImageScript
LineSep 01········02········12········14········15········
LineSepWhois 1
MTSVersion 1.1
Name 'Elite' fixed-width theme
ParenText (<text>)
PnPLineSep 40 · 01 02 12 14 15
PnPNickColors 01 05 02 02 06 05 07 03,01 05 02 02 06 05 07 03,14 04 12 12 13 04 07 03,14 04 12 12 13 04 07 10
PnPTheme 1
Prefix 12*2*1*
RGBColors 255,255,255 0,0,0 0,0,127 0,147,0 255,0,0 127,0,0 156,0,156 252,127,0 255,255,0 0,252,0 0,147,147 0,255,255 0,0,252 255,0,255 127,127,127 210,210,210
Scheme1 Alternate nicklist colors 1
Scheme2 Alternate nicklist colors 2
Scheme3 Alternate nicklist colors 3
Script eleet.mrc
TimeStamp ON
TimeStampFormat <c1>[HH:nn]
ActionChan !Script %:echo $etheme.npada(%::nick) $+ ): %::text %:comments
ActionChanSelf !Script %:echo $iif($_optn(0,23),$etheme.npada(%::me)) $+ ): %::text %:comments
TextChan !Script %:echo  $+ %::cnick $+ $etheme.npad(%::nick) $+  $+ %::cnick $+ ]: %::text %:comments
TextChanSelf !Script %:echo $iif($_optn(0,23), $+ %::cnick $+ $etheme.npad(%::me) $+  $+ %::cnick) $+ ]: %::text %:comments
ActionQuery !Script %:echo ( $+ $etheme.npad2(9,%::nick) $+ ): %::text %:comments
ActionQuerySelf !Script %:echo $iif($_optn(0,23),$chr(40) $+ $etheme.npad2(9,%::nick)) $+ ): %::text %:comments
TextQuery !Script %:echo [[ $+ $etheme.npad2(9,%::nick) $+ ]: %::text %:comments
TextQuerySelf !Script %:echo $iif($_optn(0,23),[[ $+ $etheme.npad2(9,%::nick)) $+ ]: %::text %:comments
TextChanOp <c4>[<nick><c4>:(<c3><target><c4>)] <text>
ActionChanOp <c4>(<nick><c4>:(<c3><target><c4>)) <text>
TextSelfChanOp <c4>-><target><c4>: <text>
TextMsg !Script %:echo $iif($event == ACTION,$+(,%::c4,$chr(40),,%::nick,,%::c4,$chr(40),,%::c3,%::address,,%::c4,$chr(41),$chr(41),),$+(,%::c4,[,%::nick,,%::c4,$chr(40),,%::c3,%::address,,%::c4,$chr(41),])) %::text %:comments
TextMsgSelf <c4>-><nick><c4>: <text>
Notice <c4>-<nick><c4>(<c3><address><c4>)- <text>
NoticeChan <c4>-<nick><c4>:(<c3><target><c4>)- <text>
NoticeSelf <c4>-><nick><c4>: <text>
NoticeSelfChan <c4>-><target><c4>: <text>

[scheme1]
PnPNickColors 01 02 10 10 07 02 05 06,01 02 10 10 07 02 05 06,14 12 10 10 07 12 04 13,14 12 10 10 07 12 04 13

[scheme2]
PnPNickColors 01 12 10 14 13 05 04 03,01 12 10 14 13 05 04 03,01 12 10 14 13 05 04 03,01 12 10 14 13 05 04 03

[scheme3]
PnPNickColors 02 06 05 05 10 01 07 03,02 06 05 05 10 01 07 03,12 13 04 04 10 14 07 03,12 13 04 04 10 14 07 03
