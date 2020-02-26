" Search methods definitions

"
" --- Public api ---
"

let g:any_jump_regexp_keyword_word = 'KEYWORD'

fu! search#SearchUsages(internal_buffer) abort
  let grep_results = call s:RunRgUsagesSearch(a:internal_buffer.language, a:internal_buffer.keyword)

  return grep_results
endfu

fu! search#SearchDefinitions(lang, keyword) abort
  let patterns = []
  let lang     = lang_map#find_definitions(a:lang)

  for rule in lang
    let regexp = substitute(rule.pcre2_regexp, g:any_jump_regexp_keyword_word, a:keyword, "g")
    call add(patterns, regexp)
  endfor

  let regexp = map(patterns, { _, pattern -> '(' . pattern . ')' })
  let regexp = join(regexp, '|')
  let regexp = "\"(" . regexp . ")\""

  let grep_results = s:RunRgDefinitionSearch(a:lang, regexp)

  return grep_results
endfu

fu! search#RunRegexpSpecs()
  let errors = []
  let passed = 0

  " FIXME:
  " haskell supports only ag (add ag support) ?

  " add auto shell escape for \$ to \\\$

  for lang in keys(lang_map#definitions())
    for entry in lang_map#definitions()[lang]
      let re = entry["pcre2_regexp"]
      let keyword = (lang == 'haskell' ? 'Test' : 'test')

      if len(re) > 0
        let test_re = substitute(re, 'KEYWORD', keyword, 'g')

        for spec_string in entry["spec_success"]
          let cmd = "echo \"" . spec_string . "\" | rg -N --pcre2 --no-filename \"" . test_re . "\""
          " echo 'cmd -> ' . string(cmd)
          let raw_results = system(cmd)

          if v:shell_error == 2 || v:shell_error == 1
            call add(errors, "FAILED success-spec -- " . string(raw_results) . ' -- ' . lang  . " -- " . spec_string  . ' -- ' . test_re)
          else
            let passed += 1
          endif
        endfo

        for spec_string in entry["spec_failed"]
          let cmd = "echo \'" . spec_string . "\' | rg -N --pcre2 --no-filename \"" . test_re . "\""
          let raw_results = system(cmd)

          if v:shell_error == 0 || v:shell_error == 2
            call add(errors, "FAILED failed-spec -- " . string(raw_results)  . ' -- ' . lang . ' -- ' . spec_string . ' -- ' . test_re)
          else
            let passed += 1
          endif

        endfor

      endif

    endfor
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
      end
    endfor
  endif

  return grep_results
endfu

