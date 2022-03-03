NB. repl ui widget, including history display
load 'tangentstorm/j-kvm tangentstorm/j-kvm/ui tangentstorm/j-lex'
require 'tok.ijs worlds.ijs syntaxline.ijs'

coclass 'UiRepl' extends 'UiWidget'
coinsert 'kvm'

create =: {{
  'H W' =: gethw_vt_''
  hist =: (,<y) conew 'UiList'
  ed =: '' conew 'UiSyntaxLine'  NB. syntax highlighted line editor
  XY__ed =: 3 0  NB. initial position of prompt
  on_accept__ed =: 'accept'of_self
  on_up__ed =: 'bak' of_self
  on_dn__ed =: 'fwd' of_self
  0 0$0 }}

update =: {{ R =: R +. R__ed }}

getworld =: {{ this_world_'' }}
hist_lines =: {{
  if. -.*#ehist_world_ do. return. 0$a:  end.
  NB. returns the list of echo history lines that should currently
  NB. appear on the screen, based on the cursor positions within the
  NB. outline.
  NB. hlen=number of history lines *at this point in timeline*
  NB. hcsc=last time the history was cleared
  hlen =. ('EHISTL1_',(getworld''),'_')~
  hcsc =. ('EHISTCS_',(getworld''),'_')~
  NB. leave one line at bottom for next repl input (max line is h-1, so h-2)
  (-hlen <. H-2) {. hcsc }. hlen {. ehist_world_ }}

render =: {{
  hist =. hist_lines''
  for_line. hist do.
    reset''
    goxy 0, line_index
    vputs >line
  end.
  NB. draw line editor / prompt on the last line, with 3-space prompt
  XY__ed =: 3 0 + (0, # hist)
  termdraw__ed y
  R =: R__ed =: 0 }}


bak =: {{
  if. (atz__hist'') *. #B__ed do.
    NB. save work-in-progress so arrow up, arrow down restores it.
    ins__hist B__ed [ fwd__hist''
  end.
  bak__hist''
  setval__ed >val__hist''
  R =: 1 }}

fwd =: {{
  fwd__hist''
  setval__ed >val__hist''
  R =: 1 }}


NB. k_arup =: bak
NB. k_ardn =: fwd

NB. event handler for accepting the finished input line
accept =: {{
  exec_world_ B__ed
  goz__hist''
  ins__hist B__ed
  goz__hist''
  L__hist =: L__hist -. <a:
  setval__ed'' }}



NB. B__ed =: '{{ i. y }}"0 ] 5'
NB. macro =: '$XXXXXXXXXXXXXXXX?hello world?b?,?$'

NB. standalone app (if not inside 'load' from some other file)
repl=:{{y
  cocurrent'base'
  init_world_''
  repl =: 'UiRepl' conew~ ''
  app_z_ =: 'UiApp' conew~ ,repl   NB. in z so loop_kvm can see it
  step__app loop_kvm_ >ed__repl }}
repl^:('repl.ijs' {.@E.&.|. >{.}.ARGV)''
