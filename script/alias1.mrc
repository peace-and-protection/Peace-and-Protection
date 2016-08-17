; #= P&P -a
; **********************
; Unsorted routines
; **********************
;
;;;###*** Not yet divided ***###;;;

; (returns mode with key even if 'hide channel mode' is enabled)
_chmode if (($chan($1).key != $null) && ($gettok($chan($1).mode,-1,32) != $chan($1).key)) return $chan($1).mode $chan($1).key | return $chan($1).mode

; _notconnected [error explanation]
; halts (checks $server)
_notconnected {
  if ($server) return
  _error You must be connected to use that command $+ $iif($1,$1-,(can't look up user info))
  halt
}

; _cidexists cid
; halts if cid no longer exists, with no error
_cidexists {
  if ($scid($1)) return
  halt
}

; Opposite of wildtok- returns token num that matches given token
; $_searchtok(tokens,tok,chr)
_searchtok {
  var %pos = 1,%total = $numtok($1,$3)
  :loop
  if ($gettok($1,%pos,$3) iswm $2) return %pos
  if (%pos < %total) { inc %pos | goto loop }
  return 0
}

; Date and time in default formats (current or given)
_date return $date($iif($1,$1,$ctime),$_cfgi(format.date))
_time return $time($iif($1,$1,$ctime),$_cfgi(format.time))
_datetime return $_date($iif($1,$1,$ctime)) $_time($iif($1,$1,$ctime))

_poptop var %poptop = $strip($replace($_rec(topic,$1),&&chan&&,#)) | if ($len(%poptop) > 75) return $left(%poptop,71) ... | return %poptop

; prevents reading options n0 thru n5 more than once every X seconds
; usage- $_optn(line,token) etc
_optn if ($hget(pnp,opt.n $+ $1) == $null) hadd -u8 pnp opt.n $+ $1 $readini($mircini,n,options,n $+ $1) | return $gettok($hget(pnp,opt.n $+ $1),$2,44)

; PW fog
_pw.enc {
  var %ret,%pos = 1
  while (%pos <= $len($1)) {
    %ret = $chr($calc(160 - $asc($mid($1,%pos,1)))) $+ %ret
    inc %pos
  }
  return %ret
}

; Escapes given characters
; $_chrescape(text,\[\]{}\|)
_chrescape {
  var %new
  var %leftspace = 1
  var %pos = 1

  while ($regex(prep,$mid($1,%pos),/([ $+ $2 $+ ])/)) {
    var %found = $regml(prep,1)
    var %foundpos = $calc($regml(prep,1).pos + %pos - 1)
    var %foundlen = $len(%found)

    ; Append any non-matching portion now
    if (%foundpos > %pos) {
      if (($mid($1,%pos,1) == $chr(32)) || (%new == $null)) %new = %new $mid($1,%pos,$calc(%foundpos - %pos))
      else %new = %new $!+ $mid($1,%pos,$calc(%foundpos - %pos))
      %leftspace = $iif($mid($1,$calc(%foundpos - 1),1) == $chr(32),1,0)
    }
    elseif (%new != $null) %leftspace = 0
    %found = $!chr( $+ $asc(%found) $+ )
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

  return %new
}

_merge return $remove($1-,$chr(32))
; o2tf recognizes on/off in addition to translated on/off
_tf2o return $iif($1,On,Off)
_o2tf return $iif(($1 == On) || ($1 == On),1,0)
_dur return $iif($1 >= 86400,$int($calc($1 / 86400)) day) $iif($1 >= 3600,$int($calc($1 % 86400 / 3600)) hr) $iif($1 >= 60,$int($calc($1 % 3600 / 60)) min) $calc($1 % 60) s
_p if ($2 == 0) return 0% | return $round($calc($1 * 100 / $2),2) $+ %
:www return $1 $+ http://www.kristshell.net/pnp/ $+ $1
:email return $1 $+ pnp@login.kristshell.net $+ $1
_known if ($notify($1)) return 1 | if ($2) return $iif($remtok($level($2),=black,44) != $dlevel,1,0) | return $iif($remtok($level($address($1,5)),=black,44) != $dlevel,1,0)
; Prefixes each char with + or -
_fixmode {
  var %final,%bit = +,%pos = 1
  :loop
  if ($mid($1,%pos,1)) {
    if ($ifmatch isin -+) %bit = $ifmatch
    else %final = %final $+ %bit $+ $mid($1,%pos,1)
    inc %pos | goto loop
  }
  return %final
}
; $_convmode(modes,char,default)
; Finds char in a fixmoded string and returns 1 or 0 for + or -, or default if not present (0 if not given)
_convmode if (- $+ $2 isin $1) return 0 | if (+ $+ $2 isin $1) return 1 | if ($3- != $null) return $3- | return 0

;
; Run an URL or e-mail
;
http saveini | if ($readini($mircini,n,files,browser) != $null) run $ifmatch $1- | elseif (*://* iswm $1-) run $1- | else run http:// $+ $1-
mailto run mailto: $+ $1-

;
; Size in kb/meg/etc
;
_size {
  if ($1 == $null) return (???)
  if ($1 < 10240) return $1 $+ bytes
  if ($1 < 10240000) return $round($calc($1 / 1024),1) $+ $+ k
  return $round($calc($1 / 1048576 + 0.00001),1) $+ $+ meg
}

;
; Recent target trackers (unique to one mirc)
;

; _recseen max type value [suffix] (one word; suffix is ignored in duplication searchs and is a value associated with item, usually +; max is max number to save)
_recseen {
  var %hash = $+(pnp.recseen.,$cid,.,$2)
  if ($hget(%hash)) {
    var %old = $hget(%hash,*)
    ; If exists, just rearrange order
    if ($istok(%old,$3,32)) {
      hadd %hash * $3 $remtok(%old,$3,1,32)
    }
    ; If not exists, remove last item in order also if at max
    else {
      if ($gettok(%old,$1,32)) hdel %hash $ifmatch
      hadd %hash * $3 $gettok(%old,1- $+ $calc($1 - 1),32)
    }
  }
  else {
    hmake %hash 10
    hadd %hash * $3
  }
  hadd %hash $3 $4-
}

; $_getrec(type[,curr]) (if curr is in list, returns next [null if last], otherwise returns first [null if none])
_getrec {
  var %hash = $+(pnp.recseen.,$cid,.,$1)
  if (!$hget(%hash)) return
  if ($findtok($hget(%hash,*),$2,1,32)) {
    return $gettok($hget(%hash,*),$calc($ifmatch + 1),32)
  }
  return $gettok($hget(%hash,*),1,32)
}

; $_sufxrec(type,token) Returns suffix for given token
_sufxrec {
  var %hash = $+(pnp.recseen.,$cid,.,$1)
  if (!$hget(%hash)) return
  return $hget(%hash,$2)
}

; $_sufnrec(type,n) Returns suffix for given number
_sufnrec {
  var %hash = $+(pnp.recseen.,$cid,.,$1)
  if (!$hget(%hash)) return
  return $hget(%hash,$gettok($hget(%hash,*),$2,32))
}

; $_grabrec(type,n) Returns by number; 0 returns count
_grabrec {
  var %hash = $+(pnp.recseen.,$cid,.,$1)
  if (!$hget(%hash)) return
  return $gettok($hget(%hash,*),$2,32)
}

; $_poprec(type,n[,x]) Used for popups (x is added to number if present)
_poprec {
  if ($_grabrec($1,$2)) return $calc($2 + $3) $+ . $left($replace($ifmatch,&,&&),40) $+ $iif($len($ifmatch) > 40,...)
  return
}

; _setrec /cmd /alt type [p] (pops up commands in current window from a recseen list; p adds a space to end of cmd)
; if setting is proper, auto-runs command. (if not a [p] command) /alt is used if nick has + suffix
_setrec {
  var %editact = $editbox($active)
  if (($_cfgi(recent.auto)) && ($4 != p)) {
    if ($_getrec($3)) { hadd pnp lastsrec $ifmatch | if ($gettok($_sufxrec($3,$hget(pnp,lastsrec)),1,32) == +) $2 $hget(pnp,lastsrec) | else $1 $hget(pnp,lastsrec) }
  }
  elseif (($gettok(%editact,1,32) == $1) || ($gettok(%editact,1,32) == $2)) {
    if ($_getrec($3,$gettok(%editact,2,32))) {
      hadd pnp lastsrec $ifmatch
      editbox -a $+ $4 $iif($gettok($_sufxrec($3,$gettok($hget(pnp,lastsrec),1,44)),1,32) == +,$2,$1) $hget(pnp,lastsrec)
    }
    else { editbox -a | hdel pnp lastsrec }
  }
  elseif ($_getrec($3)) { hadd pnp lastsrec $ifmatch | editbox -a $+ $4 $iif($gettok($_sufxrec($3,$hget(pnp,lastsrec)),1,32) == +,$2,$1) $hget(pnp,lastsrec) }
}

; popup special
; Returns - if first popup to call it this time around
_popssep var %old = %.psep | set -u1 %.psep 1 | return $iif(%old,$null,-)

;
; Scheme data
;

; Plays a sound scheme file (tries each one in turn until one found)
; _ssplay code [code2 etc] [1-to-play-even-if-away]
_ssplay {
  if (($inwave == $false) && ($inmidi == $false) && ($insong == $false) && (($hget(pnp. $+ $cid,away) == $null) || ($gettok($1-,-1,32) == 1))) {
    while (($1 != $null) && ($1 != 1)) {
      var %snd = $hget(pnp.theme,Snd $+ $1)
      if (%snd) {
        %snd = $theme.ff($hget(pnp.theme,filename),%snd)
        if ($isfile(%snd)) {
          _blackbox .splay " $+ %snd $+ "
          return
        }
      }
      tokenize 32 $2-
    }
  }
}

;
; Basic commands
;

j join $1-
join {
  if ($1 == 0) .raw join 0
  elseif (!$1) _qhelp /join
  else {
    var %chan = $1,%keys = $2-
    if (-* iswm $1) { %chan = $2 | %keys = $3- }
    if (%chan) {
      %chan = $_patch(%chan)
      ; lookup keys
      if (%keys == $null) {
        var %pos = 1
        while (%pos <= $numtok(%chan,44)) {
          %keys = %keys $+ , $+ $gettok($_cfgx(key,$gettok(%chan,%pos,44)),1,32)
          inc %pos
        }
        if ($remove(%keys,$chr(44)) == $null) %keys =
        else %keys = $right(%keys,-1)
      }
      ; Record keys
      else {
        var %pos = 1
        ; (padding so that we can grab empty tokens)
        var %scankeys =  $+ $replace(%keys,$chr(44), $+ $chr(44) $+ ) $+ 
        while (%pos <= $numtok(%chan,44)) {
          var %key = $mid($gettok(%scankeys,%pos,44),2,-1)
          if ((%key != $null) && (!$istok($_cfgx(key,$gettok(%chan,%pos,44)),%key,32))) {
            ; Record key
            _cfgxw key $gettok(%chan,%pos,44) %key $gettok($_cfgx(key,$gettok(%chan,%pos,44)),1-6,32)
          }
          inc %pos
        }
      }
    }
    ; Check against repjoins
    var %pos = 1,%found
    while (%pos <= $numtok(%chan,44)) {
      if ($istok($hget(pnp. $+ $cid,-repjoin),$gettok(%chan,%pos,44),44)) {
        %found = $addtok(%found,$:s($gettok(%chan,%pos,44)),44)
      }
      inc %pos
    }
    if (%found) {
      dispa You are currently attempting to rejoin: $:l(%found)
      dispa Use /repjoin -c to clear all rejoins
    }
    if (-* iswm $1) join $1 %chan %keys
    else .raw join %chan %keys
  }
}

pj jp $1-
jp if ($1) { join $_patch($1) $2- | ping $_patch($1) } | else _qhelp /jp

p part $1-
leave part $1-
part {
  if (($_ischan($1)) || ($gettok($_patch($1),1,44) ischan)) .raw part $_patch($1) : $+ $msg.compile($_msg(part,$2-),&chan&,$_patch($1))
  elseif (#) .raw part # : $+ $msg.compile($_msg(part,$1-),&chan&,$_patch($1))
  else _error You must use /part in a channel $+ $chr(40) $+ or specify a target channel $+ $chr(41)
}

rejoin cycle $1-
cycle {
  if ($1 !ischan) {
    if ($active ischan) tokenize 32 $active
    else _error You must use /cycle in a channel $+ $chr(40) $+ or specify a target channel $+ $chr(41)
  }
  hop -c $1 rejoining
}

hop {
  if (-* iswm $1) {
    if (($2 == $null) && ($active !ischan)) _error You must use /hop in a channel $+ $chr(40) $+ or specify a target channel $+ $chr(41)
    hop $1 $iif($2 != $null,$_patch($2)) $3-
  }
  else {
    if (($1 == $null) && ($active !ischan)) _error You must use /hop in a channel $+ $chr(40) $+ or specify a target channel $+ $chr(41)
    hop $iif($1 != $null,$_patch($1)) $2-
  }
}

nick {
  if ($1 == $null) _qhelp /nick
  nick $1-
  if ($2 != $null) _recent nick 9 0 $2
  _recent nick 9 0 $1
}

q query $1-
query {
  var %switch,%who,%num = 1
  if ($1 == -n) { %switch = -n | tokenize 32 $2- }
  if ($1 == $null) _qhelp /query
  var %whom = $_ncs(44,$1)
  :loop
  %who = $gettok(%whom,%num,44)
  query %switch %who
  if ($2 == /me) describe %who $3-
  elseif ($2 != $null) msg %who $2-
  if (%num < $numtok($1,44)) { inc %num | goto loop }
}

w whois $1-
whois {
  if ($1) {
    if ($1 == $2) {
      var %who = $_nc($1)
      .raw whois %who %who
    }
    else {
      var %who = $_ncs(44,$_s2c($1-))
      .raw whois %who
    }
    _whois.src %who
  }
  elseif ($_targ(=?)) {
    .raw whois $ifmatch
    hadd pnp.qwhois $cid $+ . $+ $ifmatch $active
  }
  else _qhelp /whois
}

ww whowas $1-
whowas if ($1 == $null) _qhelp /whowas | .raw whowas $1- | _whois.src $1-

ew {
  if ($1) {
    var %who = $_ncs(44,$_s2c($1-))
    :loop
    if ($gettok(%who,1,44)) {
      .raw whois $ifmatch $ifmatch
      _whois.src $ifmatch
      %who = $deltok(%who,1,44)
      goto loop
    }
  }
  elseif ($_targ(=?)) {
    .raw whois $ifmatch $ifmatch
    hadd pnp.qwhois $cid $+ . $+ $ifmatch $active
  }
  else _qhelp /ew
}

tome {
  if ($window(@Whois) == $null) {
    _window 1 -eniz + @Whois -1 -1 -1 -1 /whois @Whois
    if ($_cfgi(whois.retain)) {
      if ($exists($_temp(who))) loadbuf -c [ $+ [ $color(whois) ] ] @Whois $_temp(who)
    }
  }
  window -a @Whois
}

_whois.src {
  if ($chan) var %src = $chan
  elseif ($active == Status Window) var %src = -si2
  elseif (($chr(32) isin $active) || (@* iswm $active)) var %src = -ai2
  else var %src = $active
  var %num = 1 | :loop | if ($gettok($1,%num,44)) { hadd pnp.qwhois $cid $+ . $+ $ifmatch %src | inc %num | goto loop }
}
server {
  var %flags,%connectflags
  if ($1 == -m) {
    %flags = -m
    tokenize 32 $2-
  }
  elseif ((-* iswm $1) && (-m != $1)) {
    server $1-
    if ($1 == -n) _update.new.connects
    return
  }
  var %server = $1-
  ; Find -i or other later flags
  if ($wildtok($1-,-*,1,32)) {
    var %tok = $findtok($1-,$ifmatch,1,32)
    %connectflags = $gettok($1-,%tok $+ -,32)
    if (%tok > 1) %server = $gettok($1-,1- $+ $calc(%tok - 1),32)
    else %server = $null
  }
  if (%server == $null) {
    %server = $_entry(0,$_s2p($_cfgi(lastserv)),Enter server to connect to- $+ $chr(40) $+ you may also specify a port $+ $chr(41),$iif(%flags,1,0),New server window)
    %flags = $iif(%.entry.checkbox,-m)
  }
  elseif ($gettok(%server,2,32) == ?) {
    if ($server($gettok(%server,1,32)).port) %server = $gettok(%server,1,32) $+  $+ $gettok($ifmatch,$_pprand($numtok($ifmatch,44)),44)
    else %server = $gettok(%server,1,32)
    %server = $_entry(0,%server,Enter server and port to connect to-,$iif(%flags,1,0),New server window)
    %flags = $iif(%.entry.checkbox,-m)
  }
  ; Just gave a port?
  if ((%server isnum) && ($len(%server) >= 4)) {
    if ($server == $null) %server = $gettok($_cfgi(lastserv),1,32) %server
    else %server = $server %server
  }
  ; In favs?
  if ($_favfind($gettok(%server,1,32))) {
    var %favdata = $ifmatch
    var %favflags
    if ($findtok(%favdata,-i,1,32)) {
      %favflags = $gettok(%favdata,$ifmatch $+ -,32)
      %favdata = $gettok(%favdata,1- $+ $calc($ifmatch - 1),32)
      ; Override with awaynick?
      if ((!%flags) && (n isin $gettok($hget(pnp. $+ $cid,away),3,32))) %favflags = $puttok(%favflags,$me,2,32)
    }
    ; Grab server, port, pw, and/or flags as needed
    %server = $gettok(%favdata,1,32) $gettok(%server,2-,32)
    if ($gettok(%server,2,32) == $null) %server = %server $gettok(%favdata,2,32)
    if ($gettok(%server,3,32) == $null) %server = %server $gettok(%favdata,3-,32)
    if (!$istok(%connectflags,-i,32)) %connectflags = %favflags %connectflags
  }
  ; no.. but that network in favs? (only for grabbing -i flags)
  else {
    var %net = $server($gettok(%server,1,32)).group
    if (%net isnum) %net = $gettok($server($gettok(%server,1,32)).desc,3,32)
    if ($_favfind(%net)) {
      var %favdata = $ifmatch
      var %favflags
      if ($findtok(%favdata,-i,1,32)) {
        %favflags = $gettok(%favdata,$ifmatch $+ -,32)
        ; Override with awaynick?
        if ((!%flags) && (n isin $gettok($hget(pnp. $+ $cid,away),3,32))) %favflags = $puttok(%favflags,$me,2,32)
      }
      ; Only grab flags
      if (!$istok(%connectflags,-i,32)) %connectflags = %favflags %connectflags
    }
  }
  if (($server) && (!%flags)) quit server hop
  server %flags %server %connectflags
  if (%flags) _update.new.connects
}
quit {
  _notconnected /quit
  var %quitmsg = $msg.compile($_msg(quit,$1-),&online&,$_dur($online))
  if (%quitmsg == $null) {
    .raw quit :
    %quitmsg = (none)
    if ($hget(pnp. $+ $cid,quithalt) == $null) {
      disps Quit message- %quitmsg
      hadd pnp. $+ $cid quithalt %quitmsg
    }
  }
  else {
    quit %quitmsg
    if ($hget(pnp. $+ $cid,quithalt) == $null) {
      disps Quit message- %quitmsg
      hadd pnp. $+ $cid quithalt %quitmsg
    }
    _recent2 quit 9 %quitmsg
  }
  return %quitmsg
}
names {
  if ($1 == $null) {
    if ($active ischan) .raw names $active
    else _error You must use /names in a channel $+ $chr(40) $+ or specify a target channel $+ $chr(41)
  }
  elseif (* isin $1-) .raw names $1-
  else .raw names $_patch($1-)
}

dns {
  if ($1 == $null) { dns | return }
  elseif ($1 == -c) { dns -c | return }
  var %dns,%type
  if (-* iswm $1) { %dns = $2 | %type = $1 }
  elseif ((. isin $1) || (: isin $1)) { if (@ isin $1) %dns = $gettok($1,2,64) | else %dns = $1 | %type = -h }
  else { %dns = $_nc($1) | %type = -n }
  if ($show) {
    _Q.dns _dnsshow _dnsfail %type %dns

    if (%type == -n) set -u %::nick %dns
    else set -u %::address %dns
    set -u %:echo echo $color(other) -t $+ $_cfgi(eroute)
    theme.text DNS
  }
  else _Q.dns halt halt %type %dns
}
; _Q.dns command errorcmd -h/-n nick/addr1 nick/addr2 ...
; command is _s2p, run for each resolved ($nick/$raddress/$iaddress/$naddress set)
; errorcmd is _s2p, run if resolve fails (etc. set) halt is ok etc.
; -h for hosts, -n for nicks
_Q.dns {
  if ($3 == -n) _notconnected
  :loop
  var %whom = $cid $+ . $+ $iif($3 == -n,:) $+ $iif(@ isin $4,$gettok($4,2-,64),$4)
  hadd pnp.qdns %whom $hget(pnp.qdns,%whom) $1-2
  .!dns $iif(-* iswm $3,$3) $4
  if ($5) {
    tokenize 32 $1-3 $5-
    goto loop
  }
}

;
; Titlebar junk
;
_title.win {
  var %away = $hget(pnp. $+ $cid,away)
  if (%away) return [[ $+ $gettok(%away,4-,32) $+ ]] for [[ $+ $_dur($calc($ctime - $gettok(%away,2,32))) $+ ]]
  elseif ($active ischan) return [[ $+ $nick($active,0) $iif($nick($active,0,o),@ $+ $ifmatch) $iif($nick($active,0,h,o),% $+ $ifmatch) $iif($nick($active,0,v,ho),+ $+ $ifmatch) ø $+ $nick($active,0,r) $+ ]] on [[ $+ $active $+ ]] $hget(pnp. $+ $cid,-titleavg. $+ $active)
  elseif ($_targ(=?)) return [[ $+ $ifmatch $+ ]] on [[ $+ $_title.win²($ifmatch) $+ ]]
  elseif ($server) return [[ $+ $usermode $+ ]] on [[ $+ $server $port $+ ]]
  else return $chr(91) $+ offline $+ $chr(93)
}
_title.win² {
  var %num = $comchan($1,0),%ret
  :loop
  if (%num) {
    %ret = %ret $_stch($1,$comchan($1,%num))
    dec %num | goto loop
  }
  if (%ret) return %ret
  return ??
}
_upd.title {
  if ($hget(pnp,in.flash)) return
  if ($hget(pnp.config,title.bar)) {
    scid $activecid
    var %title = $hget(pnp. $+ $cid,title),%bar = $iif($mid(%title,1,1),$hget(pnp. $+ $cid,net)) $iif($mid(%title,1,2) == 11,:) $iif($mid(%title,2,1),$me) $iif(($hget(pnp. $+ $cid,-self.lag)) && ($mid(%title,3,1)),$+([,$hget(pnp. $+ $cid,-self.lag),]))
    if (%bar) %bar = - %bar
    if ($mid(%title,4,1)) %bar = %bar - $iif($hget(pnp,locked.title),$hget(pnp,locked.title),$_title.win)
    if (($hget(pnp. $+ $cid,away)) && ($mid(%title,5,1))) %bar = %bar - Log $+ $chr(91) $+ $iif($hget(pnp,logging),$hget(pnp,awaylog.^),off) $+ $chr(93)
    if ($mid(%title,6,1)) { if ($hget(pnp,pager)) %bar = %bar - Pager[ $+ $hget(pnp,newpages) $+ / $+ $hget(pnp,totalpages) $+ ]] | else %bar = %bar - Pager $+ $chr(91) $+ off $+ $chr(93) }
    if ($mid(%title,7,1)) %bar = %bar - $_time
    if ($mid(%title,8,1)) if ($idle > 90) %bar = %bar - Idle $_dur($idle)
    if ($hget(pnp,title.note)) %bar = - $hget(pnp,title.note) %bar
    titlebar %bar
  }
}
_lock.tb scid $activecid | hadd pnp locked.title $_title.win
_unlock.tb hdel pnp locked.title
_title.note hadd -u16 pnp title.note $1-
flash {
  if (($1 == $null) || (-* iswm $1)) {
    flash $unsafe($1-)
    return
  }
  if ($_cfgi($iif($hget(pnp. $+ $cid,away),flash.away,flash.here))) {
    var %times = $int($calc($ifmatch / 2 + 0.5))
    flash -r $+ %times $unsafe($1-)
    if (!$appactive) .timer.unflash -oi 1 $calc(%times * 2 - 1) hdel pnp in.flash $chr(124) _upd.title
  }
  else flash $unsafe($1-)
  if (!$appactive) {
    titlebar $($1-,1)
    hadd pnp in.flash 1
  }
}

; $_stch(nick,#chan)
; Returns #chan, @#chan, or +#chan for on, opped, or voiced on given channel
_stch return $_stsym($1,$2) $+ $2
; $_stsym(nick,#chan)
; Returns nothing, @, or + for on, opped, or voiced on given channel
_stsym if ($1 isop $2) return @ | if ($1 ishop $2) return % | if ($1 isvoice $2) return + | return

; **********************
; Function keys
; **********************

f1 _setrec /notice /onotice notice p
sf1 if ($mouse.key & 2) _setrec /chat /whowas user | else _setrec /query /whowas user px
cf1 _setrec /whois /whowas user
f2 if ($_targ(=?#)) ping $active | else _error You must use F2 in a channel $+ $chr(44) query $+ $chr(44) or chat. $+ $chr(40) $+ F2 pings the current window $+ $chr(41)
cf2 if ($active ischan) avglag $active | elseif (@Ping* iswm $active) { _dowclose $active | window -c $active } | else _error You must use CtrlF2 in a channel. $+ $chr(40) $+ CtrlF2 views the latest average ping $+ $chr(41)
sf2 if ($mouse.key & 2) sp | elseif (@Ping* iswm $active) window -n $active | elseif ($active ischan) pwin $active | else _error You must use ShiftF2 in a channel. $+ $chr(40) $+ ShiftF2 views stored pings $+ $chr(41)
f4 {
  if ($active ischan) {
    if ($gettok($editbox($active),1,32) == /onotice) editbox -ap /ovnotice
    else editbox -ap /onotice
  }
  elseif (@Events* iswm $active) {
    if ($gettok($editbox($active),1,32) == /onotice) editbox -ap /ovnotice $mid($active,$calc($pos($active,-,1) + 1))
    else editbox -ap /onotice $mid($active,$calc($pos($active,-,1) + 1))
  }
}
sf8 _setrec /ping /ping clones
cf9 {
  if ($hget(pnp. $+ $cid,-nickrc)) {
    disptn -a $hget(pnp. $+ $cid,-nickrc) Nick retake cancelled
    .timer.nickretake. $+ $cid off
    hdel pnp. $+ $cid -nickrc
  }
  elseif ($hget(pnp. $+ $cid,-nickretake)) {
    disptn -a $hget(pnp. $+ $cid,-nickretake) You will take this nick as soon as it is available; Press $:s(CtrlF9) again to cancel
    hadd pnp. $+ $cid -nickrc $hget(pnp. $+ $cid,-nickretake)
    _retakecheck
  }
}
f11 if ($server) fav j | else fav c
sf11 {
  if ($mouse.key & 2) _setrec /ign /ign user px
  else {
    if ($gettok($editbox($active),1,32) == /join) var %last = $_getrec(chan,$gettok($editbox($active),2,32))
    else var %last = $_getrec(chan)
    :loop
    if ($me ison %last) {
      %last = $_getrec(chan,%last)
      goto loop
    }
    if (%last) {
      if ($_cfgi(recent.auto)) join %last
      else editbox -ap /join %last
    }
    else editbox -a
  }
}
cf11 _setrec /server /server serv px
f12 if ($hget(pnp. $+ $cid,away)) { if (+q isin $gettok($ifmatch,3,32)) qb | else back } | else away
sf12 {
  if ($mouse.key & 2) {
    if ($hget(pnp. $+ $cid,away)) { if (+q isin $gettok($ifmatch,3,32)) qb | else back }
    awaylog
  }
  else pager v
}
cf12 if (@AwayLog* iswm $active) { _dowclose $active | window -c $active } | else awaylog

;
; "Color/talker" identifiers
;
_pat.rand {
  var %num = $numtok($1,46),%pos = $len($2-),%text = $replace($2-,$chr(32),),%tok,%ret
  :loop | %tok = $gettok($1,$_pprand(%num),46) | if (%tok == $) var %tok | %ret = %tok $+ $mid(%text,%pos,1) $+ %ret | if (%pos > 1) { dec %pos | goto loop }
  return $replace(%ret,,$chr(32))
}
colori return $_pat.rand(02.03.04.05.06.07.09.10.12.13,$1-)
color2i return $_pat.rand(01.02.03.04.05.06.07.09.10.12.13.14.15,$1-)
funkyi return $_pat.rand(02.03.04.05.06.07.09.10.12.13.02.03.04.05.06.07.09.10.12.13.02.03.04.05.06.07.09.10.12.13,$1-)
ulinei _pat.rand .$ $1- | if (2 // $count($result,)) return $result | return $result $+ 
boldi _pat.rand .$ $1- | if (2 // $count($result,)) return $result | return $result $+ 
codei _pat.rand ...$ $1- | var %cdi | if (2 \\ $count($result,)) %cdi = %cdi $+  | if (2 \\ $count($result,)) %cdi = %cdi $+  | return $result $+ %cdi
uvoweli return $replace($lower($1-),a,A,e,E,i,I,o,O,u,U,y,Y)
lvoweli return $replace($upper($1-),A,a,E,e,I,i,O,o,U,u,Y,y)

_cfade {
  var %ret,%tok = 1,%len = $len($2-),%str = $replace($2-,$chr(32),),%sect = $int($calc(%len / $numtok($1,46))) + 1,%extra = $calc(%len % $numtok($1,46)) + 1
  :loop
  dec %extra | if (%extra == 0) dec %sect
  %ret = %ret $+  $+ $gettok($1,%tok,46) $+ $left(%str,%sect)
  %str = $right(%str,$calc(- %sect))
  if (%tok < $numtok($1,46)) { inc %tok | goto loop }
  return $replace(%ret,,$chr(32))
}

_u return  $+ $1- $+ 
_b return  $+ $1- $+ 
_r return  $+ $1- $+ 
_k return  $+ $1- $+ 
f7 halt
sf7 halt
cf7 halt
f10 halt
sf10 halt
cf10 halt
