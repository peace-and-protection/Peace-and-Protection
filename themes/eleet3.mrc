; #= P&P.theme -rs

; Aliases for eleet3.mts

alias etheme.npad2 if ($len($2) >= $1) return $2 | return $replace($str(,$calc($1 - $len($2))) $+ $2,,$chr(32))
alias etheme.npad if (%::cmode != $null) return [ $+ $ifmatch $+ $etheme.npad2(9,$1) | return [ $etheme.npad2(9,$1)
alias etheme.npada if (%::cmode != $null) return ( $+ $ifmatch $+ $etheme.npad2(9,$1) | return ( $etheme.npad2(9,$1)
