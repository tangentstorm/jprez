NB. minimal j editor
NB.
NB. This file my attempt to port my presentation tool
NB. over to my new console-based libraries, token editor
NB. components, etc. It is something of a scratchpad and
NB. not well organized at the moment, but important enough
NB. that I should probably have it under version control.
(<'z') copath 'base' NB. clear previous path
load'tangentstorm/j-kvm tangentstorm/j-kvm/ui tangentstorm/j-lex'
load'worlds.ijs org.ijs tok.ijs repl.ijs jedit.ijs macro.ijs'
load'convert/misc/md5' NB. for wavpath (filename calculation)
coinsert 'kvm'
dbg 0 NB. cannot debug from pascal shell at the moment
copush_z_ =: {{ 18!:4 y [ BASE__y =: coname'' [ y=.<y }}
copop_z_ =: {{ y [ 18!:4 BASE [ y=.coname'' }}

NB. main code
{{ NB. initialize ORG_PATH, but let it survive a rl''
  if. 0 = 4!:0<'ORG_PATH' do. return. end.
  if. '.org' {.@E.&.|. arg=.>{:ARGV do. ORG_PATH =:arg
  else. ORG_PATH =:'./screenplay.org' end. }}''

NB. org-mode stuff
open =: {{
  if. -. y -: '' do. ORG_PATH =: y end.
  reorg freads ORG_PATH
  L__list =: heads}}

goix =: ] NB. stub because we call 'open' before drawing widgets :/
reorg =: {{
  if. -. y -: '' do. org =: org_from_str orgs =: y end.
  NB. heads is the indented outline that shows up on the left
  heads =: <@;"1((' '#~+:@<:) each 3 {"1 slides),.(0{"1 slides)
  goix 0 0
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
          elseif. '@cls' -: line do. cscr_world_@exec_world_''
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


NB. --  screen setup ---------------------------------------------------
H_SPLIT =: 24 NB. initial height of horizontal splitter

NB. indent headings based on depth
list =: 'UiList' conew~ EMPTY
H__list =: (>:ymax'')-H_SPLIT
XY__list =: 0,H_SPLIT
TX_BG__list =: 16b111122

NB. the detailed text of the screenplay (also macro commands)
cmds =: 'UiList' conew~ a:
W__cmds =: (xmax'')-(W__list)
H__cmds =: H__list
XY__cmds =: ((W__list+2),0) + XY__list
TX_BG__cmds =: 16b111122
render_item__cmds =: {{
  NB. x  is current line number
  s =. >y
  select. {. s
    case. ':' do.
      if. ': .' -: 3 {. s do.
        if. C=x do. fg _4  [ bg _12 else. fg _12 end.
      else. if. C=x do. fg _14 [ bg _6 else. fg _6 end. end.
    case. '#' do.
      fg _1
    case. do.
      if. C~:x do. NB. if not current line, show whether .wav exist
        if. fexist 'wav/',calc_wavpath_base_ s do. fg _15 end.
      end.
  end.
  puts W{.s }}



NB. led is the line editor for editing a line of text in the outline
led =: 'MacroWidget' conew~ ''
XY__led =: XY__cmds
W__led =: W__cmds
V__led =: 0

repl =: 'UiRepl' conew~ ''   NB. W,XY of repl are calculated in show/hide editor
H__repl =: H_SPLIT
A__repl =: 1
OLD__repl =: ''
red =: ed__repl

editor =: 'JCodeEditor' conew~ ''
XY__editor =: 0 0
H__editor =: H_SPLIT
W__editor =: 70

show_editor =: {{ V__editor =: 1 [ XY__repl =: (W__editor+2), 0 [ W__red =: W__repl =: W__editor -~ xmax'' }}
hide_editor =: {{ V__editor =: 0 [ XY__repl =: 0 0 [ W__red =: W__repl =: 1+xmax'' }}
hide_editor''

app =: (list,editor,cmds,led,repl) conew 'UiApp'
smudge__app BG__app =: 16b112233

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


NB. keyboard control

goix =: {{
  NB. go to y =: slide,line
  setval__red'' [ A__red =: 0 NB. halt macro
  setval__editor code cur =: C__list =: 0{y
  fwd__cmds^:(1{y)'' [go0__cmds''[ L__cmds =: text cur
  smudge__app''}}

goto =: {{ goix y,0 }}

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

NB. 1+worldnum includes the completed macro.
reset_rhist =: {{ goz__hist__repl'' [ L__hist__repl =: (1+worldnum'') {. ihist_world_ }}

reopen =: {{
  lc =. cur [ rc =. C__cmds
  open'' [ init_world_''
  R__list =: 1 [ L__list =: heads
  goto lc <. <: #slides
  C__cmds =: rc <. <: #L__cmds }}

NB. global keyboard shortcuts
NB. ----------------------------------------------------
NB. pascal frontend commands
WD_PLAYAUDIO =: 8000
WD_OPEN_FILE =: 8010

kc_l =: smudge__app
kc_o =: reopen
kc_s =: save
kc_q =: halt

k_f12 =: {{
  if. a: ~: val__cmds'' do.
    if. fexist wp=.wavpath'' do. (11!:WD_PLAYAUDIO) ::0: wp end.
  end.
  fwd_cmd''}}

k_f2 =: flip
k_f3 =: move_splitter@_1
k_f4 =: move_splitter@1
k_f5 =: toggle_editor
k_f6 =: goto@bak__list
k_f7 =: goto@fwd__list
k_f8 =: bak_cmd
k_f9 =: advance
k_f10 =: (11!:WD_OPEN_FILE) :: 0:

advance =: {{
  if. ': . ' {.@E. >val__cmds'' do. playmacro''
  else. fwd_cmd'' [ keymode'replkeys' end. }}

FLIP =: 1
flipped =: {{ FLIP }}
flip =: {{
  FLIP =: -FLIP
  H__list =: H__cmds =: H__editor [ th =. H__cmds
  H__editor =: H__repl =: th
  ty1 =. 1{XY__editor [ ty0 =. 1{XY__cmds
  XY__editor =: ty0 (1) } XY__editor
  XY__repl   =: ty0 (1) } XY__repl
  XY__list   =: ty1 (1) } XY__list
  XY__cmds   =: ty1 (1) } XY__cmds
  move_splitter 0
}}

move_splitter =: {{
  if. *./ 1 < (H__list-y),H__repl + y do.
    if. FLIP = 1 do.
      XY__list =: XY__list + 0,y [ H__list =: H__list - y
      XY__cmds =: XY__cmds + 0,y [ H__cmds =: H__cmds - y
      H__editor =: H__editor + y
      H__repl =: H__repl + y
    else.
      XY__editor =: XY__editor + 0,y [ H__editor =: H__editor - y
      XY__repl   =: XY__repl   + 0,y [ H__repl =: H__repl - y
      H__cmds =: H__cmds + y
      H__list =: H__list + y
    end.
    smudge__app''
  end. }}

toggle_editor =: {{
  if. V__editor do. hide_editor'' else. show_editor'' end.
  smudge__app'' }}


save =: {{ (org_text'') fwrites ORG_PATH }}
halt =: {{ curs@1 @ reset@'' [ break_kvm_=: 1 }}
insline =: edline@'' @ inscmd@''
delline =: rebuild @ put_text@'' @ del__cmds

bak_cmd =: {{
  if. (at0__cmds > at0__list)'' do.
    goto bak__list''
    goz__cmds''
  else. bak__cmds'' end. }}

fwd_cmd =: {{
  if. atz__cmds'' do. goto@fwd__list^:(-.@atz__list)''
  else. fwd__cmds'' end. }}

playmacro =: {{
  NB. play macro we currently looking at in the outline
  if. a: ~: cmd =. val__cmds'' do.
    cmd =. >cmd
    if. ': . ' -: 4{.cmd do.
      setstate__red olr pick~ cmdix''
      reset_rhist'' NB. this includes the completed line...
      set__hist__repl'' NB. so delete it. (TODO: handle multi-line macros)
      on_macro_end__red =: fwd_cmd_base_
      do__red 4}.cmd
    end.
  end. }}


(copush [ coinsert) 'outkeys'
NB. -----------------------------------------------------------
coinsert BASE
FOCUS =: list__BASE [ ''`inscmd =: inscmd__BASE

k_any =: {{
  if. 0=#y do. return. end.
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

focus_on_repl =: {{
  R__list =: R__repl =: 1 NB. to redraw focus
  keymode__BASE 'replkeys' }}


NB. outline / macro editor

register__led red  NB. red listens for changes to led ..
notify__led =: ]   NB. .. but ignores them by default.
edline =: {{
  R__led =: V__led =: 1 [ XY__led =: XY__cmds + 0,C__cmds-S__cmds
  C__led =: 0 [ B__led =: b=. '',>val__cmds__BASE''
  ed_edkeys_ =: led
  keymode__BASE 'edkeys'
  if. ': ' -: 2 {. b do.
    if. ': . ' -: 4{.b do.
      notify__red =: instaplay @ (4&}. [ reset_rhist_base_@'')
      setval__red ''
    else.
      notify__red =: setval @ (2&}.)
      setval__red 2}.b
    end.
  else. notify__red =: ] end.
  0 0$0 }}

edrepl =: {{
  V__red =: R__red =: 1
  C__red =: 0 [ B__red =: 2}.>val__cmds__BASE''
  keymode__BASE 'replkeys' }}

copop''

copush 'edkeys'
NB. -----------------------------------------------------------
FOCUS =: led =: led__BASE [ cmds =: cmds__BASE

stop =: {{
  keymode__BASE 'outkeys'
  V__led =: 0 [ R__repl =: R__red =: R__led =: R__cmds =: 1
  L__cmds =: (<B__led) C__cmds } L__cmds
  put_text'' }}

NB. copy keymap from led. ex:  k_arup =: k_arup__led
". {{  y,' =: ',y,'__led' }}S:0 KEY_PRESS__led
k_asc =: k_asc__led
kc_m =: stop

copop''



copush'replkeys'
NB. -----------------------------------------------------------
FOCUS =: repl =: repl__BASE
red =: ed__repl

focus_on_outline =: {{
  R__repl =: 1 NB. to redraw without focus
  keymode__BASE 'outkeys' }}

NB. copy keymap from red. ex:  k_arup =: k_arup__red
". {{  y,' =: ',y,'__red' }}S:0 KEY_PRESS__red

k_asc =: k_asc__red
kc_i =: focus_on_outline  NB. tab to unfocus

copop''


NB. -----------------------------------------------------------

calc_wavpath =: {{
  NB. calculate *.wav filename for line of text y.
  ok =. e.&'abcdefghijklmnopqrstuvwxyz0123456789'
  s =. tolower y
  r =. ({.~ 27<.#) (#~ ok) s
  r =. (4 {. md5 s),'-',r,'.wav' }}

NB. wavpath for the current line of text
wavpath =: {{
  line =. > C__cmds { L__cmds
  if. ':' -: {.line do. ''
  elseif. line -: '' do. ''
  else. calc_wavpath line end. }}

NB. -----------------------------------------------------------
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

resume =: {{ step__app loop_kvm_'base' [ smudge__app''}}

open''

NB. only run if directly invoked from command line
{{9!:29]1[9!:27 'mje _'}}^:('jprez.ijs' {.@E.&.|. >{.}.ARGV)''
