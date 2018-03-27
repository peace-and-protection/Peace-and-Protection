; #= P&P -rs
; @======================================:
; |  Peace and Protection                |
; |  Theme editing and loading           |
; `======================================'

; Theme process-

; mirc settings + theme file
; theme file
; dialog

; --> TO -->
; hash table
; --> TO -->

; mirc settings
; theme file
; dialog

; /theme [#]
; Open theme dialog
; /theme load|save [[-bcdeflmnoprst] [scheme#] filename.ext]
; Load or save theme
; -o is for overwrite on save; other options are things to load/save
; -d (display) implies -ce (script/events); -i (info) is always implied
alias theme {
  if ($1 == load) {
    ; (not with dialog open)
    if ($dialog(pnp.mts)) { _recurse theme 16 | return }

    ; Cmd line error checking
    if (-* !iswm $2) tokenize 32 $1 -bcdeflmnprst $2-
    if ($3 !isnum) tokenize 32 $1-2 0 $3-
    if ($4 == $null) { _recurse theme 16 | return }

    ; Find file as *[.mts], themes\*[.mts], themes\*\*[.mts]
    if (!$isfile($4-)) {
      var %file = $replace($4-,/,\)
      if (*.* !iswm $nopath(%file)) %file = %file $+ .mts
      if ((!$isfile(%file)) && ($gettok($nofile(%file),-1,92) != themes)) %file = $nofile(%file) $+ themes\ $+ $nopath(%file)
      if ((!$isfile(%file)) && ($gettok($nofile(%file),-1,92) == themes)) %file = $nofile(%file) $+ $deltok($nopath(%file),-1,46) $+ \ $+ $nopath(%file)
      if (!$isfile(%file)) {
        disps Theme file ' $+ $4- $+ ' not found.
        halt
      }
      tokenize 32 $1-3 %file
    }

    ; Load current settings, then load theme over it
    theme.hash -m mts.load $_cfg(theme.mtp)
    ; (if errors loading current, just load entire theme)
    if ($result) tokenize 32 $1 -bcdeflmnprst $3-
    theme.hash -e $+ $iif($3 isnum,s $+ $3) +i $+ $remove($2,-) $+ $iif(d isin $2,ce) mts.load $4-
    if ($result) halt

    ; Confirm missing files    
    if ($theme.confirm(mts.load)) {
      hfree mts.load
      halt
    }

    ; Save theme as current theme
    var %file = $_cfg(theme.mtp)
    var %script = $_cfg(theme.mrc)
    .remove " $+ %file $+ "
    .remove " $+ %script $+ "
    theme.save -h mts.load %file

    ; Load theme into mIRC (don't load some things if we didn't load them)
    theme.apply mts.load hsvctoae $+ $iif(n isin $2,n) $+ $iif(m isin $2,m) $+ $iif(r isin $2,r) $+ $iif((f isin $2) || (b isin $2),f) $+ $iif(t isin $2,i) $_cfg(theme.ct)

    ; Cleanup
    hfree mts.load

    ; Done!
    disps Theme ' $+ $4- $+ ' loaded
  }
  elseif ($1 == save) {
    ; (not with dialog open)
    if ($dialog(pnp.mts)) { _recurse theme 17 | return }

    ; Cmd line error checking
    if (-* !iswm $2) tokenize 32 $1 -bdflmnprst $2-
    if ($3 == $null) { _recurse theme 17 | return }

    ; Add .mts if no extension, place in themes\* if no directory specified
    var %file = $replace($3-,/,\)
    if (*.* !iswm $nopath(%file)) %file = %file $+ .mts
    if ((\ !isin %file) && ($isdir(themes))) {
      .mkdir "themes\ $+ $gettok(%file,1,46) $+ "
      %file = themes\ $+ $gettok(%file,1,46) $+ \ $+ %file
    }

    ; Save current theme
    theme.save $iif(o isin $2,-eco,-ec) +i $+ $remove($2,-,o) $+ $iif(d isin $2,ce) pnp.theme %file
    if ($result) halt

    ; Done!
    disps Theme saved as ' $+ %file $+ '
  }
  elseif ($dialog(pnp.mts)) {
    dialog -v pnp.mts
    if (($1 isnum) && ($gettok($did(pnp.mts,501,$1),1,32) != $null)) {
      did -c pnp.mts 501 $1
      page.show $1
    }
  }
  else {
    set %.blank $mircdirscript\16.bmp
    set %.section $1
    if ($1 == $null) set -u %.section $_dlgi(themecentral)
    dialog -am pnp.mts pnp.mts
  }
}

; Other theme dialog portions- backwards compatibility
alias display { theme 3 }
alias ncedit { theme 4 }
alias line { theme 6 }
alias textsch { theme 8 }
alias soundcfg { theme 13 }

; Theme editing dialog
dialog pnp.mts {
  title "Theme Central"
  icon script\pnp.ico
  option dbu
  size -1 -1 210 169

  ; List of sections
  list 501, 5 5 50 140, size

  ; Whether a section has been loaded yet
  list 502, 1 1 1 1, hide

  ; Did we modify fonts or backgrounds? (to save time on the apply)
  edit "", 511, 1 1 1 1, autohs hide

  ; Original RGB values
  list 509, 1 1 1 1, hide

  ; Last section selected
  edit "", 503, 1 1 1 1, autohs hide

  ; 'Actions:' drop down
  combo 504, 5 151 50 70, drop

  button "OK", 505, 60 150 30 12, default group
  button "Cancel", 506, 95 150 30 12, cancel
  button "&Help", 507, 130 150 30 12, disable
  button "&Preview >>", 508, 165 150 40 12, disable

  ; Preview image
  icon 512, 215 5 100 140

  ; Generate preview button
  button "&Generate", 513, 245 150 40 12

  ; Hidden tabs to select areas
  tab "", 19, -25 -25 1 1, disable hide group
  tab "", 1, -25 -25 1 1, disable hide
  tab "", 2, -25 -25 1 1, disable hide
  tab "", 3, -25 -25 1 1, disable hide
  tab "", 4, -25 -25 1 1, disable hide
  tab "", 5, -25 -25 1 1, disable hide
  tab "", 6, -25 -25 1 1, disable hide
  tab "", 8, -25 -25 1 1, disable hide
  tab "", 10, -25 -25 1 1, disable hide
  tab "", 11, -25 -25 1 1, disable hide
  tab "", 12, -25 -25 1 1, disable hide
  tab "", 13, -25 -25 1 1, disable hide
  tab "", 15, -25 -25 1 1, disable hide
  tab "", 16, -25 -25 1 1, disable hide
  tab "", 17, -25 -25 1 1, disable hide

  ; Text to show on tab 19
  text "", 510, 65 70 140 40, center tab 19  

  ; mIRC Colors
  text "Action text:", 20, 60 7 55 10, right tab 1
  text "CTCP text:", 21, 60 17 55 10, right tab 1
  text "Highlight text:", 22, 60 27 55 10, right tab 1
  text "Info text:", 23, 60 37 55 10, right tab 1
  text "Info2 text:", 24, 60 47 55 10, right tab 1
  text "Invite text:", 25, 60 57 55 10, right tab 1
  text "Join text:", 26, 60 67 55 10, right tab 1
  text "Kick text:", 27, 60 77 55 10, right tab 1
  text "Mode text:", 28, 60 87 55 10, right tab 1
  text "Nick text:", 29, 60 97 55 10, right tab 1
  text "Normal text:", 30, 130 7 55 10, right tab 1
  text "Notice text:", 31, 130 17 55 10, right tab 1
  text "Notify text:", 32, 130 27 55 10, right tab 1
  text "Other text:", 33, 130 37 55 10, right tab 1
  text "Own text:", 34, 130 47 55 10, right tab 1
  text "Part text:", 35, 130 57 55 10, right tab 1
  text "Quit text:", 36, 130 67 55 10, right tab 1
  text "Topic text:", 37, 130 77 55 10, right tab 1
  text "Wallops text:", 38, 130 87 55 10, right tab 1
  text "Whois text:", 39, 130 97 55 10, right tab 1
  text "Background:", 40, 60 112 55 10, right tab 1
  text "Editbox text:", 41, 60 127 55 10, right tab 1
  text "Editbox background:", 42, 60 137 55 10, right tab 1
  text "Grayed text:", 43, 130 112 55 10, right tab 1
  text "Listbox text:", 44, 130 127 55 10, right tab 1
  text "Listbox background:", 45, 130 137 55 10, right tab 1

  icon 47, 119 7 8 8, %.blank, tab 1
  icon 48, 119 17 8 8, %.blank, tab 1
  icon 49, 119 27 8 8, %.blank, tab 1
  icon 50, 119 37 8 8, %.blank, tab 1
  icon 51, 119 47 8 8, %.blank, tab 1
  icon 52, 119 57 8 8, %.blank, tab 1
  icon 53, 119 67 8 8, %.blank, tab 1
  icon 54, 119 77 8 8, %.blank, tab 1
  icon 55, 119 87 8 8, %.blank, tab 1
  icon 56, 119 97 8 8, %.blank, tab 1
  icon 57, 189 7 8 8, %.blank, tab 1
  icon 58, 189 17 8 8, %.blank, tab 1
  icon 59, 189 27 8 8, %.blank, tab 1
  icon 60, 189 37 8 8, %.blank, tab 1
  icon 61, 189 47 8 8, %.blank, tab 1
  icon 62, 189 57 8 8, %.blank, tab 1
  icon 63, 189 67 8 8, %.blank, tab 1
  icon 64, 189 77 8 8, %.blank, tab 1
  icon 65, 189 87 8 8, %.blank, tab 1
  icon 66, 189 97 8 8, %.blank, tab 1
  icon 46, 119 112 8 8, %.blank, tab 1
  icon 68, 119 127 8 8, %.blank, tab 1
  icon 67, 119 137 8 8, %.blank, tab 1
  icon 71, 189 112 8 8, %.blank, tab 1
  icon 70, 189 127 8 8, %.blank, tab 1
  icon 69, 189 137 8 8, %.blank, tab 1

  ; RGB Settings
  ;!!
  text "Sorry, this section is not currently available. You can edit RGB colors in mIRC's color dialog. (Alt+K)", 600, 65 70 140 40, center tab 2

  ; PnP Colors
  text "Text color:", 80, 65 40 80 10, right tab 3
  text "Target color:", 81, 65 52 80 10, right tab 3
  text "Text highlight color:", 82, 65 64 80 10, right tab 3
  text "Bracket color:", 83, 65 76 80 10, right tab 3
  text "Alert/error color:", 84, 65 88 80 10, right tab 3
  icon 85, 150 39 8 8, %.blank, tab 3
  icon 86, 150 51 8 8, %.blank, tab 3
  icon 87, 150 63 8 8, %.blank, tab 3
  icon 88, 150 75 8 8, %.blank, tab 3
  icon 89, 150 87 8 8, %.blank, tab 3

  ; Nicklist Colors
  text "Normal:", 90, 62 27 42 10, right tab 4
  text "Notify / Userlist:", 91, 62 38 42 10, right tab 4
  text "Failed notify:", 92, 62 49 42 10, right tab 4
  text "Blacklist / Ignore:", 93, 62 60 42 10, right tab 4
  text "IRCop:", 94, 62 71 42 10, right tab 4
  text "Yourself:", 95, 62 82 42 10, right tab 4
  text "Lagged:", 96, 62 93 42 10, right tab 4
  text "Being pinged:", 97, 62 104 42 10, right tab 4
  text "None:", 98, 109 16 20 8, center tab 4
  text "Voice:", 99, 131 16 20 8, center tab 4
  text "Half:", 100, 153 16 20 8, center tab 4
  text "Op:", 101, 175 16 20 8, center tab 4

  icon 102, 115 26 8 8, %.blank, tab 4
  icon 103, 137 26 8 8, %.blank, tab 4
  icon 104, 159 26 8 8, %.blank, tab 4
  icon 105, 181 26 8 8, %.blank, tab 4
  icon 106, 115 37 8 8, %.blank, tab 4
  icon 107, 137 37 8 8, %.blank, tab 4
  icon 108, 159 37 8 8, %.blank, tab 4
  icon 109, 181 37 8 8, %.blank, tab 4
  icon 110, 115 48 8 8, %.blank, tab 4
  icon 111, 137 48 8 8, %.blank, tab 4
  icon 112, 159 48 8 8, %.blank, tab 4
  icon 113, 181 48 8 8, %.blank, tab 4
  icon 114, 115 59 8 8, %.blank, tab 4
  icon 115, 137 59 8 8, %.blank, tab 4
  icon 116, 159 59 8 8, %.blank, tab 4
  icon 117, 181 59 8 8, %.blank, tab 4
  icon 118, 115 70 8 8, %.blank, tab 4
  icon 119, 137 70 8 8, %.blank, tab 4
  icon 120, 159 70 8 8, %.blank, tab 4
  icon 121, 181 70 8 8, %.blank, tab 4
  icon 122, 115 81 8 8, %.blank, tab 4
  icon 123, 137 81 8 8, %.blank, tab 4
  icon 124, 159 81 8 8, %.blank, tab 4
  icon 125, 181 81 8 8, %.blank, tab 4
  icon 126, 115 92 8 8, %.blank, tab 4
  icon 127, 137 92 8 8, %.blank, tab 4
  icon 128, 159 92 8 8, %.blank, tab 4
  icon 129, 181 92 8 8, %.blank, tab 4
  icon 130, 115 103 8 8, %.blank, tab 4
  icon 131, 137 103 8 8, %.blank, tab 4
  icon 132, 159 103 8 8, %.blank, tab 4
  icon 133, 181 103 8 8, %.blank, tab 4

  ; Display
  text "&Bold characters:", 161, 67 24 55 10, right tab 5
  edit "", 164, 123 22 25 11, autohs tab 5 group
  edit "", 165, 149 22 25 11, autohs tab 5
  text "&Line prefix:", 162, 67 40 55 10, right tab 5
  edit "", 166, 123 38 51 11, autohs tab 5
  text "&Parenthesis'd text:", 171, 67 56 55 10, right tab 5
  edit "", 172, 123 54 51 11, autohs tab 5
  check "&Enable timestamp:", 167, 67 70 55 10, tab 5
  edit "", 168, 123 70 51 11, autohs tab 5
  check "&Lowercase channel names", 169, 67 84 140 10, tab 5
  check "&Show separators around /whois", 170, 67 96 140 10, tab 5

  ; Line Separator
  radio "&Color-based separator:", 230, 61 12 140 8, tab 6 group
  radio "&Custom line separator:", 231, 61 80 140 8, tab 6
  radio "&No line separator", 232, 61 124 140 8, tab 6
  box "", 233, 71 22 115 50, tab 6
  box "", 234, 71 91 115 25, tab 6

  icon 235, 80 32 8 8, %.blank, tab 6
  icon 236, 90 32 8 8, %.blank, tab 6
  icon 237, 100 32 8 8, %.blank, tab 6
  icon 238, 110 32 8 8, %.blank, tab 6
  icon 239, 120 32 8 8, %.blank, tab 6
  icon 240, 130 32 8 8, %.blank, tab 6
  icon 241, 140 32 8 8, %.blank, tab 6
  icon 242, 150 32 8 8, %.blank, tab 6
  icon 243, 160 32 8 8, %.blank, tab 6
  icon 244, 170 32 8 8, %.blank, tab 6
  icon 245, 80 42 8 8, %.blank, tab 6
  icon 246, 90 42 8 8, %.blank, tab 6
  icon 247, 100 42 8 8, %.blank, tab 6
  icon 248, 110 42 8 8, %.blank, tab 6
  icon 249, 120 42 8 8, %.blank, tab 6
  icon 250, 130 42 8 8, %.blank, tab 6
  icon 251, 140 42 8 8, %.blank, tab 6
  icon 252, 150 42 8 8, %.blank, tab 6
  icon 253, 160 42 8 8, %.blank, tab 6
  icon 254, 170 42 8 8, %.blank, tab 6

  text "&Char:", 255, 75 58 24 10, right tab 6
  edit "", 256, 100 56 25 11, tab 6 group
  text "&Length:", 257, 128 58 24 10, right tab 6
  edit "", 258, 153 56 25 11, tab 6
  edit "", 259, 80 100 98 11, autohs tab 6

  ; Text theme
  radio "&Edit theme lines", 300, 61 6 50 12, push tab 8 group
  radio "&Edit script", 301, 114 6 50 12, push tab 8
  edit "", 302, 60 20 140 125, multi return hsbar vsbar tab 8 group
  edit "", 303, 60 20 140 125, multi return hsbar vsbar tab 8 group hide

  ; Fonts
  text "&Status font:", 310, 62 20 50 10, right tab 10
  edit "", 315, 113 18 65 11, read autohs tab 10 group
  button "&Select", 320, 181 18 24 11, tab 10 group
  text "&Channel font:", 311, 62 34 50 10, right tab 10
  edit "", 316, 113 32 65 11, read autohs tab 10
  button "&Select", 321, 181 32 24 11, tab 10
  text "&Query/chat font:", 312, 62 48 50 10, right tab 10
  edit "", 317, 113 46 65 11, read autohs tab 10
  button "&Select", 322, 181 46 24 11, tab 10
  text "&Send/get font:", 313, 62 62 50 10, right tab 10
  edit "", 318, 113 60 65 11, read autohs tab 10
  button "&Select", 323, 181 60 24 11, tab 10
  text "&Script window font:", 314, 62 76 50 10, right tab 10
  edit "", 319, 113 74 65 11, read autohs tab 10
  button "&Select", 324, 181 74 24 11, tab 10

  ; Backgrounds
  text "&mIRC background:", 330, 62 10 50 10, right tab 11
  edit "", 331, 113 8 65 11, read autohs tab 11 group
  button "&Select", 332, 181 8 24 11, tab 11
  combo 333, 113 21 65 100, drop tab 11
  button "&None", 334, 181 21 24 11, tab 11
  text "&Status bkg.:", 335, 62 38 50 10, right tab 11
  edit "", 336, 113 36 65 11, read autohs tab 11
  button "&Select", 337, 181 36 24 11, tab 11
  combo 338, 113 49 65 100, drop tab 11
  button "&None", 339, 181 49 24 11, tab 11
  text "&Channel bkg.:", 340, 62 66 50 10, right tab 11
  edit "", 341, 113 64 65 11, read autohs tab 11
  button "&Select", 342, 181 64 24 11, tab 11
  combo 343, 113 77 65 100, drop tab 11
  button "&None", 344, 181 77 24 11, tab 11
  text "&Query/chat bkg.:", 345, 62 94 50 10, right tab 11
  edit "", 346, 113 92 65 11, read autohs tab 11
  button "&Select", 347, 181 92 24 11, tab 11
  combo 348, 113 105 65 100, drop tab 11
  button "&None", 349, 181 105 24 11, tab 11
  text "&Script win. bkg.:", 350, 62 122 50 10, right tab 11
  edit "", 351, 113 120 65 11, read autohs tab 11
  button "&Select", 352, 181 120 24 11, tab 11
  combo 353, 113 133 65 100, drop tab 11
  button "&None", 354, 181 133 24 11, tab 11

  ; Toolbars
  text "&Toolbar icons:", 360, 62 30 50 10, right tab 12
  edit "", 361, 113 28 65 11, read autohs tab 12 group
  button "&Select", 362, 181 28 24 11, tab 12
  button "&None", 364, 181 41 24 11, tab 12
  text "&Toolbar bkg.:", 365, 62 61 50 10, right tab 12
  edit "", 366, 113 59 65 11, read autohs tab 12
  button "&Select", 367, 181 59 24 11, tab 12
  button "&None", 369, 181 72 24 11, tab 12
  text "&Switchbar bkg.:", 370, 62 92 50 10, right tab 12
  edit "", 371, 113 90 65 11, read autohs tab 12
  button "&Select", 372, 181 90 24 11, tab 12
  button "&None", 374, 181 103 24 11, tab 12

  ; Event Sounds
  text "&Editing", 401, 62 14 31 10, right tab 13
  combo 402, 95 12 60 85, drop tab 13 group
  text "event sounds:", 403, 157 14 50 10, tab 13
  ; (currently viewed sounds- Item (sound) format)
  list 404, 62 25 145 55, tab 13
  text "", 406, 65 75 75 7, tab 13
  text "", 407, 65 82 35 7, tab 13
  text "", 408, 102 82 105 7, tab 13
  button "&Select...", 409, 65 92 42 12, tab 13 group
  button "&Preview", 410, 112 92 42 12, tab 13
  button "&Clear", 411, 160 92 42 12, tab 13
  button "&Clear all", 412, 65 110 42 12, tab 13
  button "&Copy", 413, 112 110 42 12, tab 13
  button "&Paste", 414, 160 110 42 12, tab 13
  ; (all sounds in current theme- Item File format)
  list 415, 62 25 145 55, hide
  ; (all items currenetly viewed, same order as 404- just Item names)
  list 416, 62 25 145 55, hide

  ; Theme Info
  text "&Theme name:", 420, 62 20 50 10, right tab 15
  edit "", 426, 113 18 90 11, autohs tab 15 group
  text "&Version:", 421, 62 34 50 10, right tab 15
  edit "", 427, 113 32 90 11, autohs tab 15
  text "&Author:", 422, 62 48 50 10, right tab 15
  edit "", 428, 113 46 90 11, autohs tab 15
  text "&E-Mail:", 423, 62 62 50 10, right tab 15
  edit "", 429, 113 60 90 11, autohs tab 15
  text "&Homepage:", 424, 62 76 50 10, right tab 15
  edit "", 430, 113 74 90 11, autohs tab 15
  text "&Description:", 425, 62 90 50 10, right tab 15
  edit "", 431, 113 88 90 30, multi vsbar tab 15

  ; Save Theme
  text "Which elements do you wish to include?", 440, 68 10 140 10, tab 17
  check "&mIRC colors", 441, 75 20 64 8, tab 17 group
  check "&RGB settings", 442, 75 29 64 8, tab 17
  check "&PnP colors", 443, 75 38 64 8, tab 17
  check "&Nicklist colors", 444, 75 47 64 8, tab 17
  check "&Line separator", 445, 75 56 64 8, tab 17
  check "&Text theme / Display", 446, 140 20 65 8, tab 17
  check "&Font settings", 447, 140 29 65 8, tab 17
  check "&Backgrounds", 448, 140 38 65 8, tab 17
  check "&Toolbars", 449, 140 47 65 8, tab 17
  check "&Event sounds", 450, 140 56 65 8, tab 17
  box "&Filename", 451, 65 69 127 55, tab 17
  edit "", 452, 74 78 110 11, autohs tab 17 group
  text "Enter a filename, without extension, to save your theme as. This will be used for the subdirectory name, the theme file, and any script file.", 453, 72 92 110 28, tab 17
  button "&Save theme", 454, 100 130 50 12, tab 17 group

  ; Load Theme
  box "Select theme:", 460, 60 5 145 55, tab 16
  list 461, 65 15 135 50, sort group tab 16
  ; (theme filenames)
  list 474, 1 1 1 1, hide
  text "&Scheme:", 475, 59 65 30 20, right tab 16
  combo 476, 91 63 108 100, group drop tab 16
  box "", 462, 60 74 145 71, tab 16

  check "&mIRC colors", 463, 65 81 65 8, group tab 16
  check "&RGB settings", 464, 65 90 65 8, tab 16
  check "&PnP colors", 465, 65 99 65 8, tab 16
  check "&Nicklist colors", 466, 65 108 65 8, tab 16
  check "&Line separator", 467, 65 117 65 8, tab 16
  check "&Text theme / Display", 469, 135 81 65 8, tab 16
  check "&Font settings", 470, 135 90 65 8, tab 16
  check "&Backgrounds", 471, 135 99 65 8, tab 16
  check "&Toolbars", 472, 135 108 65 8, tab 16
  check "&Event sounds", 473, 135 117 65 8, tab 16

  button "&Delete theme...", 477, 65 128 65 12, group tab 16
  button "&Load theme", 478, 135 128 65 12, group tab 16
}

; Dialog init
on *:DIALOG:pnp.mts:init:*:{
  ; preload current theme into hash, including mIRC settings
  theme.hash -m mts.edit $_cfg(theme.mtp)

  ; error loading? load blank theme file.
  if ($result) theme.hash -m mts.edit script\blankpnp.mtp

  ; save current RGBs (don't need to load those from the theme as they match existing)
  var %col = 0
  while (%col <= 15) {
    did -a pnp.mts 509 $color(%col)
    inc %col
  }

  ; color icon stuff
  _cs-prep $dname

  ; prep combos/lists
  loadbuf -ottheme $dname 501 "script\dlgtext.dat"
  var %num = 17
  ; (mark all sections as un-viewed)
  while (%num > 0) {
    did -a $dname 502 0
    dec %num
  }
  ; (background style combos)
  %num = 333
  while (%num <= 353) {
    loadbuf -otbkstyle $dname %num "script\dlgtext.dat"
    inc %num 5
  }
  ; (sound categories)
  loadbuf -otsoundcat $dname 402 "script\dlgtext.dat"
  ; (mirc bk doesn't have 'photo' style)
  did -d $dname 333 6

  ;  show first or selected section of dialog
  if ((%.section !isnum) || ($gettok($did(501,%.section),1,32) == $null)) %.section = 1
  did -c $dname 501 %.section
  page.show %.section
  ;!! Need a timer for this at this time
  .timer -mio 1 0 did -c pnp.mts %.section $chr(124) did -f pnp.mts 501

  unset %.section %.blank
}

; Select new section, unless a 'blank' section was selected
on *:DIALOG:pnp.mts:sclick:501:{
  if ($gettok($did(501).seltext,1,32) == $null) did -c $dname 501 $did(503)
  else page.show $did(501).sel
}

; Close dialog
on *:DIALOG:pnp.mts:sclick:505:{
  ; (no need to reset rgb settings as they are being applied anyways)

  ; Apply all modified pages to hash
  var %num = 17
  while (%num > 0) {
    if ($did(502,%num) == 1) page.apply %num
    dec %num
  }

  ; Check theme for missing files/fonts
  did -c pnp.mts 19
  did -ra pnp.mts 510 Applying theme $+ $chr(44) please wait...
  if ($theme.confirm(mts.edit)) {
    did -c pnp.mts $did(503)
    did -r pnp.mts 510
    halt
  }

  ; Save theme as current theme
  var %file = $_cfg(theme.mtp)
  var %script = $_cfg(theme.mrc)
  .remove " $+ %file $+ "
  .remove " $+ %script $+ "
  theme.save -h mts.edit %file

  ; Load theme into mIRC
  theme.apply mts.edit $iif($did(511),hsvctomraefin,hsvctomraein) $_cfg(theme.ct)

  ; Cleanup
  _dlgw themecentral $did(503)
  hfree mts.edit
  _cs-fin $dname
  dialog -x pnp.mts
}

; Cancel- cleanup
on *:DIALOG:pnp.mts:sclick:506:{
  ; load original RGBs
  var %col = 0
  while (%col <= 15) {
    if ($did(pnp.mts,509,$calc(%col + 1)) != $color(%col)) color %col $ifmatch
    inc %col
  }

  _dlgw themecentral $did(503)
  hfree mts.edit
  _cs-fin $dname
}

; If tabs are 'clicked', undo any changes
on *:DIALOG:pnp.mts:sclick:1,2,3,4,5,6,8,10,11,12,13,15,16,17:{
  did -f pnp.mts 501
  did -c pnp.mts $did(503)
}

; 'Actions:' drop down
on *:DIALOG:pnp.mts:sclick:504:{
  ; Determine option, return to top selection
  var %sel = $did(504).sel
  if (%sel == 1) return
  did -c pnp.mts 504 1

  ; Act
  page.action $did(503) %sel
}

; Enable/disable actions
on *:DIALOG:pnp.mts:sclick:167:{ did $iif($did(167).state,-e,-b) pnp.mts 168 }
on *:DIALOG:pnp.mts:sclick:230:{ did -e pnp.mts 256,258 | did -b pnp.mts 259 }
on *:DIALOG:pnp.mts:sclick:231:{ did -e pnp.mts 259 | did -b pnp.mts 256,258 }
on *:DIALOG:pnp.mts:sclick:232:{ did -b pnp.mts 256,258,259 }
on *:DIALOG:pnp.mts:sclick:300:{ did -v pnp.mts 302 | did -h pnp.mts 303 }
on *:DIALOG:pnp.mts:sclick:301:{ did -v pnp.mts 303 | did -h pnp.mts 302 }

; 'Pick' fonts
on *:DIALOG:pnp.mts:sclick:320,321,322,323,324:{ _juryrig select.font $did }
alias select.font {
  if ($_pickfont($did(pnp.mts,$calc($1 - 5)))) did -ra pnp.mts $calc($1 - 5) $ifmatch
  dialog -v pnp.mts
}

; 'Pick' backgrounds
on *:DIALOG:pnp.mts:sclick:332,337,342,347,352,362,367,372:{
  ; Determine where to look
  var %dir,%old = $did($calc($did - 1))
  if ($isfile(%old)) %dir = %old
  elseif ($isdir($nofile(%old))) %dir = $nofile(%old)
  elseif ($_dlgi(imagedir)) %dir = $ifmatch
  else %dir = $mircdir

  ; Add filemask unless image already selected
  if (%dir != %old) %dir = %dir $+ *.bmp;*.png;*.jpg

  ; Select file, enable style combo if any
  _ssplay Question
  var %file = $$sfile(%dir,Select background)
  _dlgw imagedir $nofile(%file)
  did -ra pnp.mts $calc($did - 1) %file
  if ($did isnum 332-352) did -e pnp.mts $calc($did + 1)
}

; 'None' backgrounds
on *:DIALOG:pnp.mts:sclick:334,339,344,349,354,364,369,374:{
  did -r pnp.mts $calc($did - 3)
  if ($did isnum 334-354) did -b pnp.mts $calc($did - 1)
}

; Sounds section events
on *:DIALOG:pnp.mts:sclick:410:{ splay $$curr.sound }
on *:DIALOG:pnp.mts:sclick:411:{ store.sound $$curr.item }
on *:DIALOG:pnp.mts:sclick:412:{
  theme.clear mts.edit sounds
  page.init 13
}
on *:DIALOG:pnp.mts:sclick:413:{ clipboard $$curr.sound }
on *:DIALOG:pnp.mts:sclick:414:{ if ($isfile($cb)) store.sound $$curr.item $cb }
on *:DIALOG:pnp.mts:sclick:402:{ page.sound $did(402,1).sel }
on *:DIALOG:pnp.mts:dclick:404:{ select.sound }
on *:DIALOG:pnp.mts:sclick:409:{ select.sound }
alias -l select.sound {
  var %old = $curr.sound

  ; Determine where to look
  var %dir
  if ($isfile(%old)) %dir = %old
  elseif ($isdir($nofile(%old))) %dir = $nofile(%old)
  elseif ($_dlgi(sounddir)) %dir = $ifmatch
  elseif ($wavedir) %dir = $wavedir
  else %dir = $mircdir

  ; Add filemask unless image already selected
  if (%dir != %old) %dir = %dir $+ *.wav;*.mid;*.mp3;*.ogg;*.wma

  ; Select file
  _ssplay Question
  var %file = $$sfile(%dir,Select sound)
  _dlgw sounddir $nofile(%file)

  ; Save to both lists
  store.sound $curr.item %file
}
; /store.sound item [filename]
alias -l store.sound {
  var %line = $didwm(pnp.mts,416,$1,1)
  if ($didwm(pnp.mts,415,Snd $+ $1 *,1)) did -d pnp.mts 415 $ifmatch
  if ($2-) did -a pnp.mts 415 Snd $+ $1 $2-
  did -oc pnp.mts 404 %line $gettok($did(pnp.mts,404,%line),1,40) $iif($2-,( $+ $2- $+ ))
  update.sound
}
; Updates -b/-e on sound buttons to match current selection
on *:DIALOG:pnp.mts:sclick:404:{ update.sound }
alias -l update.sound {
  did $iif($curr.sound,-e,-b) pnp.mts 410,411,413
}
; Returns currently selected item, if any
alias -l curr.item {
  return $did(pnp.mts,416,$did(pnp.mts,404,1).sel)
}
; Returns sound of currently selected item, if any
alias -l curr.sound {
  return $gettok($did(pnp.mts,415,$didwm(pnp.mts,415,Snd $+ $curr.item *,1)),2-,32)
}

; Save Theme area events
on *:DIALOG:pnp.mts:sclick:454:{
  page.waiting 17 Saving theme $+ $chr(44) please wait...

  ; Apply all modified pages to hash; mark as unmodified
  var %num = 17
  while (%num > 0) {
    if ($did(pnp.mts,502,%num) == 1) page.apply %num
    did -o pnp.mts 502 %num 0
    dec %num
  }

  ; Filename
  var %file = $did(pnp.mts,452)
  if (%file == $null) _error Please enter a filename to save.Do not enter an extension.
  if (. isin %file) _error Please enter a filename without an extension.Extensions will be automatically added.
  if ((/ isin %file) || (\ isin %file)) _error Please enter a filename without a path.Files will be saved to subdirs of the THEMES folder.
  %file = $mkfn(%file)

  ; What to save
  var %flags = +
  if ($did(pnp.mts,448).state) %flags = %flags $+ b
  if ($did(pnp.mts,446).state) %flags = %flags $+ cde
  if ($did(pnp.mts,447).state) %flags = %flags $+ f
  %flags = %flags $+ i
  if ($did(pnp.mts,445).state) %flags = %flags $+ l
  if ($did(pnp.mts,441).state) %flags = %flags $+ m
  if ($did(pnp.mts,444).state) %flags = %flags $+ n
  if ($did(pnp.mts,443).state) %flags = %flags $+ p
  if ($did(pnp.mts,442).state) %flags = %flags $+ r
  if ($did(pnp.mts,450).state) %flags = %flags $+ s
  if ($did(pnp.mts,449).state) %flags = %flags $+ t
  if (%flags == +i) _error You have not selected anything to save.Check one or more options to save.

  ; Make sure directory exists
  .mkdir "THEMES"
  .mkdir "THEMES\ $+ %file $+ "

  ; Check if this file exists
  %file = $mircdir $+ THEMES\ $+ %file $+ \ $+ %file $+ .mts
  if ($exists(%file)) _error File ' $+ $nopath(%file) $+ ' already exists.You must delete the existing theme before saving.

  ; Save
  theme.save -c %flags mts.edit %file
  if ($result) _error Error saving theme ' $+ $nopath(%file) $+ ' $+  $+ $result
}

; Load Theme area events
on *:DIALOG:pnp.mts:sclick:461:{
  ; Theme selected- fill schemes list
  ; Name
  var %name = $did(pnp.mts,461).seltext
  ; Filename
  var %file = $right($gettok($did(pnp.mts,474,$didwm(pnp.mts,474,%name $+ $chr(160) $+ !*,1)),2-,160),-1)
  did -r pnp.mts 476
  ; Check theme file for schemes
  var %num = 1
  var %mts = $theme.issec(%file,mts)
  while (%mts) {
    var %scheme = $read(%file,nw,Scheme $+ %num *,%mts)
    if ((%scheme) && ($theme.issec(%file,scheme $+ %num))) {
      did -a pnp.mts 476 %num $+ . $gettok(%scheme,2-,32)
      inc %num
    }
    else break
  }
  if (%num > 1) did -ic pnp.mts 476 1 0. (don't load scheme)
  did $iif(%num > 1,-e,-b) pnp.mts 476
  ; Enable buttons
  did -e pnp.mts 477,478,513
}
on *:DIALOG:pnp.mts:sclick:477:{
  ; Name
  var %nameline = $did(pnp.mts,461,1).sel
  var %name = $did(pnp.mts,461).seltext
  ; Filename
  var %line = $didwm(pnp.mts,474,%name $+ $chr(160) $+ !*,1)
  var %file = $right($gettok($did(pnp.mts,474,%line),2-,160),-1)
  _okcancel 1 Delete ' $+ %file $+ ' and any associated files?
  ; Delete
  theme.delete %file
  ; Remove from lists; disable combo and buttons
  did -d pnp.mts 461 %nameline
  did -d pnp.mts 474 %line
  did -r pnp.mts 476
  did -b pnp.mts 476,477,478,513
}
on *:DIALOG:pnp.mts:dclick:461:{ page.themeload }
on *:DIALOG:pnp.mts:sclick:478:{ page.themeload }
alias -l page.themeload {
  page.waiting 16 Loading theme $+ $chr(44) please wait...

  ; Name
  var %nameline = $did(pnp.mts,461,1).sel
  var %name = $did(pnp.mts,461).seltext
  ; Filename
  var %line = $didwm(pnp.mts,474,%name $+ $chr(160) $+ !*,1)
  var %file = $right($gettok($did(pnp.mts,474,%line),2-,160),-1)

  ; Apply all modified pages to hash; mark as unmodified
  var %num = 17
  while (%num > 0) {
    if ($did(pnp.mts,502,%num) == 1) page.apply %num
    did -o pnp.mts 502 %num 0
    dec %num
  }

  ; (modified fonts/bkgs)
  did -ra pnp.mts 511 1

  ; Scheme?
  var %scheme = $gettok($did(pnp.mts,476).seltext,1,46)
  if (%scheme != $null) %scheme = -s $+ %scheme

  ; What to load
  var %flags = +
  if ($did(pnp.mts,471).state) %flags = %flags $+ b
  if ($did(pnp.mts,469).state) %flags = %flags $+ cde
  if ($did(pnp.mts,470).state) %flags = %flags $+ f
  %flags = %flags $+ i
  if ($did(pnp.mts,467).state) %flags = %flags $+ l
  if ($did(pnp.mts,463).state) %flags = %flags $+ m
  if ($did(pnp.mts,466).state) %flags = %flags $+ n
  if ($did(pnp.mts,465).state) %flags = %flags $+ p
  if ($did(pnp.mts,464).state) %flags = %flags $+ r
  if ($did(pnp.mts,473).state) %flags = %flags $+ s
  if ($did(pnp.mts,472).state) %flags = %flags $+ t
  if (%flags == +i) _error You have not selected anything to load.Check one or more options to load.

  ; Load theme
  theme.hash %scheme %flags mts.edit %file

  if ($result) _error Error loading theme ' $+ %file $+ ' $+  $+ $result

  ; Load RGBs from the theme
  var %col = 0,%rgbs = $hget(mts.edit,RGBColors)
  while (%col <= 15) {
    if ($rgb( [ $gettok(%rgbs,$calc(%col + 1),32) ] ) != $color(%col)) color %col $ifmatch
    inc %col
  }

  ; new color icons
  _cs-prep $dname

  ; Warning?
  if (%.warning) _doerror Warning- Theme contained errors $+ %.warning
}

; Preview button
on *:DIALOG:pnp.mts:sclick:508:{
  if ($gettok($did(508),-1,32) == >>) {
    did -ra pnp.mts 508 Preview <<
    dialog -bs pnp.mts -1 -1 320 169
  }
  else {
    did -ra pnp.mts 508 Preview >>
    dialog -bs pnp.mts -1 -1 210 169
  }
}

; Generate preview
on *:DIALOG:pnp.mts:sclick:513:{
  page.waiting 16 Generating preview $+ $chr(44) please wait...

  ; Save current RGBs
  var %col = 0,%rgbs
  while (%col <= 15) {
    %rgbs = $instok(%rgbs,$color(%col),0,44)
    inc %col
  }

  ; Name
  var %nameline = $did(pnp.mts,461,1).sel
  var %name = $did(pnp.mts,461).seltext
  ; Filename
  var %line = $didwm(pnp.mts,474,%name $+ $chr(160) $+ !*,1)
  var %file = $right($gettok($did(pnp.mts,474,%line),2-,160),-1)

  ; Scheme?
  var %scheme = $gettok($did(pnp.mts,476).seltext,1,46)
  if (%scheme != $null) %scheme = -s $+ %scheme

  ; Load theme into hash
  theme.hash %scheme mts.preview %file
  if ($result) _error Error loading theme ' $+ %file $+ ' $+  $+ $result

  ; Determine script file
  var %script = $hget(mts.preview,Script)
  if (%script) {
    %script = $theme.ff($hget(mts.preview,Filename),%script)
    if (%script) .reload -rs $+ $calc($script(0) - 2) " $+ $ifmatch $+ "
  }
  else %script =

  ; Temporarily apply theme
  theme.apply mts.preview hvctra 0 preview %script
  var %oldbk = $color(back)
  if (%oldbk != $gettok($hget(mts.preview,Colors),1,44)) color background $ifmatch
  .enable #previewecho

  ; Grab certain settings
  %.colors = $hget(pnp.preview.theme,Colors)
  var %font = $hget(pnp.preview.theme,FontChan)
  %.fontname = $gettok(%font,1,44)
  %.fontsize = $gettok(%font,2,44)
  %.ypos = 3

  ; Create preview image
  window -pfhn +d @.mtsprev -1 -1 200 280
  drawrect -fn @.mtsprev $gettok(%.colors,1,44) 2 0 0 200 280

  ; Prep variables
  %::timestamp = $timestamp
  %::me = pai
  %::server = pai.undernet.net
  %::fromserver = pai.undernet.net
  %::port = 6667
  %::chan = #pnp
  %::target = #pnp
  %:linesep = theme.previewlinesep

  ; My join
  %::nick = pai
  %::address = pai@pairc.com
  %:echo = theme.previewecho $gettok(%.colors,8,44)
  theme.test JoinSelf
  if ($hget(pnp.preview.events,JoinSelfLineSep)) %:linesep
  %::nick = OpGuy
  theme.testraw 332 This is a topic
  %::value = $calc($ctime - 86400)
  theme.testraw 333 %::value
  theme.testraw 353 pai @OpGuy
  %::count = 2
  %::countreg = 1
  %::count@ = 1
  theme.testraw 366 End of /NAMES list.
  theme.testraw 366uc End of /NAMES list.
  if ($hget(pnp.preview.events,Raw366LineSep)) %:linesep

  ; Talking
  %::nick = pai
  %::address = pai@pairc.com
  %::text = Hello everyone
  %:echo = theme.previewecho $gettok(%.colors,12,44)
  ; Nickcolor- myself, not opped
  _nickcol.2 $gettok($hget(pnp.preview.theme,PnPNickColors),1,44) $me
  %::cnick = $result
  theme.test TextChan

  ; Being opped
  %::modes = +o pai
  %::nick = OpGuy
  %::address = opguy@pairc.com
  %:echo = theme.previewecho $gettok(%.colors,10,44)
  theme.test Mode

  ; Two more texts
  %::nick = pai
  %::address = pai@pairc.com
  %::text = Thanks
  %:echo = theme.previewecho $gettok(%.colors,12,44)
  ; Nickcolor- myself, opped
  _nickcol.2 $gettok($hget(pnp.preview.theme,PnPNickColors),4,44) $me
  %::cnick = $result
  %::cmode = @
  theme.test TextChan
  ; Nickcolor- other person, opped
  %::nick = OpGuy
  %::address = opguy@pairc.com
  %::text = No problem
  _nickcol.2 $gettok($hget(pnp.preview.theme,PnPNickColors),4,44) OpGuy
  %::cnick = $result
  theme.test TextChan

  ; Part
  %::text = see ya
  %:echo = theme.previewecho $gettok(%.colors,17,44)
  theme.test Part p

  ; Whois
  %:echo = theme.previewecho $gettok(%.colors,21,44)
  %::realname = I Like Ops
  %::isoper = is not
  %::isregd = is not
  %::chan = #alpha @#beta
  %::barechan = #alpha #beta
  %::wserver = pai.undernet.net
  %::serverinfo = pai's Undernet server
  %::target = OpGuy
  %::text =
  if ($hget(pnp.preview.theme,LineSepWhois)) %:linesep
  %::numeric = 311
  theme.test RAW.311
  %::numeric = 319
  theme.test RAW.319
  %::numeric = 312
  theme.test RAW.312
  theme.test whois
  if ($hget(pnp.preview.events,whois) == $null) {
    %::numeric = 318
    theme.test RAW.318
  }
  if ($hget(pnp.preview.theme,LineSepWhois)) %:linesep

  drawsave @.mtsprev script\preview.bmp
  window -c @.mtsprev

  ; Load image into dialog
  did -g pnp.mts 512 script\preview.bmp
  .remove script\preview.bmp

  ; Cleanup- hashes, variables, unload script
  .disable #previewecho
  hfree mts.preview
  hfree pnp.preview.theme
  hfree pnp.preview.events
  unset %:* %::* %.*
  if (%script) .timer -mio 1 0 .unload -rs " $+ $ifmatch $+ "

  ; Reapply needed settings from current theme
  if (%oldbk != $color(back)) color background %oldbk
  theme.apply 0 vta

  ; Reset RGBs
  %col = 0
  while (%col <= 15) {
    if ($gettok(%rgbs,$calc(%col + 1),44) != $color(%col)) color %col $ifmatch
    inc %col
  }
}

; /theme.previewecho color text
; Echos to the preview window
alias theme.previewecho {
  if ($2- != $null) drawtext -npb @.mtsprev $1 $gettok(%.colors,1,44) " $+ %.fontname $+ " %.fontsize 3 %.ypos $iif($hget(mts.preview,timestamp) != OFF,$timestamp) $2-
  %.ypos = $calc(%.ypos + $height($2-,%.fontname,%.fontsize) + 1)
}

; /theme.previewlinesep
; Linesep to preview window
alias theme.previewlinesep {
  theme.previewecho %::c1 $hget(pnp.preview.events,LineSep)
}

; /theme.testraw num text
; Runs specified raw event to preview window
alias -l theme.testraw {
  %:echo = theme.previewecho %::c1
  %::text = $2-
  %::numeric = $left($1,3)
  theme.test RAW. $+ $1
}

; /theme.test event [flags]
; Runs the specified event from the preview hash.
; All variables not mentioned below shall already be set, including %:echo
; Flag p - set parentext
; Lowercases ::chan if setting true
; Returns 1 if no event found
alias -l theme.test {
  var %event = $hget(pnp.preview.events,$1)
  if (%event == $null) return 1
  if ((p isin $2) && (%::text != $null)) set -u %::parentext $eval($hget(pnp.preview.events,ParenText),2)
  if (($hget(pnp.theme,ChannelsLowercase)) && (%::chan != $null)) set -u %::chan $lower(%::chan)
  [ [ %event ] ]
  return
}

; Clicking on color icons
on *:DIALOG:pnp.mts:sclick:*:{
  if (($did isnum 46-71) || ($did isnum 85-89)) _cs-go 15 15
  elseif (($did isnum 102-133) || ($did isnum 235-254)) _cs-go 15 15 1
}

; /page.waiting page|0 text
; Shows the 'waiting' page; timer set to restore to page
alias -l page.waiting {
  did -c pnp.mts 19
  did -ra pnp.mts 510 $2-
  .timer.page.waiting -mio 1 0 $iif($1,did -c pnp.mts $1 $chr(124)) did -r pnp.mts 510
}

; /page.show n
; Show a page of the dialog
alias -l page.show {
  ; Enable/disable Preview button as needed
  if ($1 == 16) did -e pnp.mts 508
  else {
    did -b pnp.mts 508
    did -ra pnp.mts 508 Preview >>
    dialog -bs pnp.mts -1 -1 210 169
  }

  ; (do nothing if same page as before)
  if ($did(pnp.mts,503) == $1) return

  ; If area hasn't been visited yet, we must prep it
  if ($did(pnp.mts,502,$1) == 0) {
    ; 1/2/3/4/6 use colors, so while we prep, hide them
    if ($istok(1.2.3.4.6,$1,46)) did -c pnp.mts 19

    ; 16 could be slow- show message
    if ($1 == 16) page.waiting 0 Please wait $+ $chr(44) searching for themes...

    ; Mark as visited and initialize
    did -o pnp.mts 502 $1 1
    page.init $1
  }

  ; Fill 'Actions:' dropdown
  did -r pnp.mts 504
  if ($1 <= 15) {
    did -eac pnp.mts 504 Actions:
    did -a pnp.mts 504 Undo changes
    did -a pnp.mts 504 $iif($istok(1.2.5,$1,46),mIRC defaults,$iif($istok(3.4.6.10,$1,46),Auto-generate,Clear all))
    if ($1 == 5) did -a pnp.mts 504 Auto-generate
    if ($istok(4.10.11,$1,46)) did -a pnp.mts 504 Copy down
    if ($1 == 4) did -a pnp.mts 504 Copy right
    if ($istok(4.6.10,$1,46)) did -a pnp.mts 504 Clear all
  }
  else {
    did -bac pnp.mts 504 Actions:
  }

  ; Remember what page we did last, show tab, move focus back to list
  did -o pnp.mts 503 1 $1
  did -c pnp.mts $1
  did -f pnp.mts 501
}

; /page.action n act
; Perform a built-in action of a page
alias -l page.action {
  ; 1/2/3/4/6 use colors, so while we prep, hide them
  if ($istok(1.2.3.4.6,$1,46)) did -c pnp.mts 19

  ; Undo- nothing needs to be done (page.init will reload)
  if ($2 == 2) { }

  ; Defaults or clear
  elseif ($2 == 3) {
    ; Store colors/rgb colors/basecolors into hash if modified
    if ($did(pnp.mts,502,1) == 1) page.apply 1
    if ($did(pnp.mts,502,2) == 1) page.apply 2
    if ($did(pnp.mts,502,3) == 1) page.apply 3

    ; Load defaults    
    if ($1 == 1) theme.def mts.edit colors
    elseif ($1 == 2) theme.def mts.edit rgbcolors
    elseif ($1 == 3) {
      theme.def mts.edit basecolors
      theme.def mts.edit colorerror
    }
    elseif ($1 == 4) theme.def mts.edit pnpnickcolors 1
    elseif ($1 == 5) {
      theme.def mts.edit timestamp
      theme.def mts.edit timestampformat
      theme.def mts.edit channelslowercase
      theme.def mts.edit bold
      theme.def mts.edit prefix
      theme.def mts.edit parentext
      theme.def mts.edit linesepwhois
    }
    elseif ($1 == 6) theme.def mts.edit linesep 1
    elseif ($1 == 8) {
      theme.clear mts.edit script
      theme.clear mts.edit events
    }
    elseif ($1 == 10) {
      theme.def mts.edit fontdefault 1
      theme.def mts.edit fontchan
      theme.def mts.edit fontquery
      theme.def mts.edit fontscript
      theme.def mts.edit fontdcc
    }
    elseif ($1 == 11) theme.clear mts.edit backgrounds
    elseif ($1 == 12) theme.clear mts.edit toolbars
    elseif ($1 == 13) theme.clear mts.edit sounds
    elseif ($1 == 15) theme.clear mts.edit info
  }

  ; Other options
  elseif ($1 == 4) {
    if ($2 == 4) {
      ; Copy down (nc)
      var %cr = $col.zero($hget(pnp.dlgcolor.pnp.mts,102))
      var %cv = $col.zero($hget(pnp.dlgcolor.pnp.mts,103))
      var %ch = $col.zero($hget(pnp.dlgcolor.pnp.mts,104))
      var %co = $col.zero($hget(pnp.dlgcolor.pnp.mts,105))
      hadd mts.edit PnPNickColors %cr %cr %cr %cr %cr %cr %cr %cr $+ , $+ %cv %cv %cv %cv %cv %cv %cv %cv $+ , $+ %ch %ch %ch %ch %ch %ch %ch %ch $+ , $+ %co %co %co %co %co %co %co %co
    }
    elseif ($2 == 5) {
      ; Copy right (nc)
      var %cols = $col.zero($hget(pnp.dlgcolor.pnp.mts,102)) $col.zero($hget(pnp.dlgcolor.pnp.mts,106)) $col.zero($hget(pnp.dlgcolor.pnp.mts,110)) $col.zero($hget(pnp.dlgcolor.pnp.mts,114)) $col.zero($hget(pnp.dlgcolor.pnp.mts,118)) $col.zero($hget(pnp.dlgcolor.pnp.mts,122)) $col.zero($hget(pnp.dlgcolor.pnp.mts,126)) $col.zero($hget(pnp.dlgcolor.pnp.mts,130))
      hadd mts.edit PnPNickColors %cols $+ , $+ %cols $+ , $+ %cols $+ , $+ %cols
    }
    else theme.clear mts.edit nickcolors
  }
  elseif ($1 == 5) {
    ; Store colors/rgb colors/basecolors/fonts into hash if modified
    if ($did(pnp.mts,502,1) == 1) page.apply 1
    if ($did(pnp.mts,502,2) == 1) page.apply 2
    if ($did(pnp.mts,502,3) == 1) page.apply 3
    if ($did(pnp.mts,502,10) == 1) page.apply 10

    theme.def mts.edit timestamp
    theme.def mts.edit timestampformat 1
    theme.def mts.edit channelslowercase
    theme.def mts.edit bold
    theme.def mts.edit prefix 1
    theme.def mts.edit parentext
    theme.def mts.edit linesepwhois
  }
  elseif ($1 == 6) {
    theme.clear mts.edit linesep
  }
  elseif ($1 == 10) {
    if ($2 == 4) {
      ; Copy down (fonts)
      page.apply 10
      theme.def mts.edit fontchan
      theme.def mts.edit fontquery
      theme.def mts.edit fontdcc
      theme.def mts.edit fontscript
    }
    else theme.clear mts.edit fonts
  }
  elseif ($1 == 11) {
    ; Copy down (bkgs)
    page.apply 11
    hadd mts.edit ImageChan $hget(mts.edit,ImageMirc)
    hadd mts.edit ImageQuery $hget(mts.edit,ImageMirc)
    hadd mts.edit ImageStatus $hget(mts.edit,ImageMirc)
    hadd mts.edit ImageScript $hget(mts.edit,ImageMirc)
  }

  ; Load info in
  page.init $1

  ; Return to showing page for 1/2/3/4/6
  if ($istok(1.2.3.4.6,$1,46)) did -c pnp.mts $1
}

; /page.init n
; Prepare a page of the dialog from our hash table
alias -l page.init {
  if ($1 isnum 10-11) did -ra pnp.mts 511 1
  goto $1

  ; mIRC colors
  :1
  var %cols = $hget(mts.edit,Colors),%num = 1
  ; Load bitmap for each of 26 colors
  while (%num <= 26) {
    var %col = $col.fix($gettok(%cols,%num,44))
    did -g pnp.mts $calc(45 + %num) script\ $+ %col $+ .bmp
    hadd pnp.dlgcolor.pnp.mts $calc(45 + %num) %col
    inc %num
  }
  return

  ; RGB settings
  ;!!
  :2
  return

  ; PnP colors
  :3
  var %cols,%num = 1
  ; (separate line due to comma)
  %cols = $hget(mts.edit,BaseColors) $+ , $+ $hget(mts.edit,ColorError)
  ; Load bitmap for each of 5 colors
  while (%num <= 5) {
    var %col = $col.fix($gettok(%cols,%num,44))
    did -g pnp.mts $calc(84 + %num) script\ $+ %col $+ .bmp
    hadd pnp.dlgcolor.pnp.mts $calc(84 + %num) %col
    inc %num
  }
  return

  ; Nicklist colors
  :4
  var %col = $hget(mts.edit,PnPNickColors),%x = 1,%y = 1,%where = 102
  ; 8 rows of 4 colors each
  while ((%x <= 4) && (%y <= 8)) {
    var %c = $col.fix($gettok($gettok(%col,%x,44),%y,32))
    did -g pnp.mts %where script\ $+ %c $+ .bmp
    hadd pnp.dlgcolor.pnp.mts %where %c
    inc %where
    inc %x
    if (%x > 4) { %x = 1 | inc %y }
  }
  return

  ; Display
  :5
  did -ra pnp.mts 164 $hget(mts.edit,BoldLeft)
  did -ra pnp.mts 165 $hget(mts.edit,BoldRight)
  did -ra pnp.mts 166 $hget(mts.edit,Prefix)
  did -ra pnp.mts 172 $hget(mts.edit,ParenText)
  if ($hget(mts.edit,TimeStamp) == OFF) {
    did -u pnp.mts 167
    did -b pnp.mts 168
  }
  else {
    did -e pnp.mts 168
    did -c pnp.mts 167
  }
  did -ra pnp.mts 168 $hget(mts.edit,TimeStampFormat)
  did $iif($hget(mts.edit,ChannelsLowercase),-c,-u) pnp.mts 169
  did $iif($hget(mts.edit,LineSepWhois),-c,-u) pnp.mts 170
  return

  ; Line separator
  :6
  var %linesep = $hget(mts.edit,LineSep)

  ; Auto-build line separator? (len char color color...)
  if ($hget(mts.edit,PnPLineSep)) {
    var %data
    set -n %data $ifmatch
    var %num = 1
    while (%num <= 20) {
      var %c = $col.fix($gettok(%data,$calc(2 + %num),32))
      did -g pnp.mts $calc(%num + 234) script\ $+ %c $+ .bmp
      hadd pnp.dlgcolor.pnp.mts $calc(234 + %num) %c
      inc %num
    }
    did -c pnp.mts 230
    did -u pnp.mts 231,232
    did -era pnp.mts 256 $gettok(%data,2,32)
    did -era pnp.mts 258 $gettok(%data,1,32)
    did -b pnp.mts 259
  }
  ; Otherwise, create some semblance of auto-build settings
  else {
    ; Select pregenerated line separator or off
    if (%linesep == OFF) {
      did -c pnp.mts 232
      did -u pnp.mts 230,231
      did -b pnp.mts 259
      %linesep =
    }
    else {
      did -c pnp.mts 231
      did -u pnp.mts 230,232
      did -e pnp.mts 259
    }
    ; Length
    var %len = $len($strip(%linesep))
    if (%len > 200) %len = 200
    elseif (%len < 1) %len = 20
    did -bra pnp.mts 258 %len
    ; Character- second character in
    var %char = $mid($strip(%linesep),2,1)
    if (%char == $null) %char = -
    did -bra pnp.mts 256 %char
    ; Colors- all colors present
    var %num = 1
    var %total = $regex(%linesep,/(\d\d?)/g)
    while (%num <= 20) {
      var %c = $col.fix($regml(%num))
      did -g pnp.mts $calc(%num + 234) script\ $+ %c $+ .bmp
      hadd pnp.dlgcolor.pnp.mts $calc(234 + %num) %c
      inc %num
    }
  }

  ; Always load full separator into this field
  did -ra pnp.mts 259 %linesep
  return

  ; Text theme
  :8
  var %script = $hget(mts.edit,Script)
  ; Default to showing "theme lines" section
  did -c pnp.mts 300
  did -u pnp.mts 301
  did -vr pnp.mts 302
  ; (don't clear script if we're already loaded into dialog)
  did $iif(-d * iswm %script,-h,-hr) pnp.mts 303
  ; Load all events into theme lines
  ; This excludes all lines referenced in any other section
  var %count = $hget(mts.edit,0).item
  while (%count >= 1) {
    var %item = $hget(mts.edit,%count).item
    ; Events/raws only
    if ($theme.itemtype(%item) == e) did -a pnp.mts 302 %item $hget(mts.edit,%item) $+ $crlf
    dec %count
  }
  ; Sort (if any lines)
  if ($did(pnp.mts,302).lines > 1) filter -ioct 1 32 pnp.mts 302 pnp.mts 302 *
  ; Load script into other one
  if ((-d * !iswm %script) && (%script)) {
    var %script = $theme.ff($hget(mts.edit,Filename),$ifmatch)
    if (%script) loadbuf -o pnp.mts 303 " $+ %script $+ "
  }
  return

  ; Fonts
  :10
  did -ra pnp.mts 315 $font.display($hget(mts.edit,FontDefault))
  did -ra pnp.mts 316 $font.display($hget(mts.edit,FontChan))
  did -ra pnp.mts 317 $font.display($hget(mts.edit,FontQuery))
  did -ra pnp.mts 318 $font.display($hget(mts.edit,FontDCC))
  did -ra pnp.mts 319 $font.display($hget(mts.edit,FontScript))
  return

  ; Backgrounds
  :11
  if ($hget(mts.edit,ImageMirc)) {
    did -ra pnp.mts 331 $gettok($ifmatch,2-,32)
    did -ec pnp.mts 333 $findtok(Center Fill Normal Stretch Tile Photo,$gettok($ifmatch,1,32),1,32)
  }
  else {
    did -r pnp.mts 331
    did -bc pnp.mts 333 1
  }
  if ($hget(mts.edit,ImageStatus)) {
    did -ra pnp.mts 336 $gettok($ifmatch,2-,32)
    did -ec pnp.mts 338 $findtok(Center Fill Normal Stretch Tile Photo,$gettok($ifmatch,1,32),1,32)
  }
  else {
    did -r pnp.mts 336
    did -bc pnp.mts 338 1
  }
  if ($hget(mts.edit,ImageChan)) {
    did -ra pnp.mts 341 $gettok($ifmatch,2-,32)
    did -ec pnp.mts 343 $findtok(Center Fill Normal Stretch Tile Photo,$gettok($ifmatch,1,32),1,32)
  }
  else {
    did -r pnp.mts 341
    did -bc pnp.mts 343 1
  }
  if ($hget(mts.edit,ImageQuery)) {
    did -ra pnp.mts 346 $gettok($ifmatch,2-,32)
    did -ec pnp.mts 348 $findtok(Center Fill Normal Stretch Tile Photo,$gettok($ifmatch,1,32),1,32)
  }
  else {
    did -r pnp.mts 346
    did -bc pnp.mts 348 1
  }
  if ($hget(mts.edit,ImageScript)) {
    did -ra pnp.mts 351 $gettok($ifmatch,2-,32)
    did -ec pnp.mts 353 $findtok(Center Fill Normal Stretch Tile Photo,$gettok($ifmatch,1,32),1,32)
  }
  else {
    did -r pnp.mts 351
    did -bc pnp.mts 353 1
  }
  return

  ; Toolbars
  :12
  did -ra pnp.mts 361 $hget(mts.edit,ImageButtons)
  did -ra pnp.mts 366 $gettok($hget(mts.edit,ImageToolbar),2-,32)
  did -ra pnp.mts 371 $gettok($hget(mts.edit,ImageSwitchbar),2-,32)
  return

  ; Event Sounds
  :13
  ; Load all sounds into list
  did -r pnp.mts 415
  var %count = $hget(mts.edit,0).item
  while (%count >= 1) {
    var %item = $hget(mts.edit,%count).item
    ; Sounds only
    if (Snd* iswm %item) did -a pnp.mts 415 %item $hget(mts.edit,%item)
    dec %count
  }
  ; Display "all"
  did -c pnp.mts 402 1
  page.sound 1
  return

  ; Theme Info
  :15
  did -ra pnp.mts 426 $hget(mts.edit,Name)
  did -ra pnp.mts 427 $hget(mts.edit,Version)
  did -ra pnp.mts 428 $hget(mts.edit,Author)
  did -ra pnp.mts 429 $hget(mts.edit,Email)
  did -ra pnp.mts 430 $hget(mts.edit,Website)
  did -ra pnp.mts 431 $hget(mts.edit,Description)
  return

  ; Load Theme
  :16
  did -r pnp.mts 461,474,476
  did -b pnp.mts 476,477,478,513
  did -c pnp.mts 463,464,465,466,467,469,470,471,472,473
  var %count = $findfile($mircdir,*.mts,0,page.addtheme $1-)
  return

  ; Save Theme
  :17
  did -c pnp.mts 441,442,443,444,445,446,447,448,449,450
  return
}

; /page.addtheme filename
; (adds to load theme page filelist)
alias -l page.addtheme {
  ; Verify [mts]
  var %mts = $theme.issec($1-,mts)
  if (%mts) {
    var %name = $gettok($replace($read($1-,nw,name *,%mts),$chr(160),$chr(32)),2-,32)
    var %author = $gettok($replace($read($1-,nw,author *,%mts),$chr(160),$chr(32)),2-,32)
    var %version = $gettok($replace($read($1-,nw,version *,%mts),$chr(160),$chr(32)),2-,32)
    var %mtsv = $gettok($read($1-,nw,mtsversion *,%mts),2,32)
    ; Make sure version is proper and name is valid
    if ((%mtsv <= $mtsversion) && (%mtsv isnum) && (%name != $null)) {
      ; Add version, author
      if (%version != $null) %name = %name %version
      if (%author != $null) %name = %name by %author
      ; If exists, add another 160 to it (allow duplicate names)
      while ($didwm(pnp.mts,461,%name)) {
        %name = %name $+ $chr(160)
      }
      ; Add to lists (name+160(s)+!+file used to find files based on names)
      did -a pnp.mts 474 %name $+ $chr(160) $+ ! $+ $1-
      did -a pnp.mts 461 %name
    }
  }
}

; /page.apply n
; Save a page of the dialog to our hash table
alias -l page.apply {
  goto $1

  ; mIRC colors
  :1
  var %num = 1,%cols
  while (%num <= 26) {
    %cols = $instok(%cols,$col.zero($hget(pnp.dlgcolor.pnp.mts,$calc(45 + %num))),0,44)
    inc %num
  }
  hadd mts.edit Colors %cols
  return

  ; RGB settings
  ;!!
  :2
  return

  ; PnP colors
  :3
  var %num = 1,%cols
  while (%num <= 4) {
    %cols = $instok(%cols,$col.zero($hget(pnp.dlgcolor.pnp.mts,$calc(84 + %num))),0,44)
    inc %num
  }
  hadd mts.edit BaseColors %cols
  hadd mts.edit ColorError $col.zero($hget(pnp.dlgcolor.pnp.mts,89))
  return

  ; Nicklist colors
  :4
  var %where = 102,%x = 1, %y = 1,%cols1,%cols2,%cols3,%cols4
  ; 8 rows of 4 colors each
  while ((%x <= 4) && (%y <= 8)) {
    var %c = $col.zero($hget(pnp.dlgcolor.pnp.mts,%where))
    %cols [ $+ [ %x ] ] = $instok(%cols [ $+ [ %x ] ] ,%c,0,32)
    inc %where
    inc %x
    if (%x > 4) { %x = 1 | inc %y }
  }
  hadd mts.edit PnPNickColors %cols1 $+ , $+ %cols2 $+ , $+ %cols3 $+ , $+ %cols4
  ; Break it down into individual colors also
  theme.pnpnicklist mts.edit
  return

  ; Display
  :5
  hadd mts.edit BoldLeft $did(pnp.mts,164)
  hadd mts.edit BoldRight $did(pnp.mts,165)
  hadd mts.edit Prefix $did(pnp.mts,166)
  hadd mts.edit TimeStamp $iif($did(pnp.mts,167).state,ON,OFF)
  hadd mts.edit TimeStampFormat $did(pnp.mts,168)
  hadd mts.edit ParenText $iif(<text> isin $did(pnp.mts,172),$did(pnp.mts,172),(<text>))
  hadd mts.edit ChannelsLowercase $did(pnp.mts,169).state
  hadd mts.edit LineSepWhois $did(pnp.mts,170).state
  return

  ; Line separator
  :6
  if ($did(pnp.mts,232).state) {
    theme.clear mts.edit linesep
  }
  elseif ($did(pnp.mts,231).state) {
    hadd mts.edit LineSep $iif($did(pnp.mts,259),$ifmatch,-)
    hdel mts.edit PnPLineSep
  }
  else {
    ; Auto-build line separator
    var %len = $did(pnp.mts,258),%char = $did(pnp.mts,256),%num = 1,%cols
    while (%num <= 20) {
      if ($hget(pnp.dlgcolor.pnp.mts,$calc(234 + %num)) != 16) %cols = %cols $col.zero($ifmatch)
      inc %num
    }
    if (%len !isnum 1-200) %len = 20
    if ($len(%char) !isnum 1-200) %char = -
    if ($calc(%len * $len(%char)) > 200) %len = $int($calc(200 / $len(%char)))
    hadd mts.edit LineSep $_cfade($replace(%cols,$chr(32),.),$str(%char,%len))
    hadd mts.edit PnPLineSep %len %char %cols
  }
  return

  ; Text theme
  :8
  ; Remove all event/raw lines
  theme.clear mts.edit events
  ; Save lines
  %count = $did(pnp.mts,302).lines
  while (%count >= 1) {
    var %item = $did(pnp.mts,302,%count)
    if ((;* !iswm %item) && ($gettok(%item,1,32) != $null) && ($theme.itemtype($gettok(%item,1,32)) == e)) hadd mts.edit %item
    dec %count
  }
  ; See if script contains any non-blank non-comment lines
  %count = $did(pnp.mts,303).lines
  var %found = 0
  while (%count >= 1) {
    var %item = $did(pnp.mts,303,%count)
    if ((;* !iswm %item) && ($gettok(%item,1,32) != $null)) {
      %found = 1
      break
    }
    dec %count
  }
  ; Mark script as current
  if (%found) hadd mts.edit Script -d pnp.mts 303
  else theme.clear mts.edit script
  var %script = $hget(mts.edit,Script)
  return

  ; Fonts
  :10
  hadd mts.edit FontDefault $font.mts($did(pnp.mts,315))
  hadd mts.edit FontChan $font.mts($did(pnp.mts,316))
  hadd mts.edit FontQuery $font.mts($did(pnp.mts,317))
  hadd mts.edit FontDCC $font.mts($did(pnp.mts,318))
  hadd mts.edit FontScript $font.mts($did(pnp.mts,319))
  return

  ; Backgrounds
  :11
  if ($did(pnp.mts,331)) hadd mts.edit ImageMirc $gettok(Center Fill Normal Stretch Tile Photo,$did(pnp.mts,333,1).sel,32) $ifmatch
  else hdel mts.edit ImageMirc
  if ($did(pnp.mts,336)) hadd mts.edit ImageStatus $gettok(Center Fill Normal Stretch Tile Photo,$did(pnp.mts,338,1).sel,32) $ifmatch
  else hdel mts.edit ImageStatus
  if ($did(pnp.mts,341)) hadd mts.edit ImageChan $gettok(Center Fill Normal Stretch Tile Photo,$did(pnp.mts,343,1).sel,32) $ifmatch
  else hdel mts.edit ImageChan
  if ($did(pnp.mts,346)) hadd mts.edit ImageQuery $gettok(Center Fill Normal Stretch Tile Photo,$did(pnp.mts,348,1).sel,32) $ifmatch
  else hdel mts.edit ImageQuery
  if ($did(pnp.mts,351)) hadd mts.edit ImageScript $gettok(Center Fill Normal Stretch Tile Photo,$did(pnp.mts,353,1).sel,32) $ifmatch
  else hadd mts.edit ImageScript
  return

  ; Toolbars
  :12
  if ($did(pnp.mts,361)) hadd mts.edit ImageButtons $ifmatch
  else hdel mts.edit ImageButtons
  if ($did(pnp.mts,366)) hadd mts.edit ImageToolbar Tile $ifmatch
  else hdel mts.edit ImageToolbar
  if ($did(pnp.mts,371)) hadd mts.edit ImageSwitchbar Tile $ifmatch
  else hdel mts.edit ImageSwitchbar
  return

  ; Event Sounds
  :13
  theme.clear mts.edit sounds
  ; Load all sounds from list
  var %count = $did(pnp.mts,415).lines
  while (%count >= 1) {
    var %item = $did(pnp.mts,415,%count)
    if ($gettok(%item,2,32)) hadd mts.edit %item
    dec %count
  }
  return

  ; Theme Info
  :15
  if ($did(pnp.mts,426) != $null) hadd mts.edit Name $ifmatch
  else hdel mts.edit Name
  if ($did(pnp.mts,427) != $null) hadd mts.edit Version $ifmatch
  else hdel mts.edit Version
  if ($did(pnp.mts,428) != $null) hadd mts.edit Author $ifmatch
  else hdel mts.edit Author
  if ($did(pnp.mts,429) != $null) hadd mts.edit Email $ifmatch
  else hdel mts.edit Email
  if ($did(pnp.mts,430) != $null) hadd mts.edit Website $ifmatch
  else hdel mts.edit Website
  if ($did(pnp.mts,431) != $null) {
    var %desc,%num = 1
    while (%num <= $did(pnp.mts,431).lines) {
      %desc = %desc $did(pnp.mts,431,%num)
      inc %num
    }
    hadd mts.edit Description %desc
  }
  else hdel mts.edit Description
  return

  ; Load Theme
  ; Save Theme
  ; (nothing to apply)
  :16
  :17
  return
}

; /theme.pnpnicklist hash
; Converts pnpnicklist to individual colors for saving
alias -l theme.pnpnicklist {
  var %cols = $hget($1,PnPNickColors)
  var %cols1 = $gettok(%cols,1,44)
  var %cols2 = $gettok(%cols,2,44)
  var %cols3 = $gettok(%cols,3,44)
  var %cols4 = $gettok(%cols,4,44)
  ; Break it down into individual colors
  var %cr = $gettok(%cols1,1,32)
  var %cv = $gettok(%cols2,1,32)
  var %ch = $gettok(%cols3,1,32)
  var %co = $gettok(%cols4,1,32)
  var %cfriend = $gettok(%cols1,2,32)
  var %cenemy = $gettok(%cols1,3,32)
  if (%cenemy == ?) %cenemy = $gettok(%cols1,4,32)
  var %circop = $gettok(%cols1,5,32)
  var %cme = $gettok(%cols1,6,32)
  var %cmisc = $gettok(%cols1,7,32)
  if (%cmisc == ?) %cmisc = $gettok(%cols1,8,32)
  hdel -w $1 CLine*
  if (%cr != ?) hadd $1 CLineRegular %cr
  if (%cv != ?) hadd $1 CLineVoice %cv
  if (%ch != ?) hadd $1 CLineHOP %ch
  if (%co != ?) {
    hadd $1 CLineOP %co
    hadd $1 CLineOwner %co
  }
  if ((%cfriend != %cr) && (%cfriend != ?)) hadd $1 CLineFriend %cfriend
  if ((%cenemy != %cr) && (%cenemy != ?)) hadd $1 CLineEnemy %cenemy
  if ((%cme != %cr) && (%cme != ?)) hadd $1 CLineMe %cme
  if ((%circop != %cr) && (%circop != ?)) hadd $1 CLineIrcOP %circop
}

; /page.sound line
; Populates sound area of dialog with set or subset of sounds
alias -l page.sound {
  ; Determine list of sounds to show
  var %titles
  ; (1 is all- triggers all of these)
  ; Alert
  if (($1 == 1) || ($1 == 2)) %titles = Flood/attack:ProtectSelf,Channel protect:ProtectChan,Nick taken:NickTaken,Selflag alert:SelfLag,Can't join channel:NoJoin,Clones alert:Clones,Other alert:Alert,
  ; Away
  if (($1 == 1) || ($1 == 3)) %titles = %titles $+ Set away:Away,Set back:Back,Auto-away:AwayAuto,Pager sound:Pager,
  ; Connection
  if (($1 == 1) || ($1 == 4)) %titles = %titles $+ Connection:Connect,Disconnection:Disconnect,Voluntary quit:QuitSelf,mIRC startup:Start,
  ; DCC
  if (($1 == 1) || ($1 == 5)) %titles = %titles $+ Incoming chat:DCC,Incoming file:DCCSend,Get complete:FileRcvd,Send complete:FileSent,File error:GetFail,
  ; Event
  if (($1 == 1) || ($1 == 6)) %titles = %titles $+ You join:JoinSelf,You part:PartSelf,You kicked:KickSelf,You banned:BanSelf,You opped/etc:OpSelf,You deopped/etc:DeopSelf,You invited:Invite,User kicked:Kick,
  ; General
  if (($1 == 1) || ($1 == 7)) %titles = %titles $+ Dialog open:Dialog,Error:Error,Operation complete:Complete,Question:Question,Confirm:Confirm,
  ; Message
  if (($1 == 1) || ($1 == 8)) %titles = %titles $+ New query:Open,Private notice:Notice,Op notice/msg:NoticeChanOp,IRCop wallop:Wallop,Server notice:NoticeServer,
  ; Notify
  if (($1 == 1) || ($1 == 9)) %titles = %titles $+ Normal notify:Notify,Normal unnotify:UNotify,Failed notify:NotifyFail,Failed unnotify:UNotifyFail,
  ; Sort
  %titles = $sorttok(%titles,44)

  ; Clear lists
  did -r pnp.mts 404,416
  var %num = 1
  while (%num <= $numtok(%titles,44)) {
    ; Find item in sounds
    var %title = $gettok(%titles,%num,44)
    var %item = $gettok(%title,2,58)
    var %ln = $didwm(pnp.mts,415,Snd $+ %item *,1)
    var %snd
    if (%ln) %snd = $gettok($did(pnp.mts,415,%ln),2-,32)

    ; Add visible line and item name to lists
    did -a pnp.mts 404 $gettok(%title,1,58) $iif(%snd,( $+ %snd $+ ))
    did -a pnp.mts 416 %item
    inc %num
  }

  ; Update -b/-e on buttons
  update.sound
}

; /theme.hash [-flags] [+load] hash filename
; Loads a theme file into a hash table
; Returns text error if error(s) were encountered
; %.warning contains any warning that was encountered

; Flags-
; -m to load mirc settings and override theme settings
; -t to load mirc timestamp settings only
; -s# to load scheme number # (0 for none)
; -e to show errors and warnings to status

; Load- (what to load into your hash) Defaults to all
; Anything not loaded is NOT deleted or overwritten!
;  i)nfo, m)irc colors, r)gb, p)np/base colors, n)icklist, l)ine sep, e)vent, d)isplay, f)ont, b)ackground,
;  t)oolbar, s)ound, c) script line
; info includes pnptheme and filename settings

; Generates defaults as needed for-
;   colors/rgbcolors/pnpnickcolors/basecolors/colorerror/timestamp/channelslowercase/parentext
;   boldleft/boldright/imagescript/fontscript/fontdcc/fontchan/fontquery/linesep/linesepwhois
alias -l theme.hash {
  ; Force $1 to be flags, $2 to be +load
  if (-* !iswm $1) tokenize 32 - $1-
  if (+* !iswm $2) tokenize 32 $1 +bcdefilmnprst $2-

  ; Load directly into new hash if all is being loaded, otherwise temporary hash
  var %hash = $iif((b isin $2) && (c isin $2) && (d isin $2) && (e isin $2) && (f isin $2) && (i isin $2) && (l isin $2) && (m isin $2) && (n isin $2) && (p isin $2) && (r isin $2) && (s isin $2) && (t isin $2),$3,mts.temp)

  ; Check file exists
  if (!$isfile($4-)) {
    if (e isin $1) disps Error loading theme ' $+ $4- $+ ' $+ - File not found!
    return File not found!
  }

  ; Verify [mts] exists; verify version
  if ($theme.issec($4-,mts)) {
    var %from = $ifmatch
    var %mtsv = $gettok($read($4-,nw,mtsversion *,%from),2,32)
    if ((%mtsv == $null) || (%mtsv !isnum) || (%mtsv > $mtsversion)) {
      if (e isin $1) disps Error loading theme ' $+ $4- $+ ' $+ - Invalid MTS version!
      return Invalid MTS version!
    }
  }
  else {
    if (e isin $1) disps Error loading theme ' $+ $4- $+ ' $+ - $chr(91) $+ mts $+ $chr(93) section not found!
    return $chr(91) $+ mts $+ $chr(93) section not found!
  }

  ; Load theme into hash via window/loadbuf
  window -hnl @.thash
  loadbuf -tmts @.thash " $+ $4- $+ "

  ; Load scheme also?
  if (s isin $1) {
    var %scheme = $calc($mid($1,$calc($pos($1,s) + 1)) + 0)
    if (%scheme > 0) {
      ; Verify [schemeN] exists
      if (!$theme.issec($4-,scheme $+ %scheme)) {
        if (e isin $1) disps Error loading theme ' $+ $4- $+ ' $+ - Scheme %scheme not found!
        window -c @.thash
        return Scheme %scheme not found!
      }
      loadbuf -tscheme $+ %scheme @.thash " $+ $4- $+ "
    }
  }

  ; Save old settings for defaults for later
  var %oldts,%oldcl,%oldbl,%oldbr,%oldb
  if ($hget($3,TimeStampFormat) != $null) %oldts = $ifmatch
  if ($hget($3,ChannelsLowercase) != $null) %oldcl = $ifmatch
  if (($hfind($3,BoldLeft,0)) || ($hfind($3,BoldRight,0))) {
    %oldbl = $hget($3,BoldLeft)
    %oldbr = $hget($3,BoldRight)
    %oldb = 1
  }

  ; Load into hash (clear first/make sure exists
  if ($hget(%hash)) hdel -w %hash *
  else hmake %hash 20
  var %line = 1,%max = $line(@.thash,0)
  while (%line <= %max) {
    var %data = $line(@.thash,%line)
    ; (skip comments and blank lines- items with no data allowed)
    if ((;* !iswm %data) && ($gettok(%data,1,32) != $null)) hadd %hash %data
    inc %line
  }
  window -c @.thash

  ; Set special filename setting
  hadd %hash Filename $4-

  ; Load mirc settings?
  if (m isin $1) {
    saveini
    theme.curr %hash colors
    theme.curr %hash rgbcolors
    theme.curr %hash timestamp
    theme.curr %hash timestampformat
    theme.curr %hash fonts
    theme.curr %hash backgrounds
    theme.curr %hash toolbars
  }
  elseif (t isin $1) {
    saveini
    theme.curr %hash timestamp
    theme.curr %hash timestampformat
  }

  ; Error check all sections; this also replaces <c?>, 0-fills colors, and path-fills any filenames
  if ($hget(%hash,BaseColors)) theme.check %hash basecolors $1
  if ($hget(%hash,RGBColors)) theme.check %hash rgbcolors $1
  if ($hget(%hash,Colors)) theme.check %hash colors $1
  if ($hget(%hash,PnPNickColors)) theme.check %hash pnpnickcolors $1
  if ($hget(%hash,CLineOwner)) theme.check %hash clineowner $1
  if ($hget(%hash,CLineOP)) theme.check %hash clineop $1
  if ($hget(%hash,CLineHOP)) theme.check %hash clinehop $1
  if ($hget(%hash,CLineVoice)) theme.check %hash clinevoice $1
  if ($hget(%hash,CLineRegular)) theme.check %hash clineregular $1
  if ($hget(%hash,CLineIrcOP)) theme.check %hash clineircop $1
  if ($hget(%hash,CLineEnemy)) theme.check %hash clineenemy $1
  if ($hget(%hash,CLineFriend)) theme.check %hash clinefriend $1
  if ($hget(%hash,CLineMe)) theme.check %hash clineme $1
  if ($hget(%hash,CLineMisc)) theme.check %hash clinemisc $1
  if ($hget(%hash,ColorError)) theme.check %hash colorerror $1
  if ($hget(%hash,ChannelsLowercase)) theme.check %hash channelslowercase $1
  if ($hget(%hash,ImageScript)) theme.check %hash imagescript $1
  if ($hget(%hash,ImageMirc)) theme.check %hash imagemirc $1
  if ($hget(%hash,ImageChan)) theme.check %hash imagechan $1
  if ($hget(%hash,ImageQuery)) theme.check %hash imagequery $1
  if ($hget(%hash,ImageStatus)) theme.check %hash imagestatus $1
  if ($hget(%hash,ImageToolbar)) theme.check %hash imagetoolbar $1
  if ($hget(%hash,ImageButtons)) theme.check %hash imagebuttons $1
  if ($hget(%hash,ImageSwitchbar)) theme.check %hash imageswitchbar $1
  if ($hget(%hash,FontDefault)) theme.check %hash fontdefault $1
  if ($hget(%hash,FontChan)) theme.check %hash fontchan $1
  if ($hget(%hash,FontQuery)) theme.check %hash fontquery $1
  if ($hget(%hash,FontScript)) theme.check %hash fontscript $1
  if ($hget(%hash,FontDCC)) theme.check %hash fontdcc $1
  if ($hget(%hash,LineSepWhois)) theme.check %hash linesepwhois $1
  if ($hget(%hash,Script)) theme.check %hash script $1
  if ($hget(%hash,TimeStamp)) theme.check %hash timestamp $1
  theme.check %hash others $1

  ; If missing, add defaults- we use $hfind(%hash,name,0) to see if it exists but blank, if it makes a difference
  ; Some missing features default to the value already in $3 if it exists- timestamp, lowercase, bold
  if ($hget(%hash,RGBColors) == $null) theme.def %hash rgbcolors
  if ($hget(%hash,Colors) == $null) theme.def %hash colors
  if ($hget(%hash,PnPNickColors) == $null) theme.def %hash pnpnickcolors
  if ($hget(%hash,BaseColors) == $null) theme.def %hash basecolors
  if ($hget(%hash,ColorError) == $null) theme.def %hash colorerror
  if ($hget(%hash,LineSep) == $null) theme.def %hash linesep
  if ($hget(%hash,TimeStamp) == $null) theme.def %hash timestamp
  if ($hget(%hash,TimeStampFormat) == $null) {
    if (%oldts != $null) hadd %hash TimeStampFormat %oldts
    else theme.def %hash timestampformat
  }
  if ($hget(%hash,ChannelsLowercase) == $null) {
    if (%oldcl != $null) hadd %hash ChannelsLowercase %oldcl
    else theme.def %hash channelslowercase
  }
  if ((!$hfind(%hash,BoldLeft,0)) && (!$hfind(%hash,BoldRight,0))) {
    if (%oldb) {
      hadd %hash BoldLeft %oldbl
      hadd %hash BoldRight %oldbr
    }
    else theme.def %hash bold
  }
  if (!$hfind(%hash,ImageScript,0)) theme.def %hash imagescript
  if ($hget(%hash,FontDefault) == $null) theme.def %hash fontdefault
  if ($hget(%hash,FontChan) == $null) theme.def %hash fontchan
  if ($hget(%hash,FontQuery) == $null) theme.def %hash fontquery
  if ($hget(%hash,FontScript) == $null) theme.def %hash fontscript
  if ($hget(%hash,FontDCC) == $null) theme.def %hash fontdcc
  if ($hget(%hash,ParenText) == $null) theme.def %hash parentext
  if ($hget(%hash,LineSepWhois) == $null) theme.def %hash linesepwhois
  if ($hget(%hash,Prefix) == $null) theme.def %hash prefix

  ; If prefix exists, make sure it ends in ^O if needed
  var %pre = $hget(%hash,Prefix)
  ; Chop anything before the last ^O
  %pre = $mid(%pre,$calc($pos(%pre,,$pos(%pre,,0)) + 1))
  ; Remove bolds if even count, same for under and reverse
  if (. !isin $calc($count(%pre,) / 2)) %pre = $remove(%pre,)
  if (. !isin $calc($count(%pre,) / 2)) %pre = $remove(%pre,)
  if (. !isin $calc($count(%pre,) / 2)) %pre = $remove(%pre,)
  ; Any codes left? add ^O
  if ($strip(%pre) != %pre) hadd %hash Prefix $hget(%hash,Prefix) $+ 

  ; Done if we were loading straight into hash
  if (%hash == $3) return

  ; Target hash exists?
  if (!$hget($3)) hmake $3 20

  ; Delete from target hash
  window -hln @.mtsrem
  var %count = $hget($3,0).item
  while (%count >= 1) {
    var %item = $hget($3,%count).item
    ; Selected types only
    if ($theme.itemtype(%item) isin $2) aline @.mtsrem %item
    dec %count
  }
  ; Delete via a window in case deleting items changes order
  %count = $line(@.mtsrem,0)
  while (%count >= 1) {
    hdel $3 $line(@.mtsrem,%count)
    dec %count
  }
  window -c @.mtsrem

  ; Add to requested hash
  var %count = $hget(mts.temp,0).item
  while (%count >= 1) {
    var %item = $hget(mts.temp,%count).item
    ; Selected types only
    if ($theme.itemtype(%item) isin $2) hadd $3 %item $hget(mts.temp,%item)
    dec %count
  }

  hfree mts.temp
}

; /theme.save [-flags] [+save] hash filename
; Saves a theme file from a hash table
; Updates MTSversion (in hash too)
; Updates Script (in hash) to point to full pathname of saved scriptfile
; Returns error text if error(s) encountered
; Will not overwrite any files- returns errors in that case

; Flags-
; -c to copy all associated files into same directory and update theme to match
;    Files already pointed to that directory are not touched
;    (if target filename exists, it is renamed 1 2 3 etc.)
;    If not copying, files are not required to exist.
; -e to show errors to status
; -h to add a pnp header to any copied script file
; -o to overwrite any existing theme or script file

; Save- (what to write into file) Defaults to all
; Anything not saved is not written in any form; info should almost always be included
;  i)nfo, m)irc colors, r)gb, p)np/base colors, n)icklist, l)ine sep, e)vent, d)isplay, f)ont, b)ackground,
;  t)oolbar, s)ound, c) script (saved as same filename, .mrc)
; info includes 'pnptheme' and 'mtsversion' settings
; 'filename' setting not written
alias -l theme.save {
  ; Force $1 to be flags, $2 to be +save
  if (-* !iswm $1) tokenize 32 - $1-
  if (+* !iswm $2) tokenize 32 $1 +bcdefilmnprst $2-

  ; Check file exists
  if (($exists($4-)) && (o !isin $1)) {
    if (e isin $1) disps Error saving theme ' $+ $4- $+ ' $+ - File already exists!
    return File already exists!
  }

  ; Check if target directory exists
  var %dir = $nofile($4-)
  if ((%dir != $null) && (!$isdir(%dir))) {
    if (e isin $1) disps Error saving theme ' $+ $4- $+ ' $+ - No directory to save to!
    return No directory to save to!
  }

  ; Disallow saving as .mrc or with no extension
  var %ext = $gettok($3-,-1,46)
  if ((%ext == mrc) || (/ isin %ext) || (\ isin %ext) || ($numtok($3-,46) == 1)) {
    if (e isin $1) disps Error saving theme ' $+ $4- $+ ' $+ - Invalid extension
    return Invalid extension
  }

  ; Check if script exists, if we're saving one
  var %script,%scriptfile
  if (c isin $2) {
    %script = $hget($3,Script)
    if (-d * !iswm %script) %script = $theme.ff($hget($3,Filename),%script)
    if (%script) {
      %scriptfile = $deltok($4-,-1,46) $+ .mrc
      if (($exists(%scriptfile)) && (o !isin $1)) {
        if (e isin $1) disps Error saving theme ' $+ $4- $+ ' $+ - Script already exists!
        return Script already exists!
      }
    }
  }

  ; Update mtsversion, pnptheme, ensure there's a name
  if (i isin $2) {
    hadd $3 MTSVersion $mtsversion
    hadd $3 PnPTheme 1
    if ($hget($3,name) == $null) hadd $3 Name (untitled)
  }

  ; Save hash data, copy files as we go
  window -hln @.mtssave
  var %count = $hget($3,0).item
  while (%count >= 1) {
    var %item = $hget($3,%count).item
    ; Selected types only; skip filename/script/mtsversion lines
    if ((!$istok(filename script,%item,32)) && ($theme.itemtype(%item) isin $2)) {
      var %data = $hget($3,%item)
      ; Copy files?
      if ((c isin $1) && (%data != $null) && ((Snd* iswm %item) || (Image* iswm %item))) {
        var %style
        ; Image entries have 'styles'
        if ((Image* iswm %item) && (%item != ImageButtons)) {
          %style = $gettok(%data,1,32)
          %data = $gettok(%data,2-,32)
        }
        var %file = $theme.ff($hget($3,Filename),%data)
        if (%file) {
          ; New filename
          %data = $nofile($4-) $+ $nopath(%file)
          ; Same exact file? Skip copy
          if ($_truename.fn(%data) != $_truename.fn(%file)) {
            var %ext = $gettok(%data,-1,46)
            %data = $deltok(%data,-1,46)
            var %num
            ; If exists, add 1 2 etc until not exists
            while ($exists(%data $+ %num $+ . $+ %ext)) {
              inc %num
            }
            ; Copy file
            %data = %data $+ %num $+ . $+ %ext
            .copy " $+ %file $+ " " $+ %data $+ "
          }
          ; Place new file in %data
          %data = %style $nopath(%data)
        }
        else {
          window -c @.mtssave
          if (e isin $1) disps Error saving theme ' $+ $4- $+ ' $+ - File ' $+ %data $+ ' not found
          return File ' $+ %data $+ ' not found
        }
      }
      aline @.mtssave %item %data
    }
    dec %count
  }

  ; Save script
  if (%scriptfile) {
    if (-d * iswm %script) savebuf -o $gettok(%script,2-,32) " $+ %scriptfile $+ "
    else .copy -o " $+ %script $+ " " $+ %scriptfile $+ "
    if (h isin $1) write -il1 " $+ %scriptfile $+ " ; #= P&P.theme -rs
    aline @.mtssave Script $nopath(%scriptfile)
    hadd $3 Script %scriptfile
  }

  ; Save main
  filter -wwct 1 32 @.mtssave @.mtssave *
  iline @.mtssave 1 [mts]
  iline @.mtssave 2 ; MTS-compatible theme file saved by Peace and Protection $:ver by pai
  savebuf @.mtssave " $+ $4- $+ "
  window -c @.mtssave
}

; /theme.confirm hash
; Confirms if any file or font are missing
; Returns 1 if cancel selected
alias -l theme.confirm {
  ; All images, sounds, and fonts
  var %count = $hget($1,0).item
  while (%count >= 1) {
    var %item = $hget($1,%count).item
    if (Font* iswm %item) {
      var %data = $hget($1,%item)
      if (%data) {
        if ((!$_dlgi(fontmissing)) && (!$font.exists($gettok(%data,1,44))) && (!%tried [ $+ [ $_s2p($gettok(%data,1,44)) ] ] )) {
          if (!$_okcancelcheck(1,Font ' $+ $gettok(%data,1,44) $+ ' missing- Apply theme anyways?,0,Don't show this message again)) return 1
          if (%.okcheck) _dlgw fontmissing 1
          ; Don't ask twice
          var %tried [ $+ [ $_s2p($gettok(%data,1,44)) ] ]
          %tried [ $+ [ $_s2p($gettok(%data,1,44)) ] ] = 1
        }
      }
    }
    elseif ((Image* iswm %item) || (Snd* iswm %item)) {
      var %data = $hget($1,%item)
      if ((Image* iswm %item) && (%item != ImageButtons)) %data = $gettok(%data,2-,32)
      ; Exists?
      if ((!$_dlgi(imagemissing)) && (%data) && (!$theme.ff($hget($1,Filename),%data)) && (!%tried [ $+ [ $_s2p($nopath(%data)) ] ] )) {
        if (!$_okcancelcheck(1,File ' $+ $nopath(%data) $+ ' missing- Apply theme anyways?,0,Don't show this message again)) return 1
        if (%.okcheck) _dlgw imagemissing 1
        ; Don't ask twice
        var %tried [ $+ [ $_s2p($nopath(%data)) ] ]
        %tried [ $+ [ $_s2p($nopath(%data)) ] ] = 1
      }
    }
    dec %count
  }
}

; /theme.apply hash flags [hashfile [loadintohash [scriptfile]]]
; Applies a theme to PnP/mIRC
; Adds missing theme events
; Loads fonts, sounds regardless of existance
; Preloads ::c1-c4, ::pre, ::bl, ::br
; Only loads bkgs, toolbars if they exist
; Assumes Script, if present, is $_cfg(theme.mrc) or [scriptfile] and exists
; 'loadintohash' should be the prefix to use for .theme and .events (defaults to pnp)
; Assumes that all settings are otherwise 'valid' and present
; flags determines what steps to follow and what to load
; h- load into theme hashes (otherwise assumes x.theme and x.events are loaded)
; l- load from hashfile
; s- save to hashfile
; v- set vars ::c1-c4, ::pre, :;bl, ::br
; c- load script
; t- load timestamp setting
; x- only load timestamp it matches current timestamp stripped
; o- apply timestamp on/off to windows
; m- apply mirc colors
; r- apply rgb colors
; a- update display aliases
; e- run LOAD event
; f- load fonts/backgrounds
; i- load images (toolbars)
; n- refresh nicklist colors
alias -l theme.apply {
  var %themehash = pnp.theme
  var %eventhash = pnp.events
  if ($4) {
    %themehash = pnp. $+ $4 $+ .theme
    %eventhash = pnp. $+ $4 $+ .events
  }
  var %themescript = $_cfg(theme.mrc)
  if ($5) %themescript = $5-
  var %themefile,%eventfile
  %themefile = $3 $+ 1
  %eventfile = $3 $+ 2

  if (h isin $2) {
    ; Clear tables
    if ($hget(%themehash)) hdel -w %themehash *
    else hmake %themehash 20
    if ($hget(%eventhash)) hdel -w %eventhash *
    else hmake %eventhash 20

    ; Load from precompiled files? (make sure location exists)
    if ((l isin $2) && ($isfile(%themefile)) && ($isfile(%eventfile))) {
      hload -b %themehash " $+ %themefile $+ "
      hload -b %eventhash " $+ %eventfile $+ "
      goto skiphashes
    }

    ; Precompile prefix, bolds, and grab basecolors
    var %base = $hget($1,BaseColors)
    var %boldl = $eval($theme.precompile(prefix,$null,$null,$null,%base,$hget($1,BoldLeft)),2)
    var %boldr = $eval($theme.precompile(prefix,$null,$null,$null,%base,$hget($1,BoldRight)),2)
    var %prefix = $eval($theme.precompile(prefix,$null,%boldl,%boldr,%base,$hget($1,Prefix)),2)
    var %parentext = $hget($1,ParenText)
    ; (ensure contains <text> and a ^O)
    if (<text> !isin %parentext) %parentext = (<text>)
    elseif (<text> !isin %parentext) %parentext = $replace(%parentext,<text>,<text>)
    %parentext = $theme.precompile(prefix,%prefix,%boldl,%boldr,%base,%parentext)

    ; Network prefix items (allowed to be blank, but not missing- if missing, defaults to the other, else a normal default)
    var %netprefix,%netnickprefix
    if ($hfind($1,PnPNetworkPrefix,0)) %netprefix = $hget($1,PnPNetworkPrefix)
    elseif ($hfind($1,PnPNetNickPrefix,0)) %netprefix = $hget($1,PnPNetNickPrefix)
    else %netprefix = <bl>[<br> <network> <bl>]<br>
    if ($hfind($1,PnPNetNickPrefix,0)) %netnickprefix = $hget($1,PnPNetNickPrefix)
    elseif ($hfind($1,PnPNetworkPrefix,0)) %netnickprefix = $hget($1,PnPNetworkPrefix)
    else %netnickprefix = <bl>[<br> <network> $chr(58) <me> <bl>]<br>

    ; Precompile network prefixes
    %netprefix = $theme.precompile(prefix,%prefix,%boldl,%boldr,%base,%netprefix)
    %netnickprefix = $theme.precompile(prefix,%prefix,%boldl,%boldr,%base,%netnickprefix)

    ; Store compiled prefix, bold, linesep, parentext
    ; Eval prefix bold and linesep at this time (they shouldn't contain dynamics!)
    hadd %eventhash Prefix %prefix
    hadd %eventhash BoldLeft %boldl
    hadd %eventhash BoldRight %boldr
    hadd %eventhash ParenText %parentext
    hadd %eventhash PnPNetworkPrefix %netprefix
    hadd %eventhash PnPNetNickPrefix %netnickprefix
    if ($hget($1,LineSep) != OFF) hadd %eventhash LineSep $eval($theme.precompile(prefix,%prefix,%boldl,%boldr,%base,$ifmatch),2)
    else hadd %eventhash LineSep

    ; Load all items into pnp.theme; load events into pnp.events (compiled)
    var %count = $hget($1,0).item
    while (%count >= 1) {
      var %item = $hget($1,%count).item
      var %data = $hget($1,%item)
      if (%data != $null) {
        ; Add to normal table
        hadd %themehash %item %data
        ; Add to events table
        if ($theme.itemtype(%item) == e) {
          ; Parse if not already a !Script
          if (!Script * !iswm %data) hadd %eventhash %item $theme.precompile(%item,%prefix,%boldl,%boldr,%base,%data)
          ; else, remove !Script
          else hadd %eventhash %item $gettok(%data,2-,32)
        }
      }
      dec %count
    }

    ; Load missing events
    window -hnl @.thash
    loadbuf @.thash "script\events.mtp"
    var %line = 1,%max = $line(@.thash,0)
    while (%line <= %max) {
      var %data = $line(@.thash,%line)
      var %item = $gettok(%data,1,32)
      ; Add if missing
      if ($hget(%eventhash,%item) == $null) {
        ; Parse if not already a !Script
        if (& !Script * !iswm %data) hadd %eventhash %item $theme.precompile(%item,%prefix,%boldl,%boldr,%base,$gettok(%data,2-,32))
        ; else, remove !Script
        else hadd %eventhash %item $gettok(%data,3-,32)
      }
      inc %line
    }
    window -c @.thash

    ; Verify TextQuerySelf, ActionQuerySelf are valid ('me' instead of 'nick')
    var %tqs = $hget(%eventhash,TextQuerySelf)
    var %aqs = $hget(%eventhash,ActionQuerySelf)
    if ((::nick isin %tqs) && (::me !isin %tqs)) {
      hadd %eventhash TextQuerySelf $replace(%tqs,::nick,::me)
    }
    if ((::nick isin %aqs) && (::me !isin %aqs)) {
      hadd %eventhash ActionQuerySelf $replace(%aqs,::nick,::me)
    }

    ; Generate Echo and EchoTarget if missing or invalid
    var %echo = $hget(%eventhash,Echo)
    if (((% $+ :echo * iswm %echo) && (::text !isin %echo)) || (%echo == $null)) {
      %echo = % $+ :echo %prefix % $+ ::text
      hadd %eventhash Echo %echo
    }
    var %echot = $hget(%eventhash,EchoTarget)
    if ((% $+ :echo * iswm %echot) || (%echot == $null)) {
      %echot = $replace(%echot,::chan,::target,::nick,::target)
      if ((::text !isin %echot) || (::target !isin %echot)) {
        if (% $+ :echo * iswm %echo) %echot = $replace(%echo,% $+ ::text,$!chr(91) $!+ $!:s(%::target) $!+ $!chr(93) % $+ ::text)
        else %echot = % $+ :echo %prefix $!chr(91) $!+ $!:s(%::target) $!+ $!chr(93) % $+ ::text
      }
      hadd %eventhash EchoTarget %echot
    }

    ; Determine if we should add custom WHOIS and/or WHOWAS event
    if (($hget(%eventhash,RAW.311) == $null) && ($hget(%eventhash,RAW.318) == $null) && ($hget(%eventhash,Whois) == $null)) {
      hadd %eventhash Whois _pnptheme.whois
      hadd %eventhash RAW.318 _pnptheme.endofwhois
    }
    if (($hget(%eventhash,RAW.314) == $null) && ($hget(%eventhash,RAW.369) == $null) && ($hget(%eventhash,Whowas) == $null)) {
      hadd %eventhash Whowas _pnptheme.whois was
    }

    ; Determine LineSep status for JoinSelf and Names (Raws 353 and 366)
    hadd %eventhash JoinSelfLineSep $iif($theme.hassep(%eventhash,JoinSelf,%themescript,1,1),0,1)
    hadd %eventhash Raw353LineSep $iif($theme.hassep(%eventhash,RAW.353,%themescript,1,0),0,1)
    hadd %eventhash Raw366LineSep $iif($theme.hassep(%eventhash,RAW.366,%themescript,1,1),0,1)
  }

  ; Save to precompiled files?
  if ((s isin $2) && ($isdir($nofile(%themefile))) && ($3)) {
    hsave -bo %themehash " $+ %themefile $+ "
    hsave -bo %eventhash " $+ %eventfile $+ "
  }

  :skiphashes

  ; Preset certain theme items
  if (v isin $2) {
    unset %::*
    %::c1 = $gettok($hget(%themehash,BaseColors),1,44)
    %::c2 = $gettok($hget(%themehash,BaseColors),2,44)
    %::c3 = $gettok($hget(%themehash,BaseColors),3,44)
    %::c4 = $gettok($hget(%themehash,BaseColors),4,44)
    %::bl = $hget(%eventhash,BoldLeft)
    %::br = $hget(%eventhash,BoldRight)
    %::pre = $hget(%eventhash,Prefix)
  }

  if (c isin $2) {
    ; Load script
    if ($hget($1,Script) != $null) .reload -rs $+ $calc($script(0) - 2) " $+ %themescript $+ "
  }

  ; Timestamp
  var %ts = $hget(%themehash,TimeStamp)
  var %tsf = $hget(%themehash,TimeStampFormat)

  if ((t isin $2) && (%tsf != $null)) {
    %tsf = $eval($theme.precompile(prefix,$hget(%eventhash,Prefix),$hget(%eventhash,BoldLeft),$hget(%eventhash,BoldRight),$hget(%themehash,BaseColors),%tsf),2)
    if ((x !isin $2) || ($strip(%tsf) == $strip($timestampfmt))) .timestamp -f %tsf
  }

  if (o isin $2) {
    saveini
    flushini " $+ $mircini $+ "
    if (%ts == OFF) {
      ; Disable for all windows
      .timestamp off
      .timestamp -e default
      remini " $+ $mircini $+ " timestamp
      flushini " $+ $mircini $+ "
    }
    elseif (%ts) {
      .timestamp on
      ; (don't enable on a window-by-window basis)
    }
  }

  if (m isin $2) {
    ; mIRC colors (skip ?'s/blanks if any)
    var %num = 1,%cols = $hget(%themehash,Colors),%area = b.a.c.h.i.info2.inv.j.k.m.n.no.not.notif.o.ow.p.q.t.w.wh.e.editbox t.l.listbox t.g
    while (%num <= 26) {
      if ($gettok(%cols,%num,44) isnum) {
        if ($color($gettok(%area,%num,46)) != $gettok(%cols,%num,44)) {
          color $gettok(%area,%num,46) $gettok(%cols,%num,44)
          ; set inactive?
          if ($gettok(%area,%num,46) == e) color ina $gettok(%cols,%num,44)
        }
      }
      inc %num
    }
  }

  if (r isin $2) {
    ; RGB colors
    var %num = 0,%cols = $hget(%themehash,RGBColors)
    while (%num <= 15) {
      if ($rgb( [ $gettok(%cols,$calc(%num + 1),32) ] ) != $color(%num)) color %num $ifmatch
      inc %num
    }
  }

  if (a isin $2) {
    ; Update display aliases
    theme.alias %themehash %eventhash
  }

  if (e isin $2) {  
    ; Run LOAD event
    set -u %:echo echo $:c1 -sti2
    set -u %:linesep disps-div
    theme.text load
  }

  ; Fonts / Backgrounds
  if (f isin $2) {
    var %fontdef = $hget(%themehash,FontDefault)
    var %fontchan = $hget(%themehash,FontChan)
    var %fontquery = $hget(%themehash,FontQuery)
    var %fontdcc = $hget(%themehash,FontDCC)
    var %fontscript = $hget(%themehash,FontScript)
    var %bkgdef = $hget(%themehash,ImageStatus)
    var %bkgchan = $hget(%themehash,ImageChan)
    var %bkgquery = $hget(%themehash,ImageQuery)
    var %bkgscript = $hget(%themehash,ImageScript)
    var %didq,%didc

    ; (save remote scripts font as we don't touch that)
    var %mifs = $readini($mircini,n,fonts,fscripts)
    saveini
    flushini " $+ $mircini $+ "
    remini " $+ $mircini $+ " fonts
    remini " $+ $mircini $+ " background
    flushini " $+ $mircini $+ "

    ; Change open windows (all CIDs)
    var %active = $active
    var %scon = $scon(0)
    while (%scon) {
      scon %scon
      %num = 1
      while (%num <= $window(*,0)) {
        var %name = $window(*,%num)
        var %state = $window(%name).state
        var %font = %fontdef
        var %bk = %bkgdef
        var %switch = -
        var %bkname = %name
        if (@* iswm %name) {
          ; Skip @* if not first scon (IE only do them once)
          if (%scon != 1) {
            inc %num
            continue
          }
          ; Only apply to windows we opened, and only if they aren't pic/listbox
          var %flags = $hget(pnp.window. $+ %name,flags)
          if ((!%flags) || (p isin %flags) || (l isin %flags)) %switch =
          else %bk = %bkgscript
          %font = %fontscript
        }
        elseif (%name ischan) {
          %font = %fontchan
          %bk = %bkgchan
          %switch = -e
          %didc = 1
        }
        elseif ((=* iswm %name) || ($query(%name)) || (%name == Message Window)) {
          ; Skip =* if not first scon (IE only do them once)
          if ((=* iswm %name) && (%scon != 1)) {
            inc %num
            continue
          }
          if (%name == Message Window) {
            %switch = -d
            %bkname =
          }
          else %switch = -e
          %font = %fontquery
          %bk = %bkgquery
          %didq = 1
        }
        elseif ((Send * iswm %name) || (Get * iswm %name)) {
          ; Skip if not first scon (IE only do them once)
          if (%scon != 1) {
            inc %num
            continue
          }
          %font = %fontdcc
          %switch =
        }
        elseif (%name == Finger Window) {
          %switch = -g
          %bkname =
        }
        elseif (%name == Status Window) {
          %switch = -s
          %bkname =
        }
        else %switch =
        var %wname = %name
        if (=* !iswm %name) %wname = " $+ %name $+ "
        window -a %wname
        font $iif($gettok(%font,3,44),-ab,-a) $gettok(%font,2,44) $gettok(%font,1,44)
        if (%state == minimized) window -n %wname
        elseif (%state == hidden) window -h %wname
        ; (bk uses diff switches- can't use -a)
        if (%switch) {
          ; (blackbox so erroneous files for bk don't halt this script)
          if ($theme.ff($hget(%themehash,Filename),$gettok(%bk,2-,32))) {
            .background $remove(%switch,e) $+ x %bkname
            _blackbox .background %switch $+ $mid(cfnrtp,$findtok(center fill normal stretch tile photo,$gettok(%bk,1,32),1,32),1) %bkname " $+ $ifmatch $+ "
          }
          else .background $remove(%switch,e) $+ x %bkname
        }
        inc %num
      }
      dec %scon
    }
    if (!%didq) {
      if ($theme.ff($hget(%themehash,Filename),$gettok(%bkgquery,2-,32))) {
        .background -x allquery
        _blackbox .background -e $+ $mid(cfnrtp,$findtok(center fill normal stretch tile photo,$gettok(%bkgquery,1,32),1,32),1) allquery " $+ $ifmatch $+ "
      }
    }
    if (!%didc) {
      if ($theme.ff($hget(%themehash,Filename),$gettok(%bkgchan,2-,32))) {
        .background -x #allchan
        _blackbox .background -e $+ $mid(cfnrtp,$findtok(center fill normal stretch tile photo,$gettok(%bkgchan,1,32),1,32),1) #allchan " $+ $ifmatch $+ "
      }
    }
    scon -r
    saveini
    flushini " $+ $mircini $+ "

    ; (reactivate window that was active before)
    if (%active != $active) {
      if (=* iswm %active) window -a %active
      else window -a " $+ %active $+ "
    }

    ; Flush my custom fonts saved to window.ini
    if ($exists($_cfg(window.ini))) {
      filter -ffxc $_cfg(window.ini) $_cfg(window.ini) font=*
    }

    ; Write to ini
    %fontdef = $font.mirc(%fontdef)
    %fontchan = $font.mirc(%fontchan)
    %fontquery = $font.mirc(%fontquery)
    %fontdcc = $font.mirc(%fontdcc)

    writeini " $+ $mircini $+ " fonts fchannel %fontchan
    writeini " $+ $mircini $+ " fonts fquery %fontquery
    writeini " $+ $mircini $+ " fonts fmessage %fontquery
    writeini " $+ $mircini $+ " fonts fdccs %fontdcc
    writeini " $+ $mircini $+ " fonts fdccg %fontdcc
    writeini " $+ $mircini $+ " fonts fnotify %fontdef
    writeini " $+ $mircini $+ " fonts fwwwlist %fontdef
    writeini " $+ $mircini $+ " fonts flist %fontdef
    writeini " $+ $mircini $+ " fonts flinks %fontdef
    writeini " $+ $mircini $+ " fonts ffinger %fontdef
    writeini " $+ $mircini $+ " fonts fstatus %fontdef
    if (%mifs != $null) writeini " $+ $mircini $+ " fonts fscripts %mifs

    flushini " $+ $mircini $+ "
  }

  if (i isin $2) {  
    ; Non-standard image items
    if ($theme.ff($hget(%themehash,Filename),$gettok($hget(%themehash,ImageMirc),2-,32))) _blackbox background -m $+ $mid(cfnrtp,$findtok(center fill normal stretch tile photo,$gettok($hget(%themehash,ImageMirc),1,32),1,32),1) " $+ $ifmatch $+ "
    else background -mx
    if ($theme.ff($hget(%themehash,Filename),$gettok($hget(%themehash,ImageToolbar),2-,32))) _blackbox background -l " $+ $ifmatch $+ "
    else background -lx
    if ($theme.ff($hget(%themehash,Filename),$gettok($hget(%themehash,ImageSwitchbar),2-,32))) _blackbox background -h " $+ $ifmatch $+ "
    else background -hx
    if ($theme.ff($hget(%themehash,Filename),$hget(%themehash,ImageButtons))) _blackbox background -u " $+ $ifmatch $+ "
    else background -ux
  }

  if (n isin $2) {
    ; Refresh nicklist
    .nickcol
  }
}

; /_theme.start
; Loads current, existing theme into mIRC
alias _theme.start {
  ; If mtp, ct1, and ct2 all exist, we can do a special quick load
  if (($isfile($_cfg(theme.mtp))) && ($isfile($_cfg(theme.ct1))) && ($isfile($_cfg(theme.ct2)))) {
    theme.apply mts.start hlvctax $_cfg(theme.ct)

    ; Startup sound
    _ssplay Start

    return
  }
  elseif ($isfile($_cfg(theme.mtp))) {
    ; Preload current theme into hash, NOT including mIRC settings except timestamp if needed
    theme.hash -t mts.start $_cfg(theme.mtp)

    ; Error loading? reset theme file.
    if ($result) {
      hfree mts.start
      .remove " $+ $_cfg(theme.mtp) $+ "
      ; (falls through to auto-generation below)
    }

    else {
      ; Load theme into mIRC (ignoring any precreated hash files, but recreate them)
      theme.apply mts.start hsvctax $_cfg(theme.ct)

      ; Cleanup
      hfree mts.start

      ; Startup sound
      _ssplay Start

      return
    }
  }

  ; No theme? Special situation- most likely first time loaded; possibly, theme was lost
  ; Load pnp theme and current settings in so we can auto-generate some things
  theme.hash -m mts.start script\defcfg\theme.mtp

  ; Apply some defaults
  ; Only change nickcolors from normal defaults if our mirc bk is not white (or close)
  var %rgb = $calc($replace($gettok($hget(pnp.theme,rgbcolors),$calc($gettok($hget(pnp.theme,colors),1,44) + 1),32),$chr(44),+))
  if (%rgb < 730) theme.def mts.start pnpnickcolors 1
  theme.def mts.start basecolors
  theme.def mts.start colorerror
  theme.def mts.start linesep 1
  theme.def mts.start prefix 1

  ; Save and apply
  theme.save +ipnled mts.start $_cfg(theme.mtp)
  theme.apply mts.start hsvca $_cfg(theme.ct)
  hfree mts.start
}

; After translation we must reload theme events (events may change)
on *:SIGNAL:PNP.TRANSLATE:{ theme.transreload }

; Reapplies default events after a translation
alias theme.transreload {
  var %base = $hget(pnp.theme,BaseColors)
  var %boldl = $hget(pnp.events,BoldLeft)
  var %boldr = $hget(pnp.events,BoldRight)
  var %prefix = $hget(pnp.events,Prefix)

  ; Reload missing events (check pnp.theme to know if it was missing before)
  window -hnl @.thash
  loadbuf @.thash "script\events.mtp"
  var %line = 1,%max = $line(@.thash,0)
  while (%line <= %max) {
    var %data = $line(@.thash,%line)
    var %item = $gettok(%data,1,32)
    ; Add if missing
    if ($hget(pnp.theme,%item) == $null) {
      ; Parse if not already a !Script
      if (& !Script * !iswm %data) hadd pnp.events %item $theme.precompile(%item,%prefix,%boldl,%boldr,%base,$gettok(%data,2-,32))
      ; else, remove !Script
      else hadd pnp.events %item $gettok(%data,3-,32)
    }
    inc %line
  }
  window -c @.thash

  ; Save to precompiled files?
  if ($isfile($_cfg(theme.ct2))) {
    hsave -bo pnp.events " $+ $_cfg(theme.ct2) $+ "
  }
}

; /theme.alias themehash eventhash
; Updates dynamic aliases using pnp.theme / pnp.events aliases
alias theme.alias {
  var %base = $hget($1,BaseColors)
  var %error = $hget($1,ColorError)
  var %boldl = $hget($2,BoldLeft)
  var %boldr = $hget($2,BoldRight)
  var %linesep = $hget($2,LineSep)
  var %prefix = $hget($2,Prefix)

  ; Create alias file
  window -hln @.themeals
  aline @.themeals ; #= P&P.theme -a
  aline @.themeals ; @======================================:
  aline @.themeals ; $chr(124)  Peace and Protection                $chr(124)
  aline @.themeals ; $chr(124)  Theme aliases (*auto-generated*)    $chr(124)
  aline @.themeals ; `======================================'

  ; BaseColors
  aline @.themeals :c1 return $gettok(%base,1,44)
  aline @.themeals :c2 return $gettok(%base,2,44)
  aline @.themeals :c3 return $gettok(%base,3,44)
  aline @.themeals :c4 return $gettok(%base,4,44)
  aline @.themeals :cerr return %error

  ; Single (target) highlight; multiple Highlight; Warning; Bold; Target (bold+single); List of targets; Quoted
  aline @.themeals :s return  $+ $gettok(%base,2,44) $!+ $!1- $!+ 
  aline @.themeals :h return  $+ $gettok(%base,3,44) $!+ $!1- $!+ 
  aline @.themeals :w return  $+ %error $!+ $!1- $!+ 
  aline @.themeals :b return %boldl $iif(%boldl != $null,$!+) $!1- $iif(%boldr != $null,$!+) %boldr
  aline @.themeals :t return %boldl $+  $+ $gettok(%base,2,44) $!+ $!1- $!+  $+ %boldr
  aline @.themeals :l var % $+ colcma $chr(124) % $+ colcma =  $+ %boldr $+ , %boldl $+  $+ $gettok(%base,2,44) $chr(124) return %boldl $+  $+ $gettok(%base,2,44) $!+ $!replace($_s2c($1-),$chr(44),%colcma) $!+  $+ %boldr
  aline @.themeals :q return  $+ $gettok(%base,3,44) $+ ' $!+ $!1- $!+  $+ $gettok(%base,3,44) $+ '

  ; Line separator, prefix
  aline @.themeals ::: return %linesep
  aline @.themeals :* return %prefix

  ; Network identifiers
  aline @.themeals :np return $replace($hget($2,PnPNetworkPrefix),% $+ ::network,$!hget(pnp. $!+ $!cid,net))
  aline @.themeals :nnp return $replace($hget($2,PnPNetNickPrefix),% $+ ::network,$!hget(pnp. $!+ $!cid,net))

  ; Echo and EchoTarget- precompile to a single line if possible, else call theme item after setting :echo and ::text
  var %echo = $hget($2,Echo)
  var %echo2
  if ($gettok(%echo,1,32) == % $+ :echo) {
    %echo2 = echo $gettok(%base,1,44) -- $replace($gettok(%echo,2-,32),% $+ ::text,$!2-)
    %echo = echo $gettok(%base,1,44) -- $replace($gettok(%echo,2-,32),% $+ ::text,$!1-)
  }
  else {
    %echo2 = set -u % $+ :echo echo $gettok(%base,1,44) -- $chr(124) set -u % $+ ::text $!2- $chr(124) %echo
    %echo = set -u % $+ :echo echo $gettok(%base,1,44) -- $chr(124) set -u % $+ ::text $!1- $chr(124) %echo
  }

  var %echot = $hget($2,EchoTarget)
  var %echotpre
  var %echot2
  var %echotpre2
  var %echot3
  var %echotpre3
  var %echot4
  var %echotpre4
  if ($gettok(%echot,1,32) == % $+ :echo) {
    %echot4 = echo $gettok(%base,1,44) -- $replace($gettok(%echot,2-,32),% $+ ::text,$!3-,% $+ ::target,$!:b($2))
    %echot2 = echo $gettok(%base,1,44) -- $replace($gettok(%echot,2-,32),% $+ ::text,$!2-,% $+ ::target,$!:b($1))
    if ($hget($1,ChannelsLowercase)) {
      %echot3 = echo $gettok(%base,1,44) -- $replace($gettok(%echot,2-,32),% $+ ::text,$!3-,% $+ ::target,$!lower($2))
      %echot = echo $gettok(%base,1,44) -- $replace($gettok(%echot,2-,32),% $+ ::text,$!2-,% $+ ::target,$!lower($1))
    }
    else {
      %echot3 = echo $gettok(%base,1,44) -- $replace($gettok(%echot,2-,32),% $+ ::text,$!3-,% $+ ::target,$!2)
      %echot = echo $gettok(%base,1,44) -- $replace($gettok(%echot,2-,32),% $+ ::text,$!2-,% $+ ::target,$!1)
    }
  }
  else {
    %echot4 = set -u % $+ :echo echo $gettok(%base,1,44) -- $chr(124) %echot
    %echot3 = set -u % $+ :echo echo $gettok(%base,1,44) -- $chr(124) %echot
    %echot2 = set -u % $+ :echo echo $gettok(%base,1,44) -- $chr(124) %echot
    %echotpre4 = set -u % $+ ::text $!3- $chr(124) set -u % $+ ::target $!:b($2) $chr(124)
    %echotpre2 = set -u % $+ ::text $!2- $chr(124) set -u % $+ ::target $!:b($1) $chr(124)
    %echot = set -u % $+ :echo echo $gettok(%base,1,44) -- $chr(124) %echot
    if ($hget($1,ChannelsLowercase)) {
      %echotpre3 = set -u % $+ ::text $!3- $chr(124) set -u % $+ ::target $!lower($2) $chr(124)
      %echotpre = set -u % $+ ::text $!2- $chr(124) set -u % $+ ::target $!lower($1) $chr(124)
    }
    else {
      %echotpre3 = set -u % $+ ::text $!3- $chr(124) set -u % $+ ::target $!2 $chr(124)
      %echotpre = set -u % $+ ::text $!2- $chr(124) set -u % $+ ::target $!1 $chr(124)
    }
  }

  ; Disp- active or status based on configuration; uses Echo
  aline @.themeals disp $reptok(%echo,--,$_cfgi(eroute) $+ qt $iif(a isin $_cfgi(eroute),$!iif($activecid != $!cid,$:anp)),1,32)

  ; Dispw- active or status based on raw configuration; uses Echo
  aline @.themeals dispw $reptok(%echo,--,$hget(pnp.config,rawroute) $+ qt $iif(a isin $_cfgi(rawroute),$!iif($activecid != $!cid,$:anp)),1,32)

  ; Dispa- active; uses Echo
  aline @.themeals dispa $reptok(%echo,--,-ai2qt $!iif($activecid != $!cid,$:anp),1,32)

  ; Disps- status; uses Echo
  aline @.themeals disps $reptok(%echo,--,-si2qt,1,32)

  ; Dispr- routed to window, status if not open; uses Echo
  aline @.themeals dispr if (-*a* iswm $!1) dispa $!2- $chr(124) elseif ((-*s* iswm $!1) || ($window($1) != $!1)) disps $!2- $chr(124) else $chr(123) $reptok(%echo2,--,-i2qt $!1,1,32) $chr(125)

  ; Disprc- routed to channel, rawconfig if not open; uses EchoTarget (lowercases channel if applicable)
  ; Disptc- shown to any window (including -s/-a) or rawconfig if not open; uses EchoTarget (lowercases channel if applicable)
  ; /disptc window channame text
  if (-*s* iswm $hget(pnp.config,rawroute)) {
    aline @.themeals disprc %echotpre if ($1 ischan) $chr(123) $reptok(%echot,--,-i2qt $!1,1,32) $chr(125) $chr(124) else $chr(123) $reptok(%echot,--,-si2qt,1,32) $chr(125)
    aline @.themeals disptc %echotpre3 if ($window($1) == $!1) $chr(123) $reptok(%echot3,--,-i2qt $!1,1,32) $chr(125) $chr(124) elseif (-*a* iswm $!1) $chr(123) $reptok(%echot3,--,-ai2qt $!iif($activecid != $!cid,$:anp),1,32) $chr(125) $chr(124) else $chr(123) $reptok(%echot3,--,-si2qt,1,32) $chr(125)
  }
  else {
    aline @.themeals disprc %echotpre if ($1 ischan) $chr(123) $reptok(%echot,--,-i2qt $!1,1,32) $chr(125) $chr(124) else $chr(123) $reptok(%echot,--,-ai2qt $!iif($activecid != $!cid,$:anp),1,32) $chr(125)
    aline @.themeals disptc %echotpre3 if ($window($1) == $!1) $chr(123) $reptok(%echot3,--,-i2qt $!1,1,32) $chr(125) $chr(124) elseif (-*s* iswm $!1) $chr(123) $reptok(%echot3,--,-si2qt,1,32) $chr(125) $chr(124) else $chr(123) $reptok(%echot3,--,-ai2qt $!iif($activecid != $!cid,$:anp),1,32) $chr(125)
  }

  ; Disprn- routed to query, active if not open; uses EchoTarget (bolds target)
  aline @.themeals disprn %echotpre2 if ($query($1)) $chr(123) $reptok(%echot2,--,-i2qt $!1,1,32) $chr(125) $chr(124) else $chr(123) $reptok(%echot2,--,-ai2qt $!iif($activecid != $!cid,$:anp),1,32) $chr(125)

  ; Disptn- shown to any window (including -s/-a) or active if not open; uses EchoTarget (bolds target as if nickname)
  ; /disptn window nickname text
  aline @.themeals disptn %echotpre4 if ($window($1) == $!1) $chr(123) $reptok(%echot4,--,-i2qt $!1,1,32) $chr(125) $chr(124) elseif (-*s* iswm $!1) $chr(123) $reptok(%echot4,--,-si2qt,1,32) $chr(125) $chr(124) else $chr(123) $reptok(%echot4,--,-ai2qt $!iif($activecid != $!cid,$:anp),1,32) $chr(125)

  ; Dividers- Like disp* but always displays divider, only if not present, and if shown, returns true.
  ; Lineseps uses ^K^K^O to mark a linesep line
  if (%linesep == $null) {
    aline @.themeals dispa-div return 0
    aline @.themeals disps-div return 0
    aline @.themeals dispr-div return 0
  }
  else {
    aline @.themeals dispa-div if ( !isin $!line($active,$line($active,0))) $chr(123) $reptok($reptok(%echo,--,-ai2qt,1,32),$!1-,%linesep $+ ,1,32) $chr(124) return 1 $chr(125) $chr(124) return 0
    aline @.themeals disps-div if ( !isin $!line(Status Window,$line(Status Window,0))) $chr(123) $reptok($reptok(%echo,--,-si2qt,1,32),$!1-,%linesep $+ ,1,32) $chr(124) return 1 $chr(125) $chr(124) return 0
    aline @.themeals dispr-div if (-*a* iswm $!1) return $!dispa-div $chr(124) elseif ((-*s* iswm $!1) || ($window($1) != $!1)) return $!disps-div $chr(124) elseif ( !isin $!line($1,$line($1,0))) $chr(123) $reptok($reptok(%echo,--,-i2qt $!1,1,32),$!1-,%linesep $+ ,1,32) $chr(124) return 1 $chr(125) $chr(124) return 0
  }

  ; Save to theme alias file and reload
  var %script = $_cfg(themeals.mrc)
  savebuf @.themeals " $+ %script $+ "
  if ($alias(themeals.mrc)) .unload -a " $+ $ifmatch $+ "
  .load -a " $+ %script $+ "
  window -c @.themeals
}

