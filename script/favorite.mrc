; #= P&P -rs
; ########################################
; Peace and Protection
; Favorites, also default theme
; ########################################
 
;
; Favorites
;
 
; /fav
; /fav + [network|all] [#channel|server[ port]]...
; /fav - [network|all|*] [#channel|server]...
; /fav j [network|*] [on/off/x]
; /fav c [network|*] [on/off/x]
; /fav i network|* nick alt email realname...
; /fav k [network|all|*]
; Defaults to * where it can, 'all' for +
alias fav {
  var %todo,%net,%chan,%fav,%serv,%num = 1
  if (($_ischan($2)) || (. isin $2)) %todo = $_c2s($2-)
  else { %todo = $_c2s($3-) | %net = $2 }
  if ($1 == k) {
if ($_favnets == $null) dispa Your favorites are already empty.
    elseif (($2 == *) || ($2 == $null)) {
_okcancel 1 Delete ALL favorite channels/servers?
      remini $_cfg(config.ini) fav
      remini $_cfg(config.ini) favopt
      remini $_cfg(config.ini) favserv
      _cfgxw favopt all 0 0 - - -
dispa All favorites deleted.
    }
    else {
_okcancel 1 Delete ALL favorite channels/servers? ( $+ $2 $+ )
      remini $_cfg(config.ini) fav $2
      remini $_cfg(config.ini) favopt $2
      remini $_cfg(config.ini) favserv $2
      if ($2 == all) _cfgxw favopt all 0 0 - - -
dispa All favorites deleted. ( $+ $2 $+ )
    }
  }
  elseif ($1 == +) {
    if (!%net) %net = all
    if (%todo == $null) {
      var %check
if ((%net == all) && ($hget(pnp. $+ $cid,net) != Offline)) %net = $ifmatch
if (%net != all) %check = Only for %net network favorites
%todo = $_c2s($_entry(0,$iif($active ischan,$active),Channel $+ $chr(40) $+ s $+ $chr(41) or server $+ $chr(40) $+ s $+ $chr(41) to add to favorites?,1,%check))
      if (!%.entry.checkbox) %net = all
    }
    %fav = $_cfgx(fav,%net)
    %serv = $_cfgx(favserv,%net)
    :loop
    %chan = $gettok(%todo,%num,32)
    if ((!$_ischan(%chan)) && (. isin %chan)) {
      ; Server- port too?
      if ($gettok(%todo,$calc(%num + 1),32) isnum) {
        %chan = %chan $+ : $+ $ifmatch
        inc %num
      }
if (%net == all) dispa Can't add a server $chr(40) $+ $:t(%chan) $+ $chr(41) to favorites for all networks- you must specify a network.
elseif ($istok(%serv,%chan,32)) dispa $:t(%chan) is already in your favorites. $chr(40) $+ cannot add $+ $chr(41)
else { %serv = $addtok(%serv,%chan,32) | dispa Added $:t(%chan) to favorites. $chr(40) $+ on %net $+ $chr(41) }
      inc %num | goto loop
    }
    elseif (%chan) {
      %chan = $_patch(%chan)
if ($istok(%fav,%chan,32)) dispa $:t(%chan) is already in your favorites. $chr(40) $+ cannot add $+ $chr(41)
else { %fav = $addtok(%fav,%chan,32) | dispa $iif(%net == all,Added $:t(%chan) to favorites. $chr(40) $+ all networks $+ $chr(41),Added $:t(%chan) to favorites. $chr(40) $+ on %net $+ $chr(41)) }
      inc %num | goto loop
    }
    _cfgxw fav %net %fav
    _cfgxw favserv %net %serv
    if ($_cfgx(favopt,%net) == $null) _cfgxw favopt %net $iif($gettok($_cfgx(favopt,all),1,32),1,0) 0 - - -
  }
  elseif ($1 == -) {
if (%todo == $null) %todo = $_c2s($_entry(0,$iif($active ischan,$active,$null),Channel $+ $chr(40) $+ s $+ $chr(41) or server $+ $chr(40) $+ s $+ $chr(41) to remove from favorites?))
    if ((%net == $null) || (%net == *)) {
      %net = $_favnets
if (%net == $null) _error You have no favorites to remove.
    }
    var %numn = $numtok(%net,44)
    var %found
    while (%numn) {
      var %netc = $gettok(%net,%numn,44)
      %num = 1
      %fav = $_cfgx(fav,%netc)
      %serv = $_cfgx(favserv,%netc)
      :loopA
      %chan = $gettok(%todo,%num,32)
      if ((!$_ischan(%chan)) && (. isin %chan)) {
        if ($istok(%serv,%chan,32)) {
          %serv = $remtok(%serv,%chan,32)
          %found = $addtok(%found,%chan,32)
dispa Removed $:t(%chan) from favorites. $chr(40) $+ on %netc $+ $chr(41)
        }
        if ($wildtok(%serv,%chan $+ :*,1,32)) {
          %serv = $remtok(%serv,$ifmatch,32)
          %found = $addtok(%found,%chan,32)
dispa Removed $:t(%chan) from favorites. $chr(40) $+ on %netc $+ $chr(41)
        }
        inc %num
        goto loopA
      }
      elseif (%chan) {
        %chan = $_patch(%chan)
        if ($istok(%fav,%chan,32)) {
dispa $iif(%netc == all,Removed $:t(%chan) from favorites. $chr(40) $+ all networks $+ $chr(41),Removed $:t(%chan) from favorites. $chr(40) $+ on %netc $+ $chr(41))
          %fav = $remtok(%fav,%chan,32)
          %found = $addtok(%found,%chan,32)
        }
        inc %num
        goto loopA
      }
      _cfgxw fav %netc %fav
      _cfgxw favserv %netc %serv
      if ((%fav == $null) && (%serv == $null)) _cfgxw favopt %netc
      dec %numn
    }
    ; Show fails
    %num = 1
    :loopF
    %chan = $gettok(%todo,%num,32)
    if (%chan) {
if (!$istok(%found,%chan,32)) dispa $:t(%chan) is not in your favorites. $chr(40) $+ cannot remove $+ $chr(41)
      inc %num
      goto loopF 
    }
  }
  ; /fav j [network|*] [on/off/x]
  ; Join favorites or turn auto-join on off
  ; [x] surpesses any errors and only joins those with auto-join on
  elseif ($1 == j) {
if (($2 == on) || ($2 == on) || ($2 == off) || ($2 == off) || ($2 == x)) tokenize 32 j * $2
if (($3 == on) || ($3 == on) || ($3 == off) || ($3 == off)) {
      if (($2 == *) || ($2 == all)) {
        %net = $_favnets
        %num = $numtok(%net,44)
        while (%num) {
          var %netc = $gettok(%net,%num,44)
          _cfgxw favopt %netc $_o2tf($3) $gettok($_cfgx(favopt,%netc),2-,32)
          dec %num
        }
if ($_o2tf($3)) dispa Favorites will be automatically joined when you connect to IRC. $chr(40) $+ all networks $+ $chr(41)
else dispa Favorites will not be joined when you connect to IRC. $chr(40) $+ all networks $+ $chr(41)
      }
      else {
if ($_cfgx(favopt,$2) == $null) You don't have any favorites for $2 $+ .
        else {
          _cfgxw favopt $2 $_o2tf($3) $gettok($_cfgx(favopt,$2),2-,32)
if ($_o2tf($3)) dispa Favorites will be automatically joined when you connect to IRC. $chr(40) $+ on $2 $+ $chr(41)
else dispa Favorites will not be joined when you connect to IRC. $chr(40) $+ on $2 $+ $chr(41)
        }
      }
    }
    else {
      ; Join favorites now (this connection, but can specify a specific network)
      _notconnected /fav j
      %net = $2
      if ((%net == *) || (%net == all) || (%net == $null)) %net = $hget(pnp. $+ $cid,net)
      if ($_favs(%net)) {
        ; Join minimized IF not on active connection AND autojoin specified
        var %flag
        if (($cid != $activecid) && ($3 == x)) %flag = -n
        ; scid $activecid is just to suppress [network] token (since msg has that already)
if ($_favs(%net,1,$iif($3 == x,1,0))) { _linedance join %flag $ifmatch | scid $activecid dispa Joining favorite channels... $chr(40) $+ %net $+ $chr(41) }
elseif ($3 != x) dispa You are already on all of your favorite channels. $chr(40) $+ %net $+ $chr(41)
      }
elseif ($3 != x) _error You have no favorite channels to join. $chr(40) $+ %net $+ $chr(41) $+ Use /fav + to add to your favorites.
    }
  }
  ; /fav c [network|*] [on/off/x]
  ; Connect to a favorite network or turn auto-connect on off
  ; [x] surpesses any errors and only connects to those with auto-connect on
  elseif ($1 == c) {
if (($2 == on) || ($2 == on) || ($2 == off) || ($2 == off) || ($2 == x)) tokenize 32 c * $2
if (($3 == on) || ($3 == on) || ($3 == off) || ($3 == off)) {
      if (($2 == *) || ($2 == all)) {
        %net = $remtok($_favnets,all,44)
        %num = $numtok(%net,44)
        while (%num) {
          var %netc = $gettok(%net,%num,44)
          _cfgxw favopt %netc $puttok($_cfgx(favopt,%netc),$_o2tf($3),2,32)
          dec %num
        }
if ($_o2tf($3)) dispa You will automatically connect to all favorite networks when you start mIRC.
else dispa You will not connect to any favorite networks automatically when starting mIRC.
      }
      else {
if ($_cfgx(favopt,$2) == $null) You don't have any favorites for $2 $+ .
        else {
          _cfgxw favopt $2 $puttok($_cfgx(favopt,$2),$_o2tf($3),2,32)
if ($_o2tf($3)) dispa You will automatically connect to $2 when you start mIRC.
else dispa You will not connect to $2 automatically when starting mIRC.
        }
      }
    }
    else {
      ; Connect here or elsewhere?
      var %scmd = server -m
      if ($status == disconnected) %scmd = server
      ; Connect to network(s) now (this connection if not connected, new connection otherwise; skip any we're already connected to)
      %net = $2
      if ((%net == *) || (%net == all) || (%net == $null)) %net = $remtok($_favnets,all,44)
      %num = 1
      while ($gettok(%net,%num,44)) {
        var %netc = $ifmatch
        ; No favs for this? (allowed to connect if no SERVERS, but network must still be in favorites)
if (($_cfgx(favopt,%netc) == $null) && ($3 != x)) _error %netc is not in your favorites.Try /server to connect to a network.
        ; Already connected to this net somewhere? or connecting?
        var %scon = $scon(0)
        while (%scon) {
          if ($hget(pnp. $+ $scon(%scon),net) == %netc) {
if ($3 != x) dispa You are already connected to %netc $+ .
            goto nextserv
          }
          if (($scon(%scon).status == connecting) && ($server($scon(%scon).server).group == %netc)) {
if ($3 != x) dispa You are currently connecting to %netc $+ .
            goto nextserv
          }
          dec %scon
        }
        ; Connect only if auto-connect?
        if (($3 == x) && (!$gettok($_cfgx(favopt,%netc),2,32))) goto nextserv
        ; Determine server to use
        var %serv = %netc
        if ($_cfgx(favserv,%netc)) {
          ; (randomly select)
          %serv = $gettok($ifmatch,$_pprand(1,$numtok($ifmatch,32)),32)
          %serv = $gettok(%serv,1,58) $gettok(%serv,2,58) $_p2s($gettok(%serv,3-,58))
        }
        ; Connect (server cmd will determine -i info for us)
dispa Connecting to favorite networks... $chr(40) $+ %netc $+ $chr(41)
        _juryrig2 %scmd %serv %info
        ; Any further connections must be new windows
        %scmd = server -m
        :nextserv
        inc %num
      }
    }
  }
  ; /fav i network|* nick alt email realname...
  ; Set info for a favorite network or for all favorite networks
  elseif ($1 == i) {
    ; (realname is technically optional, others must be placeheld with a hyphen)
if ($5 == $null) { dispa Syntax: /fav i network nickname alternate email fullname | halt }
    %net = $2
    if ((%net == *) || (%net == all)) %net = $remtok($_favnets,all,44)
    %num = 1
    while ($gettok(%net,%num,44)) {
      var %netc = $ifmatch
      ; No favs for this?
if ($_cfgx(favopt,%netc) == $null) _error %netc is not in your favorites.Try /server to connect to a network.
      ; Update info
      _cfgxw favopt %netc $gettok($_cfgx(favopt,%netc),1-2,32) $3-
dispa Updated info for favorite network %netc $+ . $chr(40) $+ $3- $+ $chr(41)
      inc %num
    }
  }
  else config 26
}
 
; Returns a comma delimited list of what networks there are stored favorites for
; 'all' will always be LAST
alias -l _favnets {
  var %line,%ret,%file = $_cfg(config.ini),%num = $read(%file,tns,[favopt])
  if ($readn == $null) return All
  %num = $calc($readn + 1)
  :loop
  %line = $read(%file,tn,%num)
  if ((%line) && (= isin %line)) { %ret = $addtok(%ret,$gettok(%line,1,61),44) | inc %num | goto loop }
  %ret = $addtok($remtok(%ret,all,44),All,44)
  return %ret
}
; $_favs([network[,minus[,onlyauto]]])
; Returns list of favorites for given network plus favorites for all, minus dupes; minus current chans if 'minus' param is true
; Only returns favorites designated as autojoin if onlyauto is true
alias -l _favs {
  var %results,%fav1 = $_cfgx(fav,all),%fav2 = $_cfgx(fav,$1)
  if ($3) {
    if (!$gettok($_cfgx(favopt,all),1,32)) %fav1 =
    if (!$gettok($_cfgx(favopt,$1),1,32)) %fav2 =
  }    
  if (%fav1) {
    var %num = $numtok(%fav1,32)
    :loop0
    %results = $addtok(%results,$gettok(%fav1,%num,32),44)
    if (%num > 1) { dec %num | goto loop0 }
  }
  if (%fav2) {
    var %num = $numtok(%fav2,32)
    :loop1
    %results = $addtok(%results,$gettok(%fav2,%num,32),44)
    if (%num > 1) { dec %num | goto loop1 }
  }
  if (($chan(0)) && ($2)) {
    var %num = $chan(0)
    :loop2
    if (($me ison $chan(%num)) || ($chan(%num).status == joining)) %results = $remtok(%results,$chan(%num),44)
    if (%num > 1) { dec %num | goto loop2 }
  }
  return %results
}
 
; Scans favorites for a server name and returns the network name in favorites
alias _favfindnet {
  ; Find server listed in any favorites network
  var %nets = $remtok($_favnets,all,44)
  var %tok = $numtok(%nets,44)
  while (%tok) {
    var %net = $gettok(%nets,%tok,44)
    var %servs = $_cfgx(favserv,%net)
    if ($istok(%servs,$1,32)) {
      return %net
    }
    if ($wildtok(%servs,$1 $+ :*,1,32)) {
      return %net
    }
    dec %tok
  }
  return
}
 
; Scans favorites for a network or server name- if found, returns info
; Randomly selected server if network given; randomly selected port in any case
; server port [connect info]
alias _favfind {
  var %serv,%net
  ; Network?
  if ($_cfgx(favopt,$1)) {
    if ($_cfgx(favserv,$1)) {
      ; (randomly select server)
      %serv = $gettok($ifmatch,$_pprand(1,$numtok($ifmatch,32)),32)
      %serv = $gettok(%serv,1,58) $gettok(%serv,2,58) $_p2s($gettok(%serv,3-,58))
    }
    else %serv = $1
    %net = $1
  }
  else {
    ; Find server listed in any favorites network
    var %nets = $remtok($_favnets,all,44)
    var %tok = $numtok(%nets,44)
    while (%tok) {
      %net = $gettok(%nets,%tok,44)
      var %servs = $_cfgx(favserv,%net)
      if ($istok(%servs,$1,32)) {
        %serv = $1
        break
      }
      if ($wildtok(%servs,$1 $+ :*,1,32)) {
        %serv = $gettok($ifmatch,1,58) $gettok($ifmatch,2,58) $_p2s($gettok($ifmatch,3-,58))
        break
      }
      dec %tok
    }
    if (%serv == $null) return
  }
 
  ; Determine info to use, if any
  var %info
  if ($_cfgx(favopt,%net)) {
    %info = $gettok($ifmatch,3-,32)
    if (%info == - - -) %info =
    else {
      if ($gettok(%info,1,32) == -) %info = $puttok(%info,$mnick,1,32)
      if ($gettok(%info,2,32) == -) %info = $puttok(%info,$anick,2,32)
      if ($gettok(%info,3,32) == -) %info = $puttok(%info,$emailaddr,3,32)
      if ($gettok(%info,4-,32) == $null) %info = $gettok(%info,1-3,32) $fullname
      %info = -i %info
    }
  }
  
  return %serv %info
}
 
; Favorites popup list; use with $submenu
alias _favpop {
  if ($1 == begin) {
    var %all = $_cfgx(fav,all)
    var %net = $_cfgx(fav,$hget(pnp. $+ $cid,net))
    var %t = $numtok(%net,32)
    while (%t >= 1) {
      %all = $addtok(%all,$gettok(%net,%t,32),32)
      dec %t
    }
    %.popfav = $sorttok(%all,32)
    if (!$server) %.popfav =
    return -
  }
  if ($1 == end) {
    .timer -mio 1 0 unset % $+ .popfav
    return -
  }
  var %chan = $gettok(%.popfav,$1,32)
  if (%chan) return $calc($1 + %.popcount) $+ . $_chrescape($replace(%chan,&,&&),:\{\}\|\[\]\%\$\#) :j %chan
  goto $calc($1 - $numtok(%.popfav,32))
  :1
  return -
  :2
return $!iif((( $+ $iif(%.popfav,1,0) $+ ) && ($server)) || ($mouse.key & 2),Join all):fav j
  :3
if ($hget(pnp. $+ $cid,net) != Offline) {
    var %enabled = $gettok($_cfgx(favopt,$hget(pnp. $+ $cid,net)),1,32)
if (%enabled) return $style(1) Join on connect:fav j $hget(pnp. $+ $cid,net) off
return Join on connect:fav j $hget(pnp. $+ $cid,net) on
  }
  :4
  return
}
 
; Favorite SERVERS popup list; use with $submenu
alias _favservpop {
  if ($1 == begin) {
    var %nets = $_favnets
    var %found
    var %t = $numtok(%nets,44)
    while (%t >= 1) {
      if ($_cfgx(favserv,$gettok(%nets,%t,44))) {
        var %servs = $ifmatch
        if (($istok(%servs,$server,32)) || ($wildtok(%servs,$server $+ :*,1,32))) %found = 1
      }
      else %nets = $deltok(%nets,%t,44)
      dec %t
    }
    %.popservfav = $sorttok(%nets,44)
    %.popfound = %found
    %.popcount = $numtok(%.popservfav,44)
    return -
  }
  if ($1 == end) {
    .timer -mio 1 0 unset % $+ .popservfav % $+ .popfound % $+ .popcount
    return -
  }
  var %serv = $gettok(%.popservfav,$1,44)
  if (%serv) return $1 $+ . %serv $+ :fav c %serv
  return
}
