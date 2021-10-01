NB. Syntax-highlighted edit field.

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
