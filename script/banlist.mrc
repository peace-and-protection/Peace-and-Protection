; #= P&P -rs
; ########################################
; Peace and Protection
; Banlist / etc. editing, and blacklist
; ########################################

;
; Banlist/etc. editing
;
alias -l _openlist {
  var %win = $_mservwin($1,$2)
  if ($window(%win)) {
    if ($window(%win).title) {
      clear %win
      titlebar %win
      _windowreg %win _closebanlist
    }
  }
  else {
    _window 2.6 -nhlvk -t3,68,78,88 %win -1 -1 -1 -1 @banlist
    _windowreg %win _closebanlist
  }
  return %win
}
alias -l _addlist if ($3) aline $1  	 $+ $2 $+ 	 $round($calc(($ctime - $4) / 86400),2) $+ 	 $+ $3 | else aline $1  	 $+ $2 $+ 	 	 
alias -l _finlist {
  var %win = $_openlist(@ $+ $1 $+ -list,- $+ $2)
  if ($line(%win,0) == 0) {
    window -c %win
    if ($halted) return
    disprc $2 $1 list is empty.
    halt
  }
  iline %win 1 Double-click to toggle an entry. (right-click for options)
  iline %win 2 Changes will *not* be made until you close the window.
  iline %win 3  
  iline %win 4  	 $+ $1 $+ 	Days old	Set by
  iline %win 5  
  window -awb %win
  _banupd %win
  halt
}

; opens a list from the ibl
alias _iblbanlist {
  var %win = $_openlist(@Ban-list,- $+ $1)
  var %pos = 1
  while ($ibl($1,%pos)) {
    _addlist %win $ibl($1,%pos) $ibl($1,%pos).by $ibl($1,%pos).ctime
    inc %pos
  }  
  _finlist Ban $1
}

raw 367:*:{
  var %hashhit = $+(pnp.scanfound.,$cid,.,$cha2)
  if ($hget(%hashhit)) {
    var %hash = $+(pnp.scanunban.,$cid,.,$2)
    var %num = $hget(%hash,0).item
    while (%num > 0) {
      var %item = $hget(%hash,%num).item
      if ((%item iswm $3) || ($3 iswm %item)) hadd %hashhit $3 1
      dec %num
    }
  }
  else {
    if ($halted) return
    _addlist $_openlist(@Ban-list,- $+ $2) $3-
  }
  halt
}
raw 368:*:{
  if ($hget($+(pnp.scanfound.,$cid,.,$2))) {
    _scanu4 $2
    halt
  }
  _finlist Ban $2
}
raw &346:*:{ _addlist $_openlist(@Invite-list,- $+ $2) $3- | halt }
raw 347:*:_finlist Invite $2
raw &348:*:{ _addlist $_openlist(@Exception-list,- $+ $2) $3- | halt }
raw 349:*:_finlist Exception $2

