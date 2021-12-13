" NOTES:
" - all language regexps ported from https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el

let s:definitions = {}

fu! s:add_definition(lang, definition) abort
  if !has_key(s:definitions, a:lang)
    let s:definitions[a:lang] = []
  endif

  call add(s:definitions[a:lang], a:definition)
endfu

fu! lang_map#find_definitions(language) abort
  if !lang_map#lang_exists(a:language)
    return
  endif

  return s:definitions[a:language]
endfu

fu! lang_map#definitions() abort
  return s:definitions
endfu

fu! lang_map#lang_exists(language) abort
  return has_key(s:definitions, a:language)
endfu

call s:add_definition('elisp', {
	\"type": 'function',
	\"pcre2_regexp": '\((defun|cl-defun)\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\((defun|cl-defun)\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defun test (blah)","(defun test\n","(cl-defun test (blah)","(cl-defun test\n"],
	\"spec_failed": ["(defun test-asdf (blah)","(defun test-blah\n","(cl-defun test-asdf (blah)","(cl-defun test-blah\n","(defun tester (blah)","(defun test? (blah)","(defun test- (blah)"],
	\})

call s:add_definition('elisp', {
	\"type": 'variable',
	\"pcre2_regexp": '\(defvar\b\s*KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defvar\b\s*JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defvar test ","(defvar test\n"],
	\"spec_failed": ["(defvar tester","(defvar test?","(defvar test-"],
	\})

call s:add_definition('elisp', {
	\"type": 'variable',
	\"pcre2_regexp": '\(defcustom\b\s*KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defcustom\b\s*JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defcustom test ","(defcustom test\n"],
	\"spec_failed": ["(defcustom tester","(defcustom test?","(defcustom test-"],
	\})

call s:add_definition('elisp', {
	\"type": 'variable',
	\"pcre2_regexp": '\(setq\b\s*KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(setq\b\s*JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(setq test 123)"],
	\"spec_failed": ["setq test-blah 123)","(setq tester","(setq test?","(setq test-"],
	\})

call s:add_definition('elisp', {
	\"type": 'variable',
	\"pcre2_regexp": '\(KEYWORD\s+',
	\"emacs_regexp": '\(JJJ\s+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(let ((test 123)))"],
	\"spec_failed": ["(let ((test-2 123)))"],
	\})

call s:add_definition('elisp', {
	\"type": 'variable',
	\"pcre2_regexp": '\((defun|cl-defun)\s*.+\(?\s*KEYWORD($|[^a-zA-Z0-9\?\*-])\s*\)?',
	\"emacs_regexp": '\((defun|cl-defun)\s*.+\(?\s*JJJ\j\s*\)?',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["(defun blah (test)","(defun blah (test blah)","(defun (blah test)"],
	\"spec_failed": ["(defun blah (test-1)","(defun blah (test-2 blah)","(defun (blah test-3)"],
	\})

call s:add_definition('commonlisp', {
	\"type": 'function',
	\"pcre2_regexp": '\(defun\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defun\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defun test (blah)","(defun test\n"],
	\"spec_failed": ["(defun test-asdf (blah)","(defun test-blah\n","(defun tester (blah)","(defun test? (blah)","(defun test- (blah)"],
	\})

call s:add_definition('commonlisp', {
	\"type": 'variable',
	\"pcre2_regexp": '\(defparameter\b\s*KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defparameter\b\s*JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defparameter test ","(defparameter test\n"],
	\"spec_failed": ["(defparameter tester","(defparameter test?","(defparameter test-"],
	\})

call s:add_definition('racket', {
	\"type": 'function',
	\"pcre2_regexp": '\(define\s+\(\s*KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(define\s+\(\s*JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(define (test blah)","(define (test\n"],
	\"spec_failed": ["(define test blah","(define (test-asdf blah)","(define test (lambda (blah"],
	\})

