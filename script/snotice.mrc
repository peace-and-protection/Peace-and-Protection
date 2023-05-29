; #= P&P -rs
; ########################################
; Peace and Protection
; Servernotice and wallop filtering and display
; ########################################

;
; Server notices
;

on &^*:SNOTICE:Ca & Cd & Ce & Cl & Ch & Cu &:return
on &^*:SNOTICE:Re & Rl & Rp & Rq &:return
on &^*:SNOTICE:Ru & Rsh & Rs & Rt &:return
on &^*:SNOTICE:Minute *Hour *Day *Yest*:hadd pnp. $+ $cid -statsw 1 | return

alias -l _skipsn if ($hget(pnp. $+ $cid,-statsw)) $$$ | if ($hget(pnp.config,snotice.on) == 0) { _showsn $2- | halt } | if ($mid($hget(pnp.config,snotice.f),$1,1)) return | halt

on &^*:SNOTICE:& & & Nick change collision from *:{
  _skipsn 1 $1-
  _showsn Collide- $:s($10) killed by $:s($gettok($14,1,91)) (Nick collision- nick change from $:s($8) to $:s($10) $+ )
}
on &^*:SNOTICE:& & & Nick collision on *:{
  _skipsn 1 $1-
  _showsn Collide- $:s($7) killed by $:s($gettok($11,1,91)) (Nick collision)
}
on &^*:SNOTICE:& & & received kill message for *:{
  if (($10 == nickserv) || ($10 == nickop) || (services.* iswm $10)) var %num = 2
  else var %num = 3
  if ($chr(40) isin $10-) var %reason = $_noparen($mid($10-,$pos($10-,$chr(40),1),$len($10-)))
  else var %reason = $gettok($10-,$numtok($10-,33),33)
  if ($istok((older nick overruled)*(nick collision from same user@host)*(Nick collision),$gettok(%reason,4-,32),42)) { _skipsn 1 $1- | _showsn Collide- $:s($left($8,-1)) killed by $:s($10) ( $+ %reason $+ ) }
  elseif ((?change collision *->* iswm %reason) || (?collision *->* iswm %reason)) { _skipsn 1 $1- | _showsn Collide- $_break($8) killed by $:s($10) ( $+ %reason $+ ) }
  elseif (*. iswm $8) { _skipsn %num $1- | _showsn Kill- $:s($left($8,-1)) killed by $:s($10) ( $+ %reason $+ ) }
  else { _skipsn %num $1- | _showsn Kill- $_break($8) killed by $:s($10) ( $+ %reason $+ ) }
}
on &^*:SNOTICE:& & & net break*:{
  _skipsn 4 $1-
  _showsn Split- $:s($6) <-/ /-> $:s($7) ( $+ $_noparen($8-) $+ )
}
on &^*:SNOTICE:& & & Local SQUIT by *:{
  _skipsn 4 $1-
  _showsn Split- $:s($nick) <-/ /-> $:s($remove($8,$chr(91),$chr(93),:)) - Local SQUIT by $:s($7) $iif($9,( $+ $9- $+ ))
}
on &^*:SNOTICE:& & & Remote SQUIT by *:{
  _skipsn 4 $1-
  _showsn Split- $:s($remove($8,$chr(91),$chr(93),:)) - Remote SQUIT by $:s($7) $iif($9,( $+ $9- $+ ))
}
on &^*:SNOTICE:& & & Received SQUIT *:{
  _skipsn 4 $1-
  if ($8 == $6) {
    if (($9- != :) && ($9- != $null)) _showsn Split- $:s($8) - Received SQUIT $iif($9,( $+ $9- $+ ))
    else _showsn Split- $:s($8) - Received SQUIT
  }
  else {
    if (($9- != :) && ($9- != $null)) _showsn Split- $:s($8) <-/ /-> $:s($6) - Received SQUIT $iif($9,( $+ $9- $+ ))
    else _showsn Split- $:s($8) <-/ /-> $:s($6) - Received SQUIT
  }
}
on &^*:SNOTICE:& & & from & Closing link to *:{
  _skipsn 4 $1-
  _showsn Split- $:s($remove($5,:)) <-/ /-> $:s($9) ( $+ $10- $+ )
}
on &^*:SNOTICE:& & & Link with & cancelled*:{
  _skipsn 4 $1-
  _showsn Split- $_break($6) (Link cancelled: $8- $+ )
}
on &^*:SNOTICE:& & & Write error to & closing link:{
  _skipsn 4 $1-
  _showsn Split- $:s($nick) <-/ /-> $:s($gettok($7,1,44)) - Write error $+ $chr(44) closing link
}
on &^*:SNOTICE:& & & Link with & established*:{
  _skipsn 5 $1-
  _showsn Merge- $_break($6) (Link established)
}
on &^*:SNOTICE:& & & from & connection to & established*:{
  _skipsn 5 $1-
  _showsn Merge- $:s($remove($5,:)) --><-- $:s($8)
}
on &^*:SNOTICE:& & & Attempting to connect to & -- *:{
  _skipsn 5 $1-
  _showsn Merge- Attempting connection to $:s($8) ( $+ $10- $+ )
}
on &^*:SNOTICE:& & & net junction*:{
  _skipsn 5 $1-
  _showsn Merge- $:s($6) --><-- $:s($7)
}
on &^*:SNOTICE:& & & Completed net.burst*:{
  _skipsn 6 $1-
  _showsn Merge- Completed burst to $:s($7)
}
on &^*:SNOTICE:& & & Completed sending Burst Data to *:{
  _skipsn 6 $1-
  _showsn Merge- Completed sending burst to $:s($gettok($9,1-,46))
}
on &^*:SNOTICE:& & & Completed receiving Burst Data from *:{
  _skipsn 6 $1-
  _showsn Merge- Completed receiving burst from $:s($gettok($9,1-,46))
}
on &^*:SNOTICE:& & & & acknowledged end of net.burst*:{
  _skipsn 7 $1-
  _showsn Merge- Burst fully received by $:s($4)
}
on &^*:SNOTICE:& & & & adding GLINE for *:{
  _skipsn 8 $1-
  _showsn GLine- $:s($gettok($8,1,44)) g-lined by $:s($4) $+ ; expires $_datetime($gettok($11,1,58)) ( $+ $12- $+ )
}
on &^*:SNOTICE:& & & & adding local GLINE for *:{
  _skipsn 8 $1-
  _showsn GLine- $:s($gettok($9,1,44)) local g-lined by $:s($4) $+ ; expires $_datetime($gettok($12,1,58)) ( $+ $13- $+ )
}
on &^*:SNOTICE:& & & & removing GLINE for *:{
  _skipsn 9 $1-
  _showsn GLine- Removing $:s($8) g-line; removed by $:s($4)
}
on &^*:SNOTICE:& & & & GLINE's removed:{
  _skipsn 9 $1-
  _showsn GLine- Removing $:s($4) g-lines
}
on &^*:SNOTICE:& & & g-line active for *:{
  _skipsn 11 $1-
  _showsn GLine- Active g-line for $_break($7)
}
on &^*:SNOTICE:& & & & & is now operator*:{
  _skipsn 12 $1-
  var %type = $iif(H isin $9,$iif((H isincs $9) || (O isincs $9),global,local) (helpop),$iif(A isincs $9,$iif((A isincs $9) || (O isincs $9),global,local) (admin),$iif(o isincs $9,local,$iif(O isincs $9,global,$9))))
  _showsn Oper- $:s($4) $5 is now a %type operator
}
on &^*:SNOTICE:& & & & & is now an operator*:{
  _skipsn 12 $1-
  _showsn Oper- $:s($4) is now an operator
}
on &^*:SNOTICE:& & & new max local clients*:{
  _skipsn 13 $1-
  _showsn Client- New max local clients $:s($8)
}
on &^*:SNOTICE:& & & maximum connections*:{
  _skipsn 13 $1-
  _showsn Client- New max local clients $:s($remove($7,$chr(40))) ( $+ $6 total connections)
}
on &^*:SNOTICE:& & & k-line active for *:{
  _skipsn 14 $1-
  _showsn KLine- Active k-line for $_break($7)
}
on &^*:SNOTICE:& & & & has removed the k-line for*:{
  _skipsn 15 $1-
  _showsn KLine- Removing $:s($remove($11,$chr(40))) k-line $+ $chr(40) $+ s $+ $chr(41) matching $:s($10) $+ ; removed by $:s($4)
}
on &^*:SNOTICE:& & & kill line active for *:{
  _skipsn 14 $1-
  _showsn KLine- Active kill line for $_break($8)
}
on &^*:SNOTICE:& & & & added a temp k?line for *:{
  _skipsn 16 $1-
  _showsn KLine- $:s($10) temp k-lined by $:s($4) $iif($11,( $+ $11- $+ ))
}
on &^*:SNOTICE:& & & from & & added * minute autokill for *:{
  _skipsn 16 $1-
  _showsn AutoKill- $:s($9) minute autokill added for $:s($13) by $:s($6) ( $+ $15- $+ )
}
on &^*:SNOTICE:& & & connect failure*:{
  _skipsn 17 $1-
  _showsn Connect- $_break($6) failed to connect ( $+ $7- $+)
}
on &^*:SNOTICE:& & & Cannot accept connections *:{
  _skipsn 17 $1-
  _showsn Connect- $gettok($7,1,58) can't accept connections ( $+ $gettok($7-,2-,58) $+ )
}
on &^*:SNOTICE:& & & Cannot accept connections? *:{
  _skipsn 17 $1-
  _showsn Connect- Can't accept connections ( $+ $7- $+ )
}
on &^*:SNOTICE:& & & Entering high-traffic mode -*:{
  _skipsn 18 $1-
  _showsn Traffic- Entering high-traffic mode $8-
}
on &^*:SNOTICE:& & & Still high-traffic mode *:{
  _skipsn 18 $1-
  _showsn Traffic- Still in high-traffic mode ( $+ $10 $+ )
}
on &^*:SNOTICE:& & & Resuming standard operation*:{
  _skipsn 18 $1-
  _showsn Traffic- Resuming standard operation
}
on &^*:SNOTICE:& & & from & Clone Alert*:{
  _skipsn 19 $1-
  _showsn Alert- $:s($8) clones from $:s($11) $chr(40) $+ from $remove($5,:) $+ $chr(41)
}
on &^*:SNOTICE:& & & from & services are being flooded *:{
  _skipsn 20 $1-
  _showsn Alert- $:s($11) is flooding services $chr(40) $+ from $remove($5,:) $+ $chr(41)
}
on &^*:SNOTICE:& & & did /whois on you*:{
  _skipsn 21 $1-
  _showsn Report- WHOIS on you by $_break($3)
}
on &^*:SNOTICE:& & & did a /whois on you*:{
  _skipsn 21 $1-
  _showsn Report- WHOIS on you by $:s($2) $3
}
on &^*:SNOTICE:& & is doing a whois on you:{
  _skipsn 21 $1-
  _showsn Report- WHOIS on you by $:s($1) $2
}
on &^*:SNOTICE:& Report & & has issued a *:{
  _skipsn 22 $1-
  _showsn Report- ' $+ $:s($8-) $+ ' issued by $:s($4)
}
on &^*:SNOTICE:& & & & resetting expiration time on GLINE for *:{
  _skipsn 10 $1-
  _showsn GLine- $:s($11) g-line reset by $:s($4) to expire $_datetime($13)
}
on &^*:SNOTICE:& & & IP# mismatch*:{
  _skipsn 23 $1-
  _showsn Mismatch- IP $:s($6) does not match $gettok($8,1,91)
}
on &^*:SNOTICE:& & & Username & for user & contained illegal characters & and was changed to *:{
  _skipsn 24 $1-
  _showsn Username- Username for $:s($8) invalid- $5 contains illegal chars $12 and was changed to $17
}
on &^*:SNOTICE:& & & Username & for user & contained illegal characters *:{
  _skipsn 24 $1-
  _showsn Username- Username for $:s($8) invalid- $5 contains illegal chars $12
}
on &^*:SNOTICE:& & & Got signal SIGHUP, reloading ircd conf*:{
  _skipsn 25 $1-
  _showsn Rehash- Reloading IRCd configuration
}
on &^*:SNOTICE:& & & & is rehashing server config file:{
  _skipsn 25 $1-
  _showsn Rehash- Reloading IRCd configuration $chr(40) $+ by $:s($4) $+ $chr(41)
}
on &^*:SNOTICE:& & & SETTIME from & clock is set *:{
  _skipsn 26 $1-
  _showsn Report- Clock set $:s($10) second $+ $chr(40) $+ s $+ $chr(41) $remove($12,s) $chr(40) $+ by $:s($gettok($6,1,44)) $+ $chr(41)
}
on &^*:SNOTICE:& & & Received unauthorized connection from *:{
  _skipsn 27 $1-
  _showsn Connect- Unauthorized connect from $_break($gettok($8,1-,46))
}
on &^*:SNOTICE:& & & Unauthorized connection from *:{
  _skipsn 27 $1-
  _showsn Connect- Unauthorized connect from $_break($gettok($7,1-,46))
}
on &^*:SNOTICE:& & & Bogus server name & from *:{
  _skipsn 28 $1-
  _showsn Alert- Bogus server name $:s($_noparen($7)) from $:s($remove($9,$chr(91),$chr(93)))
}
on &^*:SNOTICE:& & & Throttling connections from *:{
  _skipsn 29 $1-
  if ($7 !isin $8) _showsn Throttle- Connections from $:s($7) ( $+ $mid($8,2,$calc($len($8) - 3)) $+ ) throttled
  else _showsn Throttle- Connections from $:s($7) throttled
}
on &^*:SNOTICE:& & & Removing throttle for *:{
  _skipsn 29 $1-
  if ($7 !isin $8) _showsn Throttle- Removing throttle on $:s($7) ( $+ $mid($8,2,$calc($len($8) - 3)) $+ )
  else _showsn Throttle- Removing throttle on $:s($7)
}
on &^*:SNOTICE:& & & HACK(4)*:{
  _skipsn 30 $1-
  _showsn Hack- $:s($5) $6-
}
on &^*:SNOTICE:& & & BOUNCE or HACK(3)*:{
  _skipsn 30 $1-
  _showsn Hack- $:s($7) $8-
}
on &^*:SNOTICE:& & & HACK(2)*:{
  _skipsn 30 $1-
  _showsn Hack- $:s($5) $6-
}
on &^*:SNOTICE:& & & NET.RIDE on *:{
  _skipsn 30 $1-
  _showsn Hack- Net ride on opless $:s($7) from $:s($9)
}
on &^*:SNOTICE:& & & Client connecting on port *:{
  _skipsn 32 $1-
  _showsn Client- Connection from $:s($9) $10 (port $left($8,-1) $+ )
}
on &^*:SNOTICE:& & & Client connecting*:{
  _skipsn 32 $1-
  if ($7) _showsn Client- Connection from $_break($6) ( $+ $_noparen($7-) $+ )
  else _showsn Client- Connection from $_break($6)
}
on &^*:SNOTICE:& & & Client exiting*:{
  _skipsn 32 $1-
  if ($7) _showsn Client- Exit from $_break($6) ( $+ $_noparen($7-) $+ )
  else _showsn Client- Exit from $_break($6)
}
on &^*:SNOTICE:& & & Shun from & for *:{
  _skipsn 33 $1-
  _showsn Shun- Added for $_break($8) by $_break($6) $9-
}
on &^*:SNOTICE:& & & from & & used SAMODE *:{
  _skipsn 34 $1-
  _showsn SAMODE- Used by $_break($6) $9- from $remove($5,:)
}
on &^*:SNOTICE:& & & from & & used SAJOIN *:{
  _skipsn 35 $1-
  _showsn SAJOIN- Used by $_break($6) $9- from $remove($5,:)
}
on &^*:SNOTICE:& & & from & & used GETPASS cmd for the channel *:{
  _skipsn 36 $1-
  _showsn Services- $:s($6) $7-12 $:s($13) ( $+ $4 $remove($5,:) $+ )
}
on &^*:SNOTICE:& & & from & & wiped the access list of the nickname *:{
  _skipsn 36 $1-
  _showsn Services- $:s($6) $7-13 $:s($13) ( $+ $4 $remove($5,:) $+ )
}
on &^*:SNOTICE:*:{
  if ((*total connections iswm $1-) && ($hget(pnp. $+ $cid,-statsw))) { hdel pnp. $+ $cid -statsw | return }
  elseif (($remove($usermode,+,i) == $null) || (Highest connection count* iswm $1-)) {
    ; First notice during signon = linesep
    if ($hget(pnp. $+ $cid,-linesep.signon) == 1) {
      disps-div
      hadd pnp. $+ $cid -linesep.signon 2
    }
    return
  }
  _skipsn 31 $1-
  if ($remove($1,*) == $null) _showsn $2- | else _showsn $1-
}