; /theme.delete file
; Deletes a theme and any files it links to
; Deletes the subdir the theme is in if it's empty and within THEMES
alias -l theme.delete {
  ; Check file exists
  if (!$isfile($1-)) return
  if (!$theme.issec($1-,mts)) return

  ; Load theme and all schemes into one window
  window -hnl @.tdel
  loadbuf -tmts @.tdel " $+ $1- $+ "

  ; Scan through all lines for filenames, and scheme numbers (loading more schemes in as found)
  var %ln = 1
  while (%ln <= $line(@.tdel,0)) {
    var %line = $line(@.tdel,%ln)
    if (;* !iswm %line) {
      var %item = $gettok(%line,1,32)
      var %data = $gettok(%line,2-,32)
      ; Scheme?
      if (Scheme* iswm %item) {
        var %scheme = $mid(%item,7)
        if ($theme.issec($1-,scheme $+ %scheme)) loadbuf -tscheme $+ %scheme @.tdel " $+ $1- $+ "
      }
      ; Line with filename?
      elseif ((Snd* iswm %item) || (Image* iswm %item) || (Script == %item)) {
        if ((Image* iswm %item) && (%item != ImageButtons)) %data = $gettok(%data,2-,32)
        ; Only delete if in same directory; automatically skips blank items as isfile will fail
        var %data = $nofile($1-) $+ $nopath(%data)
        if ($isfile(%data)) .remove -b " $+ %data $+ "
      }
    }
    inc %ln
  }

  window -c @.tdel

  ; Delete file itself
  .remove -b " $+ $1- $+ "

  ; Delete directory?
  if ($mircdirthemes\?* iswm $nofile($1-)) {
    if ($findfile($nofile($1-),*,1) == $null) {
      .rmdir " $+ $nofile($1-) $+ "
    }
  }
}