call s:add_definition('racket', {
	\"type": 'function',
	\"pcre2_regexp": '\(define\s+KEYWORD\s*\(\s*lambda',
	\"emacs_regexp": '\(define\s+JJJ\s*\(\s*lambda',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(define test (lambda (blah","(define test (lambda\n"],
	\"spec_failed": ["(define test blah","(define test-asdf (lambda (blah)","(define (test)","(define (test blah) (lambda (foo"],
	\})

call s:add_definition('racket', {
	\"type": 'function',
	\"pcre2_regexp": '\(let\s+KEYWORD\s*(\(|\[)*',
	\"emacs_regexp": '\(let\s+JJJ\s*(\(|\[)*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(let test ((blah foo) (bar bas))","(let test\n","(let test [(foo"],
	\"spec_failed": ["(let ((test blah"],
	\})

call s:add_definition('racket', {
	\"type": 'variable',
	\"pcre2_regexp": '\(define\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(define\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(define test ","(define test\n"],
	\"spec_failed": ["(define (test"],
	\})

call s:add_definition('racket', {
	\"type": 'variable',
	\"pcre2_regexp": '(\(|\[)\s*KEYWORD\s+',
	\"emacs_regexp": '(\(|\[)\s*JJJ\s+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(let ((test 'foo","(let [(test 'foo","(let [(test 'foo","(let [[test 'foo","(let ((blah 'foo) (test 'bar)"],
	\"spec_failed": ["{test foo"],
	\})

call s:add_definition('racket', {
	\"type": 'variable',
	\"pcre2_regexp": '\(lambda\s+\(?[^()]*\s*KEYWORD($|[^a-zA-Z0-9\?\*-])\s*\)?',
	\"emacs_regexp": '\(lambda\s+\(?[^()]*\s*JJJ\j\s*\)?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(lambda (test)","(lambda (foo test)","(lambda test (foo)"],
	\"spec_failed": ["(lambda () test"],
	\})

call s:add_definition('racket', {
	\"type": 'variable',
	\"pcre2_regexp": '\(define\s+\([^()]+\s*KEYWORD($|[^a-zA-Z0-9\?\*-])\s*\)?',
	\"emacs_regexp": '\(define\s+\([^()]+\s*JJJ\j\s*\)?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(define (foo test)","(define (foo test bar)"],
	\"spec_failed": ["(define foo test","(define (test foo","(define (test)"],
	\})

call s:add_definition('racket', {
	\"type": 'type',
	\"pcre2_regexp": '\(struct\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(struct\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(struct test (a b)"],
	\"spec_failed": [],
	\})

call s:add_definition('scheme', {
	\"type": 'function',
	\"pcre2_regexp": '\(define\s+\(\s*KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(define\s+\(\s*JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(define (test blah)","(define (test\n"],
	\"spec_failed": ["(define test blah","(define (test-asdf blah)","(define test (lambda (blah"],
	\})

call s:add_definition('scheme', {
	\"type": 'function',
	\"pcre2_regexp": '\(define\s+KEYWORD\s*\(\s*lambda',
	\"emacs_regexp": '\(define\s+JJJ\s*\(\s*lambda',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(define test (lambda (blah","(define test (lambda\n"],
	\"spec_failed": ["(define test blah","(define test-asdf (lambda (blah)","(define (test)","(define (test blah) (lambda (foo"],
	\})

call s:add_definition('scheme', {
	\"type": 'function',
	\"pcre2_regexp": '\(let\s+KEYWORD\s*(\(|\[)*',
	\"emacs_regexp": '\(let\s+JJJ\s*(\(|\[)*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(let test ((blah foo) (bar bas))","(let test\n","(let test [(foo"],
	\"spec_failed": ["(let ((test blah"],
	\})

call s:add_definition('scheme', {
	\"type": 'variable',
	\"pcre2_regexp": '\(define\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(define\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(define test ","(define test\n"],
	\"spec_failed": ["(define (test"],
	\})

call s:add_definition('scheme', {
	\"type": 'variable',
	\"pcre2_regexp": '(\(|\[)\s*KEYWORD\s+',
	\"emacs_regexp": '(\(|\[)\s*JJJ\s+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(let ((test 'foo","(let [(test 'foo","(let [(test 'foo","(let [[test 'foo","(let ((blah 'foo) (test 'bar)"],
	\"spec_failed": ["{test foo"],
	\})

call s:add_definition('scheme', {
	\"type": 'variable',
	\"pcre2_regexp": '\(lambda\s+\(?[^()]*\s*KEYWORD($|[^a-zA-Z0-9\?\*-])\s*\)?',
	\"emacs_regexp": '\(lambda\s+\(?[^()]*\s*JJJ\j\s*\)?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(lambda (test)","(lambda (foo test)","(lambda test (foo)"],
	\"spec_failed": ["(lambda () test"],
	\})

call s:add_definition('scheme', {
	\"type": 'variable',
	\"pcre2_regexp": '\(define\s+\([^()]+\s*KEYWORD($|[^a-zA-Z0-9\?\*-])\s*\)?',
	\"emacs_regexp": '\(define\s+\([^()]+\s*JJJ\j\s*\)?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(define (foo test)","(define (foo test bar)"],
	\"spec_failed": ["(define foo test","(define (test foo","(define (test)"],
	\})

call s:add_definition('c++', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD(\s|\))*\((\w|[,&*.<>]|\s)*(\))\s*(const|->|\{|$)|typedef\s+(\w|[(*]|\s)+KEYWORD(\)|\s)*\(',
	\"emacs_regexp": '\bJJJ(\s|\))*\((\w|[,&*.<>]|\s)*(\))\s*(const|->|\{|$)|typedef\s+(\w|[(*]|\s)+JJJ(\)|\s)*\(',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["int test(){","my_struct (*test)(int a, int b){","auto MyClass::test ( Builder& reference, ) -> decltype( builder.func() ) {","int test( int *random_argument) const {","test::test() {","typedef int (*test)(int);"],
	\"spec_failed": ["return test();)","int test(a, b);","if( test() ) {","else test();"],
	\})

call s:add_definition('c++', {
	\"type": 'variable',
	\"pcre2_regexp": '(\b\w+|[,>])([*&]|\s)+KEYWORD\s*(\[([0-9]|\s)*\])*\s*([=,){;]|:\s*[0-9])|#define\s+KEYWORD\b',
	\"emacs_regexp": '(\b\w+|[,>])([*&]|\s)+JJJ\s*(\[([0-9]|\s)*\])*\s*([=,){;]|:\s*[0-9])|#define\s+JJJ\b',
	\"supports": ["grep"],
	\"spec_success": ["int test=2;","char *test;","int x = 1, test = 2","int test[20];","#define test","unsigned int test:2;"],
	\"spec_failed": [],
	\})

call s:add_definition('c++', {
	\"type": 'variable',
	\"pcre2_regexp": '\b(?!(class\b|struct\b|return\b|else\b|delete\b))(\w+|[,>])([*&]|\s)+KEYWORD\s*(\[(\d|\s)*\])*\s*([=,(){;]|:\s*\d)|#define\s+KEYWORD\b',
	\"emacs_regexp": '\b(?!(class\b|struct\b|return\b|else\b|delete\b))(\w+|[,>])([*&]|\s)+JJJ\s*(\[(\d|\s)*\])*\s*([=,(){;]|:\s*\d)|#define\s+JJJ\b',
	\"supports": ["ag", "rg"],
	\"spec_success": ["int test=2;","char *test;","int x = 1, test = 2","int test[20];","#define test","typedef int test;","unsigned int test:2"],
	\"spec_failed": ["return test;","#define NOT test","else test=2;"],
	\})

call s:add_definition('c++', {
	\"type": 'type',
	\"pcre2_regexp": '\b(class|struct|enum|union)\b\s*KEYWORD\b\s*(final\s*)?(:((\s*\w+\s*::)*\s*\w*\s*<?(\s*\w+\s*::)*\w+>?\s*,*)+)?((\{|$))|}\s*KEYWORD\b\s*;',
	\"emacs_regexp": '\b(class|struct|enum|union)\b\s*JJJ\b\s*(final\s*)?(:((\s*\w+\s*::)*\s*\w*\s*<?(\s*\w+\s*::)*\w+>?\s*,*)+)?((\{|$))|}\s*JJJ\b\s*;',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["typedef struct test {","enum test {","} test;","union test {","class test final: public Parent1, private Parent2{","class test : public std::vector<int> {"],
	\"spec_failed": ["union test var;","struct test function() {"],
	\})

call s:add_definition('clojure', {
	\"type": 'variable',
	\"pcre2_regexp": '\(def\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(def\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(def test (foo)"],
	\"spec_failed": [],
	\})

call s:add_definition('clojure', {
	\"type": 'function',
	\"pcre2_regexp": '\(defn-?\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defn-?\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defn test [foo]","(defn- test [foo]"],
	\"spec_failed": ["(defn test? [foo]","(defn- test? [foo]"],
	\})

call s:add_definition('clojure', {
	\"type": 'function',
	\"pcre2_regexp": '\(defmacro\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defmacro\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defmacro test [foo]"],
	\"spec_failed": [],
	\})

call s:add_definition('clojure', {
	\"type": 'function',
	\"pcre2_regexp": '\(deftask\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(deftask\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(deftask test [foo]"],
	\"spec_failed": [],
	\})

call s:add_definition('clojure', {
	\"type": 'type',
	\"pcre2_regexp": '\(deftype\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(deftype\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(deftype test [foo]"],
	\"spec_failed": [],
	\})

call s:add_definition('clojure', {
	\"type": 'type',
	\"pcre2_regexp": '\(defmulti\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defmulti\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defmulti test fn"],
	\"spec_failed": [],
	\})

call s:add_definition('clojure', {
	\"type": 'type',
	\"pcre2_regexp": '\(defmethod\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defmethod\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defmethod test type"],
	\"spec_failed": [],
	\})

call s:add_definition('clojure', {
	\"type": 'type',
	\"pcre2_regexp": '\(definterface\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(definterface\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(definterface test (foo)"],
	\"spec_failed": [],
	\})

call s:add_definition('clojure', {
	\"type": 'type',
	\"pcre2_regexp": '\(defprotocol\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defprotocol\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defprotocol test (foo)"],
	\"spec_failed": [],
	\})

call s:add_definition('clojure', {
	\"type": 'type',
	\"pcre2_regexp": '\(defrecord\s+KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\(defrecord\s+JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["(defrecord test [foo]"],
	\"spec_failed": [],
	\})

call s:add_definition('coffeescript', {
	\"type": 'function',
	\"pcre2_regexp": '^\s*KEYWORD\s*[=:].*[-=]>',
	\"emacs_regexp": '^\s*JJJ\s*[=:].*[-=]>',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = ()  =>","test= =>","test = ->","test=()->","test : ()  =>","test: =>","test : ->","test:()->"],
	\"spec_failed": ["# test = =>","test = 1"],
	\})

call s:add_definition('coffeescript', {
	\"type": 'variable',
	\"pcre2_regexp": '^\s*KEYWORD\s*[:=][^:=-][^>]+$',
	\"emacs_regexp": '^\s*JJJ\s*[:=][^:=-][^>]+$',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = $","test : [","test = {","test = a"],
	\"spec_failed": ["test::a","test: =>","test == 1","# test = 1"],
	\})

call s:add_definition('coffeescript', {
	\"type": 'class',
	\"pcre2_regexp": '^\s*\bclass\s+KEYWORD',
	\"emacs_regexp": '^\s*\bclass\s+JJJ',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test","class test extends"],
	\"spec_failed": ["# class"],
	\})

call s:add_definition('objc', {
	\"type": 'function',
	\"pcre2_regexp": '\)\s*KEYWORD(:|\b|\s)',
	\"emacs_regexp": '\)\s*JJJ(:|\b|\s)',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["- (void)test","- (void)test:(UIAlertView *)alertView"],
	\"spec_failed": ["- (void)testnot","- (void)testnot:(UIAlertView *)alertView"],
	\})

call s:add_definition('objc', {
	\"type": 'variable',
	\"pcre2_regexp": '\b\*?KEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\b\*?JJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["NSString *test = @\"asdf\""],
	\"spec_failed": ["NSString *testnot = @\"asdf\"","NSString *nottest = @\"asdf\""],
	\})

call s:add_definition('objc', {
	\"type": 'type',
	\"pcre2_regexp": '(@interface|@protocol|@implementation)\b\s*KEYWORD\b\s*',
	\"emacs_regexp": '(@interface|@protocol|@implementation)\b\s*JJJ\b\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["@interface test: UIWindow"],
	\"spec_failed": ["@interface testnon: UIWindow"],
	\})

call s:add_definition('objc', {
	\"type": 'type',
	\"pcre2_regexp": 'typedef\b\s+(NS_OPTIONS|NS_ENUM)\b\([^,]+?,\s*KEYWORD\b\s*',
	\"emacs_regexp": 'typedef\b\s+(NS_OPTIONS|NS_ENUM)\b\([^,]+?,\s*JJJ\b\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["typedef NS_ENUM(NSUInteger, test)"],
	\"spec_failed": ["typedef NS_ENUMD(NSUInteger, test)"],
	\})

call s:add_definition('swift', {
	\"type": 'variable',
	\"pcre2_regexp": '(let|var)\s*KEYWORD\s*(=|:)[^=:\n]+',
	\"emacs_regexp": '(let|var)\s*JJJ\s*(=|:)[^=:\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["let test = 1234","var test = 1234","private lazy var test: UITapGestureRecognizer"],
	\"spec_failed": ["if test == 1234:"],
	\})

call s:add_definition('swift', {
	\"type": 'function',
	\"pcre2_regexp": 'func\s*KEYWORD\b\s*\(',
	\"emacs_regexp": 'func\s*JJJ\b\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["func test(asdf)","func test()"],
	\"spec_failed": ["func testnot(asdf)","func testnot()"],
	\})

call s:add_definition('swift', {
	\"type": 'type',
	\"pcre2_regexp": '(class|struct)\s*KEYWORD\b\s*?',
	\"emacs_regexp": '(class|struct)\s*JJJ\b\s*?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test:","class test: UIWindow"],
	\"spec_failed": ["class testnot:","class testnot(object):"],
	\})

call s:add_definition('csharp', {
	\"type": 'function',
	\"pcre2_regexp": '^\s*(?:[\w\[\]]+\s+){1,3}KEYWORD\s*\(',
	\"emacs_regexp": '^\s*(?:[\w\[\]]+\s+){1,3}JJJ\s*\(',
	\"supports": ["ag", "rg"],
	\"spec_success": ["int test()","int test(param)","static int test()","static int test(param)","public static MyType test()","private virtual SomeType test(param)","static int test()"],
	\"spec_failed": ["test()","testnot()","blah = new test()"],
	\})

call s:add_definition('csharp', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n)]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n)]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["int test = 1234"],
	\"spec_failed": ["if test == 1234:","int nottest = 44"],
	\})

call s:add_definition('csharp', {
	\"type": 'type',
	\"pcre2_regexp": '(class|interface)\s*KEYWORD\b',
	\"emacs_regexp": '(class|interface)\s*JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test:","public class test : IReadableChannel, I"],
	\"spec_failed": ["class testnot:","public class testnot : IReadableChannel, I"],
	\})

call s:add_definition('java', {
	\"type": 'function',
	\"pcre2_regexp": '^\s*(?:[\w\[\]]+\s+){1,3}KEYWORD\s*\(',
	\"emacs_regexp": '^\s*(?:[\w\[\]]+\s+){1,3}JJJ\s*\(',
	\"supports": ["ag", "rg"],
	\"spec_success": ["int test()","int test(param)","static int test()","static int test(param)","public static MyType test()","private virtual SomeType test(param)","static int test()","private foo[] test()"],
	\"spec_failed": ["test()","testnot()","blah = new test()","foo bar = test()"],
	\})

call s:add_definition('java', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n)]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n)]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["int test = 1234"],
	\"spec_failed": ["if test == 1234:","int nottest = 44"],
	\})

call s:add_definition('java', {
	\"type": 'type',
	\"pcre2_regexp": '(class|interface)\s*KEYWORD\b',
	\"emacs_regexp": '(class|interface)\s*JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test:","public class test implements Something"],
	\"spec_failed": ["class testnot:","public class testnot implements Something"],
	\})

call s:add_definition('vala', {
	\"type": 'function',
	\"pcre2_regexp": '^\s*(?:[\w\[\]]+\s+){1,3}KEYWORD\s*\(',
	\"emacs_regexp": '^\s*(?:[\w\[\]]+\s+){1,3}JJJ\s*\(',
	\"supports": ["ag", "rg"],
	\"spec_success": ["int test()","int test(param)","static int test()","static int test(param)","public static MyType test()","private virtual SomeType test(param)","static int test()"],
	\"spec_failed": ["test()","testnot()","blah = new test()"],
	\})

call s:add_definition('vala', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n)]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n)]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["int test = 1234"],
	\"spec_failed": ["if test == 1234:","int nottest = 44"],
	\})

call s:add_definition('vala', {
	\"type": 'type',
	\"pcre2_regexp": '(class|interface)\s*KEYWORD\b',
	\"emacs_regexp": '(class|interface)\s*JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test:","public class test : IReadableChannel, I"],
	\"spec_failed": ["class testnot:","public class testnot : IReadableChannel, I"],
	\})

call s:add_definition('coq', {
	\"type": 'function',
	\"pcre2_regexp": '\s*Variable\s+KEYWORD\b',
	\"emacs_regexp": '\s*Variable\s+JJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["Variable test"],
	\"spec_failed": ["Variable testx"],
	\})

call s:add_definition('coq', {
	\"type": 'function',
	\"pcre2_regexp": '\s*Inductive\s+KEYWORD\b',
	\"emacs_regexp": '\s*Inductive\s+JJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["Inductive test"],
	\"spec_failed": ["Inductive testx"],
	\})

call s:add_definition('coq', {
	\"type": 'function',
	\"pcre2_regexp": '\s*Lemma\s+KEYWORD\b',
	\"emacs_regexp": '\s*Lemma\s+JJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["Lemma test"],
	\"spec_failed": ["Lemma testx"],
	\})

call s:add_definition('coq', {
	\"type": 'function',
	\"pcre2_regexp": '\s*Definition\s+KEYWORD\b',
	\"emacs_regexp": '\s*Definition\s+JJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["Definition test"],
	\"spec_failed": ["Definition testx"],
	\})

call s:add_definition('coq', {
	\"type": 'function',
	\"pcre2_regexp": '\s*Hypothesis\s+KEYWORD\b',
	\"emacs_regexp": '\s*Hypothesis\s+JJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["Hypothesis test"],
	\"spec_failed": ["Hypothesis testx"],
	\})

call s:add_definition('coq', {
	\"type": 'function',
	\"pcre2_regexp": '\s*Theorm\s+KEYWORD\b',
	\"emacs_regexp": '\s*Theorm\s+JJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["Theorm test"],
	\"spec_failed": ["Theorm testx"],
	\})

call s:add_definition('coq', {
	\"type": 'function',
	\"pcre2_regexp": '\s*Fixpoint\s+KEYWORD\b',
	\"emacs_regexp": '\s*Fixpoint\s+JJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["Fixpoint test"],
	\"spec_failed": ["Fixpoint testx"],
	\})

call s:add_definition('coq', {
	\"type": 'function',
	\"pcre2_regexp": '\s*Module\s+KEYWORD\b',
	\"emacs_regexp": '\s*Module\s+JJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["Module test"],
	\"spec_failed": ["Module testx"],
	\})

call s:add_definition('coq', {
	\"type": 'function',
	\"pcre2_regexp": '\s*CoInductive\s+KEYWORD\b',
	\"emacs_regexp": '\s*CoInductive\s+JJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["CoInductive test"],
	\"spec_failed": ["CoInductive testx"],
	\})

call s:add_definition('python', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["if test == 1234:","_test = 1234"],
	\})

call s:add_definition('python', {
	\"type": 'function',
	\"pcre2_regexp": 'def\s*KEYWORD\b\s*\(',
	\"emacs_regexp": 'def\s*JJJ\b\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["\tdef test(asdf)","def test()"],
	\"spec_failed": ["\tdef testnot(asdf)","def testnot()"],
	\})

call s:add_definition('python', {
	\"type": 'type',
	\"pcre2_regexp": 'class\s*KEYWORD\b\s*\(?',
	\"emacs_regexp": 'class\s*JJJ\b\s*\(?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test(object):","class test:"],
	\"spec_failed": ["class testnot:","class testnot(object):"],
	\})

call s:add_definition('matlab', {
	\"type": 'variable',
	\"pcre2_regexp": '^\s*\bKEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '^\s*\bJJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["for test = 1:2:","_test = 1234"],
	\})

call s:add_definition('matlab', {
	\"type": 'function',
	\"pcre2_regexp": '^\s*function\s*[^=]+\s*=\s*KEYWORD\b',
	\"emacs_regexp": '^\s*function\s*[^=]+\s*=\s*JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["\tfunction y = test(asdf)","function x = test()","function [x, losses] = test(A, y, lambda, method, qtile)"],
	\"spec_failed": ["\tfunction testnot(asdf)","function testnot()"],
	\})

call s:add_definition('matlab', {
	\"type": 'type',
	\"pcre2_regexp": '^\s*classdef\s*KEYWORD\b\s*',
	\"emacs_regexp": '^\s*classdef\s*JJJ\b\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["classdef test"],
	\"spec_failed": ["classdef testnot"],
	\})

call s:add_definition('nim', {
	\"type": 'variable',
	\"pcre2_regexp": '(const|let|var)\s*KEYWORD\s*(=|:)[^=:\n]+',
	\"emacs_regexp": '(const|let|var)\s*JJJ\s*(=|:)[^=:\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["let test = 1234","var test = 1234","var test: Stat","const test = 1234"],
	\"spec_failed": ["if test == 1234:"],
	\})

call s:add_definition('nim', {
	\"type": 'function',
	\"pcre2_regexp": '(proc|func|macro|template)\s*`?KEYWORD`?\b\s*\(',
	\"emacs_regexp": '(proc|func|macro|template)\s*`?JJJ`?\b\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["\tproc test(asdf)","proc test()","func test()","macro test()","template test()"],
	\"spec_failed": ["\tproc testnot(asdf)","proc testnot()"],
	\})

call s:add_definition('nim', {
	\"type": 'type',
	\"pcre2_regexp": 'type\s*KEYWORD\b\s*(\{[^}]+\})?\s*=\s*\w+',
	\"emacs_regexp": 'type\s*JJJ\b\s*(\{[^}]+\})?\s*=\s*\w+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["type test = object","type test {.pure.} = enum"],
	\"spec_failed": ["type testnot = object"],
	\})

call s:add_definition('nix', {
	\"type": 'variable',
	\"pcre2_regexp": '\b\s*KEYWORD\s*=[^=;]+',
	\"emacs_regexp": '\b\s*JJJ\s*=[^=;]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234;","test = 123;","test=123"],
	\"spec_failed": ["testNot = 1234;","Nottest = 1234;","AtestNot = 1234;"],
	\})

call s:add_definition('ruby', {
	\"type": 'variable',
	\"pcre2_regexp": '^\s*((\w+[.])*\w+,\s*)*KEYWORD(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
	\"emacs_regexp": '^\s*((\w+[.])*\w+,\s*)*JJJ(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["test = 1234","self.foo, test, bar = args"],
	\"spec_failed": ["if test == 1234","foo_test = 1234"],
	\})

call s:add_definition('ruby', {
	\"type": 'function',
	\"pcre2_regexp": '(^|[^\w.])((private|public|protected)\s+)?def\s+(\w+(::|[.]))*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])((private|public|protected)\s+)?def\s+(\w+(::|[.]))*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["def test(foo)","def test()","def test foo","def test; end","def self.test()","def MODULE::test()","private def test"],
	\"spec_failed": ["def test_foo"],
	\})

call s:add_definition('ruby', {
	\"type": 'function',
	\"pcre2_regexp": '(^|\W)define(_singleton|_instance)?_method(\s|[(])\s*:KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|\W)define(_singleton|_instance)?_method(\s|[(])\s*:JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["define_method(:test, &body)","mod.define_instance_method(:test) { body }"],
	\"spec_failed": [],
	\})

call s:add_definition('ruby', {
	\"type": 'type',
	\"pcre2_regexp": '(^|[^\w.])class\s+(\w*::)*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])class\s+(\w*::)*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["class test","class Foo::test"],
	\"spec_failed": [],
	\})

call s:add_definition('ruby', {
	\"type": 'type',
	\"pcre2_regexp": '(^|[^\w.])module\s+(\w*::)*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])module\s+(\w*::)*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["module test","module Foo::test"],
	\"spec_failed": [],
	\})

call s:add_definition('ruby', {
	\"type": 'function',
	\"pcre2_regexp": '(^|\W)alias(_method)?\W+KEYWORD(\W|$)',
	\"emacs_regexp": '(^|\W)alias(_method)?\W+JJJ(\W|$)',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["alias test some_method","alias_method :test, :some_method","alias_method 'test' 'some_method'","some_class.send(:alias_method, :test, :some_method)"],
	\"spec_failed": ["alias some_method test","alias_method :some_method, :test","alias test_foo test"],
	\})

call s:add_definition('groovy', {
	\"type": 'variable',
	\"pcre2_regexp": '^\s*((\w+[.])*\w+,\s*)*KEYWORD(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
	\"emacs_regexp": '^\s*((\w+[.])*\w+,\s*)*JJJ(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["test = 1234","self.foo, test, bar = args"],
	\"spec_failed": ["if test == 1234","foo_test = 1234"],
	\})

call s:add_definition('groovy', {
	\"type": 'function',
	\"pcre2_regexp": '(^|[^\w.])((private|public)\s+)?def\s+(\w+(::|[.]))*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])((private|public)\s+)?def\s+(\w+(::|[.]))*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["def test(foo)","def test()","def test foo","def test; end","def self.test()","def MODULE::test()","private def test"],
	\"spec_failed": ["def test_foo"],
	\})

call s:add_definition('groovy', {
	\"type": 'type',
	\"pcre2_regexp": '(^|[^\w.])class\s+(\w*::)*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])class\s+(\w*::)*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["class test","class Foo::test"],
	\"spec_failed": [],
	\})

call s:add_definition('crystal', {
	\"type": 'variable',
	\"pcre2_regexp": '^\s*((\w+[.])*\w+,\s*)*KEYWORD(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
	\"emacs_regexp": '^\s*((\w+[.])*\w+,\s*)*JJJ(,\s*(\w+[.])*\w+)*\s*=([^=>~]|$)',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["test = 1234","self.foo, test, bar = args"],
	\"spec_failed": ["if test == 1234","foo_test = 1234"],
	\})

call s:add_definition('crystal', {
	\"type": 'function',
	\"pcre2_regexp": '(^|[^\w.])((private|public|protected)\s+)?def\s+(\w+(::|[.]))*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])((private|public|protected)\s+)?def\s+(\w+(::|[.]))*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["def test(foo)","def test()","def test foo","def test; end","def self.test()","def MODULE::test()","private def test"],
	\"spec_failed": ["def test_foo"],
	\})

call s:add_definition('crystal', {
	\"type": 'type',
	\"pcre2_regexp": '(^|[^\w.])class\s+(\w*::)*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])class\s+(\w*::)*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["class test","class Foo::test"],
	\"spec_failed": [],
	\})

call s:add_definition('crystal', {
	\"type": 'type',
	\"pcre2_regexp": '(^|[^\w.])module\s+(\w*::)*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])module\s+(\w*::)*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["module test","module Foo::test"],
	\"spec_failed": [],
	\})

call s:add_definition('crystal', {
	\"type": 'type',
	\"pcre2_regexp": '(^|[^\w.])struct\s+(\w*::)*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])struct\s+(\w*::)*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["struct test","struct Foo::test"],
	\"spec_failed": [],
	\})

call s:add_definition('crystal', {
	\"type": 'type',
	\"pcre2_regexp": '(^|[^\w.])alias\s+(\w*::)*KEYWORD($|[^\w|:])',
	\"emacs_regexp": '(^|[^\w.])alias\s+(\w*::)*JJJ($|[^\w|:])',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["alias test","alias Foo::test"],
	\"spec_failed": [],
	\})

call s:add_definition('scad', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["if test == 1234 {"],
	\})

call s:add_definition('scad', {
	\"type": 'function',
	\"pcre2_regexp": 'function\s*KEYWORD\s*\(',
	\"emacs_regexp": 'function\s*JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function test()","function test ()"],
	\"spec_failed": [],
	\})

call s:add_definition('scad', {
	\"type": 'module',
	\"pcre2_regexp": 'module\s*KEYWORD\s*\(',
	\"emacs_regexp": 'module\s*JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["module test()","module test ()"],
	\"spec_failed": [],
	\})

call s:add_definition('scala', {
	\"type": 'variable',
	\"pcre2_regexp": '\bval\s*KEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\bval\s*JJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["val test = 1234"],
	\"spec_failed": ["case test => 1234"],
	\})

call s:add_definition('scala', {
	\"type": 'variable',
	\"pcre2_regexp": '\bvar\s*KEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\bvar\s*JJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["var test = 1234"],
	\"spec_failed": ["case test => 1234"],
	\})

call s:add_definition('scala', {
	\"type": 'variable',
	\"pcre2_regexp": '\btype\s*KEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\btype\s*JJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["type test = 1234"],
	\"spec_failed": ["case test => 1234"],
	\})

call s:add_definition('scala', {
	\"type": 'function',
	\"pcre2_regexp": '\bdef\s*KEYWORD\s*\(',
	\"emacs_regexp": '\bdef\s*JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["def test(asdf)","def test()"],
	\"spec_failed": [],
	\})

call s:add_definition('scala', {
	\"type": 'type',
	\"pcre2_regexp": 'class\s*KEYWORD\s*\(?',
	\"emacs_regexp": 'class\s*JJJ\s*\(?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test(object)"],
	\"spec_failed": [],
	\})

call s:add_definition('scala', {
	\"type": 'type',
	\"pcre2_regexp": 'trait\s*KEYWORD\s*\(?',
	\"emacs_regexp": 'trait\s*JJJ\s*\(?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["trait test(object)"],
	\"spec_failed": [],
	\})

call s:add_definition('scala', {
	\"type": 'type',
	\"pcre2_regexp": 'object\s*KEYWORD\s*\(?',
	\"emacs_regexp": 'object\s*JJJ\s*\(?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["object test(object)"],
	\"spec_failed": [],
	\})

call s:add_definition('r', {
	\"type": 'variable',
	\"pcre2_regexp": '\bKEYWORD\s*=[^=><]',
	\"emacs_regexp": '\bJJJ\s*=[^=><]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["if (test == 1234)"],
	\})

call s:add_definition('r', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*<-\s*function\b',
	\"emacs_regexp": '\bJJJ\s*<-\s*function\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test <- function","test <- function("],
	\"spec_failed": ["test <- functionX"],
	\})

call s:add_definition('perl', {
	\"type": 'function',
	\"pcre2_regexp": 'sub\s*KEYWORD\s*(\{|\()',
	\"emacs_regexp": 'sub\s*JJJ\s*(\{|\()',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["sub test{","sub test {","sub test(","sub test ("],
	\"spec_failed": [],
	\})

call s:add_definition('perl', {
	\"type": 'variable',
	\"pcre2_regexp": 'KEYWORD\s*=\s*',
	\"emacs_regexp": 'JJJ\s*=\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["$test = 1234"],
	\"spec_failed": [],
	\})

call s:add_definition('shell', {
	\"type": 'function',
	\"pcre2_regexp": 'function\s*KEYWORD\s*',
	\"emacs_regexp": 'function\s*JJJ\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function test{","function test {","function test () {"],
	\"spec_failed": ["function nottest {"],
	\})

call s:add_definition('shell', {
	\"type": 'function',
	\"pcre2_regexp": 'KEYWORD\(\)\s*\{',
	\"emacs_regexp": 'JJJ\(\)\s*\{',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test() {"],
	\"spec_failed": ["testx() {"],
	\})

call s:add_definition('shell', {
	\"type": 'variable',
	\"pcre2_regexp": '\bKEYWORD\s*=\s*',
	\"emacs_regexp": '\bJJJ\s*=\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["blahtest = 1234"],
	\})

call s:add_definition('php', {
	\"type": 'function',
	\"pcre2_regexp": 'function\s*KEYWORD\s*\(',
	\"emacs_regexp": 'function\s*JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function test()","function test ()"],
	\"spec_failed": [],
	\})

call s:add_definition('php', {
	\"type": 'function',
	\"pcre2_regexp": '\*\s@method\s+[^ 	]+\s+KEYWORD\(',
	\"emacs_regexp": '\*\s@method\s+[^ 	]+\s+JJJ\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["/** @method string|false test($a)"," * @method bool test()"],
	\"spec_failed": [],
	\})

call s:add_definition('php', {
	\"type": 'variable',
	\"pcre2_regexp": '(\s|->|\$|::)KEYWORD\s*=\s*',
	\"emacs_regexp": '(\s|->|\$|::)JJJ\s*=\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["$test = 1234","$foo->test = 1234"],
	\"spec_failed": [],
	\})

call s:add_definition('php', {
	\"type": 'variable',
	\"pcre2_regexp": '\*\s@property(-read|-write)?\s+([^ 	]+\s+)&?\$KEYWORD(\s+|$)',
	\"emacs_regexp": '\*\s@property(-read|-write)?\s+([^ 	]+\s+)&?\$JJJ(\s+|$)',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["/** @property string $test","/** @property string $test description for $test property"," * @property-read bool|bool $test"," * @property-write \\ArrayObject<string,resource[]> $test"],
	\"spec_failed": [],
	\})

call s:add_definition('php', {
	\"type": 'trait',
	\"pcre2_regexp": 'trait\s*KEYWORD\s*\{',
	\"emacs_regexp": 'trait\s*JJJ\s*\{',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["trait test{","trait test {"],
	\"spec_failed": [],
	\})

call s:add_definition('php', {
	\"type": 'interface',
	\"pcre2_regexp": 'interface\s*KEYWORD\s*\{',
	\"emacs_regexp": 'interface\s*JJJ\s*\{',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["interface test{","interface test {"],
	\"spec_failed": [],
	\})

call s:add_definition('php', {
	\"type": 'class',
	\"pcre2_regexp": 'class\s*KEYWORD\s*(extends|implements|\{)',
	\"emacs_regexp": 'class\s*JJJ\s*(extends|implements|\{)',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test{","class test {","class test extends foo","class test implements foo"],
	\"spec_failed": [],
	\})

call s:add_definition('dart', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*\([^()]*\)\s*[{]',
	\"emacs_regexp": '\bJJJ\s*\([^()]*\)\s*[{]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test(foo) {","test (foo){","test(foo){"],
	\"spec_failed": [],
	\})

call s:add_definition('dart', {
	\"type": 'function',
	\"pcre2_regexp": 'class\s*KEYWORD\s*[\(\{]',
	\"emacs_regexp": 'class\s*JJJ\s*[\(\{]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test(object) {","class test{"],
	\"spec_failed": [],
	\})

call s:add_definition('faust', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD(\(.+\))*\s*=',
	\"emacs_regexp": '\bJJJ(\(.+\))*\s*=',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = osc + 0.5;","test(freq) = osc(freq) + 0.5;"],
	\"spec_failed": [],
	\})

call s:add_definition('fortran', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["if (test == 1234)"],
	\})

call s:add_definition('fortran', {
	\"type": 'function',
	\"pcre2_regexp": '\b(function|subroutine|FUNCTION|SUBROUTINE)\s+KEYWORD\b\s*\(',
	\"emacs_regexp": '\b(function|subroutine|FUNCTION|SUBROUTINE)\s+JJJ\b\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function test (foo)","integer function test(foo)","subroutine test (foo, bar)","FUNCTION test (foo)","INTEGER FUNCTION test(foo)","SUBROUTINE test (foo, bar)"],
	\"spec_failed": ["end function test","end subroutine test","END FUNCTION test","END SUBROUTINE test"],
	\})

call s:add_definition('fortran', {
	\"type": 'function',
	\"pcre2_regexp": '^\s*(interface|INTERFACE)\s+KEYWORD\b',
	\"emacs_regexp": '^\s*(interface|INTERFACE)\s+JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["interface test","INTERFACE test"],
	\"spec_failed": ["interface test2","end interface test","INTERFACE test2","END INTERFACE test"],
	\})

call s:add_definition('fortran', {
	\"type": 'type',
	\"pcre2_regexp": '^\s*(module|MODULE)\s+KEYWORD\s*',
	\"emacs_regexp": '^\s*(module|MODULE)\s+JJJ\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["module test","MODULE test"],
	\"spec_failed": ["end module test","END MODULE test"],
	\})

call s:add_definition('go', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["if test == 1234 {"],
	\})

call s:add_definition('go', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*:=\s*',
	\"emacs_regexp": '\s*\bJJJ\s*:=\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test := 1234"],
	\"spec_failed": [],
	\})

call s:add_definition('go', {
	\"type": 'function',
	\"pcre2_regexp": 'func\s+\([^\)]*\)\s+KEYWORD\s*\(',
	\"emacs_regexp": 'func\s+\([^\)]*\)\s+JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["func (s *blah) test(filename string) string {"],
	\"spec_failed": [],
	\})

call s:add_definition('go', {
	\"type": 'function',
	\"pcre2_regexp": 'func\s+KEYWORD\s*\(',
	\"emacs_regexp": 'func\s+JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["func test(url string) (string, error)"],
	\"spec_failed": [],
	\})

call s:add_definition('go', {
	\"type": 'type',
	\"pcre2_regexp": 'type\s+KEYWORD\s+struct\s+\{',
	\"emacs_regexp": 'type\s+JJJ\s+struct\s+\{',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["type test struct {"],
	\"spec_failed": [],
	\})

call s:add_definition('javascript', {
	\"type": 'function',
	\"pcre2_regexp": '(service|factory)\(['"]KEYWORD['"]',
	\"emacs_regexp": '(service|factory)\(['"]JJJ['"]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["module.factory('test', [\"$rootScope\", function($rootScope) {"],
	\"spec_failed": [],
	\})

call s:add_definition('javascript', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
	\"emacs_regexp": '\bJJJ\s*[=:]\s*\([^\)]*\)\s+=>',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["const test = (foo) => ","test: (foo) => {","  test: (foo) => {"],
	\"spec_failed": [],
	\})

call s:add_definition('javascript', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*\([^()]*\)\s*[{]',
	\"emacs_regexp": '\bJJJ\s*\([^()]*\)\s*[{]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test(foo) {","test (foo){","test(foo){"],
	\"spec_failed": ["test = blah.then(function(){"],
	\})

call s:add_definition('javascript', {
	\"type": 'function',
	\"pcre2_regexp": 'class\s*KEYWORD\s*[\(\{]',
	\"emacs_regexp": 'class\s*JJJ\s*[\(\{]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test(object) {","class test{"],
	\"spec_failed": [],
	\})

call s:add_definition('javascript', {
	\"type": 'function',
	\"pcre2_regexp": 'class\s*KEYWORD\s+extends',
	\"emacs_regexp": 'class\s*JJJ\s+extends',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test extends Component{"],
	\"spec_failed": [],
	\})

call s:add_definition('javascript', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234","const test = props =>"],
	\"spec_failed": ["if (test === 1234)"],
	\})

call s:add_definition('javascript', {
	\"type": 'variable',
	\"pcre2_regexp": '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
	\"emacs_regexp": '\bfunction\b[^\(]*\(\s*[^\)]*\bJJJ\b\s*,?\s*\)?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function (test)","function (test, blah)","function somefunc(test, blah) {","function(blah, test)"],
	\"spec_failed": ["function (testLen)","function (test1, blah)","function somefunc(testFirst, blah) {","function(blah, testLast)","function (Lentest)","function (blahtest, blah)","function somefunc(Firsttest, blah) {","function(blah, Lasttest)"],
	\})

call s:add_definition('javascript', {
	\"type": 'function',
	\"pcre2_regexp": 'function\s*KEYWORD\s*\(',
	\"emacs_regexp": 'function\s*JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function test()","function test ()"],
	\"spec_failed": [],
	\})

call s:add_definition('javascript', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*:\s*function\s*\(',
	\"emacs_regexp": '\bJJJ\s*:\s*function\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test: function()"],
	\"spec_failed": [],
	\})

call s:add_definition('javascript', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*=\s*function\s*\(',
	\"emacs_regexp": '\bJJJ\s*=\s*function\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = function()"],
	\"spec_failed": [],
	\})

call s:add_definition('typescript', {
	\"type": 'function',
	\"pcre2_regexp": '(service|factory)\(['"]KEYWORD['"]',
	\"emacs_regexp": '(service|factory)\(['"]JJJ['"]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["module.factory('test', [\"$rootScope\", function($rootScope) {"],
	\"spec_failed": [],
	\})

