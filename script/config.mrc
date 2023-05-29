; #= P&P.temp -rs
; @======================================:
; |  Peace and Protection                |
; |  Configuration dialogs               |
; `======================================'

; Main configuration dialog
dialog pnp.config {
  title "PnP Options"
  icon script\pnp.ico
  option map
  size -1 -1 334 214

  ; List of sections
  list 901, 6 6 77 201, size

  ; Whether a section has been loaded yet
  list 902, 1 1 1 1, hide

  ; Last section selected
  edit "", 903, 1 1 1 1, autohs hide

  button "OK", 905, 141 191 40 14, default group
  button "Cancel", 906, 188 191 40 14, cancel
  button "&Help", 907, 235 191 40 14, disable

  ; Blank tab
  tab "", 1, -25 -25 1 1, disable hide

  ; Hidden tabs to select areas
  tab "", 2, -25 -25 1 1, disable hide
  tab "", 3, -25 -25 1 1, disable hide
  tab "", 4, -25 -25 1 1, disable hide
  tab "", 7, -25 -25 1 1, disable hide
  tab "", 8, -25 -25 1 1, disable hide
  tab "", 9, -25 -25 1 1, disable hide
  tab "", 10, -25 -25 1 1, disable hide
  tab "", 11, -25 -25 1 1, disable hide
  tab "", 12, -25 -25 1 1, disable hide
  tab "", 13, -25 -25 1 1, disable hide
  tab "", 14, -25 -25 1 1, disable hide
  tab "", 17, -25 -25 1 1, disable hide
  tab "", 18, -25 -25 1 1, disable hide
  tab "", 19, -25 -25 1 1, disable hide
  tab "", 20, -25 -25 1 1, disable hide
  tab "", 21, -25 -25 1 1, disable hide
  tab "", 22, -25 -25 1 1, disable hide
  tab "", 24, -25 -25 1 1, disable hide
  tab "", 25, -25 -25 1 1, disable hide
  tab "", 26, -25 -25 1 1, disable hide
  tab "", 27, -25 -25 1 1, disable hide
  tab "", 28, -25 -25 1 1, disable hide
  tab "", 29, -25 -25 1 1, disable hide
  tab "", 30, -25 -25 1 1, disable hide
  tab "", 31, -25 -25 1 1, disable hide
  tab "", 32, -25 -25 1 1, disable hide
  tab "", 33, -25 -25 1 1, disable hide

  ; Away - Pager/Log [70-99]
  box "Pager", 70, 167 12 60 61, tab 2
  box "Away logging", 71, 233 12 86 61, tab 2
  text "&When away:", 72, 93 27 66 9, right tab 2
  combo 75, 173 24 46 61, drop tab 2
  text "&When auto-away:", 73, 93 41 66 9, right tab 2
  combo 76, 173 39 46 61, drop tab 2
  text "&When here :", 74, 93 56 66 9, right tab 2
  combo 77, 173 54 46 61, drop tab 2
  check "&On (away)", 78, 240 27 73 9, tab 2
  check "&On (auto-away)", 79, 240 41 73 9, tab 2
  box "What to log:", 80, 93 81 227 46, tab 2
  check "&Log private messages and", 81, 100 94 96 9, tab 2
  combo 82, 200 92 113 61, drop tab 2
  check "&Log channel events:", 83, 100 110 96 9, tab 2
  combo 84, 200 108 113 61, drop tab 2
  check "&Use 'classic' pager window", 85, 100 136 227 9, tab 2
  check "&Clear away log on away", 86, 100 147 227 9, tab 2
  check "&Close any open queries on away", 87, 100 158 227 9, tab 2
  check "&Save permanent copy of away log to logs directory", 88, 100 169 227 9, tab 2

  ; Away - Message [100-129]
  box "When you set away:", 100, 93 3 227 83, tab 3
  radio "&Send an action", 101, 100 14 80 9, group tab 3
  radio "&Send a message", 102, 100 25 80 9, tab 3
  text "to all", 103, 184 20 36 9, tab 3
  check "&channels", 104, 237 14 80 9, tab 3
  check "&chats/queries", 105, 237 25 80 9, tab 3
  check "&Ignore these channels:", 106, 100 42 94 9, tab 3
  edit "", 107, 195 41 116 13, autohs tab 3
  check "&Ignore channels where you are idle", 108, 100 56 133 9, tab 3
  text "minutes", 109, 256 57 60 9, tab 3
  edit "", 110, 233 55 20 13, autohs tab 3
  check "&Repeat this every", 111, 100 70 94 9, tab 3
  text "minutes", 112, 217 71 86 9, tab 3
  edit "", 113, 195 68 20 13, autohs tab 3
  box "Remind people that you're away if they:", 114, 93 93 227 92, tab 3
  check "&Send you a private message", 115, 100 104 213 9, tab 3
  check "&Trigger your mIRC highlight settings in a channel", 116, 100 115 213 9, tab 3
  check "&Use any of these words in a channel: (separate with commas)", 117, 100 126 213 9, tab 3
  edit "", 118, 112 138 162 13, autohs tab 3
  check "&Only remind if triggered in these channels:", 119, 100 154 213 9, tab 3
  edit "", 120, 112 167 162 13, autohs tab 3

  ; Away - Other [130-149]
  box "Auto-away", 130, 93 18 227 61, tab 4
  check "&Automatically set away after", 131, 100 30 102 9, tab 4
  text "minutes idle", 132, 229 31 93 9, tab 4
  edit "", 133, 204 29 20 13, autohs tab 4
  check "&Warn you before setting auto-away", 134, 100 46 213 9, tab 4
  check "&Perform auto-away quietly (don't message channels, etc.)", 135, 100 62 213 9, tab 4
  check "&Change nick on away to:", 136, 100 92 92 9, tab 4
  edit "", 137, 195 90 66 13, autohs tab 4
  text "", 138, 112 105 120 9, tab 4
  check "&Set away on all connections (by default)", 143, 100 121 213 9, tab 4
  check "&Disable sounds when away", 139, 100 132 213 9, tab 4
  check "&Disable event beeps when away", 140, 100 143 213 9, tab 4
  check "&Deop yourself in any channels when away", 141, 100 154 213 9, tab 4
  check "&Enable dedicated query window when away", 142, 100 165 213 9, tab 4

  ; Display - Nick colors [150-159]
  check "&Color nicknames in nicklist", 150, 100 30 227 9, tab 7
  check "&Color nicknames in channel text", 151, 100 46 227 9, tab 7
  text "&Use lagged nick color if lagged", 152, 112 63 102 9, tab 7
  edit "", 153, 216 61 20 13, autohs tab 7
  text "seconds", 154, 240 63 93 9, tab 7
  text "Nick colors are set in theme configuration.", 155, 112 92 213 9, tab 7
  button "&Edit Theme", 156, 112 106 66 14, tab 7

  ; Display - Notify [160-189]
  box "Notify format", 160, 167 45 73 98, tab 8
  box "Unnotify format", 161, 247 45 73 98, tab 8
  text "&Address matches:", 162, 86 60 76 9, right tab 8
  combo 165, 173 57 60 61, drop tab 8
  combo 169, 253 85 60 61, drop tab 8
  check "&Beep and flash", 172, 173 72 60 9, tab 8
  text "&Address fails:", 163, 86 88 76 9, right tab 8
  combo 166, 173 85 60 61, drop tab 8
  combo 168, 253 57 60 61, drop tab 8
  check "&Beep and flash", 173, 173 100 60 9, tab 8
  text "&No address check:", 164, 86 116 76 9, right tab 8
  combo 167, 173 114 60 61, drop tab 8
  combo 170, 253 114 60 61, drop tab 8
  check "&Beep and flash", 174, 173 128 60 9, tab 8
  text "When a user on your notify list comes online, PnP can check their address against a mask. (see /notif) PnP can show the notify differetly based on the results of this address check. 'Unnotify' is shown when a notify user leaves IRC.", 171, 93 6 227 39, tab 8
  text "&Show notifies to:", 175, 86 151 76 9, right tab 8
  combo 176, 173 148 106 61, drop tab 8
  check "&Show unnotify in quit color", 177, 173 163 153 9, tab 8
  check "&Show function keys with notify", 178, 173 174 153 9, tab 8

  ; Display - Ping [190-209]
  text "&Show channel pings to:", 190, 93 42 96 9, right tab 9
  combo 191, 193 40 106 61, drop tab 9
  text "&Show single pings to:", 192, 93 58 96 9, right tab 9
  combo 193, 193 56 106 61, drop tab 9
  box "Options:", 194, 93 92 227 66, tab 9
  check "&Minimize @Ping window when opened", 195, 100 104 213 9, tab 9
  check "&Bring @Ping window to front on new replies", 196, 100 116 213 9, tab 9
  check "&Retain replies for later viewing", 197, 100 128 213 9, tab 9
  check "&Show numeric codes when others ping you", 198, 100 141 213 9, tab 9

  ; Display - Server notices [210-229]
  text "Select shown notices and press 'Hide' to hide them, or select hidden notices and press 'Show' to show them again.", 210, 93 6 227 29, tab 10
  check "&Enable PnP server notice filtering: (when usermode +s on)", 213, 98 31 280 9, tab 10
  box "&Shown server notices:", 214, 93 45 227 68, tab 10
  list 216, 100 55 213 42, extsel sort tab 10
  list 217, 1 1 1 1, hide
  button "&Hide", 220, 273 94 40 13, tab 10
  box "&Hidden server notices:", 215, 93 117 227 68, tab 10
  list 218, 100 127 213 42, extsel sort tab 10
  list 219, 1 1 1 1, hide
  button "&Show", 221, 273 167 40 13, tab 10
  text "&Show to:", 222, 97 97 48 9, right tab 10
  combo 223, 146 94 120 61, drop tab 10

  ; Display - Text [230-249]
  check "&Copy private messages to active window", 231, 96 18 231 9, tab 11
  check "&Use PnP text theming", 230, 96 30 231 9, tab 11
  button "&Edit Theme", 244, 108 45 66 14, tab 11
  box "Notices:", 232, 98 70 106 49, tab 11
  radio "&Normal", 233, 112 82 86 9, group tab 11
  radio "&Notices window", 234, 112 93 86 9, tab 11
  radio "&Status window", 235, 112 104 86 9, tab 11
  box "Op Notices:", 236, 212 70 106 49, tab 11
  radio "&Normal", 237, 225 82 86 9, group tab 11
  radio "&Notices window", 238, 225 93 86 9, tab 11
  radio "&Events window", 239, 225 104 86 9, tab 11
  box "Services Notices:", 240, 98 125 106 49, tab 11
  radio "&Normal", 241, 112 137 86 9, group tab 11
  radio "&Notices window", 242, 112 148 86 9, tab 11
  radio "&Status window", 243, 112 159 86 9, tab 11

  ; Display - Wallops [250-269]
  text "Select shown wallops and press 'Hide' to hide them, or select hidden wallops and press 'Show' to show them again.", 250, 93 6 227 29, tab 12
  check "&Enable PnP wallop filtering: (when usermode +w on)", 253, 98 31 280 9, tab 12
  box "&Shown wallops:", 254, 93 45 227 68, tab 12
  list 256, 100 55 213 42, extsel sort tab 12
  list 257, 1 1 1 1, hide
  button "&Hide", 260, 273 94 40 13, tab 12
  box "&Hidden wallops:", 255, 93 117 227 68, tab 12
  list 258, 100 127 213 42, extsel sort tab 12
  list 259, 1 1 1 1, hide
  button "&Show", 261, 273 167 40 13, tab 12
  text "&Show to:", 262, 97 97 48 9, right tab 12
  combo 263, 146 94 120 61, drop tab 12

  ; Display - Whois replies [270-289]
  text "&Show whois replies to:", 270, 93 15 96 9, right tab 13
  combo 271, 193 13 106 61, drop tab 13
  box "Options:", 272, 93 30 227 95, tab 13
  check "&Show in query/chat if open", 273, 100 42 213 9, tab 13
  check "&Minimize @Whois window when opened", 274, 100 55 213 9, tab 13
  check "&Bring @Whois window to front on new replies", 275, 100 67 213 9, tab 13
  check "&Retain replies for later viewing", 276, 100 79 213 9, tab 13
  check "&Show extended server information", 277, 100 95 213 9, tab 13
  check "&Show shared channels in bold", 278, 100 108 213 9, tab 13
  box "Show nickname:", 279, 93 130 227 55, tab 13
  radio "&on all lines", 280, 100 142 213 9, group tab 13
  radio "&on first line only", 281, 100 154 213 9, tab 13
  radio "&on first line, but line up remaining lines", 282, 100 167 213 9, tab 13

  ; Display - Other [290-309]
  text "&Names list when joining:", 290, 93 28 96 9, right tab 14
  combo 291, 193 25 106 61, drop tab 14
  text "&Show MOTD on connect:", 292, 93 44 96 9, right tab 14
  combo 293, 193 41 106 61, drop tab 14
  text "&Time display format:", 294, 93 65 96 9, right tab 14
  combo 295, 193 62 106 61, drop edit tab 14
  text "&Date display format:", 296, 93 81 96 9, right tab 14
  combo 297, 193 78 106 61, drop edit tab 14
  box "Options:", 301, 93 104 227 66, tab 14
  check "&Show CTCPs, DNS, and away status to active window", 298, 100 116 213 9, tab 14
  check "&Show events/raws to active if channel/query not open", 302, 100 128 213 9, tab 14
  check "&Display MOTD to @MOTD window", 299, 100 141 213 9, tab 14
  check "&Show PnP splash screen during startup", 300, 100 153 213 9, tab 14

  ; Popups - Channel [310-329]
  box "Show these popups:", 329, 106 18 200 90, tab 17
  check "&Topic", 310, 113 30 93 12, tab 17
  check "&Modes", 311, 113 42 93 12, tab 17
  check "&Settings", 312, 113 55 93 12, tab 17
  check "&Banlist", 313, 113 67 93 12, tab 17
  check "&Bans", 314, 113 79 93 12, tab 17
  check "&Ping", 315, 113 92 93 12, tab 17
  check "&Scan", 316, 207 30 93 12, tab 17
  check "&Favorites", 317, 207 42 93 12, tab 17
  check "&Part", 318, 207 55 93 12, tab 17
  check "&Window", 319, 207 67 93 12, tab 17
  check "&Help", 320, 207 79 93 12, disable tab 17
  check "&Hide op popups if not opped", 321, 113 116 213 12, tab 17
  button "&Load default", 326, 113 137 80 14, tab 17
  button "&Load condensed", 327, 207 137 80 14, tab 17
  text "Tip: You can hold Ctrl when right-clicking to show hidden popups.", 328, 113 162 187 29, tab 17

  ; Popups - Menubar [330-349]
  box "Show these popups:", 349, 106 18 200 90, tab 18
  check "&Configure", 330, 113 30 93 12, tab 18
  check "&Last whois", 331, 113 42 93 12, tab 18
  check "&Lists", 332, 113 55 93 12, tab 18
  check "&Away", 333, 113 67 93 12, tab 18
  check "&Nickname", 334, 113 79 93 12, tab 18
  check "&List channels", 335, 207 30 93 12, tab 18
  check "&Channels", 336, 207 42 93 12, tab 18
  check "&Favorites", 337, 207 55 93 12, tab 18
  check "&Addons", 338, 207 67 93 12, tab 18
  check "&Help", 339, 207 79 93 12, disable tab 18
  button "&Load default", 346, 113 137 80 14, tab 18
  button "&Load condensed", 347, 207 137 80 14, tab 18
  text "Tip: You can hold Ctrl when right-clicking to show hidden popups.", 348, 113 162 187 29, tab 18

  ; Popups - Nicklist [350-369]
  box "Show these popups:", 369, 106 18 200 90, tab 19
  check "&Quick kick", 350, 113 30 93 12, tab 19
  check "&Quick ban", 351, 113 42 93 12, tab 19
  check "&Kick", 352, 113 55 93 12, tab 19
  check "&Bans", 353, 113 67 93 12, tab 19
  check "&Op / Halfop / Voice", 354, 113 79 93 12, tab 19
  check "&User info", 355, 113 92 93 12, tab 19
  check "&CTCP", 356, 207 30 93 12, tab 19
  check "&DCC", 357, 207 42 93 12, tab 19
  check "&Query", 358, 207 55 93 12, tab 19
  check "&Lists", 359, 207 67 93 12, tab 19
  check "&Notices", 360, 207 79 93 12, tab 19
  check "&Help", 361, 207 92 93 12, disable tab 19
  check "&Hide op popups if not opped", 362, 113 116 213 12, tab 19
  button "&Load default", 366, 113 137 80 14, tab 19
  button "&Load condensed", 367, 207 137 80 14, tab 19
  text "Tip: You can hold Ctrl when right-clicking to show hidden popups.", 368, 113 162 187 29, tab 19

  ; Popups - Query [370-389]
  box "Show these popups:", 389, 106 18 200 90, tab 20
  check "&Whois", 370, 113 30 93 12, tab 20
  check "&User info", 371, 113 42 93 12, tab 20
  check "&Ping", 372, 113 55 93 12, tab 20
  check "&CTCP", 373, 113 67 93 12, tab 20
  check "&DCC", 374, 113 79 93 12, tab 20
  check "&Ignore", 375, 113 92 93 12, tab 20
  check "&Userlist", 376, 207 30 93 12, tab 20
  check "&Notify", 377, 207 42 93 12, tab 20
  check "&Window", 378, 207 55 93 12, tab 20
  check "&Close", 379, 207 67 93 12, tab 20
  check "&Help", 380, 207 79 93 12, disable tab 20
  button "&Load default", 386, 113 137 80 14, tab 20
  button "&Load condensed", 387, 207 137 80 14, tab 20
  text "Tip: You can hold Ctrl when right-clicking to show hidden popups.", 388, 113 162 187 29, tab 20

  ; Popups - Status [390-409]
  box "Show these popups:", 409, 106 18 200 90, tab 21
  check "&List channels", 390, 113 30 93 12, tab 21
  check "&Channels", 391, 113 42 93 12, tab 21
  check "&Favorites", 392, 113 55 93 12, tab 21
  check "&Nickname", 393, 113 67 93 12, tab 21
  check "&Usermode", 394, 113 79 93 12, tab 21
  check "&Quit", 395, 113 92 93 12, tab 21
  check "&Server", 396, 207 30 93 12, tab 21
  check "&Stats", 397, 207 42 93 12, tab 21
  check "&Connect", 398, 207 55 93 12, tab 21
  check "&Window", 399, 207 67 93 12, tab 21
  check "&Help", 400, 207 79 93 12, disable tab 21
  button "&Load default", 406, 113 137 80 14, tab 21
  button "&Load condensed", 407, 207 137 80 14, tab 21
  text "Tip: You can hold Ctrl when right-clicking to show hidden popups.", 408, 113 162 187 29, tab 21

  ; Popups - @Windows [410-429]
  box "Show these popups:", 429, 106 18 200 90, tab 22
  check "&Select all", 410, 113 30 93 12, tab 22
  check "&Copy", 411, 113 42 93 12, tab 22
  check "&Window", 412, 113 55 93 12, tab 22
  check "&Close", 413, 113 67 93 12, tab 22
  check "&Hide", 414, 113 79 93 12, tab 22
  check "&Help", 415, 113 92 93 12, disable tab 22
  button "&Load default", 426, 113 137 80 14, tab 22
  button "&Load condensed", 427, 207 137 80 14, tab 22
  text "Tip: You can hold Ctrl when right-clicking to show hidden popups.", 428, 113 162 187 29, tab 22

  ; Channel options [430-459]
  text "&Channel:", 452, 86 9 48 9, right tab 24
  combo 453, 136 7 93 61, sort drop tab 24
  list 454, 1 1 1 1, hide
  edit "", 457, 1 1 1 1, hide autohs
  button "&Add...", 455, 235 6 40 14, tab 24
  button "&Remove", 456, 280 6 40 14, tab 24
  box "&Default tempban:", 430, 93 28 227 30, tab 24
  edit "", 431, 100 39 26 13, autohs tab 24
  text "&seconds, ban type:", 432, 129 41 66 9, tab 24
  combo 433, 196 39 117 85, drop tab 24
  box "&Default banmask:", 434, 93 62 227 30, tab 24
  combo 435, 100 73 50 61, drop tab 24
  text "@", 436, 153 76 9 9, tab 24
  combo 437, 165 73 148 73, drop tab 24
  check "&Check your op status before performing op commands", 442, 93 98 233 9, tab 24
  check "&Display note when users trigger channel protection", 443, 93 109 233 9, tab 24
  check "&Show clones on join", 444, 93 120 113 9, tab 24
  check "&Add delay between kicks", 445, 207 120 120 9, tab 24
  check "&IRCop check on join", 446, 93 131 113 9, tab 24
  check "&Show users banned", 447, 207 131 113 9, tab 24
  check "&Whois users on join...", 448, 93 148 113 9, tab 24
  check "...&but only if you're opped", 449, 207 148 120 9, tab 24
  check "...&only if you're not away", 450, 207 159 120 9, tab 24
  check "...&show results in channel", 451, 207 170 120 9, tab 24
  check "&Rejoin if alone and not op", 458, 93 170 113 9, tab 24

  ; DCC accept [40-69]
  text "These options determine how PnP handles DCCs. They override mIRC's DCC settings. Selecting 'Warn' will reject a DCC and send a notice reminding the user you are not accepting DCCs.", 40, 93 14 227 36, tab 25
  box "DCC chat", 41, 173 55 73 122, tab 25
  box "DCC send (file)", 42, 253 55 73 122, tab 25
  text "When here:", 43, 93 67 80 9, tab 25
  text "&Known user:", 44, 100 82 73 9, tab 25
  combo 50, 180 79 60 61, group drop tab 25
  combo 51, 260 79 60 61, drop tab 25
  text "&Unknown user:", 45, 100 97 73 9, tab 25
  combo 52, 180 94 60 61, drop tab 25
  combo 53, 260 94 60 61, drop tab 25
  text "When away:", 46, 93 111 80 9, tab 25
  text "&Known user:", 47, 100 126 73 9, tab 25
  combo 54, 180 124 60 61, drop tab 25
  combo 55, 260 124 60 61, drop tab 25
  text "&Unknown user:", 48, 100 141 73 9, tab 25
  combo 56, 180 138 60 61, drop tab 25
  combo 57, 260 138 60 61, drop tab 25
  text "&User with DCC auth:", 49, 100 156 73 9, tab 25
  combo 58, 180 153 60 61, drop tab 25
  combo 59, 260 153 60 61, drop tab 25

  ; Favorites [460-489,510-519]
  text "&Select/add a favorite network...", 460, 93 6 113 9, tab 26
  combo 470, 93 18 80 58, size edit tab 26
  button "&Add", 471, 180 18 26 14, tab 26
  button "&Del", 472, 180 36 26 14, tab 26
  text "...enter preferred info...", 461, 213 6 113 9, tab 26
  text "&Nick:", 462, 211 20 30 9, right tab 26
  edit "", 463, 243 18 84 13, autohs tab 26
  text "&Alt:", 464, 211 35 30 9, right tab 26
  edit "", 465, 243 33 84 13, autohs tab 26
  text "&E-Mail:", 466, 211 50 30 9, right tab 26
  edit "", 467, 243 47 84 13, autohs tab 26
  text "&Name:", 468, 211 65 30 9, right tab 26
  edit "", 469, 243 62 84 13, autohs tab 26
  list 487, 1 1 1 1, hide
  list 488, 1 1 1 1, hide
  list 489, 1 1 1 1, hide
  edit "", 512, 1 1 1 1, autohs hide
  text "&Add favorite channels:", 473, 93 92 113 9, tab 26
  combo 475, 93 104 80 58, size edit tab 26
  button "&Add", 476, 180 104 26 12, tab 26
  button "&Del", 477, 180 119 26 12, tab 26
  button "&Up", 478, 180 133 26 12, tab 26
  button "&Down", 479, 180 148 26 12, tab 26
  text "&Add favorite servers:", 474, 213 92 113 9, tab 26
  combo 480, 213 104 80 58, size edit tab 26
  button "&Add", 481, 300 104 26 12, tab 26
  button "&Del", 482, 300 119 26 12, tab 26
  button "&Up", 483, 300 133 26 12, tab 26
  button "&Down", 484, 300 148 26 12, tab 26
  check "&Join on connect", 485, 93 165 84 9, tab 26
  edit "", 510, 180 164 26 13, autohs tab 26
  check "&Connect on startup", 486, 213 165 113 9, tab 26

  ; Flashing [490-509]
  text "If mIRC is not the current application, it's taskbar button will flash on the following events, if selected.", 507, 93 14 227 36, tab 27
  box "When here:", 490, 167 42 73 61, tab 27
  box "When away:", 491, 247 42 73 61, tab 27
  text "New query window:", 492, 93 57 66 9, right tab 27
  text "Private message:", 493, 93 72 66 9, right tab 27
  text "DCC chat message:", 494, 93 87 66 9, right tab 27
  check "&Flash if here", 495, 173 57 60 9, tab 27
  check "&Flash if here", 497, 173 72 60 9, tab 27
  check "&Flash if here", 499, 173 87 60 9, tab 27
  check "&Flash if away", 496, 253 57 60 9, tab 27
  check "&Flash if away", 498, 253 72 60 9, tab 27
  check "&Flash if away", 500, 253 87 60 9, tab 27
  check "&Limit flashing to", 501, 93 116 64 9, tab 27
  edit "", 502, 160 115 26 13, autohs tab 27
  text "seconds (when here)", 503, 192 117 134 9, tab 27
  check "&Limit flashing to", 504, 93 131 64 9, tab 27
  edit "", 505, 160 130 26 13, autohs tab 27
  text "seconds (when away)", 506, 192 132 134 9, tab 27

  ; Language [520-539]
  text "Current language:", 520, 93 11 84 9, right tab 28
  edit "", 521, 180 8 93 13, autohs read tab 28
  text "Language selected:", 522, 93 25 84 9, right tab 28
  edit "", 523, 180 23 93 13, autohs read tab 28
  edit "", 529, 1 1 1 1, hide
  check "&Convert all popups to lowercase", 527, 180 38 146 9, tab 28
  check "&Convert ALL text to lowercase", 528, 180 49 146 9, tab 28
  text "To change PnP's language, select a language from the list below and click 'Select'. PnP will change to the new language when you close this options dialog. Please be patient, as loading a new language or changing the above options is time-consuming.", 524, 93 68 227 50, tab 28
  list 525, 93 119 180 61, sort tab 28
  button "&Select", 526, 280 119 40 14, tab 28

  ; Messages [540-559]
  text "&Editing", 541, 93 9 26 9, tab 29
  combo 542, 124 7 66 104, drop sort tab 29
  text "messages:", 543, 195 9 58 9, tab 29
  check "(alt. list format)", 555, 253 9 66 9, tab 29
  list 544, 93 23 227 60, size sort tab 29
  list 552, 1 1 1 1, hide
  list 553, 1 1 1 1, hide
  edit "", 556, 1 1 1 1, autohs hide
  edit "", 557, 1 1 1 1, autohs hide
  text "", 554, 93 88 227 9, tab 29
  text "&Enter a message or select a default from the dropdown:", 545, 93 100 227 9, tab 29
  combo 546, 93 113 227 104, edit drop tab 29
  text "This is a sample of how your message will look:", 547, 93 130 227 9, tab 29
  icon 548, 93 142 227 13, script\pnp.ico, tab 29
  text "", 549, 93 167 126 9, tab 29
  edit "", 550, 220 164 26 13, autohs tab 29
  edit "", 551, 251 164 26 13, autohs tab 29

  ; Protection [560-599]
  check "&Send script reply to VERSION CTCPs", 560, 93 6 233 9, tab 30
  check "&Reply to other CTCPs-", 561, 93 17 233 9, tab 30
  button "&Edit Replies", 562, 108 30 66 14, tab 30
  check "&DCC flood protection enabled", 563, 93 49 233 9, tab 30
  check "&CTCP flood protection enabled", 564, 93 60 233 9, tab 30
  check "&Change nick randomly if protection triggered", 565, 93 71 233 9, tab 30
  check "&Verify channels you are invited to", 581, 93 82 233 9, tab 30
  check "&Close DCC chat on flood:", 566, 93 103 106 9, tab 30
  edit "", 567, 200 101 26 13, autohs tab 30
  text "lines", 568, 229 104 33 9, tab 30
  edit "", 569, 264 101 26 13, autohs tab 30
  text "seconds", 570, 293 104 40 9, tab 30
  check "&Ignore queries on flood:", 571, 93 117 106 9, tab 30
  edit "", 572, 200 116 26 13, autohs tab 30
  text "queries", 573, 229 119 33 9, tab 30
  edit "", 574, 264 116 26 13, autohs tab 30
  text "seconds", 575, 293 119 40 9, tab 30
  check "&Ignore notices on flood:", 576, 93 132 106 9, tab 30
  edit "", 577, 200 131 26 13, autohs tab 30
  text "lines", 578, 229 133 33 9, tab 30
  edit "", 579, 264 131 26 13, autohs tab 30
  text "seconds", 580, 293 133 40 9, tab 30
  check "&Send self lag check every", 582, 93 151 106 9, tab 30
  edit "", 583, 200 149 26 13, autohs tab 30
  text "seconds", 584, 229 152 80 9, tab 30
  check "&Show self lag warnings at", 585, 93 165 106 9, tab 30
  edit "", 586, 200 164 26 13, autohs tab 30
  text "and", 587, 229 167 33 9, tab 30
  edit "", 588, 264 164 26 13, autohs tab 30
  text "seconds", 589, 293 167 40 9, tab 30

  ; Serverlist [600-619]
  text "PnP can include popups in status listing all known servers for a network. Add networks by entering their name (such as 'Undernet') and clicking 'Add', below.", 604, 93 6 227 29, tab 31
  check "&Enable serverlist popups in status:", 600, 93 36 227 9, tab 31
  combo 601, 93 49 180 73, size edit tab 31
  button "&Add", 602, 280 49 40 14, tab 31
  button "&Del", 603, 280 67 40 14, tab 31
  text "Servers shown in the serverlist are taken from mIRC's servers.ini. Update servers.ini and click 'Refresh' to refresh the serverlist popups.", 605, 93 128 227 29, tab 31
  button "&Refresh", 606, 253 158 66 14, tab 31
  edit "", 607, 1 1 1 1, hide
  text "The serverlist will refresh when you close this dialog.", 608, 93 158 160 19, hide tab 31

  ; Titlebar [620-649]
  check "&Update mIRC titlebar with info:", 638, 93 12 160 9, tab 32
  box "When here:", 620, 93 30 106 115, tab 32
  check "&Network", 621, 100 42 93 12, tab 32
  check "&Nickname", 622, 100 55 93 12, tab 32
  check "&Self-lag", 623, 100 67 93 12, tab 32
  check "&Active window", 624, 100 79 93 12, tab 32
  text "(and data)", 625, 112 90 81 12, tab 32
  check "&Pager", 626, 100 104 93 12, tab 32
  check "&Time", 627, 100 116 93 12, tab 32
  check "&Idle", 628, 100 128 93 12, tab 32
  box "When away:", 629, 213 30 106 115, tab 32
  check "&Network", 630, 220 42 93 12, tab 32
  check "&Nickname", 631, 220 55 93 12, tab 32
  check "&Self-lag", 632, 220 67 93 12, tab 32
  check "&Away reason", 633, 220 79 93 12, tab 32
  check "&Away logging", 634, 220 92 93 12, tab 32
  check "&Pager", 635, 220 104 93 12, tab 32
  check "&Time", 636, 220 116 93 12, tab 32
  check "&Idle", 637, 220 128 93 12, tab 32
  text "Note: Idle time will only be shown if over 90 seconds.", 639, 93 159 227 9, tab 32

  ; Other [650-679]
  text "&Channel nick-completion character(s):", 650, 93 18 133 9, right tab 33
  edit "", 651, 229 15 40 13, autohs tab 33
  text "&Inline nick-completion prefix:", 652, 93 33 133 9, right tab 33
  edit "", 653, 229 30 40 13, autohs tab 33
  check "&Ask if multiple matches found for nick-completion", 654, 100 51 227 9, tab 33
  check "&Use nick-completion in commands (/kick, /op, etc.)", 655, 100 62 227 9, tab 33
  check "&Strip colors/attributes from all script messages sent to IRC", 656, 100 79 227 9, tab 33
  box "Use /b as:", 657, 93 97 73 41, tab 33
  radio "/bac&k", 658, 106 109 53 9, group tab 33
  radio "/ba&n", 659, 106 121 53 9, tab 33
  box "FKeys for recent events: (CtrlF1, etc.)", 660, 173 97 153 41, tab 33
  radio "&Cycle through all choices", 661, 187 109 133 9, group tab 33
  radio "&Automatically use most recent", 662, 187 121 133 9, tab 33
  box "FKeys to use for misc. events such as DNS:", 663, 93 146 233 29, tab 33
  radio "&F7", 664, 106 158 66 9, group tab 33
  radio "&F10", 665, 173 158 66 9, tab 33
  radio "&Any", 666, 240 158 73 9, tab 33
}

; /_config [#]
; Open configuration dialog
alias _config {
  set -u %.section $1
  if ($1 == $null) set -u %.section $_dlgi(cfg)
  _dialog -md pnp.config pnp.config
}

; Dialog init
on *:DIALOG:pnp.config:init:*:{
  ; prep combos/lists
  loadbuf -otconfig $dname 901 "script\dlgtext.dat"
  var %num = 33
  ; (mark all sections as un-viewed)
  while (%num > 0) {
    did -a $dname 902 0
    dec %num
  }

  ; Used for preview of msgs
  window -fhnp +d @.msgprev 0 0 340 22

  ;  show first or selected section of dialog
  if ((%.section !isnum) || ($gettok($did(901,%.section),1,32) == $null) || ($findtok(1 6 16,%.section,32))) %.section = 2
  did -c $dname 901 %.section
  page.show %.section
  ;!! Need a timer for this at this time
  .timer -mio 1 0 did -c pnp.config %.section $chr(124) did -f pnp.config 901

  unset %.section
}

; Select new section, unless a 'blank' section was selected
; Selecting the top item of a group (Away, Display, Popups) will select the
; first item of the group
on *:DIALOG:pnp.config:sclick:901:{
  if ($gettok($did(901).seltext,1,32) == $null) did -c $dname 901 $did(903)
  elseif ($findtok(1 6 16,$did(901).sel,32)) {
    did -c $dname 901 $calc($did(901).sel + 1)
    page.show $did(901).sel
  }
  else page.show $did(901).sel
}

; Close dialog
on *:DIALOG:pnp.config:sclick:905:{
  ; Apply all modified pages
  var %num = 33
  while (%num > 0) {
    if ($did(902,%num) == 1) page.apply %num
    dec %num
  }

  ; Cleanup
  _dlgw cfg $did(903)
  window -c @.msgprev
  .remove script\temp\msgprev.bmp
  .timer.config.msgpreview off
  .timer.msgview.fix off
  _unload config
  dialog -x pnp.config
}

; Cleanup
on *:DIALOG:pnp.config:sclick:906:{
  _dlgw cfg $did(903)
  window -c @.msgprev
  .remove script\temp\msgprev.bmp
  .timer.config.msgpreview off
  .timer.msgview.fix off
  _unload config
}

; If tabs are 'clicked', undo any changes
on *:DIALOG:pnp.config:sclick:1,2,3,4,7,8,9,10,11,12,13,14,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,33:{
  did -f pnp.config 901
  did -c pnp.config $did(903)
}

; Handle various dynamic parts of the dialog- disable/enable on clicks, etc.
on *:DIALOG:pnp.config:*:*:{
  var %ranges = * 70-99 100-129 130-149 * * 150-159 160-189 190-209 210-229 230-249 250-269 270-289 290-309 * * 310-329 330-349 350-369 370-389 390-409 410-429 * 430-459 40-69 460-489 490-519 520-539 540-559 560-599 600-619 620-649 650-679

  ; Current range being shown
  var %shown = $gettok(%ranges,$did(901).sel,32)

  ; If an item in that range was modified, call page.mod
  if ($did isnum %shown) page.mod $did(901).sel
}

; /page.show n
; Show a page of the dialog
alias -l page.show {
  ; (do nothing if same page as before)
  if ($did(903) == $1) return

  ; If area hasn't been visited yet, we must prep it
  if ($did(902,$1) == 0) {
    ; Mark as visited and initialize
    did -o pnp.config 902 $1 1
    page.init $1
    page.mod $1 1
  }

  ; Fixes windows bug with showing && in tabbed dialogs
  if ($1 == 4) did -ro pnp.config 138 1 $chr(40) $+ use &&me&& to represent old nick $+ $chr(41)
  if ($1 == 29) {
    var %left = &&[&&
    var %right = &&]&&
    did -ro pnp.config 549 1 & $+ Brackets- Replace %left and %right with:
  }

  ; Remember what page we did last, show tab, move focus back to list, set default to O
  did -o pnp.config 903 1 $1
  did -c pnp.config $1
  did -f pnp.config 901
  did -t pnp.config 905
}

; /page.init n
; Prepare a page of the dialog from our configuration and/or prep any combos, lists, etc.
; Will not be called more than once for a page, so you can assume everything is blank/unchecked at this point
alias -l page.init {
  goto $1

  ; Away - Pager/Log
  :2
  did -a $dname 75,76,77 On
  did -a $dname 75,76,77 Off
  did -a $dname 75,76,77 Quiet
  loadbuf -otawayopt1 $dname 82 "script\dlgtext.dat"
  loadbuf -otawayopt2 $dname 84 "script\dlgtext.dat"
  did -c $dname 75 $iif($_cfgi(away.pager) == quiet,3,$iif($_cfgi(away.pager),1,2))
  did -c $dname 76 $iif($_cfgi(autoaway.pager) == quiet,3,$iif($_cfgi(autoaway.pager),1,2))
  did -c $dname 77 $iif($_cfgi(back.pager) == quiet,3,$iif($_cfgi(back.pager),1,2))
  if ($_cfgi(away.log)) did -c $dname 78
  if ($_cfgi(autoaway.log)) did -c $dname 79
  if ($hget(pnp.config,awaylog.msg)) did -c $dname 81
  did -c $dname 82 $calc(1 + $hget(pnp.config,awaylog.close))
  if ($hget(pnp.config,awaylog.chan)) {
    did -c $dname 83
    did -c $dname 84 $ifmatch
  }
  else did -c $dname 84 1
  if ($_cfgi(pager.classic)) did -c $dname 85
  if ($_cfgi(awaylog.clear)) did -c $dname 86
  if ($_cfgi(away.closeq)) did -c $dname 87
  if ($hget(pnp.config,awaylog.perm)) did -c $dname 88
  return

  ; Away - Message
  :3
  if ($_cfgi(away.act)) did -c $dname 101
  else did -c $dname 102
  if ($_cfgi(away.chan)) did -c $dname 104
  if ($_cfgi(away.msg)) did -c $dname 105
  if ($_cfgi(away.ignchan)) did -c $dname 106
  if ($_cfgi(away.ignchanlist)) did -a $dname 107 $ifmatch
  if ($_cfgi(away.ignidle)) did -c $dname 108
  if ($_cfgi(away.ignidletime) isnum) did -a $dname 110 $ifmatch
  else did -a $dname 110 30
  if ($_cfgi(away.rep)) did -c $dname 111
  if ($_cfgi(away.delay) isnum) did -a $dname 113 $ifmatch
  else did -a $dname 113 30
  if ($hget(pnp.config,away.remind)) did -c $dname 115
  if ($hget(pnp.config,awaywords.hl)) did -c $dname 116
  if ($hget(pnp.config,awaywords)) did -c $dname 117
  if ($hget(pnp.config,awaywords.words)) did -a $dname 118 $ifmatch
  if ($hget(pnp.config,awaywords.limit)) did -c $dname 119
  if ($hget(pnp.config,awaywords.chans)) did -a $dname 120 $ifmatch
  return

  ; Away - Other
  :4
  if ($hget(pnp.config,autoaway)) did -c $dname 131
  if ($hget(pnp.config,autoaway.time) isnum) did -a $dname 133 $calc($ifmatch / 60)
  else did -a $dname 133 30
  if ($_cfgi(autoaway.ask)) did -c $dname 134
  if ($_cfgi(autoaway.quiet)) did -c $dname 135
  if ($_cfgi(away.chnick)) did -c $dname 136
  if ($_cfgi(away.nick)) did -a $dname 137 $ifmatch
  else did -a $dname 137 &me&Away
  if ($_cfgi(away.sndoff)) did -c $dname 139
  if ($_cfgi(away.beepoff)) did -c $dname 140
  if ($_cfgi(away.deop)) did -c $dname 141
  if ($_cfgi(away.dq)) did -c $dname 142
  if ($_cfgi(away.allconnect)) did -c $dname 143
  return

  ; Display - Nick colors
  :7
  if ($_cfgi(nickcol)) did -c $dname 150
  if ($hget(pnp.config,themecol)) did -c $dname 151
  if ($hget(pnp.config,lagtime) isnum) did -a $dname 153 $ifmatch
  else did -a $dname 20
  return

  ; Display - Notify
  :8
  var %did = 165
  while (%did <= 170) {
    loadbuf -otnotify $dname %did "script\dlgtext.dat"
    inc %did
  }
  loadbuf -otnotifywin $dname 176 "script\dlgtext.dat"
  did -c $dname 165 $calc(1 + $findtok(ext hide,$_cfgi(notify.match),32))
  did -c $dname 166 $calc(1 + $findtok(ext hide,$_cfgi(notify.fail),32))
  did -c $dname 167 $calc(1 + $findtok(ext hide,$_cfgi(notify.nocheck),32))
  did -c $dname 168 $calc(1 + $findtok(ext hide,$_cfgi(unotify.match),32))
  did -c $dname 169 $calc(1 + $findtok(ext hide,$_cfgi(unotify.fail),32))
  did -c $dname 170 $calc(1 + $findtok(ext hide,$_cfgi(unotify.nocheck),32))
  if ($_cfgi(notify.beepmatch)) did -c $dname 172
  if ($_cfgi(notify.beepfail)) did -c $dname 173
  if ($_cfgi(notify.beepnocheck)) did -c $dname 174
  did -c $dname 176 $calc(1 + $findtok(-si2 none off,$hget(pnp.config,notify.win),32))
  if ($_cfgi(unotify.part)) did -c $dname 177
  if ($hget(pnp.config,show.fkeys)) did -c $dname 178
  return

  ; Display - Ping
  :9
  loadbuf -otpingwin1 $dname 191 "script\dlgtext.dat"
  loadbuf -otpingwin2 $dname 193 "script\dlgtext.dat"
  did -c $dname 191 $calc(1 + $findtok(-si2 @Ping * none,$hget(pnp.config,ping.bulk),32))
  did -c $dname 193 $calc(1 + $findtok(-si2 *,$hget(pnp.config,ping.one),32))
  if ($hget(pnp.config,ping.focus) == min) did -c $dname 195
  if ($hget(pnp.config,ping.focus) == front) did -c $dname 196
  if ($hget(pnp.config,ping.retain)) did -c $dname 197
  if ($hget(pnp.config,show.pingcode)) did -c $dname 198
  return

  ; Display - Server notices
  :10
  loadbuf -otsnotice $dname 223 "script\dlgtext.dat"
  if ($hget(pnp.config,snotice.on)) did -c $dname 213
  did -c $dname 223 $calc(1 + $findtok(-si2 @SNotice,$hget(pnp.config,snotice.win),32))
  var %ln = 1,%filter = $hget(pnp.config,snotice.f)
  while ($read(script\snotice.dat,n,%ln)) {
    var %data = $ifmatch,%to = 218
    if ($mid(%filter,%ln,1)) %to = 216
    did -a $dname %to %data
    did -i $dname $calc(%to + 1) $didwm($dname,%to,%data,1) %ln
    inc %ln
  }
  return

  ; Display - Text
  :11
  if ($hget(pnp.config,copy.query)) did -c $dname 231
  if ($_cfgi(texts)) did -c $dname 230
  if ($hget(pnp.config,reg.notice) isnum 0-2) did -c $dname $calc(233 + $ifmatch)
  else did -c $dname 233
  if ($hget(pnp.config,op.notice) isnum 0-2) did -c $dname $calc(237 + $ifmatch)
  else did -c $dname 237
  if ($hget(pnp.config,serv.notice) isnum 0-2) did -c $dname $calc(241 + $ifmatch)
  else did -c $dname 241

  return

  ; Display - Wallops
  :12
  loadbuf -otwallop $dname 263 "script\dlgtext.dat"
  if ($hget(pnp.config,wallop.on)) did -c $dname 253
  did -c $dname 263 $calc(1 + $findtok(-si2 @Wallop,$hget(pnp.config,wallop.win),32))
  var %ln = 1,%filter = $hget(pnp.config,wallop.f)
  while ($read(script\wallop.dat,n,%ln)) {
    var %data = $ifmatch,%to = 258
    if ($mid(%filter,%ln,1)) %to = 256
    did -a $dname %to %data
    did -i $dname $calc(%to + 1) $didwm($dname,%to,%data,1) %ln
    inc %ln
  }
  return

  ; Display - Whois replies
  :13
  loadbuf -otwhoiswin $dname 271 "script\dlgtext.dat"
  did -c $dname 271 $calc(1 + $findtok(-si2 @Whois *,$hget(pnp.config,whois.win),32))
  if ($_cfgi(whois.q)) did -c $dname 273
  if ($_cfgi(whois.focus) == min) did -c $dname 274
  if ($_cfgi(whois.focus) == front) did -c $dname 275
  if ($_cfgi(whois.retain)) did -c $dname 276
  if ($_cfgi(whois.serv)) did -c $dname 277
  if ($hget(pnp.config,whois.shared)) did -c $dname 278
  did -c $dname $calc(280 + $findtok(off hide,$hget(pnp.config,whois.nick),32))
  return

  ; Display - Other
  :14
  loadbuf -otnames $dname 291 "script\dlgtext.dat"
  loadbuf -otmotdwhen $dname 293 "script\dlgtext.dat"
  did -c $dname 291 $calc(1 + $_cfgi(show.names))
  did -c $dname 293 $calc(1 + $findtok(off changes,$_cfgi(motd.disp),32))
  if ($_cfgi(format.time)) did -o $dname 295 0 $ifmatch
  else did -o $dname 295 0 hh:nnt
  did -a $dname 295 05:30p
  did -a $dname 295 05:30pm
  did -a $dname 295 05:30P
  did -a $dname 295 05:30PM
  did -a $dname 295 17:30
  if ($_cfgi(format.date)) did -o $dname 297 0 $ifmatch
  else did -o $dname 297 0 ddd doo mmm yyyy
  did -a $dname 297 Mon 25th Jan 2002
  did -a $dname 297 Jan 25, 2002
  did -a $dname 297 01/25/02
  did -a $dname 297 25/01/02
  did -a $dname 297 01/25/2002
  did -a $dname 297 25/01/2002
  if ($_cfgi(eroute) == -ai2) did -c $dname 298
  if ($hget(pnp.config,rawroute) == -ai2) did -c $dname 302
  if ($_cfgi(motd.win) == @MOTD) did -c $dname 299
  if (!$_cfgi(hidesplash)) did -c $dname 300
  return

  ; Popups - Channel
  :17
  var %pos = 1,%data = $hget(pnp.config,popups.3)
  while (%pos <= 11) {
    if ($mid(%data,%pos,1)) did -c $dname $calc(309 + %pos)
    inc %pos
  }
  ; hide-ops are linked between this and nicklist page- so if we've visited nicklist, don't touch
  if ($did(902,19) == 0) {
    if ($hget(pnp.config,popups.hideop)) did -c $dname 321,362
  }
  return

  ; Popups - Menubar
  :18
  var %pos = 1,%data = $hget(pnp.config,popups.1)
  while (%pos <= 10) {
    if ($mid(%data,%pos,1)) did -c $dname $calc(329 + %pos)
    inc %pos
  }
  return

  ; Popups - Nicklist
  :19
  var %pos = 1,%data = $hget(pnp.config,popups.4)
  while (%pos <= 12) {
    if ($mid(%data,%pos,1)) did -c $dname $calc(349 + %pos)
    inc %pos
  }
  ; hide-ops are linked between this and nicklist page- so if we've visited channel, don't touch
  if ($did(902,17) == 0) {
    if ($hget(pnp.config,popups.hideop)) did -c $dname 321,362
  }
  return

  ; Popups - Query
  :20
  var %pos = 1,%data = $hget(pnp.config,popups.2)
  while (%pos <= 11) {
    if ($mid(%data,%pos,1)) did -c $dname $calc(369 + %pos)
    inc %pos
  }
  return

  ; Popups - Status
  :21
  var %pos = 1,%data = $hget(pnp.config,popups.5)
  while (%pos <= 11) {
    if ($mid(%data,%pos,1)) did -c $dname $calc(389 + %pos)
    inc %pos
  }
  return

  ; Popups - @Windows
  :22
  var %pos = 1,%data = $hget(pnp.config,popups.6)
  while (%pos <= 6) {
    if ($mid(%data,%pos,1)) did -c $dname $calc(409 + %pos)
    inc %pos
  }
  return

  ; Channel options
  :24
  loadbuf -ottempban $dname 433 "script\dlgtext.dat"
  loadbuf -otidentmask $dname 435 "script\dlgtext.dat"
  loadbuf -othostmask $dname 437 "script\dlgtext.dat"
  did -ac $dname 453 (default)
  did -a $dname 454 $hget(pnp.config,chopt)
  var %ch = $hmatch(pnp.config,chopt.?*,0)
  while (%ch) {
    var %item = $hmatch(pnp.config,chopt.?*,%ch)
    did -a $dname 453 $right(%item,-6)
    did -i $dname 454 $_scandid($dname,453,$right(%item,-6)) $hget(pnp.config,%item)
    dec %ch
  }
  return

  ; DCC accept
  :25
  var %did = 50,%opt = $hget(pnp.config,dcc.opt)
  while (%did <= 59) {
    loadbuf -otdccaccept $dname %did "script\dlgtext.dat"
    did -c $dname %did $gettok(1 3 4 2,$calc($mid(%opt,$calc(%did - 49),1) + 1),32)
    inc %did
  }
  return

  ; Favorites
  :26
  var %ini = $_cfg(config.ini)
  var %ln = $ini(%ini,favopt,0)
  while (%ln) {
    var %item = $ini(%ini,favopt,%ln)
    if (%item != all) did -a $dname 470 %item
    dec %ln
  }
  filter -ioct 1 32 $dname 470 $dname 470
  %ln = $did($dname,470).lines
  if (%ln) did -c $dname 470 1
  while (%ln) {
    var %item = $did($dname,470,%ln)
    var %favs = $readini(%ini,n,fav,%item)
    var %favservs = $readini(%ini,n,favserv,%item)
    var %favopts = $readini(%ini,n,favopt,%item)
    did -i $dname 487 1 - $replace(%favs,$chr(44),$chr(32))
    did -i $dname 488 1 - $replace(%favservs,$chr(44),$chr(32))
    did -i $dname 489 1 %favopts
    dec %ln
  }
  var %ln = 1,%chans
  while (%=chan. [ $+ [ %ln ] ] ) {
    %chans = %chans %=chan. [ $+ [ %ln ] ]
    inc %ln
  }
  did -i $dname 470 1 (channels menu)
  did -i $dname 487 1 - %chans
  did -i $dname 488 1 -
  did -i $dname 489 1 $iif($_cfgi(fill.chan),1,0) $iif($_cfgi(num.chan) isnum,$ifmatch,10) - - -
  did -i $+ $iif($did(470).lines < 2,c) $dname 470 1 (all networks)
  did -i $dname 487 1 - $replace($readini(%ini,n,fav,all),$chr(44),$chr(32))
  did -i $dname 488 1 -
  did -i $dname 489 1 $iif($gettok($readini(%ini,n,favopt,all),1,32),1 0 - - -,0 0 - - -)
  return

  ; Flashing
  :27
  var %opt = $hget(pnp.config,flash.opt),%pos = 1
  while (%pos <= 6) {
    if ($mid(%opt,%pos,1)) did -c $dname $calc(494 + %pos)
    inc %pos
  }
  if (($_cfgi(flash.here) isnum) && ($_cfgi(flash.here) > 0)) {
    did -a $dname 502 $ifmatch
    did -c $dname 501
  }
  else did -a $dname 502 10
  if (($_cfgi(flash.away) isnum) && ($_cfgi(flash.away) > 0)) {
    did -a $dname 505 $ifmatch
    did -c $dname 504
  }
  else did -a $dname 505 10
  return

  ; Language
  :28
  if ($readini(script\transup.ini,n,translation,enabled) == no) {
    did -ra $dname 524 This installation of PnP does not currently support translation. You may download a version that supports translation at pnp.kristshell.net/.
    did -b $dname 520,521,522,523,527,528,525,526
  }
  if ($readini(script\transup.ini,n,translation,language)) did -a $dname 521 $ifmatch
  else did -a $dname 521 English
  if ($readini(script\transup.ini,n,translation,transopt)) did -a $dname 529 $ifmatch
  else did -a $dname 529 -
  if (p isin $did($dname,529)) did -c $dname 527
  if (l isin $did($dname,529)) did -c $dname 528
  window -nhl @.trans
  var %num = $findfile(script\trans\,*.ini,@.trans)
  while (%num) {
    var %lang = $readini($line(@.trans,%num),n,info,language)
    if (%lang) did -a $dname 525 %lang
    dec %num
  }
  window -c @.trans
  return

  ; Messages
  :29
  window -nhl @.msgs
  loadbuf @.msgs script\msgdefs.dat
  var %ln = $line(@.msgs,0)
  var %last
  while (%ln) {
    var %data = $line(@.msgs,%ln)
    ; (ALL msgs data and current msg gets loaded into 552)
    var %curr = $read($_cfg(msgs.dat),ns,$gettok(%data,2,32))
    if (%curr == $null) %curr = $_p2s($gettok($gettok(%data,5,32),1,124))
    did -a $dname 552 $gettok(%data,1-4,32) %curr
    if ($gettok(%data,1,32) != %last) {
      %last = $ifmatch
      did -a $dname 542 $_p2s(%last)
    }
    dec %ln
  }
  window -c @.msgs
  did -ac $dname 542 (all)
  if ($hget(pnp.config,bracket.left)) did -a $dname 550 $ifmatch
  if ($hget(pnp.config,bracket.right)) did -a $dname 551 $ifmatch
  return

  ; Protection
  :30
  var %prot = $hget(pnp.config,myflood.prot)
  if (%prot & 1) did -c $dname 564
  if (%prot & 2) did -c $dname 563
  if (%prot & 4) did -c $dname 565
  if (%prot & 8) did -c $dname 560
  if (%prot & 16) did -c $dname 561
  if ($_cfgi(verify.inv)) did -c $dname 581
  var %cfg = $hget(pnp.config,xchat.cfg)
  if ($gettok(%cfg,1,32)) did -c $dname 566
  if ($gettok(%cfg,2,32) isnum) did -a $dname 567 $ifmatch
  else did -a $dname 567 50
  if ($gettok(%cfg,3,32) isnum) did -a $dname 569 $ifmatch
  else did -a $dname 569 5
  var %cfg = $_cfgi(xquery.cfg)
  if ($gettok(%cfg,1,32)) did -c $dname 571
  if ($gettok(%cfg,2,32) isnum) did -a $dname 572 $ifmatch
  else did -a $dname 572 5
  if ($gettok(%cfg,3,32) isnum) did -a $dname 574 $ifmatch
  else did -a $dname 574 5
  var %cfg = $hget(pnp.config,xnotice.cfg)
  if ($gettok(%cfg,1,32)) did -c $dname 576
  if ($gettok(%cfg,2,32) isnum) did -a $dname 577 $ifmatch
  else did -a $dname 577 30
  if ($gettok(%cfg,3,32) isnum) did -a $dname 579 $ifmatch
  else did -a $dname 579 5
  if (($_cfgi(sptime) isnum) && ($_cfgi(sptime) > 0)) {
    did -a $dname 583 $ifmatch
    did -c $dname 582
  }
  else {
    did -a $dname 583 30
  }
  if ($_cfgi(spwarn1) isnum) did -a $dname 586 $ifmatch
  if ($_cfgi(spwarn2) isnum) did -a $dname 588 $ifmatch
  if (($did($dname,586)) || ($did($dname,588))) did -c $dname 585
  else {
    did -ra $dname 586 30
    did -ra $dname 588 60
  }
  return

  ; Serverlist
  :31
  if ($_cfgx(serverlist,on)) did -c $dname 600
  var %nets = $_cfgx(serverlist,groups),%ln = 1
  while ($gettok(%nets,%ln,32)) {
    did -a $dname 601 $ifmatch
    inc %ln
  }
  return

  ; Titlebar
  :32
  if ($hget(pnp.config,title.bar)) did -c $dname 638
  var %here = $_cfgi(title.here)
  var %away = $_cfgi(title.away)
  var %pos = 1
  while (%pos <= 8) {
    if (($mid(%here,%pos,1)) && (%pos != 5)) did -c $dname $calc(620 + %pos)
    if ($mid(%away,%pos,1)) did -c $dname $calc(629 + %pos)
    inc %pos
  }
  return

  ; Other
  :33
  if ($hget(pnp.config,nc.char)) did -a $dname 651 $ifmatch
  if ($hget(pnp.config,nci.char)) did -a $dname 653 $ifmatch
  if ($_cfgi(nc.ask)) did -c $dname 654
  if ($hget(pnp.config,nc.cmd)) did -c $dname 655
  if ($hget(pnp.config,strip.auto)) did -c $dname 656
  if ($_cfgi(b.ban)) did -c $dname 659
  else did -c $dname 658
  if ($_cfgi(recent.auto)) did -c $dname 662
  else did -c $dname 661
  if ($_cfgi(reserve.fkey) == 2) did -c $dname 666
  elseif ($_cfgi(reserve.fkey) == 1) did -c $dname 664
  else did -c $dname 665
  return
}

; /page.apply n
; Save a page of the dialog to configuration
alias -l page.apply {
  ; Save current options?
  if ($istok(24 26 29,$1,32)) page.mod $1 0 1
  goto $1

  ; Away - Pager/Log
  :2
  _cfgw away.pager $gettok(1 0 quiet,$did(75).sel,32)
  _cfgw autoaway.pager $gettok(1 0 quiet,$did(76).sel,32)
  _cfgw back.pager $gettok(1 0 quiet,$did(77).sel,32)
  _cfgw away.log $did(78).state
  _cfgw autoaway.log $did(79).state
  `set awaylog.msg $did(81).state
  `set awaylog.close $calc($did(82).sel - 1)
  if (!$did(83).state) `set awaylog.chan 0
  else `set awaylog.chan $did(84).sel
  _cfgw pager.classic $did(85).state
  _cfgw awaylog.clear $did(86).state
  _cfgw away.closeq $did(87).state
  `set awaylog.perm $did(88).state
  return

  ; Away - Message
  :3
  _cfgw away.act $did(101).state
  _cfgw away.chan $did(104).state
  _cfgw away.msg $did(105).state
  _cfgw away.ignchan $did(106).state
  _cfgw away.ignchanlist $gettok($replace($did(107),$chr(32),$chr(44)),1-,44)
  _cfgw away.ignidle $did(108).state
  _cfgw away.ignidletime $iif($did(110) isnum,$did(110),30)
  _cfgw away.rep $did(111).state
  _cfgw away.delay $iif($did(113) isnum,$did(113),30)
  `set away.remind $did(115).state
  `set awaywords.hl $did(116).state
  `set awaywords $did(117).state
  `set awaywords.words $did(118)
  `set awaywords.limit $did(119).state
  `set awaywords.chans $gettok($replace($did(120),$chr(32),$chr(44)),1-,44)
  return

  ; Away - Other
  :4
  `set autoaway $did(131).state
  `set autoaway.time $iif($did(133) isnum,$int($calc($ifmatch * 60)),1800)
  _cfgw autoaway.ask $did(134).state
  _cfgw autoaway.quiet $did(135).state
  _cfgw away.chnick $did(136).state
  _cfgw away.nick $iif($did(137),$ifmatch,&me&Away)
  _cfgw away.sndoff $did(139).state
  _cfgw away.beepoff $did(140).state
  _cfgw away.deop $did(141).state
  _cfgw away.dq $did(142).state
  _cfgw away.allconnect $did(143).state
  return

  ; Display - Nick colors
  :7
  _cfgw nickcol $did(150).state
  `set themecol $did(151).state
  `set lagtime $iif($did(153) isnum,$ifmatch,20)
  _upd.texts
  .nickcol
  return

  ; Display - Notify
  :8
  _cfgw notify.match $gettok(show ext hide,$did(165).sel,32)
  _cfgw notify.fail $gettok(show ext hide,$did(166).sel,32)
  _cfgw notify.nocheck $gettok(show ext hide,$did(167).sel,32)
  _cfgw unotify.match $gettok(show ext hide,$did(168).sel,32)
  _cfgw unotify.fail $gettok(show ext hide,$did(169).sel,32)
  _cfgw unotify.nocheck $gettok(show ext hide,$did(170).sel,32)
  _cfgw notify.beepmatch $did(172).state
  _cfgw notify.beepfail $did(173).state
  _cfgw notify.beepnocheck $did(174).state
  `set notify.win $gettok(-ai2 -si2 none off,$did(176).sel,32)
  _cfgw unotify.part $did(177).state
  `set show.fkeys $did(178).state
  return

  ; Display - Ping
  :9
  `set ping.bulk $gettok(-ai2 -si2 @Ping * none,$did(191).sel,32)
  `set ping.one $gettok(-ai2 -si2 *,$did(193).sel,32)
  `set ping.focus $iif($did(195).state,min,$iif($did(196).state,front,norm))
  `set ping.retain $did(197).state
  `set show.pingcode $did(198).state
  return

  ; Display - Server notices
  :10
  `set snotice.on $did(213).state
  `set snotice.win $gettok(-ai2 -si2 @SNotice,$did(223).sel,32)
  var %filter = $str(0,$calc($did(217).lines + $did(219).lines))
  var %ln = $did(217).lines
  ; (set all in 'show' to 1 in filter)
  while (%ln) {
    var %pos = $did(217,%ln)
    %filter = $left(%filter,$calc(%pos - 1)) $+ 1 $+ $mid(%filter,$calc(%pos + 1))
    dec %ln
  }
  ; Set to a letter first due to mirc bug when comparing very large numeric strings
  `set snotice.f a
  `set snotice.f %filter
  return

  ; Display - Text
  :11
  `set copy.query $did(231).state
  _cfgw texts $did(230).state
  `set reg.notice $iif($did(234).state,1,$iif($did(235).state,2,0))
  `set op.notice $iif($did(238).state,1,$iif($did(239).state,2,0))
  `set serv.notice $iif($did(242).state,1,$iif($did(243).state,2,0))
  _upd.texts
  return

  ; Display - Wallops
  :12
  `set wallop.on $did(253).state
  `set wallop.win $gettok(-ai2 -si2 @Wallop,$did(263).sel,32)
  var %filter = $str(0,$calc($did(257).lines + $did(259).lines))
  var %ln = $did(257).lines
  ; (set all in 'show' to 1 in filter)
  while (%ln) {
    var %pos = $did(257,%ln)
    %filter = $left(%filter,$calc(%pos - 1)) $+ 1 $+ $mid(%filter,$calc(%pos + 1))
    dec %ln
  }
  ; Set to a letter first due to mirc bug when comparing very large numeric strings
  `set wallop.f a
  `set wallop.f %filter
  return

  ; Display - Whois replies
  :13
  `set whois.win $gettok(-ai2 -si2 @Whois *,$did(271).sel,32)
  _cfgw whois.q $did(273).state
  _cfgw whois.focus $iif($did(274).state,min,$iif($did(275).state,front,norm))
  _cfgw whois.retain $did(276).state
  _cfgw whois.serv $did(277).state
  `set whois.shared $did(278).state
  `set whois.nick $iif($did(280).state,on,$iif($did(281).state,off,hide))
  return

  ; Display - Other
  :14
  _cfgw show.names $calc($did(291).sel - 1)
  _cfgw motd.disp $gettok(on off changes,$did(293).sel,32)
  _cfgw format.time $iif($did(295),$did(295),hh:nnt)
  _cfgw format.date $iif($did(297),$did(297),ddd doo mmm yyy)
  _cfgw eroute $iif($did(298).state,-ai2,-si2)
  `set rawroute $iif($did(302).state,-ai2,-si2)
  _cfgw motd.win $iif($did(299).state,@MOTD,-si2)
  _cfgw hidesplash $iif($did(300).state,0,1)
  ; (update disp alias- eroute may have changed)
  theme.alias pnp.theme pnp.events
  return

  ; Popups - Channel
  :17
  var %pos = 1,%data
  while (%pos <= 11) {
    %data = %data $+ $did($calc(309 + %pos)).state
    inc %pos
  }
  `set popups.3 %data
  `set popups.hideop $did(321).state
  return

  ; Popups - Menubar
  :18
  var %pos = 1,%data
  while (%pos <= 10) {
    %data = %data $+ $did($calc(329 + %pos)).state
    inc %pos
  }
  `set popups.1 %data
  return

  ; Popups - Nicklist
  :19
  var %pos = 1,%data
  while (%pos <= 12) {
    %data = %data $+ $did($calc(349 + %pos)).state
    inc %pos
  }
  `set popups.4 %data
  `set popups.hideop $did(362).state
  return

  ; Popups - Query
  :20
  var %pos = 1,%data
  while (%pos <= 11) {
    %data = %data $+ $did($calc(369 + %pos)).state
    inc %pos
  }
  `set popups.2 %data
  return

  ; Popups - Status
  :21
  var %pos = 1,%data
  while (%pos <= 11) {
    %data = %data $+ $did($calc(389 + %pos)).state
    inc %pos
  }
  `set popups.5 %data
  return

  ; Popups - @Windows
  :22
  var %pos = 1,%data
  while (%pos <= 6) {
    %data = %data $+ $did($calc(409 + %pos)).state
    inc %pos
  }
  `set popups.6 %data
  return

  ; Channel options
  :24
  var %ln = $did(453).lines
  while (%ln) {
    var %chan = $did(453,%ln)
    if ($left(%chan,1) == $chr(40)) %chan = chopt
    else %chan = chopt. $+ %chan
    `set %chan $did(454,%ln)
    dec %ln
  }
  ; deleting channel(s)
  var %chanlist = $didtok($dname,453,44),%num = $hfind(pnp.config,chopt.*,0,w)
  while (%num > 0) {
    var %chan2 = $right($hfind(pnp.config,chopt.*,%num,w),-6)
    if (!$istok(%chanlist,%chan2,44)) { `set $hfind(pnp.config,chopt.*,%num,w) }
    dec %num
  }
  return

  ; DCC accept
  :25
  var %opt,%did = 50
  while (%did <= 59) {
    %opt = %opt $+ $gettok(0 3 1 2,$did(%did).sel,32)
    inc %did
  }
  `set dcc.opt %opt
  return

  ; Favorites
  :26
  ; (delete items no longer used)
  var %ini = $_cfg(config.ini)
  var %ln = $ini(%ini,favopt,0)
  while (%ln) {
    var %item = $ini(%ini,favopt,%ln)
    if (!$_scandid($dname,470,%item)) {
      _cfgxw fav %item
      _cfgxw favserv %item
      _cfgxw favopt %item
    }
    dec %ln
  }
  var %ln = $did(470).lines
  while (%ln) {
    var %sel = $did(470,%ln)
    if (%ln == 1) %sel = all
    ; Collect data
    var %chans = $gettok($did(487,%ln),2-,32)
    var %servs = $gettok($did(488,%ln),2-,32)
    var %opts = $did(489,%ln)
    ; Store where?
    if (%ln == 2) {
      ; Chans menu
      _cfgw fill.chan $gettok(%opts,1,32)
      _cfgw num.chan $iif($gettok(%opts,2,32) isnum,$ifmatch,10)
      unset %=chan.*
      var %tok = 1
      while ($gettok(%chans,%tok,32)) {
        %=chan. [ $+ [ %tok ] ] = $ifmatch
        inc %tok
      }
      if (%chans) %=chan.clr = Clear this list
    }
    else {
      ; Normal favorites
      _cfgxw fav %sel %chans
      _cfgxw favserv %sel %servs
      _cfgxw favopt %sel %opts
    }
    dec %ln
  }
  return

  ; Flashing
  :27
  var %opt,%pos = 495
  while (%pos <= 500) {
    %opt = %opt $+ $did(%pos).state
    inc %pos
  }
  `set flash.opt %opt
  if (($did(501).state) && ($did(502) isnum)) _cfgw flash.here $ifmatch
  else _cfgw flash.here 0
  if (($did(504).state) && ($did(505) isnum)) _cfgw flash.away $ifmatch
  else _cfgw flash.away 0
  return

  ; Language
  :28
  if ($readini(script\transup.ini,n,translation,enabled) == no) return
  var %flags = $iif($did(527).state,p) $+ $iif($did(528).state,l)
  var %oldflags = $iif(p isin $did(529),p) $+ $iif(l isin $did(529),l)
  if ($did(523) == $null) did -a $dname 523 $did(521)
  if (($did(521) != $did(523)) || (%flags != %oldflags)) {
    ; Translate! First find file.
    window -nhl @.trans
    var %num = $findfile(script\trans\,*.ini,@.trans)
    var %file
    while (%num) {
      var %lang = $readini($line(@.trans,%num),n,info,language)
      if (%lang == $did(523)) {
        %file = $line(@.trans,%num)
        break
      }
      dec %num
    }
    window -c @.trans
    ; File not found
    if (%file == $null) return
    if ($_okcancel(3,Applying the new translation options may take some time $+ $chr(44) during which you cannot use PnP. Continue?)) .timer -mio 1 0 translate -n $+ %flags %file
  }
  return

  ; Messages
  :29
  window -nhl @.msgs
  var %ln = $did(552).lines
  while (%ln) {
    aline @.msgs $gettok($did(552,%ln),2,32) $replace($gettok($did(552,%ln),5-,32),$chr(1),&)
    dec %ln
  }
  savebuf @.msgs " $+ $_cfg(msgs.dat) $+ "
  window -c @.msgs
  `set bracket.left $did(550)
  `set bracket.right $did(551)
  return

  ; Protection
  :30
  var %prot = 0
  if ($did(564).state) inc %prot 1
  if ($did(563).state) inc %prot 2
  if ($did(565).state) inc %prot 4
  if ($did(560).state) inc %prot 8
  if ($did(561).state) inc %prot 16
  `set myflood.prot %prot
  _cfgw verify.inv $did(581).state
  `set xchat.cfg $did(566).state $iif($did(567) isnum,$did(567),50) $iif($did(569) isnum,$did(569),5)
  _cfgw xquery.cfg $did(571).state $iif($did(572) isnum,$did(572),5) $iif($did(574) isnum,$did(574),5)
  `set xnotice.cfg $did(576).state $iif($did(577) isnum,$did(577),30) $iif($did(579) isnum,$did(579),5)
  _cfgw sptime $iif(($did(582).state) && ($did(583) isnum),$did(583),0)
  _cfgw spwarn1 $iif(($did(585).state) && ($did(586) isnum),$did(586),0)
  _cfgw spwarn2 $iif(($did(585).state) && ($did(588) isnum),$did(588),0)
  return

  ; Serverlist
  :31
  _cfgxw serverlist on $did(600).state
  var %nets,%ln = 1
  while ($did(601,%ln)) {
    %nets = %nets $ifmatch
    inc %ln
  }
  _cfgxw serverlist groups %nets
  if ($did(607)) _cfgxw serverlist last
  .timer -mio 1 0 .serverlist
  return

  ; Titlebar
  :32
  `set title.bar $did(638).state
  var %here,%away,%pos = 1
  while (%pos <= 8) {
    if (%pos == 5) %here = %here $+ 0
    else %here = %here $+ $did($calc(620 + %pos)).state
    %away = %away $+ $did($calc(629 + %pos)).state
    inc %pos
  }
  _cfgw title.here %here
  _cfgw title.away %away
  ; (update current title settings of cids)
  var %scon = $scon(0)
  while (%scon) {
    hadd pnp. $+ $scon(%scon) title $iif($hget(pnp. $+ $scon(%scon),away),%away,%here)
    dec %scon
  }
  return

  ; Other
  :33
  `set nc.char $did(651)
  `set nci.char $did(653)
  _cfgw nc.ask $did(654).state
  `set nc.cmd $did(655).state
  `set strip.auto $did(656).state
  _cfgw b.ban $did(659).state
  _cfgw recent.auto $did(662).state
  _cfgw reserve.fkey $iif($did(664).state,1,$iif($did(665).state,0,2))
  return
}

; /page.mod n [x] [y]
; Called when any item is modified or activated- sclick, edit, dclick
; Also called right after page.init
; Update any disable/enable, etc.
; [x] is true if this is being called right after init.
; [y] is true if being called manually from page.apply telling us to save any final changes.
alias -l page.mod {
  goto $1

  ; Away - Pager/Log
  :2
  did $iif($did(81).state,-e,-b) $dname 82
  did $iif($did(83).state,-e,-b) $dname 84
  return

  ; Away - Message
  :3
  did $iif($did(104).state,-e,-b) $dname 106,108
  did $iif(($did(106).state) && ($did(106).enabled),-e,-b) $dname 107
  did $iif(($did(108).state) && ($did(108).enabled),-e,-b) $dname 110
  did $iif($did(111).state,-e,-b) $dname 113
  did $iif(($did(116).state) || ($did(117).state),-e,-b) $dname 119
  did $iif($did(117).state,-e,-b) $dname 118
  did $iif(($did(119).state) && ($did(119).enabled),-e,-b) $dname 120
  return

  ; Away - Other
  :4
  did $iif($did(131).state,-e,-b) $dname 133,134,135
  did $iif($did(136).state,-e,-b) $dname 137
  return

  ; Display - Nick colors
  :7
  if (($devent == sclick) && ($did == 156)) ncedit
  return

  ; Display - Notify
  :8
  did $iif($did(176,1).sel != 4,-e,-b) $dname 165,166,167,168,169,170,172,173,174,177,178
  return

  ; Display - Ping
  :9
  did $iif(($did(191,1).sel == 3) && (!$did(196).state),-e,-b) $dname 195
  did $iif(($did(191,1).sel == 3) && (!$did(195).state),-e,-b) $dname 196
  return

  ; Display - Server notices
  :10
  ; Move?
  if ($did == 220) {
    while ($did(216,1).sel) {
      var %ln = $ifmatch
      var %text = $did(216,%ln)
      var %value = $did(217,%ln)
      did -d $dname 216 %ln
      did -d $dname 217 %ln
      did -a $dname 218 %text
      did -i $dname 219 $didwm($dname,218,%text,1) %value
    }
  }
  if ($did == 221) {
    while ($did(218,1).sel) {
      var %ln = $ifmatch
      var %text = $did(218,%ln)
      var %value = $did(219,%ln)
      did -d $dname 218 %ln
      did -d $dname 219 %ln
      did -a $dname 216 %text
      did -i $dname 217 $didwm($dname,216,%text,1) %value
    }
  }
  did $iif($did(213).state,-e,-b) $dname 216,218
  did $iif(($did(216,0).sel) && ($did(216).enabled),-e,-b) $dname 220
  did $iif(($did(218,0).sel) && ($did(218).enabled),-e,-b) $dname 221
  return

  ; Display - Text
  :11
  if (($devent == sclick) && ($did == 244)) textsch
  return

  ; Display - Wallops
  :12
  ; Move?
  if ($did == 260) {
    while ($did(256,1).sel) {
      var %ln = $ifmatch
      var %text = $did(256,%ln)
      var %value = $did(257,%ln)
      did -d $dname 256 %ln
      did -d $dname 257 %ln
      did -a $dname 258 %text
      did -i $dname 259 $didwm($dname,258,%text,1) %value
    }
  }
  if ($did == 261) {
    while ($did(258,1).sel) {
      var %ln = $ifmatch
      var %text = $did(258,%ln)
      var %value = $did(259,%ln)
      did -d $dname 258 %ln
      did -d $dname 259 %ln
      did -a $dname 256 %text
      did -i $dname 257 $didwm($dname,256,%text,1) %value
    }
  }
  did $iif($did(253).state,-e,-b) $dname 256,258
  did $iif(($did(256,0).sel) && ($did(256).enabled),-e,-b) $dname 260
  did $iif(($did(258,0).sel) && ($did(258).enabled),-e,-b) $dname 261
  return

  ; Display - Whois replies
  :13
  did $iif(($did(271,1).sel == 3) && (!$did(275).state),-e,-b) $dname 274
  did $iif(($did(271,1).sel == 3) && (!$did(274).state),-e,-b) $dname 275
  return

  ; Display - Other
  :14
  if ($devent == sclick) {
    if ($did == 295) .timer -mio 1 0 did -o $dname 295 0 $gettok(hh:nnt*hh:nntt*hh:nnT*hh:nnTT*HH:nn,$did(295).sel,42)
    if ($did == 297) .timer -mio 1 0 did -o $dname 297 0 $gettok(ddd doo mmm yyyy*mmm d $+ $chr(44) yyyy*mm/dd/yy*dd/mm/yy*mm/dd/yyyy*dd/mm/yyyy,$did(297).sel,42)
  }
  return

  ; Popups - Channel
  :17
  did $iif($did(321).state,-c,-u) $dname 362
  var %load
  if (($devent == sclick) && ($did == 326)) %load = 11111111011
  if (($devent == sclick) && ($did == 327)) %load = 01101010100
  if (%load) {
    var %pos = 1
    while (%pos <= 11) {
      did $iif($mid(%load,%pos,1),-c,-u) $dname $calc(309 + %pos)
      inc %pos
    }
  }
  return

  ; Popups - Menubar
  :18
  var %load
  if (($devent == sclick) && ($did == 346)) %load = 1111001111
  if (($devent == sclick) && ($did == 347)) %load = 1010001110
  if (%load) {
    var %pos = 1
    while (%pos <= 10) {
      did $iif($mid(%load,%pos,1),-c,-u) $dname $calc(329 + %pos)
      inc %pos
    }
  }
  return

  ; Popups - Nicklist
  :19
  did $iif($did(362).state,-c,-u) $dname 321
  var %load
  if (($devent == sclick) && ($did == 366)) %load = 001111111111
  if (($devent == sclick) && ($did == 367)) %load = 110011000110
  if (%load) {
    var %pos = 1
    while (%pos <= 12) {
      did $iif($mid(%load,%pos,1),-c,-u) $dname $calc(349 + %pos)
      inc %pos
    }
  }
  return

  ; Popups - Query
  :20
  var %load
  if (($devent == sclick) && ($did == 386)) %load = 01011111101
  if (($devent == sclick) && ($did == 387)) %load = 10101111010
  if (%load) {
    var %pos = 1
    while (%pos <= 11) {
      did $iif($mid(%load,%pos,1),-c,-u) $dname $calc(369 + %pos)
      inc %pos
    }
  }
  return

  ; Popups - Status
  :21
  var %load
  if (($devent == sclick) && ($did == 406)) %load = 11111111111
  if (($devent == sclick) && ($did == 407)) %load = 01111010100
  if (%load) {
    var %pos = 1
    while (%pos <= 11) {
      did $iif($mid(%load,%pos,1),-c,-u) $dname $calc(389 + %pos)
      inc %pos
    }
  }
  return

  ; Popups - @Windows
  :22
  var %load
  if (($devent == sclick) && ($did == 426)) %load = 111001
  if (($devent == sclick) && ($did == 427)) %load = 110100
  if (%load) {
    var %pos = 1
    while (%pos <= 6) {
      did $iif($mid(%load,%pos,1),-c,-u) $dname $calc(409 + %pos)
      inc %pos
    }
  }
  return

  ; Channel options
  :24
  ; Save current options?
  if ((($3) || (($devent == sclick) && (($did == 453) || ($did == 455)))) && ($did(457))) {
    var %opt = $did(431)
    if (%opt !isnum) %opt = 300
    %opt = %opt $mid(1236789,$did(433).sel,1)
    %opt = %opt $mid(1230,$did(435).sel,1)
    %opt = %opt $mid(254361,$did(437).sel,1)
    %opt = %opt $iif($did(442).state,1,0)
    %opt = %opt $iif($did(443).state,1,0)
    %opt = %opt $iif($did(444).state,1,0)
    %opt = %opt $iif($did(445).state,1,0)
    %opt = %opt $iif($did(446).state,1,0)
    %opt = %opt $iif($did(447).state,1,0)
    %opt = %opt $iif($did(448).state,1,0)
    %opt = %opt $iif($did(449).state,1,0)
    %opt = %opt $iif($did(450).state,1,0)
    %opt = %opt $iif($did(451).state,1,0)
    %opt = %opt $iif($did(458).state,1,0)
    did -o $dname 454 $did(457) %opt
    ; Done if just saving (page.apply)
    if ($3) return
  }
  ; Remove selected channel?
  if (($devent == sclick) && ($did == 456)) {
    var %ln = $did(453).sel
    did -d $dname 453 %ln
    did -d $dname 454 %ln
    ; (select default now)
    did -c $dname 453 $didwm($dname,453,$chr(40) $+ *,1)
  }
  ; Add new channel?
  if (($devent == sclick) && ($did == 455)) {
    var %add = $_rentry($chr(35),0,$null,Channel to add?)
    ; Exists? (select)
    if ($_scandid($dname,453,%add)) did -c $dname 453 $ifmatch
    ; Add (and select)
    else {
      did -ac $dname 453 %add
      var %ln = $_scandid($dname,453,%add)
      did -i $dname 454 %ln $hget(pnp.config,chopt)
    }
  }
  ; Load set of options?
  if (($2) || (($devent == sclick) && (($did == 453) || ($did == 455) || ($did == 456)))) {
    var %opt = $did(454,$did(453).sel)
    if (($gettok(%opt,1,32) isnum) && ($ifmatch > 0)) did -ra $dname 431 $ifmatch
    else did -ra $dname 431 300
    did -c $dname 433 $mid(123004567,$gettok(%opt,2,32),1)
    did -c $dname 435 $mid(4123,$calc($gettok(%opt,3,32) + 1),1)
    did -c $dname 437 $mid(614325,$gettok(%opt,4,32),1)
    did $iif($gettok(%opt,5,32),-c,-u) $dname 442
    did $iif($gettok(%opt,6,32),-c,-u) $dname 443
    did $iif($gettok(%opt,7,32),-c,-u) $dname 444
    did $iif($gettok(%opt,8,32),-c,-u) $dname 445
    did $iif($gettok(%opt,9,32),-c,-u) $dname 446
    did $iif($gettok(%opt,10,32),-c,-u) $dname 447
    did $iif($gettok(%opt,11,32),-c,-u) $dname 448
    did $iif($gettok(%opt,12,32),-c,-u) $dname 449
    did $iif($gettok(%opt,13,32),-c,-u) $dname 450
    did $iif($gettok(%opt,14,32),-c,-u) $dname 451
    did $iif($gettok(%opt,15,32),-c,-u) $dname 458
    did -ra $dname 457 $did(453).sel
  }
  did $iif($left($did(453).seltext,1) == $chr(40),-b,-e) $dname 456
  did $iif($did(448).state,-e,-b) $dname 449,450,451
  return

  ; DCC accept
  :25
  return

  ; Favorites
  :26
  ; Add chans/servers
  if (($devent == sclick) && ($did == 476)) {
    var %add = $gettok($did(475,0),1,32)
    if ($_scandid($dname,475,%add)) did -c $dname 475 $ifmatch
    else did -ac $dname 475 %add
  }
  if (($devent == sclick) && ($did == 481)) {
    var %add = $replace($did(480,0),$chr(44),$chr(32),:,$chr(32))
    if (($gettok(%add,2,32) !isnum) && ($gettok(%add,2,32) != $null)) %add = $gettok(%add,1,32) 6667 $gettok(%add,2-,32)
    if ($gettok(%add,3,32) isnum) %add = $gettok(%add,1-2,32)
    if ($gettok(%add,3-,32) != $null) %add = $gettok(%add,1-2,32) $_s2p($gettok(%add,3-,32))
    %add = $replace(%add,$chr(32),:)
    if ($_scandid($dname,480,%add)) did -c $dname 480 $ifmatch
    else did -ac $dname 480 %add
  }
  ; Del/Up/Down chans/servers
  if (($devent == sclick) && ($did isnum 477-479)) {
    var %del = $gettok($did(475,0),1,32)
    if ($_scandid($dname,475,%del)) {
      var %ln = $ifmatch
      did -d $dname 475 $ifmatch
      if ($did == 478) did -ic $dname 475 $iif(%ln <= 1,1,$calc(%ln - 1)) %del
      if ($did == 479) did -ic $dname 475 $iif(%ln > $did(475).lines,%ln,$calc(%ln + 1)) %del
    }
  }
  if (($devent == sclick) && ($did isnum 482-484)) {
    var %del = $replace($did(480,0),$chr(44),:,$chr(32),:)
    if ($_scandid($dname,480,%del)) {
      var %ln = $ifmatch
      did -d $dname 480 $ifmatch
      if ($did == 483) did -ic $dname 480 $iif(%ln <= 1,1,$calc(%ln - 1)) %del
      if ($did == 484) did -ic $dname 480 $iif(%ln > $did(480).lines,%ln,$calc(%ln + 1)) %del
    }
  }
  ; Add/Del networks
  if (($devent == sclick) && ($did == 471)) {
    did -ac $dname 470 $gettok($did(470,0),1,32)
    did -a $dname 487 -
    did -a $dname 488 -
    did -a $dname 489 0 0 - - -
  }
  if (($devent == sclick) && ($did == 472)) {
    var %del = $gettok($did(470,0),1,32)
    if ($_scandid($dname,470,%del)) {
      var %ln = $ifmatch
      did -d $dname 470 %ln
      did -d $dname 487 %ln
      did -d $dname 488 %ln
      did -d $dname 489 %ln
      did -c $dname 470 1
      ; (now there is no current view)
      did -r $dname 512
    }
  }
  ; Display new data if a matching item is selected/entered and it differs from the current view
  ; Also saves data, including from a mod.apply call ($3)
  if (($3) || (($_scandid($dname,470,$did(470,0))) && ($ifmatch != $did(512)))) {
    ; Remembers $3 if that's set, but then %ln is never used.
    var %ln = $ifmatch
    ; Save currently viewed data?
    if ($did(512) isnum) {
      var %chans = -
      var %servs = -
      var %pos = 1
      while ($did(475,%pos)) {
        %chans = %chans $ifmatch
        inc %pos
      }
      %pos = 1
      while ($did(480,%pos)) {
        %servs = %servs $ifmatch
        inc %pos
      }
      var %opts = $iif($did(485).state,1,0) $iif($did(486).state,1,0)
      ; (chan menu? diff option)
      if ($did(512) == 2) {
        if ($did(510) isnum 1-15) %opts = $gettok(%opts,1,32) $ifmatch
        else %otps = $gettok(%opts,1,32) 15
      }
      %opts = %opts $iif($did(463) == $null,-,$gettok($did(463),1,32))
      %opts = %opts $iif($did(465) == $null,-,$gettok($did(465),1,32))
      %opts = %opts $iif($did(467) == $null,-,$gettok($did(467),1,32))
      %opts = %opts $did(469)
      ; Save data
      did -o $dname 487 $did(512) %chans
      did -o $dname 488 $did(512) %servs
      did -o $dname 489 $did(512) %opts
    }
    ; Don't bother displaying anything if $3 true (page.apply)
    if ($3) return
    ; 1 = all, 2 = chan menu, 3+ = networks
    var %chans = $gettok($did(487,%ln),2-,32)
    var %servs = $gettok($did(488,%ln),2-,32)
    var %opts = $did(489,%ln)
    ; Load em in
    did -r $dname 475,480,463,465,467,469
    var %pos = 1
    while ($gettok(%chans,%pos,32)) {
      did -a $dname 475 $ifmatch
      inc %pos
    }
    %pos = 1
    while ($gettok(%servs,%pos,32)) {
      did -a $dname 480 $ifmatch
      inc %pos
    }
    did $iif($gettok(%opts,1,32),-c,-u) $dname 485
    did $iif($gettok(%opts,2,32),-c,-u) $dname 486
    if ($gettok(%opts,2,32) isnum 1-15) did -ra $dname 510 $ifmatch
    else did -ra $dname 510 15
    if (($gettok(%opts,3,32) != -) && ($ifmatch != $null)) did -a $dname 463 $ifmatch
    if (($gettok(%opts,4,32) != -) && ($ifmatch != $null)) did -a $dname 465 $ifmatch
    if (($gettok(%opts,5,32) != -) && ($ifmatch != $null)) did -a $dname 467 $ifmatch
    if ($gettok(%opts,6-,32) != $null) did -a $dname 469 $ifmatch
    ; Text on some of these options and/or hide some
    did -ra $dname 473 $iif(%ln == 2,&Channels menu:,&Add favorite channels:)
    did -ra $dname 485 $iif(%ln == 2,&Auto-fill menu to,&Join on connect)
    did $iif(%ln == 2,-v,-h) $dname 510
    ; (includes disable/enable the Del button)
    did $iif(%ln < 3,-b,-e) $dname 461,462,463,464,465,466,467,468,469,474,480,481,482,483,484,486,472
    ; Current line being displayed
    did -ra $dname 512 %ln
  }
  ; If entered text is not (* and differs from selected view, enable Add button
  did $iif(($left($did(470,0),1) != $chr(40)) && ($gettok($did(470,0),1,32) != $did(470,$did(512))),-e,-b) $dname 471
  ; Add/Del buttons on other two lists
  did $iif(($_scandid($dname,475,$did(475,0))) || (!$_ischan($did(475,0))),-b,-e) $dname 476
  did $iif($_scandid($dname,475,$did(475,0)),-e,-b) $dname 477,478,479
  did $iif(($_scandid($dname,480,$did(480,0))) || (. !isin $did(480,0)),-b,-e) $dname 481
  did $iif($_scandid($dname,480,$did(480,0)),-e,-b) $dname 482,483,484
  did $iif($did(485).state,-e,-b) $dname 510
  ; Set Enter to press appropriate Add button when entering text
  if ($devent == edit) {
    if ($did == 470) did -t $dname 471
    if ($did == 475) did -t $dname 476
    if ($did == 480) did -t $dname 481
  }
  return

  ; Flashing
  :27
  did $iif($did(501).state,-e,-b) $dname 502
  did $iif($did(504).state,-e,-b) $dname 505
  return

  ; Language  
  :28
  if ($readini(script\transup.ini,n,translation,enabled) == no) return
  if ((($devent == dclick) && ($did == 525)) || (($devent == sclick) && ($did == 526))) {
    did -ra $dname 523 $did(525).seltext
  }
  did $iif($did(525,0).sel == 0,-b,-e) $dname 526
  return

  ; Messages
  :29
  ; Save changes to currently selected message? (if showing a new set or new selected msg)
  if (($did(556)) && (($3) || (($devent == sclick) && (($did == 542) || ($did == 544) || ($did == 555))))) {
    ; Save to sub-list
    did -o $dname 553 $gettok($did(556),1,32) $gettok($did(553,$gettok($did(556),1,32)),1-4,32) $did(546)
    ; Save to main list
    did -o $dname 552 $gettok($did(556),2,32) $gettok($did(552,$gettok($did(556),2,32)),1-4,32) $did(546)
    ; Done if just saving (page.apply)
    if ($3) return
  }
  ; Show a different set of messages?
  if (($2) || (($devent == sclick) && (($did == 542) || ($did == 555)))) {
    var %cat = $_s2p($did(542).seltext)
    if ($left(%cat,1) == $chr(40)) %cat = &
    did -r $dname 544,553
    var %num = 1
    :loop29
    %num = $didwm($dname,552,%cat *,%num)
    if (%num) {
      var %data = $did(552,%num)
      if ($did(555).state) did -ac $dname 544 $gettok(%data,5-,32)
      else did -ac $dname 544 $_p2s($gettok(%data,3,32))
      ; (store actual data on each msg in other list, including line in original list to save it to)
      ; (line, codename, longname, params, current setting)
      did -i $dname 553 $did(544).sel %num $gettok(%data,2-,32)
      inc %num
      goto loop29
    }
    did -c $dname 544 1
    did -z $dname 544
  }
  ; Show data for a new selected message?
  if (($2) || (($devent == sclick) && (($did == 542) || ($did == 544) || ($did == 555)))) {
    var %data = $did(553,$did(544).sel)
    did -ra $dname 554 $_p2s($gettok(%data,3,32))
    did -r $dname 546
    did -o $dname 546 0 $replace($gettok(%data,5-,32),$chr(1),&)
    ; Fill with defaults
    var %defs = $read(script\msgdefs.dat,nw,& $gettok(%data,2,32) *)
    %defs = $gettok(%defs,5-,32)
    var %pos = 1
    while ($gettok(%defs,%pos,32)) {
      did -a $dname 546 $_p2s($gettok($ifmatch,-1,124))
      inc %pos
    }
    ; Add 'random' line
    did -a $dname 546
    did -a $dname 546 (random line from text file...)
    ; Remember which lines we're editing
    did -ra $dname 556 $did(544).sel $gettok(%data,1,32)
  }
  ; Load a newly selected default?
  if (($devent == sclick) && ($did == 546)) {
    ; Blank line? revert
    if (($did(546).sel == $null) || ($did(546).sel == $calc($did(546).lines - 1))) msgview.fix $_s2p($did(557))
    ; Random?
    elseif ($did(546).sel == $did(546).lines) {
      _ssplay Question
      var %file = $sfile($mircdir $+ \*.txt,File to take random replies from?)
      if (%file) msgview.fix !Random: $+ %file
      ; (no file- revert)
      else msgview.fix $_s2p($did(557))
    }
    else {
      var %data = $did(553,$did(544).sel)
      var %defs = $read(script\msgdefs.dat,nw,& $gettok(%data,2,32) *)
      var %text = $gettok($gettok(%defs,$calc(4 + $did(546).sel),32),1,124)
      msgview.fix %text
    }
  }
  ; Show preview of current message? (longer wait for typing)
  if ($2) {
    ; Save most recent edit in 557
    did -ra $dname 557 $did(546)
    msgprev.update
  }
  elseif ((($devent == sclick) && (($did == 542) || ($did == 544) || ($did == 546) || ($did == 555))) || ($devent == edit)) {
    ; Save most recent edit in 557 (anytime except when selecting a default)
    if (($did != 546) || ($devent != sclick)) did -ra $dname 557 $did(546)
    .timer.config.msgpreview -mio 1 $iif($devent == edit,1500,500) msgprev.update
  }
  return

  ; Protection
  :30
  if (($devent == sclick) && ($did == 562)) ctcpedit
  did $iif(($did(563).state) || ($did(564).state),-e,-b) $dname 565
  did $iif($did(566).state,-e,-b) $dname 567,569
  did $iif($did(571).state,-e,-b) $dname 572,574
  did $iif($did(576).state,-e,-b) $dname 577,579
  did $iif($did(582).state,-e,-b) $dname 583
  did $iif($did(585).state,-e,-b) $dname 586,588
  return

  ; Serverlist
  :31
  did $iif($did(600).state,-e,-b) $dname 601
  ; Refresh button
  if (($devent == sclick) && ($did == 606)) {
    did -ra $dname 607 1
    did -v $dname 608
  }
  ; Add/del
  if (($devent == sclick) && ($did == 602)) {
    did -ac $dname 601 $gettok($did(601),1,32)
  }
  if (($devent == sclick) && ($did == 603)) {
    var %item = $gettok($did(601),1,32)
    did -d $dname 601 $_scandid($dname,601,%item)
    did -o $dname 601 0 %item
  }
  ; Enter = add button
  if (($devent == edit) && ($did == 601)) did -t $dname 602
  did $iif((!$_scandid($dname,601,$gettok($did(601),1,32))) && ($did(601) != $null) && ($did(600).state),-e,-b) $dname 602
  did $iif(($_scandid($dname,601,$gettok($did(601),1,32))) && ($did(601) != $null) && ($did(600).state),-e,-b) $dname 603
  did $iif((!$did(607)) && ($did(600).state),-e,-b) $dname 606
  return

  ; Titlebar
  :32
  did $iif($did(638).state,-e,-b) $dname 621,622,623,624,625,626,627,628,630,631,632,633,634,635,636,637
  return

  ; Other
  :33
  did $iif(($did(655).state) || ($did(651) != $null) || ($did(653) != $null),-e,-b) $dname 654
  return
}

; Corrects message view to $_p2s($1) using a timer
alias -l msgview.fix { .timer.msgview.fix -mio 1 0 msgview.fix2  $+ $1 }
alias -l msgview.fix2 { did -o pnp.config 546 0 $replace($_p2s($1),$chr(1),&) | did -ra pnp.config 557 $did(pnp.config,546) }

; Update message preview
alias -l msgprev.update {
  if ($dialog(pnp.config) == $null) return
  .timer.msgview.fix -e
  var %torep = $gettok($did(pnp.config,553,$did(pnp.config,544).sel),4,32)
  var %text = $replace($did(pnp.config,546),$chr(1),&)
  if (!Random:* iswm %text) %text = $read($gettok(%text,2-,58),n,1)
  ; Color, Replace codes
  var %dispcol = $gettok(%torep,1,44)
  %text = $msg.compile(%text,&test&,1,&[&,$did(pnp.config,550),&]&,$did(pnp.config,551), [ $+ [ $gettok(%torep,2-,44) ] ] )
  drawrect -f @.msgprev $color(back) 1 0 0 340 22
  if (%text != $null) drawtext -pb @.msgprev $color(%dispcol) $color(back) " $+ $window(Status Window).font $+ " $window(Status Window).fontsize 3 1 $iif(%dispcol == act,* $me) %text
  drawsave @.msgprev script\temp\msgprev.bmp
  did -g pnp.config 548 script\temp\msgprev.bmp
}

