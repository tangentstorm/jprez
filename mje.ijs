NB. minimal j editor
NB.
NB. This file my attempt to port my presentation tool
NB. over to my new console-based libraries, token editor
NB. components, etc. It is something of a scratchpad and
NB. not well organized at the moment, but important enough
NB. that I should probably have it under version control.
(<'z') copath 'base' NB. clear previous path
load'tangentstorm/j-kvm tangentstorm/j-kvm/ui tangentstorm/j-lex'
load'worlds.ijs org.ijs tok.ijs repl.ijs'
coinsert 'kvm'

copush =: {{ 18!:4 y [ BASE__y =: coname'' [ y=.<y }}
copop_z_ =: {{ y [ 18!:4 BASE [ y=.coname'' }}

NB. main code
ORG_PATH =: './screenplay.org'


NB. org-mode stuff

open =: {{
  emit_vm_ =: ] NB. so j-kvm/vm outputs string we can capture (vs puts)
  org_slides ORG_PATH  NB. defines title =: ... and  slides =: ...
  NB. heads is the indented outline that shows up on the left
  heads =: <@;"1((' '#~+:@<:) each 3 {"1 slides),.(0{"1 slides)
  NB. (index I. (C__line, C__cmd) { olw) says which world we are in
  index =: 0 0 $ 0  NB. one entry per line that starts with : (slide,line no)
  olw =: ,<'WORLD0' NB. outline worlds. 'now'=HISTL0/HISTL1 in (i{olw)
  init_world_''
  for_slide. slides do. i =. slide_index
    for_line. text i do. j =. line_index
      if. -. line = a: do.
        line =. > line
        if. ': ' {.@E. line do. line =. 2}.line     NB. : marks code line
          if. '. ' {.@E. line do. line =. 2}.line   NB. : . is editor macro
            NB. TODO : execute macro
          else.
            NB. execute and colorize input
            ehlen =. #ehist_world_     NB. length of the history
            exec_world_ line           NB. execute code in repl
            ehist_world_ =: (<'   ',vtcolor_tok_ line) ehlen } ehist_world_
          end.
          index =: index, i,j
          olw =: olw,<this_world_''
        end.
      end.
    end.
  end.
  emit_vm_ =: emit0_vm_ NB. restore j-kvm/vm
  0 0$0}}

open''  NB. TODO: move to bottom
NB. rkey'' [ echo<'done loading j-talk. press enter.'

NB. --  screen setup ---------------------------------------------------
H_HIST =: 24
X_HIST =: 72
W_HIST =: X_HIST -~ xmax''
Y_META =: H_HIST+2

NB. indent headings based on depth
list =: 'UiList' conew~ heads
H__list =: (ymax'')-Y_META
XY__list =: 0,Y_META

NB. the detailed text of the screenplay (also macro commands)
cmds =: 'UiList' conew~ a:
W__cmds =: (xmax'')-32
H__cmds =: 32
XY__cmds =: 33 0 + XY__list

NB. led is the line editor for editing a line of text in the outline
led =: 'UiEditWidget' conew~ ''
XY__led =: XY__cmds
W__led =: W__cmds
V__led =: 0

repl =: 'UiRepl' conew~ ''
H__repl =: H_HIST+1
W__repl =: W_HIST
XY__repl=: X_HIST,0
A__repl =: 1
OLD__repl =: ''
red =: ed__repl

editor =: 'UiWidget' conew~ ''
XY__editor =: 0 0
H__editor =: H_HIST
W__editor =: X_HIST-2

app =: (editor,list,cmds,led,repl) conew 'UiApp'


NB. -- widget modifications ---------------------------------------

NB. allow changing the repl line as we navigate through the outline
new_repl_line =: {{
  if. ': ' {.@E. val =. >val__cmds'' do.
    if. ': . ' {.@E. val do. ''
    else. 2}.val end.
  else. '' end. }}

update__repl =: {{
  R =: R +. R__ed
  new =. new_repl_line_base_''
  if. -. new -: OLD do.
    setval__ed OLD =: new
    R =: 1
  end. }}

inscmd =: put_text [ ins__cmds

accept__repl =: {{
  inscmd_base_ ': ', B__ed
  inscmd_base_ ': . ', getlog__ed''
  NB. TODO: trigger update of "future worlds"
  accept_UiRepl_ f.'' }}

hist_lines =: {{
  NB. returns the list of echo history lines that should currently
  NB. appear on the screen, based on the cursor positions within the
  NB. outline.
  w =. olw pick~ index I. C__list, C__cmds
  NB. H_HIST-1 to leave one line at bottom for next repl input
  (-H_HIST-1) {. ('HISTL1_',w,'_')~ {. ehist_world_ }}

hist_lines__repl =: {{ hist_lines_base_''}}


NB. -- in-presentaiton editor widget (on the left) -------------------------
render__editor =: {{
  cc =. code_base_ cur_base_
  NB. draw the code editor
  cscr'' [ bg 16b101010 [ reset''
  if. -. a: -: cc do.
    for_line. >jlex cc do.
      goxy 0,line_index
      puts ' ' NB. little bit of whitespace on the left
      if. line ~: a: do.  (put_tok_TokEd_ :: ]) L:1 "1 > line end.
    end.
  end. R =: 0 }}

NB. keyboard control
goto =: {{
 R__editor =: R__repl =: 1
 L__cmds =: text cur =: y
 S__cmds =: C__cmds =: 0 }}

put_text =: {{ 0 0 $ slides =: (<L__cmds) (<cur,1) } slides  }}

COPATH =: copath coname''
keymode =: {{ (~. (}: y;copath y),COPATH__BASE) copath BASE }}


(copush [ coinsert) 'outkeys'
NB. -----------------------------------------------------------
coinsert BASE
inscmd =: inscmd__BASE
k_any =: {{
  select. 0{y
  case.'9'do. goto bak__list''
  case.'0'do. goto fwd__list''
  case.'('do. bak__cmds''
  case.')'do. fwd__cmds''
  end. }}

kc_l =: smudge__app
kc_s =: {{ (org_text'') fwrites ORG_PATH }}
kc_c =: {{ curs@1 reset@'' break_kvm_=: 1 }}
kc_o =: {{
  lc =. cur
  rc =. C__cmds
  init_world_''
  open''
  goto lc <. <: #slides
  C__cmds =: rc <. <: #L__cmds }}

edline =: {{
  R__led =: V__led =: 1 [ XY__led =: XY__cmds + 0,C__cmds
  C__led =: 0 [ B__led =: '',>val__cmds__BASE''
  ed_edkeys_ =: led
  keymode__BASE 'edkeys'}}

edrepl =: {{
  V__red =: R__red =: 1
  C__red =: 0 [ B__red =: 2}.>val__cmds__BASE''
  keymode__BASE 'replkeys' }}

insline =: edline@'' @ inscmd@''
k_O =: insline
k_o =: insline@fwd__cmds
k_e =: edline
k_E =: edrepl
k_d =: put_text@'' @ del__cmds

k_k =: k_p =: {{
  if. (at0__cmds > at0__list)'' do.
    goto bak__list''
    goz__cmds''
  else. bak__cmds'' end.
  R__red =: 1
  }}

k_j =: k_n =: {{
  if. atz__cmds'' do. goto fwd__list''
  else. fwd__cmds'' end.
  R__red =: 1
  }}

k_N =: {{
  if. -. a: = cmd =. val__cmds'' do.
    cmd =. >cmd
    if. ':' = 0{cmd do.  do_tok_>'n?','?!',~}.cmd end.
  end.
  k_n'' }}

copop''

copush 'edkeys'
NB. -----------------------------------------------------------
led =: led__BASE [ cmds =: cmds__BASE

kc_m =: stop__led =: {{
  keymode__BASE 'outkeys'
  V__led =: 0 [ R__led =: R__cmds =: 1
  L__cmds =: (<B__led) C__cmds } L__cmds
  put_text'' }}

k_asc =: {{ R__led =: 1 [ ins__led y }}
kc_d =: del__led
kc_h =: k_bksp =: bsp__led
kc_e =: eol__led
kc_b =: bak__led
kc_f =: fwd__led
kc_t =: swp__led
kc_a =: bol__led
kc_k =: keol__led

copop''



copush'replkeys'
NB. -----------------------------------------------------------
red =: red__BASE
repl =: repl__BASE

kc_m =: {{
  keymode__BASE 'outkeys'
  accept__repl''
}}

k_asc =: k_asc__red
kc_d =: kc_d__red
kc_h =: k_bksp =: kc_h__red
kc_b =: kc_b__red
kc_f =: kc_f__red
kc_t =: kc_t__red
kc_e =: kc_e__red
kc_a =: kc_a__red
kc_k =: kc_k__red

copop''


rl =: {{ load'mje.ijs' }} NB. reload command (for development)

NB. event loop
mje =: {{
  9!:29]0  NB. disable infinite loop on error
  curs 0
  goto 0 NB. slide 0
  NB. main loop
  step__app loop_kvm_'base'
  reset''
  0$0}}

9!:27 'mje'''''
9!:29]1

