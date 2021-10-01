NB. syntax aware code editor widget for j
require 'tangentstorm/j-kvm/ui'

coclass 'JCodeEditor' extends 'UiList'

render =: {{
  NB. draw the code editor
  cscr'' [ bg 16b101010 [ reset''
  if. -. a: -: L do.
    for_line. >jlex L do.
      goxy 1,line_index
      puts ' ' NB. little bit of whitespace on the left
      if. line ~: a: do.  (put_tok_TokEd_ :: ]) L:1 "1 > line end.
    end.
  end. R =: 0 }}
