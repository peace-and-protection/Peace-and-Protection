; #= P&P -rs
; ########################################
; Peace and Protection
; Userlist support, editing, etc.
; ########################################
 
;
; Popup preliminary
;
alias _addrpop {
  if ($address($remove($active,=),5)) set -u %.targaddr $ifmatch
  elseif (($query($active)) && ($query($active).address != $active)) set -u %.targaddr $active $+ ! $+ $ifmatch
  else unset %.targaddr
}
 
; Finds first matching user in the userlist, if any
; $_fuser(fulladdress) / $_fuser2(maddress) finds iswm both ways
alias _fuser var %num = 1 | :loop | if ($ulist(*,%num)) { if ($ifmatch iswm $1) return $ifmatch | inc %num | goto loop }
alias _fuser2 var %num = 1 | :loop | if ($ulist(*,%num)) { if ($ifmatch iswm $1) return $ifmatch | if ($1 iswm $ulist(*,%num)) return $ulist(*,%num) | inc %num | goto loop }
 
;
; Userlist
;
 
; /user [-v] address[,addr...]
; /user -r address[,addr...] [#chan]
; /user address[,addr...] [#chan|*] [-r|lvl] [x|-|+|%|@ [pw|?|??|!]] [=nick] [<lvl] [>lvl] [[nn]]
 
; address can be a nick, fulladdress, mask, etc.
 
; No options- Views/edits userlist entry
;   -r to remove entry, or with #chan to remove that channel
;   -v to view entry (text)
 
; Manual editing- (options in any order, even repeated)
;   #chan allows channel-specific levels
;   lvl is numeric level, or -r to remove that channel
;   x/-/+/%/@ is op status
;   pw is password, ? for required but not set, ! for automatic, ?? for required but not set but left alone if already set
;   nick allow modification of AKA
;   can use >lvl to manually add a custom named level, and <lvl to remove
;   ^k removes or adds nicklist color level =colorXX
 
alias user {
  if ($1 == $null) _qhelp /user
 
  var %flag,%mask,%rest,%stuff,%ule-mask,%ule-raw,%ule-nick,%num,%chan,%newlvl,%tok,%pw
 
  if (-* iswm $1) { %flag = $1 | %mask = $_nc($gettok($2,1,44)) | %rest = $gettok($2,2-,44) | %stuff = $3- }
  else { %flag = - | %mask = $_nc($gettok($1,1,44)) | %rest = $gettok($1,2-,44) | %stuff = $2- }
 
  %ule-mask = $_ppmask(%mask,$_stmask(3),1)
  if (%ule-mask == $null) {
dispa Looking up address of $:t(%mask) $+ ...
    _notconnected
_Q.userhost user $+ %flag $+ &n!&a, $+ %rest $+  $+ $iif(%stuff,$_s2p(%stuff)) dispaUser $+ $:t(%mask) $+ notfound. %mask
    halt
  }
  %ule-raw = $level(%ule-mask)
  %ule-nick = $readini($_cfg(userinfo.ini),n,%ule-mask,nick)
  if (%ule-nick == $null) {
    if ((* !isin %mask) && (! !isin %mask) && (@ !isin %mask) && (. !isin %mask)) %ule-nick = %mask
    if ((! isin %mask) && (* !isin $gettok(%mask,1,33))) %ule-nick = $gettok(%mask,1,33)
  }
 
  if (%flag == -v) {
    _info /user -v
dispr @Info User level $+ $chr(40) $+ s $+ $chr(41) for $:t(%ule-mask) $iif(%ule-nick,a.k.a. $:s(%ule-nick)) -
    %num = $numtok(%ule-raw,44)
    :view
    if ($_namedul($gettok(%ule-raw,%num,44),%ule-mask)) dispr @Info   - $ifmatch
    if (%num > 1) { dec %num | goto view }
    if (%rest) _juryrig2 user %flag %rest %stuff
    return
  }
  if (%flag == -r) {
    _info /user -r
if (%ule-raw == $dlevel) { .ruser %ule-mask | dispr @Info $:t(%ule-mask) is not in your userlist }
    elseif (%stuff) {
      %chan = $gettok(%stuff,1,32)
if (($left(%chan,1) !isin & $+ $remove($chantypes,+)) && (%chan != *)) dispr @Info $:t(%chan) is not a channel $chr(40) $+ cannot be removed from a user $+ $chr(41)
elseif ((%chan != *) && (,= $+ %chan $+ ¬ !isin %ule-raw)) disptc @Info %chan $:t(%ule-mask) is not in channel userlist
      else {
        remini $_cfg(userinfo.ini) %ule-mask %chan
        %ule-raw = $_leveledit(%chan,%ule-raw)
        if ((¬ !isin %ule-raw) && (%chan == *) && ($wildtok(%ule-raw,=color*,1,44))) %ule-raw = $remtok(%ule-raw,$ifmatch,1,44)
        if (%ule-raw == $dlevel) {
          remini $_cfg(userinfo.ini) %ule-mask
          .ruser %ule-mask
        }
        else .auser %ule-raw %ule-mask
disptc @Info %chan Removed $:t(%ule-mask) from channel userlist
      }
    }
    else {
      remini $_cfg(userinfo.ini) %ule-mask
      .ruser %ule-mask
dispr @Info Removed user $:t(%ule-mask) from userlist
    }
    scon -at1 _nickcol.updatemask %ule-mask 1
    if (%rest) _juryrig2 user -r %rest %stuff
    return
  }
  if (%stuff) {
    _info /user
dispr @Info Editing user $:t(%ule-mask) $iif(%ule-nick,a.k.a. $:s(%ule-nick)) -
    %chan = *
    %newlvl = $_level(*,%ule-raw)
    if (%rest) _juryrig2 user %rest %stuff
    :edit
    %tok = $gettok(%stuff,1,32)
    %stuff = $gettok(%stuff,2-,32)
    ; [#chan|*] [-r|lvl] [x|-|+|%|@ [pw|?|??|!]] [=nick] [<lvl] [>lvl] [[nn]]
    if ($istok(x.-.+.%.@,%tok,46)) {
      %newlvl = $calc(%newlvl) $+ $iif(%tok != x,%tok)
      if (%tok isin x-) remini $_cfg(userinfo.ini) %ule-mask %chan
      else {
        %pw = $gettok(%stuff,1,32)
        if (($left(%pw,1) isletter) || ($istok(!.?.??,%pw,46))) {
          if (%pw == ??) {
            %pw = $readini($_cfg(userinfo.ini),n,%ule-mask,%chan)
            if (%pw == $null) %pw = ?
          }
          if (%pw == !) remini $_cfg(userinfo.ini) %ule-mask %chan
          else writeini $_cfg(userinfo.ini) %ule-mask %chan $iif(%pw == ?,?,$hash(%pw,32))
        }
      }
      %pw = $readini($_cfg(userinfo.ini),n,%ule-mask,%chan)
      if (%tok isin x-) var %pw
elseif (%pw == ?) %pw = (password not set)
elseif (%pw == $null) %pw = (auto $+ $chr(44) without password)
else %pw = (password set)
dispr @Info   - $iif(%chan == *,Default,$:s(%chan)) Status - $gettok(Cleared $chr(40) $+ no op/voice/deop $+ $chr(41)*Auto-deop*Voiced*Halfops*Ops,$pos(x-+%@,%tok),42) %pw
    }
    elseif (%tok == -r) {
      remini $_cfg(userinfo.ini) %ule-mask %chan
dispr @Info   - $iif(%chan == *,Default,$:s(%chan)) Level and flags cleared
      var %newlvl
    }
    elseif ($left(%tok,1) isin & $+ $remove($chantypes,+)) {
      %ule-raw = $_leveledit(%chan,%ule-raw,%newlvl)
      %chan = %tok
      %newlvl = $_level(%chan,%ule-raw)
    }
    elseif (%tok == *) {
      %ule-raw = $_leveledit(%chan,%ule-raw,%newlvl)
      %chan = *
      %newlvl = $_level(*,%ule-raw)
    }
    elseif (=* iswm %tok) {
      if (%tok == =) {
dispr @Info   - Stored nickname cleared
        var %ule-nick
        remini $_cfg(userinfo.ini) %ule-mask nick
      }
      else {
dispr @Info   - Nickname stored for mask is now $:t($right(%tok,-1))
        %ule-nick = $right(%tok,-1)
      }
    }
    elseif (%tok isnum) {
      %newlvl = %tok $+ $remove(%newlvl,$calc(%newlvl))
dispr @Info   - $iif(%chan == *,Default,$:s(%chan)) Level is now $:t(%tok)
    }
    elseif (>* iswm %tok) {
      %tok = $right(%tok,-1)
      if (=* !iswm %tok) %tok = = $+ %tok
      %ule-raw = $addtok(%ule-raw,%tok,44)
dispr @Info   - Added custom level $:t(%tok)
    }
    elseif (<* iswm %tok) {
      %tok = $right(%tok,-1)
      if (=* !iswm %tok) %tok = = $+ %tok
      %ule-raw = $remtok(%ule-raw,%tok,44)
dispr @Info   - Removed custom level $:t(%tok)
    }
    elseif (* iswm %tok) {
      if ($wildtok(%ule-raw,=color*,1,44)) %ule-raw = $remtok(%ule-raw,$ifmatch,1,44)
if ( == %tok) dispr @Info   - Removed nicklist color
      else {
        if ($remove(%tok,) isnum 0-99) {
          var %color = $ifmatch
          %ule-raw = $addtok(%ule-raw,=color $+ $_cprep(%color),44)
dispr @Info   - Modified nicklist color to %tok $+ $_colorword(%color)
        }
      }
    }
    if (%stuff != $null) goto edit
    %ule-raw = $_leveledit(%chan,%ule-raw,%newlvl)
    if (%ule-raw == $dlevel) .ruser %ule-mask
    else .auser %ule-raw %ule-mask
    _reorderblack
    scon -at1 _nickcol.updatemask %ule-mask 1
    if (%ule-nick) writeini $_cfg(userinfo.ini) %ule-mask nick %ule-nick
    return %ule-raw
  }
  ; convert locals to global for editor
  set -u %.ule-nick %ule-nick
  set -u %.ule-raw %ule-raw
  set -u %.ule-mask %ule-mask
  set -u %.mask %mask
  set -u %.rest %rest
  _cs-prep useredit | _dialog -am useredit useredit
}
alias _namedul {
  if (¬ isin $1) { var %chan = $gettok($1,1,172),%lvl = $gettok($1,2,172) }
  elseif (=* iswm $1) return
  else { var %chan = *,%lvl = $1 }
  if (=* iswm %chan) %chan = $right(%chan,-1)
  var %text,%num = $calc(%lvl)
  if (%num == 1) var %num
  else {
if (%num < 25) %text = (no special level)
elseif (%num < 50) %text = (exempt from clones/strict topics/modes)
elseif (%num < 60) %text = (safe from protections)
elseif (%num < 75) %text = (protected friend)
elseif (%num < 175) %text = (protected with revenge)
else %text = (master- 'ctcp do' access)
    %num = $:t(%num)
  }
  var %spec,%pw = $readini($_cfg(userinfo.ini),n,$2,%chan)
if ($right($1,1) == -) %spec = $:b(Auto-deop) $+ $iif(%num,$chr(44))
elseif (*+ iswm $1) %spec = $:b(Voiced) ( $+ $iif(%pw == ?,Password not set,$iif(%pw,Password set,Auto $+ $chr(44) without password)) $+ ) $+ $iif(%num,$chr(44))
elseif (*% iswm $1) %spec = $:b(Halfops) ( $+ $iif(%pw == ?,Password not set,$iif(%pw,Password set,Auto $+ $chr(44) without password)) $+ ) $+ $iif(%num,$chr(44))
elseif (*@ iswm $1) %spec = $:b(Ops) ( $+ $iif(%pw == ?,Password not set,$iif(%pw,Password set,Auto $+ $chr(44) without password)) $+ ) $+ $iif(%num,$chr(44))
elseif (%text == $null) %spec = None
return $iif(%chan == *,Default,$:s(%chan)) level - %spec %num %text
}
 
;
; Userlist editor
;
 
;;; import/export?
;;; last seen times?
 
; /userlist [channel|*|+]
; Shows all, just a channel, or just 'global'
; + means 'refresh' (if open)
alias userlist useredit $1
alias useredit {
  if ($1 == +) {
    if ($window(@Userlist) == $null) return
if ($gettok($window(@Userlist).title,1-2,32) == (default only)) userlist *
    elseif ($gettok($window(@Userlist).title,1,32) != -) userlist $right($left($ifmatch,-1),-1)
    elseif ($window(@Userlist).title) userlist
    return
  }
  if (($1) && ($1 != *) && (!$_ischan($1))) userlist $_patch($1)
  if ($window(@Userlist)) clear @Userlist
  else _window 2.6 -slzk -t10,35,40,50 @Userlist $_winpos(8,12,10,10) @Userlist
  var %who,%lvl,%nick,%color,%lvlbit,%bit,%spec,%lvlnum,%num = $ulist(*,0),%file = $_cfg(userinfo.ini)
  if (%num == 0) goto done
  :loop
  %who = $ulist(*,%num)
  %lvl = $remtok($remtok($remtok($level(%who),=black,44),=auth,44),=dcc,44)
  if (%lvl != $dlevel) {
    %nick = $readini(%file,n,%who,nick)
    if (%nick == $null) %nick =  
    %lvlbit = $numtok(%lvl,44)
    if ($wildtok(%lvl,=color*,1,44)) %color = $remove($ifmatch,=color)
    else var %color
    :lvlloop
    %bit = $gettok(%lvl,%lvlbit,44)
    if (¬ isin %bit) { %chan = $gettok(%bit,1,172) | %bit = $gettok(%bit,2,172) }
    elseif (=* iswm %bit) goto lvlnext
    elseif ((%bit == 1) && ((%color == $null) || (¬ isin %lvl))) goto lvlnext
    else %chan = *
    if (=* iswm %chan) %chan = $right(%chan,-1)
    if (($1) && ($1 != %chan)) goto lvlnext
    %lvlnum = $calc(%bit)
    if (%lvlnum < 2) %lvlnum =  
if ($right(%bit,1) == -) %spec = Auto-deop
elseif (*+ iswm %bit) %spec = Voiced $iif($readini(%file,n,%who,%chan),(w/pw),(auto))
elseif (*% iswm %bit) %spec = Halfops $iif($readini(%file,n,%who,%chan),(w/pw),(auto))
elseif (*@ iswm %bit) %spec = Ops $iif($readini(%file,n,%who,%chan),(w/pw),(auto))
    else %spec =  
    if (%chan == *) var %chan | else %chan = ( $+ %chan $+ )
    aline %color @Userlist %nick $+ 	 $+ %who $+ 	 $+ %lvlnum $+ 	 $+ %spec $+ 	 $+ %chan
    :lvlnext
    if (%lvlbit > 1) { dec %lvlbit | goto lvlloop }
  }
  if (%num > 1) { dec %num | goto loop }
  :done
  %num = $line(@Userlist,0)
iline @Userlist 1 Double-click to edit a user
iline @Userlist 2 Select user $+ $chr(40) $+ s $+ $chr(41) and right-click for options
  iline @Userlist 3  
iline @Userlist 4 Nickname	Address	Level	Status	Channel
  iline @Userlist 5  
  window -b @Userlist
if ($1 == *) titlebar @Userlist (default only) - %num users
elseif ($1) titlebar @Userlist ( $+ $1 $+ ) - %num users
else titlebar @Userlist - %num users
}
alias -l _useredit {
  var %total,%num,%line,%chan,%mask
  :loop
  %num = $sline(@Userlist,1).ln
  if (%num) {
    %line = $sline(@Userlist,1)
    %mask = $gettok(%line,2,9)
    if ($gettok(%line,5,9) != $null) %chan = $right($left($ifmatch,-1),-1)
    else %chan = *
    if ($1 == ) {
      .user %mask  $+ $2
      scon -at1 _nickcol.updatemask %mask 1
      cline $2 @Userlist %num
      sline -r @Userlist %num
    }
    if ($1 == =) {
      if ($2 !isnum) return
      .user %mask %chan $2
      if ($wildtok($result,=color*,1,44)) _ridline $remove($ifmatch,=color) @Userlist %num $puttok(%line,$2,3,9)
      else _ridline @Userlist %num $puttok(%line,$2,3,9)
    }
    if ($1 == @) {
      .user %mask %chan $2-3
      if ($wildtok($result,=color*,1,44)) _ridline $remove($ifmatch,=color) @Userlist %num $puttok(%line,$4-,4,9)
      else _ridline @Userlist %num $puttok(%line,$4-,4,9)
    }
    if ($1 == r) {
      scon -at1 _nickcol.updatemask %mask 1
      .user -r %mask %chan
      dline @Userlist %num
    }
    if ($1 == e) { %total = $addtok(%total,%mask,44) | sline -r @Userlist %num }
    goto loop
  }
  if ($1 == e) { set -u %.selchan %chan | user %total }
if ($1 == r) { %num = $line(@Userlist,0) - 5 | titlebar @Userlist $gettok($window(@Userlist).title,1- $+ $calc($numtok($window(@Userlist).title,32) - 2),32) %num users }
}
alias -l _userfind {
  sline -r @Userlist
  var %num = $line(@Userlist,0)
  :loop
  if (%num > 5) {
    if ($1 == 3) { if ($gettok($line(@Userlist,%num),3,9) $2 $3) sline -a @Userlist %num }
    elseif ($2 iswm $gettok($line(@Userlist,%num),$1,9)) sline -a @Userlist %num
    dec %num | goto loop
  }
}
 
menu @Userlist {
  dclick:if ($sline($active,1).ln > 5) _useredit e
Add user...:user $_entry(-1,$null,Nickname or usermask to add?)
$iif($sline($active,1).ln > 5,Remove):_useredit r
  -
$iif($sline($active,1).ln > 5,Edit user...):_useredit e
  -
$iif($sline($active,1).ln > 5,Level)
.1	None:_useredit = 1
.25	Clone exempt:_useredit = 25
.50	Safe from protections:_useredit = 50
.60	Protected friend:_useredit = 60
.75	Protected with revenge:_useredit = 75
  .-
.	Custom...:_useredit = $_entry(-2,$null,Numeric userlevel?)
$iif($sline($active,1).ln > 5,Status)
.@	Auto-op:_useredit @ @ ! Ops (auto)
.@	Ops with pw:_useredit @ @ ?? Ops (w/pw)
  .-
.% $+ 	Auto-halfop:_useredit @ % ! Halfops (auto)
.% $+ 	Halfop with pw:_useredit @ % ?? Halfops (w/pw)
  .-
.+	Auto-voice:_useredit @ + ! Voiced (auto)
.+	Voice with pw:_useredit @ + ?? Voiced (w/pw)
  .-
.	None:_useredit @ x !  
.	Auto-deop:_useredit @ - ! Auto-deop
Color
.None:_useredit 
  .-
.Black	1:_useredit  01
.Blue	2:_useredit  02
.Green	3:_useredit  03
.Red	4:_useredit  04
.Brown	5:_useredit  05
.Purple	6:_useredit  06
.Orange	7:_useredit  07
.Yellow	8:_useredit  08
.Lt Green	9:_useredit  09
.Cyan	10:_useredit  10
.Lt Cyan	11:_useredit  11
.Lt Blue	12:_useredit  12
.Pink	13:_useredit  13
.Grey	14:_useredit  14
.Lt Grey	15:_useredit  15
.White	16:_useredit  16
  -
View
.All:userlist
  .-
  .$chan(1):userlist $chan(1)
  .$chan(2):userlist $chan(2)
  .$chan(3):userlist $chan(3)
  .$chan(4):userlist $chan(4)
  .$chan(5):userlist $chan(5)
  .-
.One channel...:userlist $_entry(-1,$null,Show users for what channel?)
.Default levels:userlist *
Find
.Nickname...:_userfind 1 $_entry(-1,$null,Enter nickname to find $chr(40) $+ wildcards OK $+ $chr(41))
.Address...:_userfind 2 $_entry(-1,$null,Enter address to find $chr(40) $+ wildcards OK $+ $chr(41))
  .-
.Level above...:_userfind 3 >= $_entry(-2,$null,Find levels above or equal to...?)
.Level below...:_userfind 3 <= $_entry(-2,$null,Find levels below or equal to...?)
.Level equal...:_userfind 3 == $_entry(-2,$null,Find level exactly equal to...?)
}
 
dialog useredit {
title "Add / Modify User"
  icon script\pnp.ico
  option dbu
  size -1 -1 190 142
 
text "&Nickname:", 201, 3 7 30 10, right
  edit "", 1, 35 5 50 11, autohs
text "(for reference only)", 202, 87 7 60 8
 
  icon 80, 151 6 8 8
text "(nicklist color)", 81, 162 4 23 15, center
 
text "&Usermask:", 203, 3 18 30 10, right
  combo 2, 35 16 125 65, drop sort edit
 
text "&Editing", 205, 5 36 22 10
  combo 71, 28 34 65 65, drop sort
text "Level:", 206, 95 36 33 10
 
button "&Add...", 56, 128 35 25 10
button "&Del", 57, 158 35 25 10
 
box "level:", 207, 5 49 95 67
 
radio "1 - &None", 101, 10 59 85 8, group
radio "25 - &Clone exempt", 125, 10 67 85 8
radio "50 - &Safe from protections", 150, 10 75 85 8
radio "60 - &Protected friend", 160, 10 83 85 8
radio "75 - &Protected with revenge", 175, 10 91 85 8
radio "&Custom:", 100, 10 103 40 8
  edit "100", 61, 50 101 20 11
 
box "Op status:", 40, 110 49 75 67
 
check "&Auto-deop", 21, 115 59 65 8, group
check "&Voiced", 22, 115 67 65 8
check "&Halfops", 23, 115 75 65 8
check "&Ops", 24, 115 83 65 8
check "&Password required:", 31, 115 93 65 8
  edit "", 32, 122 101 57 11, autohs pass
 
button "OK", 52, 5 125 40 12, OK
button "Cancel", 53, 51 125 40 12, cancel
button "&Remove", 54, 98 125 40 12
button "&Help", 55, 144 125 40 12, disable
 
  edit "", 210, 1 1 1 1, hide autohs
  edit "", 211, 1 1 1 1, hide autohs
  list 212, 1 1 1 1, hide
  edit "", 213, 1 1 1 1, hide autohs
  edit "", 214, 1 1 1 1, hide autohs
}
on *:DIALOG:useredit:init:*:{
  if ($wildtok(%.ule-raw,=color*,1,44)) hadd pnp.dlgcolor. $+ $dname 80 $calc($remove($ifmatch,=color) % 16)
  else hadd pnp.dlgcolor. $+ $dname 80 16
  did -g $dname 80 script\ $+ $hget(pnp.dlgcolor. $+ $dname,80) $+ .bmp
  did -a $dname 214 %.rest
  did -ac $dname 2 %.ule-mask
  if (%.ule-mask != %.mask) _ddaddm $dname 2 %.mask 3 4 010 2 011
  if (%.ule-nick) did -a $dname 1 $ifmatch
  elseif ((* !isin %.mask) && (! !isin %.mask) && (@ !isin %.mask) && (. !isin %.mask)) did -a $dname 1 %.mask
did -ac $dname 71 ( $+ Default $+ )
  did -a $dname 210 %.ule-raw
  if (%.ule-raw == $dlevel) did -b $dname 54
  else did -a $dname 211 %.ule-mask
  var %chan,%lvl,%num = $numtok(%.ule-raw,44),%file = $_cfg(userinfo.ini)
  :lvlloop
  %lvl = $gettok(%.ule-raw,%num,44)
  if (¬ isin %lvl) {
    %chan = $gettok(%lvl,1,172)
    if (=* iswm %chan) %chan = $right(%chan,-1)
    did -a $+ $iif((%chan == $active) || (%chan == %.selchan),c) $dname 71 %chan
    if ($readini(%file,n,%.ule-mask,%chan)) did -a $dname 212 %chan $ifmatch
  }
  if (%num > 1) { dec %num | goto lvlloop }
  if ($active ischan) _ddadd $dname 71 $active
  if ($readini(%file,n,%.ule-mask,*)) did -a $dname 212 * $ifmatch
  if ($left($did(71),1) == $chr(40)) did -b $dname 57
  unset %.ule-mask %.ule-raw %.ule-nick %.rest %.mask
  _uefreshen
}
on *:DIALOG:useredit:sclick:80:_cs-go 15 15 1
on *:DIALOG:useredit:sclick:54:{
  _cs-fin $dname
  remini $_cfg(userinfo.ini) $did(211)
  .ruser $did(211)
  scon -at1 _nickcol.updatemask $did(211) 1
  if ($did(214)) .timer -mio 1 0 user $did(214)
  else userlist +
  dialog -x $dname
}
on *:DIALOG:useredit:sclick:53:_cs-fin $dname | userlist +
on *:DIALOG:useredit:sclick:52:{
if ($did(2) == $null) _error You must specify a usermask to add a user.
  _uesave
  var %line,%file = $_cfg(userinfo.ini),%num = $did(212).lines
  if ($did(211)) {
    remini %file $did(211)
    .ruser $did(211)
    scon -at1 _nickcol.updatemask $did(211) 1
  }
  remini %file $did(2)
  if ($did(1)) writeini %file $did(2) nick $did(1)
  :loop
  if (%num) {
    %line = $did(212,%num)
    if ($gettok(%line,2,32)) writeini %file $did(2) %line
    dec %num | goto loop
  }
  if ($wildtok($did(210),=color*,1,44)) did -o $dname 210 1 $remtok($did(210),$ifmatch,1,44)
  if ($hget(pnp.dlgcolor. $+ $dname,80) < 16) did -o $dname 210 1 $addtok($did(210),=color $+ $_cprep($ifmatch),44)
  if ($did(210) == $dlevel) .ruser $did(2)
  else .auser $did(210) $did(2)
  _reorderblack
  scon -at1 _nickcol.updatemask $did(2) 1
  _cs-fin $dname
  if ($did(214)) .timer -mio 1 0 user $did(214)
  else userlist +
}
on *:DIALOG:useredit:sclick:56:{
var %newchan = $_entry(-1,$comchan($did(useredit,1),1),New channel to add userlevel for?)
if ((!$_ischan(%newchan)) || ($chr(44) isin %newchan)) _error That is not a valid channel name.
  _uesave
  if ($_finddid(useredit,71,%newchan)) {
    did -c useredit 71 $ifmatch
    if ($_chanlevel(%newchan,$did(useredit,210)) == $null) did -o useredit 210 1 $_leveledit(%newchan,$did(useredit,210),$calc($_level(*,$did(useredit,210))))
  }
  else {
    did -o useredit 210 1 $_leveledit(%newchan,$did(useredit,210),$calc($_level(*,$did(useredit,210))))
    did -ac useredit 71 %newchan
  }
  _uefreshen
}
on *:DIALOG:useredit:sclick:57:{
  did -u $dname 31
  _uesave
  did -o $dname 210 1 $_leveledit($did(71),$did(210))
  did -d $dname 71 $did(71).sel
  did -c $dname 71 $did(71).lines
  _uefreshen
}
on *:DIALOG:useredit:sclick:71:_uesave | _uefreshen | if ($left($did(71),-1) == $chr(40)) did -b $dname 57 | else did -e $dname 57
on *:DIALOG:useredit:sclick:100:did -e $dname 61
on *:DIALOG:useredit:sclick:31:did $iif($did(31).state,-e,-b) $dname 32
on *:DIALOG:useredit:sclick:*:{
  if ($did > 100) did -b $dname 61
  elseif ($did isnum 21-24) {
    if ($did != 21) did -u $dname 21
    if ($did != 22) did -u $dname 22
    if ($did != 23) did -u $dname 23
    if ($did != 24) did -u $dname 24
    if (($did(24).state) || ($did(23).state) || ($did(22).state)) { did -e $dname 31 | if ($did(31).state) did -e $dname 32 }
    else did -b $dname 31,32
  }
}
alias -l _uesave {
  var %lvl,%op,%pw,%chan = $iif($left($did(useredit,213),1) == $chr(40),*,$did(useredit,213))
  if ($did(useredit,101).state) { did -u useredit 101 | %lvl = 1 }
  elseif ($did(useredit,125).state) { did -u useredit 125 | %lvl = 25 }
  elseif ($did(useredit,150).state) { did -u useredit 150 | %lvl = 50 }
  elseif ($did(useredit,160).state) { did -u useredit 160 | %lvl = 60 }
  elseif ($did(useredit,175).state) { did -u useredit 175 | %lvl = 75 }
  else {
    did -u useredit 100
    if ($did(useredit,61) isnum) %lvl = $did(useredit,61)
    else %lvl = 1
  }
  if ($did(useredit,21).state) { did -u useredit 21 | %op = - }
  elseif ($did(useredit,22).state) { did -u useredit 22 | %op = + }
  elseif ($did(useredit,23).state) { did -u useredit 23 | %op = % }
  elseif ($did(useredit,24).state) { did -u useredit 24 | %op = @ }
  if (%op isin +%@) {
    if ($did(useredit,31).state) {
      if ($did(useredit,32) == $null) %pw = ?
      elseif ($left($did(useredit,32),1) isletter) %pw = $hash($did(useredit,32),32)
      else %pw = ??
    }
  }
  if (%pw == $null) { if ($_finddid(useredit,212,%chan)) did -d useredit 212 $ifmatch }
  elseif (%pw != ??) {
    if ($_finddid(useredit,212,%chan)) did -o useredit 212 $ifmatch %chan %pw
    else did -a useredit 212 %chan %pw
  }
  %lvl = %lvl $+ %op
  if ((%lvl == $_level(*,$did(useredit,210))) && (%chan != *) && ($_chanlevel(%chan,$did(useredit,210)) == $null)) return
  did -o useredit 210 1 $_leveledit(%chan,$did(useredit,210),%lvl)
}
alias -l _uefreshen {
  did -o useredit 213 1 $did(useredit,71)
  var %lvl = $_level($did(useredit,71),$did(useredit,210))
  if ($istok(1.25.50.60.75,$calc(%lvl),46)) { did -c useredit $calc(100 + $calc(%lvl)) | did -b useredit 61 }
  else { did -c useredit 100 | did -oe useredit 61 1 $calc(%lvl) }
  %lvl = $pos(-+%@,$right(%lvl,1))
  if (%lvl) did -c useredit $calc(20 + %lvl)
  if ((%lvl == $null) || (%lvl < 2)) { did -bu useredit 31 | did -br useredit 32 }
  else {
    if ($_finddid(useredit,212,$iif($left($did(useredit,71),1) == $chr(40),*,$did(useredit,71)))) {
      var %pw = $gettok($did(useredit,212,$ifmatch),2,32)
      did -ec useredit 31
      did -er useredit 32
      if (%pw != ?) did -a useredit 32 (encrypted)
    }
    else { did -eu useredit 31 | did -br useredit 32 }
  }
}
 
;
; Userlist CTCP commands
;
 
; OPME|HOPME|VOICEME #chan [pw]
ctcp &*:OPME:?:_doopc *@ *@ *@ o OP op $2-
ctcp &*:HOPME:?:_doopc *% *@ *@ h HOP halfop $2-
ctcp &*:VOICEME:?:_doopc *+ *% *@ v VOICE voice $2-
alias -l _doopc {
  var %error,%chan = $7
  var %level = $level($fulladdress)
  if (($wildtok(%level,$1,0,44) == 0) && ($wildtok(%level,$2,0,44) == 0) && ($wildtok(%level,$3,0,44) == 0)) return
  var %pw = $hash($8,32)
  var %sublvl = $_level($7,%level)
  hinc -u30 pnp.flood. $+ $cid opme. $+ $site
  if ($hget(pnp.flood. $+ $cid,opme. $+ $site) > 3) {
_linedance _qnotice $nick Too many requests- Ignoring CTCPs for 30 seconds.
    hinc -u30 pnp.flood. $+ $cid ignore.ctcp. $+ $site
%error = too many requests
  }
  elseif (!$_ischan($7)) {
_linedance _qnotice $nick Incorrect syntax-  $+ $5 $+ ME #chan [password]
%error = invalid syntax
    %chan = ?????
  }
  elseif (($1 iswm %sublvl) || ($2 iswm %sublvl) || ($3 iswm %sublvl)) {
    var %scan = $chr(44) $+ = $+ $7 $+ ¬
    if (%scan isin %level) %scan = $7
    else %scan = *
    var %thepw = $readini($_cfg(userinfo.ini),n,$maddress,%scan)
    if (%thepw == ?) {
var %cmd = PASS [#chan] new
_linedance _qnotice $nick Password not set yet- Please use %cmd to set one.
%error = password not yet set
    }
    elseif ((%thepw == $null) || (%thepw == %pw)) {
      if (($me isop $7) || (($me ishop $7) && ($3 == v))) { _init.mass $7 4 | _add.mass $7 + $4 $nick }
      else {
_linedance _qnotice $nick I cannot $_p2s($6) you in $7 $+ - I am not opped.
%error = you are not opped
      }
    }
    else {
_linedance _qnotice $nick Password incorrect- Ignoring CTCPs for 30 seconds.
      hinc -u30 pnp.flood. $+ $cid ignore.ctcp. $+ $site
%error = incorrect password
    }
  }
  else {
_linedance _qnotice $nick You don't have access in $7
%error = no access for channel
  }
if (%error) disptc -s %chan $5 $+ ME request from $:t($nick) failed $chr(40) $+ %error $+ $chr(41)
else disptc -s $7 $:t($nick) requested $5 $+ ME $chr(40) $+ granted $+ $chr(41)
  halt
}
; HELP
ctcp &*:HELP:?:{
  var %level = $level($fulladdress),%op = $wildtok(%level,*@,0,44),%hop = $wildtok(%level,*%,0,44),%voc = $wildtok(%level,*+,0,44)
  if ((%op == 0) && (%hop == 0) && (%voc == 0)) return
  hinc -u20 pnp.flood. $+ $cid opme. $+ $site
  if ($hget(pnp.flood. $+ $cid,opme. $+ $site) > 2) {
_linedance _qnotice $nick Too many requests- Ignoring CTCPs for 30 seconds.
    hinc -u30 pnp.flood. $+ $cid ignore.ctcp. $+ $site
var %error = too many requests
disps HELP request from $:t($nick) failed $chr(40) $+ %error $+ $chr(41)
  }
  else {
    if (%op) {
var %cmd = OPME #chan [password]
_linedance _qnotice $nick %cmd to request ops.
    }
    if (%hop) {
var %cmd = HOPME #chan [password]
_linedance _qnotice $nick %cmd to request ops.
    }
    if (%voc) {
var %cmd = VOICEME #chan [password]
_linedance _qnotice $nick %cmd to request voice.
    }
var %cmd = PASS [#chan] [old] new
_linedance _qnotice $nick %cmd to change your password.
disps $:t($nick) requested HELP $chr(40) $+ granted $+ $chr(41)
  }
  halt
}
; PASS [#chan] [old] new
ctcp &*:PASS:?:{
  var %level = $level($fulladdress),%error
  if (($wildtok(%level,*@,0,44) == 0) && ($wildtok(%level,*%,0,44) == 0) && ($wildtok(%level,*+,0,44) == 0)) return
  hinc -u30 pnp.flood. $+ $cid opme. $+ $site
  if ($hget(pnp.flood. $+ $cid,opme. $+ $site) > 3) {
_linedance _qnotice $nick Too many requests- Ignoring CTCPs for 30 seconds.
    hinc -u30 pnp.flood. $+ $cid ignore.ctcp. $+ $site
%error = too many requests
    %chan = *
  }
  elseif ($2 == $null) {
_linedance _qnotice $nick Incorrect syntax- PASS [#chan] [old] new
%error = invalid syntax
    %chan = *
  }
  else {
    if ($_ischan($2)) var %chan = $2,%old = $3,%new = $4
    else var %chan = *,%old = $2,%new = $3
    if (%new == $null) { %new = %old | %old = ? }
    else %old = $hash(%old,32)
    if (($left(%new,1) !isletter) && ($left(%new,1) !isnum)) {
_linedance _qnotice $nick Invalid password- must start with a letter or number.
%error = invalid password
    }
    elseif ($len(%new) < 5) {
_linedance _qnotice $nick Invalid password- must be at least five characters.
%error = password too short
    }
    else {
      var %num = $numtok(%level,44),%changes = 0
      :loop
      var %sub = $gettok(%level,%num,44)
      if (((%num == 1) || (=*¬* iswm %sub)) && ($right(%sub,1) isin +%@)) {
        if (%num == 1) var %subc = *
        else var %subc = $right($gettok(%sub,1,172),-1)
        var %oldpw = $readini($_cfg(userinfo.ini),n,$maddress,%subc)
        if (((%subc == %chan) || (%chan == *)) && (%oldpw == %old)) {
          writeini $_cfg(userinfo.ini) $maddress %subc $hash(%new,32)
          inc %changes
        }
        elseif ((%subc == %chan) && (%chan != *)) {
_linedance _qnotice $nick Password incorrect- Ignoring CTCPs for 30 seconds.
          hinc -u30 pnp.flood. $+ $cid ignore.ctcp. $+ $site
%error = incorrect password
        }
      }
      if (%num > 1) { dec %num | goto loop }
      if (%chan != *) {
if (%changes) _linedance _qnotice $nick Password changed to ' $+  $+ %new $+  $+ '
        elseif (%error == $null) {
_linedance _qnotice $nick You don't have access in %chan
%error = no access for channel
        }
      }
      else {
if (%changes) _linedance _qnotice $nick Password changed to ' $+  $+ %new $+  $+ ' ( $+ %changes change $+ $chr(40) $+ s $+ $chr(41) $+ )
        else {
_linedance _qnotice $nick Password incorrect- Ignoring CTCPs for 30 seconds.
          hinc -u30 pnp.flood. $+ $cid ignore.ctcp. $+ $site
%error = incorrect password
        }
      }
    }
  }
  if (%chan == *) %chan = ?????
if (%error) disptc -s %chan PASS request from $:t($nick) failed $chr(40) $+ %error $+ $chr(41)
else disptc -s %chan $:t($nick) requested PASS change $chr(40) $+ %changes change $+ $chr(40) $+ s $+ $chr(41) granted $+ $chr(41)
  halt
}
