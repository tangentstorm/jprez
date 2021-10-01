NB. syntax aware code editor widget for j
require 'tangentstorm/j-kvm/ui'
require 'tok.ijs syntaxline.ijs'

coclass 'JCodeEditor' extends 'UiList'

create =: {{
  create_UiList_ f. y
  ed =: '' conew 'UiSyntaxLine'  NB. syntax highlighted line editor
  on_accept__ed =: 'accept'of_self
  on_up__ed =: 'bak'of_self
  on_dn__ed =: 'fwd'of_self
  0 0$0 }}

setval =: {{ curxy 0 0 [ L =: y }}

curxy =: {{
  'cx cy' =. y
  setval__ed > (C=:cy) { L
  C__ed =: cx
  R =: 1 }}


render =: {{
  NB. draw the code editor
  cscr'' [ bg 16b101010 [ reset''
  if. -. a: -: L do.
    for_line. >jlex L do.
      goxy 0,line_index
      if. line ~: a: do.  (put_tok_TokEd_ :: ]) L:1 "1 > line end.
    end.
    NB. draw the cursor on current line C using is_focused flag y
  end.
  C render_cursor__ed y
  R =: 0 }}