; /theme.check hash type [-e]
; Checks setting in a hash for correctness
; Displays warnings/errors if -e present
; Sets %.warning to any warnings or errors found, then corrects or removes line
; Path-fills filenames, replaces <c?> in color lines, 0-fills colors
; Do basecolors first, as this affects other settings being checked
; Type should be an item, or 'others' to check sounds and events.
alias -l theme.check {
  var %data,%regex,%junk,%dozeros
  goto $2

  :timestamp
  %data = $hget($1,$2)
  if ((%data != ON) && (%data != OFF) && (%data)) {
    hadd $1 TimeStampFormat %data
    hadd $1 $2 ON
  }
  return

  :basecolors
  %dozeros = 1
  %regex = $left($str(\d\d? $+ $chr(44),4),-1)
  goto formatcheck

  :colors
  %dozeros = 1
  ; (25 or more toks)
  %regex = $left($str((\?|\d\d?) $+ $chr(44),25),-1) $+ .*
  goto colorreplace

  :clineowner
  :clineop
  :clinehop
  :clinevoice
  :clineregular
  :clineircop
  :clineenemy
  :clinefriend
  :clineme
  :clinemisc
  :colorerror
  %dozeros = 1
  %regex = \d\d?
  goto colorreplace

  :pnpnickcolors
  %dozeros = 1
  %regex = $left($str($left($str((\?|\d\d?) $+ $chr(32),8),-1) $+ $chr(44),4),-1)
  goto colorreplace

  :rgbcolors
  %regex = $left($str($left($str([0-2]?\d?\d $+ $chr(44),3),-1) $+ $chr(32),16),-1)
  goto formatcheck

  :channelslowercase
  :linesepwhois
  %regex = 0|1
  goto formatcheck

  :fontdefault
  :fontchan
  :fontquery
  :fontscript
  :fontdcc
  %regex = [^,]+,-?\d\d?(,b)?
  goto formatcheck

  ; Replace <c1><c2><c3><c4> and proceed to formatcheck
  :colorreplace
  %data = $hget($1,$2)
  var %base = $hget($1,BaseColors)
  %data = $replace(%data,<c1>,$gettok(%base,1,44),<c2>,$gettok(%base,2,44),<c3>,$gettok(%base,3,44),<c4>,$gettok(%base,4,44))

  ; Clean up commas/spaces and check against %regex
  :formatcheck
  if (%data == $null) %data = $hget($1,$2)
  ; Remove any quotes
  %data = $remove(%data,")
  ; Remove spacing around any commas
  %junk = /\s*,\s*/g
  %junk = $regsub(%data,%junk,$chr(44),%data)
  ; Remove doubled spacing or commas
  %data = $gettok($gettok(%data,1-,44),1-,32)
  ; Test
  if ($regex(%data,/^ $+ %regex $+ $chr(36) $+ /i)) {
    ; Fill zeros?
    if (%dozeros) {
      %junk = $regsub(%data,/(^|\D)(\d)(?=$|\D)/g,\1\2,%data)
      %data = $replace(%data,,0)
    }
    hadd $1 $2 %data
    return
  }
  set -u %.warning $2 $+ : Invalid format
  if (e isin $3) disps Error in theme- %.warning
  hdel $1 $2
  return

  :imagescript
  :imagemirc
  :imagechan
  :imagequery
  :imagestatus
  :imagetoolbar
  :imagebuttons
  :imageswitchbar
  :script
  ; Check filename, pathfill as needed, remove any quotes
  %data = $hget($1,$2)
  var %token,%file
  if ($istok(script imagebuttons,$2,32)) %file = %data
  else {
    ; Check first token- insert one if nonexistant
    %token = $gettok(%data,1,32)
    if ($istok(center fill normal stretch tile photo,%token,32)) {
      %file = $gettok(%data,2-,32)
    }
    else {
      %file = %data
      %token = normal
    }
    if (($2 == imagemirc) && (%token == photo)) %token = normal
    elseif (($2 == imagetoolbar) || ($2 == imageswitchbar)) %token = fill
  }
  if ("?*" iswm %file) %file = $mid(%file,2,-1)
  if (%file != $null) {
    if ($theme.ff($hget($1,Filename),%file)) %file = $ifmatch
    elseif ($nopath(%file) != $null) %file = $nofile($hget($1,Filename)) $+ $nopath(%file)
    else var %file
  }
  if (%file == $null) {
    set -u %.warning $2 $+ : Invalid filename
    if (e isin $3) disps Error in theme- %.warning
    hdel $1 $2
    return
  }
  ; Script? More work to do
  if ($2 == script) goto script2
  hadd $1 $2 %token %file
  return

  :script2
  if (!$isfile(%file)) {
    set -u %.warning $2 $+ : Missing script file
    if (e isin $3) disps Error in theme- %.warning
    hdel $1 $2
    return
  }
  hadd $1 $2 %file
  return

  :others
  var %count = $hget($1,0).item
  while (%count >= 1) {
    var %item = $hget($1,%count).item
    ; Sounds only
    if (Snd* iswm %item) {
      var %file = $hget($1,%item)
      if ("?*" iswm %file) %file = $mid(%file,2,-1)
      if (%file != $null) {
        if ($theme.ff($hget($1,Filename),%file)) %file = $ifmatch
        elseif ($nopath(%file) != $null) %file = $nofile($hget($1,Filename)) $+ $nopath(%file)
        else var %file
      }
      if (%file == $null) {
        set -u %.warning %item $+ : Invalid filename
        if (e isin $3) disps Error in theme- %.warning
        hdel $1 %item
      }
      else hadd $1 %item %file
    }
    ; Events/raws only
    elseif ($theme.itemtype(%item) == e) {
      ; Make sure it isn't a !script line that's blank or with | { } in it
      var %data = $hget($1,%item)
      if ($gettok(%data,1,32) == !Script) {
        if (($numtok(%data,32) == 1) || ($regex(%data,/ [\|\{\}] /))) {
          set -u %.warning %item $+ : Invalid script format
          if (e isin $3) disps Error in theme- %.warning
          hdel $1 %item
        }
      }
    }
    dec %count
  }
  return
}

; /theme.curr hash type
; Load current settings into hash
; Call saveini before using these!
; type is one of: colors, rgbcolors, timestamp, fonts, backgrounds, toolbars
alias -l theme.curr {
  goto $2

  :colors
  var %num = 1,%cols,%area = b.a.c.h.i.info2.inv.j.k.m.n.no.not.notif.o.ow.p.q.t.w.wh.e.editbox t.l.listbox t.g
  while (%num <= 26) {
    %cols = $instok(%cols,$color($gettok(%area,%num,46)),0,44)
    inc %num
  }
  hadd $1 Colors %cols
  return

  :rgbcolors
  var %num = 0,%cols
  while (%num <= 15) {
    %cols = $instok(%cols,$rgb($color(%num)),0,32)
    inc %num
  }
  hadd $1 RGBColors %cols
  return

  :timestampformat
  if (($strip($hget($1,TimeStampFormat)) == $hget($1,TimeStampFormat)) && (<c !isin $hget($1,TimeStampFormat))) hadd $1 TimeStampFormat $timestampfmt
  return

  :timestamp
  ; Use hidden window to check timestamp on/off setting
  window -hn @.tscheck
  if ($window(@.tscheck).stamp) hadd $1 TimeStamp ON
  else hadd $1 TimeStamp OFF
  window -c @.tscheck
  return

  :fonts
  hadd $1 FontDefault $font.cur(status)
  hadd $1 FontChan $font.cur(channel)
  hadd $1 FontQuery $font.cur(query)
  hadd $1 FontDCC $font.cur(dccs)
  return

  :backgrounds
  if ($image.cur(wchannel)) hadd $1 ImageChan $ifmatch
  else hdel $1 ImageChan
  if ($image.cur(wquery)) hadd $1 ImageQuery $ifmatch
  else hdel $1 ImageQuery
  if ($image.cur(@mdi)) hadd $1 ImageMirc $ifmatch
  else hdel $1 ImageMirc
  if ($image.cur(status)) hadd $1 ImageStatus $ifmatch
  else hdel $1 ImageStatus
  return

  :toolbars
  if ($image.cur(toolbar)) hadd $1 ImageToolbar $ifmatch
  else hdel $1 ImageToolbar
  if ($image.cur(switchbar)) hadd $1 ImageSwitchbar $ifmatch
  else hdel $1 ImageSwitchbar
  if ($image.cur(toolbuttons,1)) hadd $1 ImageButtons $ifmatch
  else hdel $1 ImageButtons
  return
}

; /theme.clear hash type
; Clears settings for a given item
; Types: events, script, fonts, backgrounds, toolbars, sounds, info, linesep, nickcolors
alias -l theme.clear {
  goto $2

  :events
  ; Remove all event/raw lines
  window -hln @.mtsrem
  var %count = $hget($1,0).item
  while (%count >= 1) {
    var %item = $hget($1,%count).item
    ; Events/raws only
    if ($theme.itemtype(%item) == e) aline @.mtsrem %item
    dec %count
  }
  ; Delete via a window in case deleting items changes order
  %count = $line(@.mtsrem,0)
  while (%count >= 1) {
    hdel $1 $line(@.mtsrem,%count)
    dec %count
  }
  window -c @.mtsrem
  return

  :script
  hdel mts.edit Script
  return

  :fonts
  hdel mts.edit FontDefault
  hdel mts.edit FontChan
  hdel mts.edit FontQuery
  hdel mts.edit FontScript
  hdel mts.edit FontDCC
  return

  :backgrounds
  hdel mts.edit ImageMirc
  hdel mts.edit ImageStatus
  hdel mts.edit ImageChan
  hdel mts.edit ImageQuery
  hdel mts.edit ImageScript
  return

  :toolbars
  hdel mts.edit ImageToolbar
  hdel mts.edit ImageSwitchbar
  hdel mts.edit ImageButtons
  return

  :sounds
  hdel -w mts.edit Snd*
  return

  :info
  hdel mts.edit Name
  hdel mts.edit Version
  hdel mts.edit Website
  hdel mts.edit Email
  hdel mts.edit Author
  hdel mts.edit Description
  return

  :linesep
  hadd mts.edit LineSep OFF
  hdel mts.edit PnPLineSep
  return

  :nickcolors
  hadd mts.edit PnPNickColors ? ? ? ? ? ? ? ?,? ? ? ? ? ? ? ?,? ? ? ? ? ? ? ?,? ? ? ? ? ? ? ?
  hdel -w mts.edit CLine*
  return
}

; /theme.def hash type [params]
; Load default settings into hash; sometimes based off of other settings so do in order of type
; RGBCOLORS SHOULD ALREADY BE IN HASH FOR ANYTHING BUT RGBCOLORS
; Assumes existing settings are all valid
; type is one of: colors, rgbcolors, pnpnickcolors, basecolors, colorerror, linesep, timestamp,
;  timestampformat, channelslowercase, bold, imagescript, fontdefault, fontchan, fontquery,
;  fontscript, fontdcc, parentext, linesepwhois, prefix
; params- non-zero for pnpnickcolors, linesep, prefix, timestampformat, or fontdefault to force "creation" from scratch
alias -l theme.def {
  goto $2

  :colors
  hadd $1 Colors 0,6,4,5,2,3,3,3,3,3,3,1,5,7,6,1,3,2,3,5,1,0,1,0,1,15
  return

  :rgbcolors
  hadd $1 RGBColors 255,255,255 0,0,0 0,0,128 0,144,0 255,0,0 128,0,0 160,0,160 255,128,0 255,255,0 0,255,0 0,144,144 0,255,255 0,0,255 255,0,255 128,128,128 208,208,208
  return

  :pnpnickcolors
  var %co = $col.blank($hget($1,CLineOP))
  var %ch = $col.blank($hget($1,CLineHOP))
  var %cv = $col.blank($hget($1,CLineVoice))
  var %cr = $col.blank($hget($1,CLineRegular))
  var %cme = $col.blank($hget($1,CLineMe))
  var %cfriend = $col.blank($hget($1,CLineFriend))
  var %cenemy = $col.blank($hget($1,CLineEnemy))
  var %circop = $col.blank($hget($1,CLineIrcOP))
  var %cmisc = $col.blank($hget($1,CLineMisc))

  ; Create colors if none exist at all
  if (($3) || ($remove(%co %ch %cv %cr %cme %cfriend %cenemy %circop %cmisc,$chr(32),?) == $null)) {
    var %sort = $col.sort($gettok($hget($1,Colors),1,44),$1)
    ; Order to use- *,lag,ping,ircop,friend,enemy,norm
    ; Op/Half use an alternate (brighter if possible) version of a color
    ; Remove these alternate colors as they are used up
    var %grab = 1
    while (%grab <= 6) {
      ; Create vars separate from setting as var with [ ] can mess up
      ; Get last color
      var % [ $+ [ %grab ] ]
      set % [ $+ [ %grab ] ] $gettok(%sort,-1,44)
      ; Get alternate version of last color
      var %b [ $+ [ %grab ] ]
      set %b [ $+ [ %grab ] ] $col.similar(% [ $+ [ %grab ] ] ,$1,%sort)
      ; Remove these colors from list
      %sort = $remtok($remtok(%sort,% [ $+ [ %grab ] ] ,1,44),%b [ $+ [ %grab ] ] ,1,44)
      inc %grab
    }
    ; Create list of colors
    hadd $1 PnPNickColors %1 %3 %2 %2 %4 %3 %6 %5 $+ , $+ %1 %3 %2 %2 %4 %3 %6 %5 $+ , $+ %b1 %b3 %b2 %b2 %b4 %b3 %b6 %b5 $+ , $+ %b1 %b3 %b2 %b2 %b4 %b3 %b6 %b5
    ; Break into individual settings also
    theme.pnpnicklist $1
  }
  ; Some exist- fill into color sequences with blanks as needed
  else {
    ; Filter colors up through +%@
    if (%cv == ?) %cv = %cr
    if (%ch == ?) %ch = %cv
    if (%co == ?) %co = %ch
    ; Standard list of colors- any blanks filter through to +%@ colors
    var %norm = %cfriend %cenemy %cenemy %circop %cme %cmisc %cmisc
    hadd $1 PnPNickColors %cr %norm $+ , $+ %cv %norm $+ , $+ %ch %norm $+ , $+ %co %norm
  }
  return

  :basecolors
  var %bk = $gettok($hget($1,Colors),1,44)
  var %sortcol = $col.sort(%bk,$1)
  var %rgb = $gettok($hget($1,RGBColors),$calc(%bk + 1),32)
  %rgb = $calc($gettok(%rgb,1,44) + $gettok(%rgb,2,44) + $gettok(%rgb,3,44))
  ; Use- second darkest for base, darkest for targets, third darkest for highlights, fourth darkest for brackets
  ; On a BLACK (or near-black) background, use-
  ;  third lightest for base, lightest for targets, fourth lightest for hl, second lightest for brackets
  if (%rgb < 15) {
    hadd $1 BaseColors $gettok(%sortcol,-3,44) $+ , $+ $gettok(%sortcol,-1,44) $+ , $+ $gettok(%sortcol,-4,44) $+ , $+ $gettok(%sortcol,-2,44)
  }
  else {
    hadd $1 BaseColors $gettok(%sortcol,-2--1,44) $+ , $+ $gettok(%sortcol,-3,44) $+ , $+ $gettok(%sortcol,-4,44)
  }
  return

  :colorerror
  ; Use ctcp, highlight, or notify color (in that order) for alert/error
  ; Don't use one that's part of basecolors, if possible; use no
  if ($istok($hget($1,BaseColors),$gettok($hget($1,Colors),3,44),44)) hadd $1 ColorError $gettok($hget($1,Colors),3,44)
  elseif ($istok($hget($1,BaseColors),$gettok($hget($1,Colors),4,44),44)) hadd $1 ColorError $gettok($hget($1,Colors),4,44)
  else hadd $1 ColorError $gettok($hget($1,Colors),14,44)
  return

  :linesep
  ; PnP auto-create linesep settings? Use those (length char color color...)
  if ((!$3) && ($hget($1,PnPLineSep))) {
    var %dat
    set -n %dat $hget($1,PnPLineSep)
    hadd $1 LineSep $_cfade($replace($gettok(%dat,3-,32),$chr(32),.),$str($gettok(%dat,2,32),$gettok(%dat,1,32)))
  }

  ; There but blank? Linesep is off
  elseif ((!$3) && ($hfind($1,LineSep,0))) hadd $1 LineSep OFF

  ; Auto-create from sorted colors
  elseif ($3) {
    var %sortcol = $col.sort($gettok($hget($1,Colors),1,44),$1)
    ; Reverse sort order
    var %cols,%num = $numtok(%sortcol,44)
    while (%num >= 1) {
      %cols = $instok(%cols,$gettok(%sortcol,%num,44),0,44)
      dec %num
    }
    ; Determine how similar the colors need to be by how similar our starting
    ; color is to the background color
    var %ratio1 = $col.ratio($gettok($hget($1,BaseColors),1,44),$1)
    var %ratio2 = $col.ratio($gettok($hget($1,Colors),1,44),$1)
    var %d1 = $calc($gettok(%ratio1,1,32) / $gettok(%ratio2,1,32))
    var %d2 = $calc($gettok(%ratio1,2,32) / $gettok(%ratio2,2,32))
    var %d3 = $calc($gettok(%ratio1,3,32) / $gettok(%ratio2,3,32))
    if (%d1 < 1) %d1 = $calc(1 / %d1)
    if (%d2 < 1) %d2 = $calc(1 / %d2)
    if (%d3 < 1) %d3 = $calc(1 / %d3)
    %d1 = $int($calc(%d1 + %d2 + %d3 + 2))
    ; Start with base color, create list of all similar colors (including itself)
    var %stack = $col.similar($gettok($hget($1,BaseColors),1,44),$1,%cols,%d1)
    ; Save to PnPLineSep
    hadd $1 PnPLineSep 40 · $replace(%stack,$chr(44),$chr(32))
    ; Create normal version
    hadd $1 LineSep $_cfade($replace(%stack,$chr(44),.),$str(·,40))
  }

  ; Use a single dash
  else {
    var %color = $gettok($hget($1,BaseColors),1,44)
    hadd $1 PnPLineSep 1 - %color
    hadd $1 LineSep  $+ %color $+ -
  }

  return

  :timestamp
  theme.curr $1 $2
  return

  :timestampformat
  hadd $1 TimeStampFormat $iif($3, $+ <c1>) $+ $chr(91) $+ HH:nn $+ $chr(93) $+ $iif($3,)
  return

  :channelslowercase
  hadd $1 ChannelsLowercase 0
  return

  :bold
  hadd $1 BoldLeft 
  hadd $1 BoldRight 
  return

  :prefix
  if (!$3) {
    hadd $1 Prefix ***
    return
  }
  ; Uses first three colors that would be used for linesep, backwards
  ; Uses character selected based on status font- dot or *
  var %sortcol = $col.sort($gettok($hget($1,Colors),1,44),$1)
  ; Reverse sort order
  var %cols,%num = $numtok(%sortcol,44)
  while (%num >= 1) {
    %cols = $instok(%cols,$gettok(%sortcol,%num,44),0,44)
    dec %num
  }
  ; Determine how similar the colors need to be by how similar our starting
  ; color is to the background color
  var %ratio1 = $col.ratio($gettok($hget($1,BaseColors),1,44),$1)
  var %ratio2 = $col.ratio($gettok($hget($1,Colors),1,44),$1)
  var %d1 = $calc($gettok(%ratio1,1,32) / $gettok(%ratio2,1,32))
  var %d2 = $calc($gettok(%ratio1,2,32) / $gettok(%ratio2,2,32))
  var %d3 = $calc($gettok(%ratio1,3,32) / $gettok(%ratio2,3,32))
  if (%d1 < 1) %d1 = $calc(1 / %d1)
  if (%d2 < 1) %d2 = $calc(1 / %d2)
  if (%d3 < 1) %d3 = $calc(1 / %d3)
  %d1 = $int($calc(%d1 + %d2 + %d3 + 2))
  ; Start with base color, create list of all similar colors (including itself)
  var %stack = $col.similar($gettok($hget($1,BaseColors),1,44),$1,%cols,%d1)
  var %d1 =  $+ $gettok(%stack,1,44)
  var %d2 =  $+ $gettok(%stack,2,44)
  var %d3 =  $+ $gettok(%stack,3,44)
  if (%d2 == ) %d2 = %d1
  if (%d3 == ) %d3 = %d2
  ; Pick character
  var %font = $gettok($hget($1,FontDefault),1,44)
  ; Font for *? (only search fairly common fonts)
  var %char = •
  if ($istok(Fixedsys*Courier*Goudy Medieval*MS Sans Serif*MS Serif*System*Terminal*IBM PC,%font,42)) %char = *
  ; Create
  hadd $1 Prefix %d1 $+ %char $+ %d2 $+ %char $+ %d3 $+ %char $+ 
  return

  :imagescript
  hadd $1 ImageScript $hget($1,ImageStatus)
  return

  :fontdefault
  if ((!$3) && ($hget($1,FontChan))) hadd $1 FontDefault $ifmatch
  elseif ((!$3) && ($hget($1,FontQuery))) hadd $1 FontDefault $ifmatch
  else hadd $1 FontDefault $window(Status Window).font $+ , $+ $window(Status Window).fontsize $+ $iif($window(Status Window).fontbold,$chr(44) $+ B)
  return

  :fontchan
  hadd $1 FontChan $hget($1,FontDefault)
  return

  :fontquery
  hadd $1 FontQuery $hget($1,FontDefault)
  return

  :fontscript
  hadd $1 FontScript $hget($1,FontDefault)
  return

  :fontdcc
  hadd $1 FontDCC $hget($1,FontDefault)
  return

  :parentext
  hadd $1 ParenText (<text>)
  return

  :linesepwhois
  ; LineSepWhois - ON if a) no whois events or b) whois event doesn't seem to start with a linesep-like line
  ; Calls $theme.hassep() to determine.
  hadd $1 LineSepWhois $iif($theme.hassep($1,$iif($hget($1,RAW.311),RAW.311,Whois),$theme.ff($hget(mts.edit,$1),$hget($1,Script))),0,1)
  return
}

