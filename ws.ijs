load 'net/websocket'

NB. make websocket server non-blocking.
NB. combined with ws_onstep, this will allow us to
NB. run the j-kvm loop 'inside' the websocket event
NB. loop.
WaitTimeout_jws_ =: 0.2

{{ NB. monkeypatch initrun_jws_
  src =. '-'
  oldsrc =. (5!:5)<f=.'initrun_jws_'
  lines  =. LF cut CR -.~ oldsrc
  NB. find position of the start of while loop
  pos    =. 1 + lines i. <'while. loop do.'
  src =. lines#~1+pos=i.#lines
  NB. insert this new line at the position:
  src =. (<'  ws_onstep _') pos } src
  src =. '{{)m', LF, '}}',~ LF joinstring }.}: src
  src =. '(>a:)`',f, ' =: ', src
  ". src
  0
}}''

OLDT_jws_=:0
ws_onstep_jws_ =: {{ if. 0.2<:(t=.6!:1'')-OLDT do. echo <.OLDT=:t end.}}

ws_onmessage_jws_ =: {{
  logcmd y
  echo 'in here. encoding:'
  echo encoding
  r =. ''
  if. encoding=2 do. NB. "binary" message
    echo y
    if. y -: 'stop!' do. interrupt_jws_'' end.
    if. y -: 'STOP!' do. shutdown_jws_'' end.
    r =. |.y
  else. end. NB. (TODO: encoding=1 for text message)
  ws_send r
}}


9!:27 'init_jws_ 8081 0'
9!:29]1
