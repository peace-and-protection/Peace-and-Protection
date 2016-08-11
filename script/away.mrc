; #= P&P -rs
; ########################################
; Peace and Protection
; Away system
; ########################################

on *:OPEN:=:{
  if ($hget(pnp. $+ $cid,away)) {
    if ($group(#awaylog) == on) _awaylog @ 11 0 === $nick opened a DCC chat
    ; If we're away and chat was auto-accepted, say something
    if ($gettok($hget(pnp,chat.open. $+ $nick),1,32) == auto) $iif($_cfgi(away.act),describe,msg) =$nick $_awayformat(awaychat)
  }
}

; Make sure we set back before closing a server and/or closing mirc, to cover nick changes / beeps / sounds / dqwindow
on *:SIGNAL:PNP.STATUSCLOSE:{ if ($hget(pnp. $+ $cid,away)) qb +ok }
on *:EXIT:{ if ($hget(pnp,away)) qb +k }

on *:CONNECT:{
  if ($hget(pnp. $+ $cid,away)) {
    if ($group(#awaylog) == on) _awaylog @ 12 $cid »»» You connected to $server : $port
    disps Setting away on server...
    _upd.away
  }
  else resetidle
}
alias _aa.chk {
  if ((!$hget(pnp.config,autoaway)) || ($hget(pnp,autoaway.count))) return
  ; Check idle times on all non-away connected servers; if all are over max set away
  var %num = $scon(0),%found
  while (%num >= 1) {
    if (($scon(%num).server) && (!$hget(pnp. $+ $scon(%num),away))) {
      inc %found
      if ($scon(%num).idle < $hget(pnp.config,autoaway.time)) return
    }
    dec %num
  }
  if (%found) aa.popup
}
alias -l aa.popup {
  if ($_cfgi(autoaway.ask)) {
    _ssplay AwayAuto Away 1
    _dialog -mdo autoaway autoaway
    hadd pnp autoaway.count 16
    .timer.aawarning -io 0 1 aa.upd
  }
  else autoaway now
}
alias -l aacancel scid -a resetidle | .timer.aawarning off | hdel pnp autoaway.count
alias -l aa.upd {
  if ($dialog(autoaway) == $null) { aacancel | return }
  hdec pnp autoaway.count
  if ($hget(pnp,autoaway.count) == 0) {
    hdel pnp autoaway.count
    dialog -x autoaway
    autoaway now nosound
  }
  else did -o autoaway 102 1 $hget(pnp,autoaway.count) seconds
}
; autoaway [+/-qlp] [on|off|#|now]
alias autoaway {
  var %act = $1
  if ($left($1,1) isin +-) {
    var %modes = $_fixmode($1)
    if (q isin %modes) {
      _cfgw autoaway.quiet $_convmode(%modes,q)
      dispa Quiet auto-away is now $:b($_tf2o($_convmode(%modes,q)))
    }
    if (p isin %modes) pager auto $iif(. isin %modes,q,$_tf2o($_convmode(%modes,p)))
    if (l isin %modes) awaylog auto $_tf2o($_convmode(%modes,l))
    if ($2) %act = $2 | else return
  }
  if (%act == now) {
    .timer.aawarning off
    hdel pnp autoaway.count
    if ($2 == $null) _ssplay AwayAuto Away 1
    away -o+fk $+ $iif($_cfgi(autoaway.pager),p,-p) $+ $iif($_cfgi(autoaway.log),+l,-l) $+ $iif($_cfgi(autoaway.quiet),+q,-q) $msg.compile($_msg(autoaway),&min&,$calc($hget(pnp.config,autoaway.time) / 60))
  }
  else {
    if (%act isnum) {
      if ((%act > 0) && (%act isnum)) { `set autoaway.time %act * 60 | `set autoaway 1 }
      else { `set autoaway.time 600 | `set autoaway 0 }
    }
    elseif (%act) `set autoaway $_o2tf(%act)
    if ($hget(pnp.config,autoaway)) dispa Auto-away is enabled after $:t($calc($hget(pnp.config,autoaway.time) / 60)) min
    else dispa Auto-away is disabled
  }
}

alias -l _convpager if ((+.+p isin $1) || (-.-p isin $1)) return quiet | else return $_convmode($1,p,$2)

; away [+/-mode] [reason]
; mode contains q)uiet l)ogging p)ager s)ounds off b)eeps off m)essage privately c)hannel message n)ick r)epeating as +/- (ex +p-lq) .p for quiet pager
; mode contains o)ne server only; a)sk to ask about reason even if given; f)orget to not remember as recent away msg k) skip away sound
alias qa if ($left($1,1) isin -+) away $1 $+ +q $2- | else away +q $1-
alias a away $1-
alias away {
  var %awmode,%reason

  ; Determine settings and reason
  if ($left($1,1) isin -+) {
    %awmode = $_fixmode($1)
    %reason = $2-
  }
  else {
    %awmode = +
    %reason = $1-
  }

  ; Individual settings
  var %pager = $_convpager(%awmode,$_cfgi(away.pager))
  var %log = $_convmode(%awmode,l,$_cfgi(away.log))
  var %quiet = $_convmode(%awmode,q,$_not($show))
  var %beep = $_convmode(%awmode,b,$_cfgi(away.beepoff))
  var %snd = $_convmode(%awmode,s,$_cfgi(away.sndoff))
  var %oneserver = $_convmode(%awmode,o,$_not($_cfgi(away.allconnect)))

  ; popup to change pager, log, quiet, oneserver, and reason?
  if ((%reason == $null) || (+a isin %awmode)) {
    set -u1 %.pager %pager
    set -u1 %.log %log
    set -u1 %.quiet %quiet
    set -u1 %.oneserver %oneserver
    set -u1 %.reason %reason
    _ssplay Question
    %reason = $$dialog(away,away,-4)
    %pager = %.pager
    %log = %.log
    %quiet = %.quiet
    %oneserver = %.oneserver
    unset %.pager %.log %.quiet %.oneserver
  }
  %awmode = $remove(%awmode,+q,-q) $+ $iif(%quiet,+q,-q)

  ; Stuff global to all connections- logging, pager, ebeeps, sound, dqwindow
  hadd pnp logging %log
  if (%log) .enable #awaylog
  hadd pnp pager %pager
  var %old = $hget(pnp,away)
  if (%old) {
    if ($gettok(%old,1,32)) .ebeeps on
    if ($gettok(%old,2,32)) _blackbox .sound on
  }
  else {
    ; Reset pager and away log if we weren't away anywhere
    if ($hget(pnp,newpages) > 0) pager v 0 x
    else .pager f
    hadd pnp awaylog $_temp(awy)
    if ($_cfgi(awaylog.clear)) .remove $hget(pnp,awaylog)
    hdel -w pnp awaylog.*
    hadd pnp awaylog.^ 0
  }  
  if ((%beep) && ($_optn(3,28))) .ebeeps off
  else %beep = 0
  if ((%snd) && ($_optn(3,19))) _blackbox .sound off
  else %snd = 0
  hadd pnp away %beep %snd
  if ($_cfgi(away.dq)) .dqwindow on

  ; Now do each connection, or just the current one
  ; Count the number we set and/or change on
  var %cid = $cid,%scon = $scon(0),%setaway = 0,%changedaway = 0,%closedquery = 0,%deopped = 0,%awayon
  if (!%oneserver) %cid = $scon(%scon)

  ; (so it's the same for all servers)
  var %ctime = $ctime

  :doconnection
  var %nonick = 0,%away,%net = $hget(pnp. $+ %cid,net)
  scid %cid
  if (%net == Offline) %net = (offline)
  %awayon = %awayon $+ , %net

  ; Already away?
  %old = $hget(pnp. $+ %cid,away)
  if (%old) {
    ; Preserve old nick change and away time
    if (+n isin $gettok(%old,3,32)) {
      if (n !isin %awmode) %awmode = %awmode $+ +n
      %nonick = 1
    }
    %away = $gettok(%old,1-2,32) %awmode
    if (%changedaway == 0) %changedaway = %net
    elseif (%changedaway isnum) inc %changedaway
    else %changedaway = 2
  }
  else {
    ; default nick change?
    if ((n !isin %awmode) && ($_cfgi(away.chnick))) %awmode = %awmode $+ +n
    %away = $me %ctime %awmode
    ; Close queries?
    if ($_cfgi(away.closeq)) {
      if ($query(0)) {
        inc %closedquery $query(0)
        close -m
      }
      dqwindow hide
    }
    ; Deops?
    if (($_cfgi(away.deop)) && ($server) && ($chan(0))) {
      var %num = $chan(0)
      while (%num >= 1) {
        if (($me isop $chan(%num)) || ($me ishop $chan(%num))) {
          _linedance .raw mode $chan(%num) - $+ $iif($me isop $chan(%num),o) $+ $iif($me ishop $chan(%num),h) $iif($me isop $chan(%num),$me) $iif($me ishop $chan(%num),$me)
          inc %deopped
        }
        dec %num
      }
    }
    if (%setaway == 0) %setaway = %net
    elseif (%setaway isnum) inc %setaway
    else %setaway = 2
  }

  hadd pnp. $+ %cid away %away %reason
  hdel -w pnp. $+ %cid -awayword.*
  hadd pnp. $+ %cid title $_cfgi(title.away)

  ; Set away and mode
  if ($server) {
    ; Change mode if not already away
    if ($away == $false) {
      if ($modeto($_cfgi(umode),$_cfgi(uaway))) umode $ifmatch
    }
    _upd.away
  }
  ; Message
  .timer.awayrep. $+ %cid off
  if (+q !isin %awmode) {
    var %flags = -a $+ $iif($_convmode(%awmode,c,$_cfgi(away.chan)),c) $+ $iif($_convmode(%awmode,m,$_cfgi(away.msg)),qd)
    _domm %flags $iif($_cfgi(away.act),describe,msg) $_awayformat(away)
    if ($_convmode(%awmode,r,$_cfgi(away.rep))) .timer.awayrep. $+ %cid -o 0 $iif($_cfgi(away.delay) > 2,$calc($_cfgi(away.delay) * 60),300) _awayrep %flags    
  }
  ; nickname
  if ((+n isin %awmode) && (!%nonick)) {
    var %nicklen = $iif($hget(pnp. $+ %cid,-nicklen),$ifmatch,9)
    if ($_cfgi(away.nick)) {
      ; Shorten &me& to fit in nick length, if possible; otherwise, just use full nick
      var %nick = $replace($ifmatch,&reason&,$gettok(%reason,1,32))
      if ($len($remove(%nick,&me&)) < %nicklen) %nick = $replace(%nick,&me&,$left($me,$calc(%nicklen - $ifmatch)))
      else %nick = $replace(%nick,&me&,$me)
    }
    else %nick = $left($me,$calc(%nicklen - 4)) $+ Away
    if (%nick !=== $me) nick %nick
  }

  ; Next server
  if ((!%oneserver) && (%scon > 1)) {
    dec %scon
    %cid = $scon(%scon)
    goto doconnection
  }
  scid -r

  ; Log
  if (%setaway isnum) {
    if (%setaway > 0) _awaylog - 9 0 ««« Set away on %setaway connections ( $+ %reason $+ )
  }
  else _awaylog - 9 0 ««« Set away on %setaway ( $+ %reason $+ )
  if (%changedaway isnum) {
    if (%changedaway > 0) _awaylog - 9 0 ««« Reset away on %changedaway connections ( $+ %reason $+ )
  }
  else _awaylog - 9 0 ««« Reset away on %changedaway ( $+ %reason $+ )
  if (%closedquery) _awaylog - 9 0 ««« Closed %closedquery query windows
  if (%deopped) _awaylog - 9 0 ««« Deopped in %deopped channels

  ; Sound, display
  if (+k !isin %awmode) _ssplay Away 1
  %pager = $upper($iif(%pager == quiet,quiet,$_tf2o(%pager)))
  %log = $upper($_tf2o(%log))
  if ($numtok(%awayon,32) < 3) disp You are now away on $gettok(%awayon,2-,32) $+ . $chr(40) $+ %reason $+ $chr(41) Pager: %pager / Logging: %log
  else disp You are now away on all connections. $chr(40) $+ %reason $+ $chr(41) Pager: %pager / Logging: %log
  if (+f !isin %awmode) _recent2 away 9 %reason
}
alias -l _awayrep { _domm $1 $iif($_cfgi(away.act),describe,msg) $_awayformat(awayrep) }

; back [+/-mode] [note]
; mode contains q)uiet p)ager m)essage privately c)hannel message n)ick .p for quiet pager
; mode contains o)ne server only; k) skip back sound
alias back {
  ; Modes
  var %mode,%reason,%note
  if ($left($1,1) isin -+) {
    %mode = $_fixmode($1)
    %reason = $2-
  }
  else {
    %mode = +
    %reason = $1-
  }
  %note = %reason
  if ($show == $false) %mode = %mode $+ +q
  var %oneserver = $_convmode(%mode,o,0)

  ; If not doing one server, check if we have a variety of away times/msgs
  ; If so, ask to do a single server, or do a single server if config says to do single servers
  if (!%oneserver) {
    var %scon = $scon(0)
    var %found,%diff
    while (%scon >= 1) {
      if ($hget(pnp. $+ $scon(%scon),away)) {
        var %this = $gettok($ifmatch,2,32) $gettok($ifmatch,4-,32)
        if ((%found) && (%found != %this)) {
          %diff = 1
          break
        }
        %found = %this
      }
      dec %scon
    }
    if (%diff) {
      if (!$_cfgi(away.allconnect)) %oneserver = 1
      else %oneserver = $_yesno(1,Set back on this server only?)
    }
  }

  ; Setting back when not away?
  ; (not away on the one server if only doing one)
  ; (not away on any server if doing all)
  var %away = $hget(pnp,away),%fakeback
  if (((%oneserver) && (!$hget(pnp. $+ $cid,away))) || ((!%oneserver) && (!%away))) {
    _okcancel 0 You are not away- Still announce back?
    ; Fake as if we were away (and clear back note)
    %away = 0 0
    %fakeback = 1
    var %note
  }

  ; Ask if we should return quietly?
  if (q !isin %mode) {
    var %ask
    ; See if any of the applicable servers have +q set
    if (%oneserver) {
      if (+q isin $gettok($hget(pnp. $+ $cid,away),3,32)) %ask = 1
    }
    else {
      var %scon = $scon(0)
      while (%scon >= 1) {
        if (+q isin $gettok($hget(pnp. $+ $scon(%scon),away),3,32)) %ask = 1
        dec %scon
      }
    }
    if (%ask) {
      %mode = %mode $+ $iif($_yesno(1,You set away quietly- Return quietly too?),+q,-q)
    }
  }

  ; Check if we will be back on all servers after this
  var %backall = 1
  if (%oneserver) {
    var %scon = $scon(0)
    while (%scon >= 1) {
      if (($scon(%scon) != $cid) && ($hget(pnp. $+ $scon(%scon),away))) %backall = 0
      dec %scon
    }
  }

  ; Some global stuff- pager, ebeeps, sound, dqwindow (only if back on all)
  if (%backall) {
    hadd pnp pager $_convpager(%mode,$_cfgi(back.pager))
    if ($_cfgi(away.dq)) .dqwindow off
    if ($gettok(%away,1,32)) .ebeeps on
    if ($gettok(%away,2,32)) .sound on
  }

  ; Do each connection, or just the current one
  ; Count the number we set back on
  var %cid = $cid,%scon = $scon(0),%backon,%longestgone = 0,%allreasons
  if (!%oneserver) %cid = $scon(%scon)

  :doconnection
  var %net = $hget(pnp. $+ %cid,net),%back = $hget(pnp. $+ %cid,away),%gone
  scid %cid

  ; Were we away? (or faking it)
  if ((%back) || (%fakeback)) {
    if (%fakeback) {
      %back = away $me $ctime + $iif(%reason,%reason,away)
      %gone = ??
    }
    else {
      if ($calc($ctime - $gettok(%back,2,32)) > %longestgone) %longestgone = $ifmatch
      %gone = $_dur($calc($ctime - $gettok(%back,2,32)))
    }

    ; Try to track a single reason that we were away
    if (!%allreasons) %allreasons = $gettok(%back,4-,32)
    elseif (%allreasons != $gettok(%back,4-,32)) %allreasons = various reasons

    if (%net == Offline) %net = (offline)
    %backon = %backon $+ , %net

    if ($server) {
      hinc pnp. $+ $cid -waitingback
      .raw away
      if ($modeto($_cfgi(uaway),$_cfgi(umode))) umode $ifmatch
    }
    if ($_convmode(%mode,n,$_convmode($gettok(%back,3,32),n))) {
      if ($gettok(%back,1,32) !=== $me) {
        nick $ifmatch
        .timer.nicktoofast. $+ %cid off
      }
    }
    if (+q !isin %mode) {
      _domm -a $+ $iif($_convmode(%mode,c,$_convmode($gettok(%back,3,32),c,$_cfgi(away.chan))),c) $+ $iif($_convmode(%mode,m,$_convmode($gettok(%back,3,32),m,$_cfgi(away.msg))),qd) $iif($_cfgi(away.act),describe,msg) $msg.compile($_msg($iif(%note,backnote,back)),&reason&,$gettok(%back,4-,32),&pager&,$_tf2o($hget(pnp,pager)),&logging&,Off,&when&,$_time,&awaytime&,%gone,&awaywhen&,$_time($gettok(%back,2,32)),&note&,%note)
    }
    resetidle
  }

  hdel pnp. $+ %cid away
  hdel pnp. $+ %cid timedclose
  hdel -w pnp. $+ %cid -awayword.*
  hdel -w pnp. $+ %cid -awayremind.*
  .timer.dtqc. $+ %cid off
  .timer.awayrep. $+ %cid off
  hadd pnp. $+ %cid title $_cfgi(title.here)

  ; Next server
  if ((!%oneserver) && (%scon > 1)) {
    dec %scon
    %cid = $scon(%scon)
    goto doconnection
  }
  scid -r

  ; Log back status
  if (%longestgone == 0) %longestgone = ??
  else %longestgone = $_dur(%longestgone)
  if ($numtok(%backon,32) < 3) _awaylog - 9 0 »»» Set back on $gettok(%backon,2,32) $chr(40) $+ gone %longestgone $+ $chr(41)
  else _awaylog - 9 0 »»» Set back on $calc($numtok(%backon,32) - 1) connections $chr(40) $+ gone %longestgone $+ $chr(41)

  ; Sound, display msg, log, pager
  if (+ !isin %mode) _ssplay Back 1
  if (%backall) disp You are no longer away on any connections. $chr(40) $+ %allreasons $+ $chr(41) Gone: %longestgone
  else disp You are no longer away on $gettok(%backon,2-,32) $+ . $chr(40) $+ %allreasons $+ $chr(41) Gone: %longestgone

  if ($hget(pnp,logging)) {
    var %logged
    if ($hget(pnp,awaylog.?)) %logged = , $:b($hget(pnp,awaylog.?)) message $+ $chr(40) $+ s $+ $chr(41)
    if ($hget(pnp,awaylog.!)) %logged = %logged $+ , $:b($hget(pnp,awaylog.!)) notice $+ $chr(40) $+ s $+ $chr(41)
    if ($hget(pnp,awaylog.+)) %logged = %logged $+ , $:b($hget(pnp,awaylog.+)) channel msg $+ $chr(40) $+ s $+ $chr(41)
    if ($hget(pnp,awaylog.@)) %logged = %logged $+ , $:b($hget(pnp,awaylog.@)) event $+ $chr(40) $+ s $+ $chr(41)
    if (%logged) disp Logged while away- $gettok(%logged,2-,32) - $:s(CtrlF12) to view away log
    else disp Nothing was logged while you were away.
  }
  ; flush pager only if back on all
  if ($hget(pnp,newpages) > 0) pager v 0 x
  elseif (%backall) .pager f

  ; More global stuff- logging, away var (if back on all)
  if (%backall) {
    hadd pnp logging 0
    .disable #awaylog
    hdel pnp away
  }
}
alias qb if ($left($1,1) isin -+) back $1 $+ +q $2- | else back +q $1-

; /b may be /ban or /back
alias b {
  if ($_cfgi(b.ban)) {
    if (($1 == $null) && ($hget(pnp. $+ $cid,away))) {
      _ssplay Confirm
      $$dialog(banorback1,banorback,-4)
    }
    else ban $1-
  }
  else {
    if (((* isin $1) && (. isin $1)) || ($1 ischan)) {
      _ssplay Confirm
      $$dialog(banorback2,banorback,-4) $1-
    }
    else back $1-
  }
}

alias -l _upd.away {
  if ($server) {
    ; (if waiting on a /back, don't set just yet)
    if ($hget(pnp. $+ $cid,-waitingback)) hadd pnp. $+ $cid -waitingaway $_awayformat($iif($hget(pnp,pager),wawayp,waway))
    else _linedance .raw away : $+ $_awayformat($iif($hget(pnp,pager),wawayp,waway))
  }
}
on me:*:NICK:if ($hget(pnp. $+ $cid,away)) .timer -m 1 0 _upd.away

; Pager
ctcp &*:PAGE:?:_paged CTCP * $2- | if ($result) _linedance _qcr $nick PAGE $_pagereply
on &^*:TEXT:!page *:#:if ($2 == $me) { _paged channel $+ $chan $chan $3- | if ($result) _linedance _qnotice $nick *** $_pagereply *** }
on &^*:TEXT:!page*:?:_paged privatemessage $nick $2- | if ($result) _linedance _qnotice $nick *** $_pagereply ***
on &^*:CHAT:!page*:_paged dccchat =$nick $2- | if ($result) _linedance .msg =$nick *** $_pagereply ***
on &^*:CHAT:PAGE:_paged dccchat =$nick $remove($2-,$chr(1)) | if ($result) _linedance _qcr =$nick PAGE $_pagereply
alias -l _pagereply if ($msg.compile($_msg($iif($hget(pnp,pager),pageron,pageroff)),&nick&,$nick)) return $ifmatch | $$$
alias -l _paged {
  haltdef
  hinc -u20 pnp.flood. $+ $cid recd.page
  hinc -u10 pnp.flood. $+ $cid recd.page. $+ $site
  if (($hget(pnp.flood. $+ $cid,recd.page) > 3) || ($hget(pnp.flood. $+ $cid,recd.page. $+ $site) > 2)) return 0
  var %error = 0
  if (($hget(pnp.flood. $+ $cid,recd.page) > 2) || ($hget(pnp.flood. $+ $cid,recd.page. $+ $site) > 1)) %error = 1

  var %pager
  if (%error) %pager = being ignored
  else %pager = $upper($iif($hget(pnp,pager),On,Off))
  $iif($chan ischan,disprc $chan,dispr $2) ¢ Paged by $:t($nick) via $_p2s($1) $chr(40) $+ Pager is %pager $+ $chr(41) $iif($3-,Message- $:q($3-))
  if (!$hget(pnp,pager)) return $_not(%error)

  hinc pnp newpages
  hinc pnp totalpages
  write $_temp(pag) $nick $1 $ctime $2 $fulladdress $cid $3-

  if (($_cfgi(pager.classic)) || (!$dialog(pager))) pager v $hget(pnp,totalpages) s
  else pager v $did(pager,198) s

  return $_not(%error)
}

; /pager [a[way]|h[ere]|auto] [on|off|q[uiet]]
; /pager v[iew] [n] [x|s]
; /pager f[lush]
; (x means clear pages on close; s plays pager sound)
alias pager {
  if (f* iswm $1) {
    hadd pnp totalpages 0
    hadd pnp newpages 0
    .remove $_temp(pag)
    dispa Pager flushed. $chr(40) $+ any saved pages cleared $+ $chr(41)
    return
  }
  if (v* iswm $1) {
    if ($hget(pnp,totalpages) == 0) _error No pages to view.You have not been paged since you last cleared your pager.

    var %curr,%num,%page,%where,%nick,%offs,%msg,%ln,%logged,%win,%bit,%cid

    if (($2 isnum) && (($2 >= 1) && ($2 <= $hget(pnp,totalpages)))) %curr = $2
    else %curr = $calc($hget(pnp,totalpages) + 1 - $iif($hget(pnp,newpages),$hget(pnp,newpages),1))
    if (%curr > $calc($hget(pnp,totalpages) - $hget(pnp,newpages))) hadd pnp newpages $calc($hget(pnp,totalpages) - %curr)
    if (($2 == x) || ($3 == x)) hadd pnp clear.pager 1

    if ($_cfgi(pager.classic)) {
      hadd pnp newpages 0
      if ($window(@Pager)) clear @Pager
      else {
        _window 2.1 -lz +l @Pager $_center(350,350) @Pager
        hdel pnp clear.pager
      }

      %num = 1
      :loopC

      %page = $read($_temp(pag),tn,%num)
      %where = $gettok(%page,4,32)
      %nick = $gettok(%page,1,32)
      %cid = $gettok(%page,6,32)
      %bit = $iif(%num == %curr,-a)

      aline %bit @Pager You were paged by $:t(%nick) via $_p2s($gettok(%page,2,32)) at $_datetime($gettok(%page,3,32))
      if ($gettok(%page,7-,32)) aline %bit @Pager $:b(Message) $+ - $:h($gettok(%page,7-,32))

      scid %cid
      if (($hget(pnp. $+ %cid,away)) && ($hget(pnp,clear.pager))) || ((!$hget(pnp. $+ %cid,away)) && (!$hget(pnp,clear.pager))) %logged = 0
      elseif (=* iswm %where) { %win = chat %nick | %logged = $calc($line(%win,0) - 3) }
      elseif ($query(%nick)) { %win = %nick | %logged = $line(%nick,0) }
      else {
        window -hn @.loghide
        awaylog pn ! %cid %nick @.loghide
        %win = @.loghide
        %logged = $line(@.loghide,0)
      }
      if (%logged) {
        %offs = $iif(=* iswm %where,3,0)
        %ln = 1
        :loopCL
        aline %bit @Pager $strip($line(%win,$calc(%ln + %offs)))
        if (%ln >= 5) aline %bit @Pager ... ... ...
        elseif (%ln < %logged) { inc %ln | goto loopCL }
      }
      window -c @.loghide
      scid -r

      if (%num < $hget(pnp,totalpages)) { aline @Pager $::: | inc %num | goto loopC }

      titlebar @Pager - $hget(pnp,totalpages) total pages
    }

    else {
      if ($dialog(pager) == $null) { dialog -md pager pager | hdel pnp clear.pager }

      did -o pager 1 1 Page %curr of $hget(pnp,totalpages) $iif($hget(pnp,clear.pager),(logged))
      did -o pager 198 1 %curr
      %page = $read($_temp(pag),tn,%curr)
      %nick = $gettok(%page,1,32)
      %where = $gettok(%page,4,32)
      %cid = $gettok(%page,6,32)
      %msg = $strip($gettok(%page,7-,32))
      did -o pager 2 1 %nick
      did -o pager 3 1 $iif(%msg == $null,(not given),%msg)
      did -o pager 197 1 %cid
      did -o pager 199 1 $gettok(%page,5,32)

      scid %cid
      if (($hget(pnp. $+ %cid,away)) && ($hget(pnp,clear.pager))) || ((!$hget(pnp. $+ %cid,away)) && (!$hget(pnp,clear.pager))) %logged = 0
      elseif (=* iswm %where) { %win = chat %nick | %logged = $calc($line(%win,0) - 3) }
      elseif ($query(%nick)) { %win = %nick | %logged = $line(%nick,0) }
      else {
        window -hn @.loghide
        awaylog pn ! %cid %nick @.loghide
        %win = @.loghide
        %logged = $line(@.loghide,0)
      }
      did -ra pager 4 You were paged by %nick via $_p2s($gettok(%page,2,32)) at $_datetime($gettok(%page,3,32)) $+ $crlf

      if (%curr < $hget(pnp,totalpages)) { did -e pager 102 | did -t pager 102 }
      else { did -b pager 102 | did -t pager 103 }
      if (%curr > 1) did -e pager 101
      else did -b pager 101

      if (%logged) {
        did -a pager 4 %logged logged message $+ $chr(40) $+ s $+ $chr(41) from %nick $+ $crlf

        %offs = $iif(=* iswm %where,3,0)
        %ln = 1
        :loopL
        did -a pager 4 $strip($line(%win,$calc(%ln + %offs))) $+ $crlf
        if (%ln >= 10) did -a pager 4 ... ... ...
        elseif (%ln < %logged) { inc %ln | goto loopL }

        did -c pager 4 1
      }

      window -c @.loghide
      scid -r

      if ($hget(pnp,clear.pager)) dialog -t pager Pager (viewing logged pages)

      dialog -v pager
      dialog -o pager
      dialog -n pager
    }

    if (($2 == s) || ($3 == s)) _ssplay Pager 1
    return
  }
  if ($1 == auto) { var %cfg = autoaway.pager }
  elseif (a* iswm $1) { var %cfg = away.pager }
  elseif (h* iswm $1) { var %cfg = back.pager }
  else {
    if (($1 == on) || ($1 == off) || ($1 == on) || ($1 == off)) hadd pnp pager $_o2tf($1)
    if (q* iswm $1) hadd pnp pager quiet
    ; Update away on any away connections; if any found, we use 'until_back' below
    var %num = $scon(0),%found
    while (%num >= 1) {
      scon %num
      if ($hget(pnp. $+ $cid,away)) {
        _upd.away
        %found = 1
      }
      dec %num
    }
    scon -r
    var %status = $:b($iif($hget(pnp,pager) == quiet,Quiet,$_tf2o($hget(pnp,pager))))
    dispa Pager is %status ( $+ $iif(%found,until you return from away,until you set away) $+ )
    return
  }
  if (($2 == on) || ($2 == off) || ($1 == on) || ($1 == off)) _cfgw %cfg $_o2tf($2)
  if (q* iswm $2) _cfgw %cfg quiet
  var %status = $:b($iif($_cfgi(%cfg) == quiet,Quiet,$_tf2o($_cfgi(%cfg))))
  dispa $iif(%cfg == away.pager,Pager will be %status when you set away,$iif(%cfg == back.pager,Pager will be %status when you are not away,Pager will be %status when you are auto-away from idle))
}
on *:CLOSE:@Pager:_pagerclose
alias _pagerclose {
  if ($hget(pnp,clear.pager)) {
    hadd pnp totalpages 0
    hadd pnp newpages 0
    .remove $_temp(pag)
    hdel pnp clear.pager
  }
}

; Logging

on *:SIGNAL:PNP.TRANSLATE:{ if ($hget(pnp,logging)) .enable #awaylog }
on *:START:{ .disable #awaylog }

; $1 = ? query @ event ! notice + chanmsg - don't count
; $2 = event codes 1 priv msg 2 priv action 3 opnotice 4 priv notice 5 op activity on you 6 by you 7 other op activity
; 8 notify 9 away status 10 invite 11 DCC 12 connection 13 chan msg 14 chan action
; $3 = cid or 0 for general events
alias _awaylog {
  var %log = $remove($timestamp,$chr(32)) $chr(91) $+ $iif($3 == 0,General,$hget(pnp. $+ $3,net)) $+ $chr(93) $4-
  write $hget(pnp,awaylog) $2 $3 %log
  if ($hget(pnp.config,awaylog.perm)) write " $+ $logdir $+ $mklogfn(@Awaylog) $+ " %log
  hinc pnp awaylog. $+ $1
  if ($1 isin ?!+) hinc pnp awaylog.^
}
alias _dtqc {
  if ($hget(pnp. $+ $cid,timedclose) == $null) return
  if (($idle < 15) || (($appactive) && ($idle < 30))) { .timer.dtqc. $+ $cid 1 10 _dtqc | return }
  if ($_optn(1,18) == 1) hadd pnp. $+ $cid timedclose $remtok($hget(pnp. $+ $cid,timedclose),$active,1,32)
  if ($hget(pnp. $+ $cid,timedclose)) close -m $ifmatch
  hdel pnp. $+ $cid timedclose
}
on *:INPUT:?:hadd pnp. $+ $cid timedclose $remtok($hget(pnp. $+ $cid,timedclose),$target,1,32)
on *:CLOSE:?:if ($window(Status Window)) hadd pnp. $+ $cid timedclose $remtok($hget(pnp. $+ $cid,timedclose),$target,1,32)
#awaylog on
on *:DISCONNECT:if ($hget(pnp. $+ $cid,away)) { var %lagged | if ($hget(pnp. $+ $cid,-self.lag) isnum) %lagged = (self-lag $ifmatch $+ ) | _awaylog @ 12 $cid ««« You disconnected from $server : $port %lagged }
on *:KICK:#:{
  if (!$hget(pnp. $+ $cid,away)) return
  if ((($hget(pnp.config,awaylog.chan) < 1) || ($hget(pnp.config,awaylog.chan) == $null)) && ($knick != $me)) return
  if ($knick == $me) _awaylog @ 5 $cid ( $+ $chan $+ ) ««« $nick kicked $:b($knick) ( $+ $1- $+ )
  elseif ($nick == $me) _awaylog @ 6 $cid ( $+ $chan $+ ) *** $:b($nick) kicked $knick ( $+ $1- $+ )
  elseif (($hget(pnp.config,awaylog.chan) > 2) || (($hget(pnp.config,awaylog.chan) > 1) && (($me isop $chan) || ($me ishop $chan)))) _awaylog @ 7 $cid ( $+ $chan $+ ) *** $nick kicked $knick ( $+ $1- $+ )
}
on *:BAN:#:_logban +
on *:UNBAN:#:_logban -
alias -l _logban {
  if (!$hget(pnp. $+ $cid,away)) return
  if (($hget(pnp.config,awaylog.chan) < 1) || ($hget(pnp.config,awaylog.chan) == $null)) return
  if ($banmask iswm $hget(pnp. $+ $cid,-myself)) _awaylog @ 5 $cid ( $+ $chan $+ ) *** $iif($1 == +,$nick banned $:b($me),$nick unbanned $:b($me)) ( $+ $banmask $+ )
  elseif ($nick == $me) _awaylog @ 6 $cid ( $+ $chan $+ ) *** $iif($1 == +,$:b($nick) banned $banmask,$:b($nick) unbanned $banmask)
  elseif (($hget(pnp.config,awaylog.chan) > 2) || (($hget(pnp.config,awaylog.chan) > 1) && (($me isop $chan) || ($me ishop $chan)))) _awaylog @ 7 $cid ( $+ $chan $+ ) *** $iif($1 == +,$nick banned $banmask,$nick unbanned $banmask)
}
on *:SERVEROP:#:_logop +
on *:OP:#:_logop +
on *:DEOP:#:_logop -
on *:OWNER:#:_logop +
on *:DEOWNER:#:_logop -
alias -l _logop {
  if (!$hget(pnp. $+ $cid,away)) return
  if (($hget(pnp.config,awaylog.chan) < 1) || ($hget(pnp.config,awaylog.chan) == $null)) return
  if ($opnick == $me) _awaylog @ 5 $cid ( $+ $chan $+ ) *** $iif($1 == +,$nick opped $:b($opnick),$nick deopped $:b($opnick))
  elseif ($nick == $me) _awaylog @ 6 $cid ( $+ $chan $+ ) *** $iif($1 == +,$:b($nick) opped $opnick,$:b($nick) deopped $opnick)
  elseif (($hget(pnp.config,awaylog.chan) > 2) || (($hget(pnp.config,awaylog.chan) > 1) && (($me isop $chan) || ($me ishop $chan)))) _awaylog @ 7 $cid ( $+ $chan $+ ) *** $iif($1 == +,$nick opped $opnick,$nick deopped $opnick)
}
on *:HELP:#:_loghop +
on *:DEHELP:#:_loghop -
alias -l _loghop {
  if (!$hget(pnp. $+ $cid,away)) return
  if (($hget(pnp.config,awaylog.chan) < 1) || ($hget(pnp.config,awaylog.chan) == $null)) return
  if ($hnick == $me) _awaylog @ 5 $cid ( $+ $chan $+ ) *** $iif($1 == +,$nick halfopped $:b($hnick),$nick dehalfopped $:b($hnick))
  elseif ($nick == $me) _awaylog @ 6 $cid ( $+ $chan $+ ) *** $iif($1 == +,$:b($nick) halfopped $hnick,$:b($nick) dehalfopped $hnick)
  elseif (($hget(pnp.config,awaylog.chan) > 2) || (($hget(pnp.config,awaylog.chan) > 1) && (($me isop $chan) || ($me ishop $chan)))) _awaylog @ 7 $cid ( $+ $chan $+ ) *** $iif($1 == +,$nick halfopped $hnick,$nick dehalfopped $hnick)
}

on me:*:JOIN:#:if ($hget(pnp. $+ $cid,away)) _awaylog @ 5 $cid ( $+ $chan $+ ) »»» Joined channel

on *:CLOSE:=:if ($hget(pnp. $+ $cid,away)) _awaylog @ 11 0 === $nick DCC chat closed
on *:FILERCVD:*:if ($hget(pnp. $+ $cid,away)) _awaylog @ 11 0 === Received $filename from $nick
on *:FILESENT:*:if ($hget(pnp. $+ $cid,away)) _awaylog @ 11 0 === Sent $filename to $nick
on *:GETFAIL:*:if ($hget(pnp. $+ $cid,away)) _awaylog @ 11 0 === Failed to receive $filename from $nick
on *:SENDFAIL:*:if ($hget(pnp. $+ $cid,away)) _awaylog @ 11 0 === Failed to send $filename to $nick

alias _doahl { 
    if (($3 isnum) && ($len($4) < 1)) { return } 
    if ($highlight($3-)) {
    var %word
    %word = [ [ $ifmatch ] ]
    _awaylog + $1 $cid ( $+ $chan $+ ) $_p2s($2) $replace($3-,%word,$:b(%word))
    return
  }
  var %todo = $hget(pnp.config,awaywords.words),%check,%num
  %todo = $addtok(%todo,$me,44)
  var %num = $numtok(%todo,44)
  :loop2
  %check = [ [ $gettok(%todo,%num,44) ] ]
  if (%check isin $3-) _awaylog + $1 $cid ( $+ $chan $+ ) $_p2s($2) $replace($3-,%check,$:b(%check))
  elseif (%num > 1) { dec %num | goto loop2 }
}

; Notify/Unnotify/etc
alias _away.logit if ($hget(pnp. $+ $3,away)) _awaylog $1-
#awaylog end
alias _away.logit return
alias _away.remind {
  if (($hget(pnp.config,away.remind)) && ($hget(pnp. $+ $cid,-awayremind. $+ $site) == $null) && ($hget(pnp. $+ $cid,-awayremind.!) == $null)) {
    hinc pnp. $+ $cid -awayremind. $+ $site
    hinc -u5 pnp. $+ $cid -awayremind.!
    _linedance _qnotice $nick $_awayformat(remind)
  }
}

; Away log display
; /awaylog [auto] on|off|f[lush]|[pncodum [@Window/! [cid/0] [nick/#chan [nickwin]]]]
; Examples of latter:
; /awaylog -pncodum @window [cid] <-- outputs awaylog to window
; /awaylog -pncodum ! cid/0 nick <-- opens a query and outputs what they said
; /awaylog -pncodum @window cid/0 #chan <-- outputs #chan data to window
; /awaylog -pncodum ! cid/0 nick @nickwin <-- outputs (echo) nickname data to @nickwin
alias awaylog {
  if ($1 == auto) {
    if (($2 == on) || ($2 == off) || ($2 == on) || ($2 == off)) _cfgw autoaway.log $_o2tf($2)
    dispa Away logging is $:b($_tf2o($_cfgi(autoaway.log))) when you are auto-away from idle
    return
  }
  if (($1 == on) || ($1 == on)) {
    if ($hget(pnp,away) == $null) {
      var %status = $:b(On)
      _cfgw away.log 1
      dispa Away logging will be %status when you are away
      return
    }
    hadd pnp logging 1
    .enable #awaylog
    var %status = On
    _awaylog - 9 0 »»» Away logging is now %status
    dispa Away logging is now $:b(%status) (Until you return from away)
    ; Update away on any away connections
    var %num = $scon(0)
    while (%num >= 1) {
      scon %num
      if ($hget(pnp. $+ $cid,away)) _upd.away
      dec %num
    }
    scon -r
    return
  }
  elseif (($1 == off) || ($1 == off)) {
    if ($hget(pnp,away) == $null) {
      var %status = $:b(Off)
      _cfgw away.log 0
      dispa Away logging will be %status when you are away
      return
    }
    hadd pnp logging 0
    var %status = Off
    _awaylog - 9 0 ««« Away logging is now %status
    .disable #awaylog
    dispa Away logging is now $:b(%status) (Until you return from away)
    ; Update away on any away connections
    var %num = $scon(0)
    while (%num >= 1) {
      scon %num
      if ($hget(pnp. $+ $cid,away)) _upd.away
      dec %num
    }
    scon -r
    return
  }
  elseif (f* iswm $1) {
    hdel pnp awaylog.*
    hadd pnp awaylog.^ 0
    .remove $hget(pnp,awaylog)
    _awaylog - 9 0 ««« Away log flushed.
    dispa Away log flushed.
    return
  }

  if ($1 == $null) { _recurse awaylog - $+ $iif($_cfgi(awaylog.view),$_cfgi(awaylog.view),pncodum) @AwayLog | return }
  elseif ($2 == $null) { _recurse awaylog $1 @AwayLog | return }
  elseif ($3 == $null) { _recurse awaylog $1-2 0 | return }
  ; Make sure cid exists
  if (($3 != 0) && ($scid($3) != $3)) { _recurse awaylog $1-2 0 $4- | return }
  if ($2 == @AwayLog) _cfgw awaylog.view $remove($1,-)
  var %num = 1,%count = $lines($hget(pnp,awaylog))
  if ((%count == $null) || (%count == 0)) { if ($2 == !) return | _error Your away log is empty.This probably means you have not set away yet. }
  ; Switch to cid for window purposes
  if ($3 != 0) scid $3
  if ($2 == !) { if ($5 == $null) query $4 }
  elseif ($window($2)) { clear $2 | window -a $2 }
  else {
    _window 2.1 -l $+ $iif($3 == 0,z) + $2 $_winpos(10,10,5,12) @AwayLog
    _windowreg $2 _alogclose
  }
  window -hl @.awaylog
  loadbuf @.awaylog $hget(pnp,awaylog)
  ; (tracks lines that weren't shown due to being hidden)
  set -u %.hid 0
  if ($_ischan($4)) {
    var %line,%chan = ( $+ $4 $+ ),@ $+ $4
    :loopC
    %line = $line(@.awaylog,%num)
    if ($istok(%chan,$gettok(%line,5,32),44)) _alcol $1-3 %line
    if (%num < %count) { inc %num | goto loopC }
  }
  elseif ($4) {
    var %line
    :loopQ
    %line = $line(@.awaylog,%num)
    if (($3 == 0) || ($3 == $gettok(%line,2,32))) {
      if (($gettok(%line,5,32) == *) && ($gettok(%line,6,32) == $4)) echo $color(action) -i2 $iif($5,$5,$4) $gettok(%line,3-,32)
      elseif ($gettok(%line,5,32) == < $+ $4 $+ >) echo -i2 $iif($5,$5,$4) $gettok(%line,3-,32)
      elseif ($gettok(%line,5,32) == - $+ $4 $+ -) echo $color(notice) -i2 $iif($5,$5,$4) $gettok(%line,3-,32)
    }
    if (%num < %count) { inc %num | goto loopQ }
  }
  else {
    :loopR
    _alcol $1-3 $line(@.awaylog,%num)
    if (%num < %count) { inc %num | goto loopR }
  }
  window -c @.awaylog
  if ($2 != !) {
    if (%.hid) titlebar $2 - $line($2,0) event $+ $chr(40) $+ s $+ $chr(41) ( $+ %.hid hidden)
    else titlebar $2 - $line($2,0) event $+ $chr(40) $+ s $+ $chr(41) (right-click for options)
    window -b $2
    hadd pnp alog. $+ $2 $1-3
  }
  if ($3 != 0) scid -r
}
; Picks line color for the line and adds (if not filtered) to @AwayLog
; also filters out by cid
alias -l _alcol if (($mid(ppnnoooummdmcc,$4,1) isin $1) && (($3 == 0) || ($3 == $5))) aline $color($gettok(nor a notic notic m m m notif ot inv c info nor a,$4,32)) $2 $6- | else inc %.hid

menu @AwayLog {
  dclick:_subset $active $1
  Flush:awaylog f | _dowclose $active | window -c $active
  View subset:if ($sline($active,1).ln) _subset $active $ifmatch
  -
  New window
  .Show all:awaylog pncodum $_newwin(@Awaylog)
  .-
  .Show private:awaylog p $_newwin(@Awaylog)
  .Show notices:awaylog n $_newwin(@Awaylog)
  .Show channel:awaylog c $_newwin(@Awaylog)
  .-
  .Show op activity:awaylog o $_newwin(@Awaylog)
  .Show DCC:awaylog d $_newwin(@Awaylog)
  .Show notify:awaylog u $_newwin(@Awaylog)
  .Show misc.:awaylog m $_newwin(@Awaylog)
  -
  $iif(p isin $gettok($hget(pnp,alog. $+ $active),1,32),$style(1)) Show private:awaylog $_toggle(p,$hget(pnp,alog. $+ $active))
  $iif(n isin $gettok($hget(pnp,alog. $+ $active),1,32),$style(1)) Show notices:awaylog $_toggle(n,$hget(pnp,alog. $+ $active))
  $iif(c isin $gettok($hget(pnp,alog. $+ $active),1,32),$style(1)) Show channel:awaylog $_toggle(c,$hget(pnp,alog. $+ $active))
  -
  $iif(o isin $gettok($hget(pnp,alog. $+ $active),1,32),$style(1)) Show op activity:awaylog $_toggle(o,$hget(pnp,alog. $+ $active))
  $iif(d isin $gettok($hget(pnp,alog. $+ $active),1,32),$style(1)) Show DCC:awaylog $_toggle(d,$hget(pnp,alog. $+ $active))
  $iif(u isin $gettok($hget(pnp,alog. $+ $active),1,32),$style(1)) Show notify:awaylog $_toggle(u,$hget(pnp,alog. $+ $active))
  $iif(m isin $gettok($hget(pnp,alog. $+ $active),1,32),$style(1)) Show misc.:awaylog $_toggle(m,$hget(pnp,alog. $+ $active))
}
alias _alogclose hdel pnp alog. $+ $1
alias -l _subset {
  var %net = $gettok($line($1,$2),2,32)
  var %type = $gettok($line($1,$2),3,32)
  var %actual = $read($hget(pnp,awaylog),nw,& & $line($1,$2))
  if (%actual) var %cid = $gettok(%actual,2,32)
  else var %cid = 0
  if (%type == ===) awaylog d $_newwin(@Awaylog)
  elseif (%type == (notify)) awaylog u $_newwin(@Awaylog)
  elseif (%type isin »»»«««) awaylog m $_newwin(@Awaylog)
  elseif (@* iswm %type) awaylog ncom $_newwin(@Awaylog) %cid $right(%type,-1)
  elseif ($left(%type,1) == $chr(40)) awaylog ncom $_newwin(@Awaylog) %cid $left($right(%type,-1),-1)
  elseif (%type == *) awaylog pn ! %cid $gettok($line($1,$2),4,32)
  else awaylog pn ! %cid $right($left(%type,-1),-1)
}

; Autodetect back-on-keypress, etc
raw 306:*:if ($hget(pnp. $+ $cid,away) == $null) hadd pnp. $+ $cid $me $ctime +q away | halt
raw 305:*:{
  if ($hget(pnp. $+ $cid,-waitingback)) {
    if ($ifmatch == 1) {
      if ($hget(pnp. $+ $cid,-waitingaway)) .raw away : $+ $ifmatch
      hdel pnp. $+ $cid -waitingback
      hdel pnp. $+ $cid -waitingaway
    }
    else hdec pnp. $+ $cid -waitingback
  }
  elseif ($hget(pnp. $+ $cid,away)) back $iif(+q isin $gettok($ifmatch,3,32),+q)
  halt
}

; General away config msg formatting
; $1 = message to read; $2/$3 optional replacement to do
alias _awayformat {
  var %away = $hget(pnp. $+ $cid,away)
  if (%away) return $msg.compile($_msg($1),&reason&,$gettok(%away,4-,32),&when&,$_time($gettok(%away,2,32)),&awaytime&,$_dur($calc($ctime - $gettok(%away,2,32))),&pager&,$_tf2o($hget(pnp,pager)),&logging&,$_tf2o($hget(pnp,logging)),$2,$3)
  return $msg.compile($_msg($1),&reason&,???,&when&,???,&awaytime&,???,&pager&,$_tf2o($hget(pnp,pager)),&logging&,$_tf2o($hget(pnp,logging)),$2,$3)
}

; Away words

alias _doaww {
  if (($hget(pnp. $+ $cid,-awayword. $+ $site) != $null) || ($hget(pnp. $+ $cid,-awayword.!) > 2)) return
  if (($hget(pnp.config,awaywords.limit)) && (!$istok($hget(pnp.config,awaywords.chans),$chan,44))) return
  if ($hget(pnp.config,awaywords)) _doaww² $replace($strip($1-),$chr(44),.,-,.,$chr(90),.,$chr(91),.,?,.,!,.,<,.,>,.,*,.,@,.,+,.,',.,",.,/,.,:,.,;,.,.,$chr(32))
  if ($hget(pnp.config,awaywords.hl)) {
    if ($highlight($1-)) {
      var %word = [ [ $gettok($highlight($1-),1,44) ] ]
      hinc pnp. $+ $cid -awayword. $+ $site
      hinc -u5 pnp. $+ $cid -awayword.!
      _qnotice $nick $_awayformat(awayword,&word&,%word)
      return
    }
  }
}
alias _doaww² {
  var %words = $hget(pnp.config,awaywords.words),%word,%num = $numtok(%words,44)
  while (%num) {
    %word = [ [ $gettok(%words,%num,44) ] ]
    if ($istok($1-,%word,32)) {
      hinc pnp. $+ $cid -awayword. $+ $site
      hinc -u5 pnp. $+ $cid -awayword.!
      _qnotice $nick $_awayformat(awayword,&word&,%word)
      return
    }
    dec %num
  }
}

;
; Away dialogs
;
dialog autoaway {
  title "Auto-away"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 34
  text "Setting auto away in:", 101, 7 1 60 10
  text "15 seconds", 102, 67 1 130 10
  text "(ESC to cancel)", 103, 7 10 188 10
  button "&Set away", 1, 6 20 40 12, OK default
  button "Cancel", 2, 56 20 40 12, cancel
}
on *:DIALOG:autoaway:sclick:1:autoaway now
on *:DIALOG:autoaway:sclick:2:aacancel

dialog pager {
  title "Pager"
  icon script\pnp.ico
  option dbu
  size -1 -1 275 93

  button "&>>", 102, 24 5 18 12, default

  box "Page 1 of 1", 1, 47 2 225 87
  text "Paged by:", 12, 52 14 35 10, right
  edit "", 2, 87 12 62 11, read autohs

  button "&Query", 201, 152 12 35 11
  button "&DCC", 202, 192 12 35 11
  button "&Ignore...", 203, 231 12 35 11

  text "Reason:", 13, 52 27 35 10, right
  edit "", 3, 87 25 180 11, read autohs

  edit "", 4, 52 41 216 43, autohs vsbar return multi read

  button "Close", 103, 3 45 40 12, OK
  button "&Help", 104, 3 61 40 12, disable
  button "&Configure...", 105, 3 77 40 12

  button "&<<", 101, 3 5 18 12, disable

  edit "0", 197, 1 1 1 1, hide autohs
  edit "", 198, 1 1 1 1, hide autohs
  edit "", 199, 1 1 1 1, hide autohs
}
on *:DIALOG:pager:sclick:101:if ($did(198) > 1) pager v $calc($did(198) - 1)
on *:DIALOG:pager:sclick:102:if ($did(198) < $hget(pnp,totalpages)) pager v $calc($did(198) + 1)
on *:DIALOG:pager:sclick:103:_pagerclose
on *:DIALOG:pager:sclick:105:awaycfg p
on *:DIALOG:pager:sclick:201:awaylog pn ! $did(197) $did(2) | dialog $iif($did(198) == $hget(pnp,totalpages),-k,-v) $dname
on *:DIALOG:pager:sclick:202:dcc chat $did(2) | dialog $iif($did(198) == $hget(pnp,totalpages),-k,-v) $dname
on *:DIALOG:pager:sclick:203:ign $did(199) | if (($result) && ($did(198) == $hget(pnp,totalpages))) dialog -k $dname

dialog banorback {
  title "Ban or Back?"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 34

  text "/b is /back, but you seem to be trying to /ban.", 1, 7 1 190 10
  text "What would you like to do?", 2, 7 10 190 10

  button "/bac&k", 101, 6 20 40 12, OK
  button "/ba&n", 102, 56 20 40 12
  button "&Configure...", 103, 106 20 40 12

  edit "", 3, 1 1 1 1, hide result autohs
}
on *:DIALOG:banorback?:init:*:did -tf $dname 10 $+ $right($dname,1) | did -o $dname 1 1 $iif(*1 iswm $dname,/b is /back $+ $chr(44) but you seem to be trying to /ban.,/b is /ban; but you seem to want /back.)
on *:DIALOG:banorback?:sclick:101:if ($did(3) == $null) did -o $dname 3 1 back
on *:DIALOG:banorback?:sclick:102:did -o $dname 3 1 ban | dialog -k $dname
on *:DIALOG:banorback?:sclick:103:config 33

dialog away {
  title "Set Away"
  icon script\pnp.ico
  option dbu
  size -1 -1 150 60

  text "Away message?", 202, 7 5 140 10

  combo 1, 5 15 140 80, result edit drop

  check "&Pager", 2, 5 30 35 8, 3state
  check "&Logging", 3, 40 30 35 8
  check "&Quiet", 4, 75 30 35 8
  check "&All servers", 6, 110 30 35 8

  button "OK", 101, 5 43 40 12, OK default
  button "Cancel", 102, 55 43 40 12, cancel
  button "&Options...", 103, 105 43 40 12
}
on *:DIALOG:away:init:*:{
  _fillrec $dname 1 0 $_cfg(away.lis) 0 %.reason

  if ($hget(pnp,away)) did -ra $dname 202 Away message? (note- use /back to return from away)
  if (%.pager) did -c $+ $iif(%.pager == quiet,u) $dname 2
  if (%.log) did -c $dname 3
  if (%.quiet) did -c $dname 4
  if (!%.oneserver) did -c $dname 6
  if ($scon(0) == 1) did -b $dname 6
  unset %.reason %.pager %.log %.quiet %.oneserver
}
on *:DIALOG:away:sclick:101:set -u1 %.pager $gettok(0 1 quiet,$calc($did(2).state + 1),32) | set -u1 %.log $did(3).state | set -u1 %.quiet $did(4).state | set -u1 %.oneserver $iif($did(6).state,0,1)
on *:DIALOG:away:sclick:103:_juryrig awaycfg
