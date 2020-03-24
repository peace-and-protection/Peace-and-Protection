; #= P&P -rs 1
; ########################################
; Peace and Protection
; ########################################

; **********************************************************
; ** DO NOT ADD LINES TO THIS SCRIPT. DOING SO MAY CAUSE  **
; ** SERIOUS PROBLEMS.                                    **
; **                                                      **
; ** If you want to add your own scripts, go to File->New **
; ** or File->Load. This also has the benefit of not      **
; ** overwriting your scripts when PnP upgrades.          **
; **********************************************************


; First time loading- don't show things as errors
on *:LOAD:{
  ; Version check
  if ($version < 7.61) {
    echo 4 -sti2 Peace and Protection requires mIRC 7.61 or later to run! (you are using $version $+ )
    .timer -mio 1 0 .unload -rs " $+ $script $+ "
    halt
  }

  .remote on
  .dlevel 1
  .fsend on
  .pdcc on
  .ial on
  .dcc packetsize 4096

  %firsttime = 1
}

; Startup routines
on *:START:{
  var %firsttimelocal = $iif(%firsttime,1,0)
  unset %firsttime

  hmake pnp.startup 20
  hadd pnp.startup ticks $ticks
  hadd pnp.startup firsttime %firsttimelocal

  ; Version check
  if ($version < 7.61) {
    echo 4 -sti2 Peace and Protection requires mIRC 7.61 or later to run! (you are using $version $+ )
    halt
  }

  ; Load vars and users of proper user
  var %user = $_dirhash
  .timer.loadit 1 1 .write " $+ $mircdirconfig\ $+ %user $+ \vars.mrc" $chr(124) .load -rv " $+ $mircdirconfig\ $+ %user $+ \vars.mrc" | .timer.loadit -e
  .timer.loadit 1 1 .write " $+ $mircdirconfig\ $+ %user $+ \users.mrc" $chr(124) .load -ru " $+ $mircdirconfig\ $+ %user $+ \users.mrc" | .timer.loadit -e

  ; These vars are not phased out yet (probably never will be)
  unset %:* %<* %.*

  ; Make sure hashes are ready to go
  _startup.prep
  hadd pnp user %user
  _new.connection $cid

  ; Startup sequence
  ; (_dde.init includes showing current user)
  _startup.add _dde.init Initializing DDE

  ; Perform startup or get profile or kill starting mirc?
  var %ask = $readini(config\profiles.ini,n,startup,ask)
  if ($gettok(%ask,1,32) == once) {
    _startup.add _fix.dde Closing previous mIRC
    var %ask
  }

  ; Connect to server on startup?
  var %connect = $readini(config\profiles.ini,n,startup,connect)
  if (%connect) {
    remini config\profiles.ini startup connect
    hadd pnp startupconnect %connect
  }

  _startup.add _ck.script Verifying loaded scripts
  ; (after the above, we can safely use any internal aliases/routines)
  ; (_ck.order1 includes startup sound)
  _startup.add _ck.order1 Verifying script order
  _startup.add _ck.addon Verifying loaded addons
  _startup.add _ck.order2 Verifying end script order
  ; (now we know that all scripts are loaded and in order)
  _startup.add _rehash Loading settings
  _startup.add _mischash Misc. settings
  ; (now all significant vars/hashes are loaded)
  _startup.add _pnp.upgrade Upgrading from older versions
  ; (at this point we have upgraded any out-of-date settings- done before theming)
  _startup.add _theme.start Setting display scheme
  _startup.add _upd.texts Setting display scheme
  ; (and now all theming and display items are running properly)
  _startup.add _rechash Loading recent menus
  _startup.add .serverlist Updating serverlist
  _startup.add _q.fkey.clr Preparing FKey queues
  _startup.add _clrtauth Clearing expired authorizations
  _startup.add _tut.on Starting timers

  ; Ask for startup profile?
  if (%ask) {
    if ($group(#pnpdde) == on) .ddeserver on startup $+ $_pprand(9999)

    ; Cancel any impending connection-on-startup too
    .timer -mio 1 0 if ($status != disconnected) $chr(123) hadd pnp startupreconnect 1 $chr(124) .disconnect $chr(125) $chr(124) profile startup
    return
  }

  .timer -mio 1 0 _startup.perform
}

;
; Start-up sequence
;

; (add item to queue, or perform if not in startup sequence)
alias _startup.add {
  if ($hget(pnp.startup)) {
    hinc pnp.startup head
    hadd pnp.startup $hget(pnp.startup,head) $1-
  }
  else {
    $1
  }
}

; (perform startup queue)
; $1 = R (resuming queue) $2 = N (next item: error in previous)
alias _startup.perform {
  ; Cancel any impending connection-on-startup if anything stops us
  .timer.start.disconnect -mio 1 0 if ($status != disconnected) $chr(123) hadd pnp startupreconnect 1 $chr(124) .disconnect $chr(125)
  ; In case there is an error- resume
  .timer.start.resume -io 1 1 _startup.perform R N

  if ($1) {
    if ($2) {
      ; Error in previous
      var %event = $gettok($hget(pnp.startup,$hget(pnp.startup,tail)),2-,32)
      _st.error Error during ' $+ %event $+ '
    }
    else {
      ; (don't skip)
      hdec pnp.startup tail
    }
  }

  ; Splash
  if ($readini(config\ $+ $hget(pnp,user) $+ \config.ini,n,cfg,hidesplash)) window -c @Startup
  elseif (!$window(@Startup)) {
    window -pfarodw0kBz +bdL @Startup $int($calc(($window(-1).w - 250) / 2)) $int($calc(($window(-1).h - 350) / 2)) 250 350
    titlebar @Startup $findfile(script\,pp4title*.png,$r(1,$findfile(script\,pp4title*.png,0)))
    if ($exists($window(@Startup).title)) {
      drawpic -c @Startup 0 0 " $+ $window(@Startup).title $+ "
      if ($:bver != $null) {
        drawtext -ro @Startup $rgb(0,0,0) "Arial" 16 215 310 $:bver
        drawtext -ro @Startup $rgb(255,255,255) "Arial" 16 213 308 $:bver
      }
    }
    else drawrect -rf @Startup $rgb(face) 1 0 0 250 350
  }

  :loop
  hinc pnp.startup tail

  if ($hget(pnp.startup,tail) <= $hget(pnp.startup,head)) {
    if ($window(@Startup)) {
      if ($exists($window(@Startup).title)) {
        drawpic -cn @Startup 27 211 27 211 203 36 " $+ $window(@Startup).title $+ "
        drawrect -rfn @Startup $getdot(@Startup,15,320) 0 31 213 $calc($hget(pnp.startup,tail) / $hget(pnp.startup,head) * 196) 16
      }
      else drawrect -rfn @Startup $rgb(255,0,0) 0 31 213 $calc($hget(pnp.startup,tail) / $hget(pnp.startup,head) * 196) 16
      drawtext -n @Startup $rgb(0,0,0) Arial 10 40 235 $gettok($hget(pnp.startup,$hget(pnp.startup,tail)),2-,32) $+ ...
      drawdot @Startup
    }
    $gettok($hget(pnp.startup,$hget(pnp.startup,tail)),1,32)
    goto loop
  }
  .timer.start.resume off
  drawpic -c

  disps Startup completed in $:t($calc(($ticks - $hget(pnp.startup,ticks)) / 1000)) seconds
  disps-div
  disps Welcome to PnP $:t($:ver)
  disps Press Alt+E for mIRC Setup
  disps Right-click in this window for server-related options
  disps Use the 'PnP' menu for configuration and other PnP options
  disps-div
  ; Runs first-time setup if first time or an upgrade from a version that didn't have _dragdrop
  if (($hget(pnp.startup,firsttime)) || ((_dragdrop !isin $readini($mircini,n,dragdrop,n0)) && ($readini($scriptdir $+ dofirst.ini,n,todo,done) != 1))) {
    if ($hget(pnp.startup,firsttime)) writeini config\profiles.ini startup runwizard 1
    writeini script\dofirst.ini todo done 1
    writeini script\dofirst.ini todo mirc $mircexe
    writeini script\dofirst.ini todo file $mircini
    saveini
    flushini " $+ $mircini $+ "
    writeini script\dofirst.ini todo mtime $file($mircini).mtime
    run -n $mircexe -i" $+ $scriptdir $+ dofirst.ini"
    exit
    halt
  }
  window -c @Startup
  .timer -mio 1 0 hfree pnp.startup

  ; First-time wizard?
  if ($readini(config\profiles.ini,n,startup,runwizard)) {
    remini config\profiles.ini startup runwizard
    remini config\profiles.ini startup saywizard
    .timer -mio 1 0 wizard
  }
  ;!! This is a short-term addition and will be removed in a future version
  elseif ($readini(config\profiles.ini,n,startup,saywizard)) {
    remini config\profiles.ini startup saywizard
    disps PnP now includes a $:w(configuration wizard) for common options!
    disps Select 'Configuration Wizard' from the 'PnP' menu, under 'Configure'.
    disps-div
  }

  ; Do connection-on-startup now
  .timer.start.disconnect off
  .timer.start.reconnect -mio 1 0 start.reconnect
  if ($hget(pnp.startup,errors)) _doerror Startup- $hget(pnp.startup,errors) error $+ $chr(40) $+ s $+ $chr(41) encountered during startup!See status window $chr(40) $+ red lines $+ $chr(41) for details
}
alias -l start.reconnect {
  ; Skip all connects if ctrl+shift pressed
  if ($mouse.key & 6) {
    if ($status != disconnected) .disconnect
  }
  ; Specific connect request (skip favorites)
  elseif ($hget(pnp,startupconnect)) {
    .server $ifmatch
  }
  ; Connect-on-startup
  elseif ($hget(pnp,startupreconnect)) {
    ; Still do favorites
    .!server
    fav c x
  }
  ; Favorites
  else {
    fav c x
  }
  hdel pnp startupconnect
  hdel pnp startupreconnect
}

; (errors)
alias _st.error if (!$hget(pnp.startup,firsttime)) { hinc pnp.startup errors | echo 4 -sti2 $iif($:*,$:*,***) $1- }

;
; Basic startup checks- Make sure directory structure, files, etc. are intact
; Also grabs current user
;

alias -l _dirhash {
  ; Verify certain dirs
  mkdir SCRIPT\TEMP | mkdir CONFIG | mkdir THEMES

  ; Detect profile (user)
  if ($mircdirconfig\ isin $mircini) var %user = $gettok($mircini,$calc($numtok($mircini,92) - 1),92)
  else var %user = $readini(config\profiles.ini,n,startup,main)
  if (!$isdir(config\ $+ %user)) %user =

  ; Verify profiles.ini- exists?
  if ($exists(CONFIG\profiles.ini) == $false) {
    _st.error ' $+ profiles.ini $+ ' missing $+ $chr(44) recreating...
    writeini config\profiles.ini startup ask 0
  }

  ; Verify profiles.ini contains ptr to valid user
  if (($null == $readini(config\profiles.ini,n,startup,main)) || (%user == $null)) {
    if ($finddir(config\,*,1)) {
      writeini config\profiles.ini startup main $gettok($replace($ifmatch,/,\),-1,92)
      if (%user == $null) %user = $readini(config\profiles.ini,n,startup,main)
    }
    else {
      _st.error Config directories missing $+ $chr(44) recreating a default configuration...
      if (%user == $null) %user = default
      writeini config\profiles.ini startup main %user
      writeini config\profiles.ini %user name %user
      mkdir config\ $+ %user
      .copy script\defcfg\* config\ $+ %user $+ \
      ; Don't copy theme- that's handled later, in a cleaner way.
      .remove "config\ $+ %user $+ \theme.mtp"
    }
  }

  return %user
}

; (not on top in case load warning appears)
alias -l _not.on.top { if ($window(@Startup)) window -u @Startup }

; Check that all required scripts are loaded
alias _ck.script {
  ; First, unload/remove any outdated script files
  if ($exists(addons\chanserv.mrc)) {
    _not.on.top
    if ($script(chanserv.mrc)) { .unload -rs addons\chanserv.mrc | .load -rs $+ $calc($script(0) - 2) addons\chanserv.ppa }
    .remove script\chanserv.mrc
  }
  if ($exists(addons\login.mrc)) {
    _not.on.top
    if ($script(login.mrc)) { .unload -rs addons\login.mrc | .load -rs $+ $calc($script(0) - 2) addons\login.ppa }
    .remove script\login.mrc
  }
  if ($exists(addons\xdcc.mrc)) {
    _not.on.top
    if ($script(xdcc.mrc)) { .unload -rs addons\xdcc.mrc | .load -rs $+ $calc($script(0) - 2) addons\xdcc.ppa }
    .remove script\xdcc.mrc
  }
  if ($exists(addons\xw.mrc)) {
    _not.on.top
    if ($script(xw.mrc)) { .unload -rs addons\xw.mrc | .load -rs $+ $calc($script(0) - 2) addons\xw.ppa }
    .remove script\xw.mrc
  }
  if ($exists(addons\nickserv.mrc)) {
    _not.on.top
    if ($script(nickserv.mrc)) { .unload -rs addons\nickserv.mrc | .load -rs $+ $calc($script(0) - 2) addons\nickserv.ppa }
    .remove script\nickserv.mrc
  }
  if ($exists(addons\sound.mrc)) {
    _not.on.top
    if ($script(sound.mrc)) { .unload -rs addons\sound.mrc | .load -rs $+ $calc($script(0) - 2) addons\sound.ppa }
    .remove script\sound.mrc
    ; Load this here, it is new to 4.20
    .load -rs $+ $calc($script(0) - 2) script\cfgalias.mrc
  }

  if ($exists(script\dialog.mrc)) { .unload -rs script\dialog.mrc | .remove script\dialog.mrc }
  if ($exists(script\dialogs.mrc)) { .unload -rs script\dialogs.mrc | .remove script\dialogs.mrc }
  if ($exists(script\themes.mrc)) { .unload -rs script\themes.mrc | .remove script\themes.mrc }
  if ($exists(script\themfile.mrc)) { .unload -rs script\themfile.mrc | .remove script\themfile.mrc }
  if ($exists(script\imprt320.mrc)) { .unload -rs script\imprt320.mrc | .remove script\imprt320.mrc }
  if ($exists(addons\sound2.mrc)) { .unload -rs addons\sound2.mrc | .remove addons\sound2.mrc }
  if ($exists(script\config2.mrc)) { .unload -rs script\config2.mrc | .remove script\config2.mrc }

  ; Old popup files
  var %file = config\ $+ $hget(pnp,user) $+ \popups.ini
  if ($exists(script\status.mrc)) {
    .writeini %file mpopup n0 ; Your own popups may go here.
    .flushini %file
    .load -ps %file
    .remove script\status.mrc
    .remove script\ptm\status.ptm
  }
  if ($exists(script\query.mrc)) {
    .writeini %file qpopup n0 ; Your own popups may go here.
    .flushini %file
    .load -pq %file
    .remove script\query.mrc
    .remove script\ptm\query.ptm
  }
  if ($exists(script\chan.mrc)) {
    .writeini %file cpopup n0 ; Your own popups may go here.
    .flushini %file
    .load -pc %file
    .remove script\chan.mrc
    .remove script\ptm\chan.ptm
  }
  if ($exists(script\nick.mrc)) {
    .writeini %file lpopup n0 ; Your own popups may go here.
    .flushini %file
    .load -pn %file
    .remove script\nick.mrc
    .remove script\ptm\nick.ptm
  }
  if ($exists(script\menu.mrc)) {
    .writeini %file bpopup n0 PnP
    .writeini %file bpopup n1 ; The above is the name of the script's menu on the menubar.
    .writeini %file bpopup n2 ; Your own popups may go below.
    .flushini %file
    .load -pm %file
    .remove script\menu.mrc
    .remove script\ptm\menu.ptm
  }

  ; 'your' popups- create?
  if ($!isfile(%file)) {
    .writeini %file bpopup n0 PnP
    .flushini %file
  }

  ; Verify loaded popups first time
  if ($hget(pnp.startup,firsttime)) {
    .load -ps %file
    .load -pq %file
    .load -pc %file
    .load -pn %file
    .load -pm %file
  }

  ; Now verify loaded scripts
  return $findfile($mircdirscript\,*.mrc,0,1,_ck.script2 $1-)
}
alias -l _ck.script2 {
  var %line = $read($1-,tn,1)
  if (($script($1-) == $null) && ($alias($1-) == $null) && (*#= P&P -* iswm %line)) {
    _st.error Script not loaded- Reloading ' $+ $1- $+ '
    if ($wildtok(%line,-*,1,32) == -a) .load -a " $+ $1- $+ "
    else {
      _not.on.top
      ; Load at end if only a few scripts loaded already or this is 'first time'
      $iif($hget(pnp.startup,firsttime),.reload,.load) -rs $+ $iif((!$hget(pnp.startup,firsttime)) && ($calc($script(0) - 2) > 1),$calc($script(0) - 2)) " $+ $1- $+ "
    }
  }
  ; (unload temp scripts)
  elseif ((*#= P&P.temp * iswm %line) && ($script($1-))) {
    .unload -rs " $+ $1- $+ "
  }
}

; Check that certain scripts are loaded first
alias _ck.order1 {
  var %moved,%file

  ; Unload any non-existant script.inis, etc.
  while (!$isfile($script(1))) {
    .unload -rs " $+ $script(1) $+ "
  }
  ; Make sure first.mrc is first
  var %num = 1
  while (*#= P&P -rs 1 !iswm $read($script(%num),tn,1)) {
    inc %num
    ; Fallout in case first.mrc isn't found!
    if (!$script(%num)) { %num = 1 | break }
  }
  if (%num > 1) {
    %file = " $+ $script(%num) $+ "
    inc %moved
    .reload -rs1 %file
  }

  ; Make sure all '0' scripts are next, and unload any remaining script.inis/etc
  var %num = 2,%spot = 2
  while ($script(%num)) {
    if (!$isfile($script(%num))) { .unload -rs " $+ $script(%num) $+ " | dec %num }
    elseif (*#=*-rs 0 iswm $read($script(%num),tn,1)) {
      if (%num != %spot) {
        .reload -rs $+ %spot " $+ $script(%num) $+ "
        inc %moved
      }
      inc %spot
    }
    inc %num
  }
  if ((%moved) && (!$hget(pnp.startup,firsttime))) _stecho Moved %moved scripts
}

; Check addons loaded; check 3.20 compat
alias _ck.addon {
  ; First, list all non-PnP scripts
  window -hnl @.allscript
  var %num = 1
  while ($script(%num)) {
    if (*#= P&P* -rs* !iswm $read($script(%num),tn,1)) aline @.allscript $script(%num)
    inc %num
  }

  ; Go through each loaded addon...
  var %addons = $_cfgx(addons,ids)
  var %loadedprev = %addons
  var %loadednow
  var %loadednames
  var %load320 = 0
  while (%addons) {
    var %id = $gettok(%addons,1,32)
    %addons = $gettok(%addons,2-,32)
    var %ppa = $_cfgx(addons,%id)
    ; Only counts if ppa item is present also
    if (%ppa) {
      if (!$isfile(%ppa)) {
        _st.error Addon file ' $+ %ppa $+ ' missing! Addon will be unloaded.
      }
      elseif (!$_averify(%ppa)) {
        _st.error Addon file ' $+ %ppa $+ ' corrupted!
      }
      else {
        ; Addon ppa ok- now check ind. files
        var %name = $readini(%ppa,n,addon,name)
        var %scrn = 1,%error = 0
        while ($readini(%ppa,n,files,%scrn)) {
          var %file = $ifmatch
          %file = $nofile($_truename.fn(%ppa)) $+ %file
          ; Not loaded?
          if ($script(%file) == $null) {
            ; Load
            if ($isfile(%file)) {
              _not.on.top
              _st.error Reloading addon script ' $+ %file $+ ' $chr(40) $+ %name $+ $chr(41)
              $iif($hget(pnp.startup,firsttime),.reload,.load) -rs $+ $calc($script(0) - 2) " $+ %file $+ "
            }
            ; Doesn't exist
            else {
              _st.error Addon file ' $+ %file $+ ' missing! Addon will be unloaded.
              %error = 1
            }
          }
          else {
            ; File loaded, remove from window of files
            dline @.allscript $fline(@.allscript,%file,1)
          }
          inc %scrn
        }

        ; At this point, unless a file was missing, addon is definately loaded
        if (!%error) {
          %loadednow = $addtok(%loadednow,%id,32)
          %loadednames = %loadednames %name

          ; 3.20?
          if (($readini(%ppa,n,addon,ppver) isnum) && ($readini(%ppa,n,addon,ppver) < 4.00)) %load320 = 1

          ; Check non-script files
          %scrn = 1
          while ($readini(%ppa,n,other,%scrn)) {
            var %file = $ifmatch
            %file = $nofile($_truename.fn(%ppa)) $+ %file
            if ($exists(%file) == $false) {
              _st.error Addon file ' $+ %file $+ ' missing! Addon $chr(40) $+ %name $+ $chr(41) may not function properly.
            }
            inc %scrn
          }
        }
      }
    }
  }

  ; Save ids
  _cfgxw addons ids %loadednow
  hadd pnp addon.ids %loadednow
  if (!%loadednames) %loadednames = (none)
  _stecho Addons loaded- %loadednames

  ; Any scripts to unload or warn of?
  while ($line(@.allscript,1)) {
    var %file = $ifmatch
    var %top = $read(%file,tn,1)
    if (*#= * -rs* iswm %top) {
      _st.error Unloading ' $+ %file $+ ' $chr(40) $+ addon is not properly loaded; use /addon to load it $+ $chr(41)
      .unload -rs " $+ %file $+ "
    }
    ; Warn about non-pnp scripts
    elseif ($readini(config\profiles.ini,n,warn,$shortfn(%file)) == $null) {
      _stecho Warning- Unrecognized file ' $+ %file $+ ' is loaded $chr(40) $+ non-PnP addons may not work properly $+ $chr(41)
      writeini config\profiles.ini warn $shortfn(%file) 1
    }
    dline @.allscript 1
  }
  window -c @.allscript

  ; mirc aliases.ini needs unloading?
  if (($alias(aliases.ini)) && (($readini(config\profiles.ini,n,warn,aliases.ini) == $null) || ($hget(pnp.startup,firsttime)))) {
    .unload -a aliases.ini
    _stecho Unloading mIRC 'aliases.ini'. $chr(40) $+ this file conflicts with PnP commands $+ $chr(41)
    writeini config\profiles.ini warn aliases.ini 1
  }

  ; Update popups, calculate interfaces
  if ((%loadednow != %loadedprev) || (!$isfile($_cfg(adpopups.mrc)))) _apopups
  hadd pnp addon.i $_addon.names(3)

  ; 3.20 compat?
  if (%load320) {
    if ($script(addon320.mrc) == $null) .reload -rs $+ $calc($script(0) - 2) script\addon320.mrc
    _startup.add _pnp320compat Configuring PnP 3.xx compatibility
  }
  elseif ($script(addon320.mrc)) {
    .unload -rs " $+ $ifmatch $+ "
    unset %col.* %= %^* %font.fixtab %pp.ver %pp.net
  }
}

; Check that certain scripts are last
alias _ck.order2 {
  var %top,%bad,%file

  ; Determine scripts to be reordered
  window -hnls @.reload
  var %num = $script(0)
  :loop1
  %top = $read($script(%num),tn,1)
  if (*#=*-rs* iswm %top) if ($gettok(%top,$numtok(%top,32),32) isnum) if ($ifmatch < 0) aline @.reload $ifmatch $script(%num)
  if (%num > 1) { dec %num | goto loop1 }

  ; Check for order, don't reload if already in order
  var %check = $script(0)
  %num = 1
  :loop2
  %file = $gettok($line(@.reload,%num),2-,32)
  if ($script(%check) != %file) %bad = 1
  else {
    if (%num < $line(@.reload,0)) { dec %check | inc %num | goto loop2 }
  }

  if (%bad) {
    %num = $line(@.reload,0)
    :loop3
    %file = $gettok($line(@.reload,%num),2-,32)
    .reload -rs $+ $calc($script(0) + 1) " $+ %file $+ "
    if (%num > 1) { dec %num | goto loop3 }
  }

  window -c @.reload
}

; calls disps if it exists, else echo
alias _stecho $iif($isalias(disps),disps,echo -sti2 ***) $1-

;
; Support for multiple instances
;

; For recognition during DDE and for addons
alias _ispnp return 1

; Resets DDE when translated
on *:SIGNAL:PNP.TRANSLATE:{
  if ($readini($mircini,n,dde,serverstatus) == on) .enable #pnpdde
  else .disable #pnpdde
}

; Closes previous mIRC
alias -l _fix.dde {
  var %ask = $readini(config\profiles.ini,n,startup,ask)
  writeini config\profiles.ini startup ask $gettok(%ask,3,32)
  dde $gettok(%ask,2,32) command "" /exit
  .timer.startsaveini -oi 1 30 saveini
}

; Selects a DDE name (run at startup)
; If mIRC has DDE off, this doesn't run.
; May be desired to clear window afterwards
alias _dde.init {
  if ($readini($mircini,n,dde,serverstatus) != on) {
    .disable #pnpdde
    hadd pnp ext 0
    _stecho Performing PnP startup... $chr(40) $+ profile - $hget(pnp,user) $+ $chr(41)
    return
  }

  .enable #pnpdde
  ; Only one copy should do this at a time
  if ($lof(script\temp\semaphor.) > 0) {
    if ($window(@Startup)) window -h @Startup
    ; Timestamp in semaphor too old? possible problem, auto disable DDE
    if ($read(script\temp\semaphor.,n,1) < $calc($ctime - 60)) {
      echo 4 -sti2 $iif($:*,$:*,***) Startup problems detected from earlier- Disabling DDE $chr(40) $+ may cause problems if you open multiple mIRCs $+ $chr(41)
      .remove script\temp\semaphor.
      .disable #pnpdde
      .ddeserver off
      hadd pnp ext 0
      _stecho Performing PnP startup... $chr(40) $+ profile - $hget(pnp,user) $+ $chr(41)
      return
    }
    ; Wait 10+ seconds for other mirc dde's to finish or timeout
    hinc pnp.startup ddeskip
    if ($hget(pnp.startup,ddeskip) == 1) {
      _stecho Waiting for other copies of PnP to finish starting... $chr(40) $+ use /ddeoff if having DDE problems $+ $chr(41)
      editbox -s /ddeoff
    }
    if ($hget(pnp.startup,ddeskip) < 12) { .timer.start.resume -mio 1 1 _startup.perform R | halt }
    echo 4 -sti2 $iif($:*,$:*,***) Timed out waiting $+ $chr(44) did PnP crash during startup earlier or in another copy? You may wish to use /ddeoff.
    editbox -s
    ; Go ahead anyways
    write -c script\temp\semaphor. $calc($ctime - 60)
  }
  else write -c script\temp\semaphor. $ctime
  ; In case of error, make sure to remove semaphor
  .timer.startup.ddeoops -mio 1 1 .remove script\temp\semaphor.
  ; Temporarily switch DDE off
  .ddeserver off
  var %dat,%dde,%ext
  ; Scan mIRC IDs file and 'clean out' any unused entries
  if ($lof(script\temp\mircids.) > 0) {
    var %num = 1
    :clean
    %dat = $read(script\temp\mircids.,tn,%num)
    if (%dat) {
      %dde = $gettok(%dat,1,32)
      var %dde. $+ %dde
      ; Skip those that are still active ddes
      ; Cache which ddes we tested (for later)
      %dde. [ $+ [ %dde ] ] = $isdde(%dde)
      if (%dde. [ $+ [ %dde ] ] ) { inc %num | goto clean }
      ; Unused- delete temps and remove entry
      _remove.all $gettok(%dat,2,32) $+ .* $mircdirscript\temp\
      .write -dl [ $+ [ %num ] ] script\temp\mircids.
      goto clean
    }
  }
  ; Find the first available dde
  :loop
  %dde = mIRC $+ %ext
  if (%dde. [ $+ [ %dde ] ] == $null) { if ($isdde(%dde)) { inc %ext | goto loop } }
  elseif (%dde. [ $+ [ %dde ] ] ) { inc %ext | goto loop }
  .ddeserver on %dde
  if (%ext == $null) %ext = 0
  ; Reserve this DDE
  write script\temp\mircids. %dde %ext
  hadd pnp ext %ext
  .timer.startup.ddeoops off
  .remove script\temp\semaphor.
  _stecho Performing PnP startup... $chr(40) $+ profile - $hget(pnp,user) $+ $chr(41)
}

; DDE stuff can be disabled
#pnpdde on
; _broadcast command
; Causes all other copies of PnP to run a command
alias _broadcast {
  if ($lof(script\temp\mircids.) > 0) {
    var %dat,%num = 1
    :loop
    %dat = $read(script\temp\mircids.,tn,%num)
    if (%dat) {
      if ($gettok(%dat,1,32) != $ddename) {
        dde $ifmatch command "" /if ($_ispnp) $1-
      }
      inc %num
      goto loop
    }
  }
}
; _broadcastp command
; Causes all other copies of PnP with same profile to run a command
alias _broadcastp {
  if ($lof(script\temp\mircids.) > 0) {
    var %dat,%num = 1
    :loop
    %dat = $read(script\temp\mircids.,tn,%num)
    if (%dat) {
      if ($gettok(%dat,1,32) != $ddename) {
        dde $ifmatch command "" /if (($_ispnp) && ($hget(pnp,user) == $hget(pnp,user) $+ )) $1-
      }
      inc %num
      goto loop
    }
  }
}

; Check if a mircini is in use, other than by us
alias _inuse {
  if ($lof(script\temp\mircids.) > 0) {
    var %dat,%num = 1
    :loop
    %dat = $read(script\temp\mircids.,tn,%num)
    if (%dat) {
      if ($gettok(%dat,1,32) != $ddename) {
        if ($1- == $dde($gettok(%dat,1,32),inifile)) return 1
      }
      inc %num
      goto loop
    }
  }
  return 0
}
#pnpdde end

alias _broadcast return
alias _broadcastp return
alias _inuse return 0

; Kill temp files and dde status on exit
on *:EXIT:{
  _remove.all $hget(pnp,ext) $+ .* $mircdirscript\temp\
  .write -dw"& $hget(pnp,ext) $+ " script\temp\mircids.
}

; _remove.all filemask directory
; Deletes all matching files; returns count found
alias _remove.all return $findfile($2-,$1,0,.remove " $+ $1- $+ ")

; Enable or disable dde things
alias ddeoff {
  write -c script\temp\semaphor.
  .ddeserver off
  .disable #pnpdde
  _stecho DDE features disabled. If you open multiple copies of PnP $chr(40) $+ from the same copy of mIRC $+ $chr(41) things may not work properly.
}
alias ddeon {
  if ($group(#pnpdde) == on) _stecho DDE features are already enabled.
  else {
    _stecho DDE features enabled. You should restart PnP for this to properly take effect.
    .ddeserver on PNPTEMP
    .enable #pnpdde
  }
}

; Prep on opening connections, cleanup on closing connections
on *:ACTIVE:*:{
  if (($active == Status Window) && ($hget(pnp. $+ $activecid) == $null)) _update.new.connects
}

; Checks for new connects- called from above and from /server alias
alias _update.new.connects {
  var %scon = $scon(0)
  while (%scon) {
    if ($hget(pnp. $+ $scon(%scon)) == $null) {
      ; New connection
      scid $scon(%scon)
      _new.connection $cid
      .signal PNP.STATUSOPEN $cid
    }
    dec %scon
  }
  scid -r
}

on *:CLOSE:*:{
  if ($target == Status Window) {
    ; Closed connection
    .signal -n PNP.STATUSCLOSE $cid
    ; Small delay in case windows closing next reference the hashes
    .timer -io 1 1 _close.connection $cid
  }
}

alias -l _new.connection {
  hmake pnp. $+ $1 40
  hmake pnp.flood. $+ $1 20
  hmake pnp.ping. $+ $1 40
  hadd pnp. $+ $1 net Offline
  hadd pnp. $+ $1 title $_cfgi(title.here)
}

alias -l _close.connection {
  hfree pnp. $+ $1
  hfree pnp.flood. $+ $1
  hfree pnp.ping. $+ $1
  hfree -w pnp.flood. $+ $1 $+ .*
  hfree -w pnp.recseen. $+ $1 $+ .*
  hfree -w pnp.pingret. $+ $1 $+ .*
  hfree -w pnp.nickcol. $+ $1 $+ .*
  hfree -w pnp.nickflag. $+ $1 $+ .*
}

; Prep channel hashes (cleanup is done in LAST)
on me:^*:JOIN:#:{
  if ($hget($+(pnp.nickcol.,$cid,.,$chan))) hdel -w $+(pnp.nickcol.,$cid,.,$chan) *
  else hmake $+(pnp.nickcol.,$cid,.,$chan) 40
  if ($hget($+(pnp.nickflag.,$cid,.,$chan))) hdel -w $+(pnp.nickflag.,$cid,.,$chan) *
  else hmake $+(pnp.nickflag.,$cid,.,$chan) 40
  if ($hget($+(pnp.flood.,$cid,.,$chan))) hdel -w $+(pnp.flood.,$cid,.,$chan) *
  else hmake $+(pnp.flood.,$cid,.,$chan) 40
}

; Prepare hashes that are not connection-specific
alias -l _startup.prep {
  hmake pnp.qdns 20
  hmake pnp.qwhois 20
  hmake pnp.quserhost 20
  hmake pnp 40
  hmake pnp.config 40
}

; Misc startup settings
alias _mischash {
  hadd pnp pager $_cfgi(back.pager)
  hadd pnp logging 0
  hadd pnp newpages 0
  hadd pnp totalpages 0
  .ignore -r **!**@**
  _recclr dccget
  _reorderblack
  remini config\ $+ $hget(pnp,user) $+ \config.ini e
  if ($_cfgi(away.dq)) .dqwindow off
}

;
; Upgrade from previous PnPs
;
alias _pnp.upgrade {
  ; Last version that was run is stored as a profile-specific item
  var %lastver = $_cfgi(last.ver)

  ; Most update items here are OLD- from before we stored the last version number
  ; Therefore we need to verify these upgrades on a one-by-one basis
  if (!%lastver) {
    %lastver = 0

    ; An old beta had addons / serverlist in profiles.ini and not per-profile
    remini config\profiles.ini addons
    remini config\profiles.ini serverlist

    ; Redo addon popups if they're being stored in script dir
    if (script\ isin $script(adpopups.mrc)) _apopups
    if ($exists(script\adpopups.mrc)) {
      .unload -rs script\adpopups.mrc
      .remove script\adpopups.mrc
    }

    ; Same with serverlist (already updated from earlier)
    if ($exists(script\servers.mrc)) {
      .unload -rs script\servers.mrc
      .remove script\servers.mrc
    }

    ; display.dat updates- done before we move display.dat to theme/msgs
    var %ddat = $_cfg(display.dat)    
    if ($isfile(%ddat)) {
      if ($lines(%ddat) < 117) {
        write -il108 " $+ %ddat $+ " Please do not deop &nick&
        write -il109 " $+ %ddat $+ " Please do not ban &ban&, it matches &nick&, a protected user
        write -il115 " $+ %ddat $+ " Please do not kick &nick&
        write -il116 " $+ %ddat $+ " Please do not ban &nick&
      }
      if ($lines(%ddat) < 120) {
        write -il74 " $+ %ddat $+ " &nick&
        write -il114 " $+ %ddat $+ " &msg&
        write -il115 " $+ %ddat $+ " &msg&
      }
      if ($lines(%ddat) < 122) {
        write -il40 " $+ %ddat $+ " .
        write -il41 " $+ %ddat $+ " .
      }
    }

    ; Fix old sound.ini bug with having &size instead of &size&
    var %soundini = $_cfg(sound.ini)
    if ($exists(%soundini)) {
      _fixsini wav msg %soundini
      _fixsini wav msgdesc %soundini
      _fixsini mid msg %soundini
      _fixsini mid msgdesc %soundini
      _fixsini mp3 msg %soundini
      _fixsini mp3 msgdesc %soundini
    }

    if ($exists($_cfg(sound.ini))) remini $_cfg(sound.ini) *

    if ($isfile($_cfg(pw.ini))) {
      ; Remove !all from old nickserv addons storage
      filter -ffxc $_cfg(pw.ini) $_cfg(pw.ini) !all=*

      ; Changes to nsforce/csforce sections
      window -hnl @.force
      if ($ini($_cfg(pw.ini),nsforce)) {
        loadbuf -tnsforce @.force $_cfg(pw.ini)
        var %ln = 1
        while ($line(@.force,%ln)) {
          var %item = $gettok($line(@.force,%ln),1,61)
          var %data = $gettok($line(@.force,%ln),2-,61)
          if ((%data == 1 /) || (%data == 1 \)) writeini $_cfg(pw.ini) nsforce %item 1 NickServ@/nickserv anod
          elseif ((%data == 1 @) || (%data == 1 !)) writeini $_cfg(pw.ini) nsforce %item 1 NickServ@services.??? anod
          elseif (%data == 1 0) writeini $_cfg(pw.ini) nsforce %item 1 NickServ anod
          inc %ln
        }
        clear @.force
      }
      if ($ini($_cfg(pw.ini),csforce)) {
        loadbuf -tcsforce @.force $_cfg(pw.ini)
        var %ln = 1
        while ($line(@.force,%ln)) {
          var %item = $gettok($line(@.force,%ln),1,61)
          var %data = $gettok($line(@.force,%ln),2-,61)
          if ((%data == 1 \) || (%data == 1 /)) writeini $_cfg(pw.ini) csforce %item 1 ChanServ@/chanserv
          elseif ((%data == 1 !) || (%data == 1 @)) writeini $_cfg(pw.ini) csforce %item 1 ChanServ@services.???
          elseif (%data == 1 0) writeini $_cfg(pw.ini) csforce %item 1 ChanServ
          inc %ln
        }
      }
      window -c @.force

      ; Changes to xw section
      if ($ini($_cfg(pw.ini),xw)) {
        window -hnl @.xw
        loadbuf -txw @.xw $_cfg(pw.ini)
        if (($readini($_cfg(pw.ini),n,xw,nets) == $null) && ($line(@.xw,0))) {
          var %ln = 1,%xall,%zall,%xnets
          while ($line(@.xw,%ln)) {
            var %item = $gettok($line(@.xw,%ln),1,61)
            var %data = $gettok($line(@.xw,%ln),2-,61)
            if (%item != all) {
              if (a#* iswm %item) {
                writeini $_cfg(pw.ini) xw-undernet %item %data
                writeini $_cfg(pw.ini) xw-ozorg %item %data
              }
              elseif (X * iswm %data) {
                writeini $_cfg(pw.ini) xw-undernet %item %data
                %xall = $addtok(%xall,%item,32)
              }
              elseif (Z * iswm %data) {
                writeini $_cfg(pw.ini) xw-ozorg %item %data
                %zall = $addtok(%zall,%item,32)
              }
            }
            inc %ln
          }
          if (%xall) {
            writeini $_cfg(pw.ini) xw-undernet all %xall
            %xnets = Undernet
          }
          else remini $_cfg(pw.ini) xw-undernet
          if (%zall) {
            writeini $_cfg(pw.ini) xw-ozorg all %zall
            %xnets = %xnets OzOrg
          }
          else remini $_cfg(pw.ini) xw-ozorg
          remini $_cfg(pw.ini) xw
          if (%xnets) writeini $_cfg(pw.ini) xw nets %xnets
        }
        window -c @.xw
      }
    }

    ; Inline nick completion setting?
    if (($_cfgi(nc.askin) == $null) && ($_cfgi(nc.ask) == $null)) {
      `set nci.char ;
      _cfgw nc.askin 0
    }

    ; Popups settings?
    if ($hget(pnp.config,popups.1) == $null) {
      `set popups.1 111100111111
      `set popups.2 010111111011
      `set popups.3 111111110111
      `set popups.4 001111111111
      `set popups.5 111111111111
      `set popups.6 111001111111
    }

    ; DCC queue settings?
    if ($_cfgi(dccmaxsendone) == $null) {
      _cfgw dccmaxsendone 5
      _cfgw dccmaxsendall 20
      _cfgw dccmaxqone 2
      _cfgw dccmaxqall 0
      _cfgw dccqueuehide 1
      _cfgw dccsendhide 0
      `set dccqueueclean 01101
    }

    ; Some other added settings
    if ($hget(pnp.config,whois.shared) == $null) {
      `set whois.shared 1
    }
    if ($hget(pnp.config,awaylog.perm) == $null) {
      `set awaylog.perm 0
    }
    if ($hget(pnp.config,serv.notice) == $null) {
      `set serv.notice $hget(pnp.config,reg.notice)
    }
    if ($hget(pnp.config,popups.hideop) == $null) {
      `set popups.hideop 0
    }
    if ($_cfgi(away.ignchan) == $null) {
      _cfgw away.ignchan 0
    }
    if ($_cfgi(away.ignidle) == $null) {
      _cfgw away.ignidle 0
    }
    if ($_cfgi(away.ignidletime) == $null) {
      _cfgw away.ignidletime 30
    }
    if ($_cfgi(away.allconnect) == $null) {
      _cfgw away.allconnect 1
    }
    if ($hget(pnp.config,awaywords.hl) == $null) {
      `set awaywords.hl 0
    }
    if ($hget(pnp.config,awaywords.limit) == $null) {
      `set awaywords.limit 0
    }
    if ($_cfgi(topic.sep) == $null) {
      _cfgw topic.sep //
    }
    if ($len($hget(pnp.config,sound.grab)) == 5) {
      hadd pnp.config sound.grab $hget(pnp.config,sound.grab) $+ 1
    }

    ; Combine all nc.ask settings into one
    if ($_cfgi(nc.ask) == $null) {
      if (($_cfgi(nc.askchan)) || ($_cfgi(nc.askcmd)) || ($_cfgi(nc.askin))) {
        _cfgw nc.ask 1
      }
      else {
        _cfgw nc.ask 0
      }
      _cfgw nc.askchan
      _cfgw nc.askcmd
      _cfgw nc.askin
    }

    ; New bits on personal prot setting- 8 and 16 for reply to version/other ctcps
    `set myflood.prot $calc($hget(pnp.config,myflood.prot) % 8 + 24)

    ; cflags must all be 80 tokens
    var %num = $hmatch(pnp.config,cflags*,0)
    while (%num) {
      %item = $hmatch(pnp.config,cflags*,%num)
      if ((%item == cflags) || (cflags.* iswm %item)) {
        var %data = $hget(pnp.config,%item)
        while ($numtok(%data,32) < 80) { %data = $instok(%data,?,0,32) }
        `set %item %data
      }
      dec %num
    }

    ; Recent topics/kicks should have &chan&, not &channel&
    var %file = $_cfg(topic.lis)
    if ($isfile(%file)) {
      window -hl @.recent
      loadbuf @.recent %file
      var %ln = $line(@.recent,0)
      while (%ln) {
        rline @.recent %ln $replace($line(@.recent,%ln),&channel&,&chan&)
        dec %ln
      }
      savebuf @.recent %file
      window -c @.recent
    }
    var %file = $_cfg(kick.lis)
    if ($isfile(%file)) {
      window -hl @.recent
      loadbuf @.recent %file
      var %ln = $line(@.recent,0)
      while (%ln) {
        rline @.recent %ln $replace($line(@.recent,%ln),&channel&,&chan&)
        dec %ln
      }
      savebuf @.recent %file
      window -c @.recent
    }

    ; Generate chopt vars
    if ($hget(pnp.config,chopt) == $null) {
      var %chopts = $iif($_cfgi(tempban.time) isnum,$ifmatch,300) $iif($_cfgi(tempban.type) isnum,$ifmatch,1)
      %chopts = %chopts $iif($hget(pnp.config,ban.id) isnum,$ifmatch,3) $iif($hget(pnp.config,ban.dom) isnum,$ifmatch,5)
      %chopts = %chopts $iif($_cfgi(check.ops),1,0) $iif($hget(pnp.config,show.punish),1,0) $iif($hget(pnp.config,clone.join),1,0)
      %chopts = %chopts $iif($hget(pnp.config,delay.kicks),1,0) 16 $iif($hget(pnp.config,show.banned),1,0) 26 27 79 80
      ; Convert all channels that have a cflags
      var %num = $hmatch(pnp.config,cflags*,0)
      while (%num) {
        %item = $hmatch(pnp.config,cflags*,%num)
        if ((%item == cflags) || (cflags.* iswm %item)) {
          ; Chan name and name of new chopts var
          var %chan = $mid(%item,8)
          var %name = chopt $+ $mid(%item,7)
          ; Add in whois/ircop flags from cflags
          %chopts = $puttok(%chopts,$_getcflag(%chan,16),9,32)
          %chopts = $puttok(%chopts,$_getcflag(%chan,26),11,32)
          %chopts = $puttok(%chopts,$_getcflag(%chan,27),12,32)
          %chopts = $puttok(%chopts,$_getcflag(%chan,79),13,32)
          %chopts = $puttok(%chopts,$_getcflag(%chan,80),14,32)
          ; Store
          `set %name %chopts
          ; Reset those flags to 0 or ? (flag 80 now used for halfop prot, so use setting for voice prot)
          var %set = ?
          if (%chan == $null) {
            %set = 0
            %chan = *
          }
          _setcflag %chan 16 %set
          _setcflag %chan 26 %set
          _setcflag %chan 27 %set
          _setcflag %chan 79 %set
          _setcflag %chan 80 $_getcflag(%chan,70)
        }
        dec %num
      }
    }

    ; New favorites sections
    if ($readini($_cfg(config.ini),n,favopt,all) == $null) {
      var %ini = $_cfg(config.ini)
      ; For every favorites network including 'all', add options based off current settings
      ; Also, replace commas with spaces in channels
      var %ln = $ini(%ini,fav,0)
      while (%ln) {
        var %item = $ini(%ini,fav,%ln)
        _cfgxw favopt %item $iif($_cfgi(fav.auto),1,0) 0 - - -
        _cfgxw fav %item $replace($_cfgx(fav,%item),$chr(44),$chr(32))
        dec %ln
      }
      _cfgxw favopt all $iif($_cfgi(fav.auto),1,0) 0 - - -
      if ($_cfgx(fav,all)) _cfgxw fav all $replace($ifmatch,$chr(44),$chr(32))
    }

    ; Variables phased out or cleanup; settings removal
    unset %~* %_* %-* %!* %>* %`* %@* %mid
    _recclr log
    `set horizline
    `set themeop
    `set ns.autologin
    `set popupmark
    `set hide.status.quit
    `set ctcp.q
    `set mask.id
    `set mask.dom
    `set ban.id
    `set ban.dom
    `set show.punish
    `set clone.join
    `set delay.kicks
    `set show.banned
    _cfgw whois.sep
    _cfgw format.datetime
    _cfgw fav.auto
    _cfgw tempban.time
    _cfgw tempban.type
    _cfgw check.ops

    ; Update to new theme format
    ; First, create file if non-exist
    if (!$isfile($_cfg(theme.mtp))) {
      ; Add pnp default theme if no text.dat or 'in progress' text.dat loaded
      var %textdat = $_cfg(text.dat)
      if ((!$isfile(%textdat)) || ($gettok($read(%textdat,n,1),-2-,32) == In progress)) {
        .copy -o "script\blankpnp.mtp" " $+ $_cfg(theme.mtp) $+ "
      }
      else {
        .copy -o "script\blank.mtp" " $+ $_cfg(theme.mtp) $+ "
      }
      ; Changed theme- force a reload on start
      if ($isfile($_cfg(theme.ct1))) .remove " $+ $_cfg(theme.ct1) $+ "
      if ($isfile($_cfg(theme.ct2))) .remove " $+ $_cfg(theme.ct2) $+ "
    }

    if ($isfile($_cfg(text.dat))) .remove " $+ $_cfg(text.dat) $+ "

    ; Load in settings from display.dat if stil present
    if ($isfile($_cfg(display.dat))) {
      var %file = " $+ $_cfg(theme.mtp) $+ "
      window -hln @.display
      window -hln @.msgs
      loadbuf @.display " $+ $_cfg(display.dat) $+ "
      ; (use display color as default color for ctcps)
      color ctcp $line(@.display,3)
      write -sBaseColors %file BaseColors $line(@.display,3) $+ , $+ $line(@.display,4) $+ , $+ $line(@.display,5) $+ , $+ $line(@.display,5)
      write -sColorError %file ColorError 04
      write -sBoldLeft %file BoldLeft $line(@.display,8)
      write -sBoldRight %file BoldRight $line(@.display,9)
      write -sPrefix %file Prefix $line(@.display,18)
      ; turn left/right brackets into chrs
      var %left = $line(@.display,12),%newleft,%pos = 1
      while (%pos <= $len(%left)) {
        if (%newleft) %newleft = %newleft $!+
        %newleft = %newleft $!chr( $+ $asc($mid(%left,%pos,1)) $+ )
        inc %pos
      }
      var %right = $line(@.display,13),%newright,%pos = 1
      %pos = 1
      while (%pos <= $len(%right)) {
        if (%newright) %newright = %newright $!+
        %newright = %newright $!chr( $+ $asc($mid(%right,%pos,1)) $+ )
        inc %pos
      }
      if (%newleft == $null) %newleft = $!chr(91)
      if (%newright == $null) %newright = $!chr(93)
      write -sEchoTarget %file EchoTarget !Script % $+ :echo % $+ ::pre %newleft $!+ $!:s(%::target) $!+ %newright % $+ ::text
      `set bracket.left $line(@.display,14)
      `set bracket.right $line(@.display,15)
      if (a * iswm $line(@.display,23)) write -sPnPLineSep %file PnPLineSep $gettok($line(@.display,23),2-,32)
      elseif (b * iswm $line(@.display,23)) write -sLineSep %file LineSep $gettok($line(@.display,23),2-,32)
      .remove " $+ $_cfg(display.dat) $+ "
      ; Sounds
      var %ln = 26
      var %saveto = Connect,Disconnect,QuitSelf,Start,*,DCC,DCCSend,FileRcvd,FileSent,GetFail,*,Open,Notice,NoticeChanOp,Wallop,NoticeServer,*,KickSelf,OpSelf,DeopSelf,Invite,Kick,*,Notify,UNotify,NotifyFail,UNotifyFail,*,Away,Back,AwayAuto,Pager,*,ProtectSelf,ProtectChan,NickTaken,SelfLag,NoJoin,Clones,Alert,*,Error,Complete,Question,Confirm
      while (%ln <= 70) {
        var %data = $line(@.display,%ln)
        if ((%data) && (%data != .) && ($gettok(%saveto,$calc(%ln - 25),44) != *)) {
          var %item = Snd $+ $ifmatch
          write -s $+ %item %file %item %data
        }
        inc %ln
      }
      ; Messages
      %ln = 73
      %saveto = part,quit,nc,nci,*,*,away,awayrep,back,backnote,waway,wawayp,remind,autoaway,awaychat,*,*,awayword,pageron,pageroff,*,*,pnotice,cnotice,snotice,lnotice,onotice,ovnotice,peon,allbut,*,*,rejectchat,rejectsend,rejectchata,rejectsenda,ignoreall,ignoreallbut,protectd,protectbn,*,*,kick,kwrap,tbwrap,banned,black,protectk,protectb
      while (%ln <= 121) {
        var %data = $line(@.display,%ln)
        if ((%data) && (%data != .) && ($gettok(%saveto,$calc(%ln - 72),44) != *)) {
          var %item = $ifmatch
          ; Some changes to msg format from last version- identifiers and &count& in kick msgs
          if ($istok(kick kwrap tbwrap banned black,%item,32)) %item = $replace(%item,&count&,&kickseq&)
          %item = $replace(%item,<$upper$,$ $+ upper $+ $chr(40),>$upper$,$chr(41))
          %item = $replace(%item,<$lower$,$ $+ lower $+ $chr(40),>$lower$,$chr(41))
          %item = $replace(%item,<$ulinei$,$ $+ ulinei $+ $chr(40),>$ulinei$,$chr(41))
          %item = $replace(%item,<$colori$,$ $+ colori $+ $chr(40),>$colori$,$chr(41))
          %item = $replace(%item,<$color2i$,$ $+ color2i $+ $chr(40),>$color2i$,$chr(41))
          %item = $replace(%item,<$funkyi$,$ $+ funkyi $+ $chr(40),>$funkyi$,$chr(41))
          %item = $replace(%item,<$boldi$,$ $+ boldi $+ $chr(40),>$boldi$,$chr(41))
          %item = $replace(%item,<$codei$,$ $+ codei $+ $chr(40),>$codei$,$chr(41))
          %item = $replace(%item,<$uvoweli$,$ $+ uvoweli $+ $chr(40),>$uvoweli$,$chr(41))
          %item = $replace(%item,<$lvoweli$,$ $+ lvoweli $+ $chr(40),>$lvoweli$,$chr(41))
          aline @.msgs %item %data
        }
        inc %ln
      }
      ; ohnotice message
      aline @.msgs ohnotice (ohnotice/&chan&/&ops&@/&hops&%)
      savebuf @.msgs " $+ $_cfg(msgs.dat) $+ "
      close -@ @.display @.msgs
      .remove " $+ $_cfg(display.dat) $+ "
      ; Changed theme- force a reload on start
      if ($isfile($_cfg(theme.ct1))) .remove " $+ $_cfg(theme.ct1) $+ "
      if ($isfile($_cfg(theme.ct2))) .remove " $+ $_cfg(theme.ct2) $+ "
    }

    ; Load nick color settings from current
    if ($hget(pnp.config,nickcol) == 16) {
      var %tok = 1,%n1,%n2,%n3
      var %nickcol = $hget(pnp.config,nickcol)
      while (%tok <= 8) {
        var %old = $gettok(%nickcol,%tok,32)
        var %sub = 1
        while (%sub <= 3) {
          %n [ $+ [ %sub ] ] = %n [ $+ [ %sub ] ] $gettok(%old,%sub,45)
          inc %sub
        }
        inc %tok
      }
      write -sPnPNickColors " $+ $_cfg(theme.mtp) $+ " PnPNickColors %n1 $+ , $+ %n2 $+ , $+ %n3 $+ , $+ %n3
      `set nickcol
      ; Changed theme- force a reload on start
      if ($isfile($_cfg(theme.ct1))) .remove " $+ $_cfg(theme.ct1) $+ "
      if ($isfile($_cfg(theme.ct2))) .remove " $+ $_cfg(theme.ct2) $+ "
    }

    ; Delete some outdated files (that aren't scripts- those must be deleted in another section)
    if ($exists(script\spliterr.dat)) { .remove script\spliterr.dat }
    if ($exists(script\scheme.dat)) { .remove script\scheme.dat }
    if ($exists(script\blanktxs.dat)) { .remove script\blanktxs.dat }
    if ($exists(addons\genre.txt)) { .remove addons\genre.txt }
    if ($exists(script\pp400title-b.bmp)) { .remove script\pp400title-b.bmp }

    ; Old themes
    if ($exists(schemes\blank.txs)) { .remove schemes\blank.txs }
    if ($exists(schemes\eleet.txs)) { .remove schemes\eleet.txs }
    if ($exists(schemes\progress.txs)) { .remove schemes\progress.txs }
    if ($exists(schemes\test.txs)) { .remove schemes\test.txs }
    if ($exists(themes\blue-bk.ppt)) { .remove themes\blue-bk.ppt }
    if ($exists(themes\pai.ppt)) { .remove themes\pai.ppt }
    if ($exists(themes\pnp.ppt)) { .remove themes\pnp.ppt }
    if ($exists(themes\mirc.ppt)) { .remove themes\mirc.ppt }
    if ($exists(themes\eleet.ppt)) { .remove themes\eleet.ppt }
  }

  if (%lastver < 4.21) {
    ; Var no longer used
    `set nickcol

    ; Correct problems in favorites- space-delimited, not comma-delimited
    var %ini = $_cfg(config.ini)
    var %ln = $ini(%ini,fav,0)
    while (%ln) {
      var %item = $ini(%ini,fav,%ln)
      _cfgxw fav %item $replace($_cfgx(fav,%item),$chr(44),$chr(32))
      dec %ln
    }
    var %ln = $ini(%ini,favserv,0)
    while (%ln) {
      var %item = $ini(%ini,favserv,%ln)
      _cfgxw favserv %item $replace($_cfgx(favserv,%item),$chr(44),$chr(32))
      dec %ln
    }

    ; Correct $chr(1) in msgs
    if ($isfile($_cfg(msgs.dat))) {
      window -hln @.msgs
      loadbuf @.msgs " $+ $_cfg(msgs.dat) $+ "
      var %ln = $line(@.msgs,0)
      while (%ln) {
        rline @.msgs %ln $replace($line(@.msgs,%ln),$chr(1),&)
        dec %ln
      }
      savebuf @.msgs " $+ $_cfg(msgs.dat) $+ "
      window -c @.msgs
    }

    ; Remove SCHEMES dir if empty
    if (($isdir(SCHEMES)) && ($findfile(SCHEMES\,*,1) == $null)) .rmdir SCHEMES

    ; Correct <$:t$&nick&>$:t$ in actions.dat
    if ($isfile($_cfg(actions.dat))) {
      window -hln @.actions
      loadbuf @.actions " $+ $_cfg(actions.dat) $+ "
      var %ln = $line(@.actions,0)
      while (%ln) {
        var %data = $line(@.actions,%ln)
        %data = $replace(%data,<$:t$,$ $+ :t $+ $chr(40),>$:t$,$chr(41))
        rline @.actions %ln %data
        dec %ln
      }
      savebuf @.actions " $+ $_cfg(actions.dat) $+ "
      window -c @.actions
    }
  }

  if (%lastver < 4.22) {
    ; Fixes to nsforce/csforce sections
    window -hnl @.force
    if ($ini($_cfg(pw.ini),nsforce)) {
      loadbuf -tnsforce @.force $_cfg(pw.ini)
      var %ln = 1
      while ($line(@.force,%ln)) {
        var %item = $gettok($line(@.force,%ln),1,61)
        var %data = $gettok($line(@.force,%ln),2-,61)
        if ($gettok(%data,1-2,32) == 1 /nickserv) writeini $_cfg(pw.ini) nsforce %item 1 NickServ@/nickserv $gettok(%data,3-,32)
        inc %ln
      }
      clear @.force
    }
    if ($ini($_cfg(pw.ini),csforce)) {
      loadbuf -tcsforce @.force $_cfg(pw.ini)
      var %ln = 1
      while ($line(@.force,%ln)) {
        var %item = $gettok($line(@.force,%ln),1,61)
        var %data = $gettok($line(@.force,%ln),2-,61)
        if ($gettok(%data,1-2,32) == 1 /chanserv) writeini $_cfg(pw.ini) csforce %item 1 ChanServ@/chanserv $gettok(%data,3-,32)
        inc %ln
      }
    }
    window -c @.force

    ; Remove translation data from profiles.ini
    remini config\profiles.ini translation

    ; Raw-route
    `set rawroute -si2

    ; Adjust lagbar position
    if ($_cfgx(extras,lagpos)) {
      var %pos = $ifmatch
      if ($_cfgx(extras,lagdock)) {
        %pos = $calc($gettok(%pos,1,32) - $window(-2).x) $calc($gettok(%pos,2,32) - $window(-2).y)
        _cfgxw extras lagpos %pos
      }
    }

    ; Note in status about /wizard
    writeini config\profiles.ini startup saywizard 1
  }

  ; Remember what version for next upgrade
  _cfgw last.ver $:bver
}
; (this is used above in upgrades)
alias -l _fixsini {
  var %line = $readini($3-,n,$1,$2)
  if ((&size isin %line) && (&size& !isin %line)) writeini " $+ $3- $+ " $1 $2 $replace(%line,&size,&size&)
}

;
; Blacklist halting
;
on ^black:OPEN:?:*:halt
on ^black:INVITE:#:halt
on ^black:NOTICE:*:?:halt
ctcp black:*:?:.ignore -dtu20 $wildsite | if ($1 != VERSION) halt

;
; DNS queue
;
on *:DNS:{
  var %who = $cid $+ . $+ $iif($nick,: $+ $nick,$address),%do = $hget(pnp.qdns,%who)
  if ($gettok(%do,3-,32)) hadd pnp.qdns %who $ifmatch
  else hdel pnp.qdns %who
  if (%do) {
    if ($raddress == $null) $_p2s($gettok(%do,2,32))
    else $_p2s($gettok(%do,1,32))
    halt
  }
}
; Clean queue on disconnect
on *:DISCONNECT:{ hdel -w pnp.qdns $cid $+ .:* }

alias -l _dnsshow {
  var %ln = 1
  set -u %:echo echo $color(other) -t $+ $_cfgi(eroute)
  while (%ln <= $dns(0)) {
    var %resolved = $iif($dns(%ln).addr == $dns(%ln),$dns(%ln).ip,$dns(%ln).addr)
    if (%ln == 1) {
      _Q.fkey 1 $calc($ctime + 300) clipboard %resolved
      set -u %:comments (Press $result to copy to clipboard)
    }
    else unset %:comments
    set -u %::address $dns(%ln)
    set -u %::naddress $dns(%ln).addr
    set -u %::iaddress $dns(%ln).ip
    set -u %::raddress %resolved
    set -u %::nick $dns(%ln).nick
    theme.text DNSResolve
    inc %ln
  }
}
alias -l _dnsfail {
  set -u %:echo echo $color(other) -t $+ $_cfgi(eroute)
  set -u %::nick $nick
  set -u %::iaddress $iaddress
  set -u %::naddress $naddress
  set -u %::address $iif($iaddress,$iaddress,$naddress)
  if ($iaddress) {
    _Q.fkey 1 $calc($ctime + 300) clipboard $iaddress
    set -u %:comments (Press $result to copy to clipboard)
  }
  theme.text DNSError
}

;
; Input wrapper- handles inline nick completion, allows multiple INPUTs to modify same text
;
alias _getcc set -u1 %.cmdchar $readini($mircini,n,text,commandchar)
on *:INPUT:*:{
  ; (so nick completion routines know we ran this from cmd line)
  set -u1 %.from-input-nc 1
  if ((($target !ischan) && ($query($target) == $null) && (=* !iswm $target)) || ($cmdbox)) return
  if ($hget(pnp,lastsrec)) .timer -mio 1 1 hdel pnp lastsrec
  _getcc
  var %cc = %.cmdchar
  var %text,%type
  if (($left($1,1) != %.cmdchar) || ($mouse.key & 2)) { if ($1- == $null) halt | %text = /say $1- | %type = say }
  elseif (?me iswm $1) { %text = $1- | %type = me }
  else { %text = $1- | %type = cmd }
  ; Do inline nick completion -now-
  if (($target ischan) && ($mouse.key !& 2) && ($hget(pnp.config,nci.char) isin $1-)) {
    var %num = 1,%check = $ifmatch $+ ?*
    :loop
    if ($wildtok(%text,%check,%num,32)) {
      var %tok = $ifmatch,%old = $right($ifmatch,$calc(- $len($hget(pnp.config,nci.char)))),%aft
      :loopc | if ($right(%old,1) isin -!"#$%&'()*+,./:;<=>?@~) { %aft = $ifmatch $+ %aft | %old = $left(%old,-1) | goto loopc }
      var %found = $_nci(%old,$chan)
      if (($numtok(%found,32) > 1) && ($_cfgi(nc.ask))) {
        %.part = %old
        %.found = $_s2c(%found)
        _ssplay Question
        %found = $dialog(nickcomp,nickcomp,-4)
        if (%found == $null) halt
      }
      if (%found ison $chan) %aft = $_ncin(%found,$chan,%type) $+ %aft
      else { %aft = $hget(pnp.config,nci.char) $+ %old $+ %aft | inc %num }
      %text = $reptok(%text,%tok,%aft,1,32)
      goto loop
    }
  }
  set -u1 %.from-input-nc 1
  set -u1 %.input.text %text
  set -u1 %.input.type %type
  set -u1 %.cmdchar %cc
  if (($active ischan) && ($hget(pnp.config,nc.char)) && (%.input.type == say)) _do.thenc %.input.text
}
alias -l _ncin if ($3 == cmd) return $1 | return $msg.compile($_msg(nci),&op&,$_stsym($1,$2),&nick&,$1,&chan&,$2)

;
; For invite checking- so the raws are hidden from later scripts
;
raw 324:*:{
  if ($istok($hget(pnp. $+ $cid,-invited),$2,32)) {
    hadd pnp. $+ $cid -invited $remtok($hget(pnp. $+ $cid,-invited),$2,1,32)
    hadd pnp. $+ $cid -invited2 $hget(pnp. $+ $cid,-invited2) $2
    var %nick = $hget(pnp. $+ $cid,-invn. $+ $2)
    if ($_optn(3,11)) {
      _show.invite $:b($gettok(%nick,1,32)) $2 ( $+ channel mode $3- $+ ) - Auto-joining
      join -n $2
    }
    else {
      _show.invite $:b($gettok(%nick,1,32)) $2 ( $+ channel mode $3- $+ ) - Press ShiftF11 to join
      _recseen 10 chan $2
    }
    _ssplay Invite
    _recseen 10 user $gettok(%nick,1,32)
    if ($numtok(%nick,32) > 1) hadd pnp. $+ $cid -invn. $+ $2 $gettok(%nick,2-,32)
    else hdel pnp. $+ $cid -invn. $+ $2
    halt
  }
}
raw 329:*:{
  if ($istok($hget(pnp. $+ $cid,-invited2),$2,32)) {
    hadd pnp. $+ $cid -invited2 $remtok($hget(pnp. $+ $cid,-invited2),$2,1,32)
    halt
  }
}
raw 403:*no such channel*:{
  if ($istok($hget(pnp. $+ $cid,-invited),$2,32)) {
    hadd pnp. $+ $cid -invited $remtok($hget(pnp. $+ $cid,-invited),$2,1,32)
    var %nick = $hget(pnp. $+ $cid,-invn. $+ $2)
    _show.invite $:b($gettok(%nick,1,32)) $2 ( $+ $:b(channel does not exist) $+ ) - Press ShiftF11 to join
    _recseen 10 user $gettok(%nick,1,32)
    if ($numtok(%nick,32) > 1) hadd pnp. $+ $cid -invn. $+ $2 $gettok(%nick,2-,32)
    else hdel pnp. $+ $cid -invn. $+ $2
    _recseen 10 chan $2
    halt
  }
}

;
; Predetermine if notices are 'sort of' opnotices
;
on ^*:NOTICE:*:?:{
  if (($chr(35) isin $1-3) && ($istok($hget(pnp. $+ $cid,-servnick),$nick,32) == $false)) {
    var %num = $comchan($nick,0)
    while (%num) {
      if (($comchan($nick,%num) isin $1-3) && (($comchan($nick,%num).op) || ($comchan($nick,%num).help)) && (($nick isop $comchan($nick,%num)) || ($nick ishop $comchan($nick,%num)))) {
        set -u1 %.opnotice $comchan($nick,%num)
        return
      }
      dec %num
    }
  }
  unset %.opnotice
}

;
; Pre-determine any standard DCC to be invalid
; %.dcc.invalid = invalid status, %.dcc.file = filename, %.dcc.port %.dcc.size %.dcc.id %.dcc.ip set also
;
ctcp *:DCC:*:{
  unset %.dcc.*
  if ($istok(CHAT SEND RESUME ACCEPT,$2,32)) {
    ; if (standard) DCC, check for invalid
    if ((" isin $3-) && (($2 == CHAT) || (& "*" * !iswm $2-) || ($count($2-,") != 2))) { set -u1 %.dcc.invalid Invalid quotes | return }
    if (("* iswm $3) && ($2 != CHAT)) { set -u1 %.dcc.file $gettok($2-,2,34) | var %rest = $gettok($2-,3-,34) }
    else { set -u1 %.dcc.file $3 | var %rest = $4- }
    if ($istok(RESUME ACCEPT,$2,32)) {
      set -u1 %.dcc.port $gettok(%rest,1,32) | set -u1 %.dcc.size $gettok(%rest,2,32) | set -u1 %.dcc.id $gettok(%rest,3,32)
      if (%.dcc.port == $null) { set -u1 %.dcc.invalid Missing parameters | return }
    }
    else {
      set -u1 %.dcc.ip $gettok(%rest,1,32) | set -u1 %.dcc.port $gettok(%rest,2,32) | set -u1 %.dcc.size $gettok(%rest,3,32) | set -u1 %.dcc.id $gettok(%rest,4,32)
      if (%.dcc.port == $null) { set -u1 %.dcc.invalid Missing parameters | return }
      if ((%.dcc.ip !isnum) || (. isin %.dcc.ip) || ($longip(%.dcc.ip) == $null)) { set -u1 %.dcc.invalid Invalid IP- %.dcc.ip | return }
      if (($gettok($longip(%.dcc.ip),1,46) == 127) || ($gettok($longip(%.dcc.ip),1,46) > 223) || ($gettok($longip(%.dcc.ip),1,46) == 0) || ($gettok($longip(%.dcc.ip),1-2,46) == 128.0) || ($gettok($longip(%.dcc.ip),1,46) == 192.0.0)) { set -u1 %.dcc.invalid Invalid IP- $longip(%.dcc.ip) | return }
    }
    if (($2 != CHAT) && ($remove($nopath(%.dcc.file),<,>,$chr(124),:,*,?,/,\,") != $nopath(%.dcc.file))) set -u1 %.dcc.invalid Invalid filename
    elseif (($2 != CHAT) && ($regex(%.dcc.file,/\.[^.][^.][^.]?[^.]?\.[^.][^.][^.]?[^.]?/)) && ($istok(pl.js.vbs.shs.scr.exe.com.pif.lnk.bat.htm.hta.reg.html,$gettok(%.dcc.file,-1,46),46))) set -u1 %.dcc.invalid Possible virus
    elseif ((%.dcc.size != $null) && ((%.dcc.size !isnum) || (. isin %.dcc.size) || (%.dcc.size < 1) || ($len(%.dcc.size) > 12))) set -u1 %.dcc.invalid Invalid size
    elseif (%.dcc.port == 0) { if ((%.dcc.id !isnum) || (. isin %.dcc.id) || (%.dcc.id < 0)) set -u1 %.dcc.invalid Invalid SOCKS parameters }
    elseif ((%.dcc.port !isnum 1024-65535) || (. isin %.dcc.port)) set -u1 %.dcc.invalid Invalid port
  }
}

;
; Predetermine who is banned
; If over 10 users, only stores count
;
on *:BAN:#:{
  set -u1 %.ban.count $ialchan($banmask,$chan,0)
  if (%.ban.count < 11) {
    var %who,%num = %.ban.count
    :loop
    %who = %who $ialchan($banmask,$chan,%num).nick
    if (%num > 1) { dec %num | goto loop }
    set -u1 %.ban.who %who
  }
  else unset %.ban.who
}

;
; Allows any number of routines to trigger a whois-on-join
;
on !*:JOIN:#:{ unset %.joinwhois.do | %.joinwhois.show = 0 }

;
; Preempt any non-DCC, non-VERSION CTCPs if being ignored
;
ctcp *:*:*:{
  if ($1 != VERSION) {
    if (($hget(pnp.flood. $+ $cid,ignore.ctcp)) || ($hget(pnp.flood. $+ $cid,ignore.ctcp. $+ $site))) halt
  }
}

;
; POPUPS HERE
;
menu status {
  $iif(($mid($hget(pnp.config,popups.5),3,1) != 0) || ($mouse.key & 2),Favorites)
  .$submenu($_favservpop($1))
  .$submenu($_favpop($1))
  .$iif(($hget(pnp. $+ $cid,net) != Offline) && (!%.popfound),Add $server):fav + $hget(pnp. $+ $cid,net) $server $port
  .$iif(%.popfound,Remove $server):fav - $server
  .-
  .Add...:fav +
  .Remove...:fav -
  .Edit...:fav
  $iif(($mid($hget(pnp.config,popups.5),9,1) != 0) || ($mouse.key & 2),Connect)
  .$_rec(srv,1):server $iif(($hget(pnp. $+ $cid,net) != Offline) && ($hget(pnp. $+ $cid,net) != $server($gettok(%=srv.1,1,44)).group) && ($server($server).group != $server($gettok(%=srv.1,1,44)).group),-m) $remove(%=srv.1,$chr(44))
  .$_rec(srv,2):server $iif(($hget(pnp. $+ $cid,net) != Offline) && ($hget(pnp. $+ $cid,net) != $server($gettok(%=srv.2,1,44)).group) && ($server($server).group != $server($gettok(%=srv.2,1,44)).group),-m) $remove(%=srv.2,$chr(44))
  .$_rec(srv,3):server $iif(($hget(pnp. $+ $cid,net) != Offline) && ($hget(pnp. $+ $cid,net) != $server($gettok(%=srv.3,1,44)).group) && ($server($server).group != $server($gettok(%=srv.3,1,44)).group),-m) $remove(%=srv.3,$chr(44))
  .$_rec(srv,4):server $iif(($hget(pnp. $+ $cid,net) != Offline) && ($hget(pnp. $+ $cid,net) != $server($gettok(%=srv.4,1,44)).group) && ($server($server).group != $server($gettok(%=srv.4,1,44)).group),-m) $remove(%=srv.4,$chr(44))
  .$_rec(srv,5):server $iif(($hget(pnp. $+ $cid,net) != Offline) && ($hget(pnp. $+ $cid,net) != $server($gettok(%=srv.5,1,44)).group) && ($server($server).group != $server($gettok(%=srv.5,1,44)).group),-m) $remove(%=srv.5,$chr(44))
  .$_rec(srv,6):server $iif(($hget(pnp. $+ $cid,net) != Offline) && ($hget(pnp. $+ $cid,net) != $server($gettok(%=srv.6,1,44)).group) && ($server($server).group != $server($gettok(%=srv.6,1,44)).group),-m) $remove(%=srv.6,$chr(44))
  .$_rec(srv,7):server $iif(($hget(pnp. $+ $cid,net) != Offline) && ($hget(pnp. $+ $cid,net) != $server($gettok(%=srv.7,1,44)).group) && ($server($server).group != $server($gettok(%=srv.7,1,44)).group),-m) $remove(%=srv.7,$chr(44))
  .$_rec(srv,8):server $iif(($hget(pnp. $+ $cid,net) != Offline) && ($hget(pnp. $+ $cid,net) != $server($gettok(%=srv.8,1,44)).group) && ($server($server).group != $server($gettok(%=srv.8,1,44)).group),-m) $remove(%=srv.8,$chr(44))
  .$_rec(srv,9):server $iif(($hget(pnp. $+ $cid,net) != Offline) && ($hget(pnp. $+ $cid,net) != $server($gettok(%=srv.9,1,44)).group) && ($server($server).group != $server($gettok(%=srv.9,1,44)).group),-m) $remove(%=srv.9,$chr(44))
  .-
  .%=srv.clr:_recclr srv | if ($server) _recent srv 9 44 $server $+ , $port
  .New server:server -n
  .$iif($server,Reconnect...,Other...):server
}
menu channel {
  $iif((($mid($hget(pnp.config,popups.3),1,1) != 0) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #) || ($me ishop #) || (t !isincs $gettok($chan(#).mode,1,32)))) || ($mouse.key & 2),Topic)
  .Edit $+ ...:etopic #
  .Add to topic...:atopic #
  .-
  .$iif($gettok($hget(pnp.config,stricts. $+ #),1,44) isnum 1-2,$style(1)) Lock topic:if ($gettok($hget(pnp.config,stricts. $+ #),1,44) isnum 1-2) utopic # | else ltopic #
  .Save topic:stopic #
  .$iif($hget(pnp.config,stricttopic. $+ #),Restore topic):otopic #
  .$iif($hget(pnp.config,stricttopic. $+ #),Forget topic):stopic # 0
  .-
  .Refresh:rtopic
  $iif((($mid($hget(pnp.config,popups.3),2,1) != 0) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #) || ($me ishop #))) || ($mouse.key & 2),Modes)
  .$iif($chan(#).mode === +tn,$style(1)) Set +tn only:mtn #
  .-
  .$iif(i isincs $gettok($chan(#).mode,1,32),$style(1)) Invite only	+i:_mtog # i
  .$iif(k isincs $gettok($chan(#).mode,1,32),$style(1)) Key required	+k:if ($chan(#).key == $null) mode # +k $_entry(-1,$null,Channel key to set?This 'password' will be required to join the channel.) | else mode # -k $chan(#).key
  .$iif(l isincs $gettok($chan(#).mode,1,32),$style(1)) Limit user count	+l:if ($chan(#).limit == $null) mode # +l $_entry(-2,$nick(#,0),Channel limit to set?This will limit the total number of users.) | else mode # -l
  .$iif(m isincs $gettok($chan(#).mode,1,32),$style(1)) Moderated	+m:_mtog # m
  .$iif(n isincs $gettok($chan(#).mode,1,32),$style(1)) No external msgs	+n:_mtog # n
  .$iif(p isincs $gettok($chan(#).mode,1,32),$style(1)) Private	+p:_mtog # p
  .$iif(s isincs $gettok($chan(#).mode,1,32),$style(1)) Secret	+s:_mtog # s
  .$iif(t isincs $gettok($chan(#).mode,1,32),$style(1)) Topics by ops only	+t:_mtog # t
  .-
  .Mass voice	+v:voc # *
  .Mass devoice	-v:dvoc # *
  $iif(($mid($hget(pnp.config,popups.3),3,1) != 0) || ($mouse.key & 2),Settings)
  .Protection...:protedit
  .General config...:config 24
  .Modes / topics...:strict
  .Event routing...:route
  .-
  .$iif(($_getcflag($chan,71)) || ($_getcflag($chan,72)) || ($_getcflag($chan,73)),$style(1)) Enable
  ..$iif($_getcflag($chan,72),$style(1)) CTCP protections:prot *ctcp
  ..$iif($_getcflag($chan,71),$style(1)) Text protections:prot *text
  ..$iif($_getcflag($chan,73),$style(1)) Other protections:prot *misc
  ..-
  ..Disable all:prot -all
  ..Enable all:prot +all
  .Options
  ..$iif($_getcflag($chan,69),$style(1)) Ops immune:prot *op
  ..$iif($_getcflag($chan,80),$style(1)) Halfops immune:prot *hop
  ..$iif($_getcflag($chan,70),$style(1)) Voiced immune:prot *voc
  ..-
  ..$iif($_getcflag($chan,23),$style(1)) Enforce bans:prot *enforce
  ..$iif($_getcflag($chan,45),$style(1)) Self-ban protection:prot *selfban
  .-
  .$iif($_getchopt($chan,11),$style(1)) Whois on join
  ..$iif($_getchopt($chan,11),$style(1)) Enabled:prot *whois
  ..$iif($_getchopt($chan,12),$style(1)) Only if opped:prot *whoisop
  ..$iif($_getchopt($chan,13),$style(1)) Off if away:prot *whoisaway
  ..$iif($_getchopt($chan,14),$style(1)) Show in channel:prot *whoischan
  .$iif($_getchopt($chan,9),$style(1)) IRCop check:prot *ircop
  -
  $iif(($mid($hget(pnp.config,popups.3),4,1) != 0) || ($mouse.key & 2),Banlist...):mode # b
  $iif((($mid($hget(pnp.config,popups.3),5,1) != 0) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #) || ($me ishop #))) || ($mouse.key & 2),Bans)
  .Set a ban...:ban # $_entry(-1,$null,Address or mask to ban? $+ $chr(40) $+ or you may enter a nickname $+ $chr(41))
  .Unban...:unban -s # $_entry(-1,$null,Nickname or address to unban? $+ $chr(40) $+ ALL matching bans will be unbanned $+ $chr(41))
  .-
  .Ban last user to part:banlast #
  .Unban last ban:unban #
  .Ban last unban:reban #
  $iif(($mid($hget(pnp.config,popups.3),7,1) != 0) || ($mouse.key & 2),Scan)
  .Basic info:chaninfo
  .Advanced...:scan
  .Clones:clones
  .-
  .$_rec(userscan,1):clones %=userscan.1
  .$_rec(userscan,2):clones %=userscan.2
  .$_rec(userscan,3):clones %=userscan.3
  .$_rec(userscan,4):clones %=userscan.4
  .$_rec(userscan,5):clones %=userscan.5
  .-
  .Mask...:clones $_entry(-1,$null,Usermask to scan for? $+ $chr(40) $+ For example $+ $chr(44) *.aol.com $+ $chr(41))
  .%=userscan.clr:_recclr userscan
  $iif(($mid($hget(pnp.config,popups.3),6,1) != 0) || ($mouse.key & 2),Ping):ping
  -
  $iif(($mid($hget(pnp.config,popups.3),8,1) != 0) || ($mouse.key & 2),Favorites)
  .$submenu($_favpop($1))
  .$iif(($server) && (!$istok(%.popfav,#,32)),Add $replace(#,&,&&) $+ ...):fav +
  .$iif($istok(%.popfav,#,32),Remove $replace(#,&,&&)):fav - #
  .-
  .Edit...:fav
}
menu menubar {
  $iif(($mid($hget(pnp.config,popups.1),1,1) != 0) || ($mouse.key & 2),Configure)
  .Options...:config
  .Configuration Wizard...:wizard
  .-
  .Theme central...:theme
  .Nicklist colors...:ncedit
  .Event sounds...:soundcfg
  .Load theme...:theme load
  .-
  .Font fixer...:fontfix
  .CTCP replies...:ctcpedit
  .Profiles...:profile
  .-
  .About PnP:about
  .Report a bug...:bug
  .Leave feedback...:feedback
  $iif(($mid($hget(pnp.config,popups.1),3,1) != 0) || ($mouse.key & 2),Lists)
  .Blacklist:blackedit
  .Userlist:useredit
  .Authlist:authedit
  -
  $iif((($hget(pnp.config,whois.win) == @Whois) && ($active != @Whois) && ($mid($hget(pnp.config,popups.1),2,1) != 0)) || ($mouse.key & 2),Whois tome):tome
  $iif((($hget(pnp.config,whois.win) != @Whois) && ($mid($hget(pnp.config,popups.1),2,1) != 0)) || ($mouse.key & 2),Last whois)
  .$_poprec(whois,1)
  ..User info
  ...Whois:whois $_grabrec(whois,1)
  ...Extended whois:ew $_grabrec(whois,1)
  ...User central...:uwho $_grabrec(whois,1)
  ...Address book...:abook $_grabrec(whois,1)
  ...-
  ...DNS:dns $gettok($_sufnrec(whois,1),2,32)
  ...Hostmask:host $gettok($_sufnrec(whois,1),4,32)
  ...-
  ...Ping server:sping $gettok($_sufnrec(whois,1),3,32)
  ..DCC
  ...Chat:dcc chat $_grabrec(whois,1)
  ...Chat to IP:dcc chat $gettok($_sufnrec(whois,1),2,32)
  ...-
  ...Send:dcc send $_grabrec(whois,1)
  ...Send to IP:dcc send $gettok($_sufnrec(whois,1),2,32)
  ...-
  ...$iif(($istok($level($gettok($_sufnrec(whois,1),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,1),4,32)),=auth,44) == $false),$style(1)) Authorize for DCCs:auth -t $gettok($_sufnrec(whois,1),4,32)
  ...$iif(($istok($level($gettok($_sufnrec(whois,1),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,1),4,32)),=auth,44)),$style(1)) Temp authorize:auth -t $gettok($_sufnrec(whois,1),4,32) 15
  ..Ping:ping $_grabrec(whois,1)
  ..Query:query $_grabrec(whois,1)
  ..-
  ..$iif($level($gettok($_sufnrec(whois,1),4,32)) > 1,$style(1)) Userlist...:user $gettok($_sufnrec(whois,1),4,32)
  ..$iif($_grabrec(whois,1) isnotify,$style(1)) Notify...:notif $gettok($_sufnrec(whois,1),4,32)
  ..-
  ..Copy:clipboard $_grabrec(whois,1) is $gettok($_sufnrec(whois,1),1,32) $+ @ $+ $gettok($_sufnrec(whois,1),2,32) $gettok($_sufnrec(whois,1),5-,32)
  .$_poprec(whois,2)        
  ..User info
  ...Whois:whois $_grabrec(whois,2)
  ...Extended whois:ew $_grabrec(whois,2)
  ...User central...:uwho $_grabrec(whois,2)
  ...Address book...:abook $_grabrec(whois,2)
  ...-
  ...DNS:dns $gettok($_sufnrec(whois,2),2,32)
  ...Hostmask:host $gettok($_sufnrec(whois,2),4,32)
  ...-
  ...Ping server:sping $gettok($_sufnrec(whois,2),3,32)
  ..DCC
  ...Chat:dcc chat $_grabrec(whois,2)
  ...Chat to IP:dcc chat $gettok($_sufnrec(whois,2),2,32)
  ...-
  ...Send:dcc send $_grabrec(whois,2)
  ...Send to IP:dcc send $gettok($_sufnrec(whois,2),2,32)
  ...-
  ...$iif(($istok($level($gettok($_sufnrec(whois,2),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,2),4,32)),=auth,44) == $false),$style(1)) Authorize for DCCs:auth -t $gettok($_sufnrec(whois,2),4,32)
  ...$iif(($istok($level($gettok($_sufnrec(whois,2),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,2),4,32)),=auth,44)),$style(1)) Temp authorize:auth -t $gettok($_sufnrec(whois,2),4,32) 15
  ..Ping:ping $_grabrec(whois,2)
  ..Query:query $_grabrec(whois,2)
  ..-
  ..$iif($level($gettok($_sufnrec(whois,2),4,32)) > 1,$style(1)) Userlist...:user $gettok($_sufnrec(whois,2),4,32)
  ..$iif($_grabrec(whois,2) isnotify,$style(1)) Notify...:notif $gettok($_sufnrec(whois,2),4,32)
  ..-
  ..Copy:clipboard $_grabrec(whois,2) is $gettok($_sufnrec(whois,2),1,32) $+ @ $+ $gettok($_sufnrec(whois,2),2,32) $gettok($_sufnrec(whois,2),5-,32)
  .$_poprec(whois,3)
  ..User info
  ...Whois:whois $_grabrec(whois,3)
  ...Extended whois:ew $_grabrec(whois,3)
  ...User central...:uwho $_grabrec(whois,3)
  ...Address book...:abook $_grabrec(whois,3)
  ...-
  ...DNS:dns $gettok($_sufnrec(whois,3),2,32)
  ...Hostmask:host $gettok($_sufnrec(whois,3),4,32)
  ...-
  ...Ping server:sping $gettok($_sufnrec(whois,3),3,32)
  ..DCC
  ...Chat:dcc chat $_grabrec(whois,3)
  ...Chat to IP:dcc chat $gettok($_sufnrec(whois,3),2,32)
  ...-
  ...Send:dcc send $_grabrec(whois,3)
  ...Send to IP:dcc send $gettok($_sufnrec(whois,3),2,32)
  ...-
  ...$iif(($istok($level($gettok($_sufnrec(whois,3),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,3),4,32)),=auth,44) == $false),$style(1)) Authorize for DCCs:auth -t $gettok($_sufnrec(whois,3),4,32)
  ...$iif(($istok($level($gettok($_sufnrec(whois,3),4,32)),=dcc,44)) && ($istok($level($gettok($_sufnrec(whois,3),4,32)),=auth,44)),$style(1)) Temp authorize:auth -t $gettok($_sufnrec(whois,3),4,32) 15
  ..Ping:ping $_grabrec(whois,3)
  ..Query:query $_grabrec(whois,3)
  ..-
  ..$iif($level($gettok($_sufnrec(whois,3),4,32)) > 1,$style(1)) Userlist...:user $gettok($_sufnrec(whois,3),4,32)
  ..$iif($_grabrec(whois,3) isnotify,$style(1)) Notify...:notif $gettok($_sufnrec(whois,3),4,32)
  ..-
  ..Copy:clipboard $_grabrec(whois,3) is $gettok($_sufnrec(whois,3),1,32) $+ @ $+ $gettok($_sufnrec(whois,3),2,32) $gettok($_sufnrec(whois,3),5-,32)
  .-
  .$_poprec(wch,1,$_grabrec(whois,0)):j $_grabrec(wch,1)
  .$_poprec(wch,2,$_grabrec(whois,0)):j $_grabrec(wch,2)
  .$_poprec(wch,3,$_grabrec(whois,0)):j $_grabrec(wch,3)
  .$_poprec(wch,4,$_grabrec(whois,0)):j $_grabrec(wch,4)
  .$_poprec(wch,5,$_grabrec(whois,0)):j $_grabrec(wch,5)
  .$_poprec(wch,6,$_grabrec(whois,0)):j $_grabrec(wch,6)
  .$_poprec(wch,7,$_grabrec(whois,0)):j $_grabrec(wch,7)
  .$_poprec(wch,8,$_grabrec(whois,0)):j $_grabrec(wch,8)
  .$_poprec(wch,9,$_grabrec(whois,0)):j $_grabrec(wch,9)
  .$_poprec(wch,10,$_grabrec(whois,0)):j $_grabrec(wch,10)
  .-
  .Whois tome:tome
  .Configure:config 13
  $iif(($mid($hget(pnp.config,popups.1),4,1) != 0) || ($mouse.key & 2),Away)
  .$iif(($hget(pnp. $+ $cid,away)) && (q !isin $gettok($hget(pnp. $+ $cid,away),3,32)),$style(1)) Away...:away
  .$iif(!$hget(pnp. $+ $cid,away),$style(1)) Back:back
  .-
  .$iif(q isin $gettok($hget(pnp. $+ $cid,away),3,32),$style(1)) Quiet away...:qa
  .Quiet back:qb
  .-
  .$iif($hget(pnp,pager),$style(1)) Pager
  ..$iif($hget(pnp,pager) == 1,$style(1)) On:pager on
  ..$iif($hget(pnp,pager) == quiet,$style(1)) Quiet:pager quiet
  ..$iif($hget(pnp,pager) == 0,$style(1)) Off:pager off
  ..-
  ..View...:pager v
  ..Flush:pager f
  .$iif($hget(pnp,logging),$style(1)) Logging
  ..$iif($iif($hget(pnp,away),$hget(pnp,logging),$_cfgi(away.log)),$style(1)) On $iif($hget(pnp,away) == $null,(when away)):awaylog on
  ..$iif(!$iif($hget(pnp,away),$hget(pnp,logging),$_cfgi(away.log)),$style(1)) Off $iif($hget(pnp,away) == $null,(when away)):awaylog off
  ..-
  ..View...:awaylog
  ..Flush:awaylog f
  .-
  .Configure...:awaycfg
  $iif(($mid($hget(pnp.config,popups.1),5,1) != 0) || ($mouse.key & 2),Nickname)
  .$_rec(nick,1):nick %=nick.1
  .$_rec(nick,2):nick %=nick.2
  .$_rec(nick,3):nick %=nick.3
  .$_rec(nick,4):nick %=nick.4
  .$_rec(nick,5):nick %=nick.5
  .$_rec(nick,6):nick %=nick.6
  .$_rec(nick,7):nick %=nick.7
  .$_rec(nick,8):nick %=nick.8
  .$_rec(nick,9):nick %=nick.9
  .-
  .%=nick.clr:_recclr nick | _recent nick 9 0 $me
  .Other...:nick $_entry(-1,$me,New nickname?)
  .-
  .$iif($hget(pnp. $+ $cid,oldrnick),Random nick):rn
  .$iif($hget(pnp. $+ $cid,oldrnick),Undo random nick):urn
  -
  $iif(($mouse.key & 2) || ($mid($hget(pnp.config,popups.1),8,1) != 0),Favorites)
  .$submenu($_favservpop($1))
  .$submenu($_favpop($1))
  .$iif(($hget(pnp. $+ $cid,net) != Offline) && (!%.popfound),Add $server):fav + $hget(pnp. $+ $cid,net) $server $port
  .$iif(%.popfound,Remove $server):fav - $server
  .$iif(($active ischan) && ($server) && (!$istok(%.popfav,$active,32)),Add $replace(#,&,&&) $+ ...):fav +
  .$iif(($active ischan) && ($istok(%.popfav,$active,32)),Remove $replace(#,&,&&)):fav - #
  .-
  .$iif($active !ischan,Add...):fav +
  .$iif($active !ischan,Remove...):fav -
  .Edit...:fav
  $iif(($mouse.key & 2) || ($server && ($mid($hget(pnp.config,popups.1),7,1) != 0)),Channels)
  .$_rec(chan,1):join %=chan.1
  .$_rec(chan,2):join %=chan.2
  .$_rec(chan,3):join %=chan.3
  .$_rec(chan,4):join %=chan.4
  .$_rec(chan,5):join %=chan.5
  .-
  .$_rec(chan,6):join %=chan.6
  .$_rec(chan,7):join %=chan.7
  .$_rec(chan,8):join %=chan.8
  .$_rec(chan,9):join %=chan.9
  .$_rec(chan,10):join %=chan.10
  .-
  .$_rec(chan,11):join %=chan.11
  .$_rec(chan,12):join %=chan.12
  .$_rec(chan,13):join %=chan.13
  .$_rec(chan,14):join %=chan.14
  .$_rec(chan,15):join %=chan.15
  .-
  .%=chan.clr:_recclr chan
  .$iif(%=chan.1 || ($mouse.key & 2),$iif($_cfgi(fill.chan),Lock this list,Unlock list $chr(40) $+ currently locked $+ $chr(41))):{
    if ($_cfgi(fill.chan)) { disps Channels menu is now locked and will not 'fill' automatically. | _cfgw fill.chan 0 }
    else { disps Channels menu is unlocked and will fill with channels that you join. | _cfgw fill.chan 1 }
  }
  .Join other...:join $_s2c($_entry(0,$null,Channel $+ $chr(40) $+ s $+ $chr(41) to join? $+ $chr(40) $+ You may specify multiple channels. $+ $chr(41)))
  .-
  .Edit...:fav
  $iif(($mouse.key & 2) || ($server && ($mid($hget(pnp.config,popups.1),6,1) != 0)),List channels)
  .With 5 or more users:list >5
  .With 10 or more users:list >10
  .With 20 or more users:list >20
  .With X or more users...:{
    var %num = $_entry(-2,$iif($_dlgi(list) isnum,$_dlgi(list),10),List channels with at least how many users?)
    list > $+ %num
    _dlgw list %num
  }
  .-
  .All $chr(40) $+ smaller networks $+ $chr(41):list
}
menu nicklist {
  $_banpop:{ }
  $iif((($mid($hget(pnp.config,popups.4),1,1) != 0) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #) || ($me ishop #))) || ($mouse.key & 2),Quick kick):kick # $$snicks
  $iif((($mid($hget(pnp.config,popups.4),2,1) != 0) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #) || ($me ishop #))) || ($mouse.key & 2),Quick ban):cb # $$snicks
  -
  $iif((($mid($hget(pnp.config,popups.4),3,1) != 0) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #) || ($me ishop #))) || ($mouse.key & 2),Kick...):kick # $$snicks $_rentry(kick,0,$_s2p($_msg(kick)),Reason for kick?)
  $iif((($mid($hget(pnp.config,popups.4),4,1) != 0) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #) || ($me ishop #))) || ($mouse.key & 2),Bans)
  .%.ban2:kb # $$snicks 0 $+ $_getchopt(#,3) $+ 2 $_rentry(kick,0,$_s2p($_msg(kick)),Reason for kickban?)
  .%.ban3:kb # $$snicks 0 $+ $_getchopt(#,3) $+ 4 $_rentry(kick,0,$_s2p($_msg(kick)),Reason for kickban?)
  .%.ban4:kb # $$snicks 0 $+ $_getchopt(#,3) $+ 3 $_rentry(kick,0,$_s2p($_msg(kick)),Reason for kickban?)
  .%.ban5:kb # $$snicks 0 $+ $_getchopt(#,3) $+ 6 $_rentry(kick,0,$_s2p($_msg(kick)),Reason for kickban?)
  .-
  .%.banN:kb # $$snicks 100 $_rentry(kick,0,$_s2p($_msg(kick)),Reason for kickban?)
  .%.banS:kb # $$snicks 2 $_rentry(kick,0,$_s2p($_msg(kick)),Reason for kickban?)
  .%.banD:kb # $$snicks 4 $_rentry(kick,0,$_s2p($_msg(kick)),Reason for kickban?)
  .-
  .Tempban
  ..5	mins:if ($1 == $null) halt | %.time = 5m | _ssplay Question | var %why = $$dialog(tempban,tempban,-4) | tempban %.time # $snicks %why
  ..15	mins:if ($1 == $null) halt | %.time = 15m | _ssplay Question | var %why = $$dialog(tempban,tempban,-4) | tempban %.time # $snicks %why
  ..60	mins:if ($1 == $null) halt | %.time = 60m | _ssplay Question | var %why = $$dialog(tempban,tempban,-4) | tempban %.time # $snicks %why
  ..-
  ..20	secs:if ($1 == $null) halt | %.time = 20 | _ssplay Question | var %why = $$dialog(tempban,tempban,-4) | tempban %.time # $snicks %why
  ..60	secs:if ($1 == $null) halt | %.time = 60 | _ssplay Question | var %why = $$dialog(tempban,tempban,-4) | tempban %.time # $snicks %why
  .-
  .Cloneban...:cb # $$snicks $_rentry(kick,0,$_s2p($_msg(kick)),Reason for cloneban?)
  .Blacklist...:_nurple # black **
  -
  $iif((($mid($hget(pnp.config,popups.4),5,1) != 0) && ($snick(#,$snick(#,0)) !isop #) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #))) || ($mouse.key & 2),Op):op # $$snicks
  $iif((($mid($hget(pnp.config,popups.4),5,1) != 0) && ($snick(#,1) isop #) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #))) || ($mouse.key & 2),Deop):deop # $$snicks
  $iif((($mid($hget(pnp.config,popups.4),5,1) != 0) && (($snick(#,$snick(#,0)) isreg #) || ($snick(#,$snick(#,0)) isvoice #)) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #)) && (% isin $prefix)) || ($mouse.key & 2),Halfop):hfop # $$snicks
  $iif((($mid($hget(pnp.config,popups.4),5,1) != 0) && (($snick(#,1) ishop #) || ($snick(#,$snick(#,0)) ishop #)) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #)) && (% isin $prefix)) || ($mouse.key & 2),Dehalfop):dehfop # $$snicks
  $iif((($mid($hget(pnp.config,popups.4),5,1) != 0) && ($snick(#,$snick(#,0)) isreg #) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #) || ($me ishop #))) || ($mouse.key & 2),Voice):voc # $$snicks
  $iif((($mid($hget(pnp.config,popups.4),5,1) != 0) && (($snick(#,1) isvoice #) || ($snick(#,$snick(#,0)) isvoice #)) && (($hget(pnp.config,popups.hideop) != 1) || ($me isop #) || ($me ishop #))) || ($mouse.key & 2),Devoice):devoc # $$snicks
  -
  $iif(($mid($hget(pnp.config,popups.4),6,1) != 0) || ($mouse.key & 2),User info)
  .Whois:whois $$snicks
  .Extended whois:ew $$snicks
  .User central:uwho $$1
  .Address book:abook $$1
  .-
  .DNS:_nurple # dns **
  .Hostmask:_nurple # host **
  .-
  .Ping server:_nurple # sping **
  $iif(($mid($hget(pnp.config,popups.4),7,1) != 0) || ($mouse.key & 2),CTCP)
  .Ping:ping $$snicks
  .-
  .PAGE...:ctcp $$snicks PAGE $_entry(1,$null,Reason for paging $1 $+ ? $+ $chr(40) $+ optional $+ $chr(41))
  .TIME:ctcp $$snicks TIME
  .USERINFO:ctcp $$snicks USERINFO
  .VERSION:ctcp $$snicks VERSION
  .-
  .XDCC LIST:ctcp $$snicks XDCC LIST
  .XDCC SEND...:ctcp $$snicks XDCC SEND $_entry(-2,1,XDCC packet to request?)
  .-
  .$_rec(ctcp,1):ctcp $$snicks %=ctcp.1
  .$_rec(ctcp,2):ctcp $$snicks %=ctcp.2
  .$_rec(ctcp,3):ctcp $$snicks %=ctcp.3
  .$_rec(ctcp,4):ctcp $$snicks %=ctcp.4
  .$_rec(ctcp,5):ctcp $$snicks %=ctcp.5
  .-
  .%=ctcp.clr:_recclr ctcp
  .Other...:ctcp $$snicks $_entry(0,$null,CTCP to send to $1 $+ ?)
  $iif(($mid($hget(pnp.config,popups.4),8,1) != 0) || ($mouse.key & 2),DCC)
  .Chat:dcc chat $$1
  .Chat to IP:dcc chat . $+ $$1
  .-
  .Send:dcc send $$1
  .Send to IP:dcc send . $+ $$1
  .-
  .Authorize for DCCs:_nurple # auth **
  .Temp authorize:_nurple # auth ** 15
  .Remove authorize:_nurple # auth -r **
  $iif(($mid($hget(pnp.config,popups.4),9,1) != 0) || ($mouse.key & 2),Query):query $$snicks
  -
  $iif(($mid($hget(pnp.config,popups.4),10,1) != 0) || ($mouse.key & 2),Lists)
  .Userlist...:user $$snicks
  .Notify...:notif $_c2s($$snicks)
  .-
  .Ignore user...:_nurple # ign **
  .Remove from ignore...:_nurple # ign -r **
  .-
  .Blacklist...:_nurple # black **
  $iif(($mid($hget(pnp.config,popups.4),11,1) != 0) || ($mouse.key & 2),Notices)
  .Ops...:onotice # $_entry(0,$null,Notice to send to all ops?)
  .$iif(($mouse.key & 2) || (% isin $prefix),Ops + Halfops...):ohnotice # $_entry(0,$null,Notice to send to all ops / halfops?)
  .Ops + Voices...:ovnotice # $_entry(0,$null,Notice to send to all ops / voiced?)
  .Non-ops...:peon # $_entry(0,$null,Notice to send to all regulars? $chr(40) $+ and voiced $+ $chr(41))
  .-
  .Selected...:ntc $$snicks $_entry(0,$null,$iif($numtok($snicks,44) == 1,Notice to send to $snicks $+ ?,Notice to send to $numtok($snicks,44) selected users?))
  .All but selected...:allbut # $$snicks $_entry(0,$null,$iif($numtok($snicks,44) == 1,Notice to send to everyone but $snicks $+ ?,Notice to send to everyone but $numtok($snicks,44) selected users?))
}
menu query {
  $_addrpop:{ }
  $iif($active == Notify List,Query):query $1
  $iif(($mid($hget(pnp.config,popups.2),1,1) != 0) || ($mouse.key & 2),Whois):whois $1
  $iif(($mid($hget(pnp.config,popups.2),2,1) != 0) || ($mouse.key & 2),User info)
  .Whois:whois $1
  .Extended whois:ew $1
  .User central:uwho $1
  .Address book:abook $1
  .-
  .DNS:dns $1
  .Hostmask:host $1
  .-
  .Ping server:sping $1
  $iif(($mid($hget(pnp.config,popups.2),3,1) != 0) || ($mouse.key & 2),Ping):ping
  $iif((($mid($hget(pnp.config,popups.2),4,1) != 0) && (=* !iswm $active)) || ($mouse.key & 2),CTCP)
  .Ping:ping $1
  .-
  .PAGE...:ctcp $1 PAGE $_entry(1,$null,Reason for paging $1 $+ ? $+ $chr(40) $+ optional $+ $chr(41))
  .TIME:ctcp $1 TIME
  .USERINFO:ctcp $1 USERINFO
  .VERSION:ctcp $1 VERSION
  .-
  .XDCC LIST:ctcp $$snicks XDCC LIST
  .XDCC SEND...:ctcp $$snicks XDCC SEND $_entry(-2,1,XDCC packet to request?)
  .-
  .$_rec(ctcp,1):ctcp $1 %=ctcp.1
  .$_rec(ctcp,2):ctcp $1 %=ctcp.2
  .$_rec(ctcp,3):ctcp $1 %=ctcp.3
  .$_rec(ctcp,4):ctcp $1 %=ctcp.4
  .$_rec(ctcp,5):ctcp $1 %=ctcp.5
  .-
  .%=ctcp.clr:_recclr ctcp
  .Other...:ctcp $1 $_entry(0,$null,CTCP to send to $1 $+ ?)
  $iif(($mid($hget(pnp.config,popups.2),5,1) != 0) || ($mouse.key & 2),DCC)
  .Chat:dcc chat $1
  .Chat to IP:if ((=* iswm $active) && ($chat($1).ip)) dcc chat $chat($1).ip | elseif ($query($1).address) dcc chat . $+ $query($1).address | else dcc chat . $+ $1
  .-
  .Send:dcc send $1
  .Send to IP:if ((=* iswm $active) && ($chat($1).ip)) dcc send $chat($1).ip | elseif ($query($1).address) dcc send . $+ $query($1).address | else dcc send . $+ $1
  .-
  .$iif(($istok($level(%.targaddr),=dcc,44)) && ($istok($level(%.targaddr),=auth,44) == $false),$style(1)) Authorize for DCCs:auth -t $1
  .$iif(($istok($level(%.targaddr),=dcc,44)) && ($istok($level(%.targaddr),=auth,44)),$style(1)) Temp authorize:auth -t $1 15
  -
  $iif(($mid($hget(pnp.config,popups.2),6,1) != 0) || ($mouse.key & 2),$iif(%.targaddr isignore,$style(1)) Ignore)
  .Ignore...:ign $1
  .-
  .$iif(%.targaddr isignore,Remove from ignore):ign -r $1
  .-
  .Quick ignore:ign -pdtink $1
  .Quick ignore $chr(40) $+ all $+ $chr(41):ign -pdtinck $1
  .$iif(s isin $hget(pnp. $+ $cid,-feat),Quick SILENCE):ign -pdtincks $1
  $iif(($mid($hget(pnp.config,popups.2),7,1) != 0) || ($mouse.key & 2),$iif($level(%.targaddr) > 1,$style(1)) Userlist...):user $1
  $iif(($mid($hget(pnp.config,popups.2),8,1) != 0) || ($mouse.key & 2),$iif($remove($active,=) isnotify,$style(1)) Notify...):notif $1
}
