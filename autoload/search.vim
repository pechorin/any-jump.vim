" Search methods definitions

"
" --- Public api ---
"

let s:regexp_keyword_word = 'KEYWORD'
let s:engines             = ['rg', 'ag']

fu! search#SearchUsages(internal_buffer) abort
  if g:any_jump_search_prefered_engine == 'rg'
    let grep_results = s:RunRgUsagesSearch(a:internal_buffer.language, a:internal_buffer.keyword)
  elseif g:any_jump_search_prefered_engine == 'ag'
    let grep_results = s:RunAgUsagesSearch(a:internal_buffer.language, a:internal_buffer.keyword)
  end

  return grep_results
endfu

fu! search#SearchDefinitions(lang, keyword) abort
  let patterns      = []
  let lang          = lang_map#find_definitions(a:lang)
  let search_engine = g:any_jump_search_prefered_engine

  if index(lang[0].supports, search_engine) == -1
    let search_engine = (search_engine == 'rg' ? 'ag' : 'rg')
  endif

  for rule in lang
    let regexp = substitute(rule.pcre2_regexp, s:regexp_keyword_word, a:keyword, "g")
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

fu! search#RunSearchEnginesSpecs()
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

fu! search#RunRegexpSpecs()
  let errors = []
  let passed = 0

  for lang in keys(lang_map#definitions())
    for entry in lang_map#definitions()[lang]
      let re = entry.pcre2_regexp
      let keyword = 'test'

      if len(re) > 0
        let test_re = substitute(re, 'KEYWORD', keyword, 'g')
        let error_exit_codes = {"spec_success": [1,2], "spec_failed": [0,2]}

        for spec_type in keys(error_exit_codes)
          for spec_string in entry[spec_type]
            for engine in s:engines
              if index(entry.supports, engine) == -1
                continue
              endif

              let cmd = 0

              if engine == 'rg'
                let cmd = "echo \"" . spec_string . "\" | rg --pcre2 --no-filename \"" . test_re . "\""
              end

              if engine == 'ag'
                let cmd = "echo \"" . spec_string . "\" | ag \"" . test_re . "\""
              endif

              let raw_results = system(cmd)

              if index(error_exit_codes[spec_type], v:shell_error) >= 0
                call add(errors, "FAILED -- " . spec_type . ' ' . string(raw_results) . ' -- ' . lang  . " -- " . spec_string  . ' -- ' . test_re)
              else
                let passed += 1
              endif

            endfor
          endfor
        endfor
      endif

    endfor

    echo "lang " . lang . ' finished tests ' . passed
  endfor

  echo "passed tests: " . passed
  return errors
endfu

"
" --- Private api ---
"

fu! s:NewGrepResult() abort
  return { "line_number": 0, "path": 0, "text": 0 }
endfu

fu! s:RunRgUsagesSearch(language, keyword) abort
  let cmd          = "rg -n --pcre2 --json -t " . a:language . ' -w ' . a:keyword
  let raw_results  = system(cmd)
  let grep_results = s:ParseRgResults(raw_results)

  return grep_results
endfu

fu! s:RunRgDefinitionSearch(language, patterns) abort
  let cmd          = "rg -n --pcre2 --json -t " . a:language . ' ' . a:patterns
  let raw_results  = system(cmd)
  let grep_results = s:ParseRgResults(raw_results)

  return grep_results
endfu

fu! s:RunAgUsagesSearch(language, keyword) abort
  let cmd          = "ag --nogroup --noheading --" . a:language . ' -w ' . a:keyword
  let raw_results  = system(cmd)
  let grep_results = s:ParseAgResults(raw_results)

  return grep_results
endfu

fu! s:RunAgDefinitionSearch(language, patterns) abort
  let cmd          = "ag --nogroup --noheading --" . a:language . ' ' . a:patterns
  let raw_results  = system(cmd)
  let grep_results = s:ParseAgResults(raw_results)

  return grep_results
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

      let res         = split(line, ':')
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