; $theme.precompile(event,prefix,boldl,boldr,basecolors,text)
; Converts an MTS text line to an equivalent MTS !Script line
; Prefills c1-c4 and prefix and bold (prefix/bold should already be precompiled) and doesn't waste $+s o n these
; Turns me/server/port into $me/$server/$port
; You still need to fill these %::vars, but this is faster overall
; event is name- special code for raw.*/echo/echotarget (no %:comments) and 'prefix' (no %:echo/%:comments)
; 'prefix' should be used for any line you don't want :echo/:comments on (linesep, bold, etc.)
alias -l theme.precompile {
  var %num = $regex(mts,$6,/(<[-_.a-zA-Z0-9]+>|[%#{|}\[\]$])/g),%text = $6,%old,%left,%right
  var %<gt> = >,%<lt> = <,%<pre> = $2,%<bl> = $3,%<br> = $4,%<me> = $!me,%<server> = $!server,%<port> = $!port

  ; Replace each instance
  while (%num >= 1) {
    %old = $regml(mts,%num)
    %left = $left($6,$regml(mts,%num).pos)
    %right = $mid(%text,$calc($regml(mts,%num).pos + $len(%old)))

    ; Special case for items that don't utilize $+s
    if (<c?> iswm %old) %text = $left(%left,-1) $+ $gettok($5,$mid(%old,3,1),44) $+ %right
    elseif ($istok(<gt> <lt> <pre> <bl> <br>,%old,32)) %text = $left(%left,-1) $+ % [ $+ [ %old ] ] $+ %right
    else {
      ; Do we need $+ on either side?
      if (($len(%left) != 1) && ($asc($right(%left,2)) != 32)) %left = $left(%left,-1) $!+<
      if ((%right != $null) && ($asc(%right) != 32)) %right = $!+ %right

      ; Replace
      if ($len(%old) == 1) %text = $left(%left,-1) $!chr( $+ $asc(%old) $+ ) %right
      elseif ($istok(<me> <server> <port>,%old,32)) %text = $left(%left,-1) % [ $+ [ %old ] ] %right
      else %text = $left(%left,-1) $+(%,::,$mid(%old,2,-1)) %right
    }

    dec %num
  }

  ; Add stuff on left/right
  if ($1 == Prefix) return %text
  return % $+ :echo %text $iif(($1 != Echo) && ($1 != EchoTarget),% $+ :comments)
}

; $image.cur(window[,nostyle])
; Call saveini before using this
; Reads image for $1 from mircini and returns in style filename format
; omits style if nostyle is true
; windows- wchannel, wquery, status, @mdi, toolbuttons, switchbar, toolbar
alias -l image.cur {
  var %image = $readini($mircini,n,background,$1)
  if ((%image == none) || (%image == $null)) return
  var %style = 0
  if (*,? iswm %image) {
    %style = $right(%image,1)
    %image = $left(%image,-2)
  }
  %style = $gettok(center fill normal stretch tile photo,$calc(%style + 1),32)
  return $iif(!$2,%style) %image
}

; $font.cur(window)
; Call saveini before using this
; Reads font $1 (status, etc) from mircini and returns in name,size[,B] format
alias -l font.cur {
  ; Format- name,size[,codepage]
  ; size is +700 for bold, other hundreds digits are ignored
  var %font = $readini($mircini,n,fonts,f $+ $1)
  var %size = $gettok(%font,2,44)
  var %bold = 0
  if (%size > 99) {
    if ($left(%size,1) == 7) %bold = 1
    %size = $calc(%size % 100)
  }
  return $gettok(%font,1,44) $+ , $+ %size $+ $iif(%bold,$chr(44) $+ B)
}

; $font.mirc(font)
; Turns name,size[,B] into mirc.ini format
alias -l font.mirc {
  return $gettok($1-,1,44) $+ , $+ $calc($gettok($1-,2,44) + $iif($gettok($1-,3,44),700))
}

; $font.display(font)
; Turns name,size[,B] into name size [bold] for display
alias -l font.display {
  return $gettok($1-,1,44) $gettok($1-,2,44) $iif($gettok($1-,3,44),bold)
}

; $font.mts(font)
; Turns name size [bold] into name,size[,B]
alias -l font.mts {
  var %bold = $gettok($1-,-1,32)
  var %rest = $1-
  if (%bold == bold) {
    %bold = ,B
    %rest = $deltok($1-,-1,32)
  }
  else %bold =
  return $deltok(%rest,-1,32) $+ , $+ $gettok(%rest,-1,32) $+ %bold
}

; $font.exists(font)
; Returns 1/0 depending on whether font exists
; Don't call with "blah bold" or anything like that!
alias -l font.exists {
  var %chr = 32
  while (%chr < 127) {
    if (($width($chr(%chr),$1-,100) != $width($chr(%chr),$1- bold,100)) || ($height($chr(%chr),$1-,100) != $height($chr(%chr),$1- bold,100))) return 1
    inc %chr
  }
  return 0
}

; $theme.ff(theme, file)
; Pass path of theme and filename
; Finds file in theme dir, or dir of filename if it's specified
; Returns filename if found, null if not found
alias theme.ff {
  ; Try to find as relative path
  var %try = $nofile($1) $+ $2
  if ($isfile(%try)) return %try

  ; Try to find it in theme dir
  %try = $nofile($1) $+ $nopath($2)
  if ($isfile(%try)) return %try

  ; Check if it exists as-is
  if ($isfile($2)) return $_truename.fn($2)

  ; None found
  return
}

; $theme.itemtype(name)
; Determines type of setting 'name' is (returns one of imrpnldfbtse)
; 'event' includes raws; 'info' includes mtsversion and pnptheme and filename
; i)nfo, m)irc colors, r)gb, p)np/base colors, n)icklist, l)ine sep, e)vent, d)isplay, f)ont, b)ackground, t)oolbar,
; s)ound, c) script line
alias -l theme.itemtype {
  if ($istok(imagetoolbar imagebuttons imageswitchbar,$1,32)) return t
  if (snd* iswm $1) return s
  if (scheme* iswm $1) return i
  if (image* iswm $1) return b
  if (font* iswm $1) return f
  if (cline* iswm $1) return n
  if ($findtok(script colors rgbcolors pnpnickcolors basecolors colorerror boldleft boldright prefix parentext linesep linesepwhois pnplinesep timestamp timestampformat channelslowercase script name author email website description version mtsversion pnptheme filename,$1,1,32)) return $mid(cmrnppddddldldddeiiiiiiiii,$ifmatch,1)
  return e
}

