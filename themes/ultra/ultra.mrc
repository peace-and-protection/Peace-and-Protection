Alias ultra.whois {
  %:echo 2┌─────┬───────────────────────────────────────────---·· ·
  %:echo 2│11Whois2│ 12 $+ %::nick $+([14,%::address,12])
  %:echo 2│2─────┘ 10 $+ %::realname
  if (%::chan) { %:echo 2│10 Channels:11 %::chan }
  %:echo 2│10 Server:11 %::server
  if (%::idletime) { %:echo 2│10 Idle for:11 %::idletime }
  if (%::away) { %:echo 2│10 Away: %away }
  if (%::isoper == is) { %:echo 2│10 &nick 11 $+ %::isoper $+ 10 an IRC operator. }
  %:echo 2└────────────────────────────---·· ·
}
