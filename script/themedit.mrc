; #= P&P -rs
; ########################################
; Peace and Protection
; Theme / scheme editing and related, also some sound scheme
; ########################################

; Make sure nicklist/textscheme options are correct (startup)
alias _upd.texts {
  if ($_cfgi(texts)) .enable #pp-texts
  else .disable #pp-texts
  if ($_cfgi(nickcol)) .enable #pp-nicklist
  else .disable #pp-nicklist
}
on *:SIGNAL:PNP.TRANSLATE:{ _upd.texts }

;
; Some sound schemes
;

on me:*:JOIN:#:_ssplay JoinSelf
on me:*:PART:#:_ssplay PartSelf
on *:KICK:#:_ssplay $iif($knick == $me,KickSelf,Kick) | if ($knick == $me) flash $chr(91) $+ kicked from $chan $+ $chr(93)
on *:OWNER:#:if ($opnick == $me) _ssplay OpSelf
on *:OP:#:if ($opnick == $me) _ssplay OpSelf
on *:HELP:#:if ($hnick == $me) _ssplay OpSelf
on *:VOICE:#:if ($vnick == $me) _ssplay OpSelf
on *:SERVEROP:#:if ($opnick == $me) _ssplay OpSelf
on *:DEOWNER:#:if ($opnick == $me) _ssplay DeopSelf
on *:DEOP:#:if ($opnick == $me) _ssplay DeopSelf
on *:DEHELP:#:if ($hnick == $me) _ssplay DeopSelf
on *:DEVOICE:#:if ($vnick == $me) _ssplay DeopSelf
on *:DISCONNECT:_ssplay $iif($hget(pnp. $+ $cid,quithalt != $null),QuitSelf) Disconnect | hdel pnp. $+ $cid quithalt
on *:FILESENT:*:_ssplay FileSent
on *:FILERCVD:*:_ssplay FileRcvd
on *:SENDFAIL:*:_ssplay GetFail
on *:GETFAIL:*:_ssplay GetFail

