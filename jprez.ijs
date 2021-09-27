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
dbg 1
copush_z_ =: {{ 18!:4 y [ BASE__y =: coname'' [ y=.<y }}
copop_z_ =: {{ y [ 18!:4 BASE [ y=.coname'' }}

NB. main code
ORG_PATH =: './screenplay.org'


NB. org-mode stuff
open =: {{
  org_slides ORG_PATH  NB. defines title =: ... and  slides =: ...
  NB. heads is the indented outline that shows up on the left
  heads =: <@;"1((' '#~+:@<:) each 3 {"1 slides),.(0{"1 slides)
  rebuild''}}

rebuild =: {{
  emit_vm_ =: ] NB. so j-kvm/vm outputs string we can capture (vs puts)
  NB. (index I. (C__list, C__cmd) { olw) says which world we are in
  index =: 0 0 $ 0  NB. one entry per line that starts with : (slide,line no)
  olw =: ,0  NB. outline worlds. 'now'=EHISTL0/EHISTL1 in (i{olw)
  init_world_''
  tmp =. ''conew 'UiEditWidget' NB. for tracking start states per macro
  KPS__tmp =: _ [ TSV__tmp =: 0 NB. infinite speed, no random variation
  olr =: ,<getstate__tmp''      NB. repl state for each ':' line
  for_slide. slides do. i =. slide_index
    for_line. text i do. j =. line_index
      if. -. line = a: do.
        line =. > line
        if. ': ' {.@E. line do. line =. 2}.line     NB. : marks code line
          if. '. ' {.@E. line do. line =. 2}.line   NB. : . is editor macro
            do__tmp line while. A__tmp do. update__tmp 1 end. NB. run macro
          else.
            setval__tmp line
            exec_world_ line           NB. execute code in repl
            setval__tmp''
          end.
          index =: index, i,j
          olr =: olr,<getstate__tmp'' NB. store start state for next cmd
          olw =: olw,ii_world_        NB. world stores both start & end state
        end.
      end.
    end.
  end.
  codestroy__tmp''
  emit_vm_ =: emit0_vm_ NB. restore j-kvm/vm
  0 0$0}}

open''  NB. TODO: move to bottom

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
H__cmds =: H__list
XY__cmds =: 33 0 + XY__list

NB. led is the line editor for editing a line of text in the outline
led =: 'UiEditWidget' conew~ ''
XY__led =: XY__cmds
W__led =: W__cmds
V__led =: 0

repl =: 'UiRepl' conew~ ''
H__repl =: H_HIST
W__repl =: W_HIST
XY__repl=: X_HIST,0
A__repl =: 1
OLD__repl =: ''
red =: ed__repl
KPS__red =: 10* KPS__red NB. double speed until we fix jprez speed issues

editor =: 'UiWidget' conew~ ''
XY__editor =: 0 0
H__editor =: H_HIST
W__editor =: X_HIST-2

app =: (list,editor,cmds,led,repl) conew 'UiApp'


NB. -- widget modifications ---------------------------------------

NB. allow changing the repl line as we navigate through the outline
new_repl_line =: {{
  if. ': ' {.@E. val =. >val__cmds'' do.
    if. ': . ' {.@E. val do. ''
    else. 2}.val end.
  else. '' end. }}

update__repl =: {{
  if. A__ed do. update__ed y end.
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
  cmds =. cmds_base_
  fwd__cmds^:2''
  accept_UiRepl_ f.''
  rebuild_base_'' }}

cmdix =: {{ index I. C__list, C__cmds }}

worldnum =: {{ olw_base_ pick~ cmdix_base_'' }}
getworld__repl =: {{ 'WORLD',": worldnum_base_'' }}


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
keymode =: {{
  NB. modal editing kludge to simulate focused widget
  NB. and swap out keyboard handler.
  NB. the curtail (}:) is to cut out 'z' reference from copath y
  (~. (}: y;copath y),COPATH__BASE) copath BASE
  NB. also set focus to a widget:
  F__app =: FOCUS__ns [ ns =. < y
  NB. !! this should probably be in an on_focus event, but:
  reset_rhist''
}}

reset_rhist =: {{ L__hist__repl =: (1+worldnum'') {. ihist_world_ }}


(copush [ coinsert) 'outkeys'
NB. -----------------------------------------------------------
coinsert BASE
FOCUS =: list__BASE [ ''`inscmd =: inscmd__BASE

k_any =: {{
  select. 0{y
  case.'9'do. goto bak__list''
  case.'0'do. goto fwd__list''
  case.'('do. bak__cmds''
  case.')'do. fwd__cmds''
  end. }}
k_E =: edrepl
k_N =: playmacro
k_O =: insline
k_d =: delline
k_e =: edline
k_j =: k_n =: fwd_cmd
k_k =: k_p =: bak_cmd
k_o =: insline@fwd__cmds
kc_i =: focus_on_repl
kc_l =: smudge__app
kc_o =: reopen
kc_s =: save
kc_spc =: k_nul =: halt  NB. 'kc_spc' does nothing yet

focus_on_repl =: {{
  R__list =: R__repl =: 1 NB. to redraw focus
  keymode__BASE 'replkeys' }}

save =: {{ (org_text'') fwrites ORG_PATH }}
halt =: {{ curs@1 @ reset@'' [ break_kvm_=: 1 }}
insline =: edline@'' @ inscmd@''
delline =: rebuild @ put_text@'' @ del__cmds

reopen =: {{
  lc =. cur
  rc =. C__cmds
  init_world_''
  open''
  goto lc <. <: #slides
  C__cmds =: rc <. <: #L__cmds }}

NB. more 'outkeys' definitions

edline =: {{
  R__led =: V__led =: 1 [ XY__led =: XY__cmds + 0,C__cmds
  C__led =: 0 [ B__led =: '',>val__cmds__BASE''
  ed_edkeys_ =: led
  keymode__BASE 'edkeys'}}

edrepl =: {{
  V__red =: R__red =: 1
  C__red =: 0 [ B__red =: 2}.>val__cmds__BASE''
  keymode__BASE 'replkeys' }}

bak_cmd =: {{
  if. (at0__cmds > at0__list)'' do.
    goto bak__list''
    goz__cmds''
  else. bak__cmds'' end. }}

fwd_cmd =: {{
  if. atz__cmds'' do. goto fwd__list''
  else. fwd__cmds'' end. }}

playmacro =: {{
  NB. play macro we currently looking at in the outline
  if. a: ~: cmd =. val__cmds'' do.
    cmd =. >cmd
    if. ': . ' -: 4{.cmd do.
      setstate__red olr__BASE pick~ cmdix__BASE''
      reset_rhist__BASE''
      do__red 4}.cmd
    end.
  end. }}

copop''

copush 'edkeys'
NB. -----------------------------------------------------------
FOCUS =: led =: led__BASE [ cmds =: cmds__BASE

stop =: {{
  keymode__BASE 'outkeys'
  V__led =: 0 [ R__led =: R__cmds =: 1
  L__cmds =: (<B__led) C__cmds } L__cmds
  put_text'' }}

k_asc =: {{ R__led =: 1 [ ins__led y }}
ka_b =: ka_b__led
ka_f =: ka_f__led
kc_d =: del__led
kc_h =: k_bsp =: bsp__led
kc_e =: eol__led
kc_b =: bak__led
kc_f =: fwd__led
kc_m =: stop
kc_t =: swp__led
kc_a =: bol__led
kc_k =: keol__led

copop''



copush'replkeys'
NB. -----------------------------------------------------------
FOCUS =: repl =: repl__BASE
red =: ed__repl

focus_on_outline =: {{
  R__repl =: 1 NB. to redraw without focus
  keymode__BASE 'outkeys' }}

k_arup =: k_arup__red
k_ardn =: k_ardn__red
k_asc =: k_asc__red
ka_b =: ka_b__red
ka_f =: ka_f__red
kc_a =: kc_a__red
kc_b =: kc_b__red
kc_d =: kc_d__red
kc_e =: kc_e__red
kc_f =: kc_f__red
kc_h =: k_bsp =: kc_h__red
kc_i =: focus_on_outline  NB. tab to unfocus
kc_k =: kc_k__red
kc_m =: kc_m__red
kc_t =: kc_t__red

copop''


rl =: {{ load'jprez.ijs' }} NB. reload command (for development)

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