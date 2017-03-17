alias _padcalc1 {
  var %y = $len($1-)
  var %t = $calc(2 - %y)
  return $str($chr(160),%t) $+ $1-
}
alias _padcalc2 {
  var %y = $len($1-)
  var %t = $calc(16 - %y)
  return $str($chr(160),%t) $1-
}
alias nn.linesep { 
  return $_padcalc1() $_padcalc2($chr(160)) %::pre
}
alias c.who {
  %:echo $_padcalc1(*) $_padcalc2(<who>) %::pre /who %::chan
  %:echo $_padcalc1(*) $_padcalc2(<who>) %::pre user: %::realname ( $+ %::address $+ )
  %:echo $_padcalc1(*) $_padcalc2(<who>) %::pre %::nick $+ , %::address $+ , %::away $+ , %::isoper an IRCop
}
alias c.whois {
  %:echo $_padcalc1(*) $_padcalc2(<whois>) %::pre user: %::realname ( $+ %::address $+ )
  if (%::cwhois.auth) { %:echo  $_padcalc1(*) $_padcalc2(<whois>) %::pre authnick: $ifmatch }
  if (%::operline) { %:echo  $_padcalc1(*) $_padcalc2(<whois>) %::pre %::nick is an IRC Operator }
  if (%::chan) { %:echo $_padcalc1(*) $_padcalc2(<whois>) %::pre channels: %::chan }
  if (%::wserver) { %:echo $_padcalc1(*) $_padcalc2(<whois>) %::pre server: %::wserver ( $+ %::serverinfo $+ ) }
  if (%::away) { %:echo $_padcalc1(*) $_padcalc2(<whois>) %::pre away: %::away }
  if (%::idletime) {
    %:echo $_padcalc1(*) $_padcalc2(<whois>) %::pre idle: $duration(%::idletime)
    %:echo $_padcalc1(*) $_padcalc2(<whois>) %::pre signed on: $duration($calc($ctime - $ctime(%::signontime))) ago
  }
  %:echo $_padcalc1(*) $_padcalc2(<whois>) %::pre end of /whois
  unset %::cwhois.auth
}
alias c.whowas {
  %:echo $_padcalc1(*) $_padcalc(<whowas>) %::pre %::nick was %::realname ( $+ %::address $+ )
  if (%::wserver) { %:echo $_padcalc1(*) $_padcalc(<whowas>) %::pre server: %::wserver }
  if (%::serverinfo) { return }
  %:echo $_padcalc1(*) $_padcalc2(<whowas>) %::pre end of /whowas
}
alias -l whoisloop {
  var %x = $1-, %t,%f = 1
  while (%f <= 5) {
    if ($istok($comnick(%::nick),$gettok(%x,%f,32),32)) { %t = %t $+(,$gettok(%x,%f,32),) }
    else { %t = %t $gettok(%x,%f,32) }
    inc %f
  }
  return %t
}
alias -l comnick { 
  if (!$comchan($1,0)) { return $1- } 
  var %x 1 
  while ($comchan($1,%x)) { 
    var %comnick = %comnick $iif($1 isop $comchan($1,%x),@, $iif($1 isvoice $comchan($1,%x),+,) ) $+ $comchan($1,%x) 
    inc %x 
  } 
  return %comnick 
}