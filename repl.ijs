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
  render_cursor '' }}

coclass 'UiRepl' extends 'UiWidget'
coinsert 'kvm'

create =: {{
  'H W' =: gethw_vt_''
  MJE =: 0
  ed =: '' conew 'UiSyntaxLine'  NB. syntax highlighted editor
  XY__ed =: 3 0  NB. initial position of prompt
  kc_m__ed =: ('accept_','_',~>coname'')~  NB. !! TODO: fix this ugly mess!
  0 0$0 }}

render =: {{
  if. MJE do.  NB. mje-specific features
    cmds =. cmds_base_
    NB. draw token editor on the last line
    XY__ed =: =: 3 0 + X_HIST_base_, #hist_lines_base_'' NB.   3-space prompt
    if. ':' {.@E. val =. >val__cmds'' do. B__ted =: jcut_jlex_ 2}.val
    else. B__ted =: a: end.
    NB. draw actual history
    for_line. hist_lines_base_'' do.
      reset''
      goxy 0, line_index
      vputs >line
    end.
  end.
  termdraw__ed''
  R =: 1 }}

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
