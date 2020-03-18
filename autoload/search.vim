" Search methods

let s:regexp_keyword_word = 'KEYWORD'
let s:engines             = ['rg', 'ag']

let s:rg_base_cmd = "rg -n --auto-hybrid-regex --json"
let s:ag_base_cmd = "ag --nogroup --noheading"

let s:rg_filetype_convertion_map = {
      \"python":     "py",
      \"javascript": "js",
      \"typescript": "ts",
      \"commonlisp": "lisp",
      \"scss":       "css",
      \}

let s:ag_filetype_convertion_map = {
      \"javascript": "js",
      \"typescript": "ts",
      \"commonlisp": "lisp",
      \"scss":       "css",
      \}

let s:non_standard_ft_extensions_map = {
      \"coffeescript":  [ '\.cjs\$', '\.coffee\$', 'Cakefile', '\._coffee\$', '\.coffeekup$', '\.ck\$' ],
      \"coq":           [ '\.v\$' ],
      \"scad":          [ '\.scad\$' ],
      \"protobuf":      [ '\.proto\$' ],
      \"scss":          [ '\.scss\$' ],
      \"systemverilog": [ '\.sv\$', '\.svh\$' ],
      \"racket":        [ '\.rkt\$' ],
      \"scheme":        [ '\.scm\$', '\.ss\$', '\.sld\$' ],
      \"faust":         [ '\.dsp\$', '\.lib\$' ],
      \"pascal":        [ '\.pas\$', '\.dpr\$', '\.int\$', '\.dfm\$'  ],
      \"shell":         [ '\.sh\$', '\.bash\$', '\.csh\$', '\.ksh\$', '\.tcsh\$' ],
      \"haskell":       [ '\.hs\$', '\.lhs\$' ],
      \"dart":          [ '\.dart\$' ],
      \"zig":           [ '\.zig\$' ],
      \}

let s:filetypes_comments_map = {
      \"cpp":           ["//"],
      \"elisp":         [";"],
      \"commonlisp":    [";"],
      \"javascript":    ["//"],
      \"typescript":    ["//"],
      \"dart":          ["//"],
      \"haskell":       ["--"],
      \"lua":           ["--"],
      \"rust":          ["//"],
      \"julia":         ["#"] ,
      \"objc":          ["//"],
      \"csharp":        ["//"],
      \"java":          ["//"],
      \"clojure":       [";"] ,
      \"coffeescript":  ["#"] ,
      \"faust":         ["//"],
      \"fortran":       ["!"] ,
      \"go":            ["//"],
      \"perl":          ["#"] ,
      \"php":           ["//", "#"],
      \"python":        ["#"] ,
      \"matlab":        ["%"] ,
      \"r":             ["#"] ,
      \"racket":        [";"] ,
      \"ruby":          ["#"] ,
      \"crystal":       ["#"] ,
      \"nim":           ["#"] ,
      \"nix":           ["#"] ,
      \"scala":         ["//"],
      \"scheme":        [";"] ,
      \"shell":         ["#"] ,
      \"swift":         ["//"],
      \"elixir":        ["#"] ,
      \"erlang":        ["%"] ,
      \"tex":           ["%"] ,
      \"systemverilog": ["//"],
      \"vhdl":          ["--"],
      \"scss":          ["//"],
      \"pascal":        ["//"],
      \"protobuf":      ["//"],
      \"zig":           ["//"],
      \}

" Compiled expressions to avoid recompilation
let s:non_standard_ft_extensions_map_compiled = {}
let s:filetypes_comments_map_compiled         = {}

" Do compilation
for lang in keys(s:non_standard_ft_extensions_map)
  let rules  = s:non_standard_ft_extensions_map[lang]
  let regexp = map(rules, { _, pattern -> '(' . pattern . ')' })
  let regexp = join(regexp, '|')
  let regexp = "\"(" . regexp . ")\""

  let s:non_standard_ft_extensions_map_compiled[lang] = regexp
endfor

for lang in keys(s:filetypes_comments_map)
  let rules = s:filetypes_comments_map[lang]
  let compiled_rules = map(copy(rules), "'^\s*' . v:val")
  let s:filetypes_comments_map_compiled[lang] = compiled_rules
endfor

" End of compilation

fu! s:GetRgFiletype(lang) abort
  if has_key(s:rg_filetype_convertion_map, a:lang)
    return s:rg_filetype_convertion_map[a:lang]
  else
    return a:lang
  endif
endfu

fu! s:GetAgFiletype(lang) abort
  if has_key(s:ag_filetype_convertion_map, a:lang)
    return s:ag_filetype_convertion_map[a:lang]
  else
    return a:lang
  endif
endfu