call s:add_definition('typescript', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*[=:]\s*\([^\)]*\)\s+=>',
	\"emacs_regexp": '\bJJJ\s*[=:]\s*\([^\)]*\)\s+=>',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["const test = (foo) => ","test: (foo) => {","  test: (foo) => {"],
	\"spec_failed": [],
	\})

call s:add_definition('typescript', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*\([^()]*\)\s*[{]',
	\"emacs_regexp": '\bJJJ\s*\([^()]*\)\s*[{]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test(foo) {","test (foo){","test(foo){"],
	\"spec_failed": ["test = blah.then(function(){"],
	\})

call s:add_definition('typescript', {
	\"type": 'function',
	\"pcre2_regexp": 'class\s*KEYWORD\s*[\(\{]',
	\"emacs_regexp": 'class\s*JJJ\s*[\(\{]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test{"],
	\"spec_failed": [],
	\})

call s:add_definition('typescript', {
	\"type": 'function',
	\"pcre2_regexp": 'class\s*KEYWORD\s+extends',
	\"emacs_regexp": 'class\s*JJJ\s+extends',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test extends Component{"],
	\"spec_failed": [],
	\})

call s:add_definition('typescript', {
	\"type": 'function',
	\"pcre2_regexp": 'function\s*KEYWORD\s*\(',
	\"emacs_regexp": 'function\s*JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function test()","function test ()"],
	\"spec_failed": [],
	\})

call s:add_definition('typescript', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*:\s*function\s*\(',
	\"emacs_regexp": '\bJJJ\s*:\s*function\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test: function()"],
	\"spec_failed": [],
	\})

call s:add_definition('typescript', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*=\s*function\s*\(',
	\"emacs_regexp": '\bJJJ\s*=\s*function\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = function()"],
	\"spec_failed": [],
	\})

call s:add_definition('typescript', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234","const test = props =>"],
	\"spec_failed": ["if (test === 1234)"],
	\})

