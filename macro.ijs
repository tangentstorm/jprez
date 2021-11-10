NB. macro editing widget
require 'tangentstorm/j-kvm/ui'
coinsert 'kvm'

coclass 'MacroWidget' extends 'UiEditWidget'

create =: {{
  create_UiEditWidget_ f. y
  O =: 0$a:  NB. observers
}}

register =: {{ O =: O,y }}

NB. rather than recording macros for *this* editor,
NB. we are editng a macro for *another* editor. To
NB. debug, we want to tell the other editor to play
NB. the macro up to this editor's cursor. Since we don't
NB. need logging for ourselves, we can override that to
NB. just tell the second editor (observer O) to play the
NB. macro up to the cursor.
log =: {{ for_o. O do. notify__o C {. B end. }}
