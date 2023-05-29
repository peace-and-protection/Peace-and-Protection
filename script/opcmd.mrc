; #= P&P -rs
; ########################################
; Peace and Protection
; Basic op commands
; ########################################

; inline kick- won't kick same person many times (10 sec or until a join or you gain op/help)
alias _kick if ($hget($+(pnp.flood.,$cid,.,$1),kicked. $+ $2)) return | hadd $+(pnp.flood.,$cid,.,$1) kicked. $+ $2 1 | if ($_getchopt($1,8)) _linedance .raw kick $1 $2 : $+ $3- | else .raw kick $1 $2 : $+ $3-

;
; Unset inline kick counters; strictmode/stricttopic when we are opped or join
;
on *:JOIN:#:hdel $+(pnp.flood.,$cid,.,$chan) kicked. $+ $nick
on *:OP:#:{ if ($opnick == $me) _onopstrict }
on *:OWNER:#:{ if ($opnick == $me) _onopstrict }
on *:HELP:#:{ if ($hnick == $me) _onopstrict }
alias -l _onopstrict {
  var %hash = $+(pnp.flood.,$cid,.,$chan)
  hdel -w %hash kicked.*
  if ($hget(%hash,didstrict)) return
  ; Wait for MODE reply if we get opped when there's no mode during join or no key with +k (as mirc will issue a MODE now)
  if ($event == OP) {
    if (((k isincs $gettok($chan($chan).mode,1,32)) && ($chan($chan).key == $null)) || (($chan($chan).mode == $null) && ($hget(pnp. $+ $cid,-joining. $+ $chan)))) {
      hadd %hash strictmodewait 1
      return
    }
  }
  _dostrict $chan
}

; (does all 3 strict modes- "if none", "when opped", "always enforce")
alias -l _dostrict {
  hadd -u10 $+(pnp.flood.,$cid,.,$1) didstrict 1
  var %strict = $_getsm($1)
  if ($chan($1).mode == $null) {
    var %enforce = $gettok(%strict,4,44)
    if ((%enforce != +) && (%enforce != $null)) var %junk = $_enforcemode($1,%enforce,$null,1)
  }
  var %enforce = $gettok(%strict,3,44)
  if ((%enforce != +) && (%enforce != $null)) var %junk = $_enforcemode($1,%enforce,$_chmode($1),1)
  var %enforce = $gettok(%strict,2,44)
  if ((%enforce != +) && (%enforce != $null)) var %junk = $_enforcemode($1,%enforce,$_chmode($1),1)
  if (($gettok(%strict,1,44) isnum 1-2) || ($chan($1).topic == $null)) if ($_getst($1)) _linedance .raw topic $1 : $+ $msg.compile($ifmatch,&chan&,$1)
}

; (does all 3 strict modes- end of names from join)
raw 366:*:{
  if (($me isop $2) && ($nick($2,0) == 1) && ($hget(pnp. $+ $cid,-joining. $+ $2))) {
    _dostrict $2
  }
}

; For waiting for mode reply when you get opped before receiving mode reply or with +k and no key (undernet)
raw 324:*:{
  var %hash = $+(pnp.flood.,$cid,.,$2)
  if ($hget(%hash,strictmodewait)) {
    hdel %hash strictmodewait
    if ($hget(%hash,didstrict)) return
    _dostrict $2
  }
}

; bans (just an alias for ban)
alias bans ban $1-