call s:add_definition('typescript', {
	\"type": 'variable',
	\"pcre2_regexp": '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
	\"emacs_regexp": '\bfunction\b[^\(]*\(\s*[^\)]*\bJJJ\b\s*,?\s*\)?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function (test)","function (test, blah)","function somefunc(test, blah) {","function(blah, test)"],
	\"spec_failed": ["function (testLen)","function (test1, blah)","function somefunc(testFirst, blah) {","function(blah, testLast)","function (Lentest)","function (blahtest, blah)","function somefunc(Firsttest, blah) {","function(blah, Lasttest)"],
	\})

call s:add_definition('julia', {
	\"type": 'function',
	\"pcre2_regexp": '(@noinline|@inline)?\s*function\s*KEYWORD(\{[^\}]*\})?\(',
	\"emacs_regexp": '(@noinline|@inline)?\s*function\s*JJJ(\{[^\}]*\})?\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function test()","@inline function test()","function test{T}(h)"],
	\"spec_failed": [],
	\})

call s:add_definition('julia', {
	\"type": 'function',
	\"pcre2_regexp": '(@noinline|@inline)?KEYWORD(\{[^\}]*\})?\([^\)]*\)s*=',
	\"emacs_regexp": '(@noinline|@inline)?JJJ(\{[^\}]*\})?\([^\)]*\)s*=',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test(a)=1","test(a,b)=1*8","@noinline test()=1","test{T}(x)=x"],
	\"spec_failed": [],
	\})