menu @Banlist {
  dclick:_bangroup $active _bantog
  $iif($sline($active,1).ln > 5,Toggle):_bangroup $active _bantog
  $iif($sline($active,1).ln > 5,Remove):_bangroup $active _banrem
  Add...:_banadd $active $mid(beI,$pos(bei,$mid($active,2,1),1),1) $_entry(-1,$null,$remove($gettok($active,1,45),@) to add to $gettok($active,3-,45) $+ ? $+ $chr(40) $+ You must enter a mask $+ $chr(44) not a nickname. $+ $chr(41)) +
  $iif($sline($active,1).ln > 5,Modify...):_bangroup $active _banmod
  -
  Remove
  .Entries matching...:{
    var %whom = $_entry(-1,$null,Nickname address or wildcard mask to clear matches for?)
    if ($_ppmask(%whom,1,1,1)) _bancln $active * $ifmatch
    else {
      _notconnected
      _Q.userhost _bancln $+ $active $+ *&n!&a disps $+ User $+ $:t(%whom) $+ notfound-cannotcleanmatchingentries %whom
    }
  }
  .Nick-based entries:_bancln $active n
  .Single IP entries:_bancln $active i
  .-
  .Entries set by servers:_bancln $active s
  .Entries set by...:_bancln $active b $_entry(-1,$me,Remove all entries set by whom? $chr(40) $+ wildcards OK $+ $chr(41))
  .-
  .Entries newer than...:_bancln $active <= $_entry(-2,0.1,Remove all entries younger than how many days?)
  .Entries older than...:_bancln $active >= $_entry(-2,5,Remove all entries older than how many days?)
  .-
  .All entries:_banall $active _banrem
  Backup
  .Export...:_ssplay Question | var %export = $$sfile(*.txt,File to export to?,Export) | if ($exists(%export)) _fileopt 1 %export | _banexp $active %export
  .-
  .Import $+ $chr(44) adding to list...:_ssplay Question | _banimp $active 0 $$sfile(*.txt,Banlist to import?,Import)
  .Import $+ $chr(44) replacing list...:_ssplay Question | _banimp $active 1 $$sfile(*.txt,Banlist to import?,Import)
  .-
  .$iif($sline($active,1).ln > 5,Copy to blacklist...):black $active
  .$iif($sline($active,1).ln > 5,Move to blacklist...):var %win = $active | black %win | _bangroup %win _banrem
  -
  $iif($count($window($active).title,-) > 1,Changes)
  .Perform changes:_closebanlist $active
  .-
  .Cancel changes:_banall $active _banok
  .Close and cancel:_windowreg $active | _dowclose $active | window -c $active
}
alias -l _bangroup var %blip = $mid(beI,$pos(bei,$mid($1,2,1),1),1),%num = $sline($1,0) | :loop | if (%num) { if ($sline($1,%num).ln > 5) $2 $1 $ifmatch %blip | dec %num | goto loop } | _banupd $1
alias -l _banall var %blip = $mid(beI,$pos(bei,$mid($1,2,1),1),1),%num = $line($1,0) | :loop | if (%num > 5) { $2 $1 $ifmatch %blip | dec %num | goto loop } | _banupd $1
alias _bancln {
  var %blip = $mid(beI,$pos(bei,$mid($1,2,1),1),1),%num = $line($1,0)
  :loop
  if (%num > 5) {
    var %kill
    goto $2
    :* | var %ban = $gettok($line($1,%num),2,9) | if ((%ban iswm $3) || ($3 iswm %ban)) %kill = 1 | goto next
    :n | if ($remove($gettok($gettok($line($1,%num),2,9),1,33),*,?) != $null) %kill = 1 | goto next
    :i | var %ban = $gettok($gettok($line($1,%num),2,9),2-,64) | if ((* !isin %ban) && (? !isin %ban)) %kill = 1 | goto next
    :b | if ($3 iswm $gettok($line($1,%num),4,9)) %kill = 1 | goto next
    :s | var %whom = $gettok($line($1,%num),4,9) | if ((. isin %whom) && (@ !isin %whom)) %kill = 1 | goto next
    :<= | :>= | if ($gettok($line($1,%num),3,9) $2 $3) %kill = 1
    :next
    if (%kill) _banrem $1 %num %blip
    dec %num | goto loop
  }
  _banupd $1
}
alias -l _bantog {
  if (+ isin $gettok($line($1,$2),1,9)) dline $1 $2
  elseif (- isin $gettok($line($1,$2),1,9)) rline $1 $2  	 $+ $gettok($line($1,$2),2-4,9)
  else rline $1 $2 - $+ $3 $+ 	 $+ $gettok($line($1,$2),2-4,9) $+ 	 ( $+ removing $remove($gettok($1,1,45),@) $+ )
}
alias -l _banok {
  if (+ isin $gettok($line($1,$2),1,9)) dline $1 $2
  elseif (- isin $gettok($line($1,$2),1,9)) rline $1 $2  	 $+ $gettok($line($1,$2),2-4,9)
}
alias _banrem {
  if (+ isin $gettok($line($1,$2),1,9)) dline $1 $2
  else rline $1 $2 - $+ $3 $+ 	 $+ $gettok($line($1,$2),2-4,9) $+ 	 ( $+ removing $remove($gettok($1,1,45),@) $+ )
}
alias _banadd {
  var %num = $line($1,0)
  :loop
  if ($gettok($line($1,%num),2,9) == $3) {
    if (- isin $gettok($line($1,%num),1,9)) rline $1 %num  	 $+ $gettok($line($1,%num),2-4,9)
    goto done
  }
  if (%num > 5) { dec %num | goto loop }
  aline $1 + $+ $2 $+ 	 $+ $3 $+ 	 0 $+ 	 $+ $me $+ 	 ( $+ adding $remove($gettok($1,1,45),@) $+ )
  :done
  if ($4) _banupd $1
}
alias -l _banmake {
  var %num = $line($1,0)
  :loop
  if ($gettok($line($1,%num),2,9) == $2) {
    rline $1 %num  	 $+ $gettok($line($1,%num),2-4,9)
    goto done
  }
  if (%num > 5) { dec %num | goto loop }
  aline $1  	 $+ $2 $+ 	 0 $+ 	 $+ $3
  :done
  _banupd $1
}
alias -l _bankill {
  var %num = $line($1,0)
  :loop
  if ($gettok($line($1,%num),2,9) == $2) dline $1 %num
  if (%num > 5) { dec %num | goto loop }
  _banupd $1
}
alias -l _banmod {
  var %newban = $_entry(-1,$gettok($line($1,$2),2,9),New mask for $remove($gettok($1,1,45),@) $+ ?) +
  _banrem $1-
  _banadd $1 $3 %newban
}
alias -l _banupd {
  var %title = -
  if ($fline($1,+*,0,0)) %title = %title Adding $ifmatch $remove($gettok($1,1,45),@) $+ $chr(40) $+ s $+ $chr(41) -
  if ($fline($1,-*,0,0)) %title = %title Removing $ifmatch $remove($gettok($1,1,45),@) $+ $chr(40) $+ s $+ $chr(41) -
  var %cur = $calc($line($1,0) - $fline($1,-*,0,0) - 5)
  if (%title == -) %title = - %cur total $remove($gettok($1,1,45),@) $+ $chr(40) $+ s $+ $chr(41)
  else %title = %title Resulting in %cur total $remove($gettok($1,1,45),@) $+ $chr(40) $+ s $+ $chr(41)
  titlebar $1 %title ( $+ $hget(pnp. $+ $window($1).cid,net) $+ )
}
alias _closebanlist {
  var %channel = $mid($1,$calc($pos($1,-,2) + 1),$len($1))
  _init.mass %channel
  if (($fline($1,-*,1,0)) || ($fline($1,+*,1,0))) {
    if (($me !ishop %channel) && ($me !isop %channel)) { disprc %channel Changes to $remove($gettok($1,1,45),@) list canceled- You are not opped | return }
  }
  :loopu
  if ($fline($1,-*,1,0)) {
    _add.mass %channel - $mid($line($1,$ifmatch),3,1) $gettok($line($1,$ifmatch),2,9)
    dline $1 $fline($1,-*,1,0)
    goto loopu
  }
  :loopb
  if ($fline($1,+*,1,0)) {
    _add.mass %channel + $mid($line($1,$ifmatch),3,1) $gettok($line($1,$ifmatch),2,9)
    dline $1 $fline($1,+*,1,0)
    goto loopb
  }
  _flush.mass %channel
}
alias -l _banimp {
  if ($2) _banall $1 _banrem
  var %read,%num = 1,%last = $lines($3-),%type = $mid(beI,$pos(bei,$mid($1,2,1),1),1)
  :loop
  %read = $read($3-,n,%num)
  if ($matchtok($matchtok(%read,*,1,9),*,1,32)) _banadd $1 %type $ifmatch
  if (%num < %last) { inc %num | goto loop }
  _banupd $1
}
alias _banexp {
  write " $+ $2- $+ " $remove($gettok($1,1,45),@) $+ list / $mid($1,$calc($pos($1,-,2) + 1),$len($1)) / $hget(pnp. $+ $cid,net) / $me ( $+ $_datetime $+ )
  var %line,%num = 6
  :loop
  %line = $line($1,%num)
  if (%line) {
    if (- !isin $gettok(%line,1,9)) {
      if ($gettok(%line,3,9)) write " $+ $2- $+ " $gettok(%line,2,9) 	set by $gettok(%line,4,9) $gettok(%line,3,9) days old
      else write " $+ $2- $+ " $gettok(%line,2,9)
    }
    inc %num | goto loop
  }
}
on *:BAN:#:if ($window($_mservwin(@Ban-list,- $+ $chan))) _banmake $ifmatch $banmask $nick
on *:UNBAN:#:if ($window($_mservwin(@Ban-list,- $+ $chan))) _bankill $ifmatch $banmask $nick

