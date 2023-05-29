; #= P&P -rs
; ########################################
; Peace and Protection
; Bulk info- channel info, clone info, server ping, stats, etc.
; ########################################

;
; Speedy clone scan
;

; /clones [-action] [#chan] [nick|mask]
alias _cln if ($nick($1,0)) { :loop | aline @.clonedat $gettok($address($nick($1,$ifmatch),5),2-,64) | if ($calc($ifmatch - 1)) goto loop }
alias clones {
  if ($ial == $false) _error The IAL is not enabled!You need the IAL for that command.
  _ssplit cc /clones $1-
  if ($chan(%.chan.cc).ial != $true) _error The IAL is not fully updated.Wait a few seconds and try again.
  if ($window(@Clones)) window -c @Clones
  _window 2. -hlnv -t20,35 @Clones -1 -1 -1 -1 @Clones
  var %num,%mask,%chan = %.chan.cc,%targ = %.targ.cc
  if ($_ismask(%targ)) {
    _recent userscan 5 0 %targ
    %mask = %targ
    goto fill
  }
  elseif (%targ) {
    %mask = $address($_ncc(%targ,%chan),2)
    goto fill
  }
  window -hlns @.clonedat
  _cln %chan
  :loop2
  if ($line(@.clonedat,1)) {
    if ($ifmatch == $line(@.clonedat,2)) {
      %mask = *!*@ $+ $ifmatch
      :fill
      %num = 1
      :loop3
      if ($ialchan(%mask,%chan,%num)) {
        aline -a @Clones $replace($ifmatch,!,	,@,	)
        inc %num
        goto loop3
      }
      if (%targ) goto done
      dline @.clonedat 1- $+ $calc(%num - 1)
      aline @Clones  
    }
    else dline @.clonedat 1
    goto loop2
  }
  :done
  window -c @.clonedat

  if ($_ismask(%targ)) {
    if ($sline(@Clones,0)) titlebar @Clones ( $+ %chan $+ ) $ifmatch user $+ $chr(40) $+ s $+ $chr(41) matching %targ
    else {
      window -c @Clones | _dowcleanup @Clones
      disprc %chan No users matching $:s(%targ) found on channel.
    }
  }
  elseif (%targ) {
    if ($sline(@Clones,0) > 1) titlebar @Clones ( $+ %chan $+ ) $ifmatch clones from %targ
    else {
      window -c @Clones | _dowcleanup @Clones
      disprc %chan User $:t(%targ) does not have any clones.
    }
  }
  else {
    if ($sline(@Clones,0)) titlebar @Clones ( $+ %chan $+ ) $ifmatch clones found
    else {
      window -c @Clones | _dowcleanup @Clones
      disprc %chan No clones found on channel.
    }
  }
  if ($window(@Clones)) {
    window -aw @Clones
    iline -a @Clones 1 Select one or more users and right-click for options.
    sline -r @Clones 1
    iline @Clones 2  
    iline @Clones 3 Nickname	Userid	Hostname
    iline @Clones 4  
  }
}

alias -l _clonepop set -u1 %.clonepop $iif(($sline($active,1).ln > 4) && ($numtok($sline($active,1),9) > 1),1,0)
menu @Clones {
  $_clonepop:{ }
  $iif(%.clonepop,Ping):ping $_clonesel
  $iif(%.clonepop,Whois):whois $_clonesel
  -
  $iif(%.clonepop,Warn...):_clonedo warn $_entry(0,$_s2p($_clonewarn),Warning to send?)
  -
  $iif(%.clonepop,Kick...):_clonedo kick $_rentry(kick,0,$_s2p($_clonewhy),Reason for kick?)
  $iif(%.clonepop,Cloneban...):_clonedo cb $_rentry(kick,0,$_s2p($_clonewhy),Reason for cloneban?)
  -
  Select all
  .$iif(%.clonepop,$replace($gettok($sline($active,1),2-3,9),	,@	)):_selectallw $active 5 * $+ $gettok($sline($active,1),2-3,9)
  .$iif(%.clonepop,	 $+ $gettok($sline($active,1),3,9)):_selectallw $active 5 * $+ $gettok($sline($active,1),3,9)
  .-
  .	All users:_selectallw $active 5 *	*
  -
}
alias -l _clonewarn if (clone isin $gettok($window($active).title,3,32)) { if ($_dlgi(clonewarn)) return $_readprep($ifmatch) | return I have detected &num& clones from you $chr(40) $+ &host& $+ $chr(41) Please remove them at once. } | return
alias -l _clonewhy if (clone isin $gettok($window($active).title,3,32)) { if ($_dlgi(clonekick)) return $_readprep($ifmatch) | return &num& clones detected from &host& $chr(40) $+ &count& $+ $chr(41) } | return $_msg(kick)
alias -l _clonech return $right($left($gettok($window($active).title,1,32),-1),-1)
alias -l _clonedo {
  ; (keep kick msgs from showing up in recents)
  set -u %.punishwait 1
  var %host,%total,%count,%mask1,%mask2,%last,%num = 1,%chan = $_clonech
  :loop
  if ($numtok($sline($active,%num),9) == 1) goto skip
  if ($gettok($sline($active,%num),3,9) != %last) {
    %count = 1
    %last = $ifmatch
    %mask1 = *	 $+ $ifmatch
    %mask2 = *	 $+ $gettok($sline($active,%num),2-3,9)
    %total = $fline($active,%mask1,0)
    if (%total != $fline($active,%mask2,0)) %host = $replace($gettok($sline($active,%num),2-3,9),	,@)
    else %host = %last
    ; (these remain set for the kick or notice later as well)
    set -u %&num& %total
    set -u %&host& %host
    if ($1 == cb) cb %chan %host -1 $2-
  }
  else inc %count
  ; (must pre-replace kickseq to preempt the kick replacement of it)
  if ($1 == kick) kick %chan $gettok($sline($active,%num),1,9) $replace($2-,&kickseq&,%count)
  if ($1 == warn) notice $gettok($sline($active,%num),1,9) $msg.compile($2-,&nick&,$gettok($sline($active,%num),1,9),&chan&,%chan)
  :skip | if (%num < $sline($active,0)) { inc %num | goto loop }
  unset %&num& %&host&
  if (clone isin $gettok($window($active).title,3,32)) _dlgw $iif($1 == warn,clonewarn,clonekick) $_writeprep($2-)
}
alias -l _clonesel {
  var %all,%num = 1
  :loop
  if ($numtok($sline($active,%num),9) > 1) %all = $addtok(%all,$gettok($sline($active,%num),1,9),44)
  if (%num < $sline($active,0)) { inc %num | goto loop }
  return %all
} 

;
; Chan info
;
alias chaninfo {
  _notconnected /chaninfo
  _simsplit ci /chaninfo $1-
  hadd pnp. $+ $cid -chaninfo $hget(pnp. $+ $cid,-chaninfo) %.chan.ci
  disprc %.chan.ci Retrieving channel info...
  .raw mode %.chan.ci
  .raw topic %.chan.ci
  .raw names %.chan.ci
}
alias count {
  _simsplit ci /count $1-
  if ($me !ison %.chan.ci) _error You are not on %.chan.ci $+ ! $+ $chr(40) $+ You must be on a channel to use /count $+ $chr(41)

  set -u %::chan %.chan.ci
  set -u %::count $nick(%.chan.ci,0)
  set -u %::countreg $nick(%.chan.ci,0,r)
  var %num = 1,%exclude = $chr(32)
  while (%num <= $len($prefix)) {
    set -u %::count $+ $mid($prefix,%num,1) $nick(%.chan.ci,0,$mid($prefix,%num,1),%exclude)
    %exclude = %exclude $+ $mid($prefix,%num,1)
    inc %num
  }
  set -u %:echo echo $:c1 -ti2 %.chan.ci
  set -u %:linesep dispr-div %.chan.ci

  dispr-div %.chan.ci
  theme.text RAW.366uc
  dispr-div %.chan.ci
}

; /scan [#chan] [[=]adhilmrsw]
alias scan {
  if (=* iswm $1) %.msg.ci = $1 | else _simsplit ci /scan $1-
  if (=* iswm %.msg.ci) { _cfgw scan.flag $right(%.msg.ci,-1) | dispa Default scan flags set to $:s($right(%.msg.ci,-1)) | return }
  if (%.msg.ci == $null) {
    set %.chan.ci %.chan.ci
    _ssplay Dialog
    _simsplit ci /scan $$dialog(scan,scan,-4)
  }
  disprc %.chan.ci Scanning channel...
  _who.queue %.chan.ci _fin.scan $gettok(%.msg.ci,1,32)
}
alias _fin.scan {
  if ($hget(pnp. $+ $cid,-dwho.num) < 1) {
    disprc $2 Scan results - No users found
    return
  }
  var %ppl,%best,%num,%where,%win,%flags = $1
  if ($remove(%flags,r,d)) {
    if (r isin %flags) { _info /scan | %win = @Info } | else %win = $2
    dispr-div %win
    disptc %win $2 Scan results for $:t($hget(pnp. $+ $cid,-dwho.num)) user $+ $chr(40) $+ s $+ $chr(41) $+ -
    if (a isin %flags) {
      var %here = $calc($hget(pnp. $+ $cid,-dwho.num) - $hget(pnp. $+ $cid,-dwho.gone))
      disptc %win $2 Away- $:t($hget(pnp. $+ $cid,-dwho.gone)) user $+ $chr(40) $+ s $+ $chr(41) $:s($_p($hget(pnp. $+ $cid,-dwho.gone),$hget(pnp. $+ $cid,-dwho.num)))
      disptc %win $2 Here- $:t(%here) user $+ $chr(40) $+ s $+ $chr(41) $:s($_p(%here,$hget(pnp. $+ $cid,-dwho.num)))
    }
    if (w isin %flags) {
      if ($hget(pnp. $+ $cid,-dwho.gone) == 0) {
        if (a !isin %flags) disptc %win $2 Away- None
      }
      else {
        disptc %win $2 Away- $:l($hget(pnp. $+ $cid,-dwho.away))
        var %count = 1
        while ($hget(pnp. $+ $cid,-dwho.away $+ %count)) {
          disptc %win $2 Away- $:l($hget(pnp. $+ $cid,-dwho.away $+ %count))
          inc %count
        }
      }
    }
    if (i isin %flags) {
      var %count = $numtok($hget(pnp. $+ $cid,-dwho.ircop),32)
      if (%count < 1) {
        disptc %win $2 IRCop- None
      }
      else {
        disptc %win $2 IRCop- $:t(%count) user $+ $chr(40) $+ s $+ $chr(41) $:s($_p(%count,$hget(pnp. $+ $cid,-dwho.num)))
        disptc %win $2 IRCop- $:l($hget(pnp. $+ $cid,-dwho.ircop))
        var %count = 1
        while ($hget(pnp. $+ $cid,-dwho.ircop $+ %count)) {
          disptc %win $2 IRCop- $:l($hget(pnp. $+ $cid,-dwho.ircop $+ %count))
          inc %count
        }
      }
    }
    if (h isin %flags) disptc %win $2 Hops- $:t($round($calc($hget(pnp. $+ $cid,-dwho.hops) / $hget(pnp. $+ $cid,-dwho.num)),1)) average hops among $:t($_who.countseries(-dwho.serv)) unique server $+ $chr(40) $+ s $+ $chr(41)
    if ((s isin %flags) || (l isin %flags)) {
      var %count,%best = -1
      ; Find best server
      :loop0
      %num = $numtok($hget(pnp. $+ $cid,-dwho.serv $+ %count),32)
      :loop1
      var %test = $gettok($hget(pnp. $+ $cid,-dwho.serv $+ %count),%num,32)
      if ($_who.countseries(-dwho. $+ %test) > %best) { %best = $ifmatch | %where = %test }
      if (%num > 1) { dec %num | goto loop1 }
      inc %count
      ; (loop through all serv who vars in case there are multiple lists)
      if ($hget(pnp. $+ $cid,-dwho.serv $+ %count) != $null) goto loop0
      ; If our server is tied for best, show that instead
      if ($_who.countseries(-dwho. $+ $server) >= %best) { %best = $ifmatch | %where = $server }
      ; Decrease best count because this count includes a token for num hops
      dec %best
      if ((m isin %flags) && ($me ison $2) && (%where == $server)) goto your
      _recseen 10 serv %where
      if (s isin %flags) disptc %win $2 Favorite server- $:s(%where) with $:t(%best) user $+ $chr(40) $+ s $+ $chr(41) $:s($_p(%best,$hget(pnp. $+ $cid,-dwho.num)))
      if (l isin %flags) {
        %ppl = $hget(pnp. $+ $cid,-dwho. $+ %where)
        %ppl = $gettok(%ppl,2-,32)
        if (s isin %flags) disptc %win $2 Favorite server- $:l(%ppl)
        else disptc %win $2 Favorite server- ( $+ $:s(%where) $+ ) $:l(%ppl)
        var %count = 1
        while ($hget(pnp. $+ $cid,-dwho. $+ %where $+ %count)) {
          disptc %win $2 Favorite server- $:l($hget(pnp. $+ $cid,-dwho. $+ %where $+ %count))
          inc %count
        }
      }
    }
    if ((m isin %flags) && ($me ison $2) && ($hget(pnp. $+ $cid,-dwho. $+ $server))) {
      :your
      %ppl = $hget(pnp. $+ $cid,-dwho. $+ $server)
      %ppl = $gettok(%ppl,2-,32)
      %best = $_who.countseries(-dwho. $+ $server) - 1
      %num = %best - 1
      if (%where == $server) %where = Favorite server (your server)-
      else %where = Your server-
      disptc %win $2 %where $:s($server) with $:t(%best) user $+ $chr(40) $+ s $+ $chr(41) $:s($_p(%best,$hget(pnp. $+ $cid,-dwho.num))) (not counting you- $:t(%num) user $+ $chr(40) $+ s $+ $chr(41) $:s($_p(%num,$hget(pnp. $+ $cid,-dwho.num))) $+ )
      disptc %win $2 %where $:l(%ppl)
      var %count = 1
      while ($hget(pnp. $+ $cid,-dwho. $+ $server $+ %count)) {
        disptc %win $2 %where $:l($hget(pnp. $+ $cid,-dwho. $+ $server $+ %count))
        inc %count
      }
    }
    dispr-div %win
  }
  if (d isin %flags) {
    if ($window(@ServerDetails)) window -c @ServerDetails
    _window 2.6 -lv -t25,30,35,40 @ServerDetails -1 -1 -1 -1 @ServerDetails
    %num = $_who.countseries(-dwho.serv)
    titlebar @ServerDetails - $2 ( $+ $hget(pnp. $+ $cid,-dwho.num) user $+ $chr(40) $+ s $+ $chr(41) / %num server $+ $chr(40) $+ s $+ $chr(41) $+ )
    var %count
    :loop2a
    var %var = -dwho.serv $+ %count,%num = $numtok($hget(pnp. $+ $cid,%var),32)
    :loop2b
    %where = $gettok($hget(pnp. $+ $cid,%var),%num,32)
    %ppl = $hget(pnp. $+ $cid,-dwho. $+ %where)
    var %shppl = $_s2cs($gettok(%ppl,2-,32))
    var %hops = $gettok(%ppl,1,32)
    if ($hget(pnp. $+ $cid,-dwho. $+ %where $+ 1)) %shppl = %shppl (...)
    aline @ServerDetails %where $+ 	 $gettok(%ppl,1,32) 	???	 $calc($_who.countseries(-dwho. $+ %where) - 1) 	 $+ %shppl
    if (%num > 1) { dec %num | goto loop2b }
    inc %count
    if ($hget(pnp. $+ $cid,-dwho.serv $+ %count) != $null) goto loop2a
    iline @ServerDetails 1 Double-click to connect to a server $+ $chr(44) right-click for options
    iline @ServerDetails 2 $chr(40) $+ 'hops' is a count of servers between you and a given server $+ $chr(41)
    iline @ServerDetails 3  
    iline @ServerDetails 4 Server	Hops	Ping	Num	Users
    iline @ServerDetails 5  
    if (($hget(pnp,detailsort) == 1) || ($hget(pnp,detailsort) == 4)) _servdsort $ifmatch
    else _servdsort 2
    window -b @ServerDetails
  }
}

menu @ServerDetails {
  dclick:if ($1 > 5) server $gettok($line(@ServerDetails,$1),1,9) ?
  $iif($sline(@ServerDetails,1).ln > 5,Connect...):server $gettok($sline(@ServerDetails,1),1,9) ?
  -
  $iif($sline(@ServerDetails,1).ln > 5,Ping server):_sdping 1
  Ping all:_sdping 6
  -
  Sort
  .$iif($hget(pnp,detailsort) == 1,$style(1)) by name:_servdsort 1
  .$iif($hget(pnp,detailsort) == 2,$style(1)) by hops:_servdsort 2
  .$iif($hget(pnp,detailsort) == 3,$style(1)) by ping:_servdsort 3
  .$iif($hget(pnp,detailsort) == 4,$style(1)) by user count:_servdsort 4
  -
  Refresh:scan $gettok($window(@ServerDetails).title,2,32) d
}
alias _servdsort {
  hadd pnp detailsort $1
  _dosort @ServerDetails 6 $1 $iif($1 & 1,9,32) $iif($1 < 2,0,1) $iif($1 > 3,1,0)
}
alias -l _sdping {
  var %line,%num = $1
  :loop
  if ($1 == 6) %line = $line(@ServerDetails,%num) | else %line = $sline(@ServerDetails,%num)
  if (%line) {
    _linedance .sping $gettok($ifmatch,1,9) @ServerDetails
    rline -a @ServerDetails $iif($1 == 6,%num,$sline(@ServerDetails,%num).ln) $puttok(%line,(ping...),3,9)
    inc %num | goto loop
  }
}

; /scan dialog
dialog scan {
  title "Channel Scan"
  icon script\pnp.ico
  option map
  size -1 -1 233 132

  text "&Channel to scan:", 249, 6 8 73 12, right
  edit "", 100, 82 6 140 13, autohs result

  box "Scan and show:", 250, 6 24 220 65

  check "&Away / here count", 1, 13 36 85 9
  check "&Who is away", 2, 13 49 85 9
  check "&IRCops", 3, 13 61 85 9
  check "&Average server hops", 4, 13 73 85 9

  check "&Favorite server", 5, 101 36 120 9
  check "&List who is on favorite server", 6, 101 49 120 9
  check "&Who is on my server", 7, 101 61 120 9
  check "&Server details (separate window)", 8, 101 73 120 9

  check "&Route to separate window", 9, 13 95 120 9

  button "Scan", 201, 13 111 40 14, OK default
  button "&Save as default options", 202, 66 111 93 14, disable
  button "Cancel", 203, 173 111 40 14, cancel
}
on *:DIALOG:scan:init:*:{
  var %num = 1,%flag = $_cfgi(scan.flag)
  if ($remove(%flag,r) == $null) %flag = ahi
  :loop
  if ($mid(awihslmdr,%num,1) isin %flag) did -c $dname %num
  if (%num < 9) { inc %num | goto loop }
  if (%.chan.ci != $null) did -o $dname 100 1 %.chan.ci
  unset %.chan.ci
}
alias -l _scanflag {
  var %flags,%num = 1
  :loop
  if ($did(%num).state) %flags = %flags $+ $mid(awihslmdr,%num,1)
  if (%num < 9) { inc %num | goto loop }
  return %flags
}
on *:DIALOG:scan:sclick:201:{
  if ($_ischan($did(100))) did -o $dname 100 1 $did(100) $_scanflag
  else { did -f $dname 100 | halt }
}
on *:DIALOG:scan:sclick:202:{
  var %flag = $_scanflag
  scan = $+ %flag
  did -b $dname 202 | did -t $dname 202 | did -ft $dname 201
}
on *:DIALOG:scan:sclick:*:{
  if ($did isnum 1-9) {
    if ($remove($_scanflag,r)) did -e $dname 201,202
    else did -b $dname 201,202
  }
}

; /sping nick|server
;;; multiple nicks or other no such user causes problems
alias _dosping {
  if ($hget(pnp.twhois. $+ $cid,error)) disptn $_cfgi(eroute) $hget(pnp.twhois. $+ $cid,nick) No such user $chr(40) $+ $:s(sping) $+ $chr(41)
  elseif (* isin $hget(pnp.twhois. $+ $cid,wserver)) disptn $_cfgi(eroute) $hget(pnp.twhois. $+ $cid,nick) Sorry $+ $chr(44) server ping does not work on this server
  else sping $hget(pnp.twhois. $+ $cid,nick) $hget(pnp.twhois. $+ $cid,wserver)
}
alias sping {
  if ($1 == $null) _qhelp /sping
  if (. !isin $1) {
    if ($2 == $null) {
      var %target = $_nc($1)
      disptn $_cfgi(eroute) %target Looking up server of user...
      _whois.queue %target 0 _dosping
      return
    }
    if (* isin $2) hadd pnp. $+ $cid -servmask $hget(pnp. $+ $cid,-servmask) $2
    hadd pnp. $+ $cid -servping. $+ $2 $ticks $1
    .raw time $2
    disptn $_cfgi(eroute) $1 Pinging server $:s($2)
    return
  }
  if (* isin $1) hadd pnp. $+ $cid -servmask $hget(pnp. $+ $cid,-servmask) $1
  hadd pnp. $+ $cid -servping. $+ $1 $ticks $2
  .raw time $1
  disp Pinging server $:s($1)
}

;
; Port scan
;

alias ports hadd pnp. $+ $cid -portscan 1 | var %win = $_mservwin(@Ports) | if ($window(%win)) { _dowclose %win | window -c %win } | .raw stats l

raw &211:*:{
  if (!$hget(pnp. $+ $cid,-portscan)) return
  if (($2 !isnum) && ($3 !isnum)) halt
  var %win = $_mservwin(@Ports)
  if (($window(%win) == $null) || ($line(%win,5) ==  )) {
    if ($window(%win)) clear %win
    else _window 2.6 -lkv -t20,35+l %win $_center(350,350) @Ports
    titlebar %win - $nick
  }
  elseif ($gettok($window(%win).title,2,32) != $nick) halt
  if (($nick !isin $2) && ($left($2,2) != *[) && ($right($2,3) != [*])) halt
  var %mask = $remove($gettok($2,2,91),])
  if (%mask == $null) %mask = *.6667
  var %port = $gettok(%mask,-1,46)
  if ((%port !isnum) || (%port < 256)) halt
  if (($nick == $server) && (%port == $port)) goto okay
  if (($remove(%mask,%port,.,!,@,*,?,-,[,],unknown) != $null) && ($remove(%mask,.,1,2,3,4,5,6,7,8,9,0) != $null)) halt
  if (($gettok($window(%win).title,3,32) > 1000) && ($5 < 10)) halt
  :okay
  var %switch,%speed = $5 + $7
  if ((%speed < $gettok($window(%win).title,3,32)) || ($gettok($window(%win).title,3,32) == $null)) { titlebar %win $gettok($window(%win).title,1-2,32) %speed | %switch = -s }
  var %num = 1
  if ($hget(pnp,portsort) == 0) {
    :loop0
    if ((%num <= $line(%win,0)) && ($strip($remove($gettok($line(%win,%num),2,32),[,])) < %port)) { inc %num | goto loop0 }
  }
  else {
    :loop1
    if ((%num <= $line(%win,0)) && ($strip($gettok($gettok($line(%win,%num),4,32),1,107)) < $calc(%speed / $8))) { inc %num | goto loop1 }
  }
  %port = [[ $+ %port $+ ]]
  var %ks =  $+ $round($calc(%speed / $8),2)
  iline %switch %win %num Port $:t(%port) >> $+ $_p2s($:s(%ks)) $+ k/s	 	( $+ $:s($round($calc(%speed / 1024),0)) $+ mb total traffic $+ )
  halt
}
raw 219:*:{
  if (!$hget(pnp. $+ $cid,-portscan)) return
  hdel pnp. $+ $cid -portscan
  var %win = $_mservwin(@Ports)
  if ($nick == $gettok($window(%win).title,2,32)) {
    iline %win 1 Found $:t($line(%win,0)) active ports on $nick
    var %method = $iif($hget(pnp,portsort) == 0,port number,speed $chr(40) $+ fastest ports first $+ $chr(41))
    iline %win 2 Currently sorted by %method
    iline %win 3 Double click to connect to a port $+ $chr(44) right-click for options
    iline %win 4 $chr(40) $+ note- 'total traffic' is measured over entire uptime of port $+ $chr(41)
    iline %win 5  
    if ($sline(%win,1).ln) rline -s %win $ifmatch $puttok($sline(%win,1),$:b((fastest)),2,9)
    titlebar %win $gettok($window(%win).title,1-2,32)
    halt
  }
}

menu @Ports {
  dclick:if ($1 < 6) halt | server $gettok($window($active).title,2,32) $remove($strip($gettok($line($active,$1),2,32)),[,])
  Connect to port:if ($sline($active,1).ln < 6) halt | server $gettok($window($active).title,2,32) $remove($strip($gettok($sline($active,1),2,32)),[,])
  -
  $iif($hget(pnp,portsort) == 0,Sort by speed):{
    _dosort $active 6 4 32 1 0
    hadd pnp portsort 1
    var %method = speed $chr(40) $+ fastest ports first $+ $chr(41)
    rline $active 2 Currently sorted by %method
  }
  $iif($hget(pnp,portsort) != 0,Sort by port number):{
    _dosort $active 6 2 91 1 0
    hadd pnp portsort 0
    var %method = port number
    rline $active 2 Currently sorted by %method
  }
  Get new list:ports
}

;
; Nearby servers
;
raw 364:*:{
  if (!$hget(pnp. $+ $cid,-ns.min)) return
  if (($4 >= $hget(pnp. $+ $cid,-ns.min)) && ($4 <= $hget(pnp. $+ $cid,-ns.max))) {
    dispa   - $:s($2) ( $+ $4 hops)
    hadd pnp. $+ $cid -ns.found $hget(pnp. $+ $cid,-ns.found) $2
  }
  halt
}
raw 365:*:{
  if (!$hget(pnp. $+ $cid,-ns.min)) return
  if ($hget(pnp. $+ $cid,-ns.found)) {
    _Q.fkey 1 $calc($ctime + 300) _randserv $hget(pnp. $+ $cid,-ns.found)
    dispa Found $:t($numtok($hget(pnp. $+ $cid,-ns.found),32)) servers. Press $:s($result) to select one randomly.
  }
  else dispa No servers found in this range.
  hdel -w pnp. $+ $cid -ns.*
  halt
}
alias _randserv server $gettok($1-,$_pprand($numtok($1-,32)),32) ?

dialog nearserv {
  title "Nearby Servers"
  icon script\pnp.ico
  option map
  size -1 -1 117 70

  text "List servers that are-", 1, 6 6 106 12

  text "&At least", 2, 6 19 44 12, right
  edit "1", 3, 53 17 16 13, autohs result
  text "hop(s) away", 4, 72 19 40 12

  text "&No more than", 5, 6 33 44 12, right
  edit "", 6, 53 30 16 13
  text "hop(s) away", 7, 72 33 40 12

  button "OK", 101, 20 49 36 14, OK default
  button "Cancel", 102, 64 49 36 14, cancel
}
on *:DIALOG:nearserv:sclick:101:did -o $dname 3 1 $gettok($did(3),1,32) $gettok($iif($did(6),$did(6),+),1,32)

alias nearserv {
  var %min = 1,%max = 2
  if ($1 == ?) {
    _ssplay Dialog
    %min = $$dialog(nearserv,nearserv,-4)
    %max = $gettok(%min,2,32)
    %min = $gettok(%min,1,32)
  }
  elseif ($1) { %min = $1 | %max = $iif($2,$2,$1) }
  if (%max == +) %max = 99
  if (%min !isnum) %min = 1
  if (%max !isnum) %max = 2
  if (%min > %max) { var %tmp = %min | %min = %max | %max = %tmp }
  dispa Nearby servers- $chr(40) $+ $:t(%min) to $:t(%max) hop $+ $chr(40) $+ s $+ $chr(41) away $+ $chr(41)
  links
  hdel pnp. $+ $cid -ns.found
  hadd pnp. $+ $cid -ns.min %min
  hadd pnp. $+ $cid -ns.max %max
}

alias stats {
  if ($1) var %stats = $1-
  else var %stats = $_entry(-1,$null,Server stats to request? $+ $chr(40) $+ Enter a single lowercase or uppercase letter. $+ $chr(41))
  stats %stats
  if ((%stats !isincs gkmou) && ($len(%stats) == 1) && (%stats isletter)) _recent stats 5 0 %stats
}