alias -l _noparen if (($left($1-,1) == $chr(40)) && ($right($1-,1) == $chr(41))) return $mid($1-,2,$calc($len($1-) - 2)) | return $1-

; breaks nick, nick[ip], or [ip] into one or two params and returns as nick, ip, or nick (ip), first one s:().
; will also break <nick!addr> and nick!addr into nick (addr)
alias -l _break {
  if (<*!*@*> iswm $1) return $:s($right($gettok($1,1,33),-1)) ( $+ $left($gettok($1,2-,33),-1) $+ )
  if (*!*@* iswm $1) return $:s($gettok($1,1,33)) ( $+ $gettok($1,2-,33) $+ )
  if (*.*] !iswm $1) return $:s($1)
  if (($count($1,$chr(91)) == 1) && ([* iswm $1)) return $:s($mid($1,2,$calc($len($1) - 2)))
  return $:s($left($1,$calc($pos($1,$chr(91),$count($1,$chr(91))) - 1))) ( $+ $left($mid($1,$calc($pos($1,$chr(91),$count($1,$chr(91))) + 1),$len($1)),-1) $+ )
}

alias -l _showsn {
  var %win = $hget(pnp.config,snotice.win)
  if (@* iswm %win) {
    %win = $_mservwin(%win)
    if ($window(%win) == $null) {
      _window 1 -nv + %win -1 -1 -1 -1 @SNotice
      titlebar %win ( $+ $hget(pnp. $+ $cid,net) $+ )
    }
  }

  set -u %:echo echo $color(notice) $iif(-* iswm %win,%win $+ tm $iif((a isin %win) && ($cid != $activecid),$:anp),-mti2 %win)
  set -u %::fromserver $nick
  set -u %::text $1-
  theme.text NoticeServer

  _ssplay NoticeServer
  haltdef
}

