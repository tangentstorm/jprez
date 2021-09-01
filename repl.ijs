load 'tangentstorm/j-kvm tangentstorm/j-kvm/ui tangentstorm/j-lex'
load 'tok.ijs'
coinsert 'kvm'

cocurrent 'UiSpinner' extends 'UiWidget'

create =: {{
  S =: ' _.,oO( )Oo,._ '"_ ^:(y-:'') y
  W =: # S
  A =: 1
}}

update =: {{
 R=:1 [ S=:1|.S  NB. rotate the text
}}

render =: {{
  bg _4 [ fg _9
  puts '['
  fg _15
  puts 4{. S
  fg _9
  puts']' }}

cocurrent 'base'

ed =: conew 'UiEditWidget'
s0 =: '' conew 'UiSpinner'
s1 =:  'UiSpinner' conew~ 'hello, world'
ted_z_ =: '' conew 'TokEd'  NB. for syntax highlighting
app_z_ =: (s0,s1,ed) conew 'UiApp'   NB. in z so loop_kvm can see it

XY__ed =: 3 0
XY__ted =: 3 0
XY__s0 =: 5 5
XY__s1 =: 3 3

render__ed =: {{
  cscr'' [ bg BG [ fg FG
  B__ted =: jcut_jlex_ B
  render__ted''
  render_cursor ''
  bg BG [ fg FG  }}

NB. B__ed =: '{{ i. y }}"0 ] 5'
NB. macro =: '$XXXXXXXXXXXXXXXX?hello world?b?,?$'
B__ed =: 'hello, world'
macro =: 'h_h_h_h_h_h_h__l_l_l_lh_h_h_h_h__x_x_X_X_X_X___?+?__X__?+?__?/?___?4?__X_?p?_?;?__X__?:?__?i?_?.?__?1?_?0?__x_x_x_x__x__x'

do__ed macro NB. ed.do(macro) in other languages

step__app loop_kvm_ >ed