; $theme.issec(file,section)
; Determines if [section] exists in file, and if so, returns line number
; Else, returns 0
alias -l theme.issec {
  if (!$isfile($1)) return 0
  var %mts = $read($1,ns,[[ $+ $2 $+ ]])
  if ($readn) return $readn
  return 0
}

; $theme.hassep(hash, event, scriptfile [, isscripted [, any ] ] )
; Returns true if the event's first echo'd line is a linesep or linesep-like line
; If 'any' is true, then searches for ANY echo'd linesep
; If 'isscripted' is true, assumes a script line regardless of !Script presence
alias -l theme.hassep {
  ; Grab event
  var %start = $hget($1,$2)
  var %bracket,%ln

  ; No event? False
  if (!%start) return 0

  ; Check event lines
  ; Scripted? Get actual first line
  if (($4) || ($gettok(%start,1,32) == !Script)) {
    ; Check to see if it's an alias name
    if (!$4) %start = $gettok(%start,2-,32)
    if ($left($gettok(%start,1,32),1) != %) {
      ; Alias- Find first line from the alias containing %:echo or %:linesep
      if ($isfile($3)) {
        ; Load script into window
        window -hln @.mtsscr
        loadbuf @.mtsscr " $+ $3 $+ "
        ; Start with first alias line
        %ln = $fline(@.mtsscr,alias $gettok(%start,1,32) *,1)
        :nextline
        var %found
        while ((%ln <= $line(@.mtsscr,0)) && (%bracket != 0)) {
          var %line = $line(@.mtsscr,%ln)
          ; Count brackets so we know end of alias
          inc %bracket $count(%line,$chr(123))
          dec %bracket $count(%line,$chr(125))
          ; Check for linesep
          if (% $+ :linesep isin %line) {
            %found = % $+ :linesep
            break
          }
          ; Check for echo
          if (% $+ :echo isin %line) {
            ; Extract first token separated by { } or | that has echo in it
            var %line = $_s2p(%line) $+ 
            %found = $_p2s($wildtok($replace(%line,|,$chr(32),{,$chr(32),},$chr(32)),*%:echo*,1,32))
            break
          }
          inc %ln
        }
        %start = %found
      }
      ; Script file not found- so nothing found
      else %start =
    }
  }
  ; If linesep is being shown, return true
  if (% $+ :linesep isin %start) {
    window -c @.mtsscr
    return 1
  }
  ; Count the chars in the start line other than- 0-9, a-z, A-Z, space, or $%():<>+, and color codes, and "== " (ifs)
  var %junk = $regsub(%start,/[ a-zA-Z0-9$%():<>+ $+ $chr(44) $+ ]|=?= /g,$null,%start)
  ; If count is more than 8 we count that as a linesep
  if ($len(%start) > 8) {
    window -c @.mtsscr
    return 1
  }
  ; Return 0 unless we have more lines to search
  if (($5) && (%start) && (%ln)) {
    inc %ln
    goto nextline
  }
  window -c @.mtsscr
  return 0
}

