; #= P&P -rs -2
; @======================================:
; |  Peace and Protection                |
; |  Raw and Whois display               |
; `======================================'

;
; Whois
;

; Checks to see if the current event is part of the whois queue
alias -l whois.isqueue {
  var %queue = $hget(pnp.qwhois,$cid $+ . $+ $1)
  if (%queue) {
    hdel pnp.qwhois $cid $+ . $+ $1
    hadd pnp.twhois. $+ $cid queue %queue
  }
}

; Clean queue on disconnect
on *:DISCONNECT:{ hdel -w pnp.qwhois $cid $+ .* | if ($hget(pnp.twhois. $+ $cid)) hfree pnp.twhois. $+ $cid }

; /_whois.queue nick/etc displaytarget command
; Queues a whois; displaytarget 0/null to not display; * for default window
; Make sure you are queing a single nick (no commas, no wildcards)
alias _whois.queue {
  hadd pnp.qwhois $cid $+ . $+ $1 $2-
  .raw whois $1
}

; /whois.theme event [linesep1] [linesep2]
; Sets all vars in whois hash and runs an event
; Handles :echo :linesep ::fromserver, ::text/::isoper/::isregd for whois/whoas
; Linesep1 shows before; Linesep2 shows after; Only if LineSepWhois enabled and not an error 'whois' event
; If 'queue' in hash is set, hides all non-error events and runs queue on 'whois'
; If 'error' in hash is set, this overrides the specified event and is called with :comments containing a special value for 401
; Won't call raw.other for missing events
; Skips displays if $halted is true
; Returns 1 if no event was actually run (halted, queue, missing event, default skipped)
alias -l whois.theme {
  var %targ
  if ($gettok($hget(pnp.twhois. $+ $cid,queue),2-,32)) {
    if ($1 == whois) $gettok($hget(pnp.twhois. $+ $cid,queue),2-,32)
    if ($gettok($hget(pnp.twhois. $+ $cid,queue),1,32)) %targ = $ifmatch
    else return 1
  }

  if (($halted) || ($hget(pnp.events,$1) == $null)) return 1

  ; Window to show to? (we verify that it exists)
  ; Preselected from queue?
  if ((%targ != $null) && (%targ != *)) { }
  ; @Whois if open
  elseif ($window(@Whois)) %targ = @Whois
  ; Query or chat if open and "to query" is on (or no source is known and "source" is normal destination)
  elseif (($_cfgi(whois.q)) || (($hget(pnp.twhois. $+ $cid,queue) == $null) && ($hget(pnp.config,whois.win) == *))) {
    if ($query($hget(pnp.twhois. $+ $cid,nick))) %targ = $hget(pnp.twhois. $+ $cid,nick)
    elseif ($chat($hget(pnp.twhois. $+ $cid,nick)).status == active) %targ = = $+ $hget(pnp.twhois. $+ $cid,nick)
  }
  ; If no target found and "source" is destination, use source
  if ((%targ == $null) && ($hget(pnp.config,whois.win) == *)) %targ = $hget(pnp.twhois. $+ $cid,queue)
  ; If no valid target yet, use setting; * becomes active
  if (!$_isopen(%targ)) {
    %targ = $hget(pnp.config,whois.win)
    if (%targ == *) %targ = -ai2
  }

  ; Logfile? (no logging if @Whois is being used- mirc handles it; skip logging if logdir incorrect)
  var %log = $readini($mircini,n,logging,@Whois)
  if ((%targ == @Whois) || (%log == off)) var %log
  if ((%log) && ($isdir($nofile(%log)))) set -u %.whoislog " $+ $nofile(%log) $+ $mklogfn($nopath(%log)) $+ "

  ; Retain?
  if ($_cfgi(whois.retain)) set -u %.whoisretain $_temp(who)

  ; Open/focus @Whois if needed
  var %tofront
  if (%targ == @Whois) {
    if ($window(@Whois) == $null) {
      _window 1 -eniz + @Whois -1 -1 -1 -1 /whois @Whois
      ;!! Change retain method?
      if (%.whoisretain) {
        if ($exists($_temp(who))) loadbuf -c $+ $color(whois) @Whois $_temp(who)
      }
      if ($_cfgi(whois.focus) != min) %tofront = 1
    }
    elseif ($_cfgi(whois.focus) == front) %tofront = 1
  }

  ; Setup variables
  set -u %:echo _whois.echo %targ
  set -u %:linesep _whois.linesep %targ
  set -u %::fromserver $nick
  var %num = $hget(pnp.twhois. $+ $cid,0).item
  while (%num) {
    var %item = $hget(pnp.twhois. $+ $cid,%num).item
    if (%item != text) set -u %:: $+ %item $hget(pnp.twhois. $+ $cid,%item)
    dec %num
  }

  ; Call event; lineseps for non-error events
  if ($hget(pnp.twhois. $+ $cid,error)) {
    if ($ifmatch == 401) set -u %:comments ( $+ $:s(WHOIS) $+ )
    set -u %::text $hget(pnp.twhois. $+ $cid,text)
    theme.text $hget(pnp.twhois. $+ $cid,error)
  }
  else {
    ; (1 to skip logging this particular separator)
    if (($hget(pnp.theme,LineSepWhois)) && ($2)) %:linesep 1
    if (($1 == whois) || ($1 == whowas)) {
      if (!%::isoper) set -u %::isoper is not
      if (!%::isregd) set -u %::isregd is not
      set -u %::text $hget(pnp.twhois. $+ $cid,text)

      ; Log recents
      _recseen 3 whois %::nick $gettok(%::address,1,64) $gettok(%::address,2-,64) $iif(%::wserver,%::wserver,??) %::nick $+ ! $+ %::address $iif(%::chan,- %::chan) * %::realname
      if (%::wserver) _recseen 10 serv %::wserver
      var %num = 1
      while (%num <= $numtok(%::chanbare,32)) {
        var %chan = $gettok(%::chanbare,%num,32)
        _recseen 10 chan %chan
        _recseen 10 wch %chan
        inc %num
      }
    }
    theme.text $1
    if (($hget(pnp.theme,LineSepWhois)) && ($3)) %:linesep
  }

  ; Focus @Whois?
  if (%tofront) window -a @Whois

  return
}

; Display a whois line- a normal dispr but with retain+log+networkid
alias _whois.echo {
  if (-* iswm $1) echo $color(whois) $1 $+ mt $iif((a isin $1) && ($activecid != $cid),$:anp) $2-
  else echo $color(whois) -mti2 $1 $iif((@* iswm $1) && ($scon(0) > 1),$:anp) $2-
  if (%.whoislog) write $ifmatch $strip($timestamp $2-)
  if (%.whoisretain) write $ifmatch $timestamp $2-
}
; Whois divider
alias _whois.linesep {
  ; Make sure linesep exists
  var %linesep = $:::
  if (%linesep != $null) {
    ; See if already shown
    var %win = $1
    if (-*a* iswm $1) %win = $active
    elseif (-*s* iswm $1) %win = Status Window
    if ( !isin $line(%win,$line(%win,0))) {
      ; Echo to proper window
      if (-* iswm $1) echo $color(whois) $1 $+ t $:* %linesep $+ 
      else echo $color(whois) -ti2 $1 $:* %linesep $+ 
      ; Log and retain
      if (!$2) {
        if (%.whoislog) write $ifmatch $strip($timestamp $:* %linesep)
        if (%.whoisretain) write $ifmatch $timestamp $:* %linesep $+ 
      }
    }
  }
}

; Start of WHOIS
raw 311:*:{
  ; (if already in a whois, call the WHOIS event)
  if ($hget(pnp.twhois. $+ $cid,nick)) whois.theme whois 1 1

  ; Store whois data in a hash, show opening event
  if ($hget(pnp.twhois. $+ $cid)) hdel -w pnp.twhois. $+ $cid *
  else hmake pnp.twhois. $+ $cid 20

  ; Whois queue?
  if ($nick == $server) whois.isqueue $2
  hadd pnp.twhois. $+ $cid nick $2
  hadd pnp.twhois. $+ $cid address $3 $+ @ $+ $4
  hadd pnp.twhois. $+ $cid realname $6-
  whois.theme RAW.311 1 0
  halt
}

; Start of WHOWAS
raw 314:*:{
  ; (if already in a whowas, call the WHOWAS event)
  if ($hget(pnp.twhois. $+ $cid,nick)) { if ($halted == $false) whois.theme whowas 1 1 }

  ; Store whowas data in a hash, show opening event
  if ($hget(pnp.twhois. $+ $cid)) hdel -w pnp.twhois. $+ $cid *
  else hmake pnp.twhois. $+ $cid 20

  hadd pnp.twhois. $+ $cid nick $2
  hadd pnp.twhois. $+ $cid address $3 $+ @ $+ $4
  hadd pnp.twhois. $+ $cid realname $6-
  whois.theme RAW.314 1 0
  halt
}

; WHOIS server/info
raw 312:*:{
  ; If in form of [*.1.2.3] address then handle that
  if ((* isin $3) && (. isin $4) && ($longip($remove($4,$chr(91),$chr(93))) == $null)) {
    hadd pnp.twhois. $+ $cid wserver $remove($4,$chr(91),$chr(93))
    hadd pnp.twhois. $+ $cid serverinfo $5-
  }
  else {
    hadd pnp.twhois. $+ $cid wserver $3
    hadd pnp.twhois. $+ $cid serverinfo $4-
  }
  whois.theme RAW.312
  halt
}

; "is an ircop" or a similar line
raw 313:*:{
  hadd pnp.twhois. $+ $cid isoper is
  hadd pnp.twhois. $+ $cid operline $3-
  whois.theme RAW.313
  halt
}

;Idle/signon time
raw 317:*:{
  if ($4 isnum) hadd pnp.twhois. $+ $cid signontime $4
  hadd pnp.twhois. $+ $cid idletime $3
  whois.theme RAW.317
  halt
}

; End-of-whois
raw 318:*:{
  if ($hget(pnp.twhois. $+ $cid)) {
    ; In case of error, we want this cleared- it's important
    .timer.clear.whois. $+ $cid -m 1 0 hfree pnp.twhois. $+ $cid
    hadd pnp.twhois. $+ $cid target $2
    whois.theme whois 1 1
    ; Only call end-of-whois raw if we whoised a wildcard OR if 'whois' event wasn't there
    if (($result) || (* isin $2) || (. isin $2) || (? isin $2)) {
      var %wresult = $result
      hadd pnp.twhois. $+ $cid nick $2
      ; (clear any error setting)
      hadd pnp.twhois. $+ $cid error
      ; Show closing linesep if 'whois' event wasn't there
      whois.theme RAW.318 $iif(%wresult,0 1)
    }
    hfree pnp.twhois. $+ $cid
    .timer.clear.whois. $+ $cid off
    ; queue includes wildcards (so no-such-user works properly on efnet) so delete any such now
    hdel pnp.qwhois $cid $+ . $+ $2
  }
  halt
}

; End-of-whowas
raw 369:*:{
  if ($hget(pnp.twhois. $+ $cid)) {
    ; In case of error, we want this cleared- it's important
    .timer.clear.whois. $+ $cid -m 1 0 hfree pnp.twhois. $+ $cid
    hadd pnp.twhois. $+ $cid target $2
    whois.theme whowas 1 1
    hadd pnp.twhois. $+ $cid nick $2
    ; (clear any error setting)
    hadd pnp.twhois. $+ $cid error
    ; Show closing linesep if 'whowas' event wasn't there
    whois.theme RAW.368 $iif($result,0 1)
    hfree pnp.twhois. $+ $cid
    .timer.clear.whois. $+ $cid off
  }
  halt
}

; Whois channels
raw 319:*:{
  var %old = $hget(pnp.twhois. $+ $cid,chan)
  hadd pnp.twhois. $+ $cid chan $3-
  ; Bare channels- no -+%@.
  var %bare,%num = 1
  while (%num <= $numtok($3-,32)) {
    var %chan = $gettok($3-,%num,32)
    ; Deaf is the -
    while (($left(%chan,1) isin - $+ $prefix) && ($mid(%chan,2,1) isin $prefix $+ $chantypes)) {
      %chan = $right(%chan,-1)
    }
    %bare = %bare %chan
    inc %num
  }
  hadd pnp.twhois. $+ $cid chanbare %bare
  whois.theme RAW.319
  ; add channels only if 800 or less total chars
  if ($calc($len(%old) + $len($3-)) < 800) hadd pnp.twhois. $+ $cid chan %old $3-
  halt
}

; (no-such-user 401 is later in file)
; (away 301 is later in file)
; (reg nick 307 later in file)
; (catch-all is at end of file)

; No-such-whowas
raw 406:*:{
  ; In case of error, we want this cleared- it's important
  .timer.clear.whois. $+ $cid -m 1 0 hfree pnp.twhois. $+ $cid

  ; (if already in a whowas, call the WHOWAS event)
  if ($hget(pnp.twhois. $+ $cid,nick)) whois.theme whowas 1 1

  ; Store whowas data in a hash, show no event (406 will be called when whois.theme whowas is called)
  if ($hget(pnp.twhois. $+ $cid)) hdel -w pnp.twhois. $+ $cid *
  else hmake pnp.twhois. $+ $cid 20

  ; Error event, cleanup, end of whowas
  hadd pnp.twhois. $+ $cid nick $2
  hadd pnp.twhois. $+ $cid text $3-
  hadd pnp.twhois. $+ $cid error RAW.406
  whois.theme RAW.406
  .timer.clear.whois. $+ $cid off
  hfree pnp.twhois. $+ $cid
  halt
}

; Catches all unrecognized whois lines (called from end of file)
; Also called from addons like extras (country codes)
alias whois.misc {
  if ($hget(pnp.twhois. $+ $cid,text)) hadd pnp.twhois. $+ $cid text $ifmatch $+ ; $1-
  else hadd pnp.twhois. $+ $cid text $1-
}

; Theme aliases
; /_pnptheme.whois [was]
; /_pnptheme.endofwhois
; 'was' states this is really a whowas
alias _pnptheme.whois {
  var %sinfo = %::serverinfo
  var %signoff
  if ($1) {
    %sinfo =
    %signoff = %::serverinfo
  }

  %:echo %::pre $:t(%::nick) $iif($1,was,is) $:s($gettok(%::address,1,64)) $+ @ $+ $:s($gettok(%::address,2-,64))

  ; Hide or blank for later nicknames?
  var %echo = %:echo %::pre $iif($hget(pnp.config,whois.nick) == on,$:t(%::nick),$iif($hget(pnp.config,whois.nick) == hide,$:b($:mc(back,%::nick)),   ))

  %echo $iif($1,was,is) « $+ $:h(%::realname) $+ »
  if (%::wserver) %echo $iif($1,was on $:s(%::wserver),on $:s(%::wserver)) $iif(($_cfgi(whois.serv)) && (%sinfo),« $+ $:h(%sinfo) $+ »)
  if (%::operline) %echo %::operline
  if (%::isregd == is) %echo $iif($1,was using a registered nickname,is using a registered nickname)
  if (%::text) %echo %::text
  if (%:comments) %echo %:comments
  if (%::chan) {
    ; Bolds shared channels
    ; Colors op status
    ; Turns - into (deaf) at start
    ; Skips if would overflow variable
    var %chon,%deaf,%num = 1
    if ($calc($len(%::chan) + $count(%::chan,$chr(32)) * 7) < 900) {
      while (%num <= $numtok(%::chan,32)) {
        var %chan = $gettok(%::chan,%num,32)
        ; Deaf?
        if ((-* iswm %chan) || (D* iswm %chan)) {
          %chan = $right(%chan,-1)
          %deaf = 1
        }
        ; Add to existing if any
        if (%chon) %chon = %chon $+ ,
        ; Op status? (verifies second character appears to be a valid channel or another prefix)
        ; Loop to allow multiple statuses
        var %status
        while (($left(%chan,1) isin ~^* $+ $prefix) && ($mid(%chan,2,1) isin $prefix $+ $chantypes)) {
          %status = %status $+ $left(%chan,1)
          %chan = $right(%chan,-1)
        }
        ; Bold?
        if (($me ison %chan) && ($hget(pnp.config,whois.shared))) %status = %status $+ 
        ; Build it together
        %chon = %chon %status $+ $:s(%chan)
        inc %num
      }
    }
    else %chon = %::chan
    %echo $iif($1,was on %chon,on %chon) $iif(%deaf,(deaf))
    var %num = 1
    while (%num < $numtok(%::chanbare,32)) {
      var %chan = $gettok(%::chanbare,%num,32)
      if ($chr(160) isin %chan) %echo on channel " $+ $:s(%chan $+ ) $+ " containing fake spaces
      elseif ($strip(%chan) != %chan) %echo on channel " $+ $:s(%chan $+ ) $+ " containing format codes
      inc %num
    }
  }
  if (%::away) %echo $iif($1,was away « $+ $:h(%::away) $+ »,away « $+ $:h(%::away) $+ »)
  if (%signoff) %echo signed off $:h(%signoff)
  if (%::signontime) %echo idle $:h($_dur(%::idletime)) $+ $chr(44) signed on « $+ $:h($_datetime(%::signontime)) $+ »
  elseif (%::idletime) %echo idle $:h($_dur(%::idletime))
}
alias _pnptheme.endofwhois {
  %:echo %::pre End of $:s(WHOIS) matching $:t(%::nick) $iif(@ isin %:echo,(right-click for options),(see pnp menu for whois options))
}

;
; Who info (also handles IAL update and channel scanning via who queue)
;

; /_who.queue channel command/hide
; Queues a 'who'; Make sure you are queing a single channel (no nicks, no wildcards, etc)
alias _who.queue {
  hadd -m pnp.qwho $cid $+ . $+ $1 $2-
  .raw who $1
}

; 315- end of who
raw 315:*:{
  var %queue = $hget(pnp.qwho,$cid $+ . $+ $2)
  ; Queue? Hide or call alias
  if (%queue) {
    hdel pnp.qwho $cid $+ . $+ $2
    if (%queue == hide) halt
    if (($hget(pnp. $+ $cid,-dwho.num) < 1) || ($hget(pnp. $+ $cid,-dwho.num) == $null)) {
      hadd pnp. $+ $cid -dwho.num 0
      hadd pnp. $+ $cid -dwho.hops 0
    } 
    if (($hget(pnp. $+ $cid,-dwho.gone) < 1) || ($hget(pnp. $+ $cid,-dwho.gone) == $null)) hadd pnp. $+ $cid -dwho.gone 0
    var %num = 1
    while (%num <= $len($prefix)) {
      if (($hget(pnp. $+ $cid,-dwho. $+ $mid($prefix,%num,1)) < 1) || ($hget(pnp. $+ $cid,-dwho. $+ $mid($prefix,%num,1)) == $null)) hadd pnp. $+ $cid -dwho. $+ $mid($prefix,%num,1) 0
      inc %num
    }
    %queue $2
    hdel -w pnp. $+ $cid -dwho.*
    halt
  }
  if ($halted) return

  ; Prepare for theme
  set -u %::fromserver $nick
  set -u %::value $2
  set -u %::text $2-
  set -u %::count $iif($hget(pnp. $+ $cid,-dwho.num),$ifmatch,0)
  set -u %::numeric 315
  who.show RAW.315 $iif($hget(pnp.config,whois.win) == *,-ai2,$hget(pnp.config,whois.win))
  hdel -w pnp. $+ $cid -dwho.*
  halt
}

; 352- who data
raw 352:*:{
  var %queue = $hget(pnp.qwho,$cid $+ . $+ $2)
  if (%queue == hide) halt

  ; Determine channel status
  var %status = $remove($7,G,H,*,d,r)

  ; Queue alias? Count, etc.
  if (%queue) {
    ; (skip services nicks)
    if ($istok($hget(pnp. $+ $cid,-servnick),$6,32)) halt

    ; Count gone, record away, ircops, count op, voice, total hops, total users
    if (G isin $7) { hinc pnp. $+ $cid -dwho.gone | who.series -dwho.away $6 }
    if (* isin $7) who.series -dwho.ircop $6
    if (%status) hinc pnp. $+ $cid -dwho. $+ %status
    hinc pnp. $+ $cid -dwho.hops $8
    hinc pnp. $+ $cid -dwho.num

    ; Record hops as first token of a list of users on a server; record server names
    if ($hget(pnp. $+ $cid,-dwho. $+ $5) == $null) {
      hadd pnp. $+ $cid -dwho. $+ $5 $8 $6
      who.series -dwho.serv $5
    }
    ; (this server series exists- just add new nickname)
    else who.series -dwho. $+ $5 $6
    halt
  }
  if ($halted) return

  ; Prepare for theme
  set -u %::away $iif(G isin $7,G,H)
  set -u %::nick $6
  set -u %::address $3 $+ @ $+ $4
  set -u %::chan $iif($2 != *,$2)
  set -u %::cmode %status
  set -u %::realname $9-
  set -u %::isoper $iif(* isin $7,is,is not)
  set -u %::wserver $5
  set -u %::value $8
  set -u %::fromserver $nick
  set -u %::text $2-
  set -u %::numeric 352
  who.show RAW.352 $iif($hget(pnp.config,whois.win) == *,-ai2,$hget(pnp.config,whois.win))
  halt
}

; 354- undernet special who reply
raw &354:*:{
  set -u %::fromserver $nick
  set -u %::text $2-
  set -u %::numeric 354
  who.show RAW.354 $iif($hget(pnp.config,whois.win) == *,-ai2,$hget(pnp.config,whois.win))
  halt
}

; who.series variable token
; can track any number of tokens- first set stored in %variable, next set in %variable1, %variable2, etc.
; %variable0 contains the number of the last set, or is null if only one set in %variable
alias -l who.series {
  :loop
  var %where = $1 $+ $hget(pnp. $+ $cid,$1 $+ 0)
  if ($calc($len($hget(pnp. $+ $cid,%where)) + $len($2)) < 700) {
    hadd pnp. $+ $cid %where $hget(pnp. $+ $cid,%where) $2
  }
  else {
    hinc pnp. $+ $cid $1 $+ 0
    goto loop
  }
}

; $_who.countseries(variable) counts total tokens from a series generated by who.series
alias _who.countseries {
  var %where,%total = 0
  while ($numtok($hget(pnp. $+ $cid,$1 $+ %where),32)) {
    inc %total $ifmatch
    inc %where
  }
  return %total
}

; /who.show event window
; Displays a who event (set all vars except echo/linesep before calling this)
alias -l who.show {
  if (-* iswm $2) set -u %:echo echo $:c1 $2 $+ t $iif((a isin $2) && ($activecid != $cid),$:anp)
  else set -u %:echo echo $:c1 -ti2 $2
  set -u %:linesep dispr-div $2
  if ($2 == @Whois) {
    if ($window(@Whois) == $null) {
      _window 1 -eniz + @Whois -1 -1 -1 -1 /whois @Whois
      ;!! Change retain method?
      if ($_cfgi(whois.retain)) {
        if ($exists($_temp(who))) loadbuf -c $+ $color(whois) @Whois $_temp(who)
      }
    }
  }
  if (($hget(pnp. $+ $cid,-dwho.num) < 1) || ($hget(pnp. $+ $cid,-dwho.num) == $null)) {
    dispr-div $2
    if ($2 == @Whois) window -n @Whois
  }
  hinc pnp. $+ $cid -dwho.num
  theme.text $1
  if ($1 == RAW.315) {
    dispr-div $2
    if ($2 == @Whois) window -a @Whois
  }
}

; Default display for 352, 315
alias _pnptheme.who352 {
  var %away = $iif(%::away == G,away,here)
  if (%::isoper == is) %away = %away $+ ; IRCop
  if (d isincs $gettok(%::text,6,32)) %away = %away $+ ; deaf
  if (r isincs $gettok(%::text,6,32)) %away = %away $+ ; registered
  if ((%::chan == *) || (%::chan == $null)) %:echo %::pre $:t(%::nick) is $:s($gettok(%::address,1,64)) $+ @ $+ $:s($gettok(%::address,2-,64)) $+  $chr(40) $+ %away $+ $chr(41)
  else %:echo %::pre $:t(%::nick) is $:s($gettok(%::address,1,64)) $+ @ $+ $:s($gettok(%::address,2-,64)) $+  $+ $chr(44) on %::cmode $+ $:s(%::chan) $+  $chr(40) $+ %away $+ $chr(41)
  %:echo %::pre $iif($hget(pnp.config,whois.nick) == on,$:t(%::nick),$iif($hget(pnp.config,whois.nick) == hide,$:b($:mc(back,%::nick)),   )) is « $+ $:h(%::realname) $+ » on $:s(%::wserver) $chr(40) $+ %::value hops $+ $chr(41) %:comments
}

alias _pnptheme.who315 {
  %:echo %::pre End of $:s(WHO) matching $:t(%::value) - %::count user $+ $chr(40) $+ s $+ $chr(41) found %:comments
}

;
; MOTD
;

; 372/377/378- MOTD content
raw 372:*:{ motd.process $2- | halt }
raw 377:*:{ motd.process $2- | halt }
raw 378:*:{ motd.process $2- | halt }

; Process a line of MOTD content
alias -l motd.process {
  ; In a whois? (some servers use these raws for whois data)
  _in.whois $1-

  var %win = $_mservwin(@MOTD)
  ; Right after signon? Server didn't send a 375!
  if (($hget(pnp. $+ $cid,-linesep.signon)) && ($nick == $server)) {
    if ($hget(pnp. $+ $cid,-linesep.signon) == 1) disps-div
    hdel pnp. $+ $cid -linesep.signon
    if ($window(%win)) {
      _dowclose %win
      window -c %win
    }
    ; Open @MOTD, remember server it's from
    _window 2.1 -hnlkv +l %win $_winpos(10,10,10,10) @MOTD
    titlebar %win $nick
  }
  ; If no hidden window or server differs, just show to status
  if (($window(%win).state != hidden) || ($nick != $server)) {
    if (!$halted) raw.theme 372 $color(norm) $iif($1- == $null, ,$1-)
    halt
  }
  ; Save line- handle blanks, remove first token if a hyphen, and add indentation
  set -u %:echo aline $color(norm) %win
  set -u %::fromserver $nick
  set -u %::numeric 372
  if ((($1 == -) && ($2 == $null)) || ($1 == $null)) set -u %::text  
  elseif ($1 == -) set -u %::text     $2-
  else set -u %::text     $1-
  theme.text RAW.372
  ; Calculate checksum- don't count first line if it contains a date
  if ((!$gettok($window(%win).title,2,32)) && (*/*/* iswm $2-)) return
  titlebar %win $gettok($window(%win).title,1,32) $calc($gettok($window(%win).title,2,32) + $hash($1-,16))
}

; 375- Start of MOTD
raw 375:*:{
  ; If server differs, just show to status
  if ($nick != $server) {
    if (!$halted) {
      set -u %::value $3
      raw.theme 375 $color(norm) $2-
    }
    halt
  }
  if ($hget(pnp. $+ $cid,-linesep.signon)) {
    if ($hget(pnp. $+ $cid,-linesep.signon) == 1) disps-div
    hdel pnp. $+ $cid -linesep.signon
  }
  disps (retrieving Message of the Day...)
  ; If viewing MOTD, close existing window
  var %win = $_mservwin(@MOTD)
  if ($window(%win)) {
    _dowclose %win
    window -c %win
  }
  ; Open @MOTD, remember server it's from
  _window 2.1 -hnlkv +l %win $_winpos(10,10,10,10) @MOTD
  titlebar %win $3
  halt
}

; 376- End of MOTD
raw 376:*:{
  var %win = $_mservwin(@MOTD)
  ; If halted, close any window we have
  if ($halted) {
    if ($window(%win).state == hidden) {
      _dowcleanup %win
      window -c %win
    }
    halt
  }
  ; If no hidden window or server differs, just show to status
  if (($window(%win).state != hidden) || ($nick != $server)) {
    raw.theme 376 $color(norm) $2-
    halt
  }
  ; Server and checksum
  var %motdserver = $gettok($window(%win).title,1,32)
  var %newcheck = $gettok($window(%win).title,2,32)
  ; Determine why motd is being shown, or even if we wish to hide it
  var %why
  ; Requested
  if ($hget(pnp. $+ $cid,-motd.req)) {
    hdel pnp. $+ $cid -motd.req
    %why = MOTD requested
  }
  ; Skip MOTD
  elseif ($_cfgi(motd.disp) == off) {
    disps (Message of the Day skipped)
    _dowcleanup %win
    window -c %win
    halt
  }
  ; Check if changed
  elseif ($_cfgi(motd.disp) == changes) {
    ; Get old checksum and compare
    var %old = $readini($_cfg(motd.ini),n,motd,%motdserver)
    if (%old == $null) %why = MOTD has never been viewed for this server
    elseif (%old != %newcheck) %why = MOTD has changed since last viewing!
    else {
      disps (Message of the Day has not changed- skipped)
      _dowcleanup %win
      window -c %win
      halt
    }
  }
  ; Where to show? Existing @MOTD?
  if ($_cfgi(motd.win) == @MOTD) {
    ; Top line
    set -u %:echo iline $color(norm) %win 1
    set -u %::value %motdserver
    set -u %::fromserver %motdserver
    set -u %::numeric 375
    set -u %::text - %motdserver Message of the Day -
    theme.text RAW.375
    ; 'Why' line
    if (%why) iline $color(norm) %win 1 %why
    titlebar %win - %motdserver
    ; End line
    set -u %:echo aline $color(norm) %win
    set -u %::numeric 376
    set -u %::text End of /MOTD command.
    theme.text RAW.376
    window -aw %win
  }
  else {
    ; 'Why' line
    if (%why) disps %why
    disps-div
    ; Top line
    set -u %:echo echo $color(norm) -sti2
    set -u %::value %motdserver
    set -u %::fromserver %motdserver
    set -u %::numeric 375
    set -u %::text - %motdserver Message of the Day -
    theme.text RAW.37                                
    ; Text
    var %num = 1
    while (%num <= $line(%win,0)) {
      echo $color(norm) -sti2 $line(%win,%num)
      inc %num
    }
    ; End line
    set -u %::numeric 376
    set -u %::text End of /MOTD command.
    theme.text RAW.376
    disps-div
    _dowcleanup %win
    window -c %win
  }
  ; Save new checksum
  if (%newcheck) writeini $_cfg(motd.ini) motd %motdserver %newcheck
  halt
}

; MOTD error
raw *:422:{
  if ($hget(pnp. $+ $cid,-linesep.signon)) {
    if ($hget(pnp. $+ $cid,-linesep.signon) == 1) disps-div
    hdel pnp. $+ $cid -linesep.signon
  }
  if (!$halted) raw.theme 422 $:c1 $2-
  halt
}


;
; Channel info
;

; Returned on join- Topic, Names, Mode (then Who)
; /chaninfo- Mode, Topic, Names
; Not all servers return topic set by (topic part 2) and/or channel formed (mode part 2)
; Some servers add a channel URL reply also
; We hide mode on join, and hide names themselves or show in requested locale

; Dividers shown- (if not already shown as part of events)
; Pre-names if not part of a (shown-to-channel) join or chaninfo- This is start of manual /names
; End of names- This is end of join, end of chaninfo, and end of manual /names
; Pre-mode if part of chaninfo- This is start of chaninfo
; On join- This is start of join (not shown if joinself is scripted)

; On join, clear key attempts, and remember that we're joining
on me:*:JOIN:#:{
  hdel pnp. $+ $cid -keyattempt. $+ $chan
  hinc pnp. $+ $cid -joining. $+ $chan 1
}

; Hide MODE request that mIRC sends if you become opped and key or mode is unknown, by marking it again as 'being joined'
on *:OP:#:{
  if ($opnick == $me) {
    if ((($chan($chan).mode == $null) && ($hget(pnp. $+ $cid,-joining. $+ $chan))) || ((k isincs $gettok($chan($chan).mode,1,32)) && ($chan($chan).key == $null))) {
      hinc pnp. $+ $cid -joining. $+ $chan
    }
  }
}

; 353- Names
alias _pnptheme.names353 {
  if (%::first) %:linesep
  ; Highlight op/voc/etc
  var %num = 1,%text = %::text
  while (%num <= $len($prefix)) {
    %text = $replace(%text,$mid($prefix,%num,1), $+ $mid($prefix,%num,1) $+ $left($:s,3))
    inc %num
  }
  $iif($gettok(%:echo,3,32) == -sti2,disptc -s %::chan,disprc %::chan) names- $:s(%text) %:comments
}
raw 353:*:{
  ; Blank reply- all users on channel invisible
  if ($4 == $null) {
    hadd pnp. $+ $cid -namec.ppl 0.0
    halt
  }
  ; First reply?
  if (($hget(pnp. $+ $cid,-namec.ppl) < 1) || ($hget(pnp. $+ $cid,-namec.ppl) == $null)) {
    ; show divider if a requested or channel /names (not chaninfo)
    if (!$istok($hget(pnp. $+ $cid,-chaninfo),$3,32)) set -u %::first 1
  }
  ; Counts of op/voc/etc
  var %num = 1
  while (%num <= $len($prefix)) {
    hinc pnp. $+ $cid -namec. $+ $mid($prefix,%num,1) $count($4-,$mid($prefix,%num,1))
    inc %num
  }
  ; Count all ppl, count all regulars (no prefix at all)
  hinc pnp. $+ $cid -namec.ppl $numtok($4-,32)
  hinc pnp. $+ $cid -namec.reg $regex(@ $4-,/ [^ $+ $prefix ]+/g)
  ; Halt?
  if ($halted) return
  ; Joining- Display?
  var %show = 1
  if ($hget(pnp. $+ $cid,-joining. $+ $3)) {
    ; 0 = hide, 1 = chan, 2 = status
    var %show = $_cfgi(show.names)
    if (!%show) halt
  }
  if ((%show == 2) || ($3 !ischan)) {
    set -u %:echo echo $:c1 -sti2
    set -u %:linesep disps-div
  }
  else {
    set -u %:echo echo $:c1 -ti2 $3
    set -u %:linesep dispr-div $3
    ; If joining, showing to channel, don't show divider
    if ($hget(pnp. $+ $cid,-joining. $+ $3)) unset %::first
  }
  set -u %::chan $3
  set -u %::fromserver $nick
  set -u %::text $4-
  set -u %::numeric 353
  ; Show divider if not scripted and first reply of a requested /names (as above)
  if ((%::first) && ($hget(pnp.events,Raw353LineSep))) %:linesep
  theme.text RAW.353
  halt
}

; 366- End of names
; Shows 366 (end of names), then 366uc (usercounts)
alias _pnptheme.names366uc {
  if (. isin %::count) {
    disprc %::chan All users on channel are invisible %:comments
  }
  elseif (%::count > 0) {
    disprc %::chan users- $:t(%::count) total user $+ $chr(40) $+ s $+ $chr(41) %:comments
    if (%::count != %::countreg) {
      var %users,%num = 1
      while (%num <= $len($prefix)) {
        var %name = $mid($prefix,%num,1)
        var %count = %::count [ $+ [ %name ] ]
        if (%count) {
          if (%name == @) %name = op $+ $chr(40) $+ s $+ $chr(41)
          elseif (%name == %) %name = halfop $+ $chr(40) $+ s $+ $chr(41)
          elseif (%name == +) %name = voice $+ $chr(40) $+ s $+ $chr(41)
          elseif (%name == .) %name = owner $+ $chr(40) $+ s $+ $chr(41)
          else %name = mode $+ %name
          %users = %users - $:t(%count) %name $:s($_p(%count,%::count))
        }
        inc %num
      }
      if (%::countreg) %users = %users - $:t(%::countreg) other $+ $chr(40) $+ s $+ $chr(41) $:s($_p(%::countreg,%::count))
      disprc %::chan users $+ %users
    }
  }
  else {
    disprc %::chan No users on channel $+ $chr(44) or channel is secret/private %:comments
  }
}
raw 366:*:{
  ; Recolor nicklist at end of names, unless we're joining and ial is on (IE, waiting for /who reply)
  if ((!$hget(pnp. $+ $cid,-joining. $+ $2)) || ($ial == $false)) _nickcol.updatechan $2 1
  ; Joining and modeless- don't wait for a MODE reply (since one won't be coming)
  if ((+* iswm $2) && ($hget(pnp. $+ $cid,-joining. $+ $2))) {
    ; Remove from joining list
    if ($ifmatch > 1) hdec pnp. $+ $cid -joining. $+ $2
    else hdel pnp. $+ $cid -joining. $+ $2
  }
  ; If part of chaninfo, remove token from list
  if ($istok($hget(pnp. $+ $cid,-chaninfo),$2,32)) hadd pnp. $+ $cid -chaninfo $remtok($hget(pnp. $+ $cid,-chaninfo),$2,1,32)
  ; If halted, unset and done
  if ($halted) {
    hdel -w pnp. $+ $cid -namec.*
    return
  }

  ; Requested /names or /chaninfo- show 366, then 366uc, then divider (if needed) to chan
  ; Join- show 366 to none/channel/status, then 366uc to channel, then divider (if needed) to channel or both
  set -u %::chan $2
  set -u %::fromserver $nick
  set -u %::text $3-
  set -u %::numeric 366
  set -u %:echo echo $:c1 $iif($2 ischan,-ti2 $2,-sti2)
  set -u %:linesep dispr-div $2
  ; (move -namec vars to :: vars)
  set -u %::count $hget(pnp. $+ $cid,-namec.ppl)
  set -u %::countreg $hget(pnp. $+ $cid,-namec.reg)
  var %num = 1
  while (%num <= $len($prefix)) {
    set -u %::count $+ $mid($prefix,%num,1) $hget(pnp. $+ $cid,-namec. $+ $mid($prefix,%num,1))
    inc %num
  }
  hdel -w pnp. $+ $cid -namec.*

  ; 366- if joining, show to location where 353s were shown; also show divider if in status
  if ($hget(pnp. $+ $cid,-joining. $+ $2)) {
    var %show = $_cfgi(show.names)
    if (%show == 1) {
      theme.text RAW.366
    }
    elseif (%show == 2) {
      set -u %:echo echo $:c1 -sti2
      set -u %:linesep disps-div
      theme.text RAW.366
      ; Divider to status (if 366 doesn't contain one)
      if ($hget(pnp.events,Raw366LineSep)) %:linesep
      ; Set echo/linesep to channel display (for 366uc/linesep later)
      if ($2 ischan) set -u %:echo echo $:c1 -ti2 $2
      else set -u %:echo echo $:c1 -sti2
      set -u %:linesep dispr-div $2
    }
  }
  ; 366- if not joining, show to channel
  else {
    theme.text RAW.366
  }

  ; 366uc - To channel
  theme.text RAW.366uc

  ; Divider to channel (if 366 doesn't contain one)
  if ($hget(pnp.events,Raw366LineSep)) %:linesep
  halt
}

; 324- Mode
; Record key if any, hide if joining, show divider if /chaninfo
raw 324:*:{
  ; Record any key
  if ((k isin $3) && ($chan($2).key) && ($chan($chan).key != *)) {
    var %key = $_cfgx(key,$2)
    _cfgxw key $2 $chan($2).key $gettok($remtok(%key,$chan($2).key,32),1-6,32)
  }
  ; Joining?
  if ($hget(pnp. $+ $cid,-joining. $+ $2)) {
    ; Remove from joining list
    if ($ifmatch > 1) hdec pnp. $+ $cid -joining. $+ $2
    else hdel pnp. $+ $cid -joining. $+ $2
    ; Add to secondary join list (separate list as occasional servers do not show raw 329)
    hinc pnp. $+ $cid -joining2. $+ $2
    halt
  }
  if ($halted) return
  ; Show divider if part of a /chaninfo
  if ($istok($hget(pnp. $+ $cid,-chaninfo),$2,32)) dispr-div $2
  ; Show theme line
  set -u %::chan $2
  set -u %::modes $3-
  raw.tochan 324 $2 $3-
  halt
}

; 328- URL
raw &328:*:{
  set -u %::chan $2
  raw.tochan 328 $2 $3-
  halt
}

; 329- Channel timestamp
raw 329:*:{
  ; If part of 'secondary' join list, hide
  if ($hget(pnp. $+ $cid,-joining2. $+ $2)) {
    if ($ifmatch > 1) hdec pnp. $+ $cid -joining2. $+ $2
    else hdel pnp. $+ $cid -joining2. $+ $2
    halt
  }
  if ($halted) return
  set -u %::chan $2
  set -u %::value $3
  raw.tochan 329 $2 $3-
  halt
}

; 331/332/333- No topic, Topic, Topic set by
raw &331:*:{
  ; Clear names counts just in case
  hdel -w pnp. $+ $cid -namec.*
  set -u %::chan $2
  raw.tochan 331 $2 $3-
  halt
}
raw &332:*:{
  ; Clear names counts just in case
  hdel -w pnp. $+ $cid -namec.*
  set -u %::chan $2
  raw.tochan 332 $2 $3- $+ 
  halt
}
raw &333:*:{
  set -u %::chan $2
  set -u %::nick $3
  set -u %::value $4
  raw.tochan 333 $2 $4-
  halt
}

;
; Basic raw display aliases
;

; /raw.theme event color text
; /raw.themew event color text
; /raw.themea event color text
; Sets all vars and runs a raw event that displays status, routed, or active
; Handles :echo :linesep ::fromserver ::text ::numeric
; Echos for missing events
alias -l raw.theme {
  set -u %:echo echo $2 -sti2
  set -u %:linesep disps-div
  set -u %::fromserver $nick
  set -u %::text $3-
  set -u %::numeric $left($1,3)
  if ($hget(pnp.events,RAW. $+ $1)) theme.text RAW. $+ $1
  else theme.text RAW.Other
}
alias -l raw.themew {
  set -u %:echo echo $2 $hget(pnp.config,rawroute) $+ t
  set -u %:linesep $iif($hget(pnp.config,rawroute) == -si2,disps-div,dispa-div)
  set -u %::fromserver $nick
  set -u %::text $3-
  set -u %::numeric $left($1,3)
  if ($hget(pnp.events,RAW. $+ $1)) theme.text RAW. $+ $1
  else theme.text RAW.Other
}
alias -l raw.themea {
  set -u %:echo echo $2 -ati2 $iif($activecid != $cid,$:anp)
  set -u %:linesep dispa-div
  set -u %::fromserver $nick
  set -u %::text $3-
  set -u %::numeric $left($1,3)
  if ($hget(pnp.events,RAW. $+ $1)) theme.text RAW. $+ $1
  else theme.text RAW.Other
}

; /raw.tonick event target text
; /raw.tochan event target text
; Sets all vars and runs a raw event that displays to a query/channel
; Handles :echo :linesep ::fromserver ::text ::numeric
; Disprn/Disprc for missing events; assumes color base 1
alias -l raw.tonick {
  if ($hget(pnp.events,RAW. $+ $1)) {
    if ($query($2)) {
      set -u %:echo echo $:c1 -ti2 $2
      set -u %:linesep dispr-div $2
    }
    else {
      set -u %:echo echo $:c1 -ati2 $iif($activecid != $cid,$:anp)
      set -u %:linesep dispa-div
    }
    set -u %::fromserver $nick
    set -u %::text $3-
    set -u %::numeric $left($1,3)
    theme.text RAW. $+ $1
  }
  else disprn $2 $3- %:comments
}
alias -l raw.tochan {
  if ($hget(pnp.events,RAW. $+ $1)) {
    if ($2 ischan) {
      set -u %:echo echo $:c1 -ti2 $2
      set -u %:linesep dispr-div $2
    }
    else {
      set -u %:echo echo $:c1 $hget(pnp.config,rawroute) $+ t
      set -u %:linesep $iif($hget(pnp.config,rawroute) == -si2,disps-div,dispa-div)
    }
    set -u %::fromserver $nick
    set -u %::text $3-
    set -u %::numeric $left($1,3)
    theme.text RAW. $+ $1
  }
  else disprc $2 $3- %:comments
}

; $raw.throttle(id[,time])
; returns 1 to throttle (throttles for 15/time secs)
alias -l raw.throttle {
  var %prev = $hget(pnp. $+ $cid,-rawthrottle. $+ $1)
  hadd -u $+ $iif($2,$2,15) pnp. $+ $cid -rawthrottle. $+ $1 1
  return %prev
}

; /chan.desynch chan
; Displays error if possible channel desynch (you should check op/ison status as needed before calling this)
alias -l chan.desynch {
  if (($nick != $server) && ($me ison $2)) {
    disprc $2 $:w(Probable channel desynch detected)
  }
}

; $chan.cantjoin(chan)
; Halts if channel is already being retried
; Otherwise plays cant-join sound and returns fkey to use to retry that channel
alias -l chan.cantjoin {
  if ($istok($hget(pnp. $+ $cid,-repjoin),$1,44)) halt
  _Q.fkey 1 $calc($ctime + 200) _cidexists $cid $chr(124) scid $cid $chr(124) repjoin $1
  _ssplay NoJoin
  return $result
}

;
; Raws requiring special processing
;

; 002/003- server/version, date
raw &2:*:{ set -u %::value $8 | raw.theme 002 $color(norm) $2- | halt }
raw &3:*:{ set -u %::value $6- | raw.theme 003 $color(norm) $2- | halt }
raw &102:*:{ set -u %::value $8 | raw.theme 102 $color(norm) $2- | halt }
raw &103:*:{ set -u %::value $6- | raw.theme 103 $color(norm) $2- | halt }

; 005- features, "use server x", or map
raw &5:* this server:{ raw.theme 005 $color(norm) $2- | halt }
raw &5:Use server *:{ raw.theme 005 $color(norm) $2- | halt }
raw 5:*:{ return }
raw &105:* this server:{ raw.theme 105 $color(norm) $2- | halt }
raw &105:Use server *:{ raw.theme 105 $color(norm) $2- | halt }
raw 105:*:{ return }

; 008/221- server notice mask, usermode
raw &8:*Server notice mask (*):{ set -u %::nick $1 | set -u %::value $mid($gettok($1-,-1,32),2,-1) | raw.themea 008 $:c1 $2- | halt }
raw &108:*Server notice mask (*):{ set -u %::nick $1 | set -u %::value $mid($gettok($1-,-1,32),2,-1) | raw.themea 108 $:c1 $2- | halt }
raw &8:*:{ set -u %::nick $1 | set -u %::value $2 | raw.themea 008 $:c1 $2- | halt }
raw &108:*:{ set -u %::nick $1 | set -u %::value $2 | raw.themea 108 $:c1 $2- | halt }
raw &221:*:{ set -u %::nick $1 | set -u %::modes $2- | raw.themea 221 $:c1 $2- | halt }

; 250/251/255/265/266- connections, users/invisible/servers, local clients, local users, global users
raw &250:*:{ set -u %::value $5 | raw.theme 250 $color(norm) $2- | halt }
raw &251:*:{
  set -u %::fulltext $2-
  set -u %::users $4 | set -u %::value $10 | raw.theme 251 $color(norm) $7
  ; First servernotice or motd raw after this will have a linesep first
  hadd pnp. $+ $cid -linesep.signon 1
  halt
}
raw &255:*:{ set -u %::users $4 | set -u %::value $7 | raw.theme 255 $color(norm) $2- | disps-div | halt }
raw &265:*:{ set -u %::users $remove($gettok($1-,-3,32),$chr(44)) | set -u %::value $gettok($1-,-1,32) | raw.theme 265 $color(norm) $2- | halt }
raw &266:*:{ set -u %::users $remove($gettok($1-,-3,32),$chr(44)) | set -u %::value $gettok($1-,-1,32) | raw.theme 266 $color(norm) $2- | halt }

; 271/272- silence list, end of list
alias _pnptheme.silence271 {
  if (%::first) disptn -s %::nick Silence list
  disptn -s %::nick     %::text %:comments
}

raw &271:*:{
  if (!$hget(pnp. $+ $cid,-listsilence)) {
    hadd pnp. $+ $cid -listsilence 1
    $iif($hget(pnp.config,rawroute) == -si2,disps-div,dispa-div)
  }
  set -u %::nick $2
  raw.themew 271 $:c1 $3-
  halt
}
raw 272:*:{
  if ($halted) { hdel pnp. $+ $cid -listsilence | return }
  set -u %::nick $1
  if ($hget(pnp. $+ $cid,-listsilence)) {
    hdel pnp. $+ $cid -listsilence
    raw.themew 272 $:c1 $2-
    $iif($hget(pnp.config,rawroute) == -si2,disps-div,dispa-div)
  }
  else {
    set -u %::empty 1
    raw.themew 272 $:c1 $2-
  }
  halt
}

; 301- away
raw 301:*:{
  ; Whois away
  if ($hget(pnp.twhois. $+ $cid,nick)) {
    hadd pnp.twhois. $+ $cid away $3-
    ; (don't call this unless we have a 319-channels event also)
    if ($hget(pnp.events,319)) {
      ; (in case wrong syntax used in theme)
      set -u %::text $3-
      whois.theme RAW.301
    }
    halt
  }

  if ($halted) return

  if (($2 == $me) || ($raw.throttle(301 $+ $2,60))) halt
  set -u %::nick $2
  set -u %::away $3-
  raw.tonick 301 $2 $3-
  halt
}

; 341- invite user (usually nick / channel)
raw &341:*:{
  if ($_ischan($3)) { set -u %::chan $3 | set -u %::nick $2 }
  else { set -u %::chan $2 | set -u %::nick $3 }
  raw.tochan 341 %::chan $4-
  halt
}

; 371/374- info, end of info
alias _pnptheme.info371 {
  if (%::first) %:echo %::pre  $+ Info for $chr(91) $+ %::fromserver $+ $chr(93)
  %:echo %::pre     %::text %:comments
}
raw &371:*:{
  if (!$hget(pnp. $+ $cid,-servinfo)) {
    hadd pnp. $+ $cid -servinfo 1
    disps-div
    set -u %::first 1
  }
  raw.theme 371 $color(norm) $2-
  halt
}
raw 374:*:{
  if ($halted == $false) {
    raw.theme 374 $color(norm) $2-
    disps-div
  }
  hdel pnp. $+ $cid -servinfo
  halt
}

; 391- server time
; Also handles server ping results
raw 391:*:{
  ; Determine server ping status, incluing what we ctually pinged
  var %sping = $hget(pnp. $+ $cid,-servping. $+ $2),%pinged = $2
  hdel pnp. $+ $cid -servping. $+ $2
  if (%sping == $null) {
    ; Search all pinged to see if a possible wildcard has been matched
    if ($_searchtok($hget(pnp. $+ $cid,-servmask),$2,32)) {
      %pinged = $gettok($hget(pnp. $+ $cid,-servmask),$ifmatch,32)
      hadd pnp. $+ $cid -servmask $deltok($hget(pnp. $+ $cid,-servmask),$ifmatch,32)
      %sping = $hget(pnp. $+ $cid,-servping. $+ %pinged)
      hdel pnp. $+ $cid -servping. $+ %pinged
    }
  }
  ; What to do with server ping? @ServerDetails window?
  if ($gettok(%sping,2,32) == @ServerDetails) {
    ; replace line if present; halt in all cases (even if window or line not found)
    if ($fline(@ServerDetails,%pinged $+ 	*,1,0)) {
      ; Fill in ping and actual server name
      rline @ServerDetails $ifmatch $puttok($puttok($line(@ServerDetails,$ifmatch),$round($calc(($ticks - $gettok(%sping,1,32)) / 1000),1),3,9),$2,1,9)
    }
    halt
  }
  ; Normal server ping?
  elseif (%sping) {
    $_show.reply.ping($iif($gettok(%sping,2,32),$ifmatch,$2),$null,Server,$null,$_dur($calc(($ticks - $gettok(%sping,1,32)) / 1000)),$null,-si2)
    _recseen 10 serv $2
    halt
  }
  ; Display as raw?
  if ($halted == $false) {
    set -u %::value $2
    raw.themew 391 $:c1 $2-
    halt
  }
}

; 401- failed to deliver
alias _pnptheme.failed401 {
  if ($mid($gettok(%::text,8,32),2,1) == $chr(1)) %:echo Someone left before they could receive the CTCP $:s($remove($gettok(%::text,8,32),$chr(1),$chr(91),$chr(93))) you sent them %:comments
  else %:echo The person you sent this message to has left- $:q($left($right($gettok(%::text,8-,32),-1),-1)) %:comments
}  
raw &401:*failed to deliver*:{ raw.themew 401fd $color(norm) $2- | halt }

; 401/402/403- no such user, server, channel
raw 401:*:{
  ; (if in a whois, call the WHOIS event)
  if ($hget(pnp.twhois. $+ $cid,nick)) {
    ; In case of error, we want this cleared- it's important
    .timer.clear.whois. $+ $cid -m 1 0 hfree pnp.twhois. $+ $cid
    whois.theme whois 1 1
  }

  ; no-such-user during a /whois- if this was queued (and we're not halted)
  ; Don't show other stuff if another script hid this event
  if (($hget(pnp.qwhois,$cid $+ . $+ $2)) && ($halted == $false) && ($nick == $server)) {
    ; Store whois data in a hash
    if ($hget(pnp.twhois. $+ $cid)) hdel -w pnp.twhois. $+ $cid *
    else hmake pnp.twhois. $+ $cid 20

    ; In case of error, we want this cleared- it's important
    .timer.clear.whois. $+ $cid -m 1 0 hfree pnp.twhois. $+ $cid

    ; Whois queue?
    whois.isqueue $2

    ; Error event, cleanup, end of whois (some servers end error whoises without a 318!)
    hadd pnp.twhois. $+ $cid nick $2
    hadd pnp.twhois. $+ $cid text $3-
    hadd pnp.twhois. $+ $cid error RAW.401
    whois.theme RAW.401
    .timer.clear.whois. $+ $cid off
    hfree pnp.twhois. $+ $cid
    halt
  }
  ; End any current whois
  elseif ($hget(pnp.twhois. $+ $cid)) {
    .timer.clear.whois. $+ $cid off
    hfree pnp.twhois. $+ $cid
  }

  if ($halted) return

  if ($raw.throttle(401 $+ $2)) halt
  set -u %::nick $2
  raw.tonick 401 $2 $3-
  halt
}
raw &402:*:{
  if ($raw.throttle(402 $+ $2)) halt
  set -u %::value $2
  raw.themew 402 $:c1 $2-
  halt
}
raw &403:*:{
  if ($raw.throttle(403 $+ $2)) halt
  set -u %::chan $2
  raw.tochan 403 $2 $3-
  halt
}

; 404- can't send to channel
raw &404:*:{
  if ($raw.throttle(404 $+ $2)) halt
  set -u %::chan $2
  ; Determine likely cause- not on channel, moderation, desync, banned, or unknown
  if (($me !ison $2) || ($chan($2).status == joining) || ($chan($2).status == kicked)) set -u %:comments - $:w(You are not on the channel)
  elseif ((m isin $gettok($chan($2).mode,1,32)) && ($me isreg $2)) set -u %:comments - $:w(Channel is moderated)
  elseif ($address($me,5) isban $2) set -u %:comments - $:w(You are banned)
  elseif ($nick != $server) set -u %:comments - $:w(Probable channel desynch detected)
  else set -u %:comments - $:w(You may be banned or channel may be desynched)
  raw.tochan 404 $2 $3-
  halt
}

; 405- too many channels
raw &405:*:{
  ; Hide if script is repjoining
  if ($istok($hget(pnp. $+ $cid,-repjoin),$2,44)) halt
  set -u %::chan $2
  raw.tochan 405 $2 $3-
  halt
}

; 408- no such service (wildcard for future compatibility)
raw &408:*no such service*:{ set -u %::value $3 | raw.themew 408ns $:c1 $2- | halt }

; 432- Invalid nickname
raw &432:*:{ set -u %::nick $2 | raw.themew 432 $:c1 $3- | halt }

; 433- Nickname in use/nickname registered
; Includes some nick retake functionality
raw 433:*registered to*:{ if ($halted == $false) { set -u %::nick $2 | raw.themew 433nr $:c1 $3- | halt } }
raw 433:*:{
  if ($halted == $false) {
    set -u %::nick $2
    if ($hget(pnp. $+ $cid,-nickrc)) {
      set -u %:comments - $:s(CtrlF1) to whois
      if ($hget(pnp. $+ $cid,net) == Offline) /editbox -sp /nick
    }
    elseif ($hget(pnp. $+ $cid,net) == Offline) {
      ; Auto retake (timer will start on signon)
      set -u %:comments - You will take this nick as soon as it is available; $:s(CtrlF1) to whois; $:s(CtrlF9) to cancel retake
      hadd pnp. $+ $cid -nickrc $2
    }
    else set -u %:comments - $:s(CtrlF1) to whois; $:s(CtrlF9) to automatically take nick when available
    ; (must show to status during connection)
    if ($hget(pnp. $+ $cid,net) == Offline) raw.theme 433 $:c1 $3-
    else raw.themew 433 $:c1 $3-
    _ssplay NickTaken
  }
  ; Prepare for nickname retake
  hadd pnp. $+ $cid -nickretake $2
  _recseen 10 user $2
  halt
}

; 436- Nickname collision
raw 436:*:{
  if ($halted == $false) {
    set -u %::nick $2
    raw.themew 436 $:cerr $3-
  }
  ; Attempt to dodge (doesn't work on most servers)
  if ($2 == $me) .raw nick coll $+ $r(0,9) $+ $r(0,9) $+ $r(0,9) $+ $r(0,9) $+ $r(0,9)
  halt
}

; 437- Can't change nickname while banned/nickname or channel temporarily unavailable
raw &437:*nick*chan*temp*unavail*:{
  if ($_ischan($2)) {
    set -u %::chan $2
    raw.tochan 437tu $2 $3-
  }
  else {
    set -u %::nick $2
    raw.themew 437tu $:c1 $3-
  }
  halt
}
raw &437:*:{ set -u %::chan $2 | raw.tochan 437 $2 $3- | halt }

; 438- Nick change too fast
; Includes code to reattempt change after X seconds
raw &438:*:{
  _Q.fkey 1 $calc($ctime + $9 + 4) _cidexists $cid $chr(124) scid $cid $chr(124) _cancel.toofast $2
  set -u %:comments - Changing in $:w($calc($9 + 3)) seconds $chr(40) $+ $result to cancel $+ $chr(41)
  set -u %::nick $2
  set -u %::value $9
  raw.themew 438 $:c1 $3-
  .timer.nicktoofast. $+ $cid 1 $calc($9 + 3) .raw nick $2
  halt
}
alias _cancel.toofast {
  disptn -a $1 Change to nickname cancelled
  .timer.nicktoofast. $+ $cid off
}

; 439- target change too fast 
raw &439:*:{
  if ($_ischan($2)) {
    set -u %::chan $2
    set -u %::value $9
    raw.tochan 439 $2 $3-
  }
  else {
    set -u %::nick $2
    set -u %::value $9
    raw.tonick 439 $2 $3-
  }
  .timer 1 $9 $iif($_ischan($2),disprc $2,disprn $2) You may now send text to $iif($_ischan($2),$:s($2),$:t($2))
  halt
}

; 441/442- user/you not on channel
raw &441:*:{
  ; Desynch?
  if ($2 ison $3) chan.desynch
  set -u %::nick $2
  set -u %::chan $3
  raw.tochan 441 $3 $4-
  halt
}
raw &442:*:{
  ; Desynch?
  chan.desynch
  set -u %::chan $2
  raw.tochan 442 $2 $3-
  halt
}

; 443- user already on channel
raw &443:*:{
  set -u %::nick $2
  set -u %::chan $3
  raw.tochan 443 $3 $4-
  halt
}

; 467- key already set
raw &467:*:{
  set -u %::chan $2
  raw.tochan 467 $2 $3-
  halt
}

; 468- server-only mode
raw &468:*:{
  set -u %::chan $2
  raw.tochan 467 $2 $3-
  halt
}

; 472- unknown channel mode
raw &472:*:{
  set -u %::value $2
  raw.themew 472 $:c1 $2-
  halt
}

; 471/473/474/477- Can't join channel- +l, +i, +b, +R
; 477 requires wildcard mask, as it's used for other things
raw &471:*:{
  set -u %:comments - Press $:s($chan.cantjoin($2)) to keep trying to join
  set -u %::chan $2
  raw.tochan 471 $2 $3-
  halt
}
raw &473:*:{
  set -u %:comments - Press $:s($chan.cantjoin($2)) to keep trying to join
  set -u %::chan $2
  raw.tochan 473 $2 $3-
  halt
}
raw &474:*:{
  set -u %:comments - Press $:s($chan.cantjoin($2)) to keep trying to join
  set -u %::chan $2
  raw.tochan 474 $2 $3-
  halt
}
raw &477:*reg*nick*join*:{
  set -u %:comments - Press $:s($chan.cantjoin($2)) to keep trying to join
  set -u %::chan $2
  raw.tochan 477 $2 $3-
  halt
}

; 475- can't join without key
; Tries all stored keys in sequence, with different comments show along the way
raw &475:*:{
  ; Halts if channel is being retried
  if ($istok($hget(pnp. $+ $cid,-repjoin),$2,44)) halt
  ; Retrieve keys and last tried key
  var %next,%key = $_cfgx(key,$2),%last = $hget(pnp. $+ $cid,-keyattempt. $+ $2)
  hdel pnp. $+ $cid -keyattempt. $+ $2
  ; If last tried is in list, try next, else try first
  if ($findtok(%key,%last,1,32)) %next = $gettok(%key,$calc($ifmatch + 1),32)
  else %next = $gettok(%key,1,32)
  ; If we have a 'next', attempt a join, and remember that we tried it
  if (%next) {
    _linedance .raw join $2 %next
    hadd pnp. $+ $cid -keyattempt. $+ $2 %next
  }
  ; Display message, possibly with fkey
  if (%next) {
    set -u %:comments - Attempting stored key $+ $chr(40) $+ s $+ $chr(41) $+ ... $chr(40) $+ $:t($findtok(%key,%next,1,32)) of $:t($numtok(%key,32)) $+ $chr(41)
    ; (play sound as we're not calling $chan.cantjoin to do this)
    _ssplay NoJoin
  }
  else set -u %:comments - $iif(%last,Stored keys incorrect;) Press $:s($chan.cantjoin($2)) to keep trying to join
  set -u %::chan $2
  raw.tochan 475 $2 $3-
  halt
}

; (store keys you see set)
on *:MODE:#:{
  if ((k isin $1) && ($chan($chan).key) && ($chan($chan).key != *)) {
    var %key = $_cfgx(key,$chan)
    _cfgxw key $chan $chan($chan).key $gettok($remtok(%key,$chan($chan).key,32),1-6,32)
  }
}

; 478- banlist full
raw &478:*:{
  set -u %::chan $2
  set -u %::value $3
  raw.tochan 478 $2 $3-
  halt
}

; 482- you are not opped
raw &482:*:{
  ; Desynch?
  if (($me isop $2) || ($me ishop $2)) chan.desynch
  set -u %::chan $2
  raw.tochan 482 $2 $3-
  halt
}

; 484- connection restricted or can't kick channel service
raw &484:*connection*restricted*:{ raw.themew 484cr $:c1 $2- | halt }
raw &484:*:{ set -u %::nick $2 | set -u %::chan $3 | raw.themew 484 $:c1 $4- | halt }

; MAP ISON LIST LINKS and WATCH raws- don't touch
raw 006:*:{ return }
raw 015:*:{ return }
raw 106:*:{ return }
raw 115:*:{ return }
raw 303:*:{ return }
raw 321:*:{ return }
raw 322:*:{ return }
raw 323:*:{ return }
raw 364:*:{ return }
raw 365:*:{ return }
raw 600:*:{ return }
raw 601:*:{ return }
raw 602:*:{ return }
raw 603:*:{ return }
raw 604:*:{ return }
raw 605:*:{ return }
raw 606:*:{ return }
raw 607:*:{ return }

;
; Basic raws- < for line sep before, n for normal color, b for base color (1), e for error color, > for line sep after
; s for status, rest go to dispw
; Unrecognized are simply 'b' for now
;

; 1/101- welcome to server, same
; 4/104- server modes and version, same
; 252/253/254- opers, unknown connects, channels
; 256/257/258/259- admin 1, 2, 3, 4
; 263- server load too high
; 351- version reply
; 381- now ircop
; 382- rehash
; 407- multiple recipients
; 409- no origin for ping
; 411- no recipient
; 412- no text
; 413- no toplevel domain
; 414- wildcard toplevel domain
; 416- too many lines in output
; 421- no such command
; 423- admin error
; 424- error at server
; 431- no nickname given
; 440- UNKNOWN
; 445- summon disabled
; 446- users disabled
; 451- haven't registered
; 455- problem with ident
; 461- not enough params
; 462- may not reregister
; 463- host not allowed
; 464- pass incorrect
; 465- you are banned
; 481- must be ircop
; 483- can't kill server
; 491- no oline for host
; 501- unknown user mode
; 502- can't view other user's mode
; 511- silence list full

alias -l _in.whois {
  ; In a whois?
  if ($hget(pnp.twhois. $+ $cid,nick)) {
    ; 307 or other?
    if ($numeric == 307) hadd pnp.twhois. $+ $cid isregd is
    else whois.misc $3-
    whois.theme RAW. $+ $numeric
    halt
  }
}

; Also catches all (incl 307) while in the middle of a whois, unless prev halted
raw *:*:{
  if (($numeric !isnum) || ($numeric == 0)) return
  if ($halted) return

  ; In a whois?
  _in.whois $1-

  var %pos = $findtok( 1   4  101 104 252 253 254 256 257 258 259 263 351 381 382 407 409 411 412 413 414 416 421 423 424 431 440 445 446 451 455 461 462 463 464 465 481 483 491 501 502 511,$numeric,1,32)
  var %raw =  $gettok(<sn sn> <sn sn>  sn  sn  sn <n   n   n   n>  e   b   b   b   b   n   b   b   b   b   e   b   b   b   b   b   b   b   e   e   b   e   e   e   e   b   b   e   b   b   b ,%pos,32)
  if (!%raw) %raw = b
  if (< isin %raw) $iif(($hget(pnp.config,rawroute) == -si2) || (s isin %raw),disps-div,dispa-div)
  set -u %::value $2
  $iif(s isin %raw,raw.theme,raw.themew) $right(00 $+ $numeric,3) $iif(n isin %raw,$color(norm),$iif(b isin %raw,$:c1,$:cerr)) $iif($2- == $null, ,$2-)
  if (> isin %raw) $iif(($hget(pnp.config,rawroute) == -si2) || (s isin %raw),disps-div,dispa-div)
  halt
}


;!! Anything past here needs redoing/reorganization/new location

; /motd command and @MOTD popups
alias motd hadd pnp. $+ $cid -motd.req 1 | motd $1-
menu @MOTD {
  Reload MOTD:{ motd | _dowclose $active | window -c $active }
}

;
; @Whois popups
;

menu @Whois {
  dclick:query $_grabrec(whois,1)
  $_poprec(wch,1):j $_grabrec(wch,1)
  $_poprec(wch,2):j $_grabrec(wch,2)
  $_poprec(wch,3):j $_grabrec(wch,3)
  $_poprec(wch,4):j $_grabrec(wch,4)
  $_poprec(wch,5):j $_grabrec(wch,5)
  $_poprec(wch,6):j $_grabrec(wch,6)
  $_poprec(wch,7):j $_grabrec(wch,7)
  $_poprec(wch,8):j $_grabrec(wch,8)
  $_poprec(wch,9):j $_grabrec(wch,9)
  $_poprec(wch,10):j $_grabrec(wch,10)
  -
  $_poprec(whois,1,$_grabrec(wch,0))
  .User info
  ..Whois:whois $_grabrec(whois,1)
  ..Extended whois:ew $_grabrec(whois,1)
  ..User central...:uwho $_grabrec(whois,1)
  ..Address book...:abook $_grabrec(whois,1)
  ..-
  ..DNS:dns $gettok($_sufnrec(whois,1),2,32)
  ..Hostmask:host $gettok($_sufnrec(whois,1),4,32)
  ..-
  ..Ping server:sping $gettok($_sufnrec(whois,1),3,32)
  .DCC
  ..Chat:dcc chat $_grabrec(whois,1)
  ..Chat to IP:dcc chat $gettok($_sufnrec(whois,1),2,32)
  ..-
  ..Send:dcc send $_grabrec(whois,1)
  ..Send to IP:dcc send $gettok($_sufnrec(whois,1),2,32)
  ..-
  ..$iif(($istok($level($gettok($_sufnrec(whois,1),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,1),4,32)),=auth,44) == $false),$style(1)) Authorize for DCCs:auth -t $gettok($_sufnrec(whois,1),4,32)
  ..$iif(($istok($level($gettok($_sufnrec(whois,1),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,1),4,32)),=auth,44)),$style(1)) Temp authorize:auth -t $gettok($_sufnrec(whois,1),4,32) 15
  .Ping:ping $_grabrec(whois,1)
  .Query:query $_grabrec(whois,1)
  .-
  .$iif($level($gettok($_sufnrec(whois,1),4,32)) > 1,$style(1)) Userlist...:user $gettok($_sufnrec(whois,1),4,32)
  .$iif($_grabrec(whois,1) isnotify,$style(1)) Notify...:notif $gettok($_sufnrec(whois,1),4,32)
  .-
  .Copy:clipboard $_grabrec(whois,1) is $gettok($_sufnrec(whois,1),1,32) $+ @ $+ $gettok($_sufnrec(whois,1),2,32) $gettok($_sufnrec(whois,1),5-,32)
  $_poprec(whois,2,$_grabrec(wch,0))
  .User info
  ..Whois:whois $_grabrec(whois,2)
  ..Extended whois:ew $_grabrec(whois,2)
  ..User central...:uwho $_grabrec(whois,2)
  ..Address book...:abook $_grabrec(whois,2)
  ..-
  ..DNS:dns $gettok($_sufnrec(whois,2),2,32)
  ..Hostmask:host $gettok($_sufnrec(whois,2),4,32)
  ..-
  ..Ping server:sping $gettok($_sufnrec(whois,2),3,32)
  .DCC
  ..Chat:dcc chat $_grabrec(whois,2)
  ..Chat to IP:dcc chat $gettok($_sufnrec(whois,2),2,32)
  ..-
  ..Send:dcc send $_grabrec(whois,2)
  ..Send to IP:dcc send $gettok($_sufnrec(whois,2),2,32)
  ..-
  ..$iif(($istok($level($gettok($_sufnrec(whois,2),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,2),4,32)),=auth,44) == $false),$style(1)) Authorize for DCCs:auth -t $gettok($_sufnrec(whois,2),4,32)
  ..$iif(($istok($level($gettok($_sufnrec(whois,2),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,2),4,32)),=auth,44)),$style(1)) Temp authorize:auth -t $gettok($_sufnrec(whois,2),4,32) 15
  .Ping:ping $_grabrec(whois,2)
  .Query:query $_grabrec(whois,2)
  .-
  .$iif($level($gettok($_sufnrec(whois,2),4,32)) > 1,$style(1)) Userlist...:user $gettok($_sufnrec(whois,2),4,32)
  .$iif($_grabrec(whois,2) isnotify,$style(1)) Notify...:notif $gettok($_sufnrec(whois,2),4,32)
  .-
  .Copy:clipboard $_grabrec(whois,2) is $gettok($_sufnrec(whois,2),1,32) $+ @ $+ $gettok($_sufnrec(whois,2),2,32) $gettok($_sufnrec(whois,2),5-,32)
  $_poprec(whois,3,$_grabrec(wch,0))
  .User info
  ..Whois:whois $_grabrec(whois,3)
  ..Extended whois:ew $_grabrec(whois,3)
  ..User central...:uwho $_grabrec(whois,3)
  ..Address book...:abook $_grabrec(whois,3)
  ..-
  ..DNS:dns $gettok($_sufnrec(whois,3),2,32)
  ..Hostmask:host $gettok($_sufnrec(whois,3),4,32)
  ..-
  ..Ping server:sping $gettok($_sufnrec(whois,3),3,32)
  .DCC
  ..Chat:dcc chat $_grabrec(whois,3)
  ..Chat to IP:dcc chat $gettok($_sufnrec(whois,3),2,32)
  ..-
  ..Send:dcc send $_grabrec(whois,3)
  ..Send to IP:dcc send $gettok($_sufnrec(whois,3),2,32)
  ..-
  ..$iif(($istok($level($gettok($_sufnrec(whois,3),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,3),4,32)),=auth,44) == $false),$style(1)) Authorize for DCCs:auth -t $gettok($_sufnrec(whois,3),4,32)
  ..$iif(($istok($level($gettok($_sufnrec(whois,3),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,3),4,32)),=auth,44)),$style(1)) Temp authorize:auth -t $gettok($_sufnrec(whois,3),4,32) 15
  .Ping:ping $_grabrec(whois,3)
  .Query:query $_grabrec(whois,3)
  .-
  .$iif($level($gettok($_sufnrec(whois,3),4,32)) > 1,$style(1)) Userlist...:user $gettok($_sufnrec(whois,3),4,32)
  .$iif($_grabrec(whois,3) isnotify,$style(1)) Notify...:notif $gettok($_sufnrec(whois,3),4,32)
  .-
  .Copy:clipboard $_grabrec(whois,3) is $gettok($_sufnrec(whois,3),1,32) $+ @ $+ $gettok($_sufnrec(whois,3),2,32) $gettok($_sufnrec(whois,3),5-,32)
  -
  Configure:config 13
}

;
; Away log stuff
;
#awaylog off
on &^*:OPEN:?:*:if ($hget(pnp. $+ $cid,away)) { if (($hget(pnp.config,awaylog.close)) && ($hget(pnp.config,awaylog.msg))) { hadd pnp. $+ $cid timedclose $addtok($hget(pnp. $+ $cid,timedclose),$nick,32) | .timer.dtqc. $+ $cid -o 1 $iif($hget(pnp.config,awaylog.close) == 1,20,0) _dtqc } }
on &^*:TEXT:*:?:while.away 1 $cid < $+ $nick $+ > $1-
on &^*:ACTION:*:?:while.away 2 $cid * $nick $1-
alias -l while.away {
  if (!$hget(pnp. $+ $cid,away)) return
  ; Logs any msg if logging is on, UNLESS query is open, not closing, and we close queries
  if (($hget(pnp.config,awaylog.msg)) && (($hget(pnp.config,awaylog.close) == 0) || ($query($nick) == $null) || ($istok($hget(pnp. $+ $cid,timedclose),$nick,32)))) _awaylog ? $1-
  _away.remind
}
on &^*:NOTICE:*:*:{
  if (!$hget(pnp. $+ $cid,away)) return
  if (($1 === DCC) && (($2 == Chat) || ($2 == Send))) return
  if (@* iswm $target) _awaylog ! 3 $cid $target $+  - $+ $nick $+ - $1-
  elseif (%.opnotice) _awaylog ! 3 $cid @ $+ %.opnotice $+  (?) - $+ $nick $+ - $1-
  else _awaylog ! 4 $cid - $+ $nick $+ - $1-
}
on &*:INVITE:#:if ($hget(pnp. $+ $cid,away)) _awaylog @ 10 $cid ( $+ $chan $+ ) »»» Invited by $nick
; Nick/highlight in channel
on &^*:TEXT:*:#:if ($hget(pnp. $+ $cid,away)) { _doahl 13 < $+ $nick $+ > $strip($1-) | _doaww $1- }
on &^*:ACTION:*:#:if ($hget(pnp. $+ $cid,away)) { _doahl 14 * $+ $nick $strip($1-) | _doaww $1- }
#awaylog end
; If awaylogging off, still do awaywords and reminders
on &^*:TEXT:*:#:if ($hget(pnp. $+ $cid,away)) _doaww $1-
on &^*:ACTION:*:#:if ($hget(pnp. $+ $cid,away)) _doaww $1-
on &^*:TEXT:*:?:if ($hget(pnp. $+ $cid,away)) _away.remind
on &^*:ACTION:*:?:if ($hget(pnp. $+ $cid,away)) _away.remind

;
; CTCP stuff
;
ctcp *:SOUND:return
ctcp *:MP3:return
ctcp *:SLOTS:return
ctcp &175:DO:{
  if ($_cfgi(doaccess)) {
    $2-
    set -u %.ctcp.reply 0
  }
  _do.rctcp $1-
}
ctcp &*:*:_do.rctcp $1-
on &*:CTCPREPLY:*:_do.creply $1-

