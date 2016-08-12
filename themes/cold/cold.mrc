alias _pnpnbs-irc.names366uc {
  if (. isin %::count) {
    %:echo %::pre All users on channel are invisible %:comments
  }
  elseif (%::count > 0) {
    %:echo %::pre Total $:t(%::count) nicks
    if (%::count != %::countreg) {
      var %users,%num = 1
      while (%num <= $len($prefix)) {
        var %name = $mid($prefix,%num,1)
        var %count = %::count [ $+ [ %name ] ]
        if (%count) {
          if (%name == @) %name = op $+ $chr(40) $+ s $+ $chr(41)
          elseif (%name == %) %name = halfop $+ $chr(40) $+ s $+ $chr(41)
          elseif (%name == +) %name = voice $+ $chr(40) $+ s $+ $chr(41)
          elseif (%name == .) %name = owner $+ $chr(40) $+ s $+ $chr(41)
          else %name = mode $+ %name
          %users = %users - $:t(%count) %name $:s($_p(%count,%::count))
        }
        inc %num
      }
      if (%::countreg) %users = %users - $:t(%::countreg) other $+ $chr(40) $+ s $+ $chr(41) $:s($_p(%::countreg,%::count))
      %:echo %::pre Nicks $+ %users
    }
  }
  else {
    %:echo %::pre No users on channel $+ $chr(44) or channel is secret/private %:comments
  }
}
alias _pnpnbs-irc.names353 {
  if (%::first) %:linesep
  ; Highlight op/voc/etc
  var %num = 1,%text = %::text
  while (%num <= $len($prefix)) {
    %text = $replace(%text,$mid($prefix,%num,1), $+ $mid($prefix,%num,1) $+ $left($:s,3))
    inc %num
  }
  %:echo %::pre Names- $:s(%text) %:comments
}
