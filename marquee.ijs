NB. scratch code that makes a marquee / ticker tape display
NB. at some point I will clean this up and make it a base widget
NB. for j-kvm
cocurrent 'UiMarquee' extends 'UiWidget'

create =: {{
  'w s' =. y
  S =: ' _.,oO( )Oo,._ '"_ ^:(s-:'') s
  W =: w
  A =: 1
  T =: 0 NB. timer (in seconds)
  FPS =: 20  NB. frames per second
}}

update =: {{
 T =: T + y
 if. T > % FPS do.
   T =: 0 [ R=:1 [ S=:1|.S  NB. rotate the text
 end. }}

render =: {{
  bg _4 [ fg _9
  puts '['
  fg _15
  puts (W-2){. S
  fg _9
  puts']' }}

