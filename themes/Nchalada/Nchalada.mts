[mts]
; MTS-compatible theme file saved by Peace and Protection 4.22.6 by pai
ActionChan !Script %:echo $etheme.npada(%::nick) $+ ): %::text %:comments
ActionChanOp <c4>(<nick><c4>:(<c3><target><c4>)) <text>
ActionChanSelf !Script %:echo $iif($_optn(0,23),$etheme.npada(%::me)) $+ ): %::text %:comments
ActionQuery !Script %:echo ( $+ $etheme.npad2(9,%::nick) $+ ): %::text %:comments
ActionQuerySelf !Script %:echo $iif($_optn(0,23),$chr(40) $+ $etheme.npad2(9,%::nick)) $+ ): %::text %:comments
Author Nchalada
BaseColors 15,00,11,08
BoldLeft 
BoldRight 
ChannelsLowercase 0
CLineEnemy 08
CLineFriend 11
CLineHOP 15
CLineIrcOP 09
CLineMe 04
CLineOP 15
CLineOwner 15
CLineRegular 00
CLineVoice 00
ColorError 11
Colors 01,06,11,07,12,12,10,09,04,10,10,15,14,11,06,15,05,04,10,10,14,01,00,01,14,15
Description Fixed-width, aligned nicknames theme, shows user addresses in notices
FontChan FixedSys,12
FontDCC FixedSys,12
FontDefault FixedSys,12
FontQuery FixedSys,12
FontScript FixedSys,12
ImageScript
LineSep 00··············15·············14·············
LineSepWhois 1
MTSVersion 1.1
Name Nchalada
Notice <c4>-<nick><c4>(<c3><address><c4>)- <text>
NoticeChan <c4>-<nick><c4>:(<c3><target><c4>)- <text>
NoticeSelf <c4>-><nick><c4>: <text>
NoticeSelfChan <c4>-><target><c4>: <text>
ParenText (<text>)
PnPNickColors 00 11 08 08 09 04 13 14,00 11 08 08 09 04 13 14,15 10 07 07 03 04 06 05,15 10 07 07 03 04 06 05
PnPTheme 1
Prefix 00*15*14*
RGBColors 255,255,255 0,0,0 0,0,127 0,147,0 255,0,0 127,0,0 198,0,198 252,127,0 255,255,0 0,252,0 0,147,147 0,255,255 0,0,252 255,0,255 127,127,127 210,210,210
Scheme1 Alternate nicklist colors 1
Scheme2 Alternate nicklist colors 2
Scheme3 Alternate nicklist colors 3
Script Nchalada.mrc
TextChan !Script %:echo  $+ %::cnick $+ $etheme.npad(%::nick) $+  $+ %::cnick $+ ]: %::text %:comments
TextChanOp <c4>[<nick><c4>:(<c3><target><c4>)] <text>
TextChanSelf !Script %:echo $iif($_optn(0,23), $+ %::cnick $+ $etheme.npad(%::me) $+  $+ %::cnick) $+ ]: %::text %:comments
TextMsg !Script %:echo $iif($event == ACTION,$+(,%::c4,$chr(40),,%::nick,,%::c4,$chr(40),,%::c3,%::address,,%::c4,$chr(41),$chr(41),),$+(,%::c4,[,%::nick,,%::c4,$chr(40),,%::c3,%::address,,%::c4,$chr(41),])) %::text %:comments
TextMsgSelf <c4>-><nick><c4>: <text>
TextQuery !Script %:echo [[ $+ $etheme.npad2(9,%::nick) $+ ]: %::text %:comments
TextQuerySelf !Script %:echo $iif($_optn(0,23),[[ $+ $etheme.npad2(9,%::nick)) $+ ]: %::text %:comments
TextSelfChanOp <c4>-><target><c4>: <text>
TimeStamp ON
TimeStampFormat <c1>-=ddd=-=HH:nn:ss=-
