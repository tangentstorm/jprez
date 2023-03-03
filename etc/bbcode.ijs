NB. example script for converting jprez syntax highlighting
NB. to bbcode markup.

load 'tangentstorm/j-lex'
load 'tok.ijs'  NB. run from ..
coinsert 'tok'
line =: 0 : 0
(16b221111*i.8) viewmat |:+/2<|(+*:)^:(<9)~_1+j./~ 0.01*i:175 [ load'viewmat'
)

bbcolor =: {{  NB. colorize a line of j using vt escape codes
  res =. ''
  for_tt. {.>{.> jlex y do.
    if. -.*#tt do. continue. end.
    res =. res,('[color=#',(hfd jcolor tt),']'),'[/color]',~,(>}.tt)
  end. res }}


'bbcode' fwrites~ bbcolor line
echo 'look in file: "bbcode"'
exit''
