alias bi.whoisinit {
  %:echo  $+ %::c2 $+ ┌ $+ %::c1 $+ (w)hois  $+ %::c1 $+ [ $+ %::c3 $+ %::nick $+  $+ %::c1 $+ ]
  %:echo  $+ %::c2 $+ ╞═════════╤════════════════════════════════════════╕
  %:echo  $+ %::c2 $+ │  $+ %::c1 $+ (h) $+ %::c4 $+ ost:  $+ %::c2 $+ │ $+ %::c3 $replace(%::address,@, $+ %::c2 $+ @ $+ %::c3 $+ )
  %:echo  $+ %::c2 $+ │  $+ %::c1 $+ (n) $+ %::c4 $+ ame:  $+ %::c2 $+ │ $+ %::c3 %::realname
}
alias bi.whoischan {
  %:echo  $+ %::c2 $+ │  $+ %::c1 $+ (c) $+ %::c4 $+ han:  $+ %::c2 $+ │ $+ %::c3 $replace(%::chan,@, $+ %::c2 $+ @ $+ %::c3 $+ )
}
alias bi.whoisserv {
  %:echo  $+ %::c2 $+ │  $+ %::c1 $+ (s) $+ %::c4 $+ erv:  $+ %::c2 $+ │ $+ %::c3 %::wserver
}
alias bi.whoisidle {
  %:echo  $+ %::c2 $+ │  $+ %::c1 $+ (i) $+ %::c4 $+ dle:  $+ %::c2 $+ │ $+ %::c3 $duration(%::idletime,2)
}
alias bi.whoisreg {
  %:echo  $+ %::c2 $+ │  $+ %::c1 $+ (r) $+ %::c4 $+ egd:  $+ %::c2 $+ │ $+ %::c3 this is a registered nick
}
alias bi.whoisoper {
  %:echo  $+ %::c2 $+ │  $+ %::c1 $+ (o) $+ %::c4 $+ per:  $+ %::c2 $+ │ $+ %::c3 yes
}
alias bi.whoisaway {
  %:echo  $+ %::c2 $+ │  $+ %::c1 $+ (a) $+ %::c4 $+ way:  $+ %::c2 $+ │ $+ %::c3 %::text
}
alias bi.whoisend {
  %:echo  $+ %::c2 $+ ╞═════════╧════════════════════════════════════════╛
  %:echo  $+ %::c2 $+ └ $+ %::c1 $+ (e)nd of whois
}
