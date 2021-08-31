load 'tangentstorm/j-kvm tangentstorm/j-kvm/ui tangentstorm/j-lex'
load 'tok.ijs'
coinsert 'kvm'

ed =: conew 'UiEditWidget'
ted_z_ =: '' conew 'TokEd'  NB. for syntax highlighting
app_z_ =: (,ed) conew 'UiApp'

XY__ed =: 3 0
XY__ted =: 3 0


render__ed =: {{
  cscr'' [ bg BG [ fg FG
  B__ted =: jcut_jlex_ B
  render__ted''
  render_cursor ''
  bg BG [ fg FG  }}

NB. B__ed =: '{{ i. y }}"0 ] 5'
NB. macro =: '$XXXXXXXXXXXXXXXX?hello world?b?,?$'
B__ed =: 'hello, world'
macro =: 'h_h_h_h_h_h_h__l_l_l_lh_h_h_h_h________________________________________________x_x_X_X_X_X___?+?__X__?+?__?/?___?4?__X_?p?_?;?__X__?:?__?i?_?.?__?1?_?0?__x_x_x_x__x__x'

do__ed macro

render__app loop_kvm_ >ed
