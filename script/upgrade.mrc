; #= P&P -rs
; @======================================:
; |  Peace and Protection                |
; |  Upgrade/patch, translation routines |
; `======================================'
 
;
; Translation support
;
 
; Quickly load english
alias english { translate $1 script\trans\english.ini }
 
; /translate [-opt] [languagefile]
; opts- f to force translation update
;       p for lowercase popups
;       l for lowercase everything
;       n for don't use previous options
; If n is not specified, and p/l are not specified, then options from most recent translation are used
alias translate {
  if ($readini(script\transup.ini,n,translation,language) == no) {
    dispa This installation of PnP does not currenlty support translation. You may download a version that supports translation at www.kristshell.net/pnp/.
    halt
  }
  if (-* iswm $1) {
    var %flags = $remove($1,n)
    var %file = $2-
    if ($remove($1,-,f) == $null) %flags = %flags $+ $remove($readini(script\transup.ini,n,translation,transopt),-,n,f)
  }
  else {
    var %flags = - $+ $remove($readini(script\transup.ini,n,translation,transopt),-,n,f)
    var %file = $1-
  }
  if (%file == $null) {
    config 28
    halt
  }
  ; Handle translation
  _load translate
  .timer -mio 1 0 _dotranslate %flags %file
}
 
; Misc updates done after a translation
on *:SIGNAL:PNP.TRANSLATE:{
  ; Update %=*.clr
  _rechash3
  ; Update 'net' in all pnp.$cid hashes if offline
  var %scon = $scon(0)
  while (%scon) {
if (!$scon(%scon).server) hadd pnp. $+ $scon(%scon) Offline
    dec %scon
  }
}