fu! search#GetSearchEngineFileTypeSpecifier(engine, language) abort
  let cmd = 0

  if has_key(s:non_standard_ft_extensions_map_compiled, a:language)
    if a:engine == 'rg'
      let file_lists_cmd = 'rg --files | rg ' . s:non_standard_ft_extensions_map_compiled[a:language]
      let files = split(system(file_lists_cmd), "\n")
      let cmd   = join(map(files, {_,fname -> ('-f ' . fname)}), ' ')
    elseif a:engine == 'ag'
      let cmd = '-G ' . s:non_standard_ft_extensions_map_compiled[a:language]
    endif
  else
    if a:engine == 'rg'
      let cmd = '-t ' . s:GetRgFiletype(a:language)
    elseif a:engine == 'ag'
      let cmd = '--' . s:GetAgFiletype(a:language)
    endif
  endif

  return cmd
endfu

fu! s:GetRgIgnoreSpecifier() abort
  let result = ''

  if g:any_jump_disable_vcs_ignore
    let result .= " --no-ignore-vcs"
  endif

  for glob in g:any_jump_ignored_files
    let result = result . ' -g !' . string(glob)
  endfor

  return result
endfu

fu! s:GetAgIgnoreSpecifier() abort
  let result = ''

  if g:any_jump_disable_vcs_ignore
    let result .= " --skip-vcs-ignores"
  endif

  for glob in g:any_jump_ignored_files
    let result = result . ' --ignore ' . string(glob)
  endfor

  return result
endfu

fu! search#GetCurrentSearchEngine() abort
  let search_engine = g:any_jump_search_prefered_engine
  let engine_ok     = executable(search_engine)

  if !engine_ok
    let search_engine = search_engine == 'rg' ? 'ag' : 'rg'
  endif

  return search_engine
endfu

fu! search#SearchUsages(internal_buffer) abort
  let search_engine = search#GetCurrentSearchEngine()

  if search_engine == 'rg'
    let grep_results = s:RunRgUsagesSearch(a:internal_buffer.language, a:internal_buffer.keyword)
  elseif search_engine == 'ag'
    let grep_results = s:RunAgUsagesSearch(a:internal_buffer.language, a:internal_buffer.keyword)
  end

  return grep_results
endfu

fu! search#SearchDefinitions(lang, keyword) abort
  let patterns      = []
  let lang          = lang_map#find_definitions(a:lang)
  let search_engine = search#GetCurrentSearchEngine()

  " if lang regexp doesn't support prefered search engine
  if index(lang[0].supports, search_engine) == -1
    " try to change selected engine
    let search_engine = (search_engine == 'rg' ? 'ag' : 'rg')

    " end error of changed engine not installed
    if !executable(search_engine)
      echoe "please install " . search_engine . " to run " . a:lang . " any-jump.vim search"
    endif

    return 0
  endif

  for rule in lang
    let regexp = substitute(rule.pcre2_regexp, s:regexp_keyword_word, a:keyword, "g")

    if match(&shell, 'fish') != -1
      let regexp = substitute(regexp, '\$', '\\$', 'g')
    endif

    call add(patterns, regexp)
  endfor

  let regexp = map(patterns, { _, pattern -> '(' . pattern . ')' })
  let regexp = join(regexp, '|')
  let regexp = "\"(" . regexp . ")\""

  if search_engine == 'rg'
    let grep_results = s:RunRgDefinitionSearch(a:lang, regexp)
  elseif search_engine == 'ag'
    let grep_results = s:RunAgDefinitionSearch(a:lang, regexp)
  end

  return grep_results
endfu

fu! search#RunSearchEnginesSpecs() abort
  let errors = []

  let has_rg = executable('rg')
  let has_ag = executable('ag')

  if !(has_rg || has_ag)
    let error = "rg or ag executable not found"
    echoe error

    call add(errors, error)
  endif

  return errors
endfu