; $col.blank(num)
; If number, returns it; else returns ?
alias -l col.blank {
  if ($1 isnum) return $1
  return ?
}

; $col.zero(num)
; If 0-9 returns 00-09
; 16 returns ?
alias -l col.zero {
  if ($1 == 16) return ?
  if ($1 isnum 0-9) return 0 $+ $calc($1)
  return $1
}

; $col.fix(num)
; If non-number returns 16, else returns range of 0 to 15 only
alias -l col.fix {
  if ($1 isnum) return $calc(($1 % 16 + 16) % 16)
  return 16
}


; $col.sort(from,hash)
; Uses hash to lookup rgbcolors
; Returns all colors in brightest-to-darkest sequence (by luminence)
; Based on color listed as from- usually white or black
; Caches results so you can call multiple times safely
; Colors (and from) must be 0-15
alias -l col.sort {
  if (%.col.sort. [ $+ [ $1 ] $+ [ $2 ] ] != $null) return $ifmatch
  var %target = $col.lum($1,$2),%col = 0,%ints,%cols
  while (%col <= 15) {
    ; Each color (other than first)
    if (%col != $1) {
      ; Calculate intensity difference between this and 'from' color
      var %int = $abs($calc(%target - $col.lum(%col,$2)))
      ; Insert this into list and sort it
      %ints = $instok(%ints,%int,1,44)
      %ints = $sorttok(%ints,44,n)
      ; Find where this token is, in sorted list, and insert into color
      ; list in same location, to get a color list sorted by intensity
      if (%col < 10) %col = 0 $+ %col
      %cols = $instok(%cols,%col,$findtok(%ints,%int,1,44),44)
    }
    inc %col
  }
  set -u %.col.sort. [ $+ [ $1 ] $+ [ $2 ] ] %cols
  return %cols
}

