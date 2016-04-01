[mts]
; MTS-compatible theme file saved by Peace and Protection 4.22.6 by pai
ActionChan * <nick> <text>
ActionChanSelf * <me> <text>
Author acvxqs
BaseColors 15,00,04,08
BoldLeft 
BoldRight 
ChannelsLowercase 1
CLineEnemy 02
CLineFriend 05
CLineHOP 14
CLineIrcOP 06
CLineMe 08
CLineOP 14
CLineOwner 14
CLineRegular 15
CLineVoice 15
ColorError 05
Colors 01,15,14,15,14,14,14,09,14,12,14,00,15,15,00,15,06,04,14,14,14,01,15,01,04,14
Description Based off the colour palette dusk-red by slanne (nbs-irc)
FontChan Consolas,12
FontDCC Consolas,12
FontDefault Consolas,12
FontQuery Consolas,12
FontScript Consolas,12
ImageScript
LineSep 14········04········05········04········14········
LineSepWhois 1
MTSVersion 1.1
Name PnP dusk
ParenText (<text>)
PnPLineSep 40 · 14 04 05 04 14
PnPNickColors 15 05 02 02 06 08 10 03,15 05 02 02 06 08 10 03,14 04 12 12 13 07 11 09,14 04 12 12 13 07 11 09
PnPTheme 1
Prefix 15ˣˣˣ
RGBColors 255,255,255 25,25,25 0,75,176 36,134,63 228,62,52 172,22,22 129,93,129 255,157,0 255,193,10 129,193,129 0,147,147 0,207,255 0,108,255 255,0,255 133,133,133 200,200,200
SndOpen qry.wav
TextChan <cnick>(<cmode><nick><cnick>): <text>
TextChanSelf !Script %:echo $iif($_optn(0,23),$+(,%::cnick,$chr(40),,%::cmode,%::me,,%::cnick,$chr(41),:),:) %::text %:comments
TextQuery (<nick>): <text>
TextQuerySelf !Script %:echo $iif($_optn(0,23),$+(,$chr(40),,%::me,,$chr(41),:),:) %::text %:comments
TimeStamp ON
TimeStampFormat <c1>[HH:nn]
