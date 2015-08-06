
PnP 4.22.3
mIRC 6.16


This script *requires* and is designed for mIRC v6.16 or later, not included.
Using an earlire version of mIRC will not work. Please see
http://www.kristshell.net/pnp/ for updates and other PnP-related information.

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

Have a bug report, problem, or feedback? Just type /bug, hit Enter,
and send it off!

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
been fixed. As always, let me know if you find anything.

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

Expect to see an updated addons page on www.pairc.com soon.
I'm also working on automated upgrade/patch support within the script
itself. I've also started on writing documentation- it's coming
slowly, but something should be ready for the next major version.

At some point I will be making the userlist and more of the options
network-specific, but this may be a while.

A number of hard-working individuals are working on translations for
PnP- look for these on www.pairc.com sometime in the near future. 
(see Script\Trans\English.ini for details on translating PnP.)

--- TO UPGRADE AN EXISTING INSTALLATION OF PnP ---

If you don't have mIRC 6.01 installed yet, download it
from http://www.mirc.com/get.html. Install it over your
existing PnP/mIRC. When prompted, elect to *keep* existing
settings. Note that PnP 4.22 will *not* work with mIRC
versions prior to 6.01.

Then, just unzip (or copy) all of the PnP files to your existing PnP
directory. Make sure you retain the directories, and overwrite
any existing files. In WinZip, this option is called "Use folder
names". Make sure mIRC is NOT RUNNING when you do this. mIRC may
restart once or twice the first time you run it, to clean up any
new settings.

When upgraded properly, you will not lose any of your existing
settings. Do not install this over a copy of PnP earlier than
4.00.

--- IF THIS IS A NEW INSTALLATION ---

1) Make sure no copies of mIRC are running. This is simply a
   safety precaution- PnP only installs to the mIRC directory
   you place it in.
2) If you like, make a backup of your mIRC directory.
3) If you don't have mIRC 6.01 installed yet, download it
   from http://www.mirc.com/get.html and install it. Note that
   PnP 4.22 will *not* work with mIRC versions prior to 6.01.
4) Unzip or copy all files into your mIRC directory.
     There are two ways to locate the mIRC folder
       1. Logokey + R (or Start -> Run) and type: %APPDATA%\mIRC
       2. Inside mIRC, type: //run $mircdir
   Retain all directories. In WinZip, this option is called
   "Use folder names". You should now have SCRIPT, ADDONS, and
   THEMES directories within your MIRC directory. If you do not,
   you did something wrong.
5) You should now have all of the above directories, as well
   as mirc.exe in the directory. You will also have other mIRC
   files such as mirc.ini and servers.ini- this is normal and
   not a problem.
6) Start mIRC.
7) In your status window, type /load -rs script\first.mrc
   (and press Enter)
8) Anytime mIRC asks if you'd like to run initialization
   commands, click "Yes".
9) mIRC will restart once or twice while installing PnP.
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

Bug reporting and feedback features have been enabled. Use
/bug to report a bug or /feedback to leave feedback. However,
don't expect replies to every report or e-mail. I don't
mean to be rude- I simply do not have the time to reply to each
individual e-mail. If you have a legitimate question or problem,
I will try to send a response.

IMPORTANT NOTE: Although I try to make this as bug free and usable
as possible, there will definately be bugs, and some features
aren't complete, or are undocumented.


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
