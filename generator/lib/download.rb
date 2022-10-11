require 'http'

class Download
  URL = 'https://raw.githubusercontent.com/jacktasia/dumb-jump/master/dumb-jump.el'
  PARSE_PATTERNS = {
    head: '(defcustom dumb-jump-find-rules',
    tail: '"List of regex patttern templates'
  }

  def call
    result = ""
    scp    = HTTP.get(URL).to_s
    head   = scp.index(PARSE_PATTERNS[:head])
    tail   = scp.index(PARSE_PATTERNS[:tail])

    # 1. get body
    extracted = scp[head,tail - head]

    # 2. remove definition start
    extracted.sub!(PARSE_PATTERNS[:head], '')

    # 3. remove whitespaces and some syntax elements
    extracted.strip!
    extracted.sub!(/^'\(\(/, '((')

    # 4. remove tabulation
    extracted.each_line do |line|
      result << if line[0,2] == "  "
        line[2, line.size - 2]
      else
        line
      end
    end

    return result
  end
end