;
; Blacklist
;
alias blacklist blackedit
alias blackedit {
  if ($window(@Blacklist)) clear @Blacklist
  else _window 2.7 -slzk -t20,85,125 @Blacklist $_winpos(8,12,10,10) @Blacklist
  var %file,%num,%line,%nick,%chan,%note
  %file = $_cfg(userinfo.ini)
  %num = $ulist(*,black,0)
  :loop
  if (%num) {
    %line = $ulist(*,black,%num)
    %nick = $readini(%file,n,%line,nick)
    %chan = $readini(%file,n,%line,chan)
    %note = $readini(%file,n,%line,note)
    aline @Blacklist $iif(%nick == $null,-,%nick) $+ 	 $+ %line $+ 	 $+ ( $+ $iif(%chan == $null,all,%chan) $+ ) $+ 	 $+ $_readprep(%note)
    dec %num | goto loop
  }
  iline @Blacklist 1 The following addresses will be banned and kicked where you are op.
  iline @Blacklist 2 You will also ignore private messages and CTCPs from them.
  iline @Blacklist 3 Double-click to edit a user $+ $chr(44) or right-click for options.
  iline @Blacklist 4  
  iline @Blacklist 5 Nickname	Address	Channel	Reason
  iline @Blacklist 6  
  window -b @Blacklist
}

