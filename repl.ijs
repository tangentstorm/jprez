NB. repl ui widget, including history display
load 'tangentstorm/j-kvm tangentstorm/j-kvm/ui tangentstorm/j-lex'
load 'tok.ijs worlds.ijs'

coclass 'UiSyntaxLine' extends 'UiEditWidget'

create =: {{
  create_UiEditWidget_ f. y
  ted =: '' conew 'TokEd'  NB. for syntax highlighting
}}

render =: {{
  bg BG [ fg FG
  try.
    B__ted =: jcut_jlex_ B
    render__ted y
  catch.
    render_UiEditWidget_ f. y
  end.
  render_cursor y }}

coclass 'UiRepl' extends 'UiWidget'
coinsert 'kvm'

create =: {{
  'H W' =: gethw_vt_''
  ed =: '' conew 'UiSyntaxLine'  NB. syntax highlighted editor
  hist =: (,<y) conew 'UiList'
  XY__ed =: 3 0  NB. initial position of prompt
  kc_m__ed =: ('accept_','_',~>coname'')~  NB. !! TODO: fix this ugly mess!
  0 0$0 }}

update =: {{ R =: R +. R__ed }}

getworld =: {{ this_world_'' }}
hist_lines =: {{
  if. -.*#ehist_world_ do. return. 0$a:  end.
  NB. returns the list of echo history lines that should currently
  NB. appear on the screen, based on the cursor positions within the
  NB. outline.
  NB. hlen=number of history lines *at this point in timeline*
  hlen =. ('HISTL1_',(getworld''),'_')~
  NB. leave one line at bottom for next repl input (max line is h-1, so h-2)
  (-hlen <. H-2) {. hlen {. ehist_world_ }}

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
  if. atz__hist'' do.
    if. #B__ed do. ins__hist <B__ed [ fwd__hist'' end.
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
{{y
  cocurrent'base'
  init_world_''
  repl =: 'UiRepl' conew~ ''
  app_z_ =: 'UiApp' conew~ ,repl   NB. in z so loop_kvm can see it
  step__app loop_kvm_ >ed__repl
}}^:('repl.ijs' {.@E.&.|. >{.}.ARGV)''