call s:add_definition('julia', {
	\"type": 'function',
	\"pcre2_regexp": 'macro\s*KEYWORD\(',
	\"emacs_regexp": 'macro\s*JJJ\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["macro test(a)=1"," macro test(a,b)=1*8"],
	\"spec_failed": [],
	\})

call s:add_definition('julia', {
	\"type": 'variable',
	\"pcre2_regexp": 'const\s+KEYWORD\b',
	\"emacs_regexp": 'const\s+JJJ\b',
	\"supports": ["ag", "rg"],
	\"spec_success": ["const test = "],
	\"spec_failed": [],
	\})

call s:add_definition('julia', {
	\"type": 'type',
	\"pcre2_regexp": '(mutable)?\s*struct\s*KEYWORD',
	\"emacs_regexp": '(mutable)?\s*struct\s*JJJ',
	\"supports": ["ag", "rg"],
	\"spec_success": ["struct test"],
	\"spec_failed": [],
	\})

call s:add_definition('julia', {
	\"type": 'type',
	\"pcre2_regexp": '(type|immutable|abstract)\s*KEYWORD',
	\"emacs_regexp": '(type|immutable|abstract)\s*JJJ',
	\"supports": ["ag", "rg"],
	\"spec_success": ["type test","immutable test","abstract test <:Testable"],
	\"spec_failed": [],
	\})