menu @Blacklist {
  dclick:if ($sline($active,1).ln > 6) black $gettok($sline($active,1),2,9)
  Add user...:black $_entry(-1,$null,Nickname or address to blacklist?)
  $iif($sline($active,1).ln > 6,Remove)::loop | black -r $gettok($sline($active,1),2,9) | if ($sline($active,1).ln) goto loop
  -
  $iif($sline($active,1).ln > 6,Edit...):black $gettok($sline($active,1),2,9)
}

dialog blackedit {
  title "Blacklist"
  icon script\pnp.ico
  option map
  size -1 -1 200 159

  box "Blacklisting:", 101, 6 6 187 47
  text "&Nickname:", 106, 10 20 33 12, right
  edit "", 1, 46 18 66 13
  text "(for reference only)", 107, 116 20 66 12
  text "&Usermask:", 108, 10 35 33 12, right
  combo 2, 46 33 140 73, edit drop

  box "Where:", 102, 6 56 187 52
  radio "&All channels", 5, 13 68 173 9
  radio "&Only in:", 6, 13 81 46 9
  edit "", 7, 60 79 120 13, disable
  text "(multiple channels ok)", 103, 62 95 125 12

  text "&Reason:", 104, 10 116 33 12, right
  combo 8, 46 114 140 85, edit drop

  button "&Blacklist", 201, 6 137 53 14, default
  button "Cancel", 202, 73 137 53 14, cancel
  button "&Remove", 203, 140 137 53 14, disable

  edit "", 241, 1 1 1 1, hide autohs
  edit "", 242, 1 1 1 1, hide autohs result
}
on *:DIALOG:blackedit:sclick:5:did -b $dname 7
on *:DIALOG:blackedit:sclick:6:did -e $dname 7
on *:DIALOG:blackedit:init:*:{
  var %reason
  if (@* iswm %.who) {
    var %chan = $mid(%.who,$calc($pos(%.who,-,2) + 1),$len(%.who))
    did -ae $dname 7 %chan
    did -cf $dname 6
    did -abc $dname 2 ( $+ banlist transfer from %chan $+ )
    did -a $dname 242 %.who
  }
  else {
    if ($istok($level(%.addr),=black,44)) {
      ; saves original address
      did -a $dname 241 %.addr
      did -e $dname 203
      var %file = $_cfg(userinfo.ini)
      did -a $dname 1 $readini(%file,n,%.addr,nick)
      %reason = $readini(%file,n,%.addr,note)
      var %chan = $readini(%file,n,%.addr,chan)
      if (%chan) { did -ae $dname 7 %chan | did -c $dname 6 }
      else did -c $dname 5
    }
    else {
      did -c $dname 5
      if ($gettok(%.who,1,33) != *) did -a $dname 1 $ifmatch
    }
    if ($did(7) == $null) {
      if ($active ischan) did -a $dname 7 $active
      elseif ($comchan($did(1),1)) did -a $dname 7 $ifmatch
    }
    did -ac $dname 2 %.addr
    if (* !isin %.who) {
      if (*!*@* iswm %.who) _ddaddm $dname 2 %.who 022 030 100 002 001 111
      elseif ($address(%.who,5)) _ddaddm $dname 2 $ifmatch 022 030 100 002 001 111
    }
  }
  _fillrec $dname 8 0 $_cfg(black.lis) 0 $_readprep(%reason)
  if (%reason == $null) did -u $dname 8
  unset %.who %.addr
}
on *:DIALOG:blackedit:sclick:201:{
  if ($did(8) == $null) _okcancel 1 You have not entered a blacklist reason- Continue?
  ; remove old?
  if (($did(241) != $did(2)) && ($did(241) != $null)) .black -r $did(241)
  ; add new
  ; (transfer?)
  if ($did(242) != $null) {
    var %num = 1
    if (($did(6).state) && ($_ischan($did(7),1))) var %where = $_s2c($did(7))
    else var %where = *
    var %other = = $+ $gettok($did(1),1,32) $did(8)
    :loop
    if ($sline($did(242),%num)) {
      black %where $gettok($ifmatch,2,9) %other
      inc %num | goto loop
    }
  }
  else {
    if (($did(6).state) && ($_ischan($did(7),1))) black $_s2c($did(7)) $did(2) = $+ $gettok($did(1),1,32) $did(8)
    else black * $did(2) = $+ $gettok($did(1),1,32) $did(8)
  }
  dialog -c $dname
}
on *:DIALOG:blackedit:sclick:203:black -r $did(241) | dialog -c $dname

