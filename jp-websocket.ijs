NB. minimal example for talking to JQt over a websocket
(1!:44)'d:/ver/jprez'
load'tangentstorm/j-kvm/vt'
gethw_vt_=:{{ 24 80 }}
load'jprez.ijs'

open ORG_PATH=:'d:/ver/j-talks/wip/dealing-cards/dealing-cards.org'
goix (hcur=:0), [ ccur=:0

port =: 4444

wssvr_handler_z_ =: {{
  NB. global handler for all websocket events
  'e sock' =: y
  if. e = jws_onMessage_jqtide_ do.  wss1_jrx_ on_wsmsg_base_ wss0_jrx_
  elseif. e = jws_onOpen_jqtide_ do. on_wsopen_base_''
  end. }}


ws_send =: {{ wd 'ws send ',(":sock),' *',":y }}
ws_state =: {{  wd 'ws state ',":sock }}

NB. echo websocket parameters (uri, port, etc) to console
on_wsopen =: {{  NB. smoutput ws_state''
  smoutput <'ws connected' }}


rebuild''

load'convert/pjson'
ischar_pjson_ =: (2 131072 262144 e.~ 3!:0)

make_vbuf =: {{
  if. 2=#y do. 'W__repl H__repl' =: y  end.
  buf=. tobuf__repl''
  res =. (;:'w h bgb fgb chb') ,. W__repl;H__repl;(;BGB__buf);(;FGB__buf);(;CHB__buf )
  codestroy__buf''
  res }}


NB. there's a bug in websockets with double quotes: https://github.com/jsoftware/jsource/issues/187
enc =: {{ (';';'<SEMI>')stringreplace enc_pjson_  y  }}
send_patch =: {{
  hcur=.cur [ ccur=.C__cmds [ chunks =.L__cmds [ heads =. heads
  code =. code cur  [ wpath =. wavpath''
  wps =. calc_wavpath each chunks
  vbuf =. make_vbuf''
  keys =. 'hcur ccur opath chunks heads code wpath wps vbuf'
  ws_send enc k,.". each k=.;:keys }}

apply_patch =: {{)v
  olds =. orgs
  for_row. dec_pjson_ y do. (k) =: v [ 'k v' =. row end.
  if. -. orgs  -: olds do.
    reorg orgs
    send_patch''
  else.
    goix hcur,ccur
  end. }}

on_wsmsg =: {{
  NB. ws_send y              NB. echo request back to the socket
  NB. smoutput y             NB. echo request payload to console
  smoutput 'msg:';y
  if. x -: 'text' do.    NB. what to do if x -: 'text'
    if. '.' = {. y do.
      NB. ".init main" is only message sent this way for now
      send_patch''
    else.
      apply_patch y
      send_patch''
    end.
  else.                  NB. what to do if x -: 'binary'
  end. }}

wd 'ws listen ',":port
