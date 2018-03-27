; #= P&P -rs -1
; @======================================:
; |  Peace and Protection                |
; |  Themes display and anything "last"  |
; `======================================'

;
; Text display support functions
;

; Your input- say, me, msg, describe, notice
; Normally we don't need to alias these except for nick completion purposes
; /theme.msg type target color text
; Shows a themed msg/etc. type is Text or Action
; Returns 1 if msg was shown to active.
alias theme.msg {
  set -u %::text $4-
  set -u %::target $2
  if ($2 ischan) {
    set -u %::nick $me
    set -u %::address $gettok($hget(pnp. $+ $cid,-myself),2-,33)
    set -u %::chan $2
    set -u %:echo echo $3 -ti2 $2
    theme.text $1 $+ ChanSelf c
  }
  elseif ($query($2)) {
    set -u %::nick $2
    set -u %:echo echo $3 -ti2 $2
    theme.text $1 $+ QuerySelf
  }
  elseif ((=* iswm $2) && ($chat($right($2,-1)))) {
    set -u %::nick $right($2,-1)
    set -u %:echo echo $3 -ti2 $2
    theme.text $1 $+ QuerySelf
  }
  else {
    set -u %::nick $2
    set -u %:echo echo $3 -ati2 $iif($activecid != $cid,$:anp)
    theme.text TextMsgSelf
    return 1
  }
  return 0
}

; /theme.msgcopy target color text
; Shows a copy of a msg to active if the query isn't active (this does nothing if target isn't a query)
; Only if settings are set for copy query to active
alias -l theme.msgcopy {
  ; Copy to active?
  if (($hget(pnp.config,copy.query)) && ($active != $1) && (($active ischan) || ($query($active)))) {
    set -u %::text $3-
    set -u %::target $1
    ; show as (net)nick if not on active net
    set -u %::nick $1
    set -u %:echo echo $2 -ati2 $iif($activecid != $cid,$:anp)
    theme.text TextMsgSelf
  }
}

; /notice.beep
; Does a notice event beep (sound, or beep, or nothing)
; Skips if in a sound already
alias notice.beep {
  if (($inwave) || ($inmidi) || ($insong)) return
  if ($_optn(5,15) == 0) return
  var %beep = $_optn(1,16)
  if (%beep == 1) beep
  elseif (%beep) .splay " $+ $readini($mircini,n,waves,$1) $+ "
}

; /notice.window target
; Opens notices window if not open; fills editbox regardless
; Returns window name
alias -l notice.window {
  ; Open window?
  var %win = $_mservwin(@Notices)
  if ($window(%win) == $null) {
    ; (minimize if minimize queries is on)
    _window 1 $iif($_optn(1,18),-env,-ev) + %win -1 -1 -1 -1 /n @Notices
    titlebar %win ( $+ $hget(pnp. $+ $cid,net) - F1 to cycle)
  }
  ; Don't fill editbox if something is being typed
  if ($numtok($editbox(%win),32) > 2) return %win
  ; Determine proper cmd to fill with- opvoc notice, op notice/msg, services reply, reg notice
  if (@+* iswm $1) editbox -p %win /ovnotice $right($1,-2)
  elseif (@%* iswm $1) editbox -p %win /ohnotice $right($1,-2)
  elseif (@* iswm $1) editbox -p %win $iif($event == NOTICE,/onotice,/omsg) $right($1,-1)
  elseif ($istok($hget(pnp. $+ $cid,-servnick),$1,32)) editbox -p %win / $+ $_botacc($1)
  else editbox -p %win /notice $1
  return %win
}

; /show.opnotice target display
; Used to echo an op/etc notice
alias show.opnotice {
  ; Normal- to channel
  if ($hget(pnp.config,op.notice) == 0) echo $color(notice) -bfmti2 $1 $2-
  ; To notices window
  elseif ($hget(pnp.config,op.notice) == 1) {
    ; Open to target if target contains channel name
    notice.window $iif($1 isin $target,$target,@ $+ $1)
    echo $color(notice) -bfmti2 $result $2-
  }
  ; To channel events window
  else {
    echo $color(notice) -bfmti2 $event.win($1) $2-
  }
}

; $event.win(#chan)
; Opens events window for a channel if not open; returns window name
alias -l event.win {
  ; (minimize if minimize queries is on)
  var %win = $_mservwin(@Events,- $+ $1)
  if ($window(%win) == $null) {
    _window 1 $iif($_optn(1,18),-env,-ev) + %win -1 -1 -1 -1 @Events-
    titlebar %win ( $+ $hget(pnp. $+ $cid,net) $+ )
  }
  return %win
}


; Enable group to allow theming of text, joins, and other basic mIRC output
#pp-texts on

;
; Basic text display
;

; /event.chan event text
; set echo yourself. This sets stripped text, chan, nick, address, target
; set linesep yourself if event can use it
alias -l event.chan {
  set -u %::text $strip($2-,mo)
  set -u %::chan $target
  set -u %::nick $nick
  set -u %::address $address
  set -u %::target $target
  theme.text $1 c
}

; Channel text, action, notice
on &^*:TEXT:*:#:{
  ; Global message or channel not open
  if (($me !ison $target) && (#* iswm $target)) {
    if (* isin $target) return
    halt
  }
  ; Op or regular text?
  if (@* iswm $target) {
    set -u %:echo show.opnotice $chan
    event.chan TextChanOp $1-
  }
  else {
    set -u %:echo echo -lmbfti2 $chan
    event.chan TextChan $1-
  }
  halt
}
on &^*:ACTION:*:#:{
  set -u %:echo echo $color(act) -lmbfti2 $chan
  ; Op or regular text?
  event.chan $iif(@* iswm $target,ActionChanOp,ActionChan) $1-
  halt
}
on &^*:NOTICE:*:#:{
  ; Op or regular text? (or global/not on chan?)
  if (@* iswm $target) {
    _ssplay NoticeChanOp
    set -u %:echo show.opnotice $chan
  }
  elseif ($me !ison $target) {
    _ssplay Notice
    set -u %:echo echo $color(notice) -lmbfsti2
  }
  else {
    _ssplay Notice
    set -u %:echo echo $color(notice) -lmbfti2 $chan
  }
  ; Event beep; sound (above) based on type of event
  notice.beep
  event.chan NoticeChan $1-
  halt
}

; Private text, action, notice, chat
on &^*:TEXT:*:?:{
  ; Global message
  if ($left($target,1) == $) return

  set -u %::text $strip($1-,mo)
  set -u %::nick $nick
  set -u %::address $address
  set -u %::target $target

  ; Show to query if open
  if ($query($nick)) {
    set -u %:echo echo -lmbfti2 $nick
    theme.text TextQuery

    ; Show also to active if copy-query is on, active is a chan/query, and not the current query
    if (($hget(pnp.config,copy.query) != 1) || ($active == $nick)) halt
    if (($active !ischan) && ($query($active) != $active)) halt
  }
  ; Show to dqwindow?
  elseif ($_optn(0,22)) {
    ; Pop window up if empty and mIRC option set to do so
    if (($line(Message Window,0) == $null) && ($_optn(1,18) == 0)) dqwindow show
    set -u %:echo echo -lmbfdti2
    theme.text TextMsg

    ; Show also to active if copy-query is on and active is a chan/query
    if ($hget(pnp.config,copy.query) != 1) halt
    if (($active !ischan) && ($query($active) != $active)) halt
  }

  ; Show to active- either by default, or as a fall-through from above
  set -u %:echo echo -lmbfati2 $iif($activecid != $cid,$:anp)
  theme.text TextMsg
  halt
}
on &^*:ACTION:*:?:{
  set -u %::text $strip($1-,mo)
  set -u %::nick $nick
  set -u %::address $address
  set -u %::target $target

  ; Show to query if open
  if ($query($nick)) {
    set -u %:echo echo $color(act) -lmbfti2 $nick
    theme.text ActionQuery

    ; Show also to active if copy-query is on, active is a chan/query, and not the current query
    if (($hget(pnp.config,copy.query) != 1) || ($active == $nick)) halt
    if (($active !ischan) && ($query($active) != $active)) halt
  }
  ; Show to dqwindow?
  elseif ($_optn(0,22)) {
    ; Pop window up if empty and mIRC option set to do so
    if (($line(Message Window,0) == $null) && ($_optn(1,18) == 0)) dqwindow show
    set -u %:echo echo $color(act) -lmbfdti2
    theme.text ActionQuery

    ; Show also to active if copy-query is on and active is a chan/query
    if ($hget(pnp.config,copy.query) != 1) halt
    if (($active !ischan) && ($query($active) != $active)) halt
  }

  ; Show to active- either by default, or as a fall-through from above
  set -u %:echo echo $color(act) -lmbfati2 $iif($activecid != $cid,$:anp)
  theme.text TextMsg
  halt
}
on &^*:NOTICE:*:?:{
  set -u %::text $strip($1-,mo)
  set -u %::nick $nick
  set -u %::address $address
  set -u %::target $target

  ; Determine method of display
  ; "Opnotice"
  if (%.opnotice) {
    _ssplay NoticeChanOp
    set -u %:echo show.opnotice %.opnotice
  }
  else {
    _ssplay Notice
    ; Services or normal nickname?
    if ($istok($hget(pnp. $+ $cid,-servnick),$nick,32)) var %window = $hget(pnp.config,serv.notice)
    else var %window = $hget(pnp.config,reg.notice)
    ; Determine from window setting, mIRC options, etc. where to display
    ; In order-
    ; DCC notices- status
    ; Window is "status"- status
    ; Window is "notices window"- notices window
    ; mIRC "to active" set and active is a query/channel- active
    ; Common channels- to all common channels
    ; Otherwise- to status
    if (($1 === DCC) || (%window == 2)) set -u %:echo echo $color(notice) -emsti2
    elseif (%window == 1) {
      notice.window $nick
      set -u %:echo echo $color(notice) -mbfti2 $result
    }
    elseif ((($active ischan) || ($query($active))) && ($_optn(5,13))) set -u %:echo echo $color(notice) -mbfati2 $iif($activecid != $cid,$:anp)
    elseif ($comchan($nick,0)) {
      var %num = $comchan($nick,0)
      while (%num >= 1) {
        set -u %:echo echo $color(notice) -mbfti2 $comchan($nick,%num)
        theme.text Notice
        dec %num
      }
      ; Event beep; sound above (notice or opnotice)
      notice.beep
      halt
    }
    else set -u %:echo echo $color(notice) -emsti2
  }
  ; Event beep; sound above (notice or opnotice)
  notice.beep
  theme.text Notice
  halt
}
on &^*:CHAT:*:{
  ; Ignore sounds
  if ($1 == SOUND) return

  set -u %::nick $nick

  ; Actions treated differently
  if ($1 == ACTION) {
    ; Make sure ends in chr(1) before removing it
    if (* iswm $1-) set -u %::text $strip($left($2-,-1),mo)
    else set -u %::text $strip($2-,mo)
    set -u %:echo echo $color(act) -lmbfti2 = $+ $nick
    theme.text ActionQuery
  }
  else {
    set -u %::text $strip($1-,mo)
    set -u %:echo echo $color(norm) -lmbfti2 = $+ $nick
    theme.text TextQuery
  }
  halt
}

alias say {
  ; Errors
  if ($1 == $null) {
    if ($show) _qhelp /say
    halt
  }
  if (($active !ischan) && (=* !iswm $active) && ($query($active) == $null)) {
    dispa /say $+ : Can't use /say in this window
    halt
  }
  ; Display
  if ($show) theme.msg Text $active $color(own) $1-
  ; Actually say text (using .msg because .say doesn't work)
  .!msg $active $1-
  ;!! hack for back-on-keypress (until mirc does it on it's own for /msg or allows /.say)
  if (($_optn(0,9)) && ($server)) .raw away
}
alias action {
  me $1-
}
alias me {
  ; Errors
  if ($1 == $null) {
    if ($show) _qhelp /me
    halt
  }
  if (($active !ischan) && (=* !iswm $active) && ($query($active) == $null)) {
    dispa /me $+ : Can't use /me in this window
    halt
  }
  ; Display
  if ($show) theme.msg Action $active $color($iif($color(own)  == $color(norm),action,own)) $1-
  ; Actually say text
  .me $1-
}
alias msg {
  ; Errors
  if ($2 == $null) {
    if ($show) _qhelp /msg $1
    halt
  }
  ; (leave dccs alone)
  if (=* iswm $1) msg $1-
  elseif ($show) {
    var %who = $_ncs(44,$1)
    ; Display
    theme.msg Text %who $color(own) $2-
    if (!$result) theme.msgcopy %who $color(own) $2-
    ; Actually say text
    ; (use privmsg due to problems sending to @+#chan)
    _privmsg %who $2-
  }
  ; Actually say text (if no display)
  else _privmsg $1 $2-
}
alias describe {
  ; Errors
  if ($2 == $null) {
    if ($show) _qhelp /msg $1
    halt
  }
  ; (leave dccs alone)
  if (=* iswm $1) describe $1-
  elseif ($show) {
    var %who = $_ncs(44,$1)
    ; Display
    theme.msg Action %who $color($iif($color(own)  == $color(norm),action,own)) $2-
    if (!$result) theme.msgcopy %who $color($iif($color(own)  == $color(norm),action,own)) $2-
    ; Actually say text
    .describe %who $2-
  }
  ; Actually say text (if no display)
  else .describe $1 $2-
}
alias notice {
  ; Errors
  if ($2 == $null) {
    if ($show) _qhelp /notice $1
    halt
  }
  if ($show) {
    var %who = $_ncs(44,$1)
    ; Display
    set -u %::text $2-
    set -u %::target $1
    set -u %:echo echo $color(own) -ati2 $iif($activecid != $cid,$:anp)
    if ($_ischan($1)) {
      set -u %::nick $me
      set -u %::address $gettok($hget(pnp. $+ $cid,-myself),2-,33)
      set -u %::chan $1
      theme.text NoticeSelfChan c
    }
    elseif ((@* iswm $1) && ($_ischan($right($1,-1)))) {
      set -u %::nick $me
      set -u %::address $gettok($hget(pnp. $+ $cid,-myself),2-,33)
      set -u %::chan $right($1,-1)
      theme.text NoticeSelfChan c
    }
    else {
      set -u %::nick $1
      theme.text NoticeSelf
    }
    ; Actually say text
    .notice %who $2-
  }
  ; Actually say text (if no display)
  else .notice $1 $2-
}

; /event.target #chan type
; Event targeting for a channel/type of event
; Returns hide, chan, $true, 0/$null, both
; 'both' is for quits only
; '$true' is events window
; '0/$null' is status
alias -l event.target {
  ; Retrieve setting for this channel or all channels
  var %val = 0
  if ($hget(pnp.config,$+(event.,$2,.,$1)) != $null) %val = $ifmatch
  elseif ($hget(pnp.config,event. $+ $2) != $null) %val = $ifmatch
  ; If we found non-zero, return it
  if (%val) return %val
  ; Retrieve mIRC setting
  %val = $gettok($iif($2 == quit,chan.0.both.hide,$iif($2 == nick,chan.hide,chan.0.hide)),$mirc.event($1,$findtok(join.part.quit.mode.topic.ctcp.nick.kick,$2,1,46)),46)
  return %val
}

; $mirc.event(#chan,token)
; Retrieves mirc event settings in a #channel
; Uses defaults if channel-specific not present
; Caches as needed
alias -l mirc.event {
  ; Default events cached? Read in, default to all zeroes
  if ($hget(pnp,ev.def) == $null) {
    var %data = $readini($mircini,n,events,default),%pos = 1
    if (%data == $null) %data = 0,0,0,0,0,0,0,0
    ; Increase all by one, as defaults are "off" by one
    while (%pos <= 8) {
      %data = $puttok(%data,$calc($gettok(%data,%pos,44) + 1),%pos,44)
      inc %pos
    }
    ; Cache for up to 8 seconds
    hadd -u8 pnp ev.def %data
  }
  ; Events for this window cached? Start with defaults
  if ($hget(pnp,ev. $+ $1) == $null) {
    var %data = $hget(pnp,ev.def),%pos = 1
    ; If specific events exist, use those
    if ($readini($mircini,n,events,$1)) {
      %data = $ifmatch
      ; For each zero, replace with default
      while (%pos <= 8) {
        if ($gettok(%data,%pos,44) == 0) %data = $puttok(%data,$gettok($hget(pnp,ev.def),%pos,44),%pos,44)
        inc %pos
      }
    }
    ; Cache for up to 8 seconds
    hadd -u8 pnp ev. $+ $1 %data
  }
  ; Return requested token
  return $gettok($hget(pnp,ev. $+ $1),$2,44)
}

; Mode, Join, Part, Quit, Kick, Nick, Topic
on &^*:RAWMODE:#:{
  event.target $chan mode
  if ($result == hide) halt

  set -u %::chan $chan
  set -u %::modes $1-
  set -u %::text $1-
  set -u %::nick $nick
  set -u %::address $address

  if ($result == chan) {
    set -u %:echo echo $color(mode) -ti2 $chan
    theme.text Mode c
  }
  elseif ($result) {
    set -u %:echo echo $color(mode) -ti2 $event.win($chan)
    theme.text Mode c
  }
  else {
    set -u %:echo echo $color(mode) -esti2
    theme.text ModeStatus c
  }

  halt
}
on me:&^*:JOIN:#:{
  ; Myself
  set -u %::chan $chan
  set -u %::nick $nick
  set -u %::address $address
  set -u %:echo echo $color(join) -ti2 $chan
  set -u %:linesep dispr-div $chan
  theme.text JoinSelf c
  ; Linesep?
  if ($hget(pnp.events,JoinSelfLineSep)) dispr-div $chan
  halt
}
on &^!*:JOIN:#:{
  ; Others
  event.target $chan join
  if ($result == hide) halt
  var %targ = $result

  set -u %::chan $chan
  set -u %::nick $nick
  set -u %::address $address

  ; Clone count, for %:comments
  ; Only if enabled and level < 25
  if (($_getchopt($chan,7)) && ($_level($chan,$level($fulladdress)) < 25)) {
    var %num = 1,%who,%mask = $mask($fulladdress,1),%count = $ialchan(%mask,$chan,0)
    ; If not scanning by ident, and more clones by site alone, use that
    if ($_getcflag($chan,2) == 0) {
      if ($ialchan($wildsite,$chan,0) > %count) {
        %count = $ifmatch
        %mask = $wildsite
      }
    }
    ; If only one, ignore
    if (%count > 1) {
      ; List all other nicks, up to 5 total
      while ((%num <= %count) && ($numtok(%who,32) < 5)) {
        if ($ialchan(%mask,$chan,%num).nick != $nick) %who = %who $ifmatch
        inc %num
      }
      ; More we didn't do?
      if (%num <= %count) %who = %who ...
      ; Record recent user, recent clones, recent offense
      _recseen 10 user $nick
      _recseen 10 clones $nick $+ , $+ $_s2c(%who)
      _recseen 10 offend $+ $chan $fulladdress clones %count %mask
      set -u %:comments - $:b(Clones) $+ : %count from $nick ( $+ $_s2cs(%who) $+ ) CtrlF1 whois; ShiftF8 ping $+ $iif(($me isop $chan) || ($me ishop $chan),; F8 to punish)
      ; Sound effect
      _ssplay Clones
    }
  }

  ; Display    
  if (%targ == chan) {
    set -u %:echo echo $color(join) -ti2 $chan
    theme.text Join c
  }
  elseif (%targ) {
    set -u %:echo echo $color(join) -ti2 $event.win($chan)
    theme.text Join c
  }
  else {
    set -u %:echo echo $color(join) -esti2
    theme.text JoinStatus c
  }
  halt
}
on &^!*:PART:#:{
  event.target $chan part
  if ($result == hide) halt

  set -u %::chan $chan
  set -u %::nick $nick
  set -u %::address $address
  set -u %::text $strip($1-,mo)

  ; Display
  if ($result == chan) {
    set -u %:echo echo $color(part) -ti2 $chan
    theme.text Part cp
  }
  elseif ($result) {
    set -u %:echo echo $color(part) -ti2 $event.win($chan)
    theme.text Part cp
  }
  else {
    set -u %:echo echo $color(part) -esti2
    theme.text PartStatus cp
  }
  halt
}
on &^!*:QUIT:{
  set -u %::nick $nick
  set -u %::address $address
  set -u %::text $strip($1-,mo)

  ; Loop through all channels
  var %num = $comchan($nick,0),%status = 0
  while (%num >= 1) {
    var %chan = $comchan($nick,%num)
    set -u %::chan %chan

    event.target %chan quit
    if ($result != hide) {
      ; Display for this channel
      if (($result == chan) || ($result == both)) {
        if ($result == both) %status = 1
        set -u %:echo echo $color(quit) -ti2 %chan
        theme.text Quit cp
      }
      elseif ($result) {
        set -u %:echo echo $color(quit) -ti2 $event.win(%chan)
        theme.text Quit cp
      }
      else {
        %status = 1
      }
    }

    dec %num
  }

  ; To status?
  if (%status) {
    unset %::chan
    set -u %:echo echo $color(quit) -esti2
    theme.text Quit p
  }
  halt
}
on &^*:KICK:#:{
  ; Me kicked?
  if ($knick == $me) {
    set -u %::chan $chan
    set -u %::nick $nick
    set -u %::address $address
    set -u %::knick $knick
    set -u %::kaddress $gettok($address($knick,5),2-,33)
    set -u %::text $strip($1-,mo)

    ; Display- status
    set -u %:echo echo $color(kick) -esti2
    theme.text KickSelf cp

    ; To chan (if open)
    if ($chan ischan) {
      set -u %:echo echo $color(kick) -ti2 $chan
      theme.text KickSelf cp

      ; Rejoin (if not kicking self)
      if ($nick != $me) {
        set -u %:echo echo $color(info) -ti2 $chan
        theme.text Rejoin
      }
    }
  }

  ; Someone else kicked
  else {
    event.target $chan kick
    if ($result == hide) halt

    set -u %::chan $chan
    set -u %::nick $nick
    set -u %::address $address
    set -u %::knick $knick
    set -u %::kaddress $gettok($address($knick,5),2-,33)
    set -u %::text $strip($1-,mo)

    ; Display
    if ($result == chan) {
      set -u %:echo echo $color(kick) -ti2 $chan
      theme.text Kick cp
    }
    elseif ($result) {
      set -u %:echo echo $color(kick) -ti2 $event.win($chan)
      theme.text Kick cp
    }
    else {
      set -u %:echo echo $color(kick) -esti2
      theme.text KickStatus cp
    }
  }

  halt
}
on &^*:NICK:{
  set -u %::nick $nick
  set -u %::newnick $newnick
  set -u %::address $address

  ; Loop through all channels
  var %num = $comchan($newnick,0),%status = 0
  while (%num >= 1) {
    var %chan = $comchan($newnick,%num)
    set -u %::chan %chan

    event.target %chan nick
    if ($result != hide) {
      ; Display for this channel
      if (($result) && ($result != chan)) {
        set -u %:echo echo $color(nick) -ti2 $event.win(%chan)
        theme.text Nick n
      }
      else {
        set -u %:echo echo $color(nick) -ti2 %chan
        theme.text Nick n
      }
    }

    dec %num
  }

  ; Self nick in status?
  if ($nick == $me) {
    unset %::chan
    set -u %:echo echo $color(nick) -esti2
    theme.text NickSelf
  }

  halt
}
on &^*:TOPIC:#:{
  event.target $chan topic
  if ($result == hide) halt

  set -u %::chan $chan
  set -u %::text $strip($1-,mo) $+ 
  set -u %::nick $nick
  set -u %::address $address

  if ($result == chan) {
    set -u %:echo echo $color(topic) -ti2 $chan
    theme.text Topic c
  }
  elseif ($result) {
    set -u %:echo echo $color(topic) -ti2 $event.win($chan)
    theme.text Topic c
  }
  else {
    set -u %:echo echo $color(topic) -esti2
    theme.text TopicStatus c
  }

  halt
}

#pp-texts end

; Allow copy of private text/action to current window even if text display off
on &^*:TEXT:*:?:{ copy.toquery $color(norm) $1- }
on &^*:ACTION:*:?:{ copy.toquery $color(act) $1- }
alias -l copy.toquery {
  if ($hget(pnp.config,copy.query)) {
    ; Skip global msgs
    if ($left($target,1) == $) return
    ; Active must be a chan or query
    if (($active !ischan) && ($query($active) != $active)) return
    ; Active cannot be the current query, but a query must be open or dqwindow enabled
    if (($active == $nick) || (($query($nick) == $null) && (!$_optn(0,22)))) return
    ; Show copy to active
    echo $1 -lmbfati2 $iif($activecid != $cid,$:anp) * $+ %nick $+ * $strip($2-,mo)
  }
}

; Handle opnotices entirely ourselves if text display off; play notice sound even if not an opnotice
on &^*:NOTICE:*:#:{
  if (@* iswm $target) {
    _ssplay NoticeChanOp
    notice.beep
    show.opnotice $chan - $+ $nick $+ : $+ $target $+ - $strip($1-,mo)
    halt
  }
  else {
    _ssplay Notice
  }
}

; Handle private notices entirely ourselves if not shown to "normal" location if text display off
on &^*:NOTICE:*:?:{
  ; Determine method of display
  ; "Opnotice"
  if (%.opnotice) {
    ; Event beep and sound
    _ssplay NoticeChanOp
    notice.beep
    show.opnotice %.opnotice - $+ $nick $+ - $strip($1-,mo)
  }
  else {
    _ssplay Notice
    ; See event in #pp-texts group for comments- we handle anything where %window is non-zero, and only play beeps then
    if ($istok($hget(pnp. $+ $cid,-servnick),$nick,32)) var %window = $hget(pnp.config,serv.notice)
    else var %window = $hget(pnp.config,reg.notice)
    if (($1 === DCC) || (%window == 2)) {
      notice.beep
      echo $color(notice) -esti2 - $+ $nick $+ - $strip($1-,mo)
    }
    elseif (%window == 1) {
      notice.beep
      notice.window $nick
      echo $color(notice) -mbfti2 $result - $+ $nick $+ - $strip($1-,mo)
    }
    ; Let mirc handle display and event beep
    else return
  }
  halt
}

; Versions of cmds to allow quickhelp and nickcompletion (if text display off)
alias msg {
  if ($2 == $null) {
    if ($show) _qhelp /msg $1
    halt
  }
  msg $iif($show,$_ncs(44,$1),$1) $2-
}
alias describe {
  if ($2 == $null) {
    if ($show) _qhelp /describe $1
    halt
  }
  describe $iif($show,$_ncs(44,$1),$1) $2-
}
alias notice {
  if ($2 == $null) {
    if ($show) _qhelp /notice $1
    halt
  }
  notice $iif($show,$_ncs(44,$1),$1) $2-
}

; Show linesep on join if theming off
on me:&^*:JOIN:#:{
  .timer 1 0 dispr-div $chan
}

; Display clones on join if theming off
on &^!*:JOIN:#:{
  ; Only if enabled and level < 25
  if (($_getchopt($chan,7)) && ($_level($chan,$level($fulladdress)) < 25)) {
    var %num = 1,%who,%mask = $mask($fulladdress,1),%count = $ialchan(%mask,$chan,0)
    ; If not scanning by ident, and more clones by site alone, use that
    if ($_getcflag($chan,2) == 0) {
      if ($ialchan($wildsite,$chan,0) > %count) {
        %count = $ifmatch
        %mask = $wildsite
      }
    }
    ; If only one, ignore
    if (%count > 1) {
      ; List all other nicks, up to 5 total
      while ((%num <= %count) && ($numtok(%who,32) < 5)) {
        if ($ialchan(%mask,$chan,%num).nick != $nick) %who = %who $ifmatch
        inc %num
      }
      ; More we didn't do?
      if (%num <= %count) %who = %who ...
      ; Record recent user, recent clones, recent offense
      _recseen 10 user $nick
      _recseen 10 clones $nick $+ , $+ $_s2c(%who)
      _recseen 10 offend $+ $chan $fulladdress clones %count %mask
      _juryrig2 disprc $chan $:b(Clones) $+ : %count from $nick ( $+ $_s2cs(%who) $+ ) CtrlF1 whois; ShiftF8 ping $+ $iif(($me isop $chan) || ($me ishop $chan),; F8 to punish)
      ; Sound effect
      _ssplay Clones
    }
  }
}

;
; Nicklist coloring
;

; Retain nick colors for each user in hash pnp.nickcol.$cid.#chan
; Retain nick color flags for each user in hash pnp.nickflag.$cid.#chan (p for pinging, L for lagged, * for ircop)
; Nicklist shows all colors; nicks in channel don't show ping/lag colors
; Nicklist and channel nicks can be individually turned on/off for colors

; $_nickcol(nickname,channel)
; Returns two-digit color code
alias _nickcol {
  if ($hget($+(pnp.nickcol.,$cid,.,$2),$1)) return $ifmatch
  return $color(listbox text)
}

; $_nickcol.flag(nickname,channel)
; Returns flags, if any
alias _nickcol.flag {
  return $hget($+(pnp.nickflag.,$cid,.,$2),$1)
}

; /_nickcol.set nickname fulladdress channel
; Updates nickname color in hash for a user on a channel
; Assumes hashes exist
alias _nickcol.set {
  var %flag
  ; Determine op/hop/voice status
  if ($1 isop $3) %flag = @
  elseif ($1 ishop $3) %flag = %
  elseif ($1 isvoice $3) %flag = +
  ; Determine if a mIRC nickcolor exists
  if ($cnick(%flag $+ $1)) {
    hadd $+(pnp.nickcol.,$cid,.,$3) $1 $cnick(%flag $+ $1,1).color
  }
  ; Find a PnP nickcolor
  else {
    ; (grab one of the four sets of colors from PnPNickColors based on op status)
    _nickcol.2 $gettok($hget(pnp.theme,PnPNickColors),$calc($pos(+%@,%flag) + 1),44) $1-3 $hget($+(pnp.nickflag.,$cid,.,$3),$1)
    hadd $+(pnp.nickcol.,$cid,.,$3) $1 $result
  }
}
alias _nickcol.2 {
  ; (1-8 are colors, 9 nick 10 addr 11 chan 12 flags)
  ; Pinged, Lagged, Me, Ircop, Color level in userlist, Ignore/Blacklist, Notify failed, Notify/userlist, Default
  if ((p isin $12) && ($8 isnum)) return $8
  if ((L isin $12) && ($7 isnum)) return $7
  ; hack so nick changes on your own nick work properly
  if (($6 isnum) && ($iif($event == NICK,$nick,$9) == $me)) return $6
  if ((* isin $12) && ($5 isnum)) return $5
  if ($wildtok($level($10),=color*,1,44)) return $remove($ifmatch,=color)
  if (($4 isnum) && (($10 isignore) || ($istok($level($10),=black,44)))) return $4
  if (($3 isnum) && (($9 isnotify) && ($gettok($hget(pnp. $+ $cid,-notify.on. $+ $9),3,32) == fail))) return $3
  if (($2 isnum) && (($9 isnotify) || ($level($10) != $dlevel))) return $2
  if ($1 isnum) return $1
  return $color(listbox text)
}

; /_nickcol.flagset nickname channel newflags
; Sets flags for a user (replacing existing)
; Assumes hashes exist
alias _nickcol.flagset {
  hadd $+(pnp.nickflag.,$cid,.,$2) $1 $3
}

; /_nickcol.rem nickname channel
; Removes a user from nicklist color database
; Assumes hashes exist
alias _nickcol.rem {
  hdel $+(pnp.nickcol.,$cid,.,$2) $1
  hdel $+(pnp.nickflag.,$cid,.,$2) $1
}

; /_nickcol.kill [channel]
; Deletes nicklist hashes for a chan or everywhere (this cid only)
alias _nickcol.kill {
  if ($1) {
    if ($hget($+(pnp.nickcol.,$cid,.,$1))) hfree $+(pnp.nickcol.,$cid,.,$1)
    if ($hget($+(pnp.nickflag.,$cid,.,$1))) hfree $+(pnp.nickflag.,$cid,.,$1)
  }
  else {
    hfree -w pnp.nickcol. $+ $cid $+ .*
    hfree -w pnp.nickflag. $+ $cid $+ .*
  }
}  

#pp-nicklist on

; /_nickcol.update nickname channel [callset]
; /_nickcol.updatechan channel [callset]
; /_nickcol.updatenick nickname [callset]
; /_nickcol.updatemask mask [callset]
; Updates color in nicklist for one nickname or mask (all chans), one channel, or one nick on a channel
; callset = true to call _nickcol.set also for each nick, with ial address or blank address if needed
; (this is used when filling the nicklist for the first time or updating things)

alias _nickcol.update {
  if ($3) _nickcol.set $1 $iif($address($1,5),$ifmatch,$1 $+ !*@*) $2
  cline $_nickcol($1,$2) $2 $1
}
alias _nickcol.updatechan {
  var %num = $nick($1,0)
  while (%num >= 1) {
    _nickcol.update $nick($1,%num) $1 $2
    dec %num
  }
}  
alias _nickcol.updatenick {
  var %num = $comchan($1,0)
  while (%num >= 1) {
    _nickcol.update $1 $comchan($1,%num) $2
    dec %num
  }
}
alias _nickcol.updatemask {
  var %num = $ial($1,0)
  while (%num >= 1) {
    _nickcol.updatenick $ial($1,%num).nick $2
    dec %num
  }
}  

#pp-nicklist end

; These are used if nicklist coloring is off- none except update chan do anything, which clears colors
alias _nickcol.update { return }
alias _nickcol.updatechan {
  var %num = $nick($1,0)
  while (%num >= 1) {
    cline -r $1 $nick($1,%num)
    dec %num
  }
}  
alias _nickcol.updatenick { return }
alias _nickcol.updatemask { return }

; On every /who line- update info
raw 352:*:{
  if ($me ison $2) {
    _nickcol.flagset $6 $2 $7
    _nickcol.set $6 $6 $+ ! $+ $3 $+ @ $+ $4 $2
    _nickcol.update $6 $2
  }
}

; Whenever someone joins, changes op status, or changes nick- update info
on !*:JOIN:#:{
  _nickcol.set $nick $fulladdress $chan
  _nickcol.update $nick $chan
  ; On join interface called from here; code is later
  perform.onjoin
}
on *:OP:#:{ nickcol.onop $opnick }
on *:DEOP:#:{ nickcol.onop $opnick }
on *:OWNER:#:{ nickcol.onop $opnick }
on *:DEOWNER:#:{ nickcol.onop $opnick }
on *:HELP:#:{ nickcol.onop $hnick }
on *:DEHELP:#:{ nickcol.onop $hnick }
on *:VOICE:#:{ nickcol.onop $vnick }
on *:DEVOICE:#:{ nickcol.onop $vnick }
on *:SERVEROP:#:{ nickcol.onop $opnick }
alias -l nickcol.onop {
  _nickcol.set $1 $iif($address($1,5),$ifmatch,$1 $+ !*@*) $chan
  _nickcol.update $1 $chan
}
on *:NICK:{
  if ($nick == $newnick) return
  var %num = $comchan($newnick,0)
  while (%num >= 1) {
    _nickcol.flagset $newnick $comchan($newnick,%num) $_nickcol.flag($nick,$comchan($newnick,%num))
    _nickcol.set $newnick $newnick $+ ! $+ $address $comchan($newnick,%num)
    _nickcol.update $newnick $comchan($newnick,%num)
    _nickcol.rem $nick $comchan($newnick,%num)
    dec %num
  }
}

; Whenever someone parts, quits, or is kicked- remove info
; Whenever I part or am kicked- remove all info for channel (nickcol and chanflood)
on *:PART:#:{
  if ($nick == $me) {
    _nickcol.kill $chan
    hfree $+(pnp.flood.,$cid,.,$chan)
  }
  else {
    _nickcol.rem $nick $chan
  }
}
on *:KICK:#:{
  if ($knick == $me) {
    _nickcol.kill $chan
    hfree $+(pnp.flood.,$cid,.,$chan)
  }
  else {
    _nickcol.rem $knick $chan
  }
}
on *:QUIT:{
  var %num = $comchan($nick,0)
  while (%num >= 1) {
    _nickcol.rem $nick $comchan($nick,%num)
    dec %num
  }
}

;
; On join interface - whois, ircopcheck, and anything an addon might add
;

alias -l perform.onjoin {
  ; More than 3 in a row causes a halt in join checks
  hinc -z pnp. $+ $cid -massjoin
  if ($hget(pnp. $+ $cid,-massjoin) > 3) { if ($hget(pnp. $+ $cid,-massjoin) > 10) hadd -z pnp. $+ $cid -massjoin 10 }
  ; If -just- an ircopcheck and no whois to show, we can use /userhost
  elseif ((%.joinwhois.do == _ircopchk) && (%.joinwhois.show == 0)) {
    ; Queue all checks for a channel
    hadd pnp. $+ $cid -ircopchk. $+ $chan $addtok($hget(pnp. $+ $cid,-ircopchk. $+ $chan),$nick,32)
    ; Peform at 5, or after 500ms
    if ($numtok($hget(pnp. $+ $cid,-ircopchk. $+ $chan),32) == 5) perform.onjoin.uhost $chan
    else .timer.ircop.uh. $+ $cid $+ . $+ $chan -m 1 500 perform.onjoin.uhost $chan
  }
  ; %.joinwhois.show is 0 to hide, 1 to show, 2 to show in channel
  ; %.joinwhois.do contains anything to perform on the join whois results
  elseif ((%.joinwhois.do) || (%.joinwhois.show)) _linedance _whois.queue $nick $iif(%.joinwhois.show == 1,*,$iif(%.joinwhois.show == 2,$chan,0)) _onjoin.whois $chan %.joinwhois.do
  unset %.joinwhois.show %.joinwhois.do
}
alias -l perform.onjoin.uhost {
  ; userhost to check for ircop status
  _linedance _Q.userhost _ircopchk $+ $1 $+ &n&a&i halt $hget(pnp. $+ $cid,-ircopchk. $+ $1)
  .timer.ircop.uh. $+ $cid $+ . $+ $1 off
  hdel pnp. $+ $cid -ircopchk. $+ $1
}
; /_onjoin.whois chan alias alias ...
; called when an on-join whois completes
alias _onjoin.whois {
  ; stop on any error
  if ($hget(pnp.twhois. $+ $cid,error)) return
  var %num = 2
  while ($ [ $+ [ %num ] ] ) {
    ; Call each alias in turn, use blackbox to prevent halting on errors
    _blackbox $ifmatch $1 $hget(pnp.twhois. $+ $cid,nick)
    inc %num
  }
}

;
; Misc theming
;

on &^*:USERMODE:{
  if ($1- != $null) {
    set -u %:echo echo $color(mode) -sti2
    set -u %:linesep disps-div
    set -u %::nick $nick
    set -u %::address $address
    set -u %::modes $1-
    set -u %::text $1-
    theme.text ModeUser
  }
  halt
}
on &^*:ERROR:*:{
  set -u %::text $iif(($1 == ERROR) || ($1 == ERROR:),$2-,$1-)
  ; Halt /quit error closing link
  if (($remove($gettok(%::text,1-2,32),:) == Closing Link) && ($hget(pnp. $+ $cid,quithalt != $null))) {
    if ($ifmatch isin %::text) halt
  }

  set -u %:echo echo $color(ctcp) -esti2
  set -u %:linesep disps-div
  set -u %::fromserver $nick
  theme.text ServerError
  halt
}

;!! Here on not rewritten nicely

;
; Invites
;

on &^*:INVITE:#:{
  hinc -u30 pnp.flood. $+ $cid recd.inv
  if (!$_known($nick,$fulladdress)) hinc -u30 pnp.flood. $+ $cid recd.inv. $+ $site
  ; long channels- flood counts more
  if ($len($chan) > 30) hinc -u30 pnp.flood. $+ $cid recd.inv. $+ $site
  if (($hget(pnp.flood. $+ $cid,recd.inv. $+ $site) > 3) || ($hget(pnp.flood. $+ $cid,recd.inv) > 5)) {
    .ignore -iu120 **!**@**
    _alert Flood Invite flood from $:b($nick) $chr(40) $+ $address $+ $chr(41) Further invites won't be shown
  }
  if (($hget(pnp.flood. $+ $cid,recd.inv. $+ $site) > 2) || ($hget(pnp.flood. $+ $cid,recd.inv) > 3)) halt
  _recseen 10 user $nick
  if ($_optn(3,11)) {
    if ($_cfgi(verify.inv)) {
      .ajinvite off | .timer -mio 1 0 .ajinvite on
      hadd pnp. $+ $cid -invited $hget(pnp. $+ $cid,-invited) $chan
      _linedance .raw mode $chan
      hadd pnp. $+ $cid -invn. $+ $chan $hget(pnp. $+ $cid,-invn. $+ $chan) $nick
    }
    else {
      _show.invite $nick $chan - Auto-joining
      _ssplay Invite
      _recseen 10 user $nick
    }
  }
  elseif ($_cfgi(verify.inv)) {
    hadd pnp. $+ $cid -invited $hget(pnp. $+ $cid,-invited) $chan
    _linedance .raw mode $chan
    hadd pnp. $+ $cid -invn. $+ $chan $hget(pnp. $+ $cid,-invn. $+ $chan) $nick
  }
  else {
    _show.invite $nick $chan - Press ShiftF11 to join
    _ssplay Invite
    _recseen 10 chan $chan
    _recseen 10 user $nick
  }
  halt
}

; Themed invite
; /_show.invite NICK CHAN comments
alias _show.invite {
  set -u %::nick $1
  set -u %::chan $2
  set -u %:comments $3-
  set -u %:echo echo $color(invite) -mti2 $+ $iif($_optn(3,26),a $iif($activecid != $cid,$:anp),s)
  theme.text Invite
}

;
; Menu endings
;

menu query {
  -
  $iif((($mid($hget(pnp.config,popups.2),9,1) != 0) || ($mouse.key & 2)) && ($active != Notify List),Window)
  .Hide:hide $active
  .Close:if (= isin $active) close -cf $1 | elseif ($active == Message Window) dqwindow hide | else closemsg $1
  .-
  .Logging
  ..On:log on
  ..Off:log off
  ..-
  ..View:viewlog
  ..Delete:dellog
  .Clear:clear
  $iif(($mid($hget(pnp.config,popups.2),10,1) != 0) || ($mouse.key & 2) || ($active == Notify List),Close):if ($active == Notify List) notify -h | else closemsg $1
  ;!!$iif(($mid($hget(pnp.config,popups.2),11,1) != 0) || ($mouse.key & 2),Help):{ }
}

menu channel {
  -
  $iif(($mid($hget(pnp.config,popups.3),10,1) != 0) || ($mouse.key & 2),Window)
  .Hide:hide $active
  .Close:if ($active ischan) { part # | dispa Parting # $+ ... } | elseif (= isin $active) close -cf $1 | elseif ($active == Message Window) dqwindow hide | else closemsg $1
  .-
  .Logging
  ..On:log on
  ..Off:log off
  ..-
  ..View:viewlog
  ..Delete:dellog
  .Clear:clear
  $iif(($mid($hget(pnp.config,popups.3),9,1) != 0) || ($mouse.key & 2),Part):part # | dispa Parting # $+ ...
  ;!!$iif(($mid($hget(pnp.config,popups.3),11,1) != 0) || ($mouse.key & 2),Help):{ }
}

menu status {
  -
  $iif((($mid($hget(pnp.config,popups.5),2,1) != 0) && $server) || ($mouse.key & 2),Channels)
  .$_rec(chan,1):join %=chan.1
  .$_rec(chan,2):join %=chan.2
  .$_rec(chan,3):join %=chan.3
  .$_rec(chan,4):join %=chan.4
  .$_rec(chan,5):join %=chan.5
  .-
  .$_rec(chan,6):join %=chan.6
  .$_rec(chan,7):join %=chan.7
  .$_rec(chan,8):join %=chan.8
  .$_rec(chan,9):join %=chan.9
  .$_rec(chan,10):join %=chan.10
  .-
  .$_rec(chan,11):join %=chan.11
  .$_rec(chan,12):join %=chan.12
  .$_rec(chan,13):join %=chan.13
  .$_rec(chan,14):join %=chan.14
  .$_rec(chan,15):join %=chan.15
  .-
  .%=chan.clr:_recclr chan
  .$iif(%=chan.1 || ($mouse.key & 2),$iif($_cfgi(fill.chan),Lock this list,Unlock list $chr(40) $+ currently locked $+ $chr(41))):{
    if ($_cfgi(fill.chan)) { disps Channels menu is now locked and will not 'fill' automatically. | _cfgw fill.chan 0 }
    else { disps Channels menu is unlocked and will fill with channels that you join. | _cfgw fill.chan 1 }
  }
  .Join other...:join $_s2c($_entry(0,$null,Channel $+ $chr(40) $+ s $+ $chr(41) to join? $+ $chr(40) $+ You may specify multiple channels. $+ $chr(41)))
  .-
  .Edit...:fav
  $iif((($mid($hget(pnp.config,popups.5),1,1) != 0) && $server) || ($mouse.key & 2),List channels)
  .With 5 or more users:list >5
  .With 10 or more users:list >10
  .With 20 or more users:list >20
  .With X or more users...:{
    var %num = $_entry(-2,$iif($_dlgi(list) isnum,$_dlgi(list),10),List channels with at least how many users?)
    list > $+ %num
    _dlgw list %num
  }
  .-
  .All $chr(40) $+ smaller networks $+ $chr(41):list
  -
  $iif(($mid($hget(pnp.config,popups.5),4,1) != 0) || ($mouse.key & 2),Nickname)
  .$_rec(nick,1):nick %=nick.1
  .$_rec(nick,2):nick %=nick.2
  .$_rec(nick,3):nick %=nick.3
  .$_rec(nick,4):nick %=nick.4
  .$_rec(nick,5):nick %=nick.5
  .$_rec(nick,6):nick %=nick.6
  .$_rec(nick,7):nick %=nick.7
  .$_rec(nick,8):nick %=nick.8
  .$_rec(nick,9):nick %=nick.9
  .-
  .%=nick.clr:_recclr nick | _recent nick 9 0 $me
  .Other...:nick $_entry(-1,$me,New nickname?)
  .-
  .$iif($hget(pnp. $+ $cid,oldrnick) == $null,Random nick):rn
  .$iif($hget(pnp. $+ $cid,oldrnick),Undo random nick):urn
  $iif(($mid($hget(pnp.config,popups.5),5,1) != 0) || ($mouse.key & 2),Usermode...):umode
  $iif((($mid($hget(pnp.config,popups.5),7,1) != 0) && $server) || ($mouse.key & 2),Server)
  .Port scan:ports
  .Server links:links
  .$iif((z isin $hget(pnp. $+ $cid,-feat)) || ($mouse.key & 2),Map of servers):map
  .List servers
  ..1 hop away:nearserv 1
  ..-
  ..Up to 2 hops away:nearserv 1 2
  ..Up to 3 hops away:nearserv 1 3
  ..-
  ..Custom...:nearserv ?
  .-
  .List IRCops:who 0 o
  .User counts:lusers
  .-
  .MOTD:motd
  .Time:.raw time
  .Version:.raw version
  $iif((($mid($hget(pnp.config,popups.5),8,1) != 0) && $server) || ($mouse.key & 2),Stats)
  .Global bans	g:stats g
  .Local bans	k:stats k
  .Commands	m:stats m
  .Operators	o:stats o
  .Uptime	u:stats u
  .-
  .$_rec(stats,1):stats %=stats.1
  .$_rec(stats,2):stats %=stats.2
  .$_rec(stats,3):stats %=stats.3
  .$_rec(stats,4):stats %=stats.4
  .$_rec(stats,5):stats %=stats.5
  .-
  .%=stats.clr:_recclr stats
  .Other...:stats
  -
  $iif(($mid($hget(pnp.config,popups.5),10,1) != 0) || ($mouse.key & 2),Window)
  .Hide:hide $active
  .-
  .Logging
  ..On:log on
  ..Off:log off
  ..-
  ..View:viewlog
  ..Delete:dellog
  .Clear:clear
  $iif((($mid($hget(pnp.config,popups.5),6,1) != 0) && $server) || ($mouse.key & 2),Quit...):quit $_rentry(quit,0,$_s2p($msg.compile($_msg(quit),&online&,$_dur($online))),Disconnecting- Quit message?This will be shown on any channels you are on.)
  ;!!$iif(($mid($hget(pnp.config,popups.5),11,1) != 0) || ($mouse.key & 2),Help):{ }
}

menu nicklist {
  -
  ;!!$iif(($mid($hget(pnp.config,popups.4),12,1) != 0) || ($mouse.key & 2),Help):{ }
}

menu menubar {
  -
  $iif($hget(pnp,hidden) || ($mouse.key & 2),Unhide all):unhide
  ;!!$iif(($mouse.key & 2) || ($mid($hget(pnp.config,popups.1),10,1) != 0),Help):{ }
}

;
; Generic WINDOW (sub)menus (not for picture windows/etc.)
;

; Window that only needs to close
menu @Close {
  Close:_wclose
}

; Window that closes on click
menu @Close2 {
  sclick:_wclose
  rclick:_wclose
}
alias -l _wclose window -c $active

; All other windows
menu @* {
  -
  $iif(($hget(pnp.window. $+ $active,select) >= 1) && (($mid($hget(pnp.config,popups.6),1,1) != 0) || ($mouse.key & 2)),Select all):_selectall $active $hget(pnp.window. $+ $active,select)
  $iif(($hget(pnp.window. $+ $active,copy)) && ((($mid($hget(pnp.config,popups.6),2,1) != 0) && ($sline($active,0))) || ($mouse.key & 2)),Copy):{
    if ($sline($active,0)) {
      var %num = 2,%clip = $strip($sline($active,1))
      if ($sline($active,0) > 1) {
        :loop
        %clip = %clip $+ $chr(157) $+ $strip($sline($active,%num))
        if (%num < $sline($active,0)) { inc %num | goto loop }
        %clip = %clip $+ $chr(157)
      }
      clipboard $replace(%clip,$chr(157),$crlf)
    }
  }
  -
  $iif(($hget(pnp.window. $+ $active,window)) && (($mid($hget(pnp.config,popups.6),3,1) != 0) || ($mouse.key & 2)),Window)
  .Hide:window -h $active
  .Close:_dowclose $active | window -c $active
  .-
  .$iif($hget(pnp.window. $+ $active,log),Logging)
  ..On:log on
  ..Off:log off
  ..-
  ..View:var %file = $readini($_cfg(window.ini),n,$active,log) | if (%file) %file = $logdir $+ %file | else %file = $logdir $+ $active $+ .log | if ($exists(%file)) edit %file | else disps File ' $+ %file $+ ' does not exist!
  ..Delete:var %file = $readini($_cfg(window.ini),n,$active,log) | if (%file) %file = $logdir $+ %file | else %file = $logdir $+ $active $+ .log | _remove %file
  .$iif($hget(pnp.window. $+ $active,log),Clear):clear $active | if ($active == @Whois) .remove $_temp(who)
  .$iif($line($active,0),Save...):_ssplay Question | var %save = $$sfile($logdir\ $+ $active $+ .txt,Save Buffer,Save) | if ($exists(%save)) _fileopt 2 %save | _bufsav $active %save
  .-
  .$iif(p !isin $hget(pnp.window. $+ $active,flags),Font)
  ..Select...:font
  ..Default:window -h @.fontgrab | var %font = $window(@.fontgrab).fontsize $window(@.fontgrab).font $iif($window(@.fontgrab).fontbold,bold) | window -c @.fontgrab | font %font
  .-
  .Position
  ..$iif($hget(pnp.window. $+ $active,remember),$style(1)) Remember:if ($hget(pnp.window. $+ $active,remember)) { hadd pnp.window. $+ $active 0 | writeini $_cfg(window.ini) $active rem 0 } | else { hadd pnp.window. $+ $active 1 | remini $_cfg(window.ini) $active rem }
  ..-
  ..Record now:{
    if (f isin $gettok($hget(pnp.window. $+ $active,flags),1,32)) hadd pnp.window. $+ $active position $window($active).x $window($active).y $window($active).dw $window($active).dh
    else hadd pnp.window. $+ $active position $window($active).x $window($active).y $window($active).w $window($active).h
    writeini $_cfg(window.ini) $active pos $hget(pnp.window. $+ $active,position)
  }
  ..Restore:window $active $hget(pnp.window. $+ $active,position)
  ..Default:window $active $hget(pnp.window. $+ $active,default) | hadd pnp.window. $+ $active position $hget(pnp.window. $+ $active,default) | remini $_cfg(window.ini) $active pos
  .$iif(p !isin $hget(pnp.window. $+ $active,flags),$iif(!$window($active).mdi,$style(1)) Desktop):if ($window($active).mdi) _deskon $active | else _deskoff $active
  $iif(($istok($hget(pnp.window. $+ $active,window),$active,32)) && (($mid($hget(pnp.config,popups.6),4,1) != 0) || ($mouse.key & 2)),Close):_dowclose $active | window -c $active
  $iif(($istok($hget(pnp.window. $+ $active,window),$active,32)) && (($mid($hget(pnp.config,popups.6),5,1) != 0) || ($mouse.key & 2)),Hide):window -h $active
  ;!!$iif(($istok($hget(pnp.window. $+ $active,help),$active,32)) && (($mid($hget(pnp.config,popups.6),6,1) != 0) || ($mouse.key & 2)),Help):{ }
}

; Common routines
alias -l _bufsav savebuf -a $1 " $+ $2- $+ " | disps Contents of $1 saved to ' $+ $2- $+ '
alias -l _deskon if ($window($1).mdi) _desktog $1 1
alias -l _deskoff if ($window($1).mdi) halt | _desktog $1 0
alias -l _desktog {
  var %title = $window($1).title,%edit = $editbox($1),%set = $hget(pnp.window. $+ $1,flags),%file = $_temp(dsk)
  if ($2) var %pos = $calc($window($1).x + $window(-3).dx) $calc($window($1).y + $window(-3).dy)
  else var %pos = $calc($window($1).x - $window(-3).dx) $calc($window($1).y - $window(-3).dy)
  if (f isin $gettok(%set,1,32)) %pos = %pos $window($1).dw $window($1).dh
  else %pos = %pos $window($1).w $window($1).h
  savebuf $1 %file
  window -c $1
  window $gettok(%set,1,32) $+ $iif($2,d) $_p2s($gettok(%set,2,32)) $1 %pos $gettok(%set,3-,32)
  titlebar $1 %title
  if (%edit) editbox $1 %edit
  loadbuf -c $+ $:c1 $1 %file
  .remove %file
  if ($2) writeini $_cfg(window.ini) $1 desk 1
  else remini $_cfg(window.ini) $1 desk
}

;
; Input wrappers
;

on &*:INPUT:*:{
  if ((($target !ischan) && ($query($target) == $null) && (=* !iswm $target)) || ($cmdbox)) return
  if (%.input.type == say) { if (($group(#pp-texts) == on) || (/say $1- != %.input.text)) { %.input.text | halt } }
  elseif (%.input.type == me) { if (($group(#pp-texts) == on) || ($1- != %.input.text)) { %.input.text | halt } }
  elseif (%.input.type == cmd) {
    if (?notice iswm $gettok(%.input.text,1,32)) { ntc $gettok(%.input.text,2-,32) | halt }
    elseif (($target ischan) && ($mid($gettok(%.input.text,1,32),2,1) isin +-)) {
      var %bits = $right($gettok(%.input.text,1,32),-1),%targ = $gettok(%.input.text,2-,32)
      goto %bits
      :+o | op %targ | halt
      :-o | dop %targ | halt
      :+h | hfop %targ | halt
      :-h | dhfop %targ | halt
      :+b | ban %targ | halt
      :-b | unban %targ | halt
      :+v | voc %targ | halt
      :-v | dvoc %targ | halt
      :%bits | mode %bits %targ | halt
    }
    elseif (%.input.text != $1-) { %.input.text | halt }
  }
}

; Once chat is opened, don't need to save why chat was opened
on *:OPEN:=:hdel pnp chat.open. $+ $nick

; Disconnect clearance
on *:DISCONNECT:{
  _nickcol.kill
  hadd pnp. $+ $cid net Offline
  hdel -w pnp. $+ $cid -*
  hdel -w pnp.flood. $+ $cid *
  hfree -w pnp.flood. $+ $cid $+ .*
  hdel -w pnp.ping. $+ $cid *
  unset %<*
  _upd.title
}

; flash/sounds that must be last
ctcp &*:DCC CHAT:?:_ssplay DCC
ctcp &*:DCC SEND:?:_ssplay DCCSend
on &^*:OPEN:?:*:_ssplay Open | if ($mid($hget(pnp.config,flash.opt),$iif($hget(pnp. $+ $cid,away),2,1),1)) flash $chr(91) $+ Query- $nick: $strip($1-) $+ $chr(93)
on &*:CHAT:*:if ($mid($hget(pnp.config,flash.opt),$iif($hget(pnp. $+ $cid,away),6,5),1)) flash $chr(91) $+ DCC- $nick: $strip($iif($1 == ACTION,$remove($2-,),$1-)) $+ $chr(93)
on &*:TEXT:*:?:if ($mid($hget(pnp.config,flash.opt),$iif($hget(pnp. $+ $cid,away),4,3),1)) flash $chr(91) $+ Msg- $nick: $strip($1-) $+ $chr(93)
on &*:ACTION:*:?:if ($mid($hget(pnp.config,flash.opt),$iif($hget(pnp. $+ $cid,away),4,3),1)) flash $chr(91) $+ Msg- $nick: $strip($1-) $+ $chr(93)

; Dragdrop defaults
on &*:SIGNAL:PNP.DRAGDROP:{
  if (($1 == n) && (*.wav iswm $3-)) sound $2 $3-
  else dcc send $iif(=* iswm $2,$right($2,-1),$2) $3-
}
