; #= P&P.temp -rs
; @======================================:
; |  Peace and Protection                |
; |  First-time configuration            |
; `======================================'

; First-time config dialog
dialog pnp.firsttime {
  title "PnP Options"
  icon script\pnp.ico
  option dbu
  size -1 -1 200 150

  button "Next >>", 905, 155 131 40 12, default group
  button "Cancel", 906, 5 131 40 12, cancel
  button "<< Back", 907, 110 131 40 12, disable

  ; Whether a section has been loaded yet
  list 902, 1 1 1 1, hide

  ; Last section selected
  edit "", 903, 1 1 1 1, autohs hide

  ; Intro tab
  tab "", 1, -25 -25 1 1, disable hide

  ; Hidden tabs to select areas
  tab "", 2, -25 -25 1 1, disable hide
  tab "", 3, -25 -25 1 1, disable hide
  tab "", 4, -25 -25 1 1, disable hide
  tab "", 5, -25 -25 1 1, disable hide
  tab "", 6, -25 -25 1 1, disable hide
  tab "", 7, -25 -25 1 1, disable hide
  tab "", 8, -25 -25 1 1, disable hide

  ; Applying tab
  tab "", 9, -25 -25 1 1, disable hide

  ; Intro
  text "Welcome to Peace and Protection!", 50, 5 10 190 8, hide tab 1
  text "The following pages will guide you through setting up some of the more common PnP options. If you do not wish to setup these options at this time, you may click 'Cancel'. You may rerun this setup at anytime by going to the 'PnP' menu, selecting 'Configure', and selecting 'Configuration Wizard'.", 51, 5 30 190 40, hide tab 1
  text "Press the Next button to continue.", 52, 5 115 190 8, hide tab 1

  ; Language
  text "PnP has detected multiple languages available. Please select which language you would like to use. Please note that selecting a new language will take some time to apply, so please be patient.", 514, 5 10 190 30, tab 2
  list 525, 5 45 190 70, sort tab 2
  text "", 527, 1 1 1 1, autohs hide
  text "", 528, 1 1 1 1, autohs hide
  text "Press the Next button to continue.", 526, 5 115 190 8, tab 2
  text "Please wait while the selected language is loaded...", 529, 5 65 190 8, center hide tab 2

  ; Protection
  text "PnP contains powerful protection options, but some users may find that they interfere needlessly. In addition, PnP's default channel protection options are not appropriate for some channels, such as channels with heavy amounts of text pasting, sound playing, or colors.", 563, 5 10 190 30, tab 3
  check "&Enable default personal protections", 564, 5 45 190 8, tab 3
  check "&Enable default personal protections", 664, 5 45 190 8, 3state hide tab 3
  edit "", 764, 1 1 1 1, hide autohs
  check "&Enable default channel protections", 566, 5 55 190 8, tab 3
  check "&Enable default channel protections", 666, 5 55 190 8, 3state hide tab 3
  edit "", 766, 1 1 1 1, hide autohs
  text "The self-lag check may cause problems for some networks or users- if so, you may wish to disable it.", 581, 5 75 190 15, tab 3
  check "&Enable PnP's self-lag checks", 582, 5 95 190 8, tab 3
  text "Press the Next button to continue.", 583, 5 115 190 8, tab 3

  ; Misc
  text "The following options may be configured to your liking.", 129, 5 10 190 8, tab 4
  check "&Automatically set away after 30 minutes idle", 131, 5 35 190 8, tab 4
  radio "&Use default popups (recommended for novice users)", 326, 5 50 190 8, group tab 4
  radio "&Use condensed popups", 327, 5 60 190 8, tab 4
  check "&Use channel nick-completion (when you type 'nick:' 'nick-' or 'nick,')", 650, 5 75 190 8, tab 4
  check "&Use nick-completion in commands (/kick, /op, etc.)", 655, 5 85 190 8, tab 4
  text "Press the Next button to continue.", 656, 5 115 190 8, tab 4

  ; Display
  text "The following options control where PnP shows various events.", 189, 5 10 190 8, tab 5
  text "&Show channel pings to:", 190, 5 25 72 8, right tab 5
  combo 191, 80 23 115 50, drop tab 5
  text "&Show whois replies to:", 270, 5 40 72 8, right tab 5
  combo 271, 80 38 115 50, drop tab 5
  text "&Show notifies to:", 175, 5 55 72 8, right tab 5
  combo 176, 80 53 115 50, drop tab 5
  text "&Names list when joining:", 290, 5 70 72 8, right tab 5
  combo 291, 80 68 115 50, drop tab 5
  check "&Show CTCPs, DNS, and away status to active window", 298, 5 90 190 8, tab 5
  check "&Show events/raws to active if channel/query not open", 299, 5 100 190 8, tab 5
  text "Press the Next button to continue.", 300, 5 115 190 8, tab 5

  ; Theming
  text "PnP has enhanced theming features for displaying channel text and other events. You may wish to disable these features to speed up display on slower computers. The red coloring in the theme samples represents nickname coloring and can be disabled or changed.", 149, 5 10 190 35, tab 6
  check "&Use PnP text theming:", 230, 5 45 105 8, tab 6
  radio "", 231, 15 56 10 8, group tab 6
  radio "", 232, 15 65 10 8, tab 6
  radio "", 233, 15 74 10 8, tab 6
  radio "", 234, 15 83 10 8, tab 6
  radio "", 235, 15 92 10 8, tab 6
  icon 236, 25 55 67 9, script\theme1.png, noborder tab 6
  icon 237, 25 64 67 9, script\theme2.png, noborder tab 6
  icon 238, 25 73 67 9, script\theme3.png, noborder tab 6
  icon 239, 25 82 67 9, script\theme4.png, noborder tab 6
  icon 240, 25 91 67 9, script\theme5.png, noborder tab 6
  edit "", 244, 1 1 1 1, autohs hide
  check "&Color nicknames in channel text", 151, 5 102 190 8, tab 6
  check "&Color nicknames in nicklist", 150, 5 112 190 8, tab 6
  check "&Apply this font:", 241, 110 45 85 8, tab 6
  edit "", 242, 119 55 76 11, autohs read tab 6
  button "&Select...", 243, 119 70 40 12, tab 6
  ; (already got a fixed-width?)
  edit "", 245, 1 1 1 1, autohs hide
  ; (prev settings if selected theme 5)
  edit "", 246, 1 1 1 1, autohs hide
  ; (mirc-sized version of 242)
  edit "", 247, 1 1 1 1, autohs hide
  ; (did we load a theme?)
  edit "", 248, 1 1 1 1, autohs hide

  ; Addons
  text "PnP includes a number of optional addons. You may select which addons to load below. Some of the less-commonly used addons are not listed- you can access all addons from the PnP menu.", 400, 5 10 190 30, tab 7
  check "&ChanServ", 401, 5 45 105 8, tab 7
  check "&NickServ", 402, 5 55 105 8, tab 7
  check "&X Z P Bots", 403, 5 65 105 8, tab 7
  check "&Extras", 404, 5 75 105 8, tab 7
  check "&Spam Blocker", 405, 5 85 105 8, tab 7
  check "&Sound", 406, 5 95 105 8, tab 7

  ; Done!
  text "That's it!", 420, 5 10 190 8, tab 8
  text "Enjoy using Peace and Protection! You can access more configuration options from the 'PnP' menu, under 'Configure'. You may install and configure addons from the 'PnP' menu, under 'Addons'. You may even rerun this setup process at anytime by selecting 'Configuration Wizard' from that menu.", 421, 5 30 190 40, tab 8
  text "Click 'Done' to complete setup.", 422, 5 115 190 8, tab 8

  text "", 423, 5 65 190 8, center tab 9
}

; /_firsttime
; Open firsttime config dialog
alias _firsttime {
  set -u %.section $1
  _dialog -am pnp.firsttime pnp.firsttime
}

; Dialog init
on *:DIALOG:pnp.firsttime:init:*:{
  ; (mark all sections as un-viewed)
  var %num = 8
  while (%num > 0) {
    did -a $dname 902 0
    dec %num
  }

  ; Translation init
  if ($readini(script\transup.ini,n,translation,enabled) == no) did -a $dname 527 0
  else {
    window -nhl @.trans
    var %num = $findfile(script\trans\,*.ini,@.trans)
    var %total = 0
    while (%num) {
      var %lang = $readini($line(@.trans,%num),n,info,language)
      if (%lang) inc %total
      dec %num
    }
    window -c @.trans
    did -a $dname 527 %total
  }

  ;  show first section of dialog?
  if (%.section isnum 2-8) {
    page.show %.section
    ;!! Need a timer for this at this time
    .timer -mio 1 0 did -c pnp.firsttime %.section $chr(124) did -f pnp.firsttime 905
  }
  else {
    page.show 1
  }
}

; Select next section
on *:DIALOG:pnp.firsttime:sclick:905:{
  var %old = $did(903) + 1
  if (($did(527) < 2) && (%old == 2)) %old = 3

  ; Apply translation?
  if (($did(527) > 1) && (%old == 3) && ($did(528) != $did(525).seltext)) {
    ; Translate! First find file.
    window -nhl @.trans
    var %num = $findfile(script\trans\,*.ini,@.trans)
    var %file
    while (%num) {
      var %lang = $readini($line(@.trans,%num),n,info,language)
      if (%lang == $did(525).seltext) {
        %file = $line(@.trans,%num)
        break
      }
      dec %num
    }
    window -c @.trans
    ; File found?
    if (%file) {
      did -h $dname 514,525,526
      did -b $dname 905,906,907
      did -v $dname 529

      .timer -mio 1 0 translate -f %file
      halt
    }
  }

  if (%old <= 8) page.show %old
  else {
    ; Done- apply
    did -c $dname 9
    did -b $dname 905,906,907
    did -ra $dname 423 Please wait while we apply your new settings...
    ; (in case something breaks or is canceled)
    .timer.dlgcancel -mio 1 0 did -c $dname 8 $chr(124) did -e $dname 905,906,907

    ; (page 7 with addons happens first, which is the only page with a possible cancel situation)
    var %num = 8
    while (%num) {
      if ($did(902,%num)) page.apply %num
      dec %num
    }
    .timer.dlgcancel off
    dialog -x pnp.firsttime
    _unload firstime
  }
}

on *:SIGNAL:PNP.TRANSLATE:{
  if ($dialog(pnp.firsttime)) {
    dialog -x pnp.firsttime
    .timer -mio 1 0 _firsttime 3
  }
}

; Select previous section
on *:DIALOG:pnp.firsttime:sclick:907:{
  var %old = $did(903) - 1
  if (($did(527) < 2) && (%old == 2)) %old = 1
  if (%old >= 1) page.show %old
}

; Cancel
on *:DIALOG:pnp.firsttime:sclick:906:{
  dialog -x pnp.firsttime
  _unload firstime
}

; If tabs are 'clicked', undo any changes
on *:DIALOG:pnp.firsttime:sclick:1,2,3,4,5,6,7,8,9:{
  did -f pnp.firsttime 905
  did -c pnp.firsttime $did(903)
}

; /page.show n
; Show a page of the dialog
alias -l page.show {
  ; (do nothing if same page as before)
  if ($did(903) == $1) return

  ; If area hasn't been visited yet, we must prep it
  if ($did(902,$1) == 0) {
    ; Mark as visited and initialize
    did -o pnp.firsttime 902 $1 1
    page.init $1
  }

  ; Next/prev
  did $iif($1 == 1,-b,-e) pnp.firsttime 907
  did -ra pnp.firsttime 905 $iif($1 == 8,Done!,Next >>)

  ; Remember what page we did last, show tab, move focus to OK, set default to OK
  did -o pnp.firsttime 903 1 $1
  did -c pnp.firsttime $1
  did -f pnp.firsttime 905
  did -t pnp.firsttime 905
}

; /page.init n
; Prepare a page of the dialog from our configuration and/or prep any combos, lists, etc.
; Will not be called more than once for a page, so you can assume everything is blank/unchecked at this point
alias -l page.init {
  goto $1

  ; Intro
  :1
  did -v $dname 50,51,52
  return

  ; Select language
  :2
  ; Old language    
  if ($readini(script\transup.ini,n,translation,language)) did -ra $dname 528 $ifmatch
  else did -ra $dname 528 English

  ; List  
  window -nhl @.trans
  var %num = $findfile(script\trans\,*.ini,@.trans)
  while (%num) {
    var %lang = $readini($line(@.trans,%num),n,info,language)
    if (%lang) did -a $+ $iif(%lang == $did(528),c) $dname 525 %lang
    dec %num
  }
  window -c @.trans
  return

  ; Protection configuration
  :3
  ; (uses 3-state version if current settings are NOT the default, so that you have 'on', 'off', and 'current')
  var %prot = $and($hget(pnp.config,myflood.prot),3) $gettok($hget(pnp.config,xchat.cfg),1,32) $gettok($_cfgi(xquery.cfg),1,32) $gettok($hget(pnp.config,xnotice.cfg),1,32)
  if (%prot == 3 1 1 1) did -c $dname 564
  elseif (%prot != 0 0 0 0) {
    did -a $dname 764 1
    did -ucv $dname 664
    did -h $dname 564
  }

  %prot = $hget(pnp.config,cflags)
  var %def = 4 0 +im 0 0 2000 8 10 10 4 20 5 15 90 30 0 250 10 0 1 1 0 0 0 0 0 0 1 4 15 6 8 1 3 1 2 2 2 0 1 1 2 1 1 1 0 0 0 0 0 0 0 0 1 1 1 5 15 0 20 8 10 5 0 15 4 7 60 1 0 1 1 1 1 5 300 0 0 0 0 1
  var %off = 0 0 +im 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 1 0 0 0 0 1 3 1 2 2 2 0 1 1 2 1 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 20 8 10 5 0 15 4 7 60 1 0 1 1 1 0 ? ? 0 0 0 0 1
  if (%prot == %def) did -c $dname 566
  elseif (%prot != %off) {
    did -a $dname 766 1
    did -ucv $dname 666
    did -h $dname 566
  }

  if (($_cfgi(sptime) isnum) && ($_cfgi(sptime) > 0)) did -c $dname 582
  return

  ; Misc configuration
  :4
  if ($hget(pnp.config,autoaway)) did -c $dname 131
  if (($hget(pnp.config,autoaway.time) isnum) && ($hget(pnp.config,autoaway.time) != 0)) did -ra $dname 131 & $+ Automatically set away after $calc($ifmatch / 60) minutes idle

  var %pops = a $left($hget(pnp.config,popups.1),10) $left($hget(pnp.config,popups.2),11) $left($hget(pnp.config,popups.3),11) $left($hget(pnp.config,popups.4),12) $left($hget(pnp.config,popups.5),11) $left($hget(pnp.config,popups.6),6)
  if (%pops == a 1111001111 01011111101 11111111011 001111111111 11111111111 111001) did -c $dname 326
  elseif (%pops == a 1010001110 10101111010 01101010100 110011000110 01111010100 110100) did -c $dname 327

  if ($hget(pnp.config,nc.char)) did -c $dname 650
  if ($hget(pnp.config,nc.cmd)) did -c $dname 655
  return

  ; Display configuration
  :5
  loadbuf -otpingwin1 $dname 191 "script\dlgtext.dat"
  did -c $dname 191 $calc(1 + $findtok(-si2 @Ping * none,$hget(pnp.config,ping.bulk),32))
  loadbuf -otwhoiswin $dname 271 "script\dlgtext.dat"
  did -c $dname 271 $calc(1 + $findtok(-si2 @Whois *,$hget(pnp.config,whois.win),32))
  loadbuf -otnotifywin $dname 176 "script\dlgtext.dat"
  did -c $dname 176 $calc(1 + $findtok(-si2 none off,$hget(pnp.config,notify.win),32))
  loadbuf -otnames $dname 291 "script\dlgtext.dat"
  did -c $dname 291 $calc(1 + $_cfgi(show.names))
  if ($_cfgi(eroute) == -ai2) did -c $dname 298
  if ($hget(pnp.config,rawroute) == -ai2) did -c $dname 299
  return

  ; Theme settings
  :6
  if ($hget(pnp.config,themecol)) did -c $dname 151
  if ($_cfgi(nickcol)) did -c $dname 150
  did -ra $dname 247 $window(status window).font $window(status window).fontsize
  did -ra $dname 242 $_font_m2w($did(247))
  if (($window(status window).font == FixedSys) || ($window(status window).font == IBM PC) || ($window(status window).font == Terminal) || ($gettok($window(status window).font,1,32) == Courier)) did -ra $dname 245 1
  var %theme = $hget(pnp.theme,name),%num = 0

  if ($_cfgi(texts)) did -c $dname 230
  else did -b $dname 231,232,233,234,235,236,237,238,239,240,151

  var %missing
  if (!$isfile(themes\mirc.mts)) { did -h $dname 231,236 | %missing = %missing 1 }
  if (!$isfile(themes\pnp.mts)) { did -h $dname 232,237 | %missing = %missing 2 }
  if (!$isfile(themes\pnp2.mts)) { did -h $dname 233,238 | %missing = %missing 3 }
  if (!$isfile(themes\test.mts)) { did -h $dname 234,239 | %missing = %missing 4 }
  if (!$isfile(themes\eleet3.mts)) { did -h $dname 235,240 | %missing = %missing 5 }

  if (%theme == mIRC default) %num = 1
  elseif (%theme == PnP default) %num = 2
  elseif (%theme == PnP w/fully colored nicks) %num = 3
  elseif ($gettok(%theme,1-3,32) == PnP "test" theme) %num = 4
  elseif ($gettok(%theme,1,32) == 'Elite') %num = 5
  if ((%num > 0) && (!$istok(%missing,%num,32))) did -c $dname $calc(230 + %num)
  did -ra $dname 244 %num
  return

  ; Addons
  :7
  var %ids = $hget(pnp,addon.ids)
  if ($istok(%ids,ppcsbot,32)) did -c $dname 401
  if ($istok(%ids,ppnserv,32)) did -c $dname 402
  if ($istok(%ids,ppxwzbot,32)) did -c $dname 403
  if ($istok(%ids,ppextra,32)) did -c $dname 404
  if ($istok(%ids,ppspambl,32)) did -c $dname 405
  if ($istok(%ids,ppsound,32)) did -c $dname 406
  return

  ; Finished!
  :8
  return
}

on *:DIALOG:pnp.firsttime:sclick:230:{
  did $iif($did(230).state,-e,-b) $dname 231,232,233,234,235,236,237,238,239,240,151
}

on *:DIALOG:pnp.firsttime:sclick:231,232,233,234,235,236,237,238,239,240:{
  if ($did isnum 236-240) {
    did -u $dname $_s2c($remtok(231 232 233 234 235,$calc($did - 5),32))
    did -c $dname $calc($did - 5)
  }
  ; Force to fixedsys if selecting 240 and not already have a fixed-width loaded (save old option)
  if (($did == 240) || ($did == 235)) {
    if (!$did(245)) {
      did -ra $dname 246 $did(241).state $did(247)
      did -c $dname 241
      did -ra $dname 247 FixedSys 12
      did -ra $dname 242 FixedSys 9
    }
  }
  elseif ($did(246)) {
    did $iif($gettok($did(246),1,32),-c,-u) $dname 241
    did -ra $dname 247 $gettok($did(246),2-,32)
    did -ra $dname 242 $_font_m2w($did(247))
    did -r $dname 246
  }
}
on *:DIALOG:pnp.firsttime:sclick:241:{ did -r $dname 246 }
on *:DIALOG:pnp.firsttime:sclick:243:{ .timer -mio 1 0 pft.font }
alias -l pft.font {
  if ($_pickfont) {
    did -c pnp.firsttime 241
    did -ra pnp.firsttime 247 $ifmatch  
    did -ra pnp.firsttime 242 $_font_m2w($did(pnp.firsttime,247))
    did -r pnp.firsttime 246
  }
}

; /page.apply n
; Save a page of the dialog to configuration
alias -l page.apply {
  goto $1

  ; Intro
  :1
  return

  ; Select language
  :2
  return

  ; Protection configuration
  :3
  var %prot
  if ($did(764)) %prot = $did(664).state
  else %prot = $did(564).state
  if (%prot == 0) {
    `set myflood.prot $and($hget(pnp.config,myflood.prot),252)
    var %old = $hget(pnp.config,xchat.cfg)
    `set xchat.cfg 0 $iif($gettok(%old,2,32) isnum,$ifmatch,50) $iif($gettok(%old,3,32) isnum,$ifmatch,5)
    %old = $_cfgi(pnp.config,xquery.cfg)
    _cfgw xquery.cfg 0 $iif($gettok(%old,2,32) isnum,$ifmatch,5) $iif($gettok(%old,3,32) isnum,$ifmatch,5)
    %old = $hget(pnp.config,xnotice.cfg)
    `set xnotice.cfg 0 $iif($gettok(%old,2,32) isnum,$ifmatch,30) $iif($gettok(%old,3,32) isnum,$ifmatch,5)
  }
  elseif (%prot == 1) {
    `set myflood.prot $or($hget(pnp.config,myflood.prot),3)
    var %old = $hget(pnp.config,xchat.cfg)
    `set xchat.cfg 1 $iif($gettok(%old,2,32) isnum,$ifmatch,50) $iif($gettok(%old,3,32) isnum,$ifmatch,5)
    %old = $_cfgi(pnp.config,xquery.cfg)
    _cfgw xquery.cfg 1 $iif($gettok(%old,2,32) isnum,$ifmatch,5) $iif($gettok(%old,3,32) isnum,$ifmatch,5)
    %old = $hget(pnp.config,xnotice.cfg)
    `set xnotice.cfg 1 $iif($gettok(%old,2,32) isnum,$ifmatch,30) $iif($gettok(%old,3,32) isnum,$ifmatch,5)
  }

  if ($did(766)) %prot = $did(666).state
  else %prot = $did(566).state
  if (%prot == 0) `set cflags 0 0 +im 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 1 0 0 0 0 1 3 1 2 2 2 0 1 1 2 1 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 20 8 10 5 0 15 4 7 60 1 0 1 1 1 0 ? ? 0 0 0 0 1
  elseif (%prot == 1) `set cflags 4 0 +im 0 0 2000 8 10 10 4 20 5 15 90 30 0 250 10 0 1 1 0 0 0 0 0 0 1 4 15 6 8 1 3 1 2 2 2 0 1 1 2 1 1 1 0 0 0 0 0 0 0 0 1 1 1 5 15 0 20 8 10 5 0 15 4 7 60 1 0 1 1 1 1 5 300 0 0 0 0 1

  if ($did(582).state) {
    if (($_cfgi(sptime) !isnum) || ($_cfgi(sptime) == 0)) _cfgw sptime 30
  }
  else _cfgw sptime 0
  return

  ; Misc configuration
  :4
  `set autoaway $did(131).state
  if (($hget(pnp.config,autoaway.time) !isnum) || ($hget(pnp.config,autoaway.time) == 0)) `set autoaway.time 30
  if ($did(326).state) {
    `set popups.1 1111001111
    `set popups.2 01011111101
    `set popups.3 11111111011
    `set popups.4 001111111111
    `set popups.5 11111111111
    `set popups.6 111001
  }
  elseif ($did(327).state) {
    `set popups.1 1010001110
    `set popups.2 10101111010
    `set popups.3 01101010100
    `set popups.4 110011000110
    `set popups.5 01111010100
    `set popups.6 110100
  }
  if (($did(650).state) && ($hget(pnp.config,nc.char) == $null)) `set nc.char -:,
  elseif (!$did(650).state) `set nc.char
  `set nc.cmd $did(655).state
  return

  ; Display configuration
  :5
  `set ping.bulk $gettok(-ai2 -si2 @Ping * none,$did(191).sel,32)
  `set whois.win $gettok(-ai2 -si2 @Whois *,$did(271).sel,32)
  `set notify.win $gettok(-ai2 -si2 none off,$did(176).sel,32)
  _cfgw show.names $calc($did(291).sel - 1)
  _cfgw eroute $iif($did(298).state,-ai2,-si2)
  `set rawroute $iif($did(299).state,-ai2,-si2)
  _upd.texts
  .nickcol
  ; (update disp alias if we didn't load a theme- eroute/rawroute may have changed above)
  if (!$did(248)) theme.alias pnp.theme pnp.events
  return

  ; Theme settings
  :6
  _cfgw texts $did(230).state
  `set themecol $did(151).state
  _cfgw nickcol $did(150).state
  if ($did(241).state) {
    ;(fontfix font in 247)
    var %font = $did(247)
    var %bold = 0
    if ($gettok(%font,-1,32) == bold) {
      %bold = 1
      %font = $deltok(%font,-1,32)
    }
    fontfix -cqfnops $+ $iif(%bold,b) $gettok(%font,-1,32) $deltok(%font,-1,32)
  }
  var %loaded = 0
  if (($did(231).state) && ($did(244) != 1)) {
    if ($isfile(themes\mirc.mts)) {
      theme load -ce themes\mirc.mts
      %loaded = 1
    }
  }
  if (($did(232).state) && ($did(244) != 2)) {
    if ($isfile(themes\pnp.mts)) {
      theme load -ce themes\pnp.mts
      %loaded = 1
    }
  }
  if (($did(233).state) && ($did(244) != 3)) {
    if ($isfile(themes\pnp2.mts)) {
      theme load -ce themes\pnp2.mts
      %loaded = 1
    }
  }
  if (($did(234).state) && ($did(244) != 4)) {
    if ($isfile(themes\test.mts)) {
      theme load -ce themes\test.mts
      %loaded = 1
    }
  }
  if (($did(235).state) && ($did(244) != 5)) {
    if ($isfile(themes\eleet3.mts)) {
      theme load -ce themes\eleet3.mts
      %loaded = 1
    }
  }
  did -ra $dname 248 %loaded
  return

  ; Addons
  :7
  var %ids = $hget(pnp,addon.ids)
  if ($did(401).state) {
    if (!$istok(%ids,ppcsbot,32)) .addon ik addons\chanserv.ppa
  }
  elseif ($istok(%ids,ppcsbot,32)) .addon u addons\chanserv.ppa
  if ($did(402).state) {
    if (!$istok(%ids,ppnserv,32)) .addon ik addons\nickserv.ppa
  }
  elseif ($istok(%ids,ppnserv,32)) .addon u addons\nickserv.ppa
  if ($did(403).state) {
    if (!$istok(%ids,ppxwzbot,32)) .addon ik addons\xw.ppa
  }
  elseif ($istok(%ids,ppxwzbot,32)) .addon u addons\xw.ppa
  if ($did(404).state) {
    if (!$istok(%ids,ppextra,32)) .addon ik addons\extras.ppa
  }
  elseif ($istok(%ids,ppextra,32)) .addon u addons\extras.ppa
  if ($did(405).state) {
    if (!$istok(%ids,ppspambl,32)) .addon ik addons\spamblck.ppa
  }
  elseif ($istok(%ids,ppspambl,32)) .addon u addons\spamblck.ppa
  if ($did(406).state) {
    if (!$istok(%ids,ppsound,32)) .addon ik addons\sound.ppa
  }
  elseif ($istok(%ids,ppsound,32)) .addon u addons\sound.ppa
  return

  ; Finished!
  :8
  return
}
