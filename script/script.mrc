; #= P&P -rs
; **********************
; Unsorted routines
; **********************

;;;###*** Not yet divided ***###;;;

; titlebar and other things that change on active window
on *:ACTIVE:*:{
  _upd.title
  hadd pnp. $+ $cid timedclose $remtok($hget(pnp. $+ $cid,timedclose),$active,1,32)
  if (($query($active)) || ($active ischan) || ($active == Status Window)) window -w " $+ $active $+ "
  elseif ((=* iswm $active) || ($hget(pnp.window. $+ $active))) window -w $active
}
on *:APPACTIVE:{
  if (($appactive) && ($hget(pnp,in.flash))) { hdel pnp in.flash | _upd.title }
}

; $modeto(from,to)
; returns +- to go from one mode to the other
alias modeto {
  var %remove,%add
  var %pos = 1
  while (%pos <= $len($1)) {
    if ($mid($1,%pos,1) !isincs $2) %remove = %remove $+ $ifmatch
    inc %pos
  }
  %pos = 1
  while (%pos <= $len($2)) {
    if ($mid($2,%pos,1) !isincs $1) %add = %add $+ $ifmatch
    inc %pos
  }
  return $iif(%remove,- $+ %remove) $+ $iif(%add,+ $+ %add)
}

; umode (to view/edit)
; umode +/- (normal changes)
; umode * mode (to set to exactly those modes)
alias umode {
  if ($1 == *) {
    if ($modeto($remove($usermode,+),$remove($2,+))) .raw mode $me $ifmatch
  }
  elseif ($1) .raw mode $me $1-
  else _dialog -am usermode usermode
}

dialog usermode {
  title "Usermodes"
  icon script\pnp.ico
  option map
  size -1 -1 243 98

  box "&Current", 1, 6 6 40 63
  check "+&i", 11, 13 18 24 9
  check "+&s", 12, 13 29 24 9
  check "+&w", 13, 13 40 24 9
  edit "", 14, 13 51 26 13, autohs

  box "&Default", 2, 53 6 40 63
  check "+&i", 21, 60 18 24 9
  check "+&s", 22, 60 29 24 9
  check "+&w", 23, 60 40 24 9
  edit "", 24, 60 51 26 13, autohs

  box "&Away", 3, 100 6 40 63
  check "+&i", 31, 106 18 24 9
  check "+&s", 32, 106 29 24 9
  check "+&w", 33, 106 40 24 9
  edit "", 34, 106 51 26 13, autohs

  text "(invisible)", 4, 146 18 80 12
  text "(server notices)", 5, 146 29 80 12
  text "(wallops)", 6, 146 40 80 12
  text "(other)", 7, 146 54 80 12

  button "&Filters...", 104, 200 27 36 12
  button "&Filters...", 105, 200 40 36 12

  button "OK", 101, 33 77 53 14, OK default
  button "Cancel", 102, 93 77 53 14, cancel
  button "&Help", 103, 153 77 53 14, disable

  edit $cid, 200, 1 1 1 1, hide autohs
}
on *:DIALOG:usermode:init:*:{
  if ($server == $null) did -b $dname 11,12,13,14
  else _umsplit 1 $usermode
  _umsplit 2 $_cfgi(umode)
  _umsplit 3 $_cfgi(uaway)
}
alias -l _umsplit {
  if (i isincs $2) did -c $dname $1 $+ 1
  if (s isincs $2) did -c $dname $1 $+ 2
  if (w isincs $2) did -c $dname $1 $+ 3
  did -o $dname $1 $+ 4 1 $removecs($2,i,s,w,+)
}
on *:DIALOG:usermode:sclick:101:{
  if ($scid($did(200))) {
    scid $did(200)
    if ($server) umode * $_ummerge(10)
    scid -r
  }
  _cfgw umode $_ummerge(20)
  _cfgw uaway $_ummerge(30)
}
on *:DIALOG:usermode:sclick:104:config 10
on *:DIALOG:usermode:sclick:105:config 12
alias -l _ummerge return $iif($did($calc($1 + 1)).state,i) $+ $iif($did($calc($1 + 2)).state,s) $+ $iif($did($calc($1 + 3)).state,w) $+ $did($calc($1 + 4))

; Temp - May expand/replace later
on me:^*:JOIN:#:{
  ; (highlight on join)
  window -g1 " $+ $chan $+ "
  repjoin -r $chan
  if ($ial) if ($chan($chan).inwho == $false) _linedance _who.queue $chan hide
  if ($_cfgi(fill.chan)) _recent chan $_cfgi(num.chan) 0 $chan
  _recseen 10 chan $chan
}

;
; Userhost queue wrapper
;

; Methods this supports-
; Standard- up to five replies per line, no-such-users are missing, blank line if all are no-such-user
; Undernet- up to five replies per line, no-such-users produce no-such-user and split reply, blank line if all or last are no-such-user
; ConfRoom- one reply per line, no-such-users disappear, blank line if all are no-such-user
; Strategy-
; * Hide no-such-user if next in line for queue, remove from queue
; * If a nick turns up that isn't next in queue, all in queue before it get no-such-user status
; * If a blank line turns up, all in queue up to special marker get no-such-user status
; * Special markers mark end of each line of requests, and are discarded otherwise (* is a special marker)
; Can't (ever) handle ConfRoom doing /userhost a b c and getting :a and :b back
; Juryrig sucks- use _blackbox?

