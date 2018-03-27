; #= P&P -rs
; @======================================:
; |  Peace and Protection                |
; |  Command-line configuration aliases  |
; `======================================'

; /nickcol [-nt] [on|off|edit]
; 'edit' opens theme dialog to edit nick colors
; -n modifies/views setting for nicklist
; -t modifies/views setting for theme/text
; If neither present, modifies/views both
; In all cases, refreshes all nicklists
alias nickcol {
  if (-* !iswm $1) tokenize 32 -nt $1
  if ($2 == edit) {
    ncedit
    return
  }
  if (n isin $1) {
    if (($2 == on) || ($2 == on)) _cfgw nickcol 1
    elseif (($2 == off) || ($2 == off)) _cfgw nickcol 0
    if ($_cfgi(nickcol)) {
      .enable #pp-nicklist
      var %status = $:t(On)
    }
    else {
      .disable #pp-nicklist
      var %status = $:t(Off)
    }
    dispa Nicklist coloring is %status
  }
  if (t isin $1) {
    if (($2 == on) || ($2 == on)) `set themecol 1
    elseif (($2 == off) || ($2 == off)) `set themecol 0
    if ($hget(pnp.config,themecol)) var %status = $:t(On)
    else var %status = $:t(Off)
    dispa Theme nick coloring is %status
  }
  var %scon = $scon(0)
  while (%scon >= 1) {
    scon %scon
    var %num = 1
    while ($chan(%num)) {
      _nickcol.updatechan $chan(%num) 1
      inc %num
    }
    dec %scon
  }
  scon -r
}

; /text [on|off|cfg|edit|mirc|pnp]
; /text [load|save] [scheme#] theme.ext
; on|off affects pnp theming channel events (text, joins, etc.)
; 'cfg' opens textopt dialog
; 'edit' opens theme dialog to text scheme editor
; 'mirc' loads blank events (to return to mirc display)
; 'pnp' loads blank events but with (nick): pnp display
; Loading or saving is like /theme load|save but only does script/events/display/info (-d aka +cdei)
alias text {
  if (($1 == on) || ($1 == on)) {
    _cfgw texts 1
    .enable #pp-texts
    var %status = $:t(On)
    dispa Text theming is %status ( $+ $iif($hget(pnp.theme,Name),$ifmatch,Unnamed theme) $+ )
  }
  elseif (($1 == off) || ($1 == off)) {
    _cfgw texts 0
    .disable #pp-texts
    var %status = $:t(Off)
    dispa Text theming is %status
  }
  elseif ($1 == cfg) textopt
  elseif ($1 == edit) textsch
  elseif ($1 == mirc) theme load -ce script\blank.mtp
  elseif ($1 == pnp) theme load -ce script\blankpnp.mtp
  elseif ($1 == save) theme save -d $2-
  elseif ($1 == load) theme load -d $2-
  elseif ($1 != $null) theme load -d $1-
  elseif ($_cfgi(texts)) {
    var %status = $:t(On)
    dispa Text theming is %status ( $+ $iif($hget(pnp.theme,Name),$ifmatch,Unnamed theme) $+ ) - Use $:b(/theme) to configure
  }
  else {
    var %status = $:t(Off)
    dispa Text theming is %status - Use $:b(/theme) to configure
  }
}
