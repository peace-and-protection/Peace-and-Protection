; #= P&P -rs
; ########################################
; Peace and Protection
; Notify routines and scripts
; ########################################
 
;
; Notify
;
on ^*:NOTIFY:{
  hadd pnp. $+ $cid -notify.nick. $+ $nick $nick
  if ($hget(pnp.config,notify.win) == off) return
  ; (this prevents the possibility of showing unnotify then showing notify userhost reply!)
  hadd pnp. $+ $cid -notify.waiting. $+ $nick 1
  hadd pnp. $+ $cid -notifychk $addtok($hget(pnp. $+ $cid,-notifychk),$nick,32)
  if ($numtok($hget(pnp. $+ $cid,-notifychk),32) == 5) _do.n.userhost
  else .timer.notify.uh. $+ $cid -m 1 500 _do.n.userhost
  halt
}
alias _do.n.userhost _linedance _Q.userhost _run.notify&n&a&h&n!&a halt $hget(pnp. $+ $cid,-notifychk) | .timer.notify.uh. $+ $cid off | hdel pnp. $+ $cid -notifychk
; _run.notify nick addr awaystatus nick!addr
alias _run.notify {
  ; (this prevents the possibility of showing unnotify then showing notify userhost reply!)
  if ($hget(pnp. $+ $cid,-notify.waiting. $+ $1) == 2) {
    hdel pnp. $+ $cid -notify.waiting. $+ $1
    return
  }
  hdel pnp. $+ $cid -notify.waiting. $+ $1
  hadd pnp. $+ $cid -notify.nick. $+ $1 $1
  if ($1 == $me) { hadd pnp. $+ $cid -notify.hid. $+ $1 1 | return }
  var %mask = $gettok($notify($1).note,1,32)
  if ((* isin %mask) || (@ isin %mask) || ($left(%mask,1) == $)) var %note = $gettok($notify($1).note,2-,32)
  else { %mask = | var %note = $notify($1).note }
  if ($ isin %mask) {
    if ($left(%mask,1) == $) { var %net = $right(%mask,-1) | %mask = }
    else { var %net = $gettok(%mask,2-,36) | %mask = $gettok(%mask,1,36) }
    if (* isin %net) {
      %net = * $+ %net $+ *
      if (%net !iswm $server) { hadd pnp. $+ $cid -notify.hid. $+ $1 1 | return }
    }
    elseif (%net != $hget(pnp. $+ $cid,net)) { hadd pnp. $+ $cid -notify.hid. $+ $1 1 | return }
  }
  if (%mask) { %mask = * $+ %mask $+ * | var %match = $iif(%mask iswm $4,match,fail) }
  else var %match = nocheck
  if ($hget(pnp. $+ $cid,-notify.on. $+ $1) == $null) hadd pnp. $+ $cid -notify.on. $+ $1 $ctime $2 %match
  else hadd pnp. $+ $cid -notify.on. $+ $1 $gettok($hget(pnp. $+ $cid,-notify.on. $+ $1),1,32) $2 %match
  if (%match == fail) _nickcol.updatenick $1 1
  if ($hget(pnp.config,notify.win) == none) return
  var %show = $_cfgi(notify. $+ %match)
  if (%show == hide) return
 
  set -u %:echo echo $color(notify) -mt $+ $hget(pnp.config,notify.win) $iif((a isin $hget(pnp.config,notify.win)) && ($cid != $activecid),$:anp)
set -u %:comments $iif(%match == match,- address verified,$iif(%match == fail,- address check failed))
  set -u %::text %note
  set -u %::nick $1
  set -u %::away $iif($3 == -,G,H)
  if (%show == ext) set -u %::address $2
  theme.text Notify p
  
if ($_cfgi(notify.beep $+ %match)) { beep 1 1 | flash Notify- $1 $gettok((verified) (wrong address),$findtok(match fail,%match,1,32),32) }
  _recseen 10 user $1
  if (%note != $null) %note = ( $+ %note $+ )
_away.logit @ 8 $cid (Notify) »»» $1 is on IRC $+ $iif(%match == match,- address verified,$iif(%match == fail,- address check failed)) %note $iif($3 == -,(away),(here))
  ; don't play notify sound if playing song or playing that sound already
  if ($notify($1).sound) {
    if (($ifmatch !isin $inwave.fname) && (!$inmidi) && (!$insong)) .splay " $+ $notify($1).sound $+ "
  }
  else _ssplay $iif(%match == fail,NotifyFail,Notify)
  if ($notify($1).whois) whois $1
}
on ^*:UNOTIFY:{
  ; (this prevents the possibility of showing unnotify then showing notify userhost reply!)
  if ($hget(pnp. $+ $cid,-notify.waiting. $+ $nick)) hadd pnp. $+ $cid -notify.waiting. $+ $nick 2
  if ($gettok($hget(pnp. $+ $cid,-notify.on. $+ $nick),1,32) isnum) var %time = $calc($ctime - $ifmatch)
  else var %time = 0
  var %addr = $gettok($hget(pnp. $+ $cid,-notify.on. $+ $nick),2,32),%nick = $hget(pnp. $+ $cid,-notify.nick. $+ $nick),%match = $gettok($hget(pnp. $+ $cid,-notify.on. $+ $nick),3,32)
  if (%addr == $null) %addr = ??
  if (%match == $null) %match = nocheck
  hdel pnp. $+ $cid -notify.on. $+ $nick
  hdel pnp. $+ $cid -notify.nick. $+ $nick
  if ($hget(pnp.config,notify.win) == off) return
  if (($hget(pnp. $+ $cid,-notify.hid. $+ $nick)) || (%nick == $null)) { hdel pnp. $+ $cid -notify.hid. $+ $nick | halt }
  if ($hget(pnp.config,notify.win) == none) return
  var %show = $_cfgi(unotify. $+ %match)
  if (%show == hide) halt
 
  set -u %:echo echo $iif($_cfgi(unotify.part),$color(quit),$color(notify)) -t $+ $hget(pnp.config,notify.win) $iif((a isin $hget(pnp.config,notify.win)) && ($cid != $activecid),$:anp)
set -u %:comments $iif(%match == match,- address verified,$iif(%match == fail,- address check failed))
  set -u %::text $_dur(%time)
  set -u %::nick %nick
  if (%show == ext) set -u %::address %addr
  theme.text UNotify p
  
  _recseen 10 user %nick +
_away.logit @ 8 $cid (Notify) ««« %nick left IRC ( $+ $_dur(%time) $+ ) $iif(%match == match,- address verified,$iif(%match == fail,- address check failed))
  _ssplay $iif(%match == fail,UNotifyFail,UNotify)
  halt
}
 
