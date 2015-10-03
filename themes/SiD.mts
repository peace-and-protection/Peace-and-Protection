[mts]
; MTS-compatible theme file saved by Peace and Protection 4.22.6 by pai
ActionChan * <nick> <text>
ActionChanSelf * <me> <text>
Author SiD
BaseColors 15,00,07,08
BoldLeft 
BoldRight 
ChannelsLowercase 1
CLineEnemy 08
CLineFriend 11
CLineHOP 14
CLineIrcOP 07
CLineMe 04
CLineOP 14
CLineOwner 14
CLineRegular 00
CLineVoice 15
ColorError 04
Colors 01,06,04,05,05,03,03,03,04,03,03,00,05,07,00,09,03,14,07,05,12,01,09,01,00,00
Description Standard PnP theme/settings
Email sid@donsid.net
FontChan MS Sans Serif,11
FontDCC MS Sans Serif,11
FontDefault MS Sans Serif,11
FontQuery MS Sans Serif,11
FontScript MS Sans Serif,11
ImageScript
LineSep 00··············15·············14·············
LineSepWhois 1
MTSVersion 1.1
Name PnP Black
ParenText (<text>)
PnPLineSep 40 · 00 15 14
PnPNickColors 00 11 08 12 07 04 13 14,15 11 08 12 07 04 13 14,14 11 08 12 07 04 06 05,14 11 08 12 07 04 06 05
PnPTheme 1
Prefix 00*15*14*
RGBColors 255,255,255 0,0,0 0,0,127 0,147,0 255,0,0 127,0,0 156,0,156 252,127,0 255,255,0 0,252,0 0,147,147 0,255,255 0,0,252 255,0,255 127,127,127 210,210,210
TextChan <cnick>(<cmode><nick><cnick>): <text>
TextChanSelf !Script %:echo $iif($_optn(0,23),$+(,%::cnick,$chr(40),,%::cmode,%::me,,%::cnick,$chr(41),:),:) %::text %:comments
TextQuery (<nick>): <text>
TextQuerySelf !Script %:echo $iif($_optn(0,23),$+(,$chr(40),,%::me,,$chr(41),:),:) %::text %:comments
TimeStamp ON
TimeStampFormat <c1>[HH:nn:ss]