raw 401:*no such*:{
  if ($2 == $hget(pnp. $+ $cid,nickrc)) _retakecheck
  var %next = $hget(pnp.quserhost,$cid $+ . $+ $calc($hget(pnp.quserhost,$cid $+ .head) + 1))
  if ($gettok(%next,1,32) == $2) {
    hinc pnp.quserhost $cid $+ .head
    _juryrig2 $_p2s($replace($gettok(%next,3,32),&n,$2))
    halt
  }
}
raw 302:*:{
  var %num = 2,%search,%cmd,%found
  :outer
  if ($ [ $+ [ %num ] ] != $null) { %found = $ifmatch | %search = $remove($gettok($ifmatch,1,61),*) }
  else %search = *
  :inner
  hinc pnp.quserhost $cid $+ .head
  %cmd = $hget(pnp.quserhost,$cid $+ . $+ $hget(pnp.quserhost,$cid $+ .head))
  if ($hget(pnp.quserhost,$cid $+ .head) >= $hget(pnp.quserhost,$cid $+ .tail)) hdel -w pnp.quserhost $cid $+ .*
  if (%cmd == $null) return
  if ($gettok(%cmd,1,32) == %search) {
    if (%search == *) halt
    _juryrig2 $_p2s($replace($gettok(%cmd,2,32),&i,$iif(* isin $gettok(%found,1,61),1,0),&n,$remove($gettok(%found,1,61),*),&a,$mid(%found,$calc(2 + $pos(%found,=))),&h,$left($gettok(%found,2,61),1)))
    inc %num
    if ($ [ $+ [ %num ] ] != $null) goto outer
    if ((< !isin $hget(pnp. $+ $cid,-feat)) && (> !isin $hget(pnp. $+ $cid,-feat))) { %search = * | goto inner }
    if ($hget(pnp.quserhost,$cid $+ . $+ $calc($hget(pnp.quserhost,$cid $+ .head) + 1)) == *) hinc pnp.quserhost $cid $+ .head
    halt
  }
  elseif ($gettok(%cmd,1,32) != *) _juryrig2 $_p2s($replace($gettok(%cmd,3,32),&n,$gettok(%cmd,1,32)))
  goto inner
}
on *:DISCONNECT:{ hdel -w pnp.quserhost $cid $+ .* }

;
; Channel nick completion
;

