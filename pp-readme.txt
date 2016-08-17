
PnP 4.22.7
mIRC 7.46


This script *requires* and is designed for mIRC v7.46 or later, not included.
Using an earlier version of mIRC will not work. Please see:

http://www.kristshell.net/pnp/ 
or
https://github.com/solbu/Peace-and-Protection

for updates and other PnP-related information.

See pp-faq.txt for frequently asked questions and known issues with
other software.

--- WHAT IS PnP? ---

PnP is designed to be a good choice for anyone looking for a mIRC
script. All of it's features are highly configurable, so you don't
need to settle for what someone else thinks is best. Most features
work quietly in the background- and those that don't can be turned
off. You can keep yourself and your channels safe, and have a much
nicer overall IRC experience.

PnP doesn't have the sleek, fancy look that some scripts have-
instead, all development time goes into making useful, flexible,
and powerful features. Browse through configuration and the popups
for just a glimpse of the many features available... or just run it
with the default configuration and learn as you go.

Have a bug report, problem, or feedback? Our forum is:
http://www.kristshell.net/pnp/forum/
Also, issues can be raised over at:
https://github.com/solbu/Peace-and-Protection/issues

--- WHAT'S NEW? ---

4.22 includes a new Spam Blocker addon that allows you to selectively
block unwanted spam and queries, options to show raw/revents to
active and cycle channels when alone and opless, and a new
Configuration Wizard for first-time users or for easy configuration
of common options. Select PnP -> Configure -> Configuration Wizard
to run it at any time. (It will automatically run the first time
you install PnP)

A few more theme variations have also been included- Nothing
spectacular, just some more basic options to choose from.

A lot of bugs have also been fixed from 4.20 and 4.21. Everything
seems to be fairly stable at this point- I think the majority of
the bugs from the mIRC 6.01 changes and multi-server revamps have
been fixed. As always, let us know if you find anything.

If you missed 4.20, then you're in for a treat. Since 4.06, a LOT of
major changes have been made. PnP is now fully mIRC 6.01 compatible.
Everything is multi-server aware and compliant. Favorites can now
include networks/servers to connect to on startup. The theming system
has been replaced with a sleek, MTS-compatible system, all in one
dialog. (/theme) All of the smaller configuration dialogs are now part
of a single, revamped, easy-to-use dialog. (/config) PnP fully
supports Halfops and odd channel prefixes, such as !chans. Many more
new features include new away options, sound addon improvements,
/viewpic, expanded topic popups, etc. 

See WHATSNEW.TXT for a full list of changes, additions, and the
ever-present bug fixes.

--- WHAT'S COMING? ---

So far the only translation available is Turkish. If you are fluent
in a language other than English and wish to help translate, please  
see Script\Trans\English.ini for details on translating PnP.

--- IF THIS IS A NEW INSTALLATION ---

1) mIRC installs itself in the %programfiles% folder or the 
   %systemdrive%\Program Files (x86) folder if you are running
   a 64 bit version of windows.
2) Unzip the contents of the ZIP file and copy everything (the ADDONS,
   SCRIPT, THEMES folders including the files kicks.txt, pp-faq.txt
   pp-readme.txt, quits.txt and whatsnew.txt) to your 
   %appdata%\mIRC folder.
3) Turn off script confirmation warning. In Options>Other>Confirm...
   Uncheck "Confirm when using a command that may run a script."
4) In your status window, type /load -rs script\first.mrc
   (and press Enter)
5) Any time mIRC asks if you'd like to run initialization
   commands, click "Yes".
6) mIRC will restart once or twice while installing PnP.
   Then you are ready to go!
   
If mIRC crashes any time during this installation, you should
be able to start it and PnP will pick up where it left off.
You will not lose any of your mIRC settings when you install
PnP.

--- TO UNINSTALL PnP ---

