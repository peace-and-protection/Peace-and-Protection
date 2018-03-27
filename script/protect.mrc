; #= P&P -rs
; ########################################
; Peace and Protection
; Protection system (channel)
; ########################################

; $_floodc(inc,MAX,SEC,chan,var name) (any num words, will be dotted automatically)
; returns totalcount if flood hit (doesn't reset counter)
; > 800 line is a failsafe for if length gets too long, it merges the initial 3 entries
alias _floodc {
  if (($3 <= 0) || ($3 !isnum)) return
  var %var = $replace($5-,$chr(32),.)
  var %hash = $+(pnp.flood.,$cid,.,$4)
  tokenize 32 $1-3 $calc($ctime - $3) $hget(%hash,%var)
  if ($len($5-) > 800) tokenize 32 $1-4 $gettok($5,3-,58) $calc($gettok($6,1-3,58)) $+ + $+ $gettok($6,4-,58)
  var %cutoff = 1
  while ($gettok($5,%cutoff,43) < $4) { inc %cutoff }
  tokenize 32 $1-3 $gettok($5,%cutoff $+ -,43) $+ + $+ $ctime $gettok($6,%cutoff $+ -,43) $+ + $+ $1
  hadd -u $+ $3 %hash %var $4 $5
  if ($calc($5) >= $2) return $ifmatch
}

; _floodr chan varname (any num words)
; resets a flood counter
alias _floodr hdel $+(pnp.flood.,$cid,.,$1) $replace($2-,$chr(32),.)

; Word/chan list editing
alias _wcled {
  set -u %.var $1 | set -u %.chan $2 | set -u %.type $3-
  _dialog -am protlist protlist
}
dialog protlist {
  title "Channel Protection"
  icon script\pnp.ico
  option dbu
  size -1 -1 142 117

  text "", 1, 2 2 125 10

  list 2, 2 12 100 75
  list 3, 2 12 100 75, hide disable

  button "&Edit...", 4, 105 12 35 12, default
  button "&Add...", 5, 105 28 35 12
  button "&Del", 6, 105 44 35 12

  check "&Use global default list", 9, 5 89 100 10

  button "OK", 10, 2 102 35 12, OK
  button "Cancel", 11, 67 102 35 12, cancel

  edit "", 12, 1 1 1 1, hide autohs
}
on *:DIALOG:protlist:sclick:10:{
  var %stuff,%num = 1
  if (($did(9).state != 1) || ($gettok($did(12),2,32) == *)) {
    :loop
    if ($did(2,%num)) {
      %stuff = $addtok(%stuff,$remove($ifmatch,$chr(44)),44)
      inc %num | goto loop
    }
  }
  `set $gettok($did(12),1,32) $+ $gettok($did(12),2,32) %stuff
}
on *:DIALOG:protlist:init:*:{
  did -a protlist 12 %.var %.chan %.type
  did -a protlist 1 %.type $+ $chr(40) $+ s $+ $chr(41) to scan for $+ :
  if (%.chan == *) { 
    _loadpl %.var * 2
    did -cb protlist 9
  }
  else {
    _loadpl %.var %.chan 2 | _loadpl %.var * 3
    if ($hget(pnp.config,%.var $+ %.chan) == $null) { _visprotl -h -v -b | did -c protlist 9 }
  }
  unset %.var %.chan %.type
}
alias -l _loadpl {
  var %num = 1,%stuff = $hget(pnp.config,$1 $+ $2)
  did -r protlist $3
  :loop
  if ($gettok(%stuff,%num,44) != $null) {
    did -a protlist $3 $ifmatch
    inc %num | goto loop
  }
}
alias -l _visprotl did $1 protlist 2 | did $2 protlist 3 | did $3 protlist 4,5,6
on *:DIALOG:protlist:sclick:9:{
  if ($did(9).state) _visprotl -h -v -b
  else _visprotl -v -h -e
}
on *:DIALOG:protlist:dclick:2:_pled e
on *:DIALOG:protlist:sclick:4:_pled e
on *:DIALOG:protlist:sclick:5:_pled i
on *:DIALOG:protlist:sclick:6:if ($did(protlist,2).sel isnum) did -d protlist 2 $ifmatch
alias -l _pled {
  if ($1 == e) {
    var %edit = $$did(protlist,2,$did(protlist,2).sel)
    did -oc protlist 2 $did(protlist,2).sel $_entry(0,%edit,$gettok($did(protlist,12),3-,32) to scan for?Wildcards are allowed- * will match 'anything'.)
  }
  else did -ac protlist 2 $_entry(0,$null,$gettok($did(protlist,12),3-,32) to scan for?Wildcards are allowed- * will match 'anything'.)
}

; Add channel
dialog paddchan {
  title "Add Channel"
  icon script\pnp.ico
  option dbu
  size -1 -1 105 77

  text "&Base new channel off of settings for:", 1, 2 2 125 10

  list 2, 2 12 100 50

  text "", 3, 1 1 1 1, hide autohs result

  button "OK", 10, 7 60 35 12, OK default
  button "Cancel", 11, 62 60 35 12, cancel
}
on *:DIALOG:paddchan:init:*:{
  var %num = 1
  :loop
  if ($did(chanprot,247,%num) != $null) {
    did -a paddchan 2 $ifmatch
    inc %num | goto loop
  }
}
on *:DIALOG:paddchan:dclick:2:dialog -k paddchan
on *:DIALOG:paddchan:sclick:10:did -a paddchan 3 $did(2,$did(2).sel)

;
; Track channels we are 'opped' in
;

; Updates text/ctcp/other protected channels
; Pass chan $1 cid $2 to exclude a specific channel
alias _upd.prot {
  unset %<protect.*
  var %scon = $scon(0),%all
  while (%scon) {
    scon %scon
    var %chan,%hash,%num = $chan(0)
    while (%num) {
      %chan = $chan(%num)
      if ($me ison %chan) {
        if ($len(%all) <= 500) %all = $addtok(%all,%chan,44)
        %hash = $+(pnp.flood.,$cid,.,%chan)
        hdel -w %hash prot.*
        if (((%chan != $1) || ($cid != $2)) && (($me isop %chan) || ($me ishop %chan))) {
          if ($_getcflag(%chan,71)) {
            if ((%<protect.text == $chr(35)) || ($len(%<protect.text) > 500)) %<protect.text = $chr(35)
            else %<protect.text = $addtok(%<protect.text,%chan,44)
            hadd %hash prot.text 1
          }
          if ($_getcflag(%chan,72)) {
            if ((%<protect.ctcp == $chr(35)) || ($len(%<protect.ctcp) > 500)) %<protect.ctcp = $chr(35)
            else %<protect.ctcp = $addtok(%<protect.ctcp,%chan,44)
            hadd %hash prot.ctcp 1
          }
          if ($_getcflag(%chan,73)) {
            if ((%<protect.misc == *) || ($len(%<protect.misc) > 500)) %<protect.misc = *
            else %<protect.misc = $addtok(%<protect.misc,%chan,44)
            hadd %hash prot.misc 1
          }
        }
      }
      dec %num
    }
    dec %scon
  }
  scon -r
  ; If all, just use #
  if (%all != $null) {
    if (%<protect.text == %all) %<protect.text = $chr(35)
    if (%<protect.misc == %all) %<protect.misc = $chr(35)
    if (%<protect.ctcp == %all) %<protect.ctcp = $chr(35)
  }
}

on me:*:PART:#:_upd.prot $chan $cid
raw 366:*:_upd.prot

;
; Track protection flags (cflags*) and channel options (chopt*)
;

; $_getcflag(#chan,pos) #chan of * for global
alias _getcflag {
  if ($hget(pnp.config,cflags. $+ $1) != $null) if ($gettok($ifmatch,$2,32) != ?) return $ifmatch
  return $gettok($hget(pnp.config,cflags),$2,32)
}
; _setcflag #chan pos value (#chan of * for global)
alias _setcflag {
  if ($1 == *) var %old = $hget(pnp.config,cflags) | else var %old = $hget(pnp.config,cflags. $+ $1)
  if (%old == $null) %old = $_p2s($str(?,80))

  %old = $puttok(%old,$3,$2,32)
  if ($remove(%old,?) == $null) var %old
  if ($1 == *) `set cflags %old | else `set cflags. $+ $1 %old
  if ($2 isnum 71-73) _upd.prot
}
; _clrcflag #chan
alias _clrcflag `set cflags. $+ $1

; $_getchopt(#chan,pos) #chan of * for global
alias _getchopt {
  if ($hget(pnp.config,chopt. $+ $1) != $null) return $gettok($ifmatch,$2,32)
  return $gettok($hget(pnp.config,chopt),$2,32)
}
; _setchopt #chan pos value (#chan of * for global)
alias _setchopt {
  if ($1 == *) var %old = $hget(pnp.config,chopt) | else var %old = $hget(pnp.config,chopt. $+ $1)
  if (%old == $null) %old = $hget(pnp.config,chopt)

  %old = $puttok(%old,$3,$2,32)
  if (($1 != *) && (%old == $hget(pnp.config,chopt))) `set chopt. $+ $1
  elseif ($1 == *) `set chopt %old
  else `set chopt. $+ $1 %old
}

;
; Generic code
;

; 'protect' user due to op/voice/level/chan/type
; Returns 1 if we are not protecting $chan (for this type)
; Returns 1 if over 8 sec lag
; Returns 1 if we are (just) halfop and $nick is a halfop or op (ie, we can't punish them)
; Returns 1 if $nick is owner (and we aren't)
; Returns level if level >= 50 (protected)
; Returns 1 if user is op/hop/voice and those types are protected ($2 nonnull to skip op/hop/voice protected flags)
; if ($_protect(text|ctcp|misc[,1])) $$$
; $2 = nonnull to skip @%+ protection check
alias -l _protect {
  if (!$hget($+(pnp.flood.,$cid,.,$chan),prot. $+ $1)) return 1
  if (($me ishop $chan) && (($nick isop $chan) || ($nick ishop $chan)) && ($me !isop $chan)) return 1
  if (($nick isowner $chan) && ($me !isowner $chan)) return 1
  if ($_level($chan,$level($fulladdress)) >= 50) return $ifmatch
  if ($hget(pnp. $+ $cid,-self.ticks) > 8000) return 1
  if ($2) return 0
  if ($nick isop $chan) {
    if ($_getcflag($chan,69)) return 1
  }
  elseif ($nick ishop $chan) {
    if ($_getcflag($chan,80)) return 1
  }
  elseif ($nick isvoice $chan) {
    if ($_getcflag($chan,70)) return 1
  }
  return 0
}
; (same as above but $2 = nick $3 = chan, for nick/quit/kick events)
alias -l _protectnc {
  if (!$hget($+(pnp.flood.,$cid,.,$3),prot. $+ $1)) return 1
  if (($me ishop $chan) && (($2 isop $3) || ($2 ishop $3)) && ($me !isop $3)) return 1
  if (($2 isowner $3) && ($me !isowner $3)) return 1
  if ($_level($3,$level($address($2,5))) >= 50) return $ifmatch
  if ($hget(pnp. $+ $cid,-self.ticks) > 8000) return 1
  if ($4) return 0
  if ($2 isop $3) {
    if ($_getcflag($3,69)) return 1
  }
  elseif ($2 ishop $3) {
    if ($_getcflag($3,80)) return 1
  }
  elseif ($2 isvoice $3) {
    if ($_getcflag($3,70)) return 1
  }
  return 0
}

; $_action(type,n,chan)
alias -l _action {
  var %file = $_cfg(actions.dat)
  if ($read(%file,tns,$1 $+ $2 $+ $3) != $null) return $ifmatch
  if ($read(%file,tns,$1 $+ 1 $+ $3) != $null) return
  return $read(%file,tns,$1 $+ $2 $+ *)
}

; _punish type $chan target &nick& $site &addr& &fulladdr& &A& &B& [x]
; uses current CID
; target is used as how to track and punish user- either NICK or WILDSITE
; $chan/$site used for code as well; &these& are just used in replacement of msg only
; if x is present, then no waiting is done even for rapid punishments
; returns 0 for waited on punishment or no punishment
; returns 1 for warning punishment
; returns 2 for other punishment
alias -l _punish {
  var %hash = $+(pnp.flood.,$cid,.,$2)
  if (($10 == $null) && ($hget(%hash,$+(wait.,$1,.,$3)))) return 0
  set -u %.punishwait $_getcflag($2,75)
  hinc -u $+ %.punishwait %hash $+(wait.,$1,.,$3)
  hinc -u $+ $calc($_getcflag($2,76) + %.punishwait) %hash $+(act.,$1,.,$3)
  var %actnum = $hget(%hash,$+(act.,$1,.,$3))
  var %action = $_action($1,%actnum,$2)
  if ((%action == $null) && (%actnum > 1)) {
    hdec %hash $+(act.,$1,.,$3)
    dec %actnum
    %action = $_action($1,%actnum,$2)
  }
  if (%action != $null) {
    ; 'bonus' cmd first
    if ($gettok(%action,1,32) > 1) {
      var %cmd = $gettok(* .mode+i .mode+m .mode+im warn warn-chan warn-self warn-ops warn-msg,$ifmatch,32)
      if (warn* iswm %cmd) %cmd $2 $3 $msg.compile($_protwarnmsg($mid(*...nwzwn,$gettok(%action,1,32),1),$1),&chan&,$2,&nick&,$4,&A&,$_p2s($8),&B&,$_p2s($9))
      else %cmd $2
    }
    else var %cmd
    ; 'main' cmd now
    if ($gettok(%action,2,32) > 1) var %do = $gettok(* .bk .bk0 .bk2 .cb .unop .fk .kick .tempban warn warn-chan warn-self warn-ops warn-msg,$ifmatch,32) &chan& &target& $gettok(%action,3-,32)
    else {
      var %do = $gettok(%action,3-,32)
      if ((&target& !isin %do) && (&nick& !isin %do) && (&site& !isin %do) && (&addr& !isin %do) && (&fulladdr& !isin %do) && (&chan& !isin %do)) %do = $gettok(%do,1,32) &chan& &target& $gettok(%do,2-,32)
    }
    $msg.compile(%do,&chan&,$2,&target&,$3,&nick&,$4,&site&,$5,&addr&,$6,&fulladdr&,$7,&A&,$_p2s($8),&B&,$_p2s($9))
    ; show?
    if (($_getchopt($2,6)) && ((%cmd != warn-self) && (warn* !iswm %do))) {
      disprc $2 Punishing $:t($3) $chr(40) $+ $6 $+ $chr(41) $replace($read(script\punish.dat,tsn,$1),&A&,$_p2s($8),&B&,$_p2s($9)) - Offense %actnum $chr(40) $+ $remove($gettok(%do,1,32),.) $+ $chr(41)
    }
    _ssplay ProtectChan
    _recseen 10 offend $+ $2 $7 $1 $8 $9
    if (warn isin $gettok(%do,1,32)) return 1
    return 2
  }
  return 0
}

; _protwarnmsg s|w|n|k|c code
; s = warning display local
; z = warning display local (bold/color already applied)
; w = warning display (no bold/color)
; n = warning intended for user
; k = kick message
; c = nothing
alias _protwarnmsg {
  goto $1
  :z | return $:t(&nick&) triggered protection- $read(script\punish.dat,tsn,$2) (F8 to punish)
  :s | return $!:t(&nick&) triggered protection- $read(script\punish.dat,tsn,$2) (F8 to punish)
  :w | return &nick& triggered protection- $read(script\punish.dat,tsn,$2)
  :n | return Warning: Protection on &chan& triggered- $read(script\punish2.dat,tsn,$2)
  :k | return $read(script\punish2.dat,tsn,$2)
  :c | return
}

; standard protection; assumes $3 (max) is above 0 (x is true to skip waits between punishments- see _punish)
;  _lamercheck type inc max secs nick/wildsite chan [x]
; $_lamercheck(type,inc,max,secs,nick/wildsite,chan[,x])
; uses current CID
; use nick for plain protections, wildsite for join/nick/etc; tracks and punishes by this
; assumes $nick $site $address $fulladdress are valid
; returns 1 if non-warning protection enabled to tell calling script to skip further protections
alias -l _lamercheck {
  if ($_floodc($2,$3,$4,$6,fld,$1,$5)) {
    _punish $1 $6 $5 $nick $site $address $fulladdress $3 $4 $7
    if ($result) { _floodr $6 fld $1 $5 | if ($result > 1) return 1 }
  }
}
; Same as above but uses $newnick where needed
alias -l _lamerchecknn {
  if ($_floodc($2,$3,$4,$6,fld,$1,$5)) {
    _punish $1 $6 $5 $newnick $site $address $newnick $+ ! $+ $address $3 $4 $7
    if ($result) { _floodr $6 fld $1 $5 | if ($result > 1) return 1 }
  }
}

;
; CTCP protections
;

ctcp *:DCC:%<protect.ctcp:{
  _ccprot 41
  if ($_getcflag($chan,74)) {
    if (%.dcc.invalid) _punish invdcc $chan $nick $nick $site $address $fulladdress $2 $_s2p(%.dcc.invalid)
    elseif ($istok(ACCEPT RESUME,$2,32)) _punish invdcc $chan $nick $nick $site $address $fulladdress $2 DCCACCEPT/RESUMEtoachannel
  }
}
ctcp *:PING:%<protect.ctcp:_ccprot $iif($len($1-) < 26,33,34)
ctcp *:?DCC:%<protect.ctcp:_ccprot 40
ctcp *:SOUND:%<protect.ctcp:{
  _ccprot 39
  var %sound = $_getcflag($chan,21)
  if (%sound) if ($_getcflag($chan,8) > 0) _lamercheck scroll %sound $ifmatch $_getcflag($chan,9) $nick $chan
}
ctcp *:MP3:%<protect.ctcp:{
  _ccprot 39
  var %sound = $_getcflag($chan,21)
  if (%sound) if ($_getcflag($chan,8) > 0) _lamercheck scroll %sound $ifmatch $_getcflag($chan,9) $nick $chan
}
ctcp *:*:%<protect.ctcp:if ($findtok(ECHO TIME VERSION USERINFO CLIENTINFO SOUND XDCC DCC FINGER,$1,1,32)) _ccprot $calc($ifmatch + 33) | else _ccprot 43
; (runs the given ctcp-related protection in $1; calls $_protect for us)
alias -l _ccprot {
  _recseen 10 offend $+ $chan $fulladdress ctcp x x
  if ($_protect(ctcp)) $$$

  var %pts = 1
  if ($_getcflag($chan,28)) {
    %pts = $_getcflag($chan,$1)
    if (%pts < 1) return
  }

  if ($_getcflag($chan,29) > 0) {
    if ($_lamercheck(ctcp,%pts,$ifmatch,$_getcflag($chan,30),$wildsite,$chan,x)) $$$
  }

  if ($_getcflag($chan,31) > 0) {
    if ($_floodc(%pts,$ifmatch,$_getcflag($chan,32),$chan,fld.ctcp)) {
      _punish allc $chan $wildsite $nick $site $address $fulladdress $_getcflag($chan,31) $_getcflag($chan,32)
      if ($result > 1) $$$
    }
  }
}

;
; Text protections
;

on *:NOTICE:*:%<protect.text:{
  if ($target !ischan) return
  if ($_protect(text)) return

  if ($_getcflag($chan,12) > 0) if ($_lamercheck(notice,1,$ifmatch,$_getcflag($chan,13),$nick,$chan)) return

  _txprot $1-
}

on *:TEXT:*:%<protect.text:if ($_protect(text)) return | _txprot $1-
on *:ACTION:*:%<protect.text:if ($_protect(text)) return | _txprot $1-
alias -l _txprot {
  if ($_getcflag($chan,8) > 0) if ($_lamercheck(scroll,1,$ifmatch,$_getcflag($chan,9),$nick,$chan)) return
  if ($_getcflag($chan,6) > 0) if ($_lamercheck(text,$len($1-),$ifmatch,$_getcflag($chan,7),$nick,$chan)) return

  if ($_getcflag($chan,10) > 0) {
    if ($hget($+(pnp.flood.,$cid,.,$chan),last. $+ $nick) == $strip($1-)) { if ($_lamercheck(repeat,1,$_getcflag($chan,10),$_getcflag($chan,11),$nick,$chan)) return }
    else hadd -u $+ $calc($_getcflag($chan,11) + 1) $+(pnp.flood.,$cid,.,$chan) last. $+ $nick $strip($1-)
  }
  if ($_getcflag($chan,19) > 0) if ($calc($stripped + $count($1-,,,,)) > $ifmatch) { _punish attrab $chan $nick $nick $site $address $fulladdress $ifmatch $_getcflag($chan,19) | if ($result > 1) return }
  if ($_getcflag($chan,17) > 0) if ($_lamercheck(attrfl,$calc($stripped + $count($1-,,,,)),$ifmatch,$_getcflag($chan,18),$nick,$chan)) return

  if ($_getcflag($chan,14) > 0) {
    var %letter = $calc($len($1-) - $len($remove($1-,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z)))
    if (%letter >= $_getcflag($chan,15)) {
      var %cap = $calc($len($1-) - $len($removecs($1-,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z)))
      if ($calc(%cap / %letter * 100) >= $_getcflag($chan,14)) _punish caps $chan $nick $nick $site $address $fulladdress $int($ifmatch) $_getcflag($chan,14)
    }
  }

  if ($_getcflag($chan,24)) _wordkick 1 , $1- ,
  if ($_getcflag($chan,25)) _wordkick 2 , $1- ,
}
; If word is too long, shorten and add ...
alias -l _wkshorten {
  if ($len($1) > 15) return $left($1,12) $+ ...
  return $1
}
alias -l _wordkick {
  var %words = $hget(pnp.config,$+(wordk,$1,.,$chan))
  if (%words == $null) %words = $hget(pnp.config,$+(wordk,$1,.*))
  if (%words) {
    var %match,%stripped,%num = $numtok(%words,44)
    %stripped = , $replace($strip($3-),!,.,$chr(44),.,-,.,$chr(40),.,$chr(41),.,?,.,",.,.,$chr(32)) ,
    while (%num) {
      %match = * $gettok(%words,%num,44) *
      if (%match iswm %stripped) { _punish wordk $+ $1 $chan $nick $nick $site $address $fulladdress $_s2p($gettok(%words,%num,44)) $_wkshorten($wildtok(%stripped,$gettok(%words,%num,44),1,32)) | if ($result < 2) return | $$$ }
      if (%match iswm $2-) { _punish wordk $+ $1 $chan $nick $nick $site $address $fulladdress $_s2p($gettok(%words,%num,44)) $_wkshorten($wildtok($2-,$gettok(%words,%num,44),1,32)) | if ($result < 2) return | $$$ }
      dec %num
    }
  }
}

on !*:NICK:{
  var %chan,%fulladdress = $newnick $+ ! $+ $address,%num = $comchan($newnick,0)
  while (%num) {
    %chan = $comchan($newnick,%num)
    if ($istok($level(%fulladdress),=black,44)) _runblack %chan $_fuser(%fulladdress)
    elseif ($_protectnc(text,$newnick,%chan)) {
      if ($_getcflag(%chan,4) > 0) {
        _lamerchecknn nick 1 $ifmatch $_getcflag(%chan,5) $wildsite %chan
      }
    }
    :skip
    dec %num
  }
}

on !*:TOPIC:%<protect.text:{
  if ($_protect(text,1)) return
  if ($_getcflag($chan,20) > 0) if ($_getcflag($chan,8) > 0) _lamercheck scroll $_getcflag($chan,20) $ifmatch $_getcflag($chan,9) $nick $chan
}

on !*:QUIT:{
  ; clean punishment waits when a user quits
  var %chan,%hash,%split,%num = $comchan($nick,0)
  if ((($left($1,2) == *.) || ($count($1,.) > 2)) &&  (($left($2,2) == *.) || ($count($2,.) > 2)) && ($3 == $null)) %split = 1
  while (%num) {
    %chan = $comchan($nick,%num)
    %hash = $+(pnp.flood.,$cid,.,%chan)
    hdel -w %hash wait.*. $+ $nick
    hdel -w %hash wait.*. $+ $replace($wildsite,*,?)
    if ($hget(%hash,prot.misc)) _dojplim %chan
    if (%split) hadd %hash split. $+ $nick 1
    dec %num
  }
}
on !*:PART:%<protect.misc:{
  var %hash = $+(pnp.flood.,$cid,.,$chan)
  hdel -w %hash wait.*. $+ $nick
  hdel -w %hash wait.*. $+ $replace($wildsite,*,?)
  if ($hget(%hash,prot.misc)) _dojplim $chan
  if ($_protect(misc)) return
  if ($_getcflag($chan,57) > 0) _lamercheck joinp 1 $ifmatch $_getcflag($chan,58) $wildsite $chan
}
; Cleans a blacklisted user out of a chan
; /_runblack chan usermask (must match one in userlist)
alias -l _runblack {
  var %file = $_cfg(userinfo.ini),%chan = $readini(%file,n,$2,chan)
  if ((%chan == $null) || ($istok(%chan,$1,44))) {
    set -u %.punishwait 1
    disprc $1 $:s($2) is blacklisted- Kickbanning...
    var %msg = $_msg(black)
    if (&reason& !isin %msg) %msg = %msg &reason&
    set -u %&reason& $_readprep($readini(%file,n,$2,note))
    set -u %&addr& $2
    kb $1 $2 %msg
    unset %&reason& %&addr&
  }
}
on !*:JOIN:#:{
  ; User level, for autoop etc
  var %lvl = $level($fulladdress),%level = $_level($chan,%lvl)
  if (($me isop $chan) || ($me ishop $chan)) {
    if ($istok(%lvl,=black,44)) _runblack $chan $maddress
    elseif ((@ isin %level) || (+ isin %level) || (% isin %level)) {
      ; Find out if we use pw info for channel or global
      var %scan = $chr(44) $+ = $+ $chan $+ ¬
      if (%scan isin %lvl) var %chan = $chan
      else var %chan = *
      if ((*@ iswm %level) && ($me isop $chan)) {
        if ($null == $readini($_cfg(userinfo.ini),n,$maddress,%chan)) { _init.mass $chan 4 | _add.mass $chan + o $nick }
      }
      if ((*% iswm %level) && ($me isop $chan)) {
        if ($null == $readini($_cfg(userinfo.ini),n,$maddress,%chan)) { _init.mass $chan 4 | _add.mass $chan + h $nick }
      }
      if (*+ iswm %level) {
        if ($null == $readini($_cfg(userinfo.ini),n,$maddress,%chan)) { _init.mass $chan 4 | _add.mass $chan + v $nick }
      }
    }
  }
  var %hash = $+(pnp.flood.,$cid,.,$chan)
  if ($hget(%hash,prot.misc)) _dojplim $chan
  ; If this nick was split before, clean all splits on this chan after 20 sec
  if ($hget(%hash,split. $+ $nick)) .timer.clearsplit. $+ $cid $+ . $+ $chan 1 20 if ($hget(%hash)) hdel -w %hash split.*
  ; Whois/ircop check on join
  if (($_getchopt($chan,11)) && (($me isop $chan) || ($me ishop $chan) || ($_getchopt($chan,12) == 0)) && (($hget(pnp. $+ $cid,away) == $null) || ($_getchopt($chan,13) == 0))) %.joinwhois.show = $calc(1 + $_getchopt($chan,14))
  if ($_getchopt($chan,9)) %.joinwhois.do = $addtok(%.joinwhois.do,_ircopchk,32)
  if ($_protect(misc,1)) return
  if ($_getcflag($chan,22)) %.joinwhois.do = $addtok(%.joinwhois.do,_pervscan,32)
  ; Mass join flood
  if (($_getcflag($chan,59)) && (!$hget(%hash,split. $+ $nick))) {
    var %req = $round($calc($nick($chan,0) * $_getcflag($chan,60) / 100),0)
    if ($_getcflag($chan,61) > %req) %req = $ifmatch
    if ($_getcflag($chan,62) < %req) %req = $ifmatch
    if ($_floodc(1,%req,$_getcflag($chan,63),$chan,fld.massjoin)) {
      disprc $chan Mass join detected $chr(40) $+ $:s($ifmatch) joins $+ $chr(41) Temp. setting mode...
      _floodr $chan fld.massjoin
      tempmode 60 $chan $_p2s($_getcflag($chan,3))
    }
  }
  ; Clones?
  if (($_getcflag($chan,1)) && (%level < 25)) {
    if ($_getcflag($chan,2)) var %mask = $mask($fulladdress,1)
    else var %mask = $wildsite
    if ($ialchan(%mask,$chan,0) > $_getcflag($chan,1)) {
      _punish clones $chan %mask $nick $site $address $fulladdress $ifmatch %mask
      if ($result > 1) return
    }
  }
  if ($_getcflag($chan,57) > 0) _lamercheck joinp 1 $ifmatch $_getcflag($chan,58) $wildsite $chan
}
;!! New limit update method needed? tweak? (ex: not +1 or -1)
alias -l _dojplim if ($_getcflag($1,64)) .timer.limitfresh. $+ $cid $+ . $+ $1 1 $_getcflag($1,68) _limitfresh $1
alias -l _limitfresh {
  var %limit = $calc($nick($1,0) * $_getcflag($1,65) / 100)
  if ($_getcflag($1,66) > %limit) %limit = $ifmatch
  if ($_getcflag($1,67) < %limit) %limit = $ifmatch
  if ($calc($nick($1,0) + %limit) != $chan($1).limit) .mode $1 +l $ifmatch
}
alias _ircopchk {
  if ($3) {
    if ($4 == 0) return
    ; (not translated as that matches what most servers will be sending)
    disprc $1 Warning: $:t($2) is an IRCop
  }
  else {
    if ($hget(pnp.twhois. $+ $cid,operline) == $null) return
    disprc $1 Warning: $:t($2) $hget(pnp.twhois. $+ $cid,operline)
  }
  var %num = $comchan($2,0)
  while (%num >= 1) {
    _nickcol.flagset $2 $comchan($2,%num) $_nickcol.flag($2,$comchan($2,%num)) $+ *
    dec %num
  }
  _nickcol.updatenick $2 1
}
alias _pervscan {
  var %chans = $hget(pnp.config,pervscan. $+ $1)
  if (%chans == $null) %chans = $hget(pnp.config,pervscan.*)
  if (%chans) {
    var %on = $remtok($hget(pnp.twhois. $+ $cid,chanbare),$1,1,32)
    if (%on) {
      var %num = $numtok(%chans,44)
      :loop2
      if ($wildtok(%on,$gettok(%chans,%num,44),1,32)) _punish pervscan $1 $2 $2 $gettok($hget(pnp.twhois. $+ $cid,address),2-,64) $hget(pnp.twhois. $+ $cid,address) $2 $+ ! $+ $hget(pnp.twhois. $+ $cid,address) $ifmatch $gettok(%chans,%num,44)
      elseif (%num > 1) { dec %num | goto loop2 }
    }
  }
}
on *:BAN:%<protect.misc:{
  ; Not being protected? Still show banned
  if (!$hget($+(pnp.flood.,$cid,.,$chan),prot.misc)) {
    if (($_getchopt($chan,10)) && (%.ban.count)) show.banned $chan %.ban.count %.ban.who
    return
  }
  if (($remove($banmask,*,!,?,.,@,~) == $null) && ($_getcflag($chan,56))) return
  var %skipen
  if (($banmask iswm $hget(pnp. $+ $cid,-myself)) && ($_getcflag($chan,45))) {
    _ssplay BanSelf
    if ($nick == $me) { disprc $chan You banned yourself.. removing ban. | .mode $chan -b $banmask }
    else {
      disprc $chan You were banned by $:t($nick) - attempting to unban
      unban $chan $banmask
      if ($_protect(misc,1)) return
      _punish banyou $chan $nick $nick $site $address $fulladdress $banmask $hget(pnp. $+ $cid,-myself)
      if ($result > 1) return
      %skipen = 1
    }
  }
  elseif (($_getchopt($chan,10)) && (%.ban.count)) show.banned $chan %.ban.count %.ban.who
  if ($nick == $me) return
  var %whom,%num = %.ban.count
  :loop
  %whom = $ialchan($banmask,$chan,%num).nick
  ; Was this banned user protected?
  if ((%whom != $nick) && ($_level($chan,$level($address(%whom,5))) >= 60)) {
    ; Was user protected with revenge, and banner is not a friend? if so KICK (if able)
    ; (_protect will check that user is not protected themselves, isowner, etc.)
    if ($ifmatch >= 75) {
      if (!$_protect(misc,1)) .raw kick $chan $nick : $+ $msg.compile($_msg(protectb),&chan&,$chan,&nick&,%whom,&addr&,$maddress,&ban&,$banmask,&you&,$nick)
    }
    ; Unban.
    _init.mass $chan | _add.mass $chan - b $banmask
    ; Don't loop anymore- found a user to protect already.
    ; Worst case scenario- a later user is level 75 and therefore we missed kicking the banner when we should've.
  }
  else {
    ; Next banned user
    if (%num > 1) { dec %num | goto loop }
    ; No protected users on channel were banned. Unless they banned themselves...
    if ($banmask !iswm $fulladdress) {
      ; ...see if they banned any protected users NOT on channel
      var %user = $_fuser2($banmask)
      if ($_level($chan,$level(%user)) >= 60) {
        ; User protected with revenge? deop user if able. (_protect will check that user is not protected themselves, isowner, etc.)
        if ($ifmatch >= 75) {
          _init.mass $chan
          if (!$_protect(misc,1)) {
            if ($nick isop $chan) _add.mass $chan - o $nick
            if ($nick ishop $chan) _add.mass $chan - h $nick
          }
        }
        else _init.mass $chan
        _add.mass $chan - b $banmask
        ; Send msg to user so they know why.
        if ($msg.compile($_msg(protectbn),&chan&,$chan,&nick&,%user,&addr&,%user,&ban&,$banmask,&you&,$nick)) _linedance notice $nick $ifmatch
      }
    }
  }
  ; If not doing protections, skip to ban enforcement
  if ($_protect(misc,1)) goto enforce
  if (%.ban.count) {
    if ($_getcflag($chan,50)) {
      if ($_floodc(%.ban.count,$ifmatch,$_getcflag($chan,51),$chan,fld.mbanu,$wildsite) > %.ban.count) {
        _punish mbanu $chan $wildsite $nick $site $address $fulladdress $ifmatch $_getcflag($chan,51)
        if ($result) { _floodr $chan fld.mbanu $wildsite | if ($result > 1) return | %skipen = 1 }
      }
    }
    if ($_getcflag($chan,52)) {
      if ($_floodc(1,$ifmatch,$_getcflag($chan,53),$chan,fld.mbanb,$wildsite)) {
        _punish mbanb $chan $wildsite $nick $site $address $fulladdress $ifmatch $_getcflag($chan,53)
        if ($result) { _floodr $chan fld.mbanb $wildsite | return }
      }
    }
  }
  :enforce
  if (%skipen) return
  ; enforce ban
  set -u %.punishwait 1
  if (($_getcflag($chan,23)) && (($nick isop $chan) || ($nick ishop $chan)) && (%.ban.count < 4)) {
    set -u %&banner& $nick
    .fk -rvu $chan $banmask $_msg(banned)
    unset %&banner&
  }
}
on *:BAN:#:{
  if (($_getchopt($chan,10)) && (%.ban.count)) show.banned $chan %.ban.count %.ban.who
}

on !*:MODE:%<protect.misc:{
  if ($_protect(misc,1)) return
  var %modes = $_fixmode($1)
  if (($count(%modes,+l,+k,+i) > 1) && ($_getcflag($chan,55))) {
    _init.mass $chan
    var %mode,%pos = 1
    :loop
    %mode = $mid(%modes,%pos,2)
    if ($len(%mode) == 2) {
      if (-* iswm %mode) { if (%mode !=== -k) _add.mass $chan + $mid(%mode,2,1) }
      else _add.mass $chan - $mid(%mode,2,1) $iif(%mode === +k,$chan($chan).key)
      inc %pos 2 | goto loop
    }
    _punish tover $chan $nick $nick $site $address $fulladdress $1 $_s2p($1-)
    if ($result > 1) return
  }
  if ((+l isin %modes) && ($chan($chan).limit == 1) && ($_getcflag($chan,54))) {
    _init.mass $chan
    _add.mass $chan - l
    _punish model $chan $nick $nick $site $address $fulladdress $1 $_s2p($1-)
  }
}

on *:KICK:#:{
  if ($knick == $me) _upd.prot $chan $cid
  else {
    var %hash = $+(pnp.flood.,$cid,.,$chan)
    hdel -w %hash wait.*. $+ $knick
    hdel -w %hash wait.*. $+ $replace($address($knick,2),*,?)
    if (!$hget(%hash,prot.misc)) return
    _dojplim $chan
    if (($nick == $me) || ($nick == $knick)) return
    ; protected?
    if ($_level($chan,$level($address($knick,5))) >= 60) {
      ; revenge and kicker not protected?
      if ($ifmatch >= 75) {
        ; (kick if able- includes checking that user isn't also protected, isowner, etc.)
        if (!$_protect(misc,1)) .raw kick $chan $nick : $+ $msg.compile($_msg(protectk),&chan&,$chan,&nick&,$knick,&addr&,$maddress,&you&,$nick)
      }
      invite $knick $chan
      return
    }
    if ($_protectnc(misc,$knick,$chan,1)) return
    ; mass deop/kick prots
    if (($knick isop $chan) && ($_getcflag($chan,46))) {
      if ($_floodc(1,$ifmatch,$_getcflag($chan,47),$chan,fld.deop,$wildsite)) {
        _punish deop $chan $wildsite $nick $site $address $fulladdress $ifmatch $_getcflag($chan,47)
        if ($result) { _floodr $chan fld.deop $wildsite | if ($result > 1) return }
      }
    }
    if ($_getcflag($chan,48)) {
      _lamercheck kick 1 $ifmatch $_getcflag($chan,49) $wildsite $chan
    }
  }
}
on *:DEOP:%<protect.misc:{
  if ($opnick == $me) { _upd.prot | return }
  if (($nick == $me) || ($_isbot($nick)) || ($nick == $opnick)) return
  ; protected?
  if (($me isop $chan) && ($_level($chan,$level($address($opnick,5))) >= 60)) {
    ; revenge and deopper not protected?
    if ($ifmatch >= 75) {
      _init.mass $chan
      if (!$_protect(misc,1)) _add.mass $chan - o $nick
    }
    else _init.mass $chan
    _add.mass $chan + o $opnick
    if ($msg.compile($_msg(protectd),&chan&,$chan,&nick&,$opnick,&addr&,$maddress,&you&,$nick)) _linedance notice $nick $ifmatch
  }
  if ($_protect(misc,1)) return
  if ($_getcflag($chan,46)) {
    _lamercheck deop 1 $ifmatch $_getcflag($chan,47) $wildsite $chan
  }
}
on *:DEHELP:%<protect.misc:{
  if ($hnick == $me) { _upd.prot | return }
  if (($nick == $me) || ($_isbot($nick)) || ($nick == $hnick)) return
  ; protected?
  if (($me isop $chan) && ($_level($chan,$level($address($hnick,5))) >= 60)) {
    ; revenge and deopper not protected?
    if (($ifmatch >= 75) && ($_level($chan,$level($fulladdress)) < 50)) {
      _init.mass $chan
      if (!$_protect(misc,1)) {
        if ($nick isop $chan) _add.mass $chan - o $nick
        if ($nick ishop $chan) _add.mass $chan - h $nick
      }
    }
    else _init.mass $chan
    _add.mass $chan + h $hnick
    if ($msg.compile($_msg(protectd),&chan&,$chan,&nick&,$hnick,&addr&,$maddress,&you&,$nick)) _linedance notice $nick $ifmatch
  }
}
on *:DEOP:#:{ if ($opnick == $me) _upd.prot }
on *:DEOWNER:#:{ if ($opnick == $me) _upd.prot }
on *:DEHELP:#:{ if ($hnick == $me) _upd.prot }
on *:OWNER:#:_doop 1
on *:OP:#:_doop
on *:SERVEROP:#:_doop
alias -l _doop {
  if ($opnick == $me) {
    _upd.prot
    ; Blacklist scan
    var %addr,%num = $ulist(*,black,0)
    :loop
    if (%num) {
      %addr = $ulist(*,black,%num)
      if ($ialchan(%addr,$chan,1)) _runblack $chan %addr
      dec %num | goto loop
    }
  }
  ; $2 = 1 to skip this (owner event)
  elseif (($nick != $me) && ($me isop $chan) && (!$2)) {
    ; auto-deop?
    if ($right($_level($chan,$level($address($opnick,5))),1) == -) .deop $chan $opnick
    elseif (($hget($+(pnp.flood.,$cid,.,$chan),prot.misc)) && ($_getcflag($chan,$iif(. isin $nick,78,77)))) {
      if (($notify($opnick) == $null) && ($remtok($level($address($opnick,5)),=black,1,44) == $dlevel)) .deop $chan $opnick
    }
  }
}
on *:HELP:#:{
  if ($hnick == $me) {
    _upd.prot
    ; Blacklist scan
    var %addr,%num = $ulist(*,black,0)
    :loop
    if (%num) {
      %addr = $ulist(*,black,%num)
      if ($ialchan(%addr,$chan,1)) _runblack $chan %addr
      dec %num | goto loop
    }
  }
  elseif (($nick != $me) && ($me isop $chan)) {
    ; auto-deop?
    if ($right($_level($chan,$level($address($hnick,5))),1) == -) .dehop $chan $hnick
    elseif (($hget($+(pnp.flood.,$cid,.,$chan),prot.misc)) && ($_getcflag($chan,$iif(. isin $nick,78,77)))) {
      if (($notify($hnick) == $null) && ($remtok($level($address($hnick,5)),=black,1,44) == $dlevel)) .dehop $chan $hnick
    }
  }
}

;
; show users banned
; $1 = chan $2 = count $3- = users, if <11
; Plays sound and special message if you're banned, also
;
alias -l show.banned {
  ; Don't show banned users if ONLY you were banned
  if ($3- != $me) {
    if ($3) {
      if ($2 > 1) disprc $1 Banned- $:l($3-) ( $+ $2 users)
      else disprc $1 Banned- $:l($3-)
    }
    else disprc $1 Banned- $:t($2) users
  }
  if ($banmask iswm $hget(pnp. $+ $cid,-myself)) {
    _ssplay BanSelf
    disprc $1 You were banned by $:t($nick)
  }
}

;
; Protect aliases
;

; Returns modes that you should set that aren't already set
; $_setmode(currmodes,toset)
alias _setmode {
  var %curr = $_fixmode($1)
  var %set = $_fixmode($2)
  var %pos = 1
  var %final
  while ($mid(%set,%pos,2)) {
    var %test = $ifmatch
    if ((-* iswm %test) && ($right(%test,1) isincs %curr)) %final = %final $+ %test
    if ((+* iswm %test) && ($right(%test,1) !isincs %curr)) %final = %final $+ %test
    inc %pos 2
  }
  return %final
}

; /tempmode n chan modes
alias tempmode {
  var %todo = $_setmode($chan($2).mode,$3)
  if (%todo) {
    _init.mass $2
    _add.mass $2 $left(%todo,1) $right(%todo,-1) $4-
    .timer 1 $1 .raw mode $2 $replace(%todo,+,/,-,+,/,-) $4-
  }
}
alias mode+i tempmode 60 $1 +i
alias mode+m tempmode 60 $1 +m
alias mode+im tempmode 60 $1 +im
alias warn {
  if ($_ismask($2)) _linedance fnotice $1-
  else _linedance notice $2-
}
alias warn-msg {
  ;;; leave as fnotice?
  if ($_ismask($2)) _linedance fnotice $1-
  else _linedance msg $2-
}
alias warn-chan _linedance notice $1 $3-
alias warn-self disprc $1 $3-
alias warn-ops _linedance onotice $1 $3-

;
; Quick toggles
;
; /chopt [#channel|*] [+|-|*|?]ircop|text|ctcp|misc|all|op|hop|voc|enforce|selfban|whois|whoisaway|whoischan|whoisop|checkop|protnote|showclone|kickdelay|showban ...
; /prot same
; * toggles, ? sets to use global default
alias prot chopt $1-
alias chopt {
  var %name,%flag,%bit,%work,%chan,%todo,%num = 1
  if (($left($1,1) isin $remove(& $+ $chantypes,+,-)) || ($1 == *)) { %chan = $1 | %todo = $2- } | elseif (#) { %chan = # | %todo = $1- } | else _error You must use /chopt in a channel $+ $chr(40) $+ or specify a target channel $+ $chr(41)
  if (%todo == $null) {
    dispa Syntax: /chopt [#channel] [+|-]option ...
    dispa Options: ircop, text, ctcp, misc, all, op, hop, voc, enforce, selfban, whois, whoisaway, whoischan, whoisop, checkop, protnote, showclone, showban, kickdelay
    return
  }
  :loop
  %work = $gettok(%todo,%num,32)
  if ($left(%work,1) isin 0?+-*) { %bit = $left(%work,1) | %work = $right(%work,-1) }
  else %bit = 0
  if (%work == $null) return
  if ($findtok(text ctcp misc op hop voc enforce selfban,%work,1,32)) {
    %name = $gettok(Text protections are <onoff>CTCP protections are <onoff>Other protections are <onoff>Ops immunity is <onoff>Halfops immunity is <onoff>Voiced user immunity is <onoff>Ban enforcement is <onoff>Personal ban protection is <onoff>,$ifmatch,127)
    %flag = $gettok(71 72 73 69 80 70 23 45,$ifmatch,32)
    if (%bit == *) _setcflag %chan %flag $iif($_getcflag(%chan,%flag),0,1)
    elseif (%bit == +) _setcflag %chan %flag 1
    elseif (%bit == -) _setcflag %chan %flag 0
    elseif ((%bit == ?) && (%chan != *)) _setcflag %chan %flag ?
    dispa $replace(%name,<onoff>,$:s($_tf2o($_getcflag(%chan,%flag)))) ( $+ for %chan $+ )
  }
  elseif ($findtok(ircop whois whoisaway whoischan whoisop checkop protnote showclone kickdelay showban,%work,1,32)) {
    %name = $gettok(IRCop check on join is <onoff>Whois on join is <onoff>Don't whois on join if away is <onoff>Show whois on join in channel is <onoff>Only whois on join if opped is <onoff>Check op status before performing op commands is <onoff>Display note when channel protection triggers is <onoff>Show clones on join is <onoff>Delay between multiple kicks is <onoff>Show banned usres on ban is <onoff>,$ifmatch,127)
    %flag = $gettok(9 11 13 14 12 5 6 7 8 10,$ifmatch,32)
    if (%bit == *) _setchopt %chan %flag $iif($_getchopt(%chan,%flag),0,1)
    elseif (%bit == +) _setchopt %chan %flag 1
    elseif (%bit == -) _setchopt %chan %flag 0
    elseif ((%bit == ?) && (%chan != *)) _setchopt %chan %flag $_getchopt(*,%flag)
    dispa $replace(%name,<onoff>,$:s($_tf2o($_getchopt(%chan,%flag)))) ( $+ for %chan $+ )
  }
  elseif (%work == all) %todo = %todo %bit $+ text %bit $+ ctcp %bit $+ misc
  else dispa Unknown option ' $+ %work $+ '
  inc %num | goto loop
}
