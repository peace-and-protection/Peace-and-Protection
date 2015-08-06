
; Aliases for eleet2.mts

alias etheme.npad2 if ($len($2) >= $1) return $2 | return $replace($2 $+ $str(,$calc($1 - $len($2))),,$chr(32)) $+  $+ %::cnick
alias etheme.npad if (%::cmode != $null) return $chr(91) $+ $ifmatch $+ $etheme.npad2(9,$1) | return $chr(91) $etheme.npad2(9,$1)
alias etheme.npada if (%::cmode != $null) return $chr(40) $+ $ifmatch $+ $etheme.npad2(9,$1) | return $chr(40) $etheme.npad2(9,$1)
