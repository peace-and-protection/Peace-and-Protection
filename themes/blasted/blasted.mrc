alias blasted.whoisstart {
  %:echo 1 — /whois12 %::nick 1————12————14———13————————————15——————————————————
  %:echo    1• address 15:12 %::address
  %:echo    1• name    15:12 %::realname
}
alias blasted.whowasstart {
  %:echo 1 — /whowas12 %::nick 1————12————14———13————————————15——————————————————
  %:echo    1• address 15:12 %::address
  %:echo    1• name    15:12 %::realname
}
alias blasted.st return $remove($duration($$1),ks,k,ays,ay,rs,r,ins,in,ecs,ec)
alias blasted.topic {
  %:echo  121———————12—————————14——————————13————————————————————15——————————————————————————————
  %:echo  %::pre topic  15:12 $+(',%::text,') 
}
alias blasted.endtopic {
  %:echo %::pre set by 15:12 %::nick 13on12 $asctime(%::value,dd/mmm/yyyy - HH:nn:ss 13·12 ddd)
  %:echo  121——————12———————14———————13————————————————15———————————————————————
}

; damn, the last lusers raw is different on some networks, so, I had to comment out the seplines... they ruled :\
alias blasted.lusersstart {
  ;  %:echo 
  ;  %:echo 1 — /lusers12 %::server 1———12———14———13———————————15—————————————————
  %:echo %::pre /lusers12 %::server
  %:echo    1• invis.  15:12 %::text
  %:echo    1• servers 15:12 %::value
}
alias blasted.lusersend {
  %:echo    1• global  15:12 %::users 13/ max 15:14 $+ %::value 13·12 $round($calc($calc(%::users / %::value) * 100),1) $+ %
  ;  %:echo 1 —————12————14———13—————————————15————————————————————— 
  ;  %:echo 
}

alias blasted.names {
  if (%::chan != %::blastedtheme.names.chan) {
    %:echo 1— /names12 %::chan 1—————12——————14————————13———————————————15——————————————————————
    %::blastedtheme.names.chan = %::chan
  }
  var %x = 0
  %::text = $gettok(%::text,2-,32)
  while ($gettok(%::text,$+($calc(1 + %x),-,$calc(%x + 4)),32)) {
    var %names = $ifmatch, %y = 1, %names2
    while ($gettok(%names,%y,32)) {
      %names2 = $addtok(%names2,$+(13· 12,$ifmatch,$str($chr(160),$calc(15 - $len($gettok(%names,%y,32))))),32)
      inc %y
    }
    %:echo    %names2
    inc %x 4
  }
}
alias blasted.endnames {
  %:echo 1———————12————————14—————————13——————————————————15—————————————————————————
  if (-s isin %:echo) %:echo -
  unset %::blastedtheme.names.*
}

alias blasted.intro {
  color inactive 15
  %:echo = echo -s 
  %:echo 
  %:echo %::pre blasted 14theme for mTS
  %:echo %::pre written14 by 12Brain 13· 12brain@iol.pt
  %:echo %::pre thanks 14to12 BlindSide 14for his support and friendship
  %:echo 
}
