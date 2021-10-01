NB. syntax aware code editor widget for j
require 'tangentstorm/j-kvm/ui'

coclass 'JCodeEditor' extends 'UiWidget'

render =: {{
  cc =. code_base_ cur_base_  NB. TODO: store this in a member variable
  NB. draw the code editor
  cscr'' [ bg 16b101010 [ reset''
  if. -. a: -: cc do.
    for_line. >jlex cc do.
      goxy 1,line_index
      puts ' ' NB. little bit of whitespace on the left
      if. line ~: a: do.  (put_tok_TokEd_ :: ]) L:1 "1 > line end.
    end.
  end. R =: 0 }}
