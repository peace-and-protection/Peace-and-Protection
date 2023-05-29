; #= P&P.temp -rs
; @======================================:
; |  Peace and Protection                |
; |  Translation loading routines        |
; `======================================'

;
; This internal alias actually handles the translation
; It is called alone and from it's own file to minimize any conflicts
;

alias _dotranslate {
  ; Timer to unload everything, in case of errors
  .timer -om 1 0 hfree -w pnp.trans.* $chr(124) close -@ @.trans @.ptm @.ptmsource $chr(124) _unload translate

  ; Verify file
  if (!$isfile($2-)) _error File ' $+ $2- $+ ' not foundPlease specify the name of an existing translation file
  var %language = $readini($2-,n,info,language)
  if (!%language) _error File ' $+ $2- $+ ' not a valid translation filePlease specify the name of an existing translation file

  ; Verify PTM files
  window -hnl @.ptm
  var %total = $findfile(script\ptm,*.ptm,0,@.ptm) + 1
  if (!%total) {
    window -c @.ptm
    _error No source files to translatePlease reinstall your copy of PnP
  }

  ; Progress meter now
  var %process = $readini($2-,n,process,loading)
  if (%process == $null) %process = Loading '<lang>' translation...
  %process = $replace(%process,<lang>,%language)
  _progress.1 %process

  ; Load file into window and transfer to hashes
  window -nhl @.trans
  filter -fwx " $+ $2- $+ " @.trans ;*
  var %line = 1,%last = $line(@.trans,0),%cat,%prog = 0
  inc %total $int($calc(%last / 100))

  while (%line <= %last) {
    if ($calc(%line % 100) == 0) {
      inc %prog
      _progress.2 $int($calc(%prog / %total * 100)) %process
    }
    var %data = $line(@.trans,%line)
    if ([*] iswm %data) {
      %cat = $mid(%data,2,$calc($len(%data) - 2))
      hmake pnp.trans. $+ %cat 20
      if (%cat == process) {
        ; Default strings for translation process
        hadd pnp.trans.process loading Loading '<lang>' translation...
        hadd pnp.trans.process translating Translating '<file>'...
        hadd pnp.trans.process missing Item '<item>' not found in translation file
        hadd pnp.trans.process complete Translation complete!
        hadd pnp.trans.process loaded Loaded '<lang>' translation
        hadd pnp.trans.process errors <num> translation error(s) encountered.|See status window for details.
      }
    }
    elseif ((= isin %data) && (%cat)) hadd pnp.trans. $+ %cat $gettok(%data,1,61) $gettok(%data,2-,61)
    inc %line
  }
  window -c @.trans

  ; Determine if we are updating everything or based on timestamp
  var %ts = $readini(script\transup.ini,n,translation,timestamp)
  ; If forced, diff options, never updated, new language, or language file was updated, update everything
  if ((%ts !isnum) || (f isin $1)) %ts = 0
  elseif ($readini(script\transup.ini,n,translation,language) != %language) %ts = 0
  elseif ($remove($readini(script\transup.ini,n,translation,transopt),-,f,n) != $remove($1,-,f,n)) %ts = 0
  elseif ($file($2-).mtime >= %ts) %ts = 0
  ; Otherwise, only update ptms with timestamps greater than %ts

  ; Loop through all .ptm files (pre-translation mIRC) in script\ptm
  ; Each file is translated only if it's destination directory exists, and only reloaded if currently loaded
  ; Files are only translated if the last line of the file contains a timestamp before the current ptm timestamp
  ; OR if the current translation.ini has changed OR a new translation is being loaded
  ; No file without an associated .ptm file is touched
  saveini
  var %error = 0

  ; Do each file
  while ($line(@.ptm,1)) {
    var %file = $ifmatch
    _progress.2 $int($calc(%prog / %total * 100)) $replace($hget(pnp.trans.process,translating),<file>,$nopath(%file))
    ; Do only if PTM timestamp is greater than %ts
    if ($file(%file).mtime < %ts) goto skip
    ; Load file into window
    window -hnl @.ptmsource
    loadbuf -r @.ptmsource " $+ %file $+ "
    ; Determine where this file goes
    var %dest = $_truename.fn($line(@.ptmsource,1))
    dline @.ptmsource 1
    ; Determine if the target directory exists
    if ($isdir($nofile(%dest))) {

      ; Loop through file, replacing translation data
      var %line = $line(@.ptmsource,0)
      while (%line >= 1) {

        var %text = $line(@.ptmsource,%line)

        var %orig = %text
        ; Scan for translation replacements of the form [section:item]
        ; Disallow |[]{} chars in these items
        ; Form [section:item:var=data] will replace <var> in the translation text also, data has ; changed to :
        ; Form [section:item:lower] will convert inital caps to lowercase (IE "From DCC" becomes "from DCC")
        ; Form [section:item:s2p] will convert spaces to ctrlbksp
        ; Form [section:item:dlg] will not use any $+ $chr etc (dialog format- default for dialog_blah items)
        ; Form [section:item:notdlg] will use $+ $chr etc (default for non dialog_blah items)
        ; Form [section:item:popups] will denote a popups item, for lowercase conversion if option is selected (def for popups_* items)
        ; Form [section:item:public] will convert unreplaced <item>s to &item& (default for public_blah items)
        var %num = $regex(ptm,%text,/(\[[^|\[\]\{\} ]+:[^|\[\]\{\}]+\])/g),%old
        ; Replace each instance of [sec:item]
        if (%num >= 1) {
          while (%num >= 1) {
            %old = $regml(ptm,%num)
            var %data = $mid(%old,2,-1)
            ; Determine new text
            var %text2 = $hget(pnp.trans. $+ $gettok(%data,1,58),$gettok(%data,2,58))
            ;!! unused check code
            if (%unused) hdel UNUSED $gettok(%data,1-2,58)
            ; Verify it exists- if not, read from english and count errors
            if (%text2 == $null) {
              inc %error
              disps $replace($hget(pnp.trans.process,missing),<item>,$gettok(%data,1-2,58))
              %text2 = $readini(script\trans\english.ini,n,$gettok(%data,1,58),$gettok(%data,2,58))
            }
            ; Replace | with  (multilines, errors, etc)
            %text2 = $replace(%text2,|,)
            ; Lowercase?
            if ($istok(%data,lower,58)) %text2 = $lower(%text2)
            ; l or p options
            if (l isin $1) %text2 = $lower(%text2)
            elseif ((p isin $1) && (popups* iswm $gettok(%data,1,58))) %text2 = $lower(%text2)
            ; s2p?
            if ($istok(%data,s2p,58)) %text2 = $replace(%text2,$chr(32),)
            ; Replace any <var>s in text or any metacharacters, including comma, parens
            var %orig2 = %text2
            var %num2 = $regex(ptm2,%text2,/(<[-_.a-zA-Z0-9]+>|[%#{|}\[\]$,()])/g),%old2,%left2,%right2
            ; Replace each instance of <var>
            while (%num2 >= 1) {
              %old2 = $regml(ptm2,%num2)
              %left2 = $left(%orig2,$regml(ptm2,%num2).pos)
              %right2 = $mid(%text2,$calc($regml(ptm2,%num2).pos + $len(%old2)))
              ; Do we need $+ on either side?
              if (($len(%left2) != 1) && ($asc($right(%left2,2)) != 32)) %left2 = $left(%left2,-1) $!+<
              if ((%right2 != $null) && ($asc(%right2) != 32)) %right2 = $!+ %right2
              ; Replace
              if ($len(%old2) == 1) %text2 = $left(%left2,-1) $!chr( $+ $asc(%old2) $+ ) %right2
              else {
                ; Grab value from translation tokens- find token matching name=* and retrieve value
                ; Retrieved value replace ; with :
                ; Make NO change if token not found
                if ($gettok($wildtok(%data,$mid(%old2,2,-1) $+ =*,1,58),2-,61) != $null) %old2 = $replace($ifmatch,;,:)
                ; Public? Since not found, convert to &var&
                elseif (($istok(%data,public,58)) || (public_* iswm $gettok(%data,1,58))) %old2 = $replace(%old2,<,&,>,&)
                %text2 = $left(%left2,-1) %old2 %right2
              }
              dec %num2
            }
            ; Dialog or non-dialog replacement method?
            var %dlg = $iif(*dialog iswm $gettok(%data,1,58),1,0)
            if ($istok(%data,dlg,58)) %dlg = 1
            if ($istok(%data,notdlg,58)) %dlg = 0
            if (%dlg) %text2 = $eval(%text2,2)
            ; Replace [sec:item] with modified translation
            %text = $+($left(%orig,$calc($regml(ptm,%num).pos - 1)),%text2,$mid(%text,$calc($regml(ptm,%num).pos + $len(%old))))
            dec %num
          }
          rline @.ptmsource %line %text
        }

        dec %line
      }

      ; Save file
      savebuf @.ptmsource " $+ %dest $+ "
      ; Reload script, if appropriate
      if ($script(%dest)) .reload -rs " $+ %dest $+ "
      if ($alias(%dest)) .reload -a " $+ %dest $+ "
    }
    ; Next file
    :skip
    dline @.ptm 1
    inc %prog
  }

  ; Save current translation details
  writeini script\transup.ini translation language %language
  writeini script\transup.ini translation timestamp $ctime
  writeini script\transup.ini translation transopt - $+ $remove($1,-,f,n)

  ; Update scripts as needed
  _progress.2 $int($calc(%prog / %total * 100)) $replace($hget(pnp.trans.process,loading),<lang>,%language)
  .signal -n PNP.TRANSLATE %language

  ; All files translated and reloaded as needed
  if (%error) %error = $replace($hget(pnp.trans.process,errors),|,,<num>,%error)
  _progress.2 100 $hget(pnp.trans.process,complete)
  disps $replace($hget(pnp.trans.process,loaded),<lang>,%language)
  if (%error) _error %error
}

