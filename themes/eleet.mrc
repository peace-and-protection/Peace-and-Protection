
; Aliases for eleet.mts

alias etheme.npad2 if ($len($2) >= $1) return $2 | return $replace($2 $+ $str(,$calc($1 - $len($2))),,$chr(32))
alias etheme.npad if (%::cmode != $null) return [ $+ $ifmatch $+ $etheme.npad2(9,$1) | return [ $etheme.npad2(9,$1)
alias etheme.npada if (%::cmode != $null) return ( $+ $ifmatch $+ $etheme.npad2(9,$1) | return ( $etheme.npad2(9,$1)