; $col.lum(col,hash)
; Uses hash to lookup rgbcolors
; Returns luminence/intensity- R*30 + G*59 + B*11
alias -l col.lum {
  var %rgb = $gettok($hget($2,RGBColors),$calc($1 + 1),32)
  return $calc($gettok(%rgb,1,44) * 30 + $gettok(%rgb,2,44) * 59 + $gettok(%rgb,3,44) * 11)
}

; $col.similar(color,hash,list,threshold)
; Uses hash to lookup rgbcolors
; Finds the color most similar to 'color', but darker or lighter
; If multiple matches (usually greys) returns closest in intensity
; 'color' should be 0 to 15
; Optional 'list' contains comma-delimited list of colors to scan (instead of all)
; Optional 'threshold' contains threshold- if present, instead returns comma-delimited list of all
;  colors found with similarities within that threshold, including color itself; in original order
alias -l col.similar {
  ; List of colors
  var %list = $3
  if ($3 == $null) %list = 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  ; Grab ratios and intensity of all colors (cache if possible)
  var %ratios = %.col.ratio. [ $+ [ $2 ] ]
  if (%ratios == $null) {
    var %num = 0
    while (%num <= 15) {
      %ratios = $instok(%ratios,$col.ratio(%num,$2),0,44)
      inc %num
    }
    set -u %.col.ratio. [ $+ [ $2 ] ] %ratios
  }
  ; Grab ratios and intensity of first color
  tokenize 32 $1 $2 $gettok(%ratios,$calc($1 + 1),44) $4
  var %best,%bestratio,%bestint,%tok = 1
  while (%tok <= $numtok(%list,44)) {
    ; Search each color in list
    var %col = $gettok(%list,%tok,44)
    ; Don't search same color unless doing threshold method
    if (($7) || (%col != $1)) {
      ; Calculate how close this color's ratios are to those of 'color' via dividing
      var %newratio = $gettok(%ratios,$calc(%col + 1),44)
      var %d1 = $calc($3 / $gettok(%newratio,1,32))
      var %d2 = $calc($4 / $gettok(%newratio,2,32))
      var %d3 = $calc($5 / $gettok(%newratio,3,32))
      ; Each value below one, invert- all values will be greater than one now
      if (%d1 < 1) %d1 = $calc(1 / %d1)
      if (%d2 < 1) %d2 = $calc(1 / %d2)
      if (%d3 < 1) %d3 = $calc(1 / %d3)
      ; The closer the three values are to one, the more similar they are.
      %d1 = $calc(%d1 + %d2 + %d3)
      if (%col < 10) %col = 0 $+ $calc(%col)
      ; Threshold version?
      if (($7) && (%d1 <= $7)) %best = $instok(%best,%col,0,44)
      if (!$7) {
        ; Calculate intensity difference also
        var %int = $abs($calc($gettok(%newratio,4,32) - $6))
        ; If first color, or ratio is better than best, or ratio is same but intensity is better
        if ((!%bestratio) || (%d1 < %bestratio) || ((%d1 == %bestratio) && (%int < %bestint))) {
          ; then save this as our best match so far
          %best = %col
          %bestratio = %d1
          %bestint = %int
        }
      }
    }
    inc %tok
  }
  return %best
}

