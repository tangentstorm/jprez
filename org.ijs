NB. jprez-specific org-mode parser
NB. the jprez format is a subset of org-mode:
NB.  - #+title: at the top
NB.  - any number of nested headlines
NB.  - body text only appears in leaf nodes ("slides")
NB.  - zero to one #+begin_src j ... #+end_src per slide
NB.  - lines starting with # indicate comments
NB.  - [[path/to/file.xyz]] indicates an audio file
NB.  - verbatim lines (starting with ":") indicate repl input or macros
NB.    - ": ." indicates that the line is a jprez keyboard macro
NB.    - ": " (not followed by " .") indicates verbatim repl input

MACROS_ONLY =: 0 NB. toggled by godot-plugin to ignore non-macro steps

between =: (>:@[ +  i.@<:@-~)/           NB. between 3 7 ->  4 5 6
parse =: monad define
  NB. parse a single slide
  NB. returns (head; text; src) triple
  head =. (2+I.'* 'E.h) }. h=.>{. y      NB. strip any number of leading '*'s, up to ' '
  depth =. h <:@-&# head                 NB. record the number of leading stars
  text =. }. y
  srcd =. '#+begin_src j';'#+end_src'    NB. source code delimiters
  src =. , |: si=.I. y ="1 0 srcd        NB. indices of start and end delimiters
  if. #src do.
    code =. y {~ between 2$src           NB. only take the first source block
    text =. (1{src) }. text
  else. code =. a:  end.
  if. MACROS_ONLY do. text =. text#~':'={.&> text end.
  (<head),(<text),(<code),<depth
)

org_slides =: org_from_str @ fread

org_from_str =: {{
  org =: 7 u: L:0 LF splitstring y
  headbits =. '*' = {.&> org             NB. 1 if org line starts with '*' (a headline)
  slide0 =. headbits <;.1 org            NB. group lines: each headline starts a new slide
  title =: {.org
  slides =: > parse each slide0 }}


slide_lines =: {{
  'd h t c' =. (depth;head;text;<@code) y
  r =. <(d#'*'),' ',h
  if. #>c do. r =. r,'#+begin_src j';c,<'#+end_src' end.
  r,t }}

NB. turn the arrays back into org text:
org_text =: {{ ;(,&LF)L:0 title,'';;slide_lines each i.#slides }}

head =: verb : '> (<y,0) { slides'  NB. -> str
text =: verb : '> (<y,1) { slides'  NB. -> [box(str)]
code =: verb : '> (<y,2) { slides'  NB. -> [box(str)]
depth=: verb : '> (<y,3) { slides'  NB. -> [box(str)]