call s:add_definition('haskell', {
	\"type": 'module',
	\"pcre2_regexp": '^module\s+KEYWORD\s+',
	\"emacs_regexp": '^module\s+JJJ\s+',
	\"supports": ["ag", "rg"],
	\"spec_success": ["module Test (exportA, exportB) where"],
	\"spec_failed": [],
	\})

call s:add_definition('haskell', {
	\"type": 'top level function',
	\"pcre2_regexp": '^\bKEYWORD(?!(\s+::))\s+((.|\s)*?)=\s+',
	\"emacs_regexp": '^\bJJJ(?!(\s+::))\s+((.|\s)*?)=\s+',
	\"supports": ["ag", "rg"],
	\"spec_success": ["test n = n * 2","test X{..} (Y a b c) \n bcd \n =\n x * y","test ab cd e@Datatype {..} (Another thing, inTheRow) = \n undefined","test = runRealBasedMode @ext @ctx identity identity","test unwrap wrap nr@Naoeu {..} (Action action, specSpecs) = \n    undefined"],
	\"spec_failed": ["nottest n = n * 2","let testnot x y = x * y","test $ y z","let test a o = mda","test :: Sometype -> AnotherType aoeu kek = undefined"],
	\})

call s:add_definition('haskell', {
	\"type": 'type-like',
	\"pcre2_regexp": '^\s*((data(\s+family)?)|(newtype)|(type(\s+family)?))\s+KEYWORD\s+',
	\"emacs_regexp": '^\s*((data(\s+family)?)|(newtype)|(type(\s+family)?))\s+JJJ\s+',
	\"supports": ["ag", "rg"],
	\"spec_success": ["newtype Test a = Something { b :: Kek }","data Test a b = Somecase a | Othercase b","type family Test (x :: *) (xs :: [*]) :: Nat where","data family Test ","type Test = TestAlias"],
	\"spec_failed": ["newtype NotTest a = NotTest (Not a)","data TestNot b = Aoeu"],
	\})

call s:add_definition('haskell', {
	\"type": '(data)type constructor 1',
	\"pcre2_regexp": '(data|newtype)\s{1,3}(?!KEYWORD\s+)([^=]{1,40})=((\s{0,3}KEYWORD\s+)|([^=]{0,500}?((?<!(-- ))\|\s{0,3}KEYWORD\s+)))',
	\"emacs_regexp": '(data|newtype)\s{1,3}(?!JJJ\s+)([^=]{1,40})=((\s{0,3}JJJ\s+)|([^=]{0,500}?((?<!(-- ))\|\s{0,3}JJJ\s+)))',
	\"supports": ["ag", "rg"],
	\"spec_success": ["data Something a = Test { b :: Kek }","data Mem a = TrueMem { b :: Kek } | Test (Mem Int) deriving Mda","newtype SafeTest a = Test (Kek a) deriving (YonedaEmbedding)"],
	\"spec_failed": ["data Test = Test { b :: Kek }"],
	\})

call s:add_definition('haskell', {
	\"type": 'data/newtype record field',
	\"pcre2_regexp": '(data|newtype)([^=]*)=[^=]*?({([^=}]*?)(\bKEYWORD)\s+::[^=}]+})',
	\"emacs_regexp": '(data|newtype)([^=]*)=[^=]*?({([^=}]*?)(\bJJJ)\s+::[^=}]+})',
	\"supports": ["ag", "rg"],
	\"spec_success": ["data Mem = Mem { \n mda :: A \n  , test :: Kek \n , \n aoeu :: E \n }","data Mem = Mem { \n test :: A \n  , mda :: Kek \n , \n aoeu :: E \n }","data Mem = Mem { \n mda :: A \n  , aoeu :: Kek \n , \n test :: E \n }","data Mem = Mem { test :: Kek } deriving Mda","data Mem = Mem { \n test :: Kek \n } deriving Mda","newtype Mem = Mem { \n test :: Kek \n } deriving (Eq)","newtype Mem = Mem { -- | Some docs \n test :: Kek -- ^ More docs } deriving Eq","newtype Mem = Mem { test :: Kek } deriving (Eq,Monad)","newtype NewMem = OldMem { test :: [Tx] }","newtype BlockHeaderList ssc = BHL\n { test :: ([Aoeu a], [Ssss])\n    } deriving (Eq)"],
	\"spec_failed": ["data Heh = Mda { sometest :: Kek, testsome :: Mem }"],
	\})

call s:add_definition('haskell', {
	\"type": 'typeclass',
	\"pcre2_regexp": '^class\s+(.+=>\s*)?KEYWORD\s+',
	\"emacs_regexp": '^class\s+(.+=>\s*)?JJJ\s+',
	\"supports": ["ag", "rg"],
	\"spec_success": ["class (Constr1 m, Constr 2) => Test (Kek a) where","class  Test  (Veryovka a)  where "],
	\"spec_failed": ["class Test2 (Kek a) where","class MakeTest (AoeuTest x y z) where"],
	\})

call s:add_definition('ocaml', {
	\"type": 'type',
	\"pcre2_regexp": '^\s*(and|type)\s+.*\bKEYWORD\b',
	\"emacs_regexp": '^\s*(and|type)\s+.*\bJJJ\b',
	\"supports": ["ag", "rg"],
	\"spec_success": ["type test =","and test =","type 'a test =","type ('a, _, 'c) test"],
	\"spec_failed": [],
	\})

call s:add_definition('ocaml', {
	\"type": 'variable',
	\"pcre2_regexp": 'let\s+KEYWORD\b',
	\"emacs_regexp": 'let\s+JJJ\b',
	\"supports": ["ag", "rg"],
	\"spec_success": ["let test =","let test x y ="],
	\"spec_failed": [],
	\})

call s:add_definition('ocaml', {
	\"type": 'variable',
	\"pcre2_regexp": 'let\s+rec\s+KEYWORD\b',
	\"emacs_regexp": 'let\s+rec\s+JJJ\b',
	\"supports": ["ag", "rg"],
	\"spec_success": ["let rec test =","let rec  test x y ="],
	\"spec_failed": [],
	\})

call s:add_definition('ocaml', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*val\s*\bKEYWORD\b\s*',
	\"emacs_regexp": '\s*val\s*\bJJJ\b\s*',
	\"supports": ["ag", "rg"],
	\"spec_success": ["val test"],
	\"spec_failed": [],
	\})

call s:add_definition('ocaml', {
	\"type": 'module',
	\"pcre2_regexp": '^\s*module\s*\bKEYWORD\b',
	\"emacs_regexp": '^\s*module\s*\bJJJ\b',
	\"supports": ["ag", "rg"],
	\"spec_success": ["module test ="],
	\"spec_failed": [],
	\})

call s:add_definition('ocaml', {
	\"type": 'module',
	\"pcre2_regexp": '^\s*module\s*type\s*\bKEYWORD\b',
	\"emacs_regexp": '^\s*module\s*type\s*\bJJJ\b',
	\"supports": ["ag", "rg"],
	\"spec_success": ["module type test ="],
	\"spec_failed": [],
	\})

call s:add_definition('lua', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*\bKEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\s*\bJJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["if test === 1234"],
	\})

call s:add_definition('lua', {
	\"type": 'variable',
	\"pcre2_regexp": '\bfunction\b[^\(]*\(\s*[^\)]*\bKEYWORD\b\s*,?\s*\)?',
	\"emacs_regexp": '\bfunction\b[^\(]*\(\s*[^\)]*\bJJJ\b\s*,?\s*\)?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function (test)","function (test, blah)","function somefunc(test, blah)","function(blah, test)"],
	\"spec_failed": ["function (testLen)","function (test1, blah)","function somefunc(testFirst, blah)","function(blah, testLast)","function (Lentest)","function (blahtest, blah)","function somefunc(Firsttest, blah)","function(blah, Lasttest)"],
	\})

call s:add_definition('lua', {
	\"type": 'function',
	\"pcre2_regexp": 'function\s*KEYWORD\s*\(',
	\"emacs_regexp": 'function\s*JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function test()","function test ()"],
	\"spec_failed": [],
	\})

call s:add_definition('lua', {
	\"type": 'function',
	\"pcre2_regexp": 'function\s*.+[.:]KEYWORD\s*\(',
	\"emacs_regexp": 'function\s*.+[.:]JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function MyClass.test()","function MyClass.test ()","function MyClass:test()","function MyClass:test ()"],
	\"spec_failed": [],
	\})

call s:add_definition('lua', {
	\"type": 'function',
	\"pcre2_regexp": '\bKEYWORD\s*=\s*function\s*\(',
	\"emacs_regexp": '\bJJJ\s*=\s*function\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = function()"],
	\"spec_failed": [],
	\})