; $col.ratio(color,hash)
; Uses hash to lookup rgbcolors
; Returns 4 ratios- red to green, red to blue, green to blue, luminance, space-delimited
alias -l col.ratio {
  var %rgb = $gettok($hget($2,RGBColors),$calc($1 + 1),32)
  ; We add 10 to avoid divide-by-zero errors and tweak the results a little
  var %r = $calc($gettok(%rgb,1,44) + 10)
  var %g = $calc($gettok(%rgb,2,44) + 10)
  var %b = $calc($gettok(%rgb,3,44) + 10)
  return $calc(%r / %g) $calc(%r / %b) $calc(%g / %b) $calc($gettok(%rgb,1,44) * 30 + $gettok(%rgb,2,44) * 59 + $gettok(%rgb,3,44) * 11)
}

; $mtsversion
; Returns 1.1 (the version of MTS we support)
alias mtsversion { return 1.1 }

on *:START:{ .disable #previewecho }
; Enable this during previews so everything runs smoothly
#previewecho off

; Allow /echo to go to preview window
alias echo {
  var %color
  ; Color?
  if ($1 isnum) {
    %color = $1
    tokenize 32 $2-
  }
  else {
    %color = $gettok(%.colors,12,44)
  }
  ; Flags?
  if (-* iswm $1) {
    ; Ignore flags, ignore any target
    if ((a isin $1) || (s isin $1)) theme.previewecho %color $2-
    else theme.previewecho %color $3-
  }
  else theme.previewecho %color $1-
}

; Allow $theme.setting to return preview data
alias theme.setting { return $hget(pnp.preview.theme,$1) }

#previewecho end

; $theme.setting(setting)
; Returns an unprocessed setting
alias theme.setting { return $hget(pnp.theme,$1) }

; /theme.text event [flags]
; Runs the specified event. Most variables shall already be set, including %:echo
; Sets me, server, port, timestamp (pre, c1-4, bl, br alreay preset)
; Flag p - set parentext and add ^O to text if not null
; Flag c - set cnick/cmode
; Flag n - set cnick/cmode off of newnick
; Lowercases ::chan if setting true
; Returns 1 if no event found
alias theme.text {
  var %event = $hget(pnp.events,$1)
  if (%event == $null) return 1
  set -u %::timestamp $timestamp
  set -u %::me $me
  set -u %::server $server
  set -u %::port $port
  if ((p isin $2) && (%::text != $null)) {
    set -u %::text %::text $+ 
    set -u %::parentext $eval($hget(pnp.events,ParenText),2)
  }
  if (c isin $2) {
    ; Don't set this if mode prefixes are disabled
    if ($_optn(2,30)) set -u %::cmode $iif($left($nick(%::chan,%::nick).pnick,1) isin $prefix,$ifmatch)
    ; Don't set this if theme nickname coloring disabled
    if ($hget(pnp.config,themecol)) set -u %::cnick $_nickcol(%::nick,%::chan)
  }
  if (n isin $2) {
    if ($_optn(2,30)) set -u %::cmode $iif($left($nick(%::chan,%::newnick).pnick,1) isin $prefix,$ifmatch)
    ; Use %::nick here because nick colors aren't updated yet
    if ($hget(pnp.config,themecol)) set -u %::cnick $_nickcol(%::nick,%::chan)
  }
  if (($hget(pnp.theme,ChannelsLowercase)) && (%::chan != $null)) set -u %::chan $lower(%::chan)
  [ [ %event ] ]
  return
}

; $theme.isscripted(event)
; Returns true if that event is scripted, and not just a single echo
; (used in certain cases for display of lineseps)
alias theme.isscripted {
  var %event = $hget(pnp.events,$1)
  if ((%event == $null) || ($gettok(%event,1,32) == % $+ :echo)) return 0
  return 1
}