Simply delete the SCRIPT and ADDONS directories and everything
in them. Do not do this while mIRC is running. You may also safely
delete the CONFIG directory, if you don't want to save your
configuration for later. (this won't affect your mIRC settings.)

--- IF YOU HAVE PROBLEMS ---

Most importantly-
DO NOT ADD YOUR OWN SCRIPTS/EVENTS TO PNP'S SCRIPT FILES. If you want to
add stuff, go to File->New or File->Load to create your own script file.
If you add your own stuff to PnP's files, it can very easily cause problems.

For a detailed list of changes, see WHATSNEW.TXT. For answers
to common questions, see PP-FAQ.TXT.

Feel free to visit #peace&protection on EFnet for help and questions.

Bug reporting and feedback features are not working currently.
Please raise your issue on the kristhshell forum or @ GitHub.


--- A brief list of some commands ---

/aidle (extras)
/ezping (extras)
/colorwin (extras)
/ns [on|off] (nickserv)
/kickstat [on|off|quiet|clear|nickname]
/defld
/atopic
/rtopic
/about
/bug
/feedback
/strict [#chan]
/count [#chan]
/black [-r|*|#chan] nick|addr [=nick] [reason]
/blackedit
/repjoin
/protedit [#chan]
/prot
/config
/unban [-s] nick|addr
/serverlist [+|- network] ...
/theme
  /fontfix
  /nickcol [on|off]
  /nickcol edit
  /display
  /linesep
  /msgs
  /sounds
  /text [file.ext|on|off|mirc]
  /text edit
  /text cfg
/fav [params]
/tome
/addon
/clones [#chan] [mask]
/scan [#chan] [flags]
/notif [nick]
/ign [[-r] nick|addr]
/userlist [#chan|*]
/user [-r|-v] nick|addr [editing stuff...]
/x command (x on undernet)
/cs [on|off] (chanserv)
/away
/back
/awaylog
/pager
/awaycfg
/fontfix
/umode
/profile
/authlist
/auth
/scfg (sound)
/sopt (sound)
/playlist (sound)
/loc (sound)
/squeue (sound)
/spanel (sound)
/scont (sound)
/inv [#chan] [nick]
/rec [v]
/viewpic
/mtn
/ame/amsg/aame/aamsg/acme/acmsg
/rn/urn (extras)
/lagbar (extras)
/saycolor/showcolor (extras)
/rlm/slm/rln/sln (extras)
/country/usa (extras)
/xdcc (xdcc)
/login (porttools)
/nukes (porttools)
/arp (porttools)
/rr/rrset/rropt (rerouting)
/op/fop/dop/deop/fdop/fdeop/kick/ban/unban/hfop/dhfop (etc)
/onotice/ovnotice/o/ov/wall/allbut/fnotice/peon/rnotice/nnotice
/+o/-o/+b (etc- any modes work)


--- All commands alphetical order (no syntax yet, sorry) ---

/+
/-
/a
/aame
/aamsg
/about
/acme
/acmsg
/action
/addon
/addons
/aidle
/allbut
/ame
/amsg
/arp
/atopic
/auth
/authedit
/authlist
/autoaway
/avglag
/away
/awaycfg
/awaylog
/b
/back
/ban
/banlast
/bans
/bc
/bk
/bk0
/bk2
/black
/blackedit
/blacklist
/bug
/c
/cb
/cfg
/chaninfo
/chat
/chopt
/cinfo
/clearstat
/clientinfo
/clones
/clrseen
/colorwin
/config
/count
/country
/cs
/csa
/ctcp
/ctcpedit
/ctcpreply
/cycle
/date
/dcc
/dcp
/ddeoff
/ddeon
/defld
/dehalfop
/dehfop
/dellog
/deop
/describe
/devoc
/devoice
/dhfop
/display
/dns
/donate
/dop
/dvoc
/edit
/english
/etopic
/ew
/ezping
/fav
/fdehfop
/fdeop
/fdevoc
/fdhfop
/fdop
/fdvoc
/feedback
/fhfop
/fing
/fk
/fknop
/fnotice
/fontfix
/fop
/funop
/fvoc
/halfop
/hfop
/hide
/hop
/host
/ign
/inv
/invite
/j
/join
/jp
/k
/kb
/kb0
/kb2
/kick
/kickstat
/lagbar
/lastseen
/leave
/line
/loc
/login
/ltopic
/me
/mid
/midi
/mode
/motd
/mp
/mp2
/mp3
/msg
/msgs
/mtn
/myver
/n
/names
/ncedit
/nearserv
/nick
/nickcol
/nnotice
/notice
/notif
/ns
/ntc
/nukes
/o
/ogg
/oh
/ohnotice
/onotice
/op
/opme
/otopic
/ov
/ovnotice
/p
/page
/pager
/part
/peon
/picview
/ping
/pj
/playlist
/pnp
/popups
/ports
/profile
/prot
/protedit
/ps
/pwin
/q
/qa
/qb
/query
/quit
/reban
/rec
/reindex
/rejoin
/repjoin
/rlm
/rln
/rn
/rnotice
/route
/rr
/rrkeep
/rropt
/rrset
/rtopic
/s
/say
/saycolor
/sayseen
/scan
/scfg
/scont
/script
/seen
/send
/server
/serverlist
/service
/showcolor
/slm
/sln
/sopt
/sound
/soundcfg
/sp
/spanel
/spawn
/sping
/squeue
/sseen
/starg
/stats
/stopic
/strict
/stype
/tempban
/text
/textopt
/textsch
/theme
/time
/tome
/topic
/translate
/uinfo
/umode
/unban
/unhide
/unop
/urn
/usa
/user
/useredit
/userhost
/userinfo
/userlist
/utopic
/ver
/verping
/version
/viewlog
/viewpic
/voc
/voice
/vping
/w
/wall
/wav
/wave
/who
/whois
/whowas
/wma
/ww
/x
/xdcc
/xw
/xwa
/z
