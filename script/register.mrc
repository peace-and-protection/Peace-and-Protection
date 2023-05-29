; #= P&P.temp -rs
; ########################################
; Peace and Protection
; Register, bug report, etc.
; ########################################

alias _registerunload {
  if ($dialog(bugrep)) return
  if ($dialog(bugresend)) return
  if ($dialog(pnpdonate)) return
  if ($dialog(aboutpnp)) return
  _unload register
}

dialog bugrep {
  title "Bug report and feedback"
  icon script\pnp.ico
  option map
  size -1 -1 334 235

  text "To report a bug or problem with PnP, use the 'Report a bug' section. To suggest features, or give other feedback, use the 'General feedback' section.", 1, 6 6 320 24
  radio "&Report a bug", 2, 6 30 66 14, push
  radio "&Send feedback", 3, 80 30 66 14, push
  box "", 4, 6 49 320 143

  text "Please write a detailed description of the bug, including when it occurs and how it can be reproduced. Include any information that you think may help in reproducing the bug.", 5, 13 61 307 24

  edit "", 6, 13 85 307 49, return vsbar multi

  text "Please provide your e-mail in case we need to contact you. Due to limited time, replies may not always be sent. We apologize that we cannot reply to everyone.", 7, 13 141 307 30

  text "&Your e-mail:", 8, 13 174 40 12, right
  edit "", 9, 54 171 133 13, autohs

  text "Press the Next button to continue.", 11, 13 199 200 12
  button "&Next >>", 12, 13 214 80 14, disable default

  text "To aid us in finding and fixing the bug, you may wish to send us additional information about your computer and script configuration.", 13, 13 61 307 18, hide

  check "&Send basic system info", 14, 13 84 133 9, hide
  check "&Send PnP and mIRC configuration", 15, 13 115 133 9, hide
  check "&Send recent debug log", 16, 13 152 133 9, hide

  text "This is mIRC version and other very basic information, with no security risk.", 17, 146 85 160 24, hide
  text "This includes most PnP and mIRC settings, as well as the userlist. This includes the mIRC 'perform' section.", 18, 146 116 160 33, hide
  text "This includes ALL data sent to and from mIRC since you last started mIRC. It will contain all chat and any passwords, so only send this if needed.", 19, 146 153 160 36, hide

  text "Press the Send button to send your bug report.", 20, 13 199 307 12, hide
  button "&Send!", 21, 13 214 80 14, hide disable OK

  button "<< &Back", 22, 126 214 80 14, hide

  text "Please enter your feedback and comments.", 23, 13 61 307 24, hide
  text "Press the Send button to send your feedback.", 24, 13 199 200 12, hide

  button "Cancel", 100, 240 214 80 14, cancel
}
alias _bug set -u %.option $1 | _dialog -md bugrep bugrep
on *:DIALOG:bugrep:init:*:{
  if ($debug == $null) did -b $dname 16,19
  if (%.option) {
    did -c $dname 3
    _clickbtn 3 $dname
  }
  else {
    did -c $dname 2,14
    did -f $dname 6
  }
  unset %.option
}
on *:DIALOG:bugrep:sclick:21:{
  window -c @.bug
  window -hln @.bug
  if ($did(2).state) {
    aline @.bug Subject: [AUTO] Bug report ( $+ $:ver $+ )
  }
  else {
    aline @.bug Subject: [AUTO] Feedback ( $+ $:ver $+ )
  }
  aline @.bug X-Mailer: Peace and Protection $:ver
  if ((@ isin $did(9)) && (. isin $did(9))) {
    aline @.bug From: $gettok($did(9),1,32)
    aline @.bug Reply-to: $gettok($did(9),1,32)
    titlebar @.bug login.kristshell.net $gettok($did(9),1,32)
  }
  else titlebar @.bug login.kristshell.net pnp@login.kristshell.net
  aline @.bug $lf
  var %ln = 1,%num = $did(6).lines
  :loop
  if ($left($did(6,%ln).text,1) == $null) aline @.bug $lf
  else aline @.bug $did(6,%ln).text
  if (%ln < %num) { inc %ln | goto loop }
  if ($did(2).state) {
    saveini
    flushini " $+ $mircini $+ "
    if ($did(14).state) {
      aline @.bug $lf
      aline @.bug mIRC: $version
      aline @.bug EXE: $mircexe
      aline @.bug INI: $mircini
      aline @.bug DIR: $mircdir
      aline @.bug OS: $os
      aline @.bug Timestamp: $ctime / $ticks
      aline @.bug Profile: $hget(pnp,user)
      aline @.bug DDE: $ddename $iif($readini($mircini,n,dde,ServerStatus) != on,(off))
      aline @.bug Language: $readini(script\transup.ini,n,translation,enabled) / $readini(script\transup.ini,n,translation,language)
      aline @.bug Theme: $hget(pnp.theme,Name)
      aline @.bug $lf
      var %scon = 1
      aline @.bug CIDs: $scon(0)
      while (%scon <= $scon(0)) {
        scid $scon(%scon)
        aline @.bug CID %scon $+ : $cid
        if ($ip == $null) aline @.bug IP: (unknown)
        else aline @.bug IP: $ip
        aline @.bug Nickname: $me
        if ($server == $null) aline @.bug Server: (not connected)
        else aline @.bug Server: $server $+ , $port ( $+ $hget(pnp. $+ $cid,net) $+ )
        inc %scon
      }
      scid -r
    }
    if ($did(15).state) {
      aline @.bug $lf
      aline @.bug *** $mircini
      loadbuf @.bug " $+ $mircini $+ "
      aline @.bug $lf
      aline @.bug *** $mircdirconfig\profiles.ini
      loadbuf @.bug " $+ $mircdirconfig\profiles.ini $+ "
      aline @.bug $lf
      aline @.bug *** $_cfg(config.ini)
      loadbuf @.bug " $+ $_cfg(config.ini) $+ "
      aline @.bug $lf
      aline @.bug *** $_cfg(users.mrc)
      loadbuf @.bug " $+ $_cfg(users.mrc) $+ "
      aline @.bug $lf
      ; (some pnp.* hashes)
      var %hash = $hget(0)
      while (%hash) {
        var %hname = $hget(%hash)
        if ((%hname == pnp) || (%hname == pnp.config) || (%hname == pnp.theme) || ((pnp.* iswm %hname) && ($gettok(%hname,2,46) isnum) && ($numtok(%hname,46) == 2))) {
          aline @.bug *** %hname
          if ($hget(%hname,0).item) {
            var %item = $hget(%hname,0).item
            while (%item) {
              aline @.bug $hget(%hname,%item).item $hget(%hname,%item).data
              dec %item
            }
          }
          else aline @.bug (empty)
          aline @.bug $lf
        }
        dec %hash
      }
    }
    if (($did(16).state) && ($debug)) {
      aline @.bug $lf
      aline @.bug *** Debug ( $+ $debug $+ )
      if (@* iswm $debug) {
        filter -wwr $iif($line($debug,0) > 500,$calc($line($debug,0) - 500),1) $+ - $+ $line($debug,0) $debug @.bug *
      }
      elseif ($isfile($debug)) {
        loadbuf 500 @.bug " $+ $debug $+ "
      }
      else {
        aline @.bug (file not found)
      }
    }
    aline @.bug $lf
    aline @.bug *** End of Data
  }
  _bugstart $did(2).state
}
alias _bugstart {
  _progress.1 $iif($1,Sending bug report,Sending feedback)
  _progress.2 0 Connecting to $gettok($window(@.bug).title,1,32) $+ ...
  sockclose bugrep
  sockopen bugrep $gettok($window(@.bug).title,1,32) 25
}
on *:DIALOG:bugrep:sclick:100:.timer -mio 1 0 _registerunload
on *:DIALOG:bugrep:sclick:*:if ($did > 0) _clickbtn $did $dname
alias -l _clickbtn {
  if (($1 == 2) || ($1 == 22)) {
    did -v $2 5,6,7,8,9,11,12
    did -h $2 13,14,15,16,17,18,19,20,21,22,23,24
    did -t $2 12
    did -f $2 6
  }
  elseif ($1 == 3) {
    did -v $2 6,7,8,9,21,23,24
    did -h $2 5,11,12,13,14,15,16,17,18,19,20,22
    did -t $2 21
    did -f $2 6
  }
  elseif ($1 == 12) {
    did -v $2 13,14,15,16,17,18,19,20,21,22
    did -h $2 5,6,7,8,9,11,12,23,24
    did -t $2 21
    did -f $2 14
  }
}
on *:DIALOG:bugrep:edit:*:{
  if (($did($did).lines > 1) || ($did($did).text != $null)) {
    if ($did == 6) did -e $dname 12,21
  }
  else {
    if ($did == 6) did -b $dname 12,21
  }
}
on *:SOCKOPEN:bugrep:{
  if ($sockerr) _bugresend Error connecting to server: $sock($sockname).wsmsg
  _progress.2 0 Initiating transfer...
}
on *:SOCKWRITE:bugrep:{
  if ($sockerr) _bugresend Unexpected socket error: $sock($sockname).wsmsg
  if (($sock(bugrep).mark isnum) && ($sock(bugrep).mark > 0)) {
    var %ln = $ifmatch,%line = $line(@.bug,$ifmatch)
    if (%ln \\ 5) _progress.2 $int($calc(%ln * 100 / ($line(@.bug,0) + 2))) Sending data...
    if ($left(%line,1) == .) sockwrite -n bugrep . $+ %line
    else sockwrite -nt bugrep %line
    inc %ln
    if (%ln > $line(@.bug,0)) {
      sockwrite -n bugrep .
      sockmark bugrep 0
    }
    else sockmark bugrep %ln
  }
}
on *:SOCKREAD:bugrep:{
  var %data
  :readmore
  sockread %data
  if ($sockerr) _bugresend Unexpected socket error: $sock($sockname).wsmsg
  if ($sockbr) {
    tokenize 32 %data
    if ($1 == 220) sockwrite -n bugrep HELO $iif(. isin $host,$host,$iif($longip($ip),$ip,$gettok($window(@.bug).title,1,32)))
    elseif ($1 isnum 400-599) _bugresend Error from mail relay: $2-
    elseif ($1 == 354) {
      ; Send text
      sockmark bugrep 2
      sockwrite -n bugrep $line(@.bug,1)
    }
    elseif ($1 isnum 250-259) {
      ; From/to
      if ($sock(bugrep).mark == $null) {
        sockwrite -n bugrep MAIL FROM:< $+ $gettok($window(@.bug).title,2,32) $+ >
        sockmark bugrep a
      }
      elseif ($sock(bugrep).mark == a) {
        sockwrite -n bugrep RCPT TO:<pnp@login.kristshell.net>
        sockmark bugrep b
      }
      elseif ($sock(bugrep).mark == b) {
        sockwrite -n bugrep DATA
        sockmark bugrep c
      }
      elseif ($sock(bugrep).mark == 0) {
        _progress.2 99 Disconnecting...
        sockwrite -n bugrep QUIT
      }
    }
    goto readmore
  }
}
on *:SOCKCLOSE:bugrep:{
  if ($sock(bugrep).mark == 0) {
    window -c @.bug
    _progress.2 100 Feedback sent $+ $chr(44) thank you!
    _registerunload
  }
  else _bugresend Socket closed unexpectedly: $sock($sockname).wsmsg
}
alias -l _bugresend {
  sockclose bugrep
  close -@ @Progress @.pbmp
  _dialog -am bugresend bugresend
  did -ra bugresend 2 $1-
  did -ra bugresend 5 $gettok($window(@.bug).title,1,32)
  $$$
}
dialog bugresend {
  title "Error sending feedback"
  icon script\pnp.ico
  option map
  size -1 -1 267 117
  text "There was an error sending your feedback:", 1, 6 6 267 12
  text "", 2, 6 20 267 12
  text "You may try to resend, or cancel your feedback.", 3, 6 36 253 12
  text "You may need to use your own mail server to send the e-mail- if so, please enter your mail server in the box below.", 4, 6 51 253 20
  edit "", 5, 6 74 167 13
  button "&Retry", 10, 6 95 66 14, OK default
  button "Cancel", 11, 193 95 66 14, cancel
}
on *:DIALOG:bugresend:sclick:10:{
  titlebar @.bug $iif(. isin $did(bugresend,5),$gettok($did(bugresend,5),1,32),login.kristshell.net) $gettok($window(@.bug).title,2,32)
  _bugstart 0
}
on *:DIALOG:bugresend:sclick:11:{
  window -c @.bug
  .timer -mio 1 0 _registerunload
}

