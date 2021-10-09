NB. This implements something like the 'world' concept by Allesandro Warth
NB. (used in his OMeta system).
NB.
NB. A world is just a locale (chained namespace), but when a line of code is executed
NB. through the 'exec' function, /and/ that line contains an assignment, then a new
NB. world is created on the fly to hold the results of the assignment.
NB.
NB. The result is that you can 'time travel' back and forth between states.
NB.
NB. Limitations:
NB.  - does not track global assignments that happen inside verbs
NB.  - assigmnents using locatives operate independently of the 'timeline'
NB.
NB. Basically, this is just enough magic to power my presentation tool and probably
NB. should not be used for anything else without careful consideration.

cocurrent 'world'
require 'tok.ijs' NB. for colorization

init =: {{
  ii =: 0       NB. world counter
  ihist =: ''   NB. input history
  ehist =: ''   NB. echo history
  coerase (#~ #@('WORLD\d+'&rxmatches)&>) conl''
  EHISTL0_WORLD0_=: EHISTL1_WORLD0_=: ii_world_=:0 }}

NB. m in_world_ : name builder: append locative for current world to m
in =: {{ m,'_',(this_world_''),'_' }}

lines =: {{
 if. 1 = # $ y do. y =. ,:y end.
 ,(LF cut CR -.~ ])"1 y }}

boxc =: ,(,.<"0 a.{~ 16+i.11),.(8 u: dfh) each cut'250c 252c 2510 251c 253c 2524 2514 2534 2518 2502 2500'
boxe =: {{ y rplc"1 boxc }}
echo =: {{
  for_line. lines boxe y do. ehist =: ehist,line end.
  ('EHISTL1'in_world_) =: #ehist }}

this =: {{ 'WORLD',":ii_world_ }}
next =: {{
  ni =. ii_world_ + 1
  cocurrent nw =. 'WORLD',":ni
  coinsert this_world_''
  if. EHISTL1 ~: EHISTL0 do. EHISTL0 =: EHISTL1 end.
  ii_world_ =: ni
  this_world_'' }}

NB. nesting depth of tokens
depth =: {{ +/\ 1 _1 0 {~ ('{{';'}}')&i. L:1 y }}

exec =: {{ NB. run code in the current 'world'
  NB. you get a domain error if you try to perform (".'y=:1')
  NB. inside a verb, because it conflicts with the locally defined 'y'.
  NB. (In fact, this is true for any locally defined name, hence the
  NB. 'exec' prefix on all the locals here.)
  NB. so.. we will rewrite 'x','y', etc to ('y'in_world_)...
  NB. BUT we do NOT want to do this inside a direct definition, so
  NB. we use 'depth' as a mask.
  ihist =: ihist,<y
  try.
    exec_mut =. ('=:';'=.')&(+./@e.) exec_toks =. ;: y
    exec_toks =.  ]`('=:'"_)@.('=.'&-:)L:0 exec_toks
    cocurrent next_world_''
    NB. 'echo' colorized entry
    ehlen =. # ehist_world_
    echo_world_ '    ',y
    ehist_world_ =: (<'   ',vtcolor_tok_ y) ehlen } ehist_world_
    if. #y do. NB. skip if input is blank: e.&.. gives a 0 here, but depth ='' (so length error)
      for_execslot. I. ((0=depth_world_) *. e.&(,.'xymnuv')S:0) exec_toks do.
        exec_fix =. <(>execslot{exec_toks),'_',(this_world_''),'_'
        exec_toks =. exec_fix execslot } exec_toks
      end.
    end.
    if. # exec_toks do. exec_toks =. exec_toks #~ -. 'NB.' {.@E. S:0 exec_toks end.
    exec_str =. ' ' joinstring exec_toks
    if. # exec_str -. ' ' do.
      (<'do'in_world_)`:0 'JRESULT=:', exec_str
      if. (type 'JRESULT'in_world_) -: <'noun' do. exec_res =. ": 'JRESULT'in_world_~
      else. exec_res =. 5!:5 <'JRESULT'in_world_ end.
      if. (*# exec_res) > '=:'-:>1{exec_toks,a:,a: do. echo_world_ exec_res end.
    end.
  catch.
    echo_world_ dberm''
  end. }}
