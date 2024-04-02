NB. program to write a jprez file to a sqlite database.
NB. the schema is not (yet?) public as of this writing so
NB. this file is probably not useful to anyone else
NB. without major modifications.
load 'jprez.ijs'
load 'data/sqlite'


NB. --- additions to api.ijs in data/sqlite
cocurrent'psqlite'

NB. https://sqlite.org/c3ref/db_config.html
NB. int sqlite3_db_config(sqlite3*, int op, ...);
NB. !! this is a variadic function. not sure how to handle with cd
NB.    but I only need to pass in two arguments...
lib=. '"',libsqlite,'"'
sqlite3_db_config=:(lib,' sqlite3_db_config > ',(IFWIN#'+'),' i x i i i') &cd


NB. https://sqlite.org/c3ref/load_extension.html
NB. int sqlite3_load_extension(*db, *zFile, *zProc, **pzErrMsg)
NB.  x   sqlite3 *db,          /* Load the extension into this database connection */
NB. *c   const char *zFile,    /* Name of the shared library containing extension */
NB. *c   const char *zProc,    /* Entry point.  Derived from zFile if 0 */
NB. *x   char **pzErrMsg       /* Put error message here if not 0 */
sqlite3_load_extension=:(lib,' sqlite3_load_extension > ',(IFWIN#'+'),' i x &c x *x  ')&cd

NB. https://sqlite.org/c3ref/c_dbconfig_defensive.html
SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION =: 1005
NB. https://sqlite.org/c3ref/load_extension.html
sqlconfig =: {{ sqlite3_db_config CH;y }}
sqlload =: {{
  flag =.SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION_psqlite_
  sqlconfig flag;1;0
  sqlite3_load_extension CH;y;0;,0 }}
cocurrent'base'


db =: sqlopen_psqlite_'/home/michal/db/tree.sdb'
sqlload__db '/home/michal/db/define'

MAX =: ->: NIL =: SQLITE_NULL_INTEGER_psqlite_
tree_ins =: {{ sqlinsert__db '_tree';(;:'pi ix t v');<y }}
ltri =: {{ sqlexec__db'select json_extract(kv,"$.tri")from":en"where en=":tr"'}}
lni =: {{ sqlexec__db'select json_extract(kv,"$.ni")from":en"where en=":tr"'}}

INT=: 1 [ NUM=: 2 [ TEXT=: 3 [ BLOB=: 4

pi =: TOP =: 0
stack =: ,a:
node =: {{ pi =: ltri'' [ stack =: stack,<pi }}
item =: {{tree_ins  pi;MAX ;(<x);(<y) }}
noix =: {{tree_ins  pi;NIL ;(<x);(<y) }}
attr =: {{
  s=.  'update ":no" set a=json_set(coalesce(a,"{}"),"$.',x,'",?) '
  s=.s,'where id=(select json_extract(kv,"$.ni") from ":en" where en=":tr")'
  sqlparm__db s;(,TEXT);(,<y) }}
  done =: {{ stack=:}:stack [ pi=:>{:stack }}


imp_org =: {{
  echo 'imp_org';y
  assert. (pi = TOP), stack-:,a:
  'f p' =. (>@{: ; '/' joinstring '';3 }. }:) '/'splitstring y
  node 'org' noix f
  'path' attr p
  echo 'pi:'; pi =: ltri''
  d =: 0 [ open y
  for_i. i.#heads do.
    goix i,0
    while. (depth cur) <: d do.  done [ d=: d - 1 end.
    node 'hdl' item head cur  [ d =: d + 1
    if. #c =. LF joinstring code cur do. 'src' item c end.
    for_row. (text cur)-.a: do. s=.>row
      if. ': . ' -: 4 {. s do. 'mac' item s
      elseif. ': '-: 2 {. s do. 'cmd' item s
      elseif. '#'=0{s do. 'rem' item s
      elseif. '@'=0{s do. 'anm' item s
      else. 'txt' item s end.
    end.
  end.
  echo 'done with';y;'depth:';d
  done^:(d+1)''}}

{{
  vid =: sqlopen_psqlite_'/home/michal/db/videos.sdb'
  dat =: sqlread__vid 'select path||''/''||name as p from wip where p like ''%org'''
  for_p0. (1;0){::dat do.
    echo p =. ('/home/michal',>p0)
    imp_org p
  end.
}}''