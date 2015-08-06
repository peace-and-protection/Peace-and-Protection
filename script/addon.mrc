; #= P&P -rs
; ########################################
; Peace and Protection
; Addon support
; ########################################
 
;
; Addons
;
 
alias addons addon
alias addon {
  var %addon,%num,%steps,%cur,%file,%count,%loadto,%cmd
  if ($1) {
    if ($2 == $null) _qhelp /addon $1
    %addon = $replace($_rel.fn($2-),/,\)
if ($_averify(%addon) == 0) _error That is not a valid PnP addon.The file may be corrupted or for a later version of PnP.
  }
  if ($1 == d) {
    ; delete
if ($istok($hget(pnp,addon.ids),$readini(%addon,n,addon,id),32)) _error That addon is installed!Uninstall it before deleting.
_okcancel 1 Delete the $readini(%addon,n,addon,name) addon entirely?
 
    ; Delete, phase one (leave .ppa for last)
    %count = 1
    :loopD1
    %file = $readini(%addon,n,files,%count)
    if (%file) {
      %file = $nofile(%addon) $+ %file
      if (%file != %addon) {
        .remove -b " $+ %file $+ "
if ($exists(%file)) _error Unable to delete ' $+ %file $+ '
      }
      inc %count
      goto loopD1
    }
 
    ; Delete, phase two
    %count = 1
    :loopD2
    %file = $readini(%addon,n,other,%count)
    if (%file) {
      %file = $nofile(%addon) $+ %file
      .remove -b " $+ %file $+ "
if ($exists(%file)) _error Unable to delete ' $+ %file $+ '
      inc %count
      goto loopD2
    }
 
    ; Last file
    .remove -b " $+ %addon $+ "
if ($exists(%addon)) _error Unable to delete ' $+ %addon $+ '
disps Addon ' $+ %addon $+ ' successfully deleted.
    if ($dialog(addons)) _recurse addon
    return
  }
  if (i* iswm $1) {
if ($_averify2(%addon)) _error One or more required files are missing.The file ' $+ $ifmatch $+ ' is missing.
if ($istok($hget(pnp,addon.ids),$readini(%addon,n,addon,id),32)) _error That addon is already installed!Uninstall it or restart PnP if you are having problems.
 
_progress.1 Installing $readini(%addon,n,addon,name)
 
    ; Count files to be loaded
    %count = 1
    :loopL2
    if ($readini(%addon,n,files,%count)) { inc %count | goto loopL2 }
    dec %count
 
    ; Prepare meter
    %steps = $calc(%count + 3) | %cur = 1
    %loadto = $script(0) - 2
 
    ; Load 3.20 compatibility?
    if (($readini(%addon,n,addon,ppver) < 4.00) && ($script(addon320.mrc) == $null)) {
_progress.2 $int($calc(%cur / %steps * 100)) Loading 3.20 compatibility...
      .load -rs $+ %loadto script\addon320.mrc
      _broadcastp .load -rs script\addon320.mrc
    }
 
    ; Cleanup (notify other mircs, update loaded states)
_progress.2 $int($calc(%cur / %steps * 100)) Cleaning up
    inc %cur
    hadd pnp addon.ids $addtok($hget(pnp,addon.ids),$readini(%addon,n,addon,id),32)
    _cfgxw addons ids $hget(pnp,addon.ids)
    _cfgxw addons $readini(%addon,n,addon,id) %addon
    _broadcastp hadd pnp addon.ids $hget(pnp,addon.ids)
    if ($readini(%addon,n,addon,ppver) < 4.00) {
      _pnp320compat
      _broadcastp _pnp320compat
    }
 
    ; Load addon files
    %num = 1
    :loopL3
    %file = $nofile(%addon) $+ $readini(%addon,n,files,%num)
_progress.2 $int($calc(%cur / %steps * 100)) Loading %file
    .load -rs $+ %loadto " $+ %file $+ "
    _broadcastp .load -rs $+ %loadto " $+ %file $+ "
    inc %loadto
    inc %cur
    if (%num < %count) { inc %num | goto loopL3 }
 
    ; Popups and interfaces
_progress.2 $int($calc(%cur / %steps * 100)) Updating popups
    _apopups
    hadd pnp addon.i $_addon.names(3)
    _broadcastp hadd pnp addon.i $!_addon.names(3)
 
_progress.2 100 Addon installed!
    %cmd = $readini(%addon,n,addon,config)
    if ($dialog(addons)) _recurse addon
    if ((%cmd) && (k !isin $1)) { window -c @Progress | _juryrig2 %cmd }
    return
  }
  if ($1 == u) {
if ($istok($hget(pnp,addon.ids),$readini(%addon,n,addon,id),32) == $null) _error That addon is not installed!Restart PnP if you are having problems.
 
    ; Unload command? Clear vars? Windows? Dialogs? Timers? Hash settings?
    %cmd = $readini(%addon,n,addon,unload) | if (%cmd) %cmd
    %cmd = $readini(%addon,n,addon,vars) | if (%cmd) unset [ %cmd ]
    %cmd = $readini(%addon,n,addon,windows)
    if (%cmd) {
      var %windows = $window(0)
      :loopW
      if (%windows) {
        if ($_searchtok(%cmd,$window(%windows),32)) {
          _dowcleanup $window(%windows)
          window -c $window(%windows)
        }
        dec %windows | goto loopW
      }
    }
    %cmd = $readini(%addon,n,addon,dialogs)
    if (%cmd) {
      var %dialogs = $dialog(0)
      :loopD
      if (%dialogs) {
        if ($_searchtok(%cmd,$dialog(%dialogs),32)) dialog -x $dialog(%dialogs)
        dec %dialogs | goto loopD
      }
    }
    %cmd = $readini(%addon,n,addon,timers)
    if (%cmd) {
      var %timer = $numtok(%cmd,32)
      :loopT
      if (%timer) {
        .timer [ $+ [ $gettok(%cmd,%timer,32) ] ] off
        dec %timer | goto loopT
      }
    }
    %cmd = $readini(%addon,n,addon,sockets)
    if (%cmd) {
      var %socks = $numtok(%cmd,32)
      :loopS
      if (%socks) {
        sockclose $gettok(%cmd,%socks,32)
        dec %socks | goto loopS
      }
    }
    ; Delete from config vars
    %cmd = $readini(%addon,n,addon,vars2)
    if (%cmd) {
      var %vars = $numtok(%cmd,32)
      :loopV
      if (%vars) {
        `set $gettok(%cmd,%vars,32)
        dec %vars | goto loopV
      }
    }
    ; Delete from cid-specific hashes
    %cmd = $readini(%addon,n,addon,hashcid)
    if (%cmd) {
      var %scon = $scon(0)
      while (%scon >= 1) {
        var %vars = $numtok(%cmd,32)
        :loopH1
        if (%vars) {
          hdel -w pnp. $+ $scon(%scon) $gettok(%cmd,%vars,32)
          dec %vars | goto loopH1
        }
        dec %scon
      }
    }
    ; Delete from pnp hash
    %cmd = $readini(%addon,n,addon,hashpnp)
    if (%cmd) {
      var %vars = $numtok(%cmd,32)
      :loopH2
      if (%vars) {
        hdel -w pnp $gettok(%cmd,%vars,32)
        dec %vars | goto loopH2
      }
    }
 
_progress.1 Uninstalling $readini(%addon,n,addon,name)
 
    ; Count files to be unloaded
    %count = 1
    :loopU1
    if ($readini(%addon,n,files,%count)) { inc %count | goto loopU1 }
    dec %count
 
    ; Prepare meter
    %steps = $calc(%count + 3) | %cur = 1
 
    ; Unload addon files
    %num = 1
    :loopU2
    %file = $script($readini(%addon,n,files,%num))
_progress.2 $int($calc(%cur / %steps * 100)) Unloading %file
    .timer -mio 1 0 .unload -rs " $+ %file $+ "
    _broadcastp .unload -rs " $+ %file $+ "
    inc %cur
    if (%num < %count) { inc %num | goto loopU2 }
 
    ; Cleanup (notify other mircs, update loaded states)
_progress.2 $int($calc(%cur / %steps * 100)) Cleaning up
    inc %cur
    hadd pnp addon.ids $remtok($hget(pnp,addon.ids),$readini(%addon,n,addon,id),32)
    _cfgxw addons ids $hget(pnp,addon.ids)
    _cfgxw addons $readini(%addon,n,addon,id)
    _broadcastp hadd pnp addon.ids $hget(pnp,addon.ids)
 
    ; Popups and interfaces
_progress.2 $int($calc(%cur / %steps * 100)) Updating popups
    _apopups
    hadd pnp addon.i $_addon.names(3)
    _broadcastp hadd pnp addon.i $!_addon.names(3)
 
_progress.2 100 Addon uninstalled!
    if ($dialog(addons)) _recurse addon
    return
  }
  if ($1 == n) {
    if ($dialog(addoninfo) == $null) {
      set -u %.addon %addon
      _ssplay Dialog
      var %junk = $dialog(addoninfo,addoninfo,-4)
    }
    return
  }
  if ($1 == c) {
if ($istok($hget(pnp,addon.ids),$readini(%addon,n,addon,id),32) == $null) _error That addon is not installed!Restart PnP if you are having problems.
    %cmd = $readini(%addon,n,addon,config)
if (%cmd == $null) _doerror Sorry- This addon has no configuration.Check the addon's documentation for assistance.
    _juryrig2 %cmd
    return
  }
  if ($1 == h) {
if ($istok($hget(pnp,addon.ids),$readini(%addon,n,addon,id),32) == $null) _error That addon is not installed!Restart PnP if you are having problems.
    %cmd = $readini(%addon,n,addon,help)
if (%cmd == $null) _doerror Sorry- This addon has no defined help.Try reading any text files that came with the addon.
    _juryrig2 %cmd
    return
  }
  window -hnl @.files
  %num = $findfile($mircdir,*.ppa,0,@.files)
  %num = $line(@.files,0)
if (%num == 0) { window -c @.files | _error No addon files found!Unzip any addons to $mircdiraddons\ and try again. }
  if ($dialog(addons)) { did -r addons 1,2 | dialog -v addons }
  else dialog -ma addons addons
  var %error = 0
  :loopF
  %file = $line(@.files,%num)
  %cur = $readini(%file,n,addon,ppver)
  if (%cur > $:bver) %error = 2 %file
  elseif (%cur !isnum) %error = 1 %file
  else did -a addons $iif(($istok($hget(pnp,addon.ids),$readini(%file,n,addon,id),32)) && ($script($readini(%file,n,files,1)) == %file),1,2) $readini(%file,n,addon,name) $chr(160) ( $+ %file $+ )
  if (%num > 1) { dec %num | goto loopF }
  window -c @.files
 
if (1* iswm %error) $_doerror($gettok(%error,2-,32),That is not a valid PnP addon.The file may be corrupted or for a later version of PnP.)
if (2* iswm %error) $_doerror($gettok(%error,2-,32),Unusable addon file!This addon is for PnP $readini($gettok(%error,2-,32),n,addon,ppver) $+ .)
}
alias _averify if (($readini($1-,n,addon,ppver) !isnum) || ($readini($1-,n,addon,ppver) > $:bver) || ($readini($1-,n,addon,id) == $null) || ($readini($1-,n,addon,name) == $null) || ($readini($1-,n,files,1) == $null)) return 0 | return 1
alias _averify2 {
  var %num = 1
  :loop1
  var %file = $readini($1-,n,files,%num)
  if (%file) {
    %file = $nofile($1-) $+ %file
    if ($exists(%file)) { inc %num | goto loop1 }
    return %file
  }
  %num = 1
  :loop2
  %file = $readini($1-,n,other,%num)
  if (%file) {
    %file = $nofile($1-) $+ %file
    if ($exists(%file)) { inc %num | goto loop2 }
    return %file
  }
  return
}
 
; Update addon popups
on *:SIGNAL:PNP.TRANSLATE:{ _apopups }
alias _apopups {
  var %num = 1,%mtypes = nicklist query channel status
  :winp
  var %bit = $gettok(%mtypes,%num,32)
  window -hl @.adpopups $+ %bit
  aline -hl @.adpopups $+ %bit menu %bit $chr(123)
aline -hl @.adpopups $+ %bit Misc.
  if (%num < 4) { inc %num | goto winp }
 
  window -hl @.adpopups
  aline @.adpopups ; #= P&P -rs 0
  aline @.adpopups ; @======================================:
  aline @.adpopups ; $chr(124)  Peace and Protection                $chr(124)
  aline @.adpopups ; $chr(124)  Addon popups (*auto-generated*)     $chr(124)
  aline @.adpopups ; `======================================'
  aline @.adpopups menu menubar $chr(123)
 
  window -hls @.apops
 
  ; Get addon names
  var %file,%name,%pop,%popup,%cfg,%help,%num = $numtok($hget(pnp,addon.ids),32)
if (%num < 1) { aline @.adpopups $!iif(($mouse.key & 2) || ($mid($hget(pnp.config,popups.1),9,1) != 0),Addons...):addon | goto nope }
 
aline @.adpopups $!iif(($mouse.key & 2) || ($mid($hget(pnp.config,popups.1),9,1) != 0),Addons)
 
  :loop1
  %file = $_cfgx(addons,$gettok($hget(pnp,addon.ids),%num,32))
  %name = $readini(%file,n,addon,popup)
  if (%name == $null) %name = $readini(%file,n,addon,name)
  aline @.apops %name $+  $+ %file
  if (%num > 1) { dec %num | goto loop1 }
 
  ; Write popups
  %num = 1
  :loop2
  %name = $line(@.apops,%num)
  if (%name) {
    aline @.adpopups . $+ $gettok(%name,1,127)
    %file = $gettok(%name,2,127)
 
    ; Special popups?
    %pop = 1
    :loop3
    %popup = $readini(%file,n,menu,%pop)
    if (%popup != $null) { aline @.adpopups .. $+ %popup | inc %pop | goto loop3 }
 
    ; Misc. popups?
    var %mtype = 1
    :loopmt
    var %bit = $gettok(%mtypes,%mtype,32),%pop = 1
    :loopmt2
    %popup = $readini(%file,n,%bit,%pop)
    if (%popup != $null) { aline @.adpopups $+ %bit . $+ %popup | inc %pop | goto loopmt2 }
    if (%mtype < 4) { inc %mtype | goto loopmt }
 
    %cfg = $readini(%file,n,addon,config)
    %help = $readini(%file,n,addon,help)
 
    aline @.adpopups ..-
if (%cfg != $null) aline @.adpopups ..Configure...: $+ %cfg
if (%help != $null) aline @.adpopups ..Help...: $+ %help
    aline @.adpopups ..-
aline @.adpopups ..Info...:addon n %file
aline @.adpopups ..Uninstall:addon u %file
 
    inc %num | goto loop2
  }
 
  aline @.adpopups .-
aline @.adpopups .More...:addon
  :nope
  aline @.adpopups $chr(125)
 
  savebuf @.adpopups $_cfg(adpopups.mrc)
 
  %num = 1
  :winp2
  %bit = $gettok(%mtypes,%num,32)
  loadbuf -t $+ %bit @.adpopups $+ %bit script\miscmenu.dat
  aline @.adpopups $+ %bit $chr(125)
  ; Only write if greater than 3 lines
  if ($line(@.adpopups $+ %bit,0) > 3) savebuf -a @.adpopups $+ %bit $_cfg(adpopups.mrc)
  window -c @.adpopups $+ %bit
  if (%num < 4) { inc %num | goto winp2 }
 
  close -@ @.apops @.adpopups
 
  _broadcastp .reload -rs2 -rs2 $_cfg(adpopups.mrc)
  .reload -rs2 $_cfg(adpopups.mrc)
}
 
;
; Addon dialog
;
 
dialog addons {
title "PnP Addons"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 182
 
box "Installed addons", 11, 5 5 190 75
  list 1, 10 15 115 70, sort
button "&Information...", 101, 130 15 60 12, default
button "&Uninstall", 102, 130 31 60 12
button "&Configure...", 103, 130 47 60 12
button "&Help on addon...", 104, 130 63 60 12
 
box "More addons", 12, 5 85 190 75
  list 2, 10 95 115 70, sort
button "&Information...", 201, 130 95 60 12
button "&Install", 205, 130 111 60 12
button "&Delete...", 206, 130 127 60 12
 
button "&Close", 21, 55 165 40 12, cancel
button "&Help", 22, 105 165 40 12, disable
}
on *:DIALOG:addons:sclick:1:did -t $dname 101 | did -u $dname 2
on *:DIALOG:addons:sclick:2:did -t $dname 201 | did -u $dname 1
on *:DIALOG:addons:dclick:*:if ($did < 1) return | var %addon = $did($did,$did($did).sel) | addon n $left($gettok(%addon,$numtok(%addon,40),40),-1)
on *:DIALOG:addons:sclick:21:return
on *:DIALOG:addons:sclick:101,102,103,104,201,205,206:{
  var %addon = $did($left($did,1),$did($left($did,1)).sel)
  if (%addon == $null) return
  addon $mid(nuchid,$right($did,1),1) $mid(%addon,$calc($pos(%addon,$chr(160),1) + 3),-1)
}
 
;
; Addon info identifier- (loaded)
;
 
; $_addon.names(n)
; 1 = names (commaspace sep)
; 2 = id/ver pairs (space sep)
; 3 = calculate interfaces (returns interfaces available)
alias _addon.names {
  var %ln,%get,%id,%ppa,%names,%num = 1,%addons = $_cfgx(addons,ids),%old
  if ($1 == 3) hdel -w pnp addon.i.*
  if (%addons) {
    :loop
    %id = $gettok(%addons,%num,32)
    %ppa = $_cfgx(addons,%id)
    if ($exists(%ppa)) {
      if ($1 == 1) %names = %names $readini(%ppa,n,addon,name) $+ ,
      elseif ($1 == 2) %names = %names %id $+ / $+ $readini(%ppa,n,addon,version)
      else {
        %ln = $read(%ppa,s,[interfaces])
        if ($readn) {
          %ln = $readn + 1
          :loop2
          %get = $read(%ppa,n,%ln)
          if (([* !iswm %get) && (#* !iswm %get) && (%get)) {
            %names = $addtok(%names,$gettok($ifmatch,1,61),32)
            %old = $hget(pnp,addon.i. $+ $gettok($ifmatch,1,61))
            hadd pnp addon.i. $+ $gettok($ifmatch,1,61) $addtok(%old,$gettok($ifmatch,2-,61),44)
            inc %ln
            goto loop2
          }
        }
      }
    }
    if (%num < $numtok(%addons,32)) { inc %num | goto loop }
    if ($1 == 1) return $left(%names,-1)
    return %names
  }
  return
}
 
;
; Addon info dialog
;
 
dialog addoninfo {
title "PnP Addons"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 170
 
text "Addon:", 2, 2 5 40 8, right
  text "", 12, 45 5 150 8
text "Version:", 3, 2 13 40 8, right
  text "", 13, 45 13 150 8
text "For PnP:", 4, 2 21 40 8, right
  text "", 14, 45 21 150 8
text "Author:", 5, 2 29 40 8, right
  text "", 15, 45 29 150 8
text "E-Mail:", 6, 2 37 40 8, right
  link "", 16, 45 37 150 8
text "Homepage:", 7, 2 45 40 8, right
  link "", 17, 45 45 150 8
text "Info:", 8, 2 55 40 8, right
  edit "", 18, 45 53 150 50, multi read return vsbar
text "Addon file(s):", 9, 2 106 40 8, right
text "(Double-click a filename to view it)", 10, 2 117 40 24, right disable
  list 19, 45 105 150 50
 
button "Close", 1, 45 153 50 12, cancel default
}
on *:DIALOG:addoninfo:init:*:{
  var %load = name version ppver author email url
  var %tok = 1
  while ($gettok(%load,%tok,32)) {
    if ($readini(%.addon,n,addon,$ifmatch) != $null) {
      did -ra $dname $calc(11 + %tok) $ifmatch
      did -v $dname $calc(1 + %tok)
    }
    else {
      did -r $dname $calc(11 + %tok)
      did -h $dname $calc(1 + %tok)
    }
    inc %tok
  }
  if ($readini(%.addon,n,addon,group) != $null) did -ra $dname 14 $did(14) ( $+ $ifmatch $+ )
  did -r $dname 18
  if ($readini(%.addon,n,notes,1) != $null) {
    did -a $dname 18 $ifmatch
    var %line = 2
    while ($readini(%.addon,n,notes,%line) != $null) {
      did -a $dname 18 $crlf $+ $crlf $+ $ifmatch
      inc %line
    }
  }
  did -r $dname 19
  _ddadd $dname 19 $lower($_truename.fn(%.addon))
  var %line = 1
  while ($readini(%.addon,n,files,%line)) {
    _ddadd $dname 19 $lower($_truename.fn($nofile(%.addon) $+ $ifmatch))
    inc %line
  }
  %line = 1
  while ($readini(%.addon,n,other,%line)) {
    _ddadd $dname 19 $lower($_truename.fn($nofile(%.addon) $+ $ifmatch))
    inc %line
  }
  did -z $dname 19
  unset %.addon
}
on *:DIALOG:addoninfo:sclick:16:mailto $did(16)
on *:DIALOG:addoninfo:sclick:17:http $did(17)
on *:DIALOG:addoninfo:dclick:19:edit $did(19).seltext
