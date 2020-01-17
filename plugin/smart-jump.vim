" POINTS:
" - async load of additional searches
"   start async requests after some timeout of main rg request
"
"   is it possible to run async in vim?

" NOTES:
" - all language regexps ported from https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el

let g:smart_jump_loaded = 1

" ----------------------------------------------
" Languages definitions

let s:lang_map = {}

" Ruby
let s:lang_map.ruby = []

" Why foo_test = 1234 is a mismatch?
call add(s:lang_map.ruby, {
      \"type": "variable",
      \"regexp": "",
      \"emacs_regexp": "^\\s*((\\w+[.])*\\w+,\\s*)*JJJ(,\\s*(\\w+[.])*\\w+)*\\s*=([^=>~]|$)",
      \"match_tests": ["test = 1234", "self.foo, test, bar = args"],
      \"mismtach_tests": ["if test == 1234", "foo_test = 1234"],
      \})

" ----------------------------------------------
" Service functions

let s:debug = 1

function! g:SmartJumpDebug()
  if s:debug == 0
    let s:debug = 1
  else
    let s:debug = 0
  endif
endfunction

function! s:Log(message)
  if s:debug == 1
    echo "[smart-jump] " . message
  endif
endfunction

" ----------------------------------------------
" Functions

function! g:Current_filetype_lang_map()
  let ft = &l:filetype

  if ft
    return s:langmap[ft]
  else
    echo "not found map definition for " . ft
    return 0
  endif
endfunction

