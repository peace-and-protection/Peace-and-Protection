; #= P&P -rs
; ########################################
; Peace and Protection
; User profile support
; ########################################
 
;
; User profiles
;
 
alias profile {
  if ($1 == startup) {
    set %.method $1
    _ssplay Dialog
    if ($dialog(profile,profile,-4) == startup) .timer -mio 1 0 .timer -mio 1 0 _startup.perform
  }
  else _dialog -am profile profile
}
 
alias -l _profile {
  var %profile,%name,%num,%id,%file,%data,%from,%tok
 
  ; NEW
  if ($1 == n) {
    if ($2) {
      ; Base profile
      %profile = $did(profile,11,$did(profile,1).sel)
      ; Importing? (sets %.ver, %.which, and %.whichp if ver 4)
      if (%profile == +) %name = $_profimport
      var %ver = %.ver,%which = %.which,%whichp = %.whichp
%name = $_entry(0,%name,Profile name? $+ $chr(40) $+ be as descriptive as you like $+ $chr(41))
      ; Generate profile id
      %id = $_gen.id(%name)
      var %num
      :loop2
      %data = %id $+ %num
      if ($null != $readini(config\profiles.ini,n,%data,name)) { inc %num | goto loop2 }
      %id = %data
      ; Create new profile
_progress.1 Creating new profile... $chr(40) $+ %id $+ $chr(41)
      ; Directory
_progress.2 0 Making directory...
      saveini
      if ($exists(config\ $+ %id) == $false) mkdir config\ $+ %id
      ; Copy files incl. mirc.ini
_progress.2 33 Copying files...
      if (%profile == +) {
        if (%ver == 4) { %from = $nofile(%which) $+ config\ $+ %whichp | %from = $shortfn(%from) }
        else %from = script\defcfg
      }
      elseif (%profile == -) %from = script\defcfg
      else %from = config\ $+ %profile
      .copy %from $+ \* config\ $+ %id $+ \
      ; Don't copy theme from defcfg
      if (%from == script\defcfg) .remove "config\ $+ %id $+ \theme.mtp"
      if ((%profile == +) && (%ver == 3)) {
_progress.2 50 Converting 3.x settings...
        ;;; NOT DONE YET.. perhaps move to after profile copy? separate progress...
        ;_load imprt320 _import320 config\ $+ %id %which
      }
      if (%profile == +) {
        if (%ver == 4) {
          %from = $nofile(%which) $+ config\profiles.ini
          if (%whichp == $readini(%from,n,startup,main)) {
            flushini " $+ %which $+ "
            .copy -o " $+ %which $+ " config\ $+ %id $+ \mirc.ini
          }
        }
        else {
          flushini " $+ %which $+ "
          .copy -o " $+ %which $+ " config\ $+ %id $+ \mirc.ini
        }
      }
      elseif ((%profile == -) || (%profile == $readini(config\profiles.ini,n,startup,main))) {
        flushini " $+ $mircdir $+ mirc.ini"
        .copy -o " $+ $mircdir $+ mirc.ini" config\ $+ %id $+ \mirc.ini
        ; Clean out any loaded addons
        window -hln @.deaddon
        loadbuf @.deaddon config\ $+ %id $+ \mirc.ini
        while ($fline(@.deaddon,n*=addons\*.ppa,1)) {
          rline @.deaddon $ifmatch $gettok($line(@.deaddon,$ifmatch),1,61) $+ =script\nonexist.mrc
        }
        savebuf @.deaddon config\ $+ %id $+ \mirc.ini
        window -c @.deaddon
      }
      ; Add to profiles.ini
_progress.2 66 Adding to profiles...
      writeini config\profiles.ini %id name %name
      ; Fix sections from imported mirc.ini?
      if ((%profile == +) && (%ver != 4)) {
        %file = config\ $+ %id $+ \mirc.ini
        %data = pfiles rfiles afiles dragdrop clicks perform
        :loopfix
        %tok = $gettok(%data,1,32)
        remini %file %tok
        %num = [[ $+ %tok $+ ]]
        %num = $read($mircini,ns,%num)
        %num = $readn + 1
        :loopfix2
        %from = $read($mircini,n,%num)
        if ((%from != $null) && ([*] !iswm %from)) {
          writeini %file %tok $gettok(%from,1,61) $gettok(%from,2-,61)
          inc %num | goto loopfix2
        }
        %data = $gettok(%data,2-,32)
        if (%data) goto loopfix
      }
_progress.2 100 Done!
      did -v profile 102,103,104,12,2,201,40
did -a profile 101 &Open profile
      did -r profile 150
      did -h profile 80
      _refill %id
    }
    else {
dialog -t profile User Profile (creating new)
      did -h profile 102,103,104,12,2,201,40
did -a profile 101 &Select
      did -ra profile 150 1
      did -v profile 80
did -i profile 1 1 (import settings from another mirc or pnp)
      did -i profile 11 1 +
did -i profile 1 1 (default pnp settings)
      did -i profile 11 1 -
      did -u profile 1
      _profdir
    }
    return
  }
 
  if ($did(profile,1).sel == $null) return
  %profile = $did(profile,11,$did(profile,1).sel)
 
  ; DEFAULT
  if ($1 == s) {
if (%profile == $readini(config\profiles.ini,n,startup,main)) _error That profile is already the default.
    var %proini = $mircdirconfig\ $+ %profile $+ \mirc.ini
if ($_inuse(%proini)) _error You cannot make that profile default.It is currently in use by another copy of mIRC.
if ($_inuse($mircdirmirc.ini)) _error You cannot change the default profile.Another copy of mIRC is using the current default.
_okcancel 0 $iif(%profile == $hget(pnp,user),This will require a TOTAL restart of mIRC- Continue?,This will RESTART mIRC with this profile- Continue?)
    %data = $readini(config\profiles.ini,n,startup,main)
    saveini
    .copy -o mirc.ini config\ $+ %data $+ \mirc.ini
    .copy -o " $+ %proini $+ " mirc.ini
    writeini config\profiles.ini startup main %profile
    _swapto %profile $true $true
  }
  ; SWITCH
  if ($1 == l) {
    if (%profile == $hget(pnp,user)) {
      if ($did(profile,50) == startup) .timer -mio 1 0 _startup.perform
elseif ($group(#pnpdde) == off) _error You cannot open the same profile twice.Type /ddeon to enable DDE and allow this functionality.
else _okcancel 1 Open another copy of current profile?
    }
    saveini
    _swapto %profile $iif($did(profile,50) == startup,$true,$false)
  }
  ; RENAME
  if ($1 == r) {
    %name = $readini(config\profiles.ini,n,%profile,name)
%name = $_entry(0,$_s2p(%name),Profile name? $+ $chr(40) $+ be as descriptive as you like $+ $chr(41))
    writeini config\profiles.ini %profile name %name
    _refill %profile
  }
  ; DELETE
  if ($1 == d) {
if (%profile == $hget(pnp,user)) _error You cannot delete the current profile.Switch to another profile if you want to delete this one.
if (%profile == $readini(config\profiles.ini,n,startup,main)) _error You cannot delete the default profile.Change the default if you want to delete this one.
    %file = $mircdirconfig\ $+ %profile $+ \mirc.ini
if ($_inuse(%file)) _error You cannot delete that profile.It is currently in use by another copy of mIRC.
    ; Delete profile
_progress.1 Deleting profile... $chr(40) $+ %profile $+ $chr(41)
    ; Delete files
_progress.2 0 Deleting files...
    _remove.all * $mircdirconfig\ $+ %profile
if ($findfile($mircdirconfig\ $+ %profile,*,1)) _error Error deleting ' $+ $ifmatch $+ '.Profile was not entirely deleted.
    ; Delete directories
    %data = $finddir($mircdirconfig\ $+ %profile,*,0,.rmdir $1-)
if ($finddir($mircdirconfig\ $+ %profile,*,1)) _error Error deleting ' $+ $ifmatch $+ '.Profile was not entirely deleted.
    ; Remove from profiles.ini
_progress.2 50 Removing from profiles...
    remini config\profiles.ini %profile
    ; Remove main directory
    .rmdir config\ $+ %profile
_progress.2 100 Done!
    _refill
  }
}
 
; Load profile (via restart of mIRC)
; $2 = $true to close this copy, $false to just open another copy
; $3 = $true to close even if profile matches current
alias _swapto {
  ; Load profile
  if (($2) && ($1 == $hget(pnp,user)) && (!$3)) { if ($dialog(profile)) { did -r profile 50 | dialog -c profile } | return }
  if ($2) {
    if ($dialog(profile)) var %ask = $did(profile,2).state
    else var %ask = $readini(config\profiles.ini,n,startup,ask)
    writeini config\profiles.ini startup ask once $ddename $gettok(%ask,-1,32)
    if ($group(#pnpdde) == off) .timer.doexit -io 1 20 exit
  }
  if ($1 == $readini(config\profiles.ini,n,startup,main)) run $mircexe -i" $+ $mircdir $+ mirc.ini"
  else run $mircexe -i" $+ $mircdir $+ config\ $+ $1 $+ \mirc.ini"
  if ($dialog(profile)) { did -r profile 50 | dialog -c profile }
  halt
}
 
alias spawn {
  if ($1-) server -m $1-
  else server -n
}
 
;
; Profile dialogs
;
 
dialog profile {
title "User Profile"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 152
 
text "Choose a user profile by double-clicking, or select an option.", 40, 5 5 190 8
 
box "&User profiles", 13, 5 15 190 75
  list 1, 10 25 115 70
  list 11, 10 25 115 70, hide
  edit "", 150, 1 1 1 1, hide autohs
button "&Open profile", 101, 130 25 60 12, default
button "&Delete profile", 102, 130 41 60 12
button "&Rename profile", 103, 130 57 60 12
button "&Set as default", 104, 130 73 60 12
 
  text "", 75, 7 95 250 10
 
box "Options", 12, 5 105 190 24
check "&Ask for profile on startup", 2, 10 115 115 8
button "&New profile", 201, 130 112 60 12
text "Select the profile or option you wish to base the new profile on", 80, 7 107 190 8, hide
 
button "Close", 202, 55 135 40 12, cancel
button "&Help", 203, 105 135 40 12, disable
 
  edit "", 50, 1 1 1 1, hide result autohs
}
on *:DIALOG:profile:init:*:{
  if ($readini(config\profiles.ini,n,startup,ask)) did -c $dname 2
  _refill $hget(pnp,user)
  if (%.method == startup) {
    did -h profile 102,103,104,201
did -a $dname 40 Choose a user profile by double-clicking.
    did -a $dname 50 %.method
  }
  unset %.method
}
alias -l _refill {
  dialog -t profile User Profile
  did -r profile 1,11
  var %file1,%file2,%profile,%name,%num = 1,%default = $readini(config\profiles.ini,n,startup,main)
  :loop
  %profile = $nopath($finddir($mircdirconfig,*,%num,1))
  %name = $readini(config\profiles.ini,n,%profile,name)
  if (%profile) {
    if (%name == $null) {
      %file1 = $mircdirconfig\ $+ %profile $+ \config.ini
      %file2 = $mircdirconfig\ $+ %profile $+ \cfgvar.dat
      if (($exists(%file1)) && ($exists(%file2))) { %name = %profile | writeini config\profiles.ini %profile name %profile }
    }
    if (%name != $null) {
did -a $+ $iif(%profile == $1,c) profile 1 %name $iif(%profile == $hget(pnp,user),$chr(91) $+ current $+ $chr(93),$iif(%profile == %default,$chr(91) $+ default $+ $chr(93),$chr(32)))
      did -a profile 11 %profile
    }
    inc %num | goto loop
  }
  _profdir
}
alias -l _profdir {
if (($did(profile,1).sel) && ($did(profile,11,$did(profile,1).sel) !isin +-)) did -av profile 75 Profile directory: $mircdirconfig\ $+ $ifmatch
  else did -h profile 75
}
on *:DIALOG:profile:sclick:1:_profdir
on *:DIALOG:profile:dclick:1:if ($did(150) == 1) _profile n 2 | elseif ($did(profile,50) == startup) _profile l | else _profile l
on *:DIALOG:profile:sclick:101:if ($did(150) == 1) _profile n 2 | elseif ($did(profile,50) == startup) _profile l | else _profile l
on *:DIALOG:profile:sclick:102:_profile d
on *:DIALOG:profile:sclick:103:_profile r
on *:DIALOG:profile:sclick:104:_profile s
on *:DIALOG:profile:sclick:201:_profile n
on *:DIALOG:profile:sclick:202:if ($did(profile,50) == startup) { did -c profile 1 1 | _profile l }
on *:DIALOG:profile:sclick:2:writeini config\profiles.ini startup ask $did(profile,2).state
 
;
; Profile importing
;
alias _profimport {
  _ssplay Question
  var %how = $$dialog(profileimp,profileimp,-4)
  if (%how == search) {
    %.where = $_drivesearch
    if (%.where == $null) halt
    _ssplay Question
    var %which = $$dialog(profilesearch,profilesearch,-4)
  }
  else {
    _ssplay Question
var %which = $$sfile($gettok($mircdir,1,58) $+ :\mirc.ini,Select MIRC.INI to import from:,Import)
    if ($exists(%which) == $false) halt
  }
  ; Determine version- plain mirc, 3.x, or 4.x
  var %file1 = $nofile(%which) $+ pp300\r-main.mrc,%file2 = $nofile(%which) $+ pp300\variable.mrc
  if (($exists(%file1)) && ($exists(%file2))) var %ver = 3
  %file1 = $nofile(%which) $+ script\first.mrc
  %file2 = $nofile(%which) $+ config\profiles.ini
  if (($exists(%file1)) && ($exists(%file2))) {
    %.which = %which
    _ssplay Question
    var %name = $$dialog(profimpsel,profimpsel,-4),%ver = 4
  }
  else var %name = $readini(%which,n,mirc,nick)
  set -u %.which %which
  set -u %.ver %ver
  return %name
}
dialog profileimp {
title "Profile Import"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 35
 
text "Should PnP search for your other copies of mIRC or do you wish to locate MIRC.INI manually?", 201, 7 2 150 15
 
button "&Search", 101, 6 20 65 12, default
button "&Manual", 103, 81 20 65 12, OK
button "Cancel", 105, 156 20 32 12, cancel
 
  edit "manual", 1, 1 1 1 1, result hide
}
on *:DIALOG:profileimp:sclick:101:did -o $dname 1 1 search | dialog -k $dname
dialog profilesearch {
title "Profile Import"
  icon script\pnp.ico
  option dbu
  size -1 -1 108 105
text "&Select MIRC.INI to import from:", 1, 2 2 100 8
  list 2, 4 12 100 75, sort
button "&Select", 3, 31 90 45 12, default ok
  edit "", 4, 1 1 1 1, hide autohs result
}
on *:DIALOG:profilesearch:init:*:{
_progress.1 Searching for MIRC.INI...
  var %junk,%num = 1,%where = %.where
  unset %.where
  :loop1
  if ($gettok(%where,%num,32)) {
_progress.2 $round($calc((%num - 1) * 100 / $numtok(%where,32)),0) Searching $ifmatch $+ ...
    %junk = $findfile($gettok(%where,%num,32),MIRC.INI,0,did -a profilesearch 2 $1-)
    inc %num | goto loop1
  }
_progress.2 100 Done!
  ; Remove anything in our mircdir or in a \config\ subdir or in recycled
  %num = $did(2).lines
  :loop2
  if ((*\recycle*\* iswm $did(2,%num)) || ($mircdir* iswm $did(2,%num)) || (*\config\*\mirc.ini iswm $did(2,%num)) || (*\script\defcfg\mirc.ini iswm $did(2,%num))) did -d $dname 2 %num
  if (%num > 1) { dec %num | goto loop2 }
  window -c @Progress
if ($did(2).lines == 0) { dialog -c $dname | _error No MIRC.INIs found to import from. }
}
on *:DIALOG:profilesearch:dclick:2:dialog -k $dname
on *:DIALOG:profilesearch:sclick:3:did -o $dname 4 1 $did(2,$did(2).sel)
dialog profimpsel {
title "Select profile"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 96
 
text "Import which profile?", 40, 5 5 190 8
 
box "&Profiles", 13, 5 15 190 75
  list 1, 10 25 115 70
  list 11, 10 25 115 70, hide
button "&Select", 101, 130 25 60 12, default ok
 
  edit "", 50, 1 1 1 1, hide result autohs
  edit %.which, 51, 1 1 1 1, hide autohs
}
on *:DIALOG:profimpsel:init:*:{
  var %where,%profile,%name,%num = 1,%dir = $nofile(%.which) $+ config
  unset %.which
  :loop
  %profile = $nopath($finddir(%dir,*,%num,1))
  %where = " $+ %dir $+ \profiles.ini"
  %name = $readini(%where,n,%profile,name)
  if (%name) {
    did -a $dname 1 %name
    did -a $dname 11 %profile
  }
  if (%profile) { inc %num | goto loop }
}
on *:DIALOG:profimpsel:dclick:1:dialog -k $dname
on *:DIALOG:profimpsel:sclick:101:set -u1 %.whichp $did(11,$did(1).sel) | did -o $dname 50 1 $did(1,$did(1).sel)