; Notify theming defaults
alias _pnptheme.notify {
var %away = $iif(%::away == G,$:b(Away))
var %show = $:b(%::nick) is on IRC $+ %:comments
  if (%::address) %show = %show $:b($chr(40)) $+ %::address $+ $:b($chr(41))
  if (%away) {
    if (%::address) %show = %show - %away
    else %show = %show $+ - %away
  }
  if (%::parentext) {
    if ((%::address) || (%away)) %show = %show - %::parentext
    else %show = %show %::parentext
  }
  if ($hget(pnp.config,show.fkeys)) {
if ((%::address) || (%away) || (%::parentext)) %show = %show - CtrlF1 whois; ShiftF1 query
else %show = %show $+ - CtrlF1 whois; ShiftF1 query
  }
  %:echo $str(»,$len($strip($:*))) %show
}
alias _pnptheme.unotify {
%:echo $str(«,$len($strip($:*))) $:b(%::nick) left IRC $+ %:comments $iif(%::address,$:b($chr(40)) $+ %::address $+ $:b($chr(41)) -) ( $+ was on %::text $+ ) $iif($hget(pnp.config,show.fkeys),- CtrlF1 whowas)
}
 
 
;
; Notify
;
 
; /notif [-r] nick [more nicks]
; Adds/Edits notify list entry(s)
alias notif {
  if ($1 == -r) {
    var %param = $_ncs(32,$2-)
    while (%param) {
      notify -r $gettok(%param,1,32)
      scid -at1 _nickcol.updatenick $gettok(%param,1,32) 1
      %param = $gettok(%param,2-,32)
    }
  }
  else {
    set %.param $_ncs(32,$1-)
    :loop2
    _ssplay Dialog
    set %.param $dialog(addnotif,addnotif,-4)
    if (%.param) goto loop2
  }
}
dialog addnotif {
title "Notify"
  icon script\pnp.ico
  option dbu
  size -1 -1 115 130
 
text "&Adding:", 201, 2 4 23 10
  edit "", 1, 26 2 50 11, autohs
text "(notify list)", 202, 78 4 35 10
 
radio "&on all networks", 2, 11 15 100 8
radio "&only on", 3, 11 25 30 8
  edit "", 4, 42 23 44 11, autohs
text "network", 203, 88 25 25 10
 
text "&Mask to match address against:", 204, 2 45 105 10
 
  combo 5, 11 55 100 50, drop edit
check "&Whois user on notify", 6, 11 67 100 8
 
text "&User note:", 205, 2 85 105 10
 
  edit "", 7, 10 94 101 11, autohs
 
button "OK", 101, 2 115 35 12, OK default
button "Cancel", 102, 40 115 35 12, cancel
button "&Remove", 103, 77 115 35 12
 
  edit "", 241, 1 1 1 1, hide autohs
  edit "", 242, 1 1 1 1, hide autohs result
}
on *:DIALOG:addnotif:init:*:{
  var %net,%mask,%note,%addr,%nick = $gettok(%.param,1,32)
  if (! isin %nick) { %addr = %nick | %nick = $gettok(%nick,1,33) }
  elseif ($address(%nick,5)) %addr = $ifmatch
  elseif (($query(%nick).address != $null) && ($query(%nick).address != %nick)) %addr = %nick $+ ! $+ $ifmatch
  elseif (%nick) %addr = *! $+ %nick $+ @*
  did -a $dname 1 %nick
 
  ; Saves original nick and any extra params
  did -a $dname 241 %nick
  did -a $dname 242 $gettok(%.param,2-,32)
  unset %.param
 
  if ($hget(pnp. $+ $cid,net)) did -a $dname 4 $ifmatch
 
  if ($notify(%nick)) {
did -a $dname 201 Editing:
    if ($notify(%nick).whois) did -c $dname 6
 
    %note = $notify(%nick).note
    %mask = $gettok(%note,1,32)
    if ((* isin %mask) || (@ isin %mask) || ($left(%mask,1) == $)) {
      %note = $gettok(%note,2-,32)
      if ($ isin %mask) {
        %mask = @ $+ %mask
        %net = $gettok(%mask,2-,36)
        %mask = $right($gettok(%mask,1,36),-1)
      }
    }
 
    did -a $dname 7 %note
 
    if (%net) {
      did -o $dname 4 1 %net
      did -c $dname 3
    }
    else {
      did -c $dname 2
      did -b $dname 4
    }
  }
  else {
    did -b $dname 103,4
    did -c $dname 2
  }
  did -f $dname $iif(%nick,5,1)
 
  if (%mask) did -ca $dname 5 %mask
  else did -ca $dname 5 None
 
  if (* isin %addr) { if (%addr != %mask) did -a $dname 5 %addr }
  elseif (%addr) _ddaddm $dname 5 %addr 002 022 030 011
}
on *:DIALOG:addnotif:sclick:2:did -b $dname 4
on *:DIALOG:addnotif:sclick:3:did -e $dname 4
on *:DIALOG:addnotif:sclick:101:{
  if ($did(1)) {
    var %mask = $did(5)
    if (%mask == None) var %mask
    elseif ((@ !isin %mask) && (* !isin %mask)) %mask = * $+ %mask $+ *
    if (($did(3).state) && ($did(4))) %mask = %mask $+ $ $+ $did(4)
    %mask = %mask $did(7)
    if ($notify($did(241))) {
      if (($did(1) == $did(241)) && ($notify($did(241)).note == %mask) && ($_tf($notify($did(241)).whois) == $did(6).state)) return
      .notify -r $did(241)
      scid -at1 _nickcol.updatenick $did(241) 1
      .notify -r $did(1)
    }
    notify $iif($did(6).state,+) $+ $did(1) %mask
    scid -at1 _nickcol.updatenick $did(1) 1
  }
}
on *:DIALOG:addnotif:sclick:103:notify -r $did(241) | did -r $dname 1 | scid -at1 _nickcol.updatenick $did(241) 1 | dialog -k $dname
