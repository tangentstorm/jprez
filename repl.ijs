NB. repl ui widget, including history display
load 'tangentstorm/j-kvm tangentstorm/j-kvm/ui tangentstorm/j-lex'
load 'tok.ijs worlds.ijs'

coclass 'UiRepl' extends 'UiWidget'
coinsert 'kvm'

create =: {{
  'H W' =: gethw_vt_''
  ed =: conew 'UiEditWidget'
  ted =: '' conew 'TokEd'  NB. for syntax highlighting
  XY__ed =: XY__ted =: 0 0  NB. initial position of prompt
  kc_m__ed =: ('accept_','_',~>coname'')~  NB. !! TODO: fix this ugly mess!
  0 0$0 }}

render =: {{
  bg BG__ed [ fg FG__ed
  try.
    B__ted =: jcut_jlex_ B__ed
    render__ted''
  catch.
    render__ed''
  end.
  render_cursor__ed ''
  bg BG__ed [ fg FG__ed  }}

NB. event handler for accepting the finished input line
accept =: {{
  exec_world_ B__ed
  setval__ed'' [ R__ed =: 1
  break_kvm_ =: 1 }}


NB. B__ed =: '{{ i. y }}"0 ] 5'
NB. macro =: '$XXXXXXXXXXXXXXXX?hello world?b?,?$'

NB. standalone app (if not inside 'load' from some other file)
{{y
  cocurrent'base'
  repl =: 'UiRepl' conew~ ''
  app_z_ =: 'UiApp' conew~ ,repl   NB. in z so loop_kvm can see it
  step__app loop_kvm_ >ed__repl
}}^:('repl.ijs' {.@E.&.|. >{.}.ARGV)''