;
; Donate dialog
;
dialog pnpdonate {
  title "paiRC.com Donations"
  icon script\pnp.ico
  option map
  size -1 -1 334 101
  text "paiRC.com is now accepting monetary donations via PayPal to support the development of Peace and Protection. These donations will be used to cover ongoing server, domain, and bandwidth costs.", 2, 6 6 320 24
  text "Please note that donations are entirely voluntary and optional- Peace and Protection is and will always remain a free script. Thank you for using Peace and Protection- your support is appreciated.", 3, 6 30 320 24
  text "Click on the link below or visit www.pairc.com to make a donation.", 4, 6 55 320 12
  link "http://www.parc.com/donate.html", 5, 6 67 320 12
  button "Close", 13, 133 82 66 13, cancel default
}
on *:DIALOG:pnpdonate:sclick:5:{ dialog -x $dname | http http://www.pairc.com/donate.html | .timer -mio 1 0 _registerunload }
on *:DIALOG:pnpdonate:sclick:13:{ .timer -mio 1 0 _registerunload }
alias _donate _dialog -md pnpdonate pnpdonate

;
; ABOUT dialog
;
dialog aboutpnp {
  title "About PnP"
  icon script\pnp.ico
  option map
  size -1 -1 167 171
  text "Peace and Protection", 2, 6 6 100 9
  text "by pai", 3, 6 15 100 9
  text "", 4, 6 25 100 9
  text "Dedicated to Awenyedd", 10, 6 35 100 9
  text "Homepage:", 5, 6 71 45 12, right
  text "E-Mail:", 6, 6 82 45 12, right
  link "", 7, 54 71 120 13
  link "", 8, 54 82 120 13
  button "&Close", 1, 6 98 32 12, cancel default
  icon 9, 93 104 66 61
  button "&Report a bug...", 11, 6 121 76 13
  button "&Send feedback...", 12, 6 137 76 13
  button "&Make donation...", 13, 6 153 76 13, disable
}
on *:DIALOG:aboutpnp:init:*:{
  hmake pnp.about 10
  did -a $dname 4 $:ver
  did -o $dname 7 1 $:www
  did -o $dname 8 1 $:email
  var %icon = $_dlgi(about)
  if (%icon !isnum) %icon = 1
  else %icon = $calc(%icon % 3 + 1)
  _dlgw about %icon
  did -g $dname 9 script\pai $+ %icon $+ .bmp
  .timer -mio 1 0 do3d
}
on *:DIALOG:aboutpnp:sclick:1:stop3d
on *:DIALOG:aboutpnp:sclick:7:http $:www | dialog -c aboutpnp
on *:DIALOG:aboutpnp:sclick:8:mailto $:email | dialog -c aboutpnp
on *:DIALOG:aboutpnp:sclick:11:.timer -mio 1 0 bug | dialog -c aboutpnp
on *:DIALOG:aboutpnp:sclick:12:.timer -mio 1 0 feedback | dialog -c aboutpnp
on *:DIALOG:aboutpnp:sclick:13:.timer -mio 1 0 donate | dialog -c aboutpnp
menu @PNP3D {
  sclick:fix3d
  dclick:fix3d | inc -u5 %.blah | if (%.blah > 1) hadd pnp.about cq 1
  $fix3d:{ }
}
alias -l fix3d dialog -v aboutpnp
alias -l do3d window -pfdow0aB +dL @PNP3D $calc($dialog(aboutpnp).x + 145) $calc($dialog(aboutpnp).x + $dialog(aboutpnp).h - $dialog(aboutpnp).ch + 2) 100 100 @PNP3D | hadd pnp.about cx 0 | hadd pnp.about cy 0 | hadd pnp.about cz 0 | .timer3d -mio 0 50 drawbox | dialog -v aboutpnp
alias -l draw3d { drawline -rn @PNP3D $rgb(frame) 1 $calc($1 + 50 + $calc($3 / 4)) $calc($2 + 50 - $calc($3 / 4)) $calc($4 + 50 + $calc($6 / 4)) $calc($5 + 50 - $calc($6 / 4)) }
alias -l drawbox {
  hadd pnp.about cx $calc(($hget(pnp.about,cx) + 4) % 256)
  hadd pnp.about cy $calc(($hget(pnp.about,cy) + 252.5) % 256)
  hadd pnp.about cz $calc(($hget(pnp.about,cz) + 2 + $sin($calc(0.02454 * $hget(pnp.about,cy)))) % 256)
  dorots $cos($calc(0.02454 * $hget(pnp.about,cx))) $sin($calc(0.02454 * $hget(pnp.about,cx))) $cos($calc(0.02454 * $hget(pnp.about,cy))) $sin($calc(0.02454 * $hget(pnp.about,cy))) $cos($calc(0.02454 * $hget(pnp.about,cz))) $sin($calc(0.02454 * $hget(pnp.about,cz)))
}
alias -l dodraws {
  drawrect -frn @PNP3D $rgb(face) 2 0 0 101 101
  draw3d $1-6 | draw3d $4-9 | draw3d $7-12 | draw3d $10-12 $1-3
  draw3d $13-18 | draw3d $16-21 | draw3d $19-24 | draw3d $22-24 $13-15
  draw3d $1-3 $13-15 | draw3d $4-6 $16-18 | draw3d $7-9 $19-21 | draw3d $10-12 $22-24
  drawdot @PNP3D | window @PNP3D $calc($dialog(aboutpnp).x + 145) $calc($dialog(aboutpnp).y + 25)
  if ($appactive) window -ro @PNP3D | else window -h @PNP3D
}
alias -l dorots dodraws $hget(pnp.about,cq) $bitrot(-30,-30,30,$1,$2,$3,$4,$5,$6) $bitrot(30,-30,30,$1,$2,$3,$4,$5,$6) $bitrot(30,30,30,$1,$2,$3,$4,$5,$6) $bitrot(-30,30,30,$1,$2,$3,$4,$5,$6) $bitrot(-30,-30,-30,$1,$2,$3,$4,$5,$6) $bitrot(30,-30,-30,$1,$2,$3,$4,$5,$6) $bitrot(30,30,-30,$1,$2,$3,$4,$5,$6) $bitrot(-30,30,-30,$1,$2,$3,$4,$5,$6)
alias -l bitrot return $calc((($2 * $5 + $3 * $4) * $7 + $1 * $6) * $8 - ($2 * $4 - $3 * $5) * $9) $calc((($2 * $5 + $3 * $4) * $7 + $1 * $6) * $9 + ($2 * $4 - $3 * $5) * $8) $calc(($2 * $5 + $3 * $4) * $6 - $1 * $7)
alias -l stop3d .timer3d off | window -c @PNP3D | hfree pnp.about
alias _about _ssplay Dialog | $dialog(aboutpnp,aboutpnp,-2) | _registerunload