;;; clean up?
alias _do.thenc {
  if (($right($2,1) isin $hget(pnp.config,nc.char)) && ($3)) { var %chr = $right($2,1),%part = $left($2,-1),%msg = $3- }
  elseif (($len($3) == 1) && ($3 isin $hget(pnp.config,nc.char)) && ($4)) { var %chr = $3,%part = $2,%msg = $4- }
  elseif (($len($2) isnum 3-20) && ($2 !ison $chan) && ($left($2,-1) !ison $chan)) {
    var %num = $len($2)
    :loop
    if ($mid($2,%num,1) isin $hget(pnp.config,nc.char)) { var %chr = $mid($2,%num,1),%part = $left($2,$calc(%num - 1)),%msg = $mid($2,$calc(%num + 1),20) $3- }
    elseif (%num > 3) { dec %num | goto loop }
  }
  else return
  if ((%chr) && (%msg != $null)) {
    if ((%chr != ,) || ($istok(k aw yes no uh uhh hey um umm er err heh hehe hah haha well ok okay so wow ack look see duh doh now o oh ah ahh hi yo i and nah mm mmm hm hmm,%part,32) == $false)) {
      var %cc = %.cmdchar
      var %text = %.input.text,%found = $_nci(%part,$chan)
      if (($numtok(%found,32) > 1) && ($_cfgi(nc.ask))) {
        _ssplay Question
        %.part = %part
        %.found = $_s2c(%found)
        %found = $dialog(nickcomp,nickcomp,-4)
        if (%found == $null) halt
      }
      if (%found ison $chan) {
        var %form = $_msg(nc)
        if (&msg& !isin %form) %form = %form &msg&
        %text = $1 $msg.compile(%form,&op&,$_stsym(%found,$chan),&nick&,%found,&chan&,$chan,&char&,%chr,&msg&,%msg)
      }
      set -u1 %.from-input-nc 1
      set -u1 %.input.text %text
      set -u1 %.input.type say
      set -u1 %.cmdchar %cc
    }
  }
}
alias _nci {
  if ($1 ison $2) return $nick($2,$nick($2,$1))
  if ((* isin $1) || (? isin $1)) return $1
  if ($chan($2).ial == $true) {
    var %scan = * $+ $left($1,1) $+ * $+ $mid($1,2,1) $+ * $+ $mid($1,3,1) $+ *!*
    if ($ialchan(%scan,$2,0) > 0) {
      var %found,%nick,%num = $ifmatch
      :loop
      %nick = $ialchan(%scan,$2,%num).nick
      if (($1* iswm %nick) || ($1* iswm $remove(%nick,$chr(124),\,`,^,-,_,$chr(91),$chr(93),$chr(123),$chr(125)))) %found = %found %nick
      if (%num > 1) { dec %num | goto loop }
      return $remtok(%found,$me,1,32)
    }
    return $1
  }
  return $_qnc($1,$2)
}
dialog nickcomp {
  title "Selection"
  icon script\pnp.ico
  option map
  size -1 -1 93 95
  text "", 1, 1 1 86 17
  list 2, 0 19 93 62, sort
  button "&Select", 3, 13 81 64 12, default ok
  edit "", 4, 1 1 1 1, hide result autohs
  button "", 5, 1 1 1 1, hide cancel
}
on *:DIALOG:nickcomp:init:*:{
  if (%.fullmsg) did -a $dname 1 & $+ %.fullmsg
  else did -a $dname 1 ' $+ %.part $+ ' matches multiple nicks $+ $chr(44) please select one:
  var %num = $numtok(%.found,44)
  :loop
  if (%num) { did -a $dname 2 $gettok(%.found,%num,44) | dec %num | goto loop }
  did -c $dname 2 1
  unset %.fullmsg %.part %.found
}
on *:DIALOG:nickcomp:dclick:2:dialog -k $dname
on *:DIALOG:nickcomp:sclick:3:did -o $dname 4 1 $did(2,$did(2).sel)

;
; Nick completion identifiers
;

; $_nc(partial)
; Returns partial if no match
alias _nc {
  if ($1 == $null) return
  if (($hget(pnp.config,nc.cmd) == 0) || (%.from-input-nc != 1)) return $1
  if ($1 == $hget(pnp,lastsrec)) return $hget(pnp,lastsrec)
  if ($1 !isnum) {
    if ($query($1)) return $query($1)
    if ($chat($1)) return $chat($1)
  }
  if (" isin $1) return $remove($1,")
  if ((= isin $1) || (, isin $1) || (! isin $1) || (* isin $1) || (@ isin $1) || (? isin $1) || (. isin $1) || ($left($1,1) isin +& $+ $chantypes)) return $1
  if ($1 == $me) return $me
  if ($comchan($1,1)) return $nick($ifmatch,$nick($ifmatch,$1))
  if (($notify($1).ison) && ($1 !isnum)) return $hget(pnp. $+ $cid,-notify.nick. $+ $1)
  if ($istok($hget(pnp. $+ $cid,-servnick),$1,32)) return $1
  var %nick,%scan,%found,%num = 1
  if (($_cfgi(nc.ask)) && ($ial)) {
    if (($query($active)) && ($1* iswm $active)) %found = $active
    :loopN2
    if ($notify(%num)) {
      if ($notify(%num).ison) if ($1* iswm $notify(%num)) %found = $addtok(%found,$hget(pnp. $+ $cid,-notify.nick. $+ $notify(%num)),44)
      inc %num
      goto loopN2
    }
    %scan = * $+ $left($1,1) $+ * $+ $mid($1,2,1) $+ * $+ $mid($1,3,1) $+ *!*
    if ($ial(%scan,0) > 0) {
      %num = $ial(%scan,0)
      :loopS2
      %nick = $ial(%scan,%num).nick
      if (($1* iswm %nick) || ($1* iswm $remove(%nick,$chr(124),\,`,^,-,_,$chr(91),$chr(93),$chr(123),$chr(125),0,1,2,3,4,5,6,7,8,9))) %found = $addtok(%found,%nick,44)
      if (%num > 1) { dec %num | goto loopS2 }
    }
    if ($numtok(%found,44) == 1) return %found
    if (%found == $null) return $1
    set %.part $1
    set %.found %found
    _ssplay Question
    return $$dialog(nickcomp,nickcomp,-4)
  }
  if (($query($active)) && ($1* iswm $active)) return $active
  if (#) {
    if ($chan(#).ial == $true) {
      if ($ialchan($1*!*,#,0) > 1) return $1
      if ($ialchan($1*!*,#,1).nick) return $ifmatch
    }
    elseif ($_qnc($1,#)) return $ifmatch
  }
  if ($ial) {
    if ($ial($1*!*,0) > 1) return $1
    if ($ial($1*!*,1).nick) return $ifmatch
  }
  elseif ($chan(0)) {
    %num = $chan(0)
    :loopC
    if ($_qnc($1,$chan(%num))) return $ifmatch
    if (%num > 1) { dec %num | goto loopC }
  }
  %num = 1
  :loopN
  if ($notify(%num)) {
    if ($notify(%num).ison) if ($1* iswm $notify(%num)) return $hget(pnp. $+ $cid,-notify.nick. $+ $notify(%num))
    inc %num
    goto loopN
  }
  if ($ial) {
    %scan = * $+ $left($1,1) $+ * $+ $mid($1,2,1) $+ * $+ $mid($1,3,1) $+ *!*
    if ($ial(%scan,0) > 0) {
      %num = $ifmatch
      :loopS
      if ($1* iswm $remove($ial(%scan,%num).nick,$chr(124),\,`,^,-,_,$chr(91),$chr(93),$chr(123),$chr(125),0,1,2,3,4,5,6,7,8,9)) return $ial(%scan,%num).nick
      if (%num > 1) { dec %num | goto loopS }
    }
  }
  return $1
}
; $_ncs(token,series)
; Same as above for a series
alias _ncs {
  if ($2 == $null) return
  if (($hget(pnp.config,nc.cmd) == 0) || (%.from-input-nc != 1)) return $2-
  if ($2- == $hget(pnp,lastsrec)) return $hget(pnp,lastsrec)
  if ($chr($1) !isin $2-) return $_nc($2)
  var %ret,%num = 1
  :loop
  %ret = $addtok(%ret,$_nc($gettok($2-,%num,$1)),$1)
  if (%num < $numtok($2-,$1)) { inc %num | goto loop }
  return %ret
}
; $_qnc(partial,#chan)
; Quick nick complete- uses $nick, only scans a channel, returns $null if no match
alias _qnc {
  if (($nick($2,0) < 1) || ($2 !ischan)) return
  var %num = $nick($2,0)
  :loop
  if ($1* iswm $nick($2,%num)) return $nick($2,%num)
  if (%num > 1) { dec %num | goto loop }
  return
}
; $_ncc(partial,#chan)
; Returns parial if no match
alias _ncc {
  if ($2 == $null) return
  if (($hget(pnp.config,nc.cmd) == 0) || (%.from-input-nc != 1)) return $1
  if ($1 == $hget(pnp,lastsrec)) return $hget(pnp,lastsrec)
  if (" isin $1) return $remove($1,")
  if ((= isin $1) || (, isin $1) || (! isin $1) || (* isin $1) || (@ isin $1) || (? isin $1) || (. isin $1) || ($left($1,1) isin +& $+ $chantypes)) return $1
  if ($1 ison $2) return $nick($2,$nick($2,$1))
  if ($1 == $me) return $me
  if ($istok($hget(pnp. $+ $cid,-servnick),$1,32)) return $1
  if ($chan($2).ial == $true) {
    if ($_cfgi(nc.ask)) {
      var %scan = * $+ $left($1,1) $+ * $+ $mid($1,2,1) $+ * $+ $mid($1,3,1) $+ *!*
      var %found
      if ($ialchan(%scan,$2,0) > 0) {
        var %nick,%num = $ifmatch
        :loopS2
        %nick = $ialchan(%scan,$2,%num).nick
        if (($1* iswm %nick) || ($1* iswm $remove(%nick,$chr(124),\,`,^,-,_,$chr(91),$chr(93),$chr(123),$chr(125),0,1,2,3,4,5,6,7,8,9))) %found = $addtok(%found,%nick,44)
        if (%num > 1) { dec %num | goto loopS2 }
      }
      if ($numtok(%found,44) == 1) return %found
      if (%found == $null) return $1
      set %.part $1
      set %.found %found
      _ssplay Question
      return $$dialog(nickcomp,nickcomp,-4)
    }
    if ($ialchan($1*!*,$2,0) > 1) return $1
    if ($ialchan($1*!*,$2,1).nick) return $ifmatch
    var %scan = * $+ $left($1,1) $+ * $+ $mid($1,2,1) $+ * $+ $mid($1,3,1) $+ *!*
    if ($ialchan(%scan,$2,0) > 0) {
      var %num = $ifmatch
      :loopS
      if ($1* iswm $remove($ialchan(%scan,$2,%num).nick,$chr(124),\,`,^,-,_,$chr(91),$chr(93),$chr(123),$chr(125),0,1,2,3,4,5,6,7,8,9)) return $ialchan(%scan,$2,%num).nick
      if (%num > 1) { dec %num | goto loopS }
    }
  }
  elseif ($_qnc($1,$2)) return $ifmatch
  return $1
}
; $_nccs(token,#chan,series)
; Same as above for a series
alias _nccs {
  if ($3 == $null) return
  if (($hget(pnp.config,nc.cmd) == 0) || (%.from-input-nc != 1)) return $3-
  if ($3- == $hget(pnp,lastsrec)) return $hget(pnp,lastsrec)
  if ($chr($1) !isin $3-) return $_ncc($3,$2)
  var %ret,%num = 1
  :loop
  %ret = $addtok(%ret,$_ncc($gettok($3-,%num,$1),$2),$1)
  if (%num < $numtok($3-,$1)) { inc %num | goto loop }
  return %ret
}

;
; Adds nick to recent nicknames; detects query-open flood
;

on ^*:OPEN:?:*:{
  if (($notify($nick) == $null) && ($level($fulladdress) == $dlevel)) {
    if ($hget(pnp.flood. $+ $cid,newqueryhalt)) { hadd -u60 pnp.flood. $+ $cid newqueryhalt 1 | halt }
    if ($_genflood(newquery,$_cfgi(xquery.cfg))) {
      hadd -u60 pnp.flood. $+ $cid newqueryhalt 1
      _alert Flood Query flood detected- Further queries from unknown users won't be opened
      halt
    }
  }
  _recseen 10 user $nick
}

;
; Ignore
;

dialog ignore {
  title "Ignore User"
  icon script\pnp.ico
  option map
  size -1 -1 200 169

  box "&Ignoring:", 101, 6 6 187 33
  combo 1, 13 18 173 61, edit drop

  box "Duration:", 102, 6 41 187 40
  radio "&Permanent", 5, 13 54 173 9
  radio "&Ignore for", 6, 13 66 53 9
  text "minutes", 103, 98 67 80 12
  edit "1", 7, 69 63 26 13

  text "&Ignore:", 104, 13 89 30 12, right
  combo 8, 46 87 133 73, drop
  check "&All networks", 11, 46 103 146 9
  check "&Tell user that they are being ignored:", 9, 46 114 146 9
  edit "", 10, 57 126 133 13, autohs disable

  button "&Ignore", 201, 6 147 53 14, OK default result
  button "Cancel", 202, 73 147 53 14, cancel
  button "&Help", 203, 140 147 53 14, disable

  edit $cid, 300, 1 1 1 1, hide autohs
}
on *:DIALOG:ignore:init:*:{
  var %opt = $_dlgi(ign)
  if (%opt == $null) %opt = 5 10 1 0 0

  loadbuf -otignore $dname 8 script\dlgtext.dat

  if (* !isin $gettok(%.mask,1,33)) did -o $dname 101 1 Ignoring: ( $+ $gettok(%.mask,1,33) $+ )
  else did -b $dname 9
  _ddaddm $dname 1 %.mask 022 030 100 002 111
  did -c $dname 1 1
  unset %.mask

  did -c $dname $gettok(%opt,1,32)
  if ($gettok(%opt,1,32) == 5) did -b $dname 7
  did -o $dname 7 1 $gettok(%opt,2,32)
  did -c $dname 8 $gettok(%opt,3,32)
  if ($gettok(%opt,3,32) isnum 3-4) did -b $dname 9
  if ($gettok(%opt,4,32)) { did -c $dname 9 | if ($did(9).enabled) did -e $dname 10 }
  if ($gettok(%opt,5,32)) did -c $dname 11
  if ($gettok(%opt,3,32) == 5) did -b $dname 11
}
on *:DIALOG:ignore:sclick:5:did -b $dname 7
on *:DIALOG:ignore:sclick:6:did -e $dname 7
on *:DIALOG:ignore:sclick:8:{
  if ($did(8).sel isnum 3-4) did -b $dname 9 | elseif ($chr(40) isin $did(101)) did -e $dname 9
  if ($did(8).sel == 5) did -b $dname 11 | else did -e $dname 11
}
on *:DIALOG:ignore:sclick:9:did $iif($did(9).state,-e,-b) $dname 10
on *:DIALOG:ignore:sclick:201:{
  var %time = 10
  if (($did(7) isnum) && ($did(7) > 0)) %time = $did(7)
  if ($scid($did(300)) == $null) return
  scid $did(300)
  ign $gettok(-pdtinck -pdtink -idt -k -pdtincks,$did(8).sel,32) $+ $iif($did(11).state,w) $+ $iif($did(6).state,u $+ $int($calc(%time * 60))) $$did(1)
  _dlgw ign $iif($did(5).state,5,6) %time $did(8).sel $did(9).state $did(11).state
  var %nick = $left($right($gettok($did(101),2,32),-1),-1)
  if (%nick) {
    if ($did(11).state) scid -a close -m %nick
    else close -m %nick
    if (($did(9).state) && ($did(8).sel !isnum 3-4)) {
      var %msg = $_msg($iif($did(8).sel == 2,ignoreallbut,ignoreall))
      if ((&reason& !isin %msg) && ($did(10) != $null)) notice %nick $msg.compile(%msg,&nick&,%nick) ( $+ $did(10) $+ )
      else notice %nick $msg.compile(%msg,&nick&,%nick,&reason&,$did(10))
    }
  }
}
; /ign [-r] nick|address (or mirc-style options)
; returns "ignore" if ignore occured and dialog was used (this is used in our pager)
alias ign {
  if (-* iswm $1) { var %mask,%flag = $1,%who = $_nc($2) }
  else { var %mask,%flag = -,%who = $_nc($1) }
  if (%who == $null) _qhelp /ign $1
  if ((@ isin %who) || (* isin %who)) %mask = $_fixmask(%who)
  elseif (($query(%who) == %who) && ($query(%who).address != %who)) %mask = %who $+ ! $+ $ifmatch
  elseif ($address(%who,5)) %mask = $ifmatch
  else {
    dispa Looking up address of $:t(%who) $+ ...
    _notconnected
    _Q.userhost ign $+ %flag $+ &n!&a $+ $3 dispa $+ User $+ $:t(%who) $+ notfound %who
    halt
  }
  if (r isin %flag) {
    if (((s isin $hget(pnp. $+ $cid,-feat)) || (s isin %flag)) && ($server)) .raw silence - $+ %mask
    var %count = 0,%num = $ignore(0)
    :loop
    if (%num) {
      if ((%mask iswm $ignore(%num)) || ($ignore(%num) iswm %mask)) {
        inc %count
        %who = $ignore(%num)
        dispa Removed $:s(%who) from ignore list
        .ignore -r $+ $iif($ignore(%num).network == $null,w) %who
        scid -at1 _nickcol.updatemask %who 1
      }
      dec %num | goto loop
    }
    if (%count) dispa Removed $:t(%count) ignore $+ $chr(40) $+ s $+ $chr(41) total
    else dispa No ignores matching $:s(%mask) found to remove
  }
  elseif (%flag != -) {
    if ($3 isnum) %who = $_ppmask(%mask,$3)
    else %who = $_ppmask(%mask,3)
    if ((s isin %flag) && ($server)) {
      .raw silence + $+ %mask
      if (u isin %flag) .timer 1 $calc($mid(%flag,$calc($pos(%flag,u) + 1),$len(%flag))) .raw silence - $+ %mask
    }
    ignore %flag %who
    if (u isin %flag) .timer -io 1 $calc($mid(%flag,$calc($pos(%flag,u) + 1),$len(%flag))) scid -at1 _nickcol.updatemask %who 1
    scid -at1 _nickcol.updatemask %who 1
    if (* !isin $gettok(%mask,1,33)) {
      if (w isin %flag) scid -a close -m $gettok(%mask,1,33)
      else close -m $gettok(%mask,1,33)
    }
  }
  else { set %.mask %mask | _ssplay Dialog | return $dialog(ignore,ignore,-4) }
}

;
; Nickname retake
;
alias _retakecheck {
  if ($hget(pnp. $+ $cid,net) == Offline) halt
  .timer.nickretake. $+ $cid 1 15 _retakecheck
  if ($hget(pnp. $+ $cid,-sp.count) > 20) halt
  _linedance _Q.userhost halt _donretake $hget(pnp. $+ $cid,-nickrc)
}
on *:SIGNAL:PNP.SIGNON:{ if ($hget(pnp. $+ $cid,-nickrc)) _retakecheck }
on *:UNOTIFY:if ($nick == $hget(pnp. $+ $cid,-nickrc)) _retakecheck
on *:NICK:if ($nick == $hget(pnp. $+ $cid,-nickrc)) { if ($nick == $me) { hdel pnp. $+ $cid -nickrc | _donretake } | elseif ($nick != $newnick) _retakecheck } | else if (($nick == $me) && ($newnick == $hget(pnp. $+ $cid,-nickretake))) hdel pnp. $+ $cid -nickretake
on *:QUIT:if ($nick == $hget(pnp. $+ $cid,-nickrc)) _retakecheck
on *:PART:#:if ($nick == $hget(pnp. $+ $cid,-nickrc)) .timer.nickretake. $+ $cid 1 5 _retakecheck
on *:NOTICE:*Your ghost has been killed*:?:if ($hget(pnp. $+ $cid,-nickrc)) .timer.nickretake. $+ $cid 1 1 _retakecheck
on *:NOTICE:*Nick*has been released from custody*:?:if ($hget(pnp. $+ $cid,-nickrc)) .timer.nickretake. $+ $cid 1 1 _retakecheck
alias _donretake {
  if ($hget(pnp. $+ $cid,-nickrc)) {
    disptn -a $hget(pnp. $+ $cid,-nickrc) Nickname no longer in use. Changing to nick...
    nick $hget(pnp. $+ $cid,-nickrc)
  }
  .timer.nickretake. $+ $cid off
  hdel pnp. $+ $cid -nickrc
  hdel pnp. $+ $cid -nickretake
}

;
; Channel rejoin
;
alias repjoin {
  if ($_ischan($1)) {
    if ($istok($hget(pnp. $+ $cid,-repjoin),$1,44)) {
      if ($remtok($hget(pnp. $+ $cid,-repjoin),$1,1,44)) hadd pnp. $+ $cid -repjoin $ifmatch
      else {
        hdel pnp. $+ $cid -repjoin
        .timer.repjoin. $+ $cid off
      }
      dispa Removed $:s($1) from rejoin attempts
    }
    else {
      hadd pnp. $+ $cid -repjoin $addtok($hget(pnp. $+ $cid,-repjoin),$1,44)
      dispa Added $:s($1) to rejoin attempts; You will attempt to rejoin every 20 seconds; Use /repjoin -c to cancel
      .timer.repjoin. $+ $cid 0 20 _linedance .raw join $!hget(pnp. $+ $cid $+ ,-repjoin)
    }
  }
  elseif ($1 == -c) {
    if ($hget(pnp. $+ $cid,-repjoin),$1,44) dispa All rejoin attempts cancelled
    else dispa No channel rejoins being attempted
    hdel pnp. $+ $cid -repjoin
    .timer.repjoin. $+ $cid off
  }
  elseif ($1 == -r) {
    if ($remtok($hget(pnp. $+ $cid,-repjoin),$2,1,44)) hadd pnp. $+ $cid -repjoin $ifmatch
    else {
      hdel pnp. $+ $cid -repjoin
      .timer.repjoin. $+ $cid off
    }
  }
  else {
    if ($hget(pnp. $+ $cid,-repjoin)) { dispa You are currently attempting to rejoin: $:l($hget(pnp. $+ $cid,-repjoin)) | dispa Use /repjoin $chr(35) $+ chan to add or remove channels | dispa Use /repjoin -c to clear all rejoins }
    else { dispa No channel rejoins being attempted | dispa Use /repjoin $chr(35) $+ chan to add or remove channels }
  }
}

;
; Connect routines- Obtain my address, network, services, and determine server features from version
;
; address from 1 raw or USERHOST we send
; network from 1 raw, 4 raw, or certain connection data
; services from network name
; features from raws or network name

raw 1:& Welcome to & IRC *:_do.raw1 $4 $1-
raw 1:& Welcome to IRC at & *:_do.raw1 $6 $1-
raw 1:& Welcome to the & *network *:_do.raw1 $5 $1-
raw 1:*:_do.raw1 $4 $1-
alias -l _do.raw1 {
  unset %<*
  hadd pnp. $+ $cid -myself $gettok($2-,-1,32)
  if ($gettok($hget(pnp. $+ $cid,-myself),1,33) !=== $me) hadd pnp. $+ $cid -myself $me
  if (!$_isaddr($hget(pnp. $+ $cid,-myself))) _Q.userhost _addself&n!&a _trackcode $hget(pnp. $+ $cid,-myself)
  hadd pnp. $+ $cid net $1
  if ($len($hget(pnp. $+ $cid,net)) < 5) hadd pnp. $+ $cid net internet
  if (($hget(pnp. $+ $cid,net) == dalnet) && (*.dal.net !iswm $server)) hadd pnp. $+ $cid net internet
  hadd pnp. $+ $cid -signon progress
  _upd.title
  remini config\ $+ $hget(pnp,user) $+ \config.ini c

  _cfgw lastserv $server $port
  _recent srv 9 44 $server $+ , $port
  if ($_cfgi($iif($hget(pnp. $+ $cid,away),uaway,umode)) != $null) umode $ifmatch
}

raw 4:*:{
  if ((nn-* iswm $3) && ($hget(pnp. $+ $cid,net) == internet)) hadd pnp. $+ $cid net NewNet

  ; Find matching server version for "additional features", max modes, num targets, identd prefixes
  window -hl @.servfeat
  loadbuf @.servfeat script\servfeat.dat
  var %num = $line(@.servfeat,0)
  :loop
  if ($gettok($line(@.servfeat,%num),1,32) iswm $3) {
    hadd pnp. $+ $cid -modes $gettok($line(@.servfeat,%num),2,32)
    hadd pnp. $+ $cid -target $gettok($line(@.servfeat,%num),3,32)
    hadd pnp. $+ $cid -feat $gettok($line(@.servfeat,%num),4-,32)
    hadd pnp. $+ $cid -matched $gettok($line(@.servfeat,%num),1,32)
  }
  elseif (%num > 1) { dec %num | goto loop }
  window -c @.servfeat

  ; Network
  if ($hget(pnp. $+ $cid,net) == internet) {
    hadd pnp. $+ $cid net $_cap1st($network)
    if (($hget(pnp. $+ $cid,net) == dalnet) && (*.dal.net !iswm $server)) hadd pnp. $+ $cid net internet
    elseif ($hget(pnp. $+ $cid,net) == $null) hadd pnp. $+ $cid net $iif(efnet isin $2,EFnet,internet)
  }
  if ((CR* iswm $3) && ($hget(pnp. $+ $cid,net) == internet)) hadd pnp. $+ $cid net $_cap1st($gettok($server,$count($server,.),46))
}

raw 5:*:{
  ; Decode raw 5- Add to feat / etc. as found
  if ($findtok($2-,WALLCHOPS,1,32)) hadd pnp. $+ $cid -feat $hget(pnp. $+ $cid,-feat) $+ @
  if ($findtok($2-,WHOX,1,32)) hadd pnp. $+ $cid -feat $hget(pnp. $+ $cid,-feat) $+ w
  if ($findtok($2-,USERIP,1,32)) hadd pnp. $+ $cid -feat $hget(pnp. $+ $cid,-feat) $+ u
  if (($findtok($2-,CPRIVMSG,1,32)) && ($findtok($2-,CNOTICE,1,32))) hadd pnp. $+ $cid -feat $hget(pnp. $+ $cid,-feat) $+ c
  if ($findtok($2-,MAP,1,32)) hadd pnp. $+ $cid -feat $hget(pnp. $+ $cid,-feat) $+ z
  if ($wildtok($2-,SILENCE=*,1,32)) hadd pnp. $+ $cid -feat $hget(pnp. $+ $cid,-feat) $+ s
  if ($wildtok($2-,MODES=*,1,32)) hadd pnp. $+ $cid -modes $gettok($ifmatch,2,61)
  if ($wildtok($2-,CHANTYPES=*,1,32)) hadd pnp. $+ $cid -feat $remove($hget(pnp. $+ $cid,-feat),l) $+ $iif(+ isin $ifmatch,l)
  if ($wildtok($2-,PREFIX=*,1,32)) hadd pnp. $+ $cid -feat $remove($hget(pnp. $+ $cid,-feat),h) $+ $iif(% isin $ifmatch,h)
  if ($wildtok($2-,NETWORK=*,1,32)) {
    var %net = $ifmatch
    ; Don't allow dalnet on non dal net servers
    if ((%net != dalnet) || (*.dal.net iswm $server)) hadd pnp. $+ $cid net $gettok(%net,2,61)
  }
  if ($wildtok($2-,NICKLEN=*,1,32)) hadd pnp. $+ $cid -nicklen $gettok($ifmatch,2,61)
}

raw 250:*Highest connection count*:if (($hget(pnp. $+ $cid,net) == internet) && ($network == $null)) hadd pnp. $+ $cid net EFNet
raw 265:*Current local*:if (($hget(pnp. $+ $cid,net) == internet) && ($network == $null)) hadd pnp. $+ $cid net EFNet
raw 251:*There are & users plus & invisible and & services on & servers:if (($hget(pnp. $+ $cid,net) == internet) && ($network == $null)) hadd pnp. $+ $cid net IRCnet
raw 255:*I have & clients, & services and & servers:if (($hget(pnp. $+ $cid,net) == internet) && ($network == $null)) hadd pnp. $+ $cid net IRCnet

; MOTD missing
raw 422:*:_fin.signon
; Start of MOTD
raw 375:*:_fin.signon
; End of MOTD
raw 376:*:_fin.signon
alias -l _fin.signon {
  if ($hget(pnp. $+ $cid,-signon) != progress) return
  hdel pnp. $+ $cid -signon
  if ($hget(pnp. $+ $cid,net) == internet) hadd pnp. $+ $cid net $iif(*.oz.org iswm $server,Oz_ORG,$_cap1st($gettok($server,$count($server,.),46)))
  ; Always override with favorites network setting
  if ($_favfindnet($server)) hadd pnp. $+ $cid net $ifmatch

  ; Verify network has only alphanumerics
  hadd pnp. $+ $cid net $_escape2($hget(pnp. $+ $cid,net))

  ; If matched server is *, load certain features from mirc vars
  if ($hget(pnp. $+ $cid,-matched) == *) {
    hadd pnp. $+ $cid -modes $modespl
  }
  hdel pnp. $+ $cid -matched

  ; Determine services on network and approx. number of servers
  tokenize 32 $read(script\netwfeat.dat,tns,$hget(pnp. $+ $cid,net))
  hadd pnp. $+ $cid -serv $1
  hadd pnp. $+ $cid -servopt $2
  hadd pnp. $+ $cid -servaddr $replace($3-,???,$gettok($server,-2-,46))

  ; Chops all servnicks pre-@; replaces ??? in addresses
  var %servnick = $3-
  var %num = $numtok(%servnick,32)
  while (%num >= 1) {
    %servnick = $puttok(%servnick,$gettok($gettok(%servnick,%num,32),1,64),%num,32)
    dec %num
  }
  hadd pnp. $+ $cid -servnick %servnick

  _ssplay Connect
  .signal PNP.SIGNON
  if (($mouse.key !& 2) || ($mouse.key !& 4)) .timer -m 1 0 fav j x
  _upd.title
}

alias _trackcode if (*!*@* !iswm $hget(pnp. $+ $cid,-myself)) hadd pnp. $+ $cid -myself $me | _Q.userhost _addself&n!&a _trackcode $me
alias _addself hadd pnp. $+ $cid -myself $1


; $msg.compile(msgtext,&var1&,var1value,&var2&,var2value,...)
; Compiles a message. msgtext may contain &vars& that are replaced, or $idents(...) that are run.
; Uses regex, etc. to prevent any double-evaluation of any vars or any idents that may be within a var.
; (if you want to evaluate stuff in a var, run the var through msg.compile first)
; If $2 is &test& then we won't increase values of counters; if $prop is recurse then this is a recurse
; You can set global vars of the form %&var& as well, to fill them.
alias msg.compile {
  var %col = 02 03 04 05 06 07 10 12 13 14
  var %new
  var %leftspace = 1

  ; Fill local %&vars&
  if ($prop != recurse) {
    var %&me& = $me
    var %&[& = $hget(pnp.config,bracket.left)
    var %&]& = $hget(pnp.config,bracket.right)
    var %&ver& = $:ver
    var %pos = 2
    while ($ [ $+ [ %pos ] ] != $null) {
      var % $+ [ $ $+ [ %pos ] ] $ [ $+ [ $calc(%pos + 1) ] ]
      inc %pos 2
    }
  }

  var %pos = 1

  ; find next instance of a &var&, $ident( ), or special character needing escaping
  while ($regex(msgc,$mid($1,%pos),/(&[-_.a-zA-Z0-9\[\]]+&|\$[-_.a-zA-Z0-9\x3A]+\([^\ $+ $chr(41) $+ ]*\)|[%#{|}\[\]$])/)) {
    var %found = $regml(msgc,1)
    var %foundpos = $calc($regml(msgc,1).pos + %pos - 1)
    var %foundlen = $len(%found)
    ; If an $ident, make sure the number of parenthesis is correct
    if ($!?* iswm %found) {
      ; Slurp additional characters until we have matching parens or an error
      while ($count(%found,$chr(40)) != $count(%found,$chr(41))) {
        if ($pos($mid($1,$calc(%foundpos + %foundlen)),$chr(41))) {
          inc %foundlen $ifmatch
          %found = $mid($1,%foundpos,%foundlen)
        }
        else break
      }
      ; Error? Just escape the $
      if ($count(%found,$chr(40)) != $count(%found,$chr(41))) {
        %found = $
        %foundlen = 1
      }
    }
    ; Append any non-matching portion now
    if (%foundpos > %pos) {
      if (($mid($1,%pos,1) == $chr(32)) || (%new == $null)) %new = %new $mid($1,%pos,$calc(%foundpos - %pos))
      else %new = %new $!+ $mid($1,%pos,$calc(%foundpos - %pos))
      %leftspace = $iif($mid($1,$calc(%foundpos - 1),1) == $chr(32),1,0)
    }
    elseif (%new != $null) %leftspace = 0
    ; Escape %found
    if (&* iswm %found) {
      ; &col*, &count*? (don't mess with setting vars if this is a recurse)
      if (($prop != recurse) && (% [ $+ [ %found ] ] == $null)) {
        if (&col* iswm %found) {
          var %sel = $gettok(%col,$_pprand($numtok(%col,32)),32)
          %col = $remtok(%col,%sel,32)
          if (%col == $null) %col = 02 03 04 05 06 07 10 12 13 14
          var % [ $+ [ %found ] ]
          % [ $+ [ %found ] ] =  $+ %sel
        }
        elseif (&count* iswm %found) {
          var %sel = $_cfgx($mid(%found,7,1),%found)
          inc %sel
          if ($2 != &test&) _cfgxw $mid(%found,7,1) %found %sel
          var % [ $+ [ %found ] ]
          % [ $+ [ %found ] ] = %sel
        }
      }
      %found = % $+ %found
    }
    elseif ($!?* iswm %found) {
      ; Divide into ident portion and data portion, and run data portion through msg.compile again! No need to pass vars, they'll evaluate here
      var %ident = $pos(%found,$chr(40))
      var %data = $mid(%found,$calc(%ident + 1),-1)
      %found = $left(%found,%ident) $+ $msg.recurse(%data,$iif($2 == &test&,$2)) $+ $chr(41)
    }
    else {
      %found = $!chr( $+ $asc(%found) $+ )
    }
    ; Append the matching portion, escaped
    %new = %new $iif(!%leftspace,$!+) %found
    ; Next position
    %pos = %foundpos + %foundlen
  }

  ; Append any remaining portion
  if (%pos <= $len($1)) {
    if (($mid($1,%pos,1) == $chr(32)) || (%new == $null)) %new = %new $mid($1,%pos)
    else %new = %new $!+ $mid($1,%pos)
  }

  ; Return result- recursed?
  if ($prop == recurse) return %new
  set -n %new [ [ %new ] ]
  return $_stripout(%new)
}
alias -l msg.recurse { return $msg.compile($1,$2).recurse }
alias _stripout if ($hget(pnp.config,strip.auto)) return $strip($1-) | return $1-

; $_msg(code[,msg])
; Returns a message from current scheme; default if none; uses msg if present; Handles !Random:* stuff
alias _msg {
  ; Get message
  if ($2 != $null) return $2-
  var %found = $read($_cfg(msgs.dat),ns,$1)
  if ($readn) {
    if (%found == $null) return
  }
  ; Find default
  else %found = $_p2s($gettok($gettok($read(script\msgdefs.dat,nw,& $1 *),5,32),1,124))
  if (!Random:* iswm %found) %found = $read($gettok(%found,2-,58),n)
  return %found
}

; $_msgwrap(wrapcode,msgcode[,msg])
; Used for kick wrappers / etc.
; &msg& is done with normal $replace, very unlikely this will cause a problem
alias _msgwrap {
  ; Get message (to place in &msg&)
  var %msg
  if ($3 != $null) %msg = $3-
  else {
    var %found = $read($_cfg(msgs.dat),ns,$2)
    if ($readn) %msg = %found
    ; Find default
    else %msg = $_p2s($gettok($gettok($read(script\msgdefs.dat,nw,& $2 *),5,32),1,124))
    if (!Random:* iswm %msg) %msg = $read($gettok(%msg,2-,58),n)
  }
  ; Get wrapper
  var %wrapper = $read($_cfg(msgs.dat),ns,$1)
  ; Find default
  if (!$readn) %wrapper = $_p2s($gettok($gettok($read(script\msgdefs.dat,nw,& $1 *),5,32),1,124))
  if (!Random:* iswm %wrapper) %wrapper = $read($gettok(%wrapper,2-,58),n)
  if (&msg& !isin %wrapper) %wrapper = %wrapper &msg&
  return $replace(%wrapper,&msg&,%msg)
}

