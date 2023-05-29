; #= P&P -rs
; ########################################
; Peace and Protection
; DCC and related routines and scripts
; ########################################

;
; DCC authorization
;

; /auth [-t|-r|-x] nick/addr [time]
; -t = toggle (off if already on permanent, or if time given, off if already on temp); -x = expire, -r = remove, else add (optionally with time)
; Authorizes by site to accept DCCs
alias auth {
  if (-* iswm $1) { var %opt = $1,%who = $2,%time = $3 }
  else { var %opt = -,%who = $1,%time = $2 }
  if (%who == $null) _qhelp /auth $1
  %who = $_nc(%who)
  var %auth = $_ppmask(%who,$_stmask(3),1)
  if (%auth == $null) {
    dispa Looking up address of $:t(%who) $+ ...
    _notconnected
    _Q.userhost auth $+ %opt $+ &n!&a $+ %time dispaUser $+ $:t(%who) $+ notfound %who
    halt
  }
  if (* isin $gettok(%who,1,33)) var %show = $:t(%auth)
  else var %show = $:t($gettok(%who,1,33)) ( $+ $:s(%auth) $+ )
  if (x isin %opt) {
    disp DCC authorization for %show has expired
    .ruser =dcc,=auth %auth
    if ($level(%auth) == $dlevel) .ruser %auth
    .timer.auth. $+ $replace(%auth,*,`,?,') off
    scid -a _nickcol.updatemask %auth 1
    return
  }
  :remove
  if (r isin %opt) {
    if ($istok($level(%auth),=dcc,44)) dispa Removing DCC authorization for %show
    else dispa %show does not have DCC authorization
    .ruser =dcc,=auth %auth
    if ($level(%auth) == $dlevel) .ruser %auth
    .timer.auth. $+ $replace(%auth,*,`,?,') off
  }
  elseif (%time) {
    if ($istok($level(%auth),=dcc,44)) {
      if ((t isin %opt) && ($istok($level(%auth),=auth,44))) { %opt = -r | goto remove }
      dispa Giving %show DCC authorization for %time minute $+ $chr(40) $+ s $+ $chr(41)
    }
    else {
      dispa Giving %show DCC authorization for %time minute $+ $chr(40) $+ s $+ $chr(41)
      if ($window(@DCClist)) aline @DCClist %auth $+ 	(temp)
    }
    if ($level(%auth) == $dlevel) .auser $dlevel %auth
    .auser -a =dcc,=auth %auth
    .timer.auth. $+ $replace(%auth,*,`,?,') -io 1 $calc(%time * 60) auth -x %auth
  }
  else {
    if ((t isin %opt) && ($istok($level(%auth),=dcc,44)) && ($istok($level(%auth),=auth,44) == $false)) { %opt = -r | goto remove }
    if (($window(@DCClist)) && ($istok($level(%auth),=dcc,44) == $false)) aline @DCClist %auth
    dispa Granting %show DCC authorization $chr(40) $+ permanent $+ $chr(41)
    if ($level(%auth) == $dlevel) .auser $dlevel %auth
    else .ruser =auth %auth
    .auser -a =dcc %auth
    .timer.auth. $+ $replace(%auth,*,`,?,') off
  }
  scid -a _nickcol.updatemask %auth 1
}

alias _clrtauth {
  ;  clear any temp auths (designed ONLY for startup, otherwise saveini is needed)
  var %who,%num = $ulist(*,auth,0)
  :loop
  if (%num) {
    %who = $ulist(*,auth,%num)
    .ruser =dcc,=auth %who
    if ($level(%who) == $dlevel) .ruser %who
    dec %num | goto loop
  }
}

;
; /dcc replacement
;

alias c dcc chat $1-
alias s dcc send $1-
alias chat dcc chat $1-
alias send dcc send $1-
alias dcc {
  if ($1 == queue) { _dialog -am dccqcfg dccqcfg | return }
  var %cflag = 0
  if (($1 == send) && ($2 == -c)) {
    %cflag = 1
    tokenize 32 $1 $3-
  }
  if (.* iswm $2) {
    if (: isin $2) { var %port = : $+ $gettok($2,2-,58) | var %p2 = $gettok($2,1,58) }
    else { var %p2 = $2 | var %port = :59 }
    var %dns = $_nc($right(%p2,-1))
    if (@ isin %dns) %dns = $gettok(%dns,2-,64)
    dispa Looking up address of $:t(%dns) for direct DCC connection to IP...
    _Q.dns _dccdo $+ %cflag $+  $+ $1 $+  $+ %port $+  $+ $iif($3,$_s2p($3-)) _dccerr $+ %cflag $+  $+ $1 $+  $+ %port $+  $+ $iif($3,$_s2p($3-)) $iif(. isin %dns,-h,-n) %dns
    halt
  }
  if ($1 == $null) _qhelp /dcc
  if (($1 == send) || ($1 == chat) || ($1 == fserve)) {
    if (. !isin $2) _notconnected (can't send dcc request)
    if (($1 == send) && ($3 != $null) && ($nopath($3) == $null)) tokenize 32 $1- $+ *.*
    var %who
    if ($2) { %who = $_nc($2) | dcc $1 $iif(%cflag,-c) %who $3- }
    elseif ($query($active) == $active) { dcc $1 $iif(%cflag,-c) $active | %who = $active }
    elseif ($chat($right($active,-1)) != $null) { dcc $1 $iif(%cflag,-c) $ifmatch | %who = $ifmatch } 
    else dcc $1 $iif(%cflag,-c)
    if ((%who) && ($1 == chat) && (. !isin %who)) hadd pnp chat.open. $+ %who request
  }
  else dcc $1-
}
alias _dccerr if ($iaddress) _dccdo $1- | else _error Could not resolve address for direct DCC.Use / $+ $2 $nick to attempt a normal connection.
alias _dccdo _juryrig2 dcc $2 $iif($1,-c) $iaddress $+ $3 $4-

;
; DCC auth list editing
;
alias authedit authlist $1-
alias authlist {
  window -c @DCClist
  if ($window(@DCClist)) clear @DCClist
  else _window 2.7 -lizk -t65 @DCClist $_winpos(8,12,10,10) @DCClist
  var %num = $ulist(*,dcc,0)
  :loop
  if (%num) {
    aline @DCClist $ulist(*,dcc,%num) $+ 	 $+ $iif($istok($level($ulist(*,dcc,%num)),=auth,44),(temp))
    dec %num | goto loop
  }
  iline @DCClist 1 The following addresses have authorization to send you DCC chats and sends. $chr(40) $+ files $+ $chr(41)
  iline @DCClist 2 Any DCCs from these users will be automatically accepted. $chr(40) $+ unless you are away $+ $chr(41)
  iline @DCClist 3 Double-click to remove a user $+ $chr(44) or right-click for options.
  iline @DCClist 4  
  iline @DCClist 5 Address	Status
  iline @DCClist 6  
  window -b @DCClist
}
menu @DCClist {
  dclick:.auth -r $gettok($line($active,$1),1,9) | dline $active $1
  Add authorization...:.auth $_entry(-1,$null,Nickname or address to add DCC authorization for?)
  Add temporary auth...:var %who = $_entry(-1,$null,Nickname or address to add DCC authorization for?) | .auth %who $_entry(-2,15,Number of minutes to authorize for?)
  -
  $iif($sline($active,1).ln > 6,Remove authorization)::loop | .auth -r $gettok($sline($active,1),1,9) | dline $active $sline($active,1).ln | if ($sline($active,1)) goto loop
  $iif($sline($active,1).ln > 6,Change to temporary auth...):var %time = $_entry(-2,15,Number of minutes to authorize for?) | :loop | .auth $gettok($sline($active,1),1,9) %time | rline $active $sline($active,1).ln $gettok($sline($active,1),1,9) $+ 	(temp) | if ($sline($active,1)) goto loop
}

;
; DCC Ping
;
on &^*:CHAT:PING &:if (($len($2) < 25) && ($2 isnum)) { _dccpprot | .msg =$nick PONG $2 | $_show.ctcp(=$nick,$address,DCC PING,$iif($hget(pnp.config,show.pingcode),$2-)) | halt }
on &^*:CHAT:PONG &:if (($len($2) < 25) && ($2 isnum)) { _dccpprot | $_show.reply.ping($nick,$address,DCC,$null,$_dur($calc(($ticks - $2) / 1000)),$null,=$nick) | halt }
alias -l _dccpprot {
  hinc -u10 pnp dccping
  if ($hget(pnp,dccping) > 9) {
    .msg =$nick DCC chat with $nick closed due to detection of a DCC PING flood
    close -c $nick
    dispa DCC chat with $:t($nick) closed due to detection of a DCC PING flood
    halt
  }
}
alias dcp {
  if ($1) {
    var %who
    if (=* iswm $1) %who = $right($1,-1) | else %who = $1
    if ($chat(%who) != %who) _error DCC ping $chr(40) $+ /dcp $+ $chr(41) is only for DCC chats.Use /ping for channels or queries.
    .msg = $+ %who PING 0 $+ $ticks
    $_show.ctcp.send(= $+ %who,DCC PING)
  }
  else {
    if (=* !iswm $active) _error DCC ping $chr(40) $+ /dcp $+ $chr(41) is only for DCC chats.Use /ping for channels or queries.
    .msg $active PING 0 $+ $ticks
    $_show.ctcp.send($active,DCC PING)
  }
}

;
; Flood-in-DCC protection
;
on *:CHAT:*:{
  if ($_genflood(dcc. $+ $nick,$hget(pnp.config,xchat.cfg))) {
    .msg =$nick DCC chat with $nick closed due to detection of a DCC flood
    close -c $nick
    dispa DCC chat with $:t($nick) closed due to detection of a DCC flood
    halt
  }
}

; Count unfinished sends to a user
; $_numsend($nick)
alias _numsend {
  var %total = 0,%num = $send(0)
  :loop
  if (($1 == $send(%num)) && ($send(%num).status != inactive)) inc %total
  if (%num > 1) { dec %num | goto loop }
  return %total
}

; Count unfinished sends to any user any cid
; $_numsendall
alias _numsendall {
  var %total = 0,%scon = $scon(0)
  while (%scon >= 1) {
    scid $scon(%scon)
    %num = $send(0)
    while (%num >= 1) {
      if ($send(%num).status != inactive) inc %total
      dec %num
    }
    dec %scon
  }
  scid -r
  return %total
}

;
; DCC queueing
;
alias _Q.dcc {
  if ($window(@DCCQueue) == $null) {
    _window 2.3 -lnzk $+ $iif($_cfgi(dccqueuehide),h) -t20 @DCCQueue -1 -1 -1 -1 @DCCQueue
    _windowreg @DCCQueue .timer.dcc.queue off
    aline @DCCQueue Nickname	Network	File
    aline @DCCQueue  
  }
  aline @DCCQueue $1 $+ 	 $+ $hget(pnp. $+ $cid,net) $chr(91) $+ $cid $+ $chr(93) $+ 	 $+ $2-
  .timer.dcc.queue -io 0 30 _check.dcc
}
menu @DCCQueue {
  $iif($sline(@DCCQueue,1).ln > 2,Remove):{
    :loop | if ($sline(@DCCQueue,1).ln) { dline @DCCQueue $ifmatch | goto loop }
    if ($line(@DCCQueue,0) < 3) {
      window -c @DCCQueue
      .timer.dcc.queue off
    }
  }
  $iif($sline(@DCCQueue,1).ln > 2,Move to top):{
    :loop | if ($sline(@DCCQueue,1)) { iline @DCCQueue 3 $sline(@DCCQueue,1) | dline @DCCQueue $sline(@DCCQueue,1).ln | goto loop }
  }
  Settings...:dcc queue
}
alias _hide.dcc .dcc send -c $1 " $+ $2- $+ " | if ($_cfgi(dccsendhide)) window -h "Send $1 $nopath($2-) $+ "
; Returns -1 if failed due to user total queued
; Returns -2 if failed due to total queued
; Returns -3 if no queueing
; Returns -4 if file not found
; Returns -5 if file already queued to user
; Returns -6 if file already being sent to user
; Returns 0 if sent
; Returns x if queued and it's position
alias _send.dcc {
  if ($exists($2-) == $false) return -4
  var %line = $1 $+ 	 $+ $hget(pnp. $+ $cid,net) $chr(91) $+ $cid $+ $chr(93) $+ 	 $+ $2-
  var %scan = $1 $+ 	* $chr(91) $+ $cid $+ $chr(93) $+ 	 $+ $2-
  var %userscan = $1 $+ 	* $chr(91) $+ $cid $+ $chr(93) $+ 	*
  if ($fline(@DCCQueue,%scan,1)) return -5
  ; count num active sends to all, nick, and look for same filename
  var %num = $send(0),%total = 0,%nick = 0
  if (%num) {
    :loop
    if ($send(%num).status != inactive) {
      if ($1 == $send(%num)) {
        %file = $send(%num).path $+ $send(%num).file
        if (%file == $2-) return -6
        inc %nick
      }
      inc %total
    }
    if (%num > 1) { dec %num | goto loop }
  }
  ; Add in active sends to users on other servers
  var %scon = $scon(0)
  while (%scon >= 1) {
    if ($scon(%scon) != $cid) {
      scid $scon(%scon)
      %num = $send(0)
      while (%num >= 1) {
        if ($send(%num).status != inactive) inc %total
        dec %num
      }
    }
    dec %scon
  }
  scid -r
  if ((%nick >= $_cfgi(dccmaxsendone)) || (%total >= $_cfgi(dccmaxsendall))) {
    if (($window(@DCCQueue)) && ($fline(@DCCQueue,%userscan,0) >= $_cfgi(dccmaxqone))) return -1
    if ($_cfgi(dccmaxqall)) {
      if (($window(@DCCQueue)) && ($line(@DCCQueue,0) >= $calc($_cfgi(dccmaxqall) + 2))) return -2
    }
    else return -3
    _Q.dcc $1-
    return $calc(0 + $line(@DCCQueue,0) - 2)
  }
  _linedance _hide.dcc $1-
  return 0
}
; Cancels any dccs queued to a user and returns number canceled
alias _cancel.dcc {
  if ($window(@DCCQueue) == $null) return 0
  var %userscan = $1 $+ 	* $chr(91) $+ $cid $+ $chr(93) $+ 	*
  var %total = $fline(@DCCQueue,%userscan,0)
  :loop | if ($fline(@DCCQueue,%userscan,1)) { dline @DCCQueue $ifmatch | goto loop }
  if ($line(@DCCQueue,0) < 3) {
    window -c @DCCQueue
    .timer.dcc.queue off
  }
  return %total
}
; Cancels any dccs on current net
alias _cancel.dcc.net {
  if ($window(@DCCQueue) == $null) return 0
  var %userscan = *	* $chr(91) $+ $cid $+ $chr(93) $+ 	*
  var %total = $fline(@DCCQueue,%userscan,0)
  :loop | if ($fline(@DCCQueue,%userscan,1)) { dline @DCCQueue $ifmatch | goto loop }
  if ($line(@DCCQueue,0) < 3) {
    window -c @DCCQueue
    .timer.dcc.queue off
  }
  return %total
}
; Counts dccs queued to a user (if $1 given) or all (if null)
alias _count.dcc {
  if ($window(@DCCQueue) == $null) return 0
  if ($1) return $fline(@DCCQueue,$1 $+ 	* $chr(91) $+ $cid $+ $chr(93) $+ 	*,0)
  return $calc($line(@DCCQueue,0) - 2)
}
; Returns position in queue of first file to nick
alias _pos.dcc {
  if ($window(@DCCQueue) == $null) return
  return $fline(@DCCQueue,$1 $+ 	* $chr(91) $+ $cid $+ $chr(93) $+ 	*,1)
}
alias -l _check.dcc {
  if ($_numsendall >= $_cfgi(dccmaxsendall)) return
  var %line,%num = 3
  while ($line(@DCCQueue,%num)) {
    var %data = $ifmatch
    var %cid = $gettok(%data,2,9)
    if ($scid(%cid)) {
      scid %cid
      if (($server) && ($_numsend($gettok(%data,1,9)) < $_cfgi(dccmaxsendone))) {
        %line = $line(@DCCQueue,%num)
        _linedance _hide.dcc $gettok(%data,1,9) $gettok(%data,3-,9)
        dline @DCCQueue %num
      }
      else inc %num
    }
    else dline @DCCQueue %num
  }
  scid -r
  if ($line(@DCCQueue,0) < 3) {
    window -c @DCCQueue
    .timer.dcc.queue off
  }
}
on *:FILESENT:*:.timer.dcc.queue -e
on *:SENDFAIL:*:.timer.dcc.queue -e
on *:NICK:if ($nick == $newnick) return | :loop | if ($fline(@DCCQueue,$nick $+ 	* $chr(91) $+ $cid $+ $chr(93) $+ 	*,1)) { rline @DCCQueue $ifmatch $puttok($line(@DCCQueue,$ifmatch),$newnick,1,9) | goto loop }
raw 401:*no such*:if ($send(0)) _pend.dcc $2 (no such user)
on me:*:PART:#:if (($mid($hget(pnp.config,dccqueueclean),4,1)) && ($window(@DCCQueue))) _clean.dcc
on *:PART:#:if (($comchan($nick,0) == 1) && ($mid($hget(pnp.config,dccqueueclean),1,1))) { _cancel.dcc $nick | if ($result) _linedance _qnotice $nick $result files queued to you have been cancelled }
on *:KICK:#:{
  if ($knick == $me) {
    if (($mid($hget(pnp.config,dccqueueclean),4,1)) && ($window(@DCCQueue))) _clean.dcc
  }
  else {
    if (($comchan($knick,0) == 1) && ($mid($hget(pnp.config,dccqueueclean),2,1))) { _cancel.dcc $knick | if ($result) _linedance _qnotice $knick $result files queued to you have been cancelled }
  }
}
on *:QUIT:if ($send(0)) _pend.dcc $nick (user quit irc) | if ($mid($hget(pnp.config,dccqueueclean),3,1)) _cancel.dcc $nick
on *:DISCONNECT:if (($mid($hget(pnp.config,dccqueueclean),5,1)) && ($window(@DCCQueue))) { _cancel.dcc.net | if ($result) disps Removed $result pending send $+ $chr(40) $+ s $+ $chr(41) from DCC Queue for $hget(pnp. $+ $cid,net) due to disconnection }
on *:CONNECT:if ($window(@DCCQueue)) .timer.dcc.queue -io 0 30 _check.dcc
alias -l _pend.dcc {
  var %num = $send(0),%total = 0
  :loop
  if ($send(%num) == $1) {
    if ($send(%num).status != waiting) return
    else inc %total
  }
  if (%num > 1) { dec %num | goto loop }
  if (%total) {
    close -s $1
    disps Removed %total pending send $+ $chr(40) $+ s $+ $chr(41) from DCC Queue to $1 $2-
    .timer.dcc.queue -e
  }
}
alias -l _clean.dcc {
  var %num = $nick($chan,0)
  :loop
  if ($comchan($nick($chan,%num),0) == 1) {
    _cancel.dcc $nick($chan,%num)
    if ($result) _linedance _qnotice $nick($chan,%num) $result files queued to you have been cancelled
  }
  if (%num > 1) { dec %num | goto loop }
}
; dcc queue config
dialog dccqcfg {
  title "DCC Queueing Config"
  icon script\pnp.ico
  option map
  size -1 -1 200 203

  text "These options determine how many total files a user can request from PnP addons at one time. (sound, XDCC, etc)", 1, 2 2 193 18
  box "Maximum simultaneous DCC sends:", 2, 2 24 193 42
  text "&Per user:", 3, 6 38 52 9, right
  edit "", 5, 60 35 33 13
  text "&Total:", 4, 96 38 56 9, right
  edit "", 6, 153 35 33 13
  check "&Hide DCC sends (if automated)", 7, 46 51 140 9
  check "&Queue DCCs when maximum reached", 8, 9 73 187 9
  box "Maximum queued DCCs:", 9, 2 87 193 42
  text "&Per user:", 10, 6 100 52 9, right
  edit "", 12, 60 98 33 13
  text "&Total:", 11, 96 100 56 9, right
  edit "", 13, 153 98 33 13
  check "&Hide queue window", 14, 46 114 140 9
  box "Queue cleanup:", 15, 2 135 193 42
  text "When user:", 16, 6 147 44 9, right
  text "When you:", 17, 6 160 44 9, right
  check "&Quits", 20, 53 147 40 9
  check "&Parts", 18, 93 147 40 9
  check "&Is kicked", 19, 133 147 60 9
  check "&Leave channel", 21, 53 160 80 9
  check "&Disconnect", 22, 133 160 60 9

  button "OK", 101, 13 184 46 14, ok default
  button "Cancel", 102, 76 184 46 14, cancel
  button "&Help", 103, 140 184 46 14, disable
}
on *:DIALOG:dccqcfg:init:*:{
  did -a $dname 5 $_cfgi(dccmaxsendone)
  did -a $dname 6 $_cfgi(dccmaxsendall)
  if ($_cfgi(dccsendhide)) did -c $dname 7
  if ($_cfgi(dccmaxqall)) {
    did -c $dname 8
    did -a $dname 13 $ifmatch
  }
  else {
    did -a $dname 13 5
    _bulkdid -b $dname 9 22
  }
  did -a $dname 12 $_cfgi(dccmaxqone)
  if ($_cfgi(dccqueuehide)) did -c $dname 14
  var %num = 1
  :loop
  if ($mid($hget(pnp.config,dccqueueclean),%num,1)) did -c $dname $calc(%num + 17)
  if (%num < 5) { inc %num | goto loop }
}
on *:DIALOG:dccqcfg:sclick:8:_bulkdid $iif($did(8).state,-e,-b) $dname 9 22
on *:DIALOG:dccqcfg:sclick:101:{
  _cfgw dccmaxsendone $iif($did(5) isnum,$did(5),1)
  _cfgw dccmaxsendall $iif($did(6) isnum,$did(6),5)
  _cfgw dccsendhide $did(7).state
  _cfgw dccmaxqone $iif($did(12) isnum,$did(12),2)
  _cfgw dccmaxqall $iif($did(8).state,$iif($did(13) isnum,$did(13),10),0)
  _cfgw dccqueuehide $did(14).state
  var %opts,%num = 18
  :loop
  %opts = %opts $+ $did(%num).state
  if (%num < 22) { inc %num | goto loop }
  `set dccqueueclean %opts
}

; Last DCC action
; /rec [n] to run/view, /rec d [n] to delete, /rec e [n] to edit, /rec f [n] for folder, /rec v to view list
on *:FILERCVD:*:_recent dccget 10 0 $filename
on *:GETFAIL:*:_recent dccget 10 0 $filename
;;; show msg when file rcvd with fkey to /rec it?
alias rec {
  if (($1 !isnum) && ($1 != $null) && ($1 !isin def)) {
    dispa-div
    var %num = 1
    :loop
    if (%=dccget. [ $+ [ %num ] ] ) {
      dispa   - $:t(%num) $+ . $ifmatch $iif($exists($ifmatch) == $false,( $+ $:s(deleted) $+ ))
      inc %num | goto loop
    }
    %num = (num)
    if (%num == 1) dispa No recently received DCC files
    else dispa $:s(/rec) $chr(40) $+ number optional $+ $chr(41) to run a file $+ $chr(44) $:s(/rec d %num) to delete $+ $chr(44) $:s(/rec e %num) to edit $+ $chr(44) $:s(/rec f %num) for folder
    dispa-div
  }
  else {
    var %file
    if ($1 isnum) {
      if (%=dccget. [ $+ [ $1 ] ] ) %file = $ifmatch
      else dispa That is not the number of a recently received DCC file
    }
    elseif ($2 isnum) {
      if (%=dccget. [ $+ [ $2 ] ] ) %file = $ifmatch
      else dispa That is not the number of a recently received DCC file
    }
    elseif (%=dccget.1) %file = $ifmatch
    else dispa No recently received DCC files
    if (%file != $null) {
      if ($1 == f) run $nofile(%file)
      elseif ($exists(%file) == $false) dispa File $:s(%file) no longer exists
      elseif ($1 == e) edit %file
      elseif ($1 == d) {
        _okcancel 1 Delete ' $+ %file $+ '?
        _remove %file
      }
      elseif ($pic(%file).width) viewpic %file
      else run %file
    }
  }
}

; CTCP DCC code tracks why a DCC chat is opened
; Above /dcc alias tracks why a DCC chat is opened
; This tracks why a DCC chat is opened if DCCSERVER
on *:DCCSERVER:Chat:if ($creq == ignore) hdel pnp chat.open. $+ $nick | else hadd pnp chat.open. $+ $nick $creq server