menu @SNotice {
  Filters...:config 10
  Usermode...:umode
  -
  $iif(s isincs $usermode,$style(1)) Mode +s on:umode +s
  $iif(s !isincs $usermode,$style(1)) Mode +s off:umode -s
}

;
; Wallops
;

alias -l _skipwa if ($hget(pnp.config,wallop.on) == 0) { _showwo ! $+ $nick $+ ! $2- | halt } | if ($mid($hget(pnp.config,wallop.f),$1,1)) return | halt

on &^*:WALLOPS:*Alert* & attempted to flood services:{
  _skipwa 4 $1-
  _showwo Alert- $_break($2) is flooding services $chr(40) $+ from $nick $+ $chr(41)
}
on &^*:WALLOPS:& adding *netban* for & hours on & *:{
  _skipwa 11 $1-
  _showwo NetBan- $:s($8) added by $:s($1) for $5-6 $9-
}
on &^*:WALLOPS:& adding KLINE for & exp*:{
  _skipwa 3 $1-
  _showwo KLine- $:s($5) k-lined by $:s($1) $6-
}
on &^*:WALLOPS:& is using & & MODE *:{
  _skipwa 8 $1-
  _showwo Mode- $7- ( $+ from $:s($1) using $4 $+ )
}
on &^*:WALLOPS:CMD mode *:{
  _skipwa 8 $1-
  _showwo Mode- $3- ( $+ from $nick $+ )
}
on &^*:WALLOPS:Invite FORCED from & on &:{
  _skipwa 6 $1-
  _showwo Invite- $:s($4) to $:s($6) $chr(40) $+ forced using $nick $+ $chr(41)
}
on &^*:WALLOPS:& is asking me to & channel &:{
  _skipwa 10 $1-
  _showwo Services- $_break($1) is asking $:s($nick) to $6 $:s($8)
}
on &^*:WALLOPS:& is using & & CLEARCHAN *:{
  _skipwa 7 $1-
  _showwo Services- $:s($7) cleared by $:s($1) $chr(40) $+ using $4 $+ $chr(41)
}
on &^*:WALLOPS:REMGLINE &:{
  _skipwa 5 $1-
  _showwo GLine- Removing $:s($2) g-line; removed by $:s($nick)
}
on &^*:WALLOPS:GLINE for *:{
  _skipwa 2 $1-
  _showwo GLine- $:s($3) g-lined by $:s($nick) $4-
}
on &^*:WALLOPS:& [BLOCK] *:{
  _skipwa 2 $1-
  _showwo Block- $:s($3) blocked by $:s($right($left($1,-1),-1)) ( $+ $4- $+ )
}
on &^*:WALLOPS:HACK*:{
  _skipwa 1 $1-
  _showwo Hack- $2-
}
on &^*:WALLOPS:Remote CONNECT *:{
  _skipwa 9 $1-
  _showwo Merge- Remote connect of $:s($3) on $4 by $:s($6)
}
on &^*:WALLOPS:*:{
  _skipwa 12 $1-
  _showwo $1-
}

alias -l _showwo {
  var %win = $hget(pnp.config,wallop.win)
  if (@* iswm %win) {
    %win = $_mservwin(%win)
    if ($window(%win) == $null) {
      _window 1 -nv + %win -1 -1 -1 -1 @Wallop
      titlebar %win ( $+ $hget(pnp. $+ $cid,net) $+ )
    }
  }

  set -u %:echo echo $color(wallop) $iif(-* iswm %win,%win $+ tm $iif((a isin %win) && ($cid != $activecid),$:anp),-mti2 %win)
  set -u %::fromserver $iif(. isin $nick,$nick)
  set -u %::nick $iif(. !isin $nick,$nick)
  set -u %::text $1-
  theme.text Wallop

  _ssplay Wallop
  haltdef
}

menu @Wallop {
  Filters...:config 12
  Usermode...:umode
  -
  $iif(w isincs $usermode,$style(1)) Mode +w on:umode +w
  $iif(w !isincs $usermode,$style(1)) Mode +w off:umode -w
}

