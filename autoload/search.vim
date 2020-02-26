" Search methods definitions

fu! search#NewGrepResult() abort
  return { "line_number": 0, "path": 0, "text": 0 }
endfu

fu! search#RunRgUsagesSearch(language, keyword) abort
  let cmd          = "rg -n --pcre2 --json -t " . a:language . ' -w ' . a:keyword
  let raw_results  = system(cmd)
  let grep_results = s:ParseRgResults(raw_results)

  return grep_results
endfu

fu! search#RunRgDefinitionSearch(language, patterns) abort
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

          let grep_result             = search#NewGrepResult()
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


fu! search#SearchUsages(internal_buffer) abort
  let grep_results = call search#RunRgUsagesSearch(a:internal_buffer.language, a:internal_buffer.keyword)

  return grep_results
endfu

fu! search#SearchDefinitions(lang, keyword) abort
  let patterns = []
  let lang     = lang_map#find_definitions(a:lang)

  for rule in lang
    let regexp = substitute(rule.pcre2_regexp, "KEYWORD", a:keyword, "g")
    call add(patterns, regexp)
  endfor

  let regexp = map(patterns, { _, pattern -> '(' . pattern . ')' })
  let regexp = join(regexp, '|')
  let regexp = "\"(" . regexp . ")\""

  let grep_results = search#RunRgDefinitionSearch(a:lang, regexp)

  return grep_results
endfu