fu! search#RunRegexpSpecs() abort
  let errors = []
  let passed = 0
  let failed = 0

  for lang in keys(lang_map#definitions())
    let lang_passed = 0
    let lang_failed = 0

    for entry in lang_map#definitions()[lang]
      let re = entry.pcre2_regexp
      let keyword = 'test'

      if len(re) > 0
        let test_re = substitute(re, 'KEYWORD', keyword, 'g')
        let invalid_exist_statues = {"spec_success": [1,2], "spec_failed": [0,2]}
        let spec_types = keys(invalid_exist_statues)

        for spec_type in spec_types
          for spec_string in entry[spec_type]
            for engine in s:engines
              if index(entry.supports, engine) == -1
                continue
              endif

              let cmd = 0
              let ft_args = search#GetSearchEngineFileTypeSpecifier(engine, lang)

              if engine == 'rg'
                let rg_ft = s:GetRgFiletype(lang)
                let cmd   = "echo \"" . spec_string . "\" | "
                      \ . s:rg_base_cmd .  " --no-filename  "
                      \ . ft_args . " \"" . test_re . "\""
              end

              if engine == 'ag'
                let ag_ft = s:GetAgFiletype(lang)
                let cmd   = "echo \"" . spec_string . "\" | "
                      \ . s:ag_base_cmd . " " . ft_args . " \""
                      \ . test_re . "\""
              endif

              let raw_results = system(cmd)

              if index(invalid_exist_statues[spec_type], v:shell_error) != -1
                call add(errors, 'FAILED ' . engine . ' ' . lang . ' ' . spec_type . ' -- result: ' . string(raw_results) . "; spec: " . string(spec_string)  . '; re: ' . string(test_re))
                let lang_failed += 1
              else
                let lang_passed += 1
              endif

            endfor
          endfor
        endfor
      endif

    endfor

    echo "lang " . lang . ' finished  success:' . lang_passed . ' failed: ' . lang_failed
  endfor

  return errors
endfu

"
" --- Private api ---
"

fu! s:NewGrepResult() abort
  return { "line_number": 0, "path": 0, "text": 0 }
endfu

fu! s:RunRgDefinitionSearch(language, patterns) abort
  let rg_ft = s:GetRgFiletype(a:language)

  let cmd = s:rg_base_cmd . ' -t ' . rg_ft
  let cmd = cmd . s:GetRgIgnoreSpecifier()
  let cmd = cmd . ' ' . a:patterns

  let raw_results  = system(cmd)
  let grep_results = s:ParseRgResults(raw_results)
  let grep_results = s:FilterGrepResults(a:language, grep_results)

  return grep_results
endfu

fu! s:RunAgDefinitionSearch(language, patterns) abort
  let ag_ft = s:GetAgFiletype(a:language)

  let cmd = s:ag_base_cmd . ' --' . ag_ft
  let cmd = cmd . s:GetAgIgnoreSpecifier()
  let cmd = cmd . ' ' . a:patterns

  let raw_results  = system(cmd)
  let grep_results = s:ParseAgResults(raw_results)
  let grep_results = s:FilterGrepResults(a:language, grep_results)

  return grep_results
endfu

fu! s:RunRgUsagesSearch(language, keyword) abort
  let kw = a:keyword
  let kw = substitute(kw, "\-", "\\\\-", "g") " shell escape

  let cmd = s:rg_base_cmd . ' -w ' . string(kw)
  let cmd = cmd . s:GetRgIgnoreSpecifier()

  if g:any_jump_references_only_for_current_filetype
        \ && type(a:language) == v:t_string

    let rg_ft = s:GetRgFiletype(a:language)
    let cmd   = cmd . ' -t ' . rg_ft
  endif

  let raw_results  = system(cmd)
  let grep_results = s:ParseRgResults(raw_results)
  let grep_results = s:FilterGrepResults(a:language, grep_results)

  return grep_results
endfu

fu! s:RunAgUsagesSearch(language, keyword) abort
  let cmd = s:ag_base_cmd . ' -w ' . string(a:keyword)
  let cmd = cmd . s:GetAgIgnoreSpecifier()

  if g:any_jump_references_only_for_current_filetype
        \ && type(a:language) == v:t_string

    let ag_ft = s:GetAgFiletype(a:language)
    let cmd   = cmd . ' --' . ag_ft
  endif

  let raw_results  = system(cmd)

  let grep_results = s:ParseAgResults(raw_results)
  let grep_results = s:FilterGrepResults(a:language, grep_results)

  return grep_results
endfu

fu! s:FilterGrepResults(language, grep_results) abort
  if type(a:language) != v:t_string
    return a:grep_results
  endif

  if g:any_jump_remove_comments_from_results
        \ && has_key(s:filetypes_comments_map_compiled, a:language)

    let filtered = copy(a:grep_results)

    for comment_pattern in s:filetypes_comments_map_compiled[a:language]
      call filter(filtered, 'v:val.text !~# comment_pattern')
    endfor

    return filtered
  else
    return a:grep_results
  endif
endfu

fu! s:ParseRgResults(raw_results) abort
  let grep_results = []

  if len(a:raw_results) > 0
    let matches = []

    for res in split(a:raw_results, "\n")
      let match = json_decode(res)
      call add(matches, match)
    endfor

    for match in matches
      if get(match, 'type') == 'match'
        let data = get(match, 'data')

        if type(data) == v:t_dict
          let text = data.lines.text
          let text = substitute(text, '^\s*', '', 'g')
          let text = substitute(text, '\n', '', 'g')

          let grep_result             = s:NewGrepResult()
          let grep_result.line_number = data.line_number
          let grep_result.path        = data.path.text
          let grep_result.text        = text

          call add(grep_results, grep_result)
        endif
      endif
    endfor
  endif

  return grep_results
endfu

fu! s:ParseAgResults(raw_results) abort
  let grep_results = []

  if len(a:raw_results) > 0
    let matches = []

    for line in split(a:raw_results, "\n")
      if len(line) == 0
        continue
      endif

      let max_splits = 3
      let head = 0
      let tail = line
      let res  = []

      while len(tail) != 0
        let midx = match(tail, ':')

        if midx >= 0 && len(res) != (max_splits - 1)
          let head = tail[0 : midx - 1]
          let tail = tail[midx + 1 : -1]

          call add(res, head)
        else
          call add(res, tail)
          let tail = ''
        endif
      endwhile

      let grep_result = s:NewGrepResult()

      if len(res) != 3
        continue
      endif

      let grep_result.line_number = res[1]
      let grep_result.path        = res[0]
      let grep_result.text        = substitute(res[2], '^\s*', '', '')

      call add(grep_results, grep_result)
    endfor
  endif

  return grep_results
endfu