;
; Events routing
;
alias route set -u %.chan $1 | _dialog -am evroute evroute
dialog evroute {
  title "Event routing"
  icon script\pnp.ico
  option map
  size -1 -1 231 136

  text "&Event routing for:", 1, 2 6 66 9
  combo 9, 62 3 153 61, drop edit sort

  text "&Joins:", 2, 5 23 33 12
  radio "mIRC setting", 11, 40 23 53 9, group
  radio "Events window", 12, 96 23 66 9
  radio "Don't show", 13, 162 23 66 9

  text "&Parts:", 3, 5 35 33 12
  radio "mIRC setting", 21, 40 35 53 9, group
  radio "Events window", 22, 96 35 66 9
  radio "Don't show", 23, 162 35 66 9

  text "&Quits:", 4, 5 47 33 12
  radio "mIRC setting", 31, 40 47 53 9, group
  radio "Events window", 32, 96 47 66 9
  radio "Don't show", 33, 162 47 66 9

  text "&Kicks:", 5, 5 60 33 12
  radio "mIRC setting", 41, 40 60 53 9, group
  radio "Events window", 42, 96 60 66 9
  radio "Don't show", 43, 162 60 66 9

  text "&Modes:", 6, 5 72 33 12
  radio "mIRC setting", 51, 40 72 53 9, group
  radio "Events window", 52, 96 72 66 9
  radio "Don't show", 53, 162 72 66 9

  text "&Topics:", 7, 5 84 33 12
  radio "mIRC setting", 61, 40 84 53 9, group
  radio "Events window", 62, 96 84 66 9
  radio "Don't show", 63, 162 84 66 9

  text "&Nicks:", 8, 5 97 33 12
  radio "mIRC setting", 71, 40 97 53 9, group
  radio "Events window", 72, 96 97 66 9
  radio "Don't show", 73, 162 97 66 9

  button "Close", 101, 9 115 53 14, cancel default
  button "&Reset", 102, 88 115 53 14
  button "&Help", 103, 168 115 53 14, disable
}
on *:DIALOG:evroute:*:9:_evswitchto
alias -l _evconv if ($_ischan($1-)) return . $+ $1 | return
alias -l _evswitchto {
  tokenize 32 $_evconv($did(9,$did(9).sel))
  var %num = 1
  :loop2
  var %value = $hget(pnp.config,event. $+ $gettok(join part quit kick mode topic nick,%num,32) $+ $1)
  if (%value == $null) %value = $hget(pnp.config,event. $+ $gettok(join part quit kick mode topic nick,%num,32))
  if (%value == hide) %value = 3 | else %value = $iif(%value,2,1)
  did -u $dname %num $+ 3, $+ %num $+ 2, $+ %num $+ 1
  did -c $dname %num $+ %value
  if (%num < 7) { inc %num | goto loop2 }
}
on *:DIALOG:evroute:init:*:{
  var %num = 1
  :loop1
  if ($chan(%num)) {
    did -a $dname 9 $ifmatch
    inc %num
    goto loop1
  }
  window -nlh @.evroute
  filter -fw $_cfg(cfgvar.dat) @.evroute event.*
  %num = $line(@.evroute,0)
  :loop2
  if (%num) {
    var %chan = $gettok($gettok($line(@.evroute,%num),3-,46),1,32)
    if (%chan) {
      _ddadd $dname 9 $ifmatch
      if (%chan == $active) %.chan = $active
    }
    dec %num
    goto loop2
  }
  window -c @.evroute
  did -ac $dname 9 (all channels)
  if ($_ischan(%.chan)) {
    if ($_finddid($dname,9,%.chan)) did -c $dname 9 $ifmatch
    else did -ac $dname 9 %.chan
  }
  unset %.chan
  _evswitchto
}
on *:DIALOG:evroute:sclick:102:{
  var %where = $_evconv($did(9)),%num = 1
  if (%where == $null) {
    :loop1
    `set event. $+ $gettok(join part quit kick mode topic nick,%num,32) $false
    did -u $dname %num $+ 3
    did -u $dname %num $+ 2
    did -c $dname %num $+ 1
    if (%num < 7) { inc %num | goto loop1 }
  }
  else {
    :loop2
    var %name = $gettok(join part quit kick mode topic nick,%num,32)
    var %value = $hget(pnp.config,event. $+ %name)
    `set event. $+ %name $+ %where
    if (%value == hide) %value = 3 | else %value = $iif(%value,2,1)
    did -u $dname %num $+ 3, $+ %num $+ 2, $+ %num $+ 1
    did -c $dname %num $+ %value
    if (%num < 7) { inc %num | goto loop2 }
  }
}
on *:DIALOG:evroute:sclick:*:{
  if ($did isnum 11-73) {
    var %where = $_evconv($did(9)),%value = $gettok($false $true hide,$calc($did % 10),32),%name = $gettok(join part quit kick mode topic nick,$calc($did / 10),32)
    if ((%where != $null) && ($hget(pnp.config,event. $+ %name) == %value)) var %value
    `set event. $+ %name $+ %where %value
  }
}

;
; Font control dialog
;

dialog fontfix {
  title "Font Control"
  icon script\pnp.ico
  option map
  size -1 -1 180 106
  text "PnP can change the fonts of other window types to match your current status window font. Select the window types to update and press Update to do so.", 1, 6 8 180 36
  check "&Channels", 10, 6 42 80 9
  check "&Queries / Chats", 11, 6 55 80 9
  check "&DCC Send / Get", 12, 6 67 80 9
  check "&Notify / URL List", 13, 89 42 80 9
  check "&Other mIRC Windows", 14, 89 55 80 9
  check "&PnP Windows", 15, 89 67 80 9
  button "&Update", 101, 20 85 53 14, OK default
  button "Cancel", 102, 102 85 53 14, cancel
  edit "", 200, 1 1 1 1, autohs hide result
}
on *:DIALOG:fontfix:init:*:did -c $dname 10,11,12,13,14,15
on *:DIALOG:fontfix:sclick:101:did -ra $dname 200 -s $+ $iif($did(10).state,c) $+ $iif($did(11).state,q) $+ $iif($did(12).state,f) $+ $iif($did(13).state,n) $+ $iif($did(14).state,o) $+ $iif($did(15).state,p)
; /fontfix [-cqfnopsb] [fontsize fontname]
; -cqfnops applies to those windows, -b for bold font (if font given)
alias fontfix {
  var %flags,%font
  if (-* iswm $1) { %flags = $1 | %font = $2- }
  else {
    _ssplay Dialog
    %flags = $$dialog(fontfix,fontfix,-4)
    %font = $1-
  }

  ; Grab font?
  if (%font == $null) {
    window -h @.fontgrab
    %font = $window(@.fontgrab).fontsize $window(@.fontgrab).font
    %flags = $remove(%flags,b) $+ $iif($window(@.fontgrab).fontbold,b)
    window -c @.fontgrab
  }

  var %error,%num,%data,%font2
  %font2 = $gettok(%font,2-,32) $+ , $+ $calc($iif(b isin %flags,700,400) + $gettok(%font,1,32))

  saveini
  flushini " $+ $mircini $+ "
  if (s isin %flags) {
    var %scon = $scon(0)
    while (%scon) {
      scon %scon
      %num = 1
      font -s %font
      dec %scon
    }
  }
  if (c isin %flags) {
    var %scon = $scon(0)
    while (%scon) {
      scon %scon
      %num = 1
      while ($chan(%num)) { font $ifmatch %font | inc %num }
      dec %scon
    }
    scon -r
    writeini " $+ $mircini $+ " fonts fchannel %font2
    %num = $read($mircini,tns,[fonts])
    %num = $readn + 1
    :loop2
    %data = $read($mircini,tn,%num)
    if (([* !iswm %data) && (%data)) {
      if ($_ischan($right($gettok(%data,1,61),-1))) write -dl [ $+ [ %num ] ] " $+ $mircini $+ "
      else inc %num
      goto loop2
    }
  }
  if (q isin %flags) {
    var %scon = $scon(0)
    while (%scon) {
      scon %scon
      %num = 1
      while ($query(%num)) { font $ifmatch %font | inc %num }
      dec %scon
    }
    scon -r
    %num = 1
    :loop4
    if ($chat(%num)) { font = $+ $ifmatch %font | inc %num | goto loop4 }
    %num = 1
    :loop5
    if ($fserv(%num)) { font = $+ $ifmatch %font | inc %num | goto loop5 }
    writeini " $+ $mircini $+ " fonts fquery %font2
    writeini " $+ $mircini $+ " fonts fmessage %font2
  }
  if (f isin %flags) {
    writeini " $+ $mircini $+ " fonts fdccs %font2
    writeini " $+ $mircini $+ " fonts fdccg %font2
    if (($send(0)) || ($get(0))) %error = 1
  }
  if (n isin %flags) {
    notify -h
    url hide
    writeini " $+ $mircini $+ " fonts fnotify %font2
    writeini " $+ $mircini $+ " fonts fwwwlist %font2
  }
  if (o isin %flags) {
    writeini " $+ $mircini $+ " fonts flist %font2
    writeini " $+ $mircini $+ " fonts flinks %font2
    writeini " $+ $mircini $+ " fonts ffinger %font2
    if ($line(finger window,0)) font -g %font
  }
  if (p isin %flags) {
    %num = 1
    :loop6
    if ($window(@*,%num)) { if ($hget(pnp.window. $+ $window(@*,%num))) font $window(@*,%num) %font | inc %num | goto loop6 }
    if ($exists($_cfg(window.ini))) filter -ffxc $_cfg(window.ini) $_cfg(window.ini) font=*
  }
  flushini " $+ $mircini $+ "
  if (%error) _error Warning- Could not change open DCCs.Any open DCC windows will not be updated until reopened.
}