call s:add_definition('lua', {
	\"type": 'function',
	\"pcre2_regexp": '\b.+\.KEYWORD\s*=\s*function\s*\(',
	\"emacs_regexp": '\b.+\.JJJ\s*=\s*function\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["MyClass.test = function()"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'variable',
	\"pcre2_regexp": '\blet\s+(\([^=\n]*)?(muts+)?KEYWORD([^=\n]*\))?(:\s*[^=\n]+)?\s*=\s*[^=\n]+',
	\"emacs_regexp": '\blet\s+(\([^=\n]*)?(muts+)?JJJ([^=\n]*\))?(:\s*[^=\n]+)?\s*=\s*[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["let test = 1234;","let test: u32 = 1234;","let test: Vec<u32> = Vec::new();","let mut test = 1234;","let mut test: Vec<u32> = Vec::new();","let (a, test, b) = (1, 2, 3);","let (a, mut test, mut b) = (1, 2, 3);","let (mut a, mut test): (u32, usize) = (1, 2);"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'variable',
	\"pcre2_regexp": '\bconst\s+KEYWORD:\s*[^=\n]+\s*=[^=\n]+',
	\"emacs_regexp": '\bconst\s+JJJ:\s*[^=\n]+\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["const test: u32 = 1234;"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'variable',
	\"pcre2_regexp": '\bstatic\s+(mut\s+)?KEYWORD:\s*[^=\n]+\s*=[^=\n]+',
	\"emacs_regexp": '\bstatic\s+(mut\s+)?JJJ:\s*[^=\n]+\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["static test: u32 = 1234;","static mut test: u32 = 1234;"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'variable',
	\"pcre2_regexp": '\bfn\s+.+\s*\((.+,\s+)?KEYWORD:\s*[^=\n]+\s*(,\s*.+)*\)',
	\"emacs_regexp": '\bfn\s+.+\s*\((.+,\s+)?JJJ:\s*[^=\n]+\s*(,\s*.+)*\)',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["fn abc(test: u32) -> u32 {","fn abc(x: u32, y: u32, test: Vec<u32>, z: Vec<Foo>)","fn abc(x: u32, y: u32, test: &mut Vec<u32>, z: Vec<Foo>)"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'variable',
	\"pcre2_regexp": '(if|while)\s+let\s+([^=\n]+)?(mut\s+)?KEYWORD([^=\n\(]+)?\s*=\s*[^=\n]+',
	\"emacs_regexp": '(if|while)\s+let\s+([^=\n]+)?(mut\s+)?JJJ([^=\n\(]+)?\s*=\s*[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["if let Some(test) = abc() {","if let Some(mut test) = abc() {","if let Ok(test) = abc() {","if let Ok(mut test) = abc() {","if let Foo(mut test) = foo {","if let test = abc() {","if let Some(test) = abc()","if let Some((a, test, b)) = abc()","while let Some(test) = abc() {","while let Some(mut test) = abc() {","while let Ok(test) = abc() {","while let Ok(mut test) = abc() {"],
	\"spec_failed": ["while let test(foo) = abc() {"],
	\})

call s:add_definition('rust', {
	\"type": 'variable',
	\"pcre2_regexp": 'struct\s+[^\n{]+[{][^}]*(\s*KEYWORD\s*:\s*[^\n},]+)[^}]*}',
	\"emacs_regexp": 'struct\s+[^\n{]+[{][^}]*(\s*JJJ\s*:\s*[^\n},]+)[^}]*}',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["struct Foo { abc: u32, test: Vec<String>, b: PathBuf }","struct Foo<T>{test:Vec<T>}","struct FooBar<'a> { test: Vec<String> }"],
	\"spec_failed": ["struct Foo { abc: u32, b: Vec<String> }","/// ... construct the equivalent ...\nfn abc() {\n"],
	\})

call s:add_definition('rust', {
	\"type": 'variable',
	\"pcre2_regexp": 'enum\s+[^\n{]+\s*[{][^}]*\bKEYWORD\b[^}]*}',
	\"emacs_regexp": 'enum\s+[^\n{]+\s*[{][^}]*\bJJJ\b[^}]*}',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["enum Foo { VariantA, test, VariantB(u32) }","enum Foo<T> { test(T) }","enum BadStyle{test}","enum Foo32 { Bar, testing, test(u8) }"],
	\"spec_failed": ["enum Foo { testing }"],
	\})

call s:add_definition('rust', {
	\"type": 'function',
	\"pcre2_regexp": '\bfn\s+KEYWORD\s*\(',
	\"emacs_regexp": '\bfn\s+JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["fn test(asdf: u32)","fn test()","pub fn test()"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'function',
	\"pcre2_regexp": '\bmacro_rules!\s+KEYWORD',
	\"emacs_regexp": '\bmacro_rules!\s+JJJ',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["macro_rules! test"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'type',
	\"pcre2_regexp": 'struct\s+KEYWORD\s*[{\(]?',
	\"emacs_regexp": 'struct\s+JJJ\s*[{\(]?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["struct test(u32, u32)","struct test;","struct test { abc: u32, def: Vec<String> }"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'type',
	\"pcre2_regexp": 'trait\s+KEYWORD\s*[{]?',
	\"emacs_regexp": 'trait\s+JJJ\s*[{]?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["trait test;","trait test { fn abc() -> u32; }"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'type',
	\"pcre2_regexp": '\btype\s+KEYWORD([^=\n]+)?\s*=[^=\n]+;',
	\"emacs_regexp": '\btype\s+JJJ([^=\n]+)?\s*=[^=\n]+;',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["type test<T> = Rc<RefCell<T>>;","type test = Arc<RwLock<Vec<u32>>>;"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'type',
	\"pcre2_regexp": 'impl\s+((\w+::)*\w+\s+for\s+)?(\w+::)*KEYWORD\s+[{]?',
	\"emacs_regexp": 'impl\s+((\w+::)*\w+\s+for\s+)?(\w+::)*JJJ\s+[{]?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["impl test {","impl abc::test {","impl std::io::Read for test {","impl std::io::Read for abc::test {"],
	\"spec_failed": [],
	\})

call s:add_definition('rust', {
	\"type": 'type',
	\"pcre2_regexp": 'mod\s+KEYWORD\s*[{]?',
	\"emacs_regexp": 'mod\s+JJJ\s*[{]?',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["mod test;","pub mod test {"],
	\"spec_failed": [],
	\})

call s:add_definition('elixir', {
	\"type": 'function',
	\"pcre2_regexp": '\bdef(p)?\s+KEYWORD\s*[ ,\(]',
	\"emacs_regexp": '\bdef(p)?\s+JJJ\s*[ ,\(]',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["def test do","def test, do:","def test() do","def test(), do:","def test(foo, bar) do","def test(foo, bar), do:","defp test do","defp test(), do:"],
	\"spec_failed": [],
	\})

call s:add_definition('elixir', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*KEYWORD\s*=[^=\n]+',
	\"emacs_regexp": '\s*JJJ\s*=[^=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["if test == 1234"],
	\})

call s:add_definition('elixir', {
	\"type": 'module',
	\"pcre2_regexp": 'defmodule\s+(\w+\.)*KEYWORD\s+',
	\"emacs_regexp": 'defmodule\s+(\w+\.)*JJJ\s+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["defmodule test do","defmodule Foo.Bar.test do"],
	\"spec_failed": [],
	\})

call s:add_definition('elixir', {
	\"type": 'module',
	\"pcre2_regexp": 'defprotocol\s+(\w+\.)*KEYWORD\s+',
	\"emacs_regexp": 'defprotocol\s+(\w+\.)*JJJ\s+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["defprotocol test do","defprotocol Foo.Bar.test do"],
	\"spec_failed": [],
	\})

call s:add_definition('erlang', {
	\"type": 'function',
	\"pcre2_regexp": '^KEYWORD\b\s*\(',
	\"emacs_regexp": '^JJJ\b\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test() ->","test()->","test(Foo) ->","test (Foo,Bar) ->","test(Foo, Bar)->"],
	\"spec_failed": [],
	\})

call s:add_definition('erlang', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*KEYWORD\s*=[^:=\n]+',
	\"emacs_regexp": '\s*JJJ\s*=[^:=\n]+',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test = 1234"],
	\"spec_failed": ["if test =:= 1234","if test == 1234"],
	\})

call s:add_definition('erlang', {
	\"type": 'module',
	\"pcre2_regexp": '^-module\(KEYWORD\)',
	\"emacs_regexp": '^-module\(JJJ\)',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["-module(test)."],
	\"spec_failed": [],
	\})

call s:add_definition('scss', {
	\"type": 'function',
	\"pcre2_regexp": '@mixin\sKEYWORD\b\s*\(',
	\"emacs_regexp": '@mixin\sJJJ\b\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["@mixin test()"],
	\"spec_failed": [],
	\})

call s:add_definition('scss', {
	\"type": 'function',
	\"pcre2_regexp": '@function\sKEYWORD\b\s*\(',
	\"emacs_regexp": '@function\sJJJ\b\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["@function test()"],
	\"spec_failed": [],
	\})

call s:add_definition('scss', {
	\"type": 'variable',
	\"pcre2_regexp": 'KEYWORD\s*:\s*',
	\"emacs_regexp": 'JJJ\s*:\s*',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["test  :"],
	\"spec_failed": [],
	\})

call s:add_definition('sml', {
	\"type": 'type',
	\"pcre2_regexp": '\s*(data)?type\s+.*\bKEYWORD\b',
	\"emacs_regexp": '\s*(data)?type\s+.*\bJJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["datatype test =","datatype test=","datatype 'a test =","type test =","type 'a test =","type 'a test","type test"],
	\"spec_failed": ["datatypetest ="],
	\})

call s:add_definition('sml', {
	\"type": 'variable',
	\"pcre2_regexp": '\s*val\s+\bKEYWORD\b',
	\"emacs_regexp": '\s*val\s+\bJJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["val test =","val test=","val test : bool"],
	\"spec_failed": [],
	\})

call s:add_definition('sml', {
	\"type": 'function',
	\"pcre2_regexp": '\s*fun\s+\bKEYWORD\b.*\s*=',
	\"emacs_regexp": '\s*fun\s+\bJJJ\b.*\s*=',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["fun test list =","fun test (STRING_NIL, a) =","fun test ((s1,s2): 'a queue) : 'a * 'a queue =","fun test (var : q) : int =","fun test f e xs ="],
	\"spec_failed": [],
	\})

call s:add_definition('sml', {
	\"type": 'module',
	\"pcre2_regexp": '\s*(structure|signature|functor)\s+\bKEYWORD\b',
	\"emacs_regexp": '\s*(structure|signature|functor)\s+\bJJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["structure test =","structure test : MYTEST =","signature test =","functor test (T:TEST) =","functor test(T:TEST) ="],
	\"spec_failed": [],
	\})

call s:add_definition('sql', {
	\"type": 'function',
	\"pcre2_regexp": '(CREATE|create)\s+(.+?\s+)?(FUNCTION|function|PROCEDURE|procedure)\s+KEYWORD\s*\(',
	\"emacs_regexp": '(CREATE|create)\s+(.+?\s+)?(FUNCTION|function|PROCEDURE|procedure)\s+JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["CREATE FUNCTION test(i INT) RETURNS INT","create or replace function test (int)","CREATE PROCEDURE test (OUT p INT)","create definer = 'test'@'localhost' procedure test()"],
	\"spec_failed": [],
	\})

call s:add_definition('sql', {
	\"type": 'table',
	\"pcre2_regexp": '(CREATE|create)\s+(.+?\s+)?(TABLE|table)(\s+(IF NOT EXISTS|if not exists))?\s+KEYWORD\b',
	\"emacs_regexp": '(CREATE|create)\s+(.+?\s+)?(TABLE|table)(\s+(IF NOT EXISTS|if not exists))?\s+JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["CREATE TABLE test (","create temporary table if not exists test","CREATE TABLE IF NOT EXISTS test (","create global temporary table test"],
	\"spec_failed": [],
	\})

call s:add_definition('sql', {
	\"type": 'view',
	\"pcre2_regexp": '(CREATE|create)\s+(.+?\s+)?(VIEW|view)\s+KEYWORD\b',
	\"emacs_regexp": '(CREATE|create)\s+(.+?\s+)?(VIEW|view)\s+JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["CREATE VIEW test (","create sql security definer view test","CREATE OR REPLACE VIEW test AS foo"],
	\"spec_failed": [],
	\})

call s:add_definition('sql', {
	\"type": 'type',
	\"pcre2_regexp": '(CREATE|create)\s+(.+?\s+)?(TYPE|type)\s+KEYWORD\b',
	\"emacs_regexp": '(CREATE|create)\s+(.+?\s+)?(TYPE|type)\s+JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["CREATE TYPE test","CREATE OR REPLACE TYPE test AS foo (","create type test as ("],
	\"spec_failed": [],
	\})

call s:add_definition('systemverilog', {
	\"type": 'type',
	\"pcre2_regexp": '\s*class\s+\bKEYWORD\b',
	\"emacs_regexp": '\s*class\s+\bJJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["virtual class test;","class test;","class test extends some_class"],
	\"spec_failed": ["virtual class testing;","class test2;","class some_test","class some_class extends test"],
	\})

call s:add_definition('systemverilog', {
	\"type": 'type',
	\"pcre2_regexp": '\s*task\s+\bKEYWORD\b',
	\"emacs_regexp": '\s*task\s+\bJJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["task test (","task test("],
	\"spec_failed": ["task testing (","task test2("],
	\})

call s:add_definition('systemverilog', {
	\"type": 'type',
	\"pcre2_regexp": '\s*\bKEYWORD\b\s*=',
	\"emacs_regexp": '\s*\bJJJ\b\s*=',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["assign test =","assign test=","int test =","int test="],
	\"spec_failed": ["assign testing =","assign test2="],
	\})

call s:add_definition('systemverilog', {
	\"type": 'function',
	\"pcre2_regexp": 'function\s[^\s]+\s*\bKEYWORD\b',
	\"emacs_regexp": 'function\s[^\s]+\s*\bJJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["function Matrix test ;","function Matrix test;"],
	\"spec_failed": ["function test blah"],
	\})

call s:add_definition('systemverilog', {
	\"type": 'function',
	\"pcre2_regexp": '^\s*[^\s]*\s*[^\s]+\s+\bKEYWORD\b',
	\"emacs_regexp": '^\s*[^\s]*\s*[^\s]+\s+\bJJJ\b',
	\"supports": ["ag", "rg", "git-grep"],
	\"spec_success": ["some_class_name test","  another_class_name  test ;","some_class test[];","some_class #(1) test"],
	\"spec_failed": ["test some_class_name","class some_class extends test"],
	\})

call s:add_definition('vhdl', {
	\"type": 'type',
	\"pcre2_regexp": '\s*type\s+\bKEYWORD\b',
	\"emacs_regexp": '\s*type\s+\bJJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["type test is","type test  is"],
	\"spec_failed": ["type testing is","type test2  is"],
	\})

call s:add_definition('vhdl', {
	\"type": 'type',
	\"pcre2_regexp": '\s*constant\s+\bKEYWORD\b',
	\"emacs_regexp": '\s*constant\s+\bJJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["constant test :","constant test:"],
	\"spec_failed": ["constant testing ","constant test2:"],
	\})

call s:add_definition('vhdl', {
	\"type": 'function',
	\"pcre2_regexp": 'function\s*"?KEYWORD"?\s*\(',
	\"emacs_regexp": 'function\s*"?JJJ"?\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["function test(signal)","function test (signal)","function \"test\" (signal)"],
	\"spec_failed": ["function testing(signal"],
	\})

call s:add_definition('tex', {
	\"type": 'command',
	\"pcre2_regexp": '\\.*newcommand\*?\s*\{\s*(\\)KEYWORD\s*}',
	\"emacs_regexp": '\\.*newcommand\*?\s*\{\s*(\\)JJJ\s*}',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["\\newcommand{\\test}","\\renewcommand{\\test}","\\renewcommand*{\\test}","\\newcommand*{\\test}","\\renewcommand{ \\test }"],
	\"spec_failed": ["\\test","test"],
	\})

call s:add_definition('tex', {
	\"type": 'command',
	\"pcre2_regexp": '\\.*newcommand\*?\s*(\\)KEYWORD($|[^a-zA-Z0-9\?\*-])',
	\"emacs_regexp": '\\.*newcommand\*?\s*(\\)JJJ\j',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["\\newcommand\\test {}","\\renewcommand\\test{}","\\newcommand \\test"],
	\"spec_failed": ["\\test","test"],
	\})

call s:add_definition('tex', {
	\"type": 'length',
	\"pcre2_regexp": '\\(s)etlength\s*\{\s*(\\)KEYWORD\s*}',
	\"emacs_regexp": '\\(s)etlength\s*\{\s*(\\)JJJ\s*}',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["\\setlength { \\test}","\\setlength{\\test}","\\setlength{\\test}{morecommands}"],
	\"spec_failed": ["\\test","test"],
	\})

call s:add_definition('tex', {
	\"type": 'counter',
	\"pcre2_regexp": '\\newcounter\{\s*KEYWORD\s*}',
	\"emacs_regexp": '\\newcounter\{\s*JJJ\s*}',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["\\newcounter{test}"],
	\"spec_failed": ["\\test","test"],
	\})

call s:add_definition('tex', {
	\"type": 'environment',
	\"pcre2_regexp": '\\.*newenvironment\s*\{\s*KEYWORD\s*}',
	\"emacs_regexp": '\\.*newenvironment\s*\{\s*JJJ\s*}',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["\\newenvironment{test}","\\newenvironment {test}{morecommands}","\\lstnewenvironment{test}","\\newenvironment {test}"],
	\"spec_failed": ["\\test","test"],
	\})

call s:add_definition('pascal', {
	\"type": 'function',
	\"pcre2_regexp": '\bfunction\s+KEYWORD\b',
	\"emacs_regexp": '\bfunction\s+JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["  function test : "],
	\"spec_failed": [],
	\})

call s:add_definition('pascal', {
	\"type": 'function',
	\"pcre2_regexp": '\bprocedure\s+KEYWORD\b',
	\"emacs_regexp": '\bprocedure\s+JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["  procedure test ; "],
	\"spec_failed": [],
	\})

call s:add_definition('fsharp', {
	\"type": 'variable',
	\"pcre2_regexp": 'let\s+KEYWORD\b.*\=',
	\"emacs_regexp": 'let\s+JJJ\b.*\=',
	\"supports": ["ag", "grep", "git-grep"],
	\"spec_success": ["let test = 1234","let test() = 1234","let test abc def = 1234"],
	\"spec_failed": ["let testnot = 1234","let testnot() = 1234","let testnot abc def = 1234"],
	\})

call s:add_definition('fsharp', {
	\"type": 'interface',
	\"pcre2_regexp": 'member(\b.+\.|\s+)KEYWORD\b.*\=',
	\"emacs_regexp": 'member(\b.+\.|\s+)JJJ\b.*\=',
	\"supports": ["ag", "grep", "git-grep"],
	\"spec_success": ["member test = 1234","member this.test = 1234"],
	\"spec_failed": ["member testnot = 1234","member this.testnot = 1234"],
	\})

call s:add_definition('fsharp', {
	\"type": 'type',
	\"pcre2_regexp": 'type\s+KEYWORD\b.*\=',
	\"emacs_regexp": 'type\s+JJJ\b.*\=',
	\"supports": ["ag", "grep", "git-grep"],
	\"spec_success": ["type test = 1234"],
	\"spec_failed": ["type testnot = 1234"],
	\})

call s:add_definition('kotlin', {
	\"type": 'function',
	\"pcre2_regexp": 'fun\s*(<[^>]*>)?\s*KEYWORD\s*\(',
	\"emacs_regexp": 'fun\s*(<[^>]*>)?\s*JJJ\s*\(',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["fun test()","fun <T> test()"],
	\"spec_failed": [],
	\})

call s:add_definition('kotlin', {
	\"type": 'variable',
	\"pcre2_regexp": '(val|var)\s*KEYWORD\b',
	\"emacs_regexp": '(val|var)\s*JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["val test ","var test"],
	\"spec_failed": ["val testval","var testvar"],
	\})

call s:add_definition('kotlin', {
	\"type": 'type',
	\"pcre2_regexp": '(class|interface)\s*KEYWORD\b',
	\"emacs_regexp": '(class|interface)\s*JJJ\b',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["class test","class test : SomeInterface","interface test"],
	\"spec_failed": [],
	\})

call s:add_definition('protobuf', {
	\"type": 'message',
	\"pcre2_regexp": 'message\s+KEYWORD\s*\{',
	\"emacs_regexp": 'message\s+JJJ\s*\{',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["message test{","message test {"],
	\"spec_failed": [],
	\})

call s:add_definition('protobuf', {
	\"type": 'enum',
	\"pcre2_regexp": 'enum\s+KEYWORD\s*\{',
	\"emacs_regexp": 'enum\s+JJJ\s*\{',
	\"supports": ["ag", "grep", "rg", "git-grep"],
	\"spec_success": ["enum test{","enum test {"],
	\"spec_failed": [],
	\})
