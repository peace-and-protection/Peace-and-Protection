; #= P&P -rs
; ########################################
; Peace and Protection
; Dialog support code (for extra stuff not built-in
; to mIRC's dialogs)
; ########################################
 
;
; Drive search selection (returns space-delimited c:\ d:\ etc)
; Use $_drivesearch(1) to include removable media
;
alias _drivesearch set %.dsparm $1 | _ssplay Question | return $dialog(drivesearch,drivesearch,-4)
dialog drivesearch {
title "Drive Search"
  icon script\pnp.ico
  option dbu
  size -1 -1 108 91
text "&Select one or more drives to search:", 1, 2 2 100 8
  list 2, 4 12 50 75, extsel sort
button "&Select", 3, 58 40 45 12, default ok
  edit "", 4, 1 1 1 1, hide autohs result
}
on *:DIALOG:drivesearch:init:*:{
  if (%.dsparm) var %types = fixed,cdrom,removable
  else var %types = fixed
  unset %.dsparm
  var %asc = 65
  :loop
  if ($istok(%types,$disk($chr(%asc)).type,44)) did -a $+ $iif(%asc == 67,c) $dname 2 $chr(%asc) $+ :\
  if (%asc < 90) { inc %asc | goto loop }
  if ($did(2).lines == 1) dialog -k $dname
}
on *:DIALOG:drivesearch:dclick:2:dialog -k $dname
on *:DIALOG:drivesearch:sclick:3:{
  var %ret,%num = 1
  :loop
  if ($did(2,$did(2,%num).sel)) {
    %ret = $addtok(%ret,$ifmatch,32)
    inc %num | goto loop
  }
  did -o $dname 4 1 %ret
}
 
;
; Color selector
;
 
; call /_cs-prep $dname when dialog opens
; call /_cs-fin $dname when dialog closes
; call /_cs-go xsize ysize allownone when a color is clicked on
; colors are stored in hash pnp.dlgcolor.$dname item is dialog id
; (color of 16 = none)
 
alias _cs-prep {
  var %col = 0
  window -pfhn +d @.csbmp -1 -1 16 16
  while (%col < 16) {
    drawrect -f @.csbmp %col 2 0 0 16 16
    drawsave @.csbmp script\ $+ %col $+ .bmp
    inc %col
  }
  window -c @.csbmp
  if ($hget(pnp.dlgcolor. $+ $1) == $null) hmake pnp.dlgcolor. $+ $1 20
}
alias _cs-fin window -c @Ç | hfree pnp.dlgcolor. $+ $1
alias _cs-go {
  if ($window(@Ç).state == hidden) {
    window -f @Ç $calc($mouse.dx - 5) $calc($mouse.dy - 5) $calc($1 * 4 + 8) $calc($2 * 4 + 8 + $iif($3,$calc($2 + 2),0))
  }
  else {
    window -c @Ç
    window -fphkdBz +fL @Ç $calc($mouse.dx - 5) $calc($mouse.dy - 5) $calc($1 * 4 + 8) $calc($2 * 4 + 8 + $iif($3,$calc($2 + 2),0)) @colpck
  }
  drawrect -nfr @Ç $rgb(face) 2 0 0 200 200
  var %x,%y = 0,%col = 0
  :loopy | %x = 0 | :loopx
  drawrect -nf @Ç %col 2 $calc(%x * ($1 + 2) + 1) $calc(%y * ($2 + 2) + 1) $1 $2
  inc %col
  if (%x < 3) { inc %x | goto loopx }
  if (%y < 3) { inc %y | goto loopy }
if ($3) drawtext -nr @Ç $rgb(text) "ms sans serif" 12 $int($calc(2 * $1 + 4 - $width(No color,ms sans serif,12,0,0) / 2)) $int($calc(4.5 * $2 + 10 - $height(No color,ms sans serif,12) / 2)) No color
  drawdot @Ç
  window -a @Ç
  titlebar @Ç $calc($1 + 2) $calc($2 + 2)
  hadd pnp colordlg $dname $did
  hadd pnp colorwait 2
}
menu @colpck {
  mouse:if ($hget(pnp,colorwait)) hdec pnp colorwait | _mcp $leftwin $mouse.x $mouse.y $window($leftwin).title
  uclick:if (!$hget(pnp,colorwait)) _mcc $leftwin $window($leftwin).title
  leave:_mcp $leftwin -1 -1 $window($leftwin).title
}
alias -l _mcc {
  if ($5 == 4) var %bit = 16
  else var %bit = $calc($4 + $5 * 4)
  hadd pnp.dlgcolor. $+ $gettok($hget(pnp,colordlg),1,32) $gettok($hget(pnp,colordlg),2,32) %bit
  dialog -v $gettok($gettok($hget(pnp,colordlg),1,32),1,32)
  did -g $hget(pnp,colordlg) script\ $+ %bit $+ .bmp
  hdel pnp colorwait
  hdel pnp colordlg
  window -h $1
}
alias -l _mcp {
  var %x = $int($calc($2 / $4)),%y = $int($calc($3 / $5))
  if (%y == 4) %x = 0
  if ($6 $7 != %x %y) {
    if ($6 != $null) {
      if ($7 == 4) drawrect -nr $1 $rgb(face) 2 $calc($6 * $4 - 1) $calc($7 * $5 - 1) $calc($4 * 4 + 2) $calc($5 + 2)
      else drawrect -nr $1 $rgb(face) 2 $calc($6 * $4 - 1) $calc($7 * $5 - 1) $calc($4 + 2) $calc($5 + 2)
    }
    if ($2 >= 0) {
      if (%y == 4) {
        drawline -nr $1 $rgb(hilight) 1 0 $calc(%y * $5 + $5 - 1) $calc($4 * 4 - 1) $calc(%y * $5 + $5 - 1) $calc($4 * 4 - 1) $calc(%y * $5 - 1)
        drawline -nr $1 $rgb(shadow) 1 0 $calc(%y * $5 + $5 - 1) 0 $calc(%y * $5) $calc($4 * 4 - 1) $calc(%y * $5)
      }
      else {
        drawline -nr $1 $rgb(hilight) 1 $calc(%x * $4) $calc(%y * $5 + $5 - 1) $calc(%x * $4 + $4 - 1) $calc(%y * $5 + $5 - 1) $calc(%x * $4 + $4 - 1) $calc(%y * $5 - 1)
        drawline -nr $1 $rgb(shadow) 1 $calc(%x * $4) $calc(%y * $5 + $5 - 1) $calc(%x * $4) $calc(%y * $5) $calc(%x * $4 + $4 - 1) $calc(%y * $5)
      }
      titlebar $1 $4-5 %x %y
    }
    else titlebar $1 $4-5
    drawdot $1
  }
}
 
; Converts font n [bold] between mirc and windows sizes
; mirc -> windows- * 3/4
; windows -> mirc- * 4/3
 
alias _font_m2w {
  var %font = $1-
  var %tok = $iif($gettok(%font,-1,32) == bold,-2,-1)
  return $puttok(%font,$round($calc($gettok(%font,%tok,32) * 3 / 4),0),%tok,32)
}
alias _font_w2m {
  var %font = $1-
  var %tok = $iif($gettok(%font,-1,32) == bold,-2,-1)
  return $puttok(%font,$round($calc($gettok(%font,%tok,32) * 4 / 3),0),%tok,32)
}
 
;
; Font picker- $_pickfont(old)
; returns font size [bold]
; old is optional (same format) but if specified will be returned even if cancel is pressed
;
 
alias _pickfont {
  window -pfh +d @.pickfont 50 50 1 1 cancel 13
  if ($1) {
    var %bold = $gettok($1-,-1,32)
    var %rest = $1-
    if (%bold == bold) {
      %bold = -b
      %rest = $deltok($1-,-1,32)
    }
    else %bold =
    font %bold @.pickfont $gettok(%rest,-1,32) $deltok(%rest,-1,32)
  }
  window -a @.pickfont | font
  if ($window(@.pickfont).font == cancel) { window -c @.pickfont | return }
  var %font = $window(@.pickfont).font $window(@.pickfont).fontsize $iif($window(@.pickfont).fontbold,bold)
  window -c @.pickfont | return %font
}
 
;
; Generic entry
;
; $_entry(type,defaultvalue,question[,checkvalue,checkbox])
; default value is $_s2p and $null/%emptyvar works
; question can contain a  to be two lines
; type = 0 only accept data 1 blank is ok 2 return cancel as blank too
; type = -1 to require data and only return one word
; type = -2 to require data be a number
; If present, a checkbox (checked if checkvalue is true) is present
; and it's value is set -u into %.entry.checkbox
;
dialog entry {
title "PnP Entry"
  icon script\pnp.ico
  option dbu
  size -1 -1 175 60
 
  text "", 202, 7 8 142 14
  text "", 203, 7 5 142 10, hide
  text "", 204, 7 12 142 10, hide
 
  edit %.entry.ans, 1, 5 22 165 11, result autohs
  check %.entry.checkbox, 2, 5 35 165 11, hide
 
  icon 11, 151 3 16 16, script\pnp.ico
 
button "OK", 101, 40 43 40 12, OK default
button "Cancel", 102, 95 43 40 12, cancel
}
dialog entrycheck {
title "PnP Entry"
  icon script\pnp.ico
  option dbu
  size -1 -1 175 68
 
  text "", 202, 7 8 142 14
  text "", 203, 7 5 142 10, hide
  text "", 204, 7 12 142 10, hide
 
  edit %.entry.ans, 1, 5 22 165 11, result autohs
  check "", 2, 5 35 165 11
 
  icon 11, 151 3 16 16, script\pnp.ico
 
button "OK", 101, 40 51 40 12, OK default
button "Cancel", 102, 95 51 40 12, cancel
}
on *:DIALOG:entry:init:*:{
  if (%.entry.q2) {
    did -h $dname 202
    did -va $dname 203 & $+ $replace(%.entry.q,&,&&)
    did -va $dname 204 $replace(%.entry.q2,&,&&)
  }
  else did -a $dname 202 & $+ $replace(%.entry.q,&,&&)
  if (%.entry.checkbox) did -a $dname 2 %.entry.checkbox
  if (%.entry.checkboxvalue) did -c $dname 2
  unset %.entry.q %.entry.q2 %.entry.checkbox %.entry.checkboxvalue
  _ssplay Question
}
on *:DIALOG:entry:sclick:101:{ set -u1 %.entry.o 1 | set -u1 %.entry.checkbox $did(2).state }
on *:DIALOG:entry:sclick:102:{ set -u1 %.entry.checkbox $did(2).state }
alias _entry {
  unset %.entry.o
  var %type = $1
  %.entry.ans = $_p2s($2)
  %.entry.q2 = $gettok($3,2,127)
  :retry
  %.entry.q = $gettok($3,1,127)
  if ($5) {
    %.entry.checkbox = & $+ $replace($5,&,&&)
    %.entry.checkboxvalue = $4
    set -u1 %.entry.ans $dialog(entry,entrycheck,-4)
  }
  else {
    set -u1 %.entry.ans $dialog(entry,entry,-4)
  }
  if ((%type <= 0) && (%.entry.ans == $null)) $$$
  if (%type < 0) %.entry.ans = $gettok(%.entry.ans,1,32)
if ((%type == -2) && (%.entry.ans !isnum)) { %.entry.q2 = (please enter a number) | goto retry }
  if (%.entry.o) return %.entry.ans
  if (%type == 2) return
  $$$
}
 
;
; Entry based off of a 'recents' list
;
; $_rentry(type,code,defaultvalue,question)
; default value is $_s2p and $null/%emptyvar works (will then use top list of recents)
; question can contain a  to be two lines
; type = recents list name (don't include .lis extension) (as far as entry goes, something must be entered or all is canceled)
; type = # for a list of all open channels (on all CIDs)
; code = 0 for normal .lis, #chan for &chan& replacement .lis
;
dialog rentry {
title "PnP Entry"
  icon script\pnp.ico
  option dbu
  size -1 -1 175 60
 
  text "", 202, 7 8 142 14
  text "", 203, 7 5 142 10, hide
  text "", 204, 7 12 142 10, hide
 
  combo 1, 5 22 165 80, drop result edit
 
  icon 11, 151 3 16 16, script\pnp.ico
 
  edit %.entry.t, 100, 1 1 1 1, autohs hide
 
button "OK", 101, 15 43 40 12, OK default
button "Cancel", 102, 70 43 40 12, cancel
button "&Clear list", 103, 135 44 35 10, disable
}
; fills drop down with recents (bdid = clear button to enable if recents; chan = false if n/a)
; /_fillrec dname did bdid file chan [current]
alias _fillrec {
  if ($exists($4)) {
    if ($3) did -e $1 $3
    if ($_ischan($5)) {
      var %num = 1
      :loop1
      if ($read($4,nt,%num) != $null) { if ($replace($ifmatch,&chan&,$5) != $6-) did -a $1 $2 $ifmatch | inc %num | goto loop1 }
    }
    else {
      if ($6- == $null) loadbuf -o $1 $2 $4
      else filter -fox $4 $1 $2 $6-
    }
  }
  if ($6 != $null) did -ic $1 $2 1 $6-
  else did -c $1 $2 1
}
on *:DIALOG:rentry:init:*:{
  if (%.entry.t == $chr(35)) {
    var %scon = 1
    while ($scon(%scon)) {
      scon %scon
      var %chan = 1
      while ($chan(%chan)) {
        did -a $+ $iif($chan(%chan) == %.entry.a,c) $dname 1 $chan(%chan)
        inc %chan
      }
      inc %scon
    }
    scon -r
    if (($did($dname,1).lines > 0) && ($did($dname,1).sel == $null)) did -c $dname 1 1
  }
  else _fillrec $dname 1 103 %.entry.t %.entry.c %.entry.a
  if (%.entry.q2) {
    did -h $dname 202
    did -va $dname 203 & $+ $replace(%.entry.q,&,&&)
    did -va $dname 204 $replace(%.entry.q2,&,&&)
  }
  else did -a $dname 202 & $+ $replace(%.entry.q,&,&&)
  unset %.entry.t %.entry.c %.entry.a %.entry.q %.entry.q2
  _ssplay Question
}
on *:DIALOG:rentry:sclick:103:{
  did -b $dname 103
  .remove $did(100)
  :loop | if ($did(1,1) != $null) { did -d $dname 1 1 | goto loop }
}
alias _rentry {
  ; if we ever add .rct support, erasure button has to handle this proplerly
  if ($1 == $chr(35)) set %.entry.t $chr(35)
  else set %.entry.t $_cfg($1.lis)
  set %.entry.c $2
  set %.entry.a $_p2s($3)
  set %.entry.q $gettok($4-,1,127)
  set %.entry.q2 $gettok($4-,2,127)
  return $$dialog(rentry,rentry,-4)
}
 
;
; Generic buttons
;
 
; $_yesno(x,prompt)
; x = 0 for no default 1 for yes default
; returns 1/0
alias _yesno {
  set %.yesno $1-
  return $$dialog(yesno,yesno,-4)
}
dialog yesno {
title "PnP Entry"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 34
 
  edit "", 202, 1 1 1 1, hide result autohs
  text "", 201, 7 4 150 14
 
  icon 11, 162 1 16 16, script\check1.ico
  icon 12, 178 1 16 16, script\check2.ico
  icon 13, 162 17 16 16, script\check3.ico
  icon 14, 178 17 16 16, script\check4.ico
 
button "&Yes", 101, 6 20 40 12, OK
button "&No", 102, 56 20 40 12
button "Cancel", 103, 106 20 40 12, cancel
}
on *:DIALOG:yesno:init:*:{
  did -a $dname 201 $replace($gettok(%.yesno,2-,32),&,&&)
  if ($gettok(%.yesno,1,32)) did -ft $dname 101
  else did -ft $dname 102
  unset %.yesno
  _ssplay Confirm
}
on *:DIALOG:yesno:sclick:101:if ($did(202) == $null) did -a $dname 202 1
on *:DIALOG:yesno:sclick:102:did -a $dname 202 0 | dialog -k $dname
 
; $_okcancel(x,prompt) or _okcancel x prompt
; x = 0 for cancel default 1 for ok default
; returns 1 or halts
; x & 2 to return 1 or 0. (no halt)
alias _okcancel {
  set %.okcancel $1-
  var %result = $dialog(okcancel,okcancel,-4)
  unset %.okcancel
  if (!%result) {
    if ($1 & 2) %result = 0
    else halt
  }
  return %result
}
dialog okcancel {
title "PnP Confirm"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 34
 
  edit "1", 202, 1 1 1 1, hide result autohs
  text "", 201, 7 4 150 14
 
  icon 11, 162 1 16 16, script\check1.ico
  icon 12, 178 1 16 16, script\check2.ico
  icon 13, 162 17 16 16, script\check3.ico
  icon 14, 178 17 16 16, script\check4.ico
 
button "OK", 101, 6 20 40 12, OK
button "Cancel", 102, 56 20 40 12, cancel
}
on *:DIALOG:okcancel:init:*:{
  did -a $dname 201 $replace($gettok(%.okcancel,2-,32),&,&&)
  if ($gettok(%.okcancel,1,32) & 1) did -ft $dname 101
  else did -ft $dname 102
  _ssplay Confirm
}
 
; $_okcancelcheck(x,prompt,value,checkbox)
; x = 0 for cancel default 1 for ok default
; returns 1 or 0. state of check in %.okcheck
alias _okcancelcheck {
  set %.okcancel $1-2
  set %.okcheck $3-4
  var %result = $dialog(okcancelcheck,okcancelcheck,-4)
  unset %.okcancel
  set -u %.okcheck %.okcheck
  if (!%result) %result = 0
  return %result
}
dialog okcancelcheck {
title "PnP Confirm"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 44
 
  edit "1", 202, 1 1 1 1, hide result autohs
  text "", 201, 7 4 150 14
  check "", 203, 7 19 150 8
 
  icon 11, 162 1 16 16, script\check1.ico
  icon 12, 178 1 16 16, script\check2.ico
  icon 13, 162 17 16 16, script\check3.ico
  icon 14, 178 17 16 16, script\check4.ico
 
button "OK", 101, 6 30 40 12, OK
button "Cancel", 102, 56 30 40 12, cancel
}
on *:DIALOG:okcancelcheck:init:*:{
  did -a $dname 201 $replace($gettok(%.okcancel,2-,32),&,&&)
  did -a $dname 203 & $+ $replace($gettok(%.okcheck,2-,32),&,&&)
  if ($gettok(%.okcancel,1,32) & 1) did -ft $dname 101
  else did -ft $dname 102
  if ($gettok(%.okcheck,1,32)) did -c $dname 203
  set %.okcheck $did(203).state
  _ssplay Confirm
}
on *:DIALOG:okcancelcheck:sclick:203:set %.okcheck $did(203).state
 
; $_fileopt(x,file) or _fileopt x file
; x = 0 for normal 1 to allow append 2 to make append the default
; returns 1/0 (overwrite/append) halts on cancel
; if overwrite is selected, file is automatically cleared
alias _fileopt {
  set %.fileopt $1-
  return $$dialog(fileopt,fileopt,-4)
}
dialog fileopt {
title "File Exists"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 34
 
  edit "", 203, 1 1 1 1, hide autohs
  edit "", 202, 1 1 1 1, hide result autohs
  text "", 201, 7 4 150 14
 
  icon 11, 162 1 16 16, script\file1.ico
  icon 12, 178 1 16 16, script\file2.ico
  icon 13, 162 17 16 16, script\file3.ico
  icon 14, 178 17 16 16, script\file4.ico
 
button "&Overwrite", 101, 6 20 40 12, OK
button "&Append", 102, 56 20 40 12, disable
button "Cancel", 103, 106 20 40 12, cancel
}
on *:DIALOG:fileopt:init:*:{
  did -a $dname 203 $gettok(%.fileopt,2-,32)
did -a $dname 201 File ' $+ $replace($gettok(%.fileopt,2-,32),&,&&) $+ ' already exists $+ :
  if ($gettok(%.fileopt,1,32)) {
    did -e $dname 102
    if ($ifmatch == 2) did -ft $dname 102
    else did -ft $dname 101
  }
  else did -ft $dname 101
  unset %.fileopt
  _ssplay Confirm
}
on *:DIALOG:fileopt:sclick:101:if ($did(202) == $null) { did -a $dname 202 1 | .remove -b " $+ $did(203) $+ " }
on *:DIALOG:fileopt:sclick:102:did -a $dname 202 0 | dialog -k $dname
 
;
; Quick-pick popup
;
; _qp-go xsize cmd word1 2 3 etc
alias _qp-go {
  .timer.qpickfin off
  window -c @¶
  var %x = $calc($mouse.dx - ($1 / 2))
  var %y = $calc($mouse.dy - 1)
  var %ys = $calc($numtok($3-,32) * 20)
  window -fphkdonBz +fL @¶ %x %y $1 %ys @quikpck
  if ($window(@¶).dy < %y) window -f @¶ %x $calc(%y - %ys - 3) $1 %ys
  drawrect -nfr @¶ $rgb(face) 2 0 0 $1 200
  var %text,%y = 0 | :loopy
  %text = $_p2s($gettok($3-,$calc(%y + 1),32))
  if ($left(%text,1) isin 01) {
    hadd pnp qpick. $+ %y $ifmatch
    drawrect -nr @¶ $rgb(hilight) 1 4 $calc(20 * %y + 4) 12 12
    drawline -nr @¶ $rgb(shadow) 1 4 $calc(20 * %y + 15) 4 $calc(20 * %y + 4) 15 $calc(20 * %y + 4)
    if ($left(%text,1) == 1) drawtext -nro @¶ $rgb(text) arial 18 5 $calc(20 * %y - 1) ×
    %text = $right(%text,-1)
  }
  drawtext -nr @¶ $rgb(text) "ms sans serif" 12 24 $calc(%y * 20 + 3) %text
  inc %y | if (%y < $numtok($3-,32)) goto loopy
  hadd pnp qpick.cmd $2
  %.skipit = 1
  .timer -mio 1 0 unset % $+ .skipit
  drawdot @¶
  window -a @¶
}
on *:ACTIVE:*:if ($lactive == @¶) _qp-fin @¶
on *:APPACTIVE:if ($appactive == $false) _qp-fin @¶
alias _qp-fin {
  var %do = $_p2s($hget(pnp,qpick.cmd)) $2
  hdel pnp qpick.cmd
  window -c @¶
  .timer.qpickfin -mio 1 0 hdel -w pnp qpick.*
  %do
}
menu @quikpck {
  sclick:_qcp $leftwin $mouse.x $mouse.y $mouse.key $window($leftwin).dw $window($leftwin).title
  mouse:if (%.skipit) return | _qcp $leftwin $mouse.x $mouse.y $mouse.key $window($leftwin).dw $window($leftwin).title
  dclick:_qcp $leftwin $mouse.x $mouse.y $mouse.key $window($leftwin).dw $window($leftwin).title
  uclick:{
    if ($numtok($window($leftwin).title,32) < 1) return
    _qcp $leftwin $mouse.x $mouse.y $mouse.key $window($leftwin).dw $window($leftwin).title
    if ($hget(pnp,qpick. $+ $result) isnum) {
      hadd pnp qpick. $+ $result $calc(1 - $ifmatch)
      if ($ifmatch) drawrect -fr $leftwin $rgb(face) 2 5 $calc(20 * $result + 5) 10 10
      else drawtext -ro $leftwin $rgb(text) arial 18 5 $calc(20 * $result - 1) ×
    }
    else _qp-fin $leftwin $gettok($window($leftwin).title,1,32)
  }
  leave:_qcp $leftwin -20 -20 $mouse.key $window($leftwin).dw $window($leftwin).title
}
alias -l _qcp {
  var %y = $int($calc($3 / 20))
  if (($6 != %y) || ($4 != $7)) {
    if ($6 != $null) {
      if ($7 & 1) {
        if ($hget(pnp,qpick. $+ $6) isnum) {
          drawrect -nr $1 $rgb(hilight) 1 4 $calc(20 * $6 + 4) 12 12
          drawline -nr $1 $rgb(shadow) 1 4 $calc(20 * $6 + 15) 4 $calc(20 * $6 + 4) 15 $calc(20 * $6 + 4)
        }
        drawscroll -n $1 -1 -1 16 $calc(20 * $6 + 1) $calc($5 - 17) 18
      }
      drawrect -nr $1 $rgb(face) 1 0 $calc(20 * $6) $5 20
    }
    if ($2 >= 0) {
      if ($4 & 1) {
        if ($hget(pnp,qpick. $+ %y) isnum) drawrect -nr $1 $rgb(face) 1 4 $calc(20 * %y + 4) 12 12
        drawscroll -n $1 1 1 16 $calc(20 * %y + 1) $calc($5 - 17) 18
      }
      drawrect -nr $1 $rgb($iif($4 & 1,hilight,shadow)) 1 0 $calc(20 * %y) $5 20
      drawline -nr $1 $rgb($iif($4 & 1,shadow,hilight)) 1 0 $calc(20 * %y + 19) 0 $calc(20 * %y) $calc($5 - 1) $calc(20 * %y)
      titlebar $1 %y $4
    }
    else titlebar $1
    drawdot $1
  }
  return %y
}
alias _doubleclick {
  if ($2-3 == Message Window) tokenize 32 $1 MessageWindow $3-
var %popups = $gettok(JoinFavs ListUsers PortScan Reconnect Usermode!Whois DCCChat Ping Clear!Ping ChanCentral Banlist EditTopic Clear!Whois Query DCCChat QuickKick QuickBan!Whois Query DCCChat Ping,$1,33)
  if ($_cfgi(dc. $+ $1) isnum) {
if (($mouse.key & 2) || ($mouse.key & 4)) _qp-go 104 _doubleclick² $+ $1 $+ $2 $+ $3 %popups 1Selectdefault
    else _doubleclick² $1 $2 $3 $_cfgi(dc. $+ $1) 1
  }
else _qp-go 104 _doubleclick² $+ $1 $+ $2 $+ $3 %popups 0Selectdefault
}
alias _doubleclick² {
  if ($4 == $null) return
  if (($1 == 2) || ($1 == 5)) var %bit = 4
  else var %bit = 5
  if ($hget(pnp,qpick. $+ %bit) == 1) {
var %popups = $gettok(JoinFavs ListUsers PortScan Reconnect Usermode!Whois DCCChat Ping Clear!Ping ChanCentral Banlist EditTopic Clear!Whois Query DCCChat QuickKick QuickBan!Whois Query DCCChat Ping,$1,33)
var %area = $gettok(statusquerychannelnicklistnotify,$1,127)
_okcancel 1 Set the default %area double-click action to ' $+ $_p2s($gettok(%popups,$calc($4 + 1),32)) $+ '?
    _cfgw dc. $+ $1 $4
    if ($_dlgi(undefault) != 1) {
      _ssplay Confirm
      if ($dialog(howundefault,howundefault,-4)) _dlgw undefault 1
    }
    return
  }
  if ($hget(pnp,qpick. $+ %bit) == 0) _cfgw dc. $+ $1
  goto $1 $+ $4
  :20 | :40 | :50 | whois $3 | return
  :41 | :51 | query $3 | return
  :21 | :42 | :52 | dcc chat $3 | return
  :43 | kick $2 $3 | return
  :44 | cb $2 $3 | return
  :22 | :30 | :53 | if (=* iswm $2) dcp $3 | else ping $3 | return
  :31 | channel $3 | return
  :32 | ban $3 | return
  :33 | etopic $3 | return
  :23 | :34 | if (=* iswm $2) clear Chat $3 | else clear $3 | return
  :10 | fav j | return
  :11 | lusers | return
  :12 | ports | return
  :13 | server | return
  :14 | umode | return
}
dialog howundefault {
title "Setting Double-click Default"
  icon script\pnp.ico
  option dbu
  size -1 -1 125 62
text "To change the default action in the future, hold down the 'Ctrl' key while double-clicking.", 3, 5 5 115 50
check "&Don't show this message again", 2, 20 30 100 10
button "OK", 1, 42 45 40 12, ok default
  edit "", 4, 1 1 1 1, hide autohs result
}
on *:DIALOG:howundefault:sclick:1:did -o $dname 4 1 $did(2).state
 
; Convienience commands
 
; _bulkdid op dname first last [params]
; like a /did op dname first-last [params] ie on multiples
alias _bulkdid var %num = $3 | :loop | did $1-2 %num $5- | if (%num < $4) { inc %num | goto loop }
 
; Add to dropdown without duplication
; _ddadd dname did item
alias _ddadd {
  var %num = $did($1,$2).lines
  :loop
  if (%num) {
    if ($3- === $did($1,$2,%num)) return
    dec %num | goto loop
  }
  did -a $1-
}
; _ddaddm dname did addr mask1 mask2...
; (for multiple masks of same addr) uses usermask settings
alias _ddaddm {
  var %num = 4
  :loop
  if ($ [ $+ [ %num ] ] ) { _ddadd $1-2 $_ppmask($3,$_stmask($ifmatch)) | inc %num | goto loop }
}
 
; finds a line in a dialog listbox where the first (space) token matches
; returns line number or 0; $_finddid(dname,did,text)
alias _finddid {
  var %num = $did($1,$2).lines
  :loop
  if ($gettok($did($1,$2,%num),1,32) == $3) return %num
  if (%num > 1) { dec %num | goto loop }
  return 0
}
 
; finds a line in a dialog listbox matching exactly
; returns line number or 0; $_scandid(dname,did,text)
alias _scandid {
  var %num = $did($1,$2).lines
  :loop
  if ($did($1,$2,%num) == $3) return %num
  if (%num > 1) { dec %num | goto loop }
  return 0
}
 
; if dialog is already open, makes it active, else opens it
alias _dialog if ($dialog($2)) dialog -v $2 | else { _ssplay Dialog | dialog $1- }