; /black [-r|#channel(s)|*] nick|addr|@window [=nick] [reason]
; pops up dialog only if just nick/addr is given
alias black {
  var %num,%nick,%line,%line2
  if ((-* iswm $1) || ($_ischan($1)) || ($1 == *)) { var %where = $1,%who = $2,%why = $3- }
  else { var %where,%who = $1,%why = $2- }
  if (%who == $null) _qhelp /black $1-

  if (@* iswm %who) { set -u %.who %who | _dialog -ma blackedit blackedit | return }

  var %dialog = $iif($1- == %who,1,0)

  %who = $_nc(%who)
  var %addr = $_ppmask(%who,$_stmask(3,%where),1)
  if (%addr == $null) {
    dispa Looking up address of $:t(%who) $+ ... $+ ...
    _notconnected
    _Q.userhost black $+ %where $+ &n!&a $+ $iif(%why != $null,$_s2p(%why)) dispa $+ User $+ $:t(%who) $+ notfound-cannotblacklist %who
    halt
  }

  ; dialog
  if (%dialog) { set -u %.who %who | set -u %.addr %addr | _dialog -ma blackedit blackedit | return }

  var %file = $_cfg(userinfo.ini)
  if (%where == -r) {
    if ($window(@Blacklist)) {
      %num = 7 | :loop1 | if ($line(@Blacklist,%num)) { if ($gettok($ifmatch,2,9) == %addr) dline @Blacklist %num | else inc %num | goto loop1 }
    }
    else {
      if ($istok($level(%addr),=black,44)) dispa Removing $:s(%addr) from blacklist.
      else dispa $:s(%addr) is not in blacklist.
    }
    .ruser black %addr
    if ($level(%addr) == $dlevel) .ruser %addr
    scid -a _nickcol.updatemask %addr 1
    remini %file %addr
  }
  else {
    if (=* iswm $gettok(%why,1,32)) { %nick = $right($gettok(%why,1,32),-1) | %why = $gettok(%why,2-,32) }
    elseif ((* !isin $gettok(%who,1,33)) && ($gettok(%who,1,33) != $null)) %nick = $ifmatch
    else %nick = $readini(%file,n,%addr,nick)
    if (%why == $null) { %why = $readini(%file,n,%addr,note) | %why = $_readprep(%why) }
    if (%where == $null) %where = $readini(%file,n,%addr,chan)
    if (%where == *) var %where
    if ($window(@Blacklist)) {
      %line = $iif(%nick == $null,-,%nick) $+ 	 $+ %addr $+ 	 $+ ( $+ $iif(%where == $null,all,%where) $+ ) $+ 	 $+ %why
      %num = 7 | :loop2
      if ($line(@Blacklist,%num)) {
        if ($gettok($ifmatch,2,9) == %addr) _ridline @Blacklist %num %line
        else { inc %num | goto loop2 }
      }
      else iline @Blacklist $calc($line(@Blacklist,0) + 1) %line
    }
    else {
      if (%nick) %line = $:t(%nick) ( $+ $:s(%addr) $+ ) | else %line = $:s(%addr)
      if (%where == $null) %line2 = $:s(all channels) | else %line2 = $:s(%where)
      var %whyshow = $iif(%why == $null,none,$:s(%why))
      dispa $iif($istok($level(%addr),=black,44),Modifying blacklist entry- %line in %line2 $chr(40) $+ reason- %whyshow $+ $chr(41),Adding blacklist entry- %line in %line2 $chr(40) $+ reason- %whyshow $+ $chr(41))
    }
    if ($level(%addr) == $dlevel) .auser -a $dlevel %addr
    .auser -a black %addr
    if (%nick) writeini %file %addr nick %nick | else remini %file %addr nick
    if (%why) { writeini %file %addr note $_writeprep(%why) | _recent2 black 9 %why } | else remini %file %addr note
    if (%where) writeini %file %addr chan %where | else remini %file %addr chan
    var %cid = $scon(0)
    set -u %.punishwait 1
    while (%cid >= 1) {
      scon %cid
      _nickcol.updatemask %addr 1
      %num = $chan(0)
      :loopC
      ; No need to check for connection status or on channel, as we check for isop/ishop
      if ((($me isop $chan(%num)) || ($me ishop $chan(%num))) && ($ialchan(%addr,$chan(%num),0))) {
        if ((%where == $null) || ($istok(%where,$chan(%num),44))) {
          disprc $chan(%num) Blacklisted $:s(%addr) $+ - Kickbanning $+ ...
          %line = $_msg(black)
          if (&reason !isin %line) %line = %line &reason&
          set -u %&reason& %why
          set -u %&addr& %addr
          kb $chan(%num) %addr %line
        }
      }
      if (%num > 1) { dec %num | goto loopC }
      dec %cid
    }
    scon -r
    unset %&reason& %&addr&
  }
}

; Reorders userlist so all blacklist-only entries are at the end.
alias _reorderblack {
  saveini
  if ($isfile($_cfg(users.mrc))) {
    window -hln @.userlist
    loadbuf @.userlist $_cfg(users.mrc)
    var %ln = 1,%last = $line(@.userlist,0)
    while (%ln <= %last) {
      if (1,=black:* iswm $line(@.userlist,%ln)) {
        aline @.userlist $line(@.userlist,%ln)
        dline @.userlist %ln
        dec %last
      }
      else inc %ln
    }
    savebuf @.userlist $_cfg(users.mrc)
    .load -ru " $+ $_cfg(users.mrc) $+ "
    window -c @.userlist
  }
}