; ban [-u#] [#chan] [who[ who][,who]] [n]
alias ban _ssplit ban /ban $1- | if (%.targ.ban == $null) mode %.chan.ban b | elseif ($gettok(%.msg.ban,$numtok(%.msg.ban,32),32) isnum) _ban² %.opt.ban %.chan.ban $ifmatch %.targ.ban $remtok(%.msg.ban,$ifmatch,32) | else _ban² %.opt.ban %.chan.ban 3 %.targ.ban %.msg.ban
alias _ban² _ban³ $1-3 $_c2s($4-)
alias _ban³ {
  _operr $2 ban
  ; Must nick complete OUTSIDE loop
  var %total,%ban,%ban2,%usebot = %.usebot,%bans = $_nccs(32,$2,$4-),%num = 1
  _init.mass $2
  :loopB
  %ban = $gettok(%bans,%num,32)
  if (%ban) {
    %ban2 = $_ppmask(%ban,$_stmask($3,$2))
    if (%ban2) {
      if (%usebot) $ifmatch ! $2 ban %ban2
      else _add.mass $2 + b %ban2
      %total = %total %ban2
    }
    else {
      disprc $2 Looking up address of $:t(%ban) for ban...
      _notconnected
      _Q.userhost ban $+ $1 $+  $+ $2 $+ &n!&a $+ $3 disprc $+ $2 $+ User $+ $:t(%ban) $+ notfound %ban
    }
    inc %num | goto loopB
  }
  if ((-u* iswm $1) && ($remove($1,-u) isnum) && (%total != $null)) {
    if ($numtok(%total,32) > 1) .timer 1 $remove($1,-u) .unban $2 %total
    else .timer.unban. $+ $cid $+ . $+ $replace(%total,*,`,?,') 1 $remove($1,-u) .unban $2 %total
  }
}

; reban [-u#] [#chan] [num[-num]]
alias reban {
  _ssplit ban /reban $1-
  if (%.targ.ban == $null) set -u %.targ.ban 1
  if ($gettok($hget($+(pnp.flood.,$cid,.,%.chan.ban),lastunban),%.targ.ban,32) == $null) _error No matching recent unban $+ $chr(40) $+ s $+ $chr(41) in %.chan.ban $+ !Use /ban to ban or view the banlist.
  ban %.opt.ban %.chan.ban $gettok($hget($+(pnp.flood.,$cid,.,%.chan.ban),lastunban),%.targ.ban,32)
}

; banlast [-u#] [#chan] [num[-num]]
alias banlast {
  _ssplit ban /banlast $1-
  if (%.targ.ban == $null) set -u %.targ.ban 1
  if ($gettok($hget($+(pnp.flood.,$cid,.,%.chan.ban),lastleave),%.targ.ban,32) == $null) _error No matching recent parting user $+ $chr(40) $+ s $+ $chr(41) found!Use /ban to ban or view the banlist.
  ban %.opt.ban %.chan.ban $gettok($hget($+(pnp.flood.,$cid,.,%.chan.ban),lastleave),%.targ.ban,32)
}

; unban [-s] [#chan] [who|num[-num] ...]
alias unban {
  _ssplit ban /unban $1-
  var %targets = %.targ.ban %.msg.ban
  if (%.targ.ban == $null) %targets = 1
  ; Replace numbers/ranges with recent bans
  var %tok = 1
  while ($gettok(%targets,%tok,32)) {
    var %item = $ifmatch
    if ((%item isnum) || (($gettok(%item,1,45) isnum) && ($gettok(%item,2,45) isnum) && ($gettok(%item,3,45) == $null))) {
      %item = $gettok($hget($+(pnp.flood.,$cid,.,%.chan.ban),lastban),%item,32)
      if (%item == $null) _error No matching recent ban $+ $chr(40) $+ s $+ $chr(41) in %.chan.ban $+ !Specify a user to unban or use /ban to view the banlist.
      %targets = $puttok(%targets,%item,%tok,32)
    }
    inc %tok
  }
  _unban² %.opt.ban %.chan.ban %targets
}
alias _unban² _unban³ $1-2 $_c2s($3-)
alias _unban³ {
  _operr $2 unban
  if ($1 == -s) {
    var %hash = $+(pnp.scanunban.,$cid,.,$chan)
    if ($hget(%hash)) hdel -w %hash *
    else hmake %hash 20
    if ($hget($+(pnp.scanfound.,$cid,.,$chan))) hfree $+(pnp.scanfound.,$cid,.,$chan)
    hadd %hash miss 0
  }
  else _init.mass $2
  var %ban,%num = 1
  :loopB
  %ban = $gettok($3-,%num,32)
  if (%ban) {
    if (%.usebot) $ifmatch ! $2 unban %ban
    elseif ($1 == -s) {
      if (($_ismask(%ban)) || (! isin %ban) || (@ isin %ban) || (. isin %ban)) hadd %hash %ban 1
      elseif ($address(%ban,5)) hadd %hash $ifmatch 1
      else {
        hinc %hash miss
        disprc $2 Looking up address of $:t(%ban) for unban...
        _notconnected
        _Q.userhost _scanu2&n!&a $+ $2 _scanu2 $+ %ban $+  $+ $2 %ban
      }
    }
    else _add.mass $2 - b $_fixmask(%ban)
    inc %num | goto loopB
  }
  if (($1 == -s) && ($hget(%hash,miss) == 0)) _scanu3 $2
}
alias _scanu2 {
  var %hash = $+(pnp.scanunban.,$cid,.,$2)
  if (! isin $1) hadd %hash $1 1
  else disprc $2 User $:t($1) not found
  hdec %hash miss
  if ($hget(%hash,miss) < 1) _scanu3 $2
}
alias _scanu3 {
  var %hash = $+(pnp.scanunban.,$cid,.,$1)
  var %hashhit = $+(pnp.scanfound.,$cid,.,$1)
  hdel %hash miss
  if ($hget(%hash,0).item == 0) {
    hfree %hash
    disprc $1 No one to unban!
  }
  elseif ($chan($1).ibl == $true) {
    disprc $1 Scanning internal banlist to find matching bans...
    var %pos = $ibl($1,0)
    hmake %hashhit 20
    while (%pos > 0) {
      var %ban = $ibl($1,%pos)
      var %num = $hget(%hash,0).item
      while (%num > 0) {
        var %item = $hget(%hash,%num).item
        if ((%item iswm %ban) || (%ban iswm %item)) {
          hadd %hashhit %ban 1
          break
        }
        dec %num
      }
      dec %pos
    }
    _scanu4 $1
  }
  else {
    disprc $1 Retrieving banlist to find matching bans...
    hmake %hashhit 20
    .raw mode $1 b
  }
}
alias _scanu4 {
  var %hash = $+(pnp.scanunban.,$cid,.,$1)
  var %hashhit = $+(pnp.scanfound.,$cid,.,$1)
  if ($hget(%hashhit,0).item == $null) disprc $1 No matching bans found.
  else {
    _init.mass $1
    var %num = $hget(%hashhit,0).item
    disprc $1 Unbanned $:t(%num) matching bans.
    while (%num > 0) {
      _add.mass $1 - b $hget(%hashhit,%num).item
      dec %num
    }
  }
  hfree %hash
  hfree %hashhit
}

; kick [#chan] who[,who]|mask [comment]
alias k kick $1-
alias kick {
  if ($1 == $null) _qhelp /kick | _split k /kick $1- | if (%.targ.k == $null) _qhelp /kick $1-
  if ($_ismask(%.targ.k)) fk $1-
  else {
    _operr %.chan.k kick
    var %who,%chan = %.chan.k,%targ = %.targ.k,%msg = %.msg.k,%num = 1,%usebot = %.usebot
    _flush.mass %.chan.k
    :loop
    if ($gettok(%targ,%num,44)) {
      %who = $_ncc($gettok($ifmatch,1,33),%chan)
      %who = %who $msg.compile($_msgwrap(kwrap,kick,%msg),&chan&,%chan,&nick&,%who,&kickseq&,%num)
      if (%usebot) $ifmatch ! %chan kick %who
      else _kick %chan %who
      inc %num | goto loop
    }
    if ((%msg) && (%.punishwait == $null)) _recent2 kick 9 %msg
  }
}

; fk [-qohvru] [#chan] mask [comment]
; -qohvr = only kick owners, ops, helps, vocs, regs; -u = don't kick known users
alias fknop fk -vr $1-
alias fk {
  if ($1 == $null) _qhelp /fk | _ssplit k /fk $1- | if (%.targ.k == $null) _qhelp /fk $1-
  _operr %.chan.k kick
  if ($ial == $false) _error The IAL is not enabled!You need the IAL for that command.
  if ($chan(%.chan.k).inwho) $_doerror(Please wait-,The IAL is not fully updated.Wait a few seconds and try again.)
  if ($chan(%.chan.k).ial == $false) _error The channel IAL has not been filled.You need IAL filling enabled for that command.
  if ($_ppmask(%.targ.k,$_stmask(2,%.chan.k))) %.targ.k = $ifmatch
  else %.targ.k = %.targ.k $+ !*@*
  _flush.mass %.chan.k
  var %nick,%count = 1,%num = 1
  ; .opt.k needs a counterpart for scanning $nick()- ie if options are -vr then we need the opposite -qoh to 'exclude'
  var %optexclude = $iif(q isin %.opt.k,-,$iif(o isin %.opt.k,q,$iif(h isin %.opt.k,qo,$iif(v isin %.opt.k,qoh,$iif(r isin %.opt.k,qohv,-)))))
  :loop
  %nick = $ialchan(%.targ.k,%.chan.k,%num).nick
  if (%nick) {
    if ((u isin %.opt.k) && (($notify(%nick) != $null) || (($level($address(%nick,5)) > 1) && ($istok($level($address(%nick,5)),=black,44) == $false)))) { inc %num | goto loop }
    if (-?* iswm $remove(%.opt.k,u)) {
      if ($nick(%.chan.k,%nick,%.opt.k,%optexclude) == $null) { inc %num | goto loop }
    }
    if (%nick != $me) {
      %nick = $ifmatch $msg.compile($_msgwrap(kwrap,kick,%.msg.k),&chan&,%.chan.k,&nick&,$ifmatch,&kickseq&,%count,&mask&,%.targ.k)
      inc %count
      if (%.usebot) $ifmatch ! %.chan.k kick %nick
      else _kick %.chan.k %nick
    }
    inc %num | goto loop
  }
  if ((%.msg.k) && (%.punishwait == $null)) _recent2 kick 9 %.msg.k
  if (%num == 1) disprc %.chan.k No matching users found. $chr(40) $+ mask- %.targ.k $+ $chr(41)
}

; tempban [-u#] [#chan] who|mask[,who|mask] [n] [comment]
alias tempban {
  if (-u* iswm $1) _kb² 0 /tempban $1-
  else _kb² 0 /tempban -u $1-
}

dialog tempban {
  title "Tempban"
  icon script\pnp.ico
  option map
  size -1 -1 233 73

  text "&Reason for tempban?", 203, 9 6 220 12
  combo 1, 6 18 220 98, drop result edit

  text "&Tempban for:", 2, 9 36 46 12, right
  edit "", 3, 58 34 26 13
  text "seconds", 4, 86 36 133 12
  ; (time multiplier- 1 or 60)
  edit "1", 50, 1 1 1 1, hide autohs

  button "OK", 101, 20 52 53 14, OK default
  button "Cancel", 102, 93 52 53 14, cancel
  button "&Clear list", 103, 180 54 46 12, disable
}
on *:DIALOG:tempban:init:*:{
  did -a $dname 3 $calc(%.time)
  if (*m iswm %.time) {
    did -a $dname 4 minutes
    did -ra $dname 50 60
  }
  _fillrec $dname 1 103 $_cfg(kick.lis) 0 $_msg(kick)
  unset %.time
}
on *:DIALOG:tempban:sclick:101:{
  %.time = $did(50) * $did(3)
  if (%.time isnum) set -u1 %.time -u $+ %.time
  else unset %.time
}
on *:DIALOG:tempban:sclick:103:{
  did -b $dname 103
  .remove $_cfg(kick.lis)
  :loop | if ($did(1,1) != $null) { did -d $dname 1 1 | goto loop }
}

; kb/kb0/kb2/cb [-u[#]] [#chan] who|mask[,who|mask] [n] [comment]
; -u without # uses default tempban time
alias bk kb $1-
alias kb _kb² 3 /kb $1-
alias bk0 kb0 $1-
alias kb0 _kb² 2 /kb0 $1-
alias bk2 kb2 $1-
alias kb2 _kb² 4 /kb2 $1-
alias bc cb $1-
alias cb _kb² -1 /cb $1-
alias _kb² {
  if ($3 == $null) _qhelp $2
  _ssplit k $2 $3-
  if (%.targ.k == $null) _qhelp $iif($2 == /tempban,$deltok($2-,2,32),$2-)
  if ((-u* iswm %.opt.k) && ($remove(%.opt.k,-u) !isnum)) %.opt.k = -u $+ $_getchopt(%.chan.k,1)
  ; Passed a 0 for default bantype ($1) means use default tempban type
  _kb³ %.opt.k %.chan.k %.targ.k $iif($gettok(%.msg.k,1,32) !isnum,$iif($1 == 0,$_getchopt(%.chan.k,2),$1)) %.msg.k
}
alias _kb³ {
  _operr $2 ban
  var %targ.ban,%targ.kick,%who,%mask,%mask2,%num2,%wrap,%dur,%usebot = %.usebot,%num = $numtok($3,44)
  :loop1
  %who = $_ncc($gettok($3,%num,44),$2)
  if ($4 >= 0) %mask = $_ppmask(%who,$_stmask($4,$2))
  else {
    %mask = $_ppmask(%who,0,0,1)
    %mask2 = $_ppmask(%who,$_stmask(3,$2))
    if ($ialchan(%mask,$2,0) == $ialchan(%mask2,$2,0)) %mask = %mask2
  }
  if (%mask == $null) {
    if ($_ismask(%who)) {
      if ($ial == $false) _error The IAL is not enabled!You need the IAL for that command.
      if ($chan($2).inwho) $_doerror(Please wait-,The IAL is not fully updated.Wait a few seconds and try again.)
      if ($chan($2).ial == $false) _error The channel IAL has not been filled.You need IAL filling enabled for that command.
    }
    else {
      disprc $2 Looking up address of $:t(%who) for ban...
      _notconnected
      _Q.userhost kb $+ $1 $+  $+ $2 $+ &n!&a $+ $_s2p($4-) disprc $+ $2 $+ User $+ $:t(%who) $+ notfound %who
    }
  }
  else {
    %targ.ban = $addtok(%targ.ban,%mask,32)
    if (%usebot) $ifmatch ! $2 ban %mask $msg.compile($_msgwrap(kwrap,kick,$5-),&chan&,$2,&nick&,%who,&kickseq&,%num)
    else {
      ; After a userhost (exact addr given) we kick that user exactly
      if ((*!* iswm $gettok($3,%num,44)) && (* !isin $gettok($3,%num,44)) && (? !isin $gettok($3,%num,44))) {
        %targ.ban = $addtok(%targ.ban,%mask,32)
        %targ.kick = $addtok(%targ.kick,$gettok($gettok($3,%num,44),1,33),32)
      }
      else {
        if (%who == $me) %targ.kick = $addtok(%targ.kick,%who,32)
        %num2 = $ialchan(%mask,$2,0)
        :loopC
        if (%num2 >= 1) {
          if ($ialchan(%mask,$2,%num2).nick != $me) %targ.kick = $addtok(%targ.kick,$ifmatch,32)
          if (%num2 > 1) { dec %num2 | goto loopC }
        }
      }
    }
  }
  if (%num > 1) { dec %num | goto loop1 }
  if (%usebot) goto botdone
  _init.mass $2
  %num = $numtok(%targ.kick,32)
  :loopD
  if ($gettok(%targ.kick,%num,32) isop $2) _add.mass $2 - o $ifmatch
  if ($gettok(%targ.kick,%num,32) ishop $2) _add.mass $2 - h $ifmatch
  if (%num > 1) { dec %num | goto loopD }
  %num = $numtok(%targ.ban,32)
  :loopB
  if (%num >= 1) {
    _add.mass $2 + b $gettok(%targ.ban,%num,32)
    if (%num > 1) { dec %num | goto loopB }
  }
  _flush.mass $2
  %num = 1
  if ((-u* iswm $1) && ($remove($1,-u) isnum) && (%targ.ban != $null)) { %wrap = tbwrap | %dur = $gettok($_dur($remove($1,-u)),1-2,32) }
  else %wrap = kwrap
  :loopK
  if ($gettok(%targ.kick,%num,32) ison $2) _kick $2 $ifmatch $msg.compile($_msgwrap(%wrap,kick,$5-),&chan&,$2,&nick&,$ifmatch,&kickseq&,%num,&dur&,%dur)
  if (%num < $numtok(%targ.kick,32)) { inc %num | goto loopK }
  if (%wrap = tbwrap) {
    if ($numtok(%targ.ban,32) > 1) .timer 1 $remove($1,-u) .unban $2 %targ.ban
    else .timer.unban. $+ $cid $+ . $+ $replace(%targ.ban,*,`,?,') 1 $remove($1,-u) .unban $2 %targ.ban
  }
  :botdone
  if (($5) && (%.punishwait == $null)) _recent2 kick 9 $5-
}

; unop [#chan] who[ who][,who]|mask - deop AND/OR dehop as needed
alias unop {
  if ($1 == $null) _qhelp /unop | _simsplit o /unop $1- | if (%.msg.o == $null) _qhelp /unop $1-
  if ($_ismask(%.msg.o)) funop $1-
  else {
    _operr %.chan.o deop
    ; Have to do nick completion OUTSIDE of loop
    var %chan = %.chan.o,%num = 1,%usebot = %.usebot,%who = $_nccs(32,%.chan.o,$_c2s(%.msg.o))
    if (%usebot) $ifmatch ! %chan deop %who
    else {
      _init.mass %.chan.o
      :loop
      if ($gettok(%who,%num,32)) {
        var %nick = $ifmatch
        if (%nick ishop %.chan.o) _add.mass %.chan.o - h $ifmatch
        if (%nick isop %.chan.o) _add.mass %.chan.o - o $ifmatch
        inc %num
        goto loop
      }
    }
  }
}

; op/deop/hfop/dehfop/voc/devoc [#chan] who[ who][,who]|mask
alias opme op $1- $me
alias op _op² /op fop op + o $1-
alias deop _op² /deop fdeop deop - o $1-
alias dop deop $1-
alias hfop _op² /hfop fhfop halfop + h $1-
alias halfop hfop $1-
alias dehfop _op² /dehfop fdehfop dehalfop - h $1-
alias dhfop dehfop $1-
alias dehalfop dehfop $1-
alias voc _op² /voc fvoc voice + v $1-
alias voice voc $1-
alias devoc _op² /devoc fdevoc devoice - v $1-
alias dvoc devoc $1-
alias devoice devoice $1-
; _op² /cmd filtercmd botcommand -|+ modechar [chan] who
alias _op² {
  if ($6 == $null) _qhelp $1 | _simsplit o $1 $6- | if (%.msg.o == $null) _qhelp $1 $6-
  if ($_ismask(%.msg.o)) $2 $6-
  else {
    if ((%.msg.o == $me) && ($1 == /op)) _operr %.chan.o opme
    else _operr %.chan.o $3
    ; Have to do nick completion OUTSIDE of loop
    var %chan = %.chan.o,%num = 1,%usebot = %.usebot,%who = $_nccs(32,%.chan.o,$_c2s(%.msg.o))
    if (%usebot) $ifmatch ! %chan $3 %who
    else {
      _init.mass %.chan.o
      :loop
      if ($gettok(%who,%num,32)) { _add.mass %.chan.o $4-5 $ifmatch | inc %num | goto loop }
    }
  }
}

; funop [#chan] who|mask - deop AND/OR dehop as needed
alias funop _fop² /funop deop - oh oh q $1-

; fop/fdeop/fhfop/fdehfop/fvoc/fdevoc [#chan] who|mask
alias fop _fop² /fop op + o rvh oq $1-
alias fdop fdeop $1-
alias fdeop _fop² /fdeop deop - o o q $1-
alias fhfop _fop² /fhfop halfop + h rv hoq $1-
alias fdhfop fdehfop $1-
alias fdehfop _fop² /fdehfop dehalfop - h h oq $1-
alias fvoc _fop² /fvoc voice + v r vhoq $1-
alias fdvoc fdevoc $1-
alias fdevoc _fop² /fdevoc devoice - v v hoq $1-
; _fop² /cmd botcommand -|+ modechar allow disalllow [chan] who
alias _fop² {
  if ($7 == $null) _qhelp $1 | _split o $1 $7- | if (%.targ.o == $null) _qhelp $1 $7-
  if ($ial == $false) _error The IAL is not enabled!You need the IAL for that command.
  if ($chan(%.chan.o).inwho) $_doerror(Please wait-,The IAL is not fully updated.Wait a few seconds and try again.)
  if ($chan(%.chan.o).ial == $false) _error The channel IAL has not been filled.You need IAL filling enabled for that command.
  _operr %.chan.o $2
  %.targ.o = $_ppmask(%.targ.o,0,2,$_getchopt(%.chan.o,4))
  var %total,%num = $ialchan(%.targ.o,%.chan.o,0)
  if (%.usebot) {
    :loop1
    var %nick = $ialchan(%.targ.o,%.chan.o,%num).nick
    if (($nick(%.chan.o,%nick,$5,$6)) && (%nick != $me)) %total = %total %nick
    if (%num > 1) { dec %num | goto loop1 }
    if (%total == $null) { disprc %.chan.o No matching users found. $chr(40) $+ mask- %.targ.o $+ $chr(41) | return }
    %.usebot ! %.chan.o $2 %total
  }
  else {
    _init.mass %.chan.o
    :loop2
    var %nick = $ialchan(%.targ.o,%.chan.o,%num).nick
    if (($nick(%.chan.o,%nick,$5,$6)) && (%nick != $me)) {
      %total = 1
      if ($3-4 == - oh) {
        if (%nick ishop %.chan.o) _add.mass %.chan.o - h %nick
        if (%nick isop %.chan.o) _add.mass %.chan.o - o %nick
      }
      else _add.mass %.chan.o $3-4 %nick
    }
    if (%num > 1) { dec %num | goto loop2 }
    if (%total == $null) { disprc %.chan.o No matching users found. $chr(40) $+ mask- %.targ.o $+ $chr(41) | return }
  }
}

; topic [#chan] [topic]
alias topic {
  _simsplit t /topic $1-
  if (%.msg.t) {
    _operr %.chan.t topic
    if (%.usebot) $ifmatch ! %.chan.t topic %.msg.t
    else .raw topic %.chan.t : $+ %.msg.t
  }
  else {
    .raw topic %.chan.t
    disprc %.chan.t Requesting topic...
  }
}

; etopic [#chan] [topic]
alias etopic _simsplit t /etopic $1- | topic %.chan.t $_rentry(topic,%.chan.t,$_s2p($iif(%.msg.t,%.msg.t,$chan(%.chan.t).topic)),New topic for %.chan.t $+ ?)

; rtopic [#chan]
alias rtopic _simsplit t /rtopic $1- | topic %.chan.t $iif(%.msg.t,%.msg.t,$chan(%.chan.t).topic)

; atopic [#chan]
alias atopic _simsplit t /atopic $1- | var %chan = %.chan.t | if (%.msg.t == $null) set -u %.msg.t $_entry(0,$null,Add what to topic? $chr(40) $+ no separator needed $+ $chr(41)) | topic %chan $chan(%chan).topic $iif($chan(%chan).topic != $null,$_cfgi(topic.sep)) %.msg.t

; mtn [#chan]
alias mtn _simsplit m /mtn $1- | var %old = $gettok($chan(%.chan.m).mode,1,32) | if (%old != $null) var %old = $remove(%old,+,n,t) | if (%old != $null) %old = - $+ %old | mode %.chan.m %old $+ +tn $chan(%.chan.m).key

; _mtog #chan mode
alias _mtog mode $1 $iif($2 isincs $gettok($chan($1).mode,1,32),-,+) $+ $2

; mode [#chan] [modes]
alias mode {
  if ($1 == $me) { umode $2- | return }
  _simsplit m /mode $1-
  if (%.msg.m) {
    if ($remove(%.msg.m,-,+) === b) {
      if ($chan(%.chan.m).ibl == $true) {
        _iblbanlist %.chan.m
      }
      else {
        .raw mode %.chan.m b
        disprc %.chan.m Requesting channel banlist...
      }
    }
    else {
      _operr %.chan.m mode 1
      if (%.usebot) $ifmatch ! %.chan.m mode %.msg.m
      else .raw mode %.chan.m %.msg.m
    }
  }
  else {
    .raw mode %.chan.m
    disprc %.chan.m Requesting channel modes...
  }
}

; Splitting for command parameters
alias _ssplit if (-* iswm $3) { set -u %.opt. [ $+ [ $1 ] ] $3 | _split $1-2 $4- } | else { set -u %.opt. [ $+ [ $1 ] ] - | _split $1- }
alias _simsplit {
  if ($left($3,1) isin $remove(& $+ $chantypes,+,-)) { set -u %.chan. [ $+ [ $1 ] ] $3 | set -u %.msg. [ $+ [ $1 ] ] $4- }
  elseif ($chan ischan) { set -u %.chan. [ $+ [ $1 ] ] $chan | set -u %.msg. [ $+ [ $1 ] ] $3- }
  elseif ($active ischan) { set -u %.chan. [ $+ [ $1 ] ] $active | set -u %.msg. [ $+ [ $1 ] ] $3- }
  else _error You must use $2 in a channel $+ $chr(40) $+ or specify a target channel $+ $chr(41)
}
alias _split {
  if ($left($3,1) isin $remove(& $+ $chantypes,+,-)) { set -u %.chan. [ $+ [ $1 ] ] $3 | set -u %.targ. [ $+ [ $1 ] ] $4 | set -u %.msg. [ $+ [ $1 ] ] $5- }
  elseif ($chan ischan) { set -u %.chan. [ $+ [ $1 ] ] $chan | set -u %.targ. [ $+ [ $1 ] ] $3 | set -u %.msg. [ $+ [ $1 ] ] $4- }
  elseif ($active ischan) { set -u %.chan. [ $+ [ $1 ] ] $active | set -u %.targ. [ $+ [ $1 ] ] $3 | set -u %.msg. [ $+ [ $1 ] ] $4- }
  else _error You must use $2 in a channel $+ $chr(40) $+ or specify a target channel $+ $chr(41)
}
; Ops check and error message
; /_operr #chan type [skiperror]
; type is used for bot checks (use - for no check)
; skiperror = no error if no bot found
alias _operr {
  unset %.usebot
  if (($2 == topic) && (t !isin $gettok($chan($1).mode,1,32))) return
  if (($me !isop $1) && ($me !ishop $1) && (o !isin $usermode)) {
    if (($2 != -) && ($hget(pnp,addon.i.bot))) {
      var %num = $numtok($ifmatch,44)
      :loop
      $gettok($hget(pnp,addon.i.bot),%num,44) ? $1 $2
      if ($result) { set -u %.usebot $gettok($hget(pnp,addon.i.bot),%num,44) | return }
      if (%num > 1) { dec %num | goto loop }
    }
    if (($_getchopt($1,5)) && (!$3)) {
      if ($me ison $1) _error You are not opped on $1 $+ ! $+ $chr(40) $+ you must have ops for that command $+ $chr(41)
      else _error You are not on $1 $+ ! $+ $chr(40) $+ You must be on a channel and opped for that command $+ $chr(41)
    }
  }
}

; mass mode aliases; work as groups and from routine to routine, even if the target channel changes
; call before a massmode set (if you specify $2 it is the amount of seconds to delay)
alias _init.mass {
  .timer.massmode. $+ $cid $+ . $+ $1 1 $iif($2 isnum,$2,0) _flush.mass $1
}
; call to add to the modes- /_add.mass chan +|- o|v|b|etc [target]
; can specify a chunk of modes w/targets but not gaurunteed to work properly at all times
alias _add.mass {
  var %hash = $+(pnp.flood.,$cid,.,$1)
  if ((m !isin $hget(pnp. $+ $cid,-feat)) && ($3 isincs ovh)) {
    if (($hget(%hash,mass.ovh) != $null) && ($hget(%hash,mass.ovh) !=== $3)) _flush.mass $1
    hadd %hash mass.ovh $3
  }
  hadd %hash mass.modes $hget(%hash,mass.modes) $+ $2 $+ $3
  hadd %hash mass.who $hget(%hash,mass.who) $4-
  if ($numtok($hget(%hash,mass.who),32) >= $hget(pnp. $+ $cid,-modes)) _flush.mass $1
}
; finished
alias _flush.mass {
  var %hash = $+(pnp.flood.,$cid,.,$1)
  if ($hget(%hash,mass.modes)) {
    .raw mode $1 $ifmatch $hget(%hash,mass.who)
    hdel -w %hash mass.*
  }
}

;
; Recent topic remember, strict topic
;
on *:TOPIC:#:{
  if ($1) _recent2 topic 15 $replace($1-,$chan,&chan&)
  if (($nick == $me) || (($me !isop $chan) && ($me !ishop $chan)) || ($_level($chan,$level($fulladdress)) >= 25)) return
  var %enforce = $gettok($_getsm($chan),1,44)
  if ((%enforce == 1) && ($_getst($chan))) {
    var %topic = $msg.compile($ifmatch,&chan&,$chan)
    if (%topic != $1-) {
      _linedance .raw topic $chan : $+ %topic
      hinc -u20 $+(pnp.flood.,$cid,.,$chan) stricttopic
      if ($hget($+(pnp.flood.,$cid,.,$chan),stricttopic) > 2) {
        if ($nick isop $chan) .deop $chan $nick
        elseif ($nick ishop $chan) .dehop $chan $nick
        if (t !isin $chan($chan).mode) { _init.mass $chan | _add.mass $chan + t }
      }
    }
  }
}
raw 332:*:_recent2 topic 15 $replace($3-,$2,&chan&)

;
; Track recent kick/parts and ban/unbans, cancel unban timers, rejoin for ops
;
on *:KICK:#:{
  hadd $+(pnp.flood.,$cid,.,$chan) lastleave $address($knick,5) $gettok($hget($+(pnp.flood.,$cid,.,$chan),lastleave),1-9,32)
  if (($knick != $me) && ($_getchopt($chan,15)) && ($nick($chan,0) == 2) && ($me !isop $chan)) hop -cn $chan
}
on !*:PART:#:{
  hadd $+(pnp.flood.,$cid,.,$chan) lastleave $fulladdress $gettok($hget($+(pnp.flood.,$cid,.,$chan),lastleave),1-9,32)
  if (($_getchopt($chan,15)) && ($nick($chan,0) == 2) && ($me !isop $chan)) hop -cn $chan
}
on *:QUIT:{
  var %num = $comchan($nick,0)
  while (%num) {
    hadd $+(pnp.flood.,$cid,.,$comchan($nick,%num)) lastleave $fulladdress $gettok($hget($+(pnp.flood.,$cid,.,$comchan($nick,%num)),lastleave),1-9,32)
    if (($_getchopt($comchan($nick,%num),15)) && ($nick($comchan($nick,%num),0) == 2) && ($me !isop $comchan($nick,%num))) hop -cn $comchan($nick,%num)
    dec %num
  }
}
on *:BAN:#:{
  hadd $+(pnp.flood.,$cid,.,$chan) lastban $banmask $gettok($hget($+(pnp.flood.,$cid,.,$chan),lastban),1-9,32)
  if ($nick != $me) .timer.unban. $+ $cid $+ . $+ $replace($banmask,*,`,?,') off
}
on *:UNBAN:#:{
  hadd $+(pnp.flood.,$cid,.,$chan) lastunban $banmask $gettok($hget($+(pnp.flood.,$cid,.,$chan),lastunban),1-9,32)
  .timer.unban. $+ $cid $+ . $+ $replace($banmask,*,`,?,') off
}

;
; Nicklist popups
;
alias _banpop {
  if ($snick(#,1)) {
    if ($address($snick(#,1),5)) {
      set -u1 %.ban2 $_ppmask($snick(#,1),0,$_getchopt(#,3),2)
      if ($_ppmask($snick(#,1),0,$_getchopt(#,3),4) != %.ban2) set -u1 %.ban3 $ifmatch
      else unset %.ban3
      set -u1 %.ban4 $_ppmask($snick(#,1),0,$_getchopt(#,3),3)
      if ((%.ban4 == %.ban2) || (%.ban4 == %.ban3)) unset %.ban4
      set -u1 %.ban5 $_ppmask($snick(#,1),0,$_getchopt(#,3),6)
      if ((%.ban5 == %.ban2) || (%.ban5 == %.ban3) || (%.ban5 == %.ban4)) unset %.ban5
      set -u1 %.banD $_ppmask($snick(#,1),$_stmask(4,#))
      if ($_ppmask($snick(#,1),$_stmask(2,#)) != %.banD) set -u1 %.banS $ifmatch
      else unset %.banS
      set -u1 %.banN $snick(#,1) $+ !*@*
    }
    else {
      set -u1 %.ban2 Standard $chr(40) $+ *!ident@*.domain.com $+ $chr(41)
      set -u1 %.banD Full domain $chr(40) $+ *!*@*.domain.com $+ $chr(41)
      set -u1 %.banS Site $chr(40) $+ *!*@site.domain.com $+ $chr(41)
      set -u1 %.banN Nickname $chr(40) $+ nick!*@* $+ $chr(41)
      unset %.ban3 %.ban4 %.ban5
    }
  }
}
alias _nurple var %num = $snick($1,0) | :loop | if (%num > 0) { $reptok($2-,**,$snick($1,%num),1,32) | dec %num | goto loop }

;
; Stricts
;
; (lock topic)
alias ltopic {
  _simsplit t /ltopic $1-
  if ((%.msg.t != $null) || ($chan(%.chan.t).topic)) {
    `set stricttopic. $+ %.chan.t $ifmatch
    var %old = $hget(pnp.config,stricts. $+ %.chan.t)
    if (%old == $null) %old = $hget(pnp.config,stricts)
    `set stricts. $+ %.chan.t $puttok(%old,1,1,44)
    if ((%.msg.t != $chan(%.chan.t).topic) && ($me isop %.chan.t)) topic %.chan.t %.msg.t
    disprc %.chan.t Topic locked as $:q($hget(pnp.config,stricttopic. $+ %.chan.t)) $+ .
  }
  else disprc %.chan.t No topic to save- set a topic $+ $chr(44) then try again.
}
; (unlock topic)
alias utopic {
  _simsplit t /utopic $1-
  var %old = $hget(pnp.config,stricts. $+ %.chan.t)
  if ($gettok(%old,1,44) isnum 1-2) {
    `set stricts. $+ %.chan.t $puttok(%old,3,1,44)
    disprc %.chan.t Topic unlocked.
  }
  else disprc %.chan.t Topic not currently locked. $chr(40) $+ see popups or /strict to lock topic $+ $chr(41)
}
; (save topic)
alias stopic {
  _simsplit t /stopic $1-
  if (%.msg.t == 0) {
    `set stricttopic. $+ %.chan.t
    var %old = $hget(pnp.config,stricts. $+ %.chan.t)
    if ($gettok(%old,1,44) isnum 1-2) `set stricts. $+ %.chan.t $puttok(%old,3,1,44)
    disprc %.chan.t Topic forgotten.
  }
  elseif ((%.msg.t != $null) || ($chan(%.chan.t).topic)) {
    `set stricttopic. $+ %.chan.t $ifmatch
    disprc %.chan.t Topic saved- use popups or /otopic to restore.
  }
  else disprc %.chan.t No topic to save- set a topic $+ $chr(44) then try again.
}
; (old topic)
alias otopic {
  _simsplit t /otopic $1-
  if ($_getst(%.chan.t)) topic %.chan.t $msg.compile($ifmatch,&chan&,%.chan.t)
  else disprc %.chan.t No topic saved for channel. $chr(40) $+ see popups or /strict to set one $+ $chr(41)
}

alias strict {
  if ($_ischan($1)) set -u %.chan $1
  elseif ($active ischan) set -u %.chan $active
  _dialog -am strictm strictm
}
dialog strictm {
  title "Strict Modes / Topics"
  icon script\pnp.ico
  option map
  size -1 -1 300 153

  text "&View settings for:", 1, 4 6 86 12, right
  combo 2, 93 3 120 61, drop sort
  button "&Add...", 3, 216 3 33 12
  button "&Remove", 4, 253 3 40 12

  box "Modes:", 5, 6 24 287 60
  text "&Always enforced:", 6, 13 35 88 12, right
  text "&Always set when opped:", 7, 13 51 88 12, right
  text "&Set if none set:", 8, 13 67 88 12, right
  edit "", 9, 102 33 80 13, autohs
  edit "", 10, 102 49 80 13, autohs
  edit "", 11, 102 65 80 13, autohs
  button "Use current", 109, 200 34 73 12, disable
  button "Use current", 110, 200 50 73 12, disable
  button "Use current", 111, 200 66 73 12, disable

  box "&Topics:", 12, 6 92 287 29
  combo 13, 13 101 88 61, drop
  combo 14, 102 101 183 61, drop edit

  edit "", 15, 1 1 1 1, hide autohs

  button "Close", 100, 173 131 53 14, ok default
  button "&Help", 101, 233 131 53 14, disable
}
on *:DIALOG:strictm:init:*:{
  did -ac $dname 2 ( $+ all other channels $+ )
  window -hln @.vars
  filter -fw $_cfg(cfgvar.dat) @.vars stricts.*
  var %ln = $line(@.vars,0)
  :loop
  if (%ln) {
    var %chan = $right($gettok($line(@.vars,%ln),1,32),-8)
    did -a $+ $iif(%chan == %.chan,c) $dname 2 %chan
    dec %ln | goto loop
  }
  window -c @.vars
  loadbuf -otstrictm $dname 13 script\dlgtext.dat
  unset %.chan
  _loadsm
}
on *:DIALOG:strictm:sclick:109,110,111:did -ra $dname $calc($did - 100) $_chmode($did($dname,2).seltext)
on *:DIALOG:strictm:sclick:2:_savesm | _loadsm
on *:DIALOG:strictm:sclick:100:_savesm
alias -l _loadsm {
  did -o strictm 15 1 $did(strictm,2,$did(strictm,2).sel)
  var %chan = . $+ $did(strictm,2,$did(strictm,2).sel)
  if ($mid(%chan,2,1) == $chr(40)) {
    var %chan
    did -b strictm 4,109,110,111
  }
  else {
    did -e strictm 4
    did $iif($right(%chan,-1) ischan,-e,-b) strictm 109,110,111
  }
  var %opt = $hget(pnp.config,stricts $+ %chan)
  if (%opt == $null) %opt = 3,+,+tn,+
  if ($gettok(%opt,1,44) isnum 1-3) did -c strictm 13 $ifmatch
  else did -c strictm 13 3
  did -o strictm 9 1 $gettok(%opt,2,44)
  did -o strictm 10 1 $gettok(%opt,3,44)
  did -o strictm 11 1 $gettok(%opt,4,44)
  did -r strictm 14
  _fillrec strictm 14 0 $_cfg(topic.lis) $iif($right(%chan,-1) ischan,$ifmatch,0) $hget(pnp.config,stricttopic $+ %chan)
  if ($hget(pnp.config,stricttopic $+ %chan) == $null) did -d strictm 14 0
}
alias -l _savesm {
  var %chan = . $+ $did(strictm,15)
  if ($mid(%chan,2,1) == $chr(40)) var %chan
  var %opt = $iif($did(strictm,14) == $null,0,$did(strictm,13).sel),%num = 9
  :loop
  if ($did(strictm,%num) != $null) %opt = %opt $+ , $+ $ifmatch
  else %opt = %opt $+ ,+
  if (%num < 11) { inc %num | goto loop }
  `set stricts $+ %chan %opt
  `set stricttopic $+ %chan $did(strictm,14)
}
on *:DIALOG:strictm:sclick:3:{
  var %chan = $_rentry($chr(35),0,$active,Channel to add?)
  if ($hget(pnp.config,stricts. $+ %chan)) return
  did -ac strictm 2 %chan
  `set stricts. $+ %chan 3,+,+tn,+
  _loadsm
}
on *:DIALOG:strictm:sclick:4:{
  var %chan = . $+ $did(strictm,2,$did(strictm,2).sel)
  `set stricts $+ %chan
  `set stricttopic $+ %chan
  did -d strictm 2 $did(strictm,2).sel
  did -c strictm 2 $did(strictm,2).lines
  _loadsm
}
alias _getsm if ($hget(pnp.config,stricts. $+ $1) != $null) return $ifmatch | return $hget(pnp.config,stricts)
alias _getst if ($hget(pnp.config,stricttopic. $+ $1) != $null) return $ifmatch | return $hget(pnp.config,stricttopic)
on @!*:MODE:#:{
  if ($_level($chan,$level($fulladdress)) >= 25) return
  var %enforce = $gettok($_getsm($chan),2,44)
  if ((%enforce == +) || (%enforce == $null)) return
  if ($_enforcemode($chan,%enforce,$1-)) {
    hinc -u20 $+(pnp.flood.,$cid,.,$chan) strictmode
    if ($hget($+(pnp.flood.,$cid,.,$chan),strictmode) > 2) {
      if ($nick isop $chan) .deop $chan $nick
      elseif ($nick ishop $chan) .dehop $chan $nick
    }
  }
}
; $1 = channel $2 = modes to enforce (include key/limit)
; $3 = current modes/changes (include key/limit) $4 = assume -mode if not given in $3 (IE, current modes)
; performs enforcement, returns 1 if any enforcement made
;;; change the following aliases to use $chanmodes.
alias _enforcemode {
  var %enforce = $_fixmode($gettok($2,1,32)),%change = $replace($_fixmode($gettok($3,1,32)),+,/,-,+,/,-),%num = 1,%revert
  if ($3 == $null) var %change
  :loop
  var %bit = $mid(%enforce,%num,2)
  if (%bit isincs %change) %revert = %revert $+ %bit
  elseif (($4) && (+? iswm %bit) && ($right(%bit,1) !isincs %change)) %revert = %revert $+ %bit
  inc %num 2
  if (%num < $len(%enforce)) goto loop
  ; -k here (and -l below) are really +k/+l (as we swapped them)
  if ((+k isincs %enforce) && (-k isincs %change)) {
    var %oldkey = $_whichkey($3),%forcekey = $_whichkey($2)
    if (%oldkey !=== %forcekey) {
      .raw mode $1 -k %oldkey
      %revert = %revert $+ +k
    }
  }
  if ((+l isincs %enforce) && (-l isincs %change)) {
    if ($_whichlimit($3) != $_whichlimit($2)) %revert = %revert $+ +l
  }
  elseif (+l isincs %revert) %revert = $removecs(%revert,+l) $+ +l
  if (+k isincs %revert) %revert = %revert $_whichkey($2)
  elseif (-k isincs %revert) %revert = %revert $_whichkey($3)
  if (+l isincs %revert) %revert = %revert $_whichlimit($2)
  if (%revert) {
    _init.mass $1
    _add.mass $1 $left(%revert,1) $right(%revert,-1)
    return 1
  }
  return 0
}
; reduces a set of modes to only those that take params
alias _parammodes {
  var %set = $_fixmode($1),%num = 1
  :loop
  if ($mid(%set,%num,2) !isincs +b-b+o-o+h-h+v-v+I-I+e-e+l+k-k) %set = $removecs(%set,$ifmatch)
  else inc %num 2
  if (%num < $len(%set)) goto loop
  return %set
}
; returns the key in a set of modes
alias _whichkey {
  var %set = $_parammodes($gettok($1,1,32))
  if (k !isincs %set) return
  return $gettok($1-,$calc($pos(%set,k,1) / 2 + 1),32)
}
; returns the limit in a set of modes
alias _whichlimit {
  var %set = $_parammodes($gettok($1,1,32))
  if (+l !isincs %set) return
  return $gettok($1-,$calc(($pos(%set,+l,1) + 1) / 2 + 1),32)
}

;
; Recent offenders
;
alias f8 {
  if ($active !ischan) _error F8 can only be used in channel windows. $+ $chr(40) $+ to view and punish recent offenders. $+ $chr(41)
  if ($_grabrec(offend $+ $active,0) == $null) _error No recent offenders in $active $+ .F8 is used to view and punish recent channel offenders.
  _dialog -am recond recond
}
alias -l _rosel {
  did -c recond 2 $1
  did -r recond 8
  var %sel = $did(21,$did(2).sel)
  _ddaddm recond 8 $gettok(%sel,1,32) 022 030 002 001 111
  did -c recond 8 1
  did -d recond 4 1
  did -ic recond 4 1 $replace($_protwarnmsg(k,$gettok(%sel,2,32)),&A&,$_p2s($gettok(%sel,3,32)),&B&,$_p2s($gettok(%sel,4,32)))
  did $iif($gettok(%sel,2,32) == clones,-c,-u) recond 9
}
dialog recond {
  title "Recent Offenders"
  icon script\pnp.ico
  option map
  size -1 -1 320 173

  box "", 1, 6 6 227 55
  list 2, 13 18 213 42

  box "&Kick reason:", 3, 6 67 227 33
  combo 4, 13 79 212 92, drop edit

  box "Action:", 5, 6 105 227 60
  button "&Kick", 6, 13 119 33 14, default
  check "&Kick clones also", 9, 53 121 172 9
  button "&Ban:", 7, 13 141 33 14
  combo 8, 53 142 172 92, drop edit

  text "1) Select a recent offender from the list.", 201, 240 18 73 61
  text "2) Optionally change the kick reason.", 202, 240 79 73 29
  text "3) Select Kick or Ban to punish.", 203, 240 116 73 42

  button "Cancel", 101, 276 149 33 14, cancel

  edit "", 20, 1 1 1 1, hide autohs
  list 21, 1 1 1 1, hide
  edit $cid, 22, 1 1 1 1, hide autohs
}
on *:DIALOG:recond:sclick:2:_rosel $did(2).sel | did -t $dname 6
on *:DIALOG:recond:init:*:{
  did -o $dname 20 1 $active
  did -o $dname 1 1 & $+ Recent offenders on $replace($active,&,&&) $+ :
  did -r $dname 2
  var %token,%data,%total = $_grabrec(offend $+ $active,0),%num = 1
  :loop
  %token = $_grabrec(offend $+ $active,%num)
  %data = $_sufnrec(offend $+ $active,%num)
  did -a $dname 2 $gettok(%token,1,33) - $gettok(%data,1,32) ( $+ $gettok(%token,2-,33) $+ )
  did -a $dname 21 %token %data
  if (%num < %total) { inc %num | goto loop }
  _fillrec $dname 4 0 $_cfg(kick.lis) $active
  _rosel 1
}
on *:DIALOG:recond:sclick:6:_cidexists $did(22) | scid $did(22) | $iif($did(9).state,fk,kick) $did(20) $gettok($did(2,$did(2).sel),1,32) $did(4) | dialog -x $dname
on *:DIALOG:recond:sclick:7:if ($did(8) == $null) _error You must have a banmask selected. | _cidexists $did(22) | scid $did(22) | kb $did(20) $did(8) $did(4) | dialog -x $dname
on *:DIALOG:recond:sclick:8:did -t $dname 7
on *:DIALOG:recond:edit:8:did -t $dname 7

