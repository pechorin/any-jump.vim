((:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "elisp"
         :regex "\\\((defun|cl-defun)\\s+JJJ\\j"
         ;; \\j usage see `dumb-jump-ag-word-boundary`
         :tests ("(defun test (blah)" "(defun test\n" "(cl-defun test (blah)" "(cl-defun test\n")
         :not ("(defun test-asdf (blah)" "(defun test-blah\n" "(cl-defun test-asdf (blah)"
               "(cl-defun test-blah\n"  "(defun tester (blah)" "(defun test? (blah)" "(defun test- (blah)"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "elisp"
         :regex "\\\(defvar\\b\\s*JJJ\\j"
         :tests ("(defvar test " "(defvar test\n")
         :not ("(defvar tester" "(defvar test?" "(defvar test-"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "elisp"
         :regex "\\\(defcustom\\b\\s*JJJ\\j"
         :tests ("(defcustom test " "(defcustom test\n")
         :not ("(defcustom tester" "(defcustom test?" "(defcustom test-"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "elisp"
         :regex "\\\(setq\\b\\s*JJJ\\j" :tests ("(setq test 123)")
         :not ("setq test-blah 123)" "(setq tester" "(setq test?" "(setq test-"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "elisp"
         :regex "\\\(JJJ\\s+" :tests ("(let ((test 123)))") :not ("(let ((test-2 123)))"))

  ;; variable in method signature
  (:type "variable" :supports ("ag" "rg" "git-grep") :language "elisp"
         :regex "\\((defun|cl-defun)\\s*.+\\\(?\\s*JJJ\\j\\s*\\\)?"
         :tests ("(defun blah (test)" "(defun blah (test blah)" "(defun (blah test)")
         :not ("(defun blah (test-1)" "(defun blah (test-2 blah)" "(defun (blah test-3)"))

  ;; common lisp
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "commonlisp"
         :regex "\\\(defun\\s+JJJ\\j"
         ;; \\j usage see `dumb-jump-ag-word-boundary`
         :tests ("(defun test (blah)" "(defun test\n")
         :not ("(defun test-asdf (blah)" "(defun test-blah\n"
               "(defun tester (blah)" "(defun test? (blah)" "(defun test- (blah)"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "commonlisp"
         :regex "\\\(defparameter\\b\\s*JJJ\\j"
         :tests ("(defparameter test " "(defparameter test\n")
         :not ("(defparameter tester" "(defparameter test?" "(defparameter test-"))

  ;; racket
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "racket"
         :regex "\\\(define\\s+\\(\\s*JJJ\\j"
         :tests ("(define (test blah)" "(define (test\n")
         :not ("(define test blah" "(define (test-asdf blah)" "(define test (lambda (blah"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "racket"
         :regex "\\\(define\\s+JJJ\\s*\\\(\\s*lambda"
         :tests ("(define test (lambda (blah" "(define test (lambda\n")
         :not ("(define test blah" "(define test-asdf (lambda (blah)" "(define (test)" "(define (test blah) (lambda (foo"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "racket"
         :regex "\\\(let\\s+JJJ\\s*(\\\(|\\\[)*"
         :tests ("(let test ((blah foo) (bar bas))" "(let test\n" "(let test [(foo")
         :not ("(let ((test blah"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "racket"
         :regex "\\\(define\\s+JJJ\\j"
         :tests ("(define test " "(define test\n")
         :not ("(define (test"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "racket"
         :regex "(\\\(|\\\[)\\s*JJJ\\s+"
         :tests ("(let ((test 'foo" "(let [(test 'foo" "(let [(test 'foo" "(let [[test 'foo" "(let ((blah 'foo) (test 'bar)")
         :not ("{test foo"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "racket"
         :regex "\\\(lambda\\s+\\\(?[^\(\)]*\\s*JJJ\\j\\s*\\\)?"
         :tests ("(lambda (test)" "(lambda (foo test)" "(lambda test (foo)")
         :not ("(lambda () test"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "racket"
         :regex "\\\(define\\s+\\\([^\(\)]+\\s*JJJ\\j\\s*\\\)?"
         :tests ("(define (foo test)" "(define (foo test bar)")
         :not ("(define foo test" "(define (test foo" "(define (test)"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "racket"
         :regex "\\(struct\\s+JJJ\\j"
         :tests ("(struct test (a b)"))

  ;; scheme
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "scheme"
         :regex "\\\(define\\s+\\(\\s*JJJ\\j"
         :tests ("(define (test blah)" "(define (test\n")
         :not ("(define test blah" "(define (test-asdf blah)" "(define test (lambda (blah"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "scheme"
         :regex "\\\(define\\s+JJJ\\s*\\\(\\s*lambda"
         :tests ("(define test (lambda (blah" "(define test (lambda\n")
         :not ("(define test blah" "(define test-asdf (lambda (blah)" "(define (test)" "(define (test blah) (lambda (foo"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "scheme"
         :regex "\\\(let\\s+JJJ\\s*(\\\(|\\\[)*"
         :tests ("(let test ((blah foo) (bar bas))" "(let test\n" "(let test [(foo")
         :not ("(let ((test blah"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "scheme"
         :regex "\\\(define\\s+JJJ\\j"
         :tests ("(define test " "(define test\n")
         :not ("(define (test"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "scheme"
         :regex "(\\\(|\\\[)\\s*JJJ\\s+"
         :tests ("(let ((test 'foo" "(let [(test 'foo" "(let [(test 'foo" "(let [[test 'foo" "(let ((blah 'foo) (test 'bar)")
         :not ("{test foo"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "scheme"
         :regex "\\\(lambda\\s+\\\(?[^\(\)]*\\s*JJJ\\j\\s*\\\)?"
         :tests ("(lambda (test)" "(lambda (foo test)" "(lambda test (foo)")
         :not ("(lambda () test"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "scheme"
         :regex "\\\(define\\s+\\\([^\(\)]+\\s*JJJ\\j\\s*\\\)?"
         :tests ("(define (foo test)" "(define (foo test bar)")
         :not ("(define foo test" "(define (test foo" "(define (test)"))

  ;; c++
  (:type "function" :supports ("ag" "rg" "git-grep") :language "c++"
         :regex "\\bJJJ(\\s|\\))*\\((\\w|[,&*.<>]|\\s)*(\\))\\s*(const|->|\\{|$)|typedef\\s+(\\w|[(*]|\\s)+JJJ(\\)|\\s)*\\("
         :tests ("int test(){" "my_struct (*test)(int a, int b){" "auto MyClass::test ( Builder& reference, ) -> decltype( builder.func() ) {" "int test( int *random_argument) const {" "test::test() {" "typedef int (*test)(int);")
         :not ("return test();)" "int test(a, b);" "if( test() ) {" "else test();"))

  ;; (:type "variable" :supports ("grep") :language "c++"
  ;;        :regex "(\\b\\w+|[,>])([*&]|\\s)+JJJ\\s*(\\[([0-9]|\\s)*\\])*\\s*([=,){;]|:\\s*[0-9])|#define\\s+JJJ\\b"
  ;;        :tests ("int test=2;" "char *test;" "int x = 1, test = 2" "int test[20];" "#define test" "unsigned int test:2;"))

  (:type "variable" :supports ("ag" "rg") :language "c++"
         :regex "\\b(?!(class\\b|struct\\b|return\\b|else\\b|delete\\b))(\\w+|[,>])([*&]|\\s)+JJJ\\s*(\\[(\\d|\\s)*\\])*\\s*([=,(){;]|:\\s*\\d)|#define\\s+JJJ\\b"
         :tests ("int test=2;" "char *test;" "int x = 1, test = 2" "int test[20];" "#define test" "typedef int test;" "unsigned int test:2")
         :not ("return test;" "#define NOT test" "else test=2;"))

  (:type "type" :supports ("ag" "rg" "git-grep") :language "c++"
         :regex "\\b(class|struct|enum|union)\\b\\s*JJJ\\b\\s*(final\\s*)?(:((\\s*\\w+\\s*::)*\\s*\\w*\\s*<?(\\s*\\w+\\s*::)*\\w+>?\\s*,*)+)?((\\{|$))|}\\s*JJJ\\b\\s*;"
         :tests ("typedef struct test {" "enum test {" "} test;" "union test {" "class test final: public Parent1, private Parent2{" "class test : public std::vector<int> {")
         :not("union test var;" "struct test function() {"))

  ;; clojure
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(def\\s+JJJ\\j"
         :tests ("(def test (foo)"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(defn-?\\s+JJJ\\j"
         :tests ("(defn test [foo]" "(defn- test [foo]")
         :not ("(defn test? [foo]" "(defn- test? [foo]"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(defmacro\\s+JJJ\\j"
         :tests ("(defmacro test [foo]"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(deftask\\s+JJJ\\j"
         :tests ("(deftask test [foo]"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(deftype\\s+JJJ\\j"
         :tests ("(deftype test [foo]"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(defmulti\\s+JJJ\\j"
         :tests ("(defmulti test fn"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(defmethod\\s+JJJ\\j"
         :tests ("(defmethod test type"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(definterface\\s+JJJ\\j"
         :tests ("(definterface test (foo)"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(defprotocol\\s+JJJ\\j"
         :tests ("(defprotocol test (foo)"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "clojure"
         :regex "\\(defrecord\\s+JJJ\\j"
         :tests ("(defrecord test [foo]"))

  ;; coffeescript
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "coffeescript"
         :regex "^\\s*JJJ\\s*[=:].*[-=]>"
         :tests ("test = ()  =>" "test= =>" "test = ->" "test=()->"
                 "test : ()  =>" "test: =>" "test : ->" "test:()->")
         :not ("# test = =>" "test = 1"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "coffeescript"
         :regex "^\\s*JJJ\\s*[:=][^:=-][^>]+$"
         :tests ("test = $" "test : [" "test = {" "test = a")
         :not ("test::a" "test: =>" "test == 1" "# test = 1"))

  (:type "class" :supports ("ag" "grep" "rg" "git-grep") :language "coffeescript"
         :regex "^\\s*\\bclass\\s+JJJ"
         :tests ("class test" "class test extends")
         :not ("# class"))

  ;; obj-c
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "objc"
         :regex "\\\)\\s*JJJ(:|\\b|\\s)"
         :tests ("- (void)test" "- (void)test:(UIAlertView *)alertView")
         :not ("- (void)testnot" "- (void)testnot:(UIAlertView *)alertView"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "objc"
         :regex "\\b\\*?JJJ\\s*=[^=\\n]+"
         :tests ("NSString *test = @\"asdf\"")
         :not ("NSString *testnot = @\"asdf\"" "NSString *nottest = @\"asdf\""))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "objc"
         :regex "(@interface|@protocol|@implementation)\\b\\s*JJJ\\b\\s*"
         :tests ("@interface test: UIWindow")
         :not ("@interface testnon: UIWindow"))


  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "objc"
         :regex "typedef\\b\\s+(NS_OPTIONS|NS_ENUM)\\b\\([^,]+?,\\s*JJJ\\b\\s*"
         :tests ("typedef NS_ENUM(NSUInteger, test)")
         :not ("typedef NS_ENUMD(NSUInteger, test)"))

  ;; swift
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "swift"
         :regex "(let|var)\\s*JJJ\\s*(=|:)[^=:\\n]+"
         :tests ("let test = 1234" "var test = 1234" "private lazy var test: UITapGestureRecognizer") :not ("if test == 1234:"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "swift"
         :regex "func\\s*JJJ\\b\\s*\\\("
         :tests ("func test(asdf)" "func test()")
         :not ("func testnot(asdf)" "func testnot()"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "swift"
         :regex "(class|struct)\\s*JJJ\\b\\s*?"
         :tests ("class test:" "class test: UIWindow")
         :not ("class testnot:" "class testnot(object):"))

  ;; c#
  (:type "function" :supports ("ag" "rg") :language "csharp"
         :regex "^\\s*(?:[\\w\\[\\]]+\\s+){1,3}JJJ\\s*\\\("
         :tests ("int test()" "int test(param)" "static int test()" "static int test(param)"
                 "public static MyType test()" "private virtual SomeType test(param)" "static int test()")
         :not ("test()" "testnot()" "blah = new test()"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "csharp"
         :regex "\\s*\\bJJJ\\s*=[^=\\n)]+" :tests ("int test = 1234") :not ("if test == 1234:" "int nottest = 44"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "csharp"
         :regex "(class|interface)\\s*JJJ\\b"
         :tests ("class test:" "public class test : IReadableChannel, I")
         :not ("class testnot:" "public class testnot : IReadableChannel, I"))

  ;; java (literally the same regexes as c#, but different tests)
  (:type "function" :supports ("ag" "rg") :language "java"
         :regex "^\\s*(?:[\\w\\[\\]]+\\s+){1,3}JJJ\\s*\\\("
         :tests ("int test()" "int test(param)" "static int test()" "static int test(param)"
                 "public static MyType test()" "private virtual SomeType test(param)" "static int test()"
                 "private foo[] test()")
         :not ("test()" "testnot()" "blah = new test()" "foo bar = test()"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "java"
         :regex "\\s*\\bJJJ\\s*=[^=\\n)]+" :tests ("int test = 1234") :not ("if test == 1234:" "int nottest = 44"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "java"
         :regex "(class|interface)\\s*JJJ\\b"
         :tests ("class test:" "public class test implements Something")
         :not ("class testnot:" "public class testnot implements Something"))

  ;; vala (again just like c#, exactly the same..)
  (:type "function" :supports ("ag" "rg") :language "vala"
         :regex "^\\s*(?:[\\w\\[\\]]+\\s+){1,3}JJJ\\s*\\\("
         :tests ("int test()" "int test(param)" "static int test()" "static int test(param)"
                 "public static MyType test()" "private virtual SomeType test(param)" "static int test()")
         :not ("test()" "testnot()" "blah = new test()"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "vala"
         :regex "\\s*\\bJJJ\\s*=[^=\\n)]+" :tests ("int test = 1234") :not ("if test == 1234:" "int nottest = 44"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "vala"
         :regex "(class|interface)\\s*JJJ\\b"
         :tests ("class test:" "public class test : IReadableChannel, I")
         :not ("class testnot:" "public class testnot : IReadableChannel, I"))

  ;; coq
  (:type "function" :supports ("ag" "rg" "git-grep") :language "coq"
         :regex "\\s*Variable\\s+JJJ\\b"
         :tests ("Variable test")
         :not ("Variable testx"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "coq"
         :regex "\\s*Inductive\\s+JJJ\\b"
         :tests ("Inductive test")
         :not ("Inductive testx"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "coq"
         :regex "\\s*Lemma\\s+JJJ\\b"
         :tests ("Lemma test")
         :not ("Lemma testx"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "coq"
         :regex "\\s*Definition\\s+JJJ\\b"
         :tests ("Definition test")
         :not ("Definition testx"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "coq"
         :regex "\\s*Hypothesis\\s+JJJ\\b"
         :tests ("Hypothesis test")
         :not ("Hypothesis testx"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "coq"
         :regex "\\s*Theorm\\s+JJJ\\b"
         :tests ("Theorm test")
         :not ("Theorm testx"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "coq"
         :regex "\\s*Fixpoint\\s+JJJ\\b"
         :tests ("Fixpoint test")
         :not ("Fixpoint testx"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "coq"
         :regex "\\s*Module\\s+JJJ\\b"
         :tests ("Module test")
         :not ("Module testx"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "coq"
         :regex "\\s*CoInductive\\s+JJJ\\b"
         :tests ("CoInductive test")
         :not ("CoInductive testx"))

  ;; python
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "python"
         :regex "\\s*\\bJJJ\\s*=[^=\\n]+"
         :tests ("test = 1234")
         :not ("if test == 1234:" "_test = 1234"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "python"
         :regex "def\\s*JJJ\\b\\s*\\\("
         :tests ("\tdef test(asdf)" "def test()")
         :not ("\tdef testnot(asdf)" "def testnot()"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "python"
         :regex "class\\s*JJJ\\b\\s*\\\(?"
         :tests ("class test(object):" "class test:")
         :not ("class testnot:" "class testnot(object):"))

  ;; matlab
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "matlab"
         :regex "^\\s*\\bJJJ\\s*=[^=\\n]+"
         :tests ("test = 1234")
         :not ("for test = 1:2:" "_test = 1234"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "matlab"
           :regex "^\\s*function\\s*[^=]+\\s*=\\s*JJJ\\b"
         :tests ("\tfunction y = test(asdf)" "function x = test()" "function [x, losses] = test(A, y, lambda, method, qtile)")
         :not ("\tfunction testnot(asdf)" "function testnot()"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "matlab"
         :regex "^\\s*classdef\\s*JJJ\\b\\s*"
         :tests ("classdef test")
         :not ("classdef testnot"))

  ;; nim
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "nim"
         :regex "(const|let|var)\\s*JJJ\\s*(=|:)[^=:\\n]+"
         :tests ("let test = 1234" "var test = 1234" "var test: Stat" "const test = 1234")
         :not ("if test == 1234:"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "nim"
         :regex "(proc|func|macro|template)\\s*`?JJJ`?\\b\\s*\\\("
         :tests ("\tproc test(asdf)" "proc test()" "func test()" "macro test()" "template test()")
         :not ("\tproc testnot(asdf)" "proc testnot()"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "nim"
         :regex "type\\s*JJJ\\b\\s*(\\{[^}]+\\})?\\s*=\\s*\\w+"
         :tests ("type test = object" "type test {.pure.} = enum")
         :not ("type testnot = object"))

  ;; nix
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "nix"
         :regex "\\b\\s*JJJ\\s*=[^=;]+"
         :tests ("test = 1234;" "test = 123;" "test=123")
         :not ("testNot = 1234;" "Nottest = 1234;" "AtestNot = 1234;"))

  ;; ruby
  (:type "variable" :supports ("ag" "rg" "git-grep") :language "ruby"
         :regex "^\\s*((\\w+[.])*\\w+,\\s*)*JJJ(,\\s*(\\w+[.])*\\w+)*\\s*=([^=>~]|$)"
         :tests ("test = 1234" "self.foo, test, bar = args")
         :not ("if test == 1234" "foo_test = 1234"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "ruby"
         :regex "(^|[^\\w.])((private|public|protected)\\s+)?def\\s+(\\w+(::|[.]))*JJJ($|[^\\w|:])"
         :tests ("def test(foo)" "def test()" "def test foo" "def test; end"
                 "def self.test()" "def MODULE::test()" "private def test")
         :not ("def test_foo"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "ruby"
         :regex "(^|\\W)define(_singleton|_instance)?_method(\\s|[(])\\s*:JJJ($|[^\\w|:])"
         :tests ("define_method(:test, &body)"
                 "mod.define_instance_method(:test) { body }"))

  (:type "type" :supports ("ag" "rg" "git-grep") :language "ruby"
         :regex "(^|[^\\w.])class\\s+(\\w*::)*JJJ($|[^\\w|:])"
         :tests ("class test" "class Foo::test"))

  (:type "type" :supports ("ag" "rg" "git-grep") :language "ruby"
         :regex "(^|[^\\w.])module\\s+(\\w*::)*JJJ($|[^\\w|:])"
         :tests ("module test" "module Foo::test"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "ruby"
         :regex "(^|\\W)alias(_method)?\\W+JJJ(\\W|$)"
         :tests ("alias test some_method"
                 "alias_method :test, :some_method"
                 "alias_method 'test' 'some_method'"
                 "some_class.send(:alias_method, :test, :some_method)")
         :not ("alias some_method test"
               "alias_method :some_method, :test"
               "alias test_foo test"))

  ;; Groovy
  (:type "variable" :supports ("ag" "rg" "git-grep") :language "groovy"
         :regex "^\\s*((\\w+[.])*\\w+,\\s*)*JJJ(,\\s*(\\w+[.])*\\w+)*\\s*=([^=>~]|$)"
         :tests ("test = 1234" "self.foo, test, bar = args")
         :not ("if test == 1234" "foo_test = 1234"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "groovy"
         :regex "(^|[^\\w.])((private|public)\\s+)?def\\s+(\\w+(::|[.]))*JJJ($|[^\\w|:])"
         :tests ("def test(foo)" "def test()" "def test foo" "def test; end"
                 "def self.test()" "def MODULE::test()" "private def test")
         :not ("def test_foo"))

  (:type "type" :supports ("ag" "rg" "git-grep") :language "groovy"
         :regex "(^|[^\\w.])class\\s+(\\w*::)*JJJ($|[^\\w|:])"
         :tests ("class test" "class Foo::test"))

  ;; crystal
  (:type "variable" :supports ("ag" "rg" "git-grep") :language "crystal"
         :regex "^\\s*((\\w+[.])*\\w+,\\s*)*JJJ(,\\s*(\\w+[.])*\\w+)*\\s*=([^=>~]|$)"
         :tests ("test = 1234" "self.foo, test, bar = args")
         :not ("if test == 1234" "foo_test = 1234"))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "crystal"
         :regex "(^|[^\\w.])((private|public|protected)\\s+)?def\\s+(\\w+(::|[.]))*JJJ($|[^\\w|:])"
         :tests ("def test(foo)" "def test()" "def test foo" "def test; end"
                 "def self.test()" "def MODULE::test()" "private def test")
         :not ("def test_foo"))

  (:type "type" :supports ("ag" "rg" "git-grep") :language "crystal"
         :regex "(^|[^\\w.])class\\s+(\\w*::)*JJJ($|[^\\w|:])"
         :tests ("class test" "class Foo::test"))

  (:type "type" :supports ("ag" "rg" "git-grep") :language "crystal"
         :regex "(^|[^\\w.])module\\s+(\\w*::)*JJJ($|[^\\w|:])"
         :tests ("module test" "module Foo::test"))

  (:type "type" :supports ("ag" "rg" "git-grep") :language "crystal"
         :regex "(^|[^\\w.])struct\\s+(\\w*::)*JJJ($|[^\\w|:])"
         :tests ("struct test" "struct Foo::test"))

  (:type "type" :supports ("ag" "rg" "git-grep") :language "crystal"
         :regex "(^|[^\\w.])alias\\s+(\\w*::)*JJJ($|[^\\w|:])"
         :tests ("alias test" "alias Foo::test"))

  ;; scad
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "scad"
         :regex "\\s*\\bJJJ\\s*=[^=\\n]+" :tests ("test = 1234") :not ("if test == 1234 {"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "scad"
         :regex "function\\s*JJJ\\s*\\\("
         :tests ("function test()" "function test ()"))

  (:type "module" :supports ("ag" "grep" "rg" "git-grep") :language "scad"
         :regex "module\\s*JJJ\\s*\\\("
         :tests ("module test()" "module test ()"))

  ;; scala
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "scala"
         :regex "\\bval\\s*JJJ\\s*=[^=\\n]+" :tests ("val test = 1234") :not ("case test => 1234"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "scala"
         :regex "\\bvar\\s*JJJ\\s*=[^=\\n]+" :tests ("var test = 1234") :not ("case test => 1234"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "scala"
         :regex "\\btype\\s*JJJ\\s*=[^=\\n]+" :tests ("type test = 1234") :not ("case test => 1234"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "scala"
         :regex "\\bdef\\s*JJJ\\s*\\\("
         :tests ("def test(asdf)" "def test()"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "scala"
         :regex "class\\s*JJJ\\s*\\\(?"
         :tests ("class test(object)"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "scala"
         :regex "trait\\s*JJJ\\s*\\\(?"
         :tests ("trait test(object)"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "scala"
         :regex "object\\s*JJJ\\s*\\\(?"
         :tests ("object test(object)"))

  ;; R
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "r"
         :regex "\\bJJJ\\s*=[^=><]" :tests ("test = 1234") :not ("if (test == 1234)"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "r"
         :regex "\\bJJJ\\s*<-\\s*function\\b"
         :tests ("test <- function" "test <- function(")
         :not   ("test <- functionX"))

  ;; perl
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "perl"
         :regex "sub\\s*JJJ\\s*(\\{|\\()"
         :tests ("sub test{" "sub test {" "sub test(" "sub test ("))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "perl"
         :regex "JJJ\\s*=\\s*"
         :tests ("$test = 1234"))

  ;; shell
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "shell"
         :regex "function\\s*JJJ\\s*"
         :tests ("function test{" "function test {" "function test () {")
         :not   ("function nottest {"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "shell"
         :regex "JJJ\\\(\\\)\\s*\\{"
         :tests ("test() {")
         :not ("testx() {"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "shell"
         :regex "\\bJJJ\\s*=\\s*"
         :tests ("test = 1234") :not ("blahtest = 1234"))

  ;; php
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "php"
         :regex "function\\s*JJJ\\s*\\\("
         :tests ("function test()" "function test ()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "php"
         :regex "\\*\\s@method\\s+[^ 	]+\\s+JJJ\\("
         :tests ("/** @method string|false test($a)" " * @method bool test()"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "php"
         :regex "(\\s|->|\\$|::)JJJ\\s*=\\s*"
         :tests ("$test = 1234" "$foo->test = 1234"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "php"
         :regex "\\*\\s@property(-read|-write)?\\s+([^ 	]+\\s+)&?\\$JJJ(\\s+|$)"
         :tests ("/** @property string $test" "/** @property string $test description for $test property"  " * @property-read bool|bool $test" " * @property-write \\ArrayObject<string,resource[]> $test"))
  (:type "trait" :supports ("ag" "grep" "rg" "git-grep") :language "php"
         :regex "trait\\s*JJJ\\s*\\\{"
         :tests ("trait test{" "trait test {"))

  (:type "interface" :supports ("ag" "grep" "rg" "git-grep") :language "php"
         :regex "interface\\s*JJJ\\s*\\\{"
         :tests ("interface test{" "interface test {"))

  (:type "class" :supports ("ag" "grep" "rg" "git-grep") :language "php"
         :regex "class\\s*JJJ\\s*(extends|implements|\\\{)"
         :tests ("class test{" "class test {" "class test extends foo" "class test implements foo"))

  ;; dart
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "dart"
         :regex "\\bJJJ\\s*\\([^()]*\\)\\s*[{]"
         :tests ("test(foo) {" "test (foo){" "test(foo){"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "dart"
         :regex "class\\s*JJJ\\s*[\\\(\\\{]"
         :tests ("class test(object) {" "class test{"))

  ;; faust
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "faust"
         :regex "\\bJJJ\(\\\(.+\\\)\)*\\s*="
         :tests ("test = osc + 0.5;" "test(freq) = osc(freq) + 0.5;"))

  ;; fortran
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "fortran"
         :regex "\\s*\\bJJJ\\s*=[^=\\n]+"
         :tests ("test = 1234")
         :not ("if (test == 1234)"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "fortran"
         :regex "\\b(function|subroutine|FUNCTION|SUBROUTINE)\\s+JJJ\\b\\s*\\\("
         :tests ("function test (foo)" "integer function test(foo)"
                 "subroutine test (foo, bar)" "FUNCTION test (foo)"
                 "INTEGER FUNCTION test(foo)" "SUBROUTINE test (foo, bar)")
         :not ("end function test" "end subroutine test" "END FUNCTION test"
               "END SUBROUTINE test"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "fortran"
         :regex "^\\s*(interface|INTERFACE)\\s+JJJ\\b"
         :tests ("interface test" "INTERFACE test")
         :not ("interface test2" "end interface test" "INTERFACE test2"
               "END INTERFACE test"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "fortran"
         :regex "^\\s*(module|MODULE)\\s+JJJ\\s*"
         :tests ("module test" "MODULE test")
         :not ("end module test" "END MODULE test"))

  ;; go
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "go"
         :regex "\\s*\\bJJJ\\s*=[^=\\n]+" :tests ("test = 1234") :not ("if test == 1234 {"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "go"
         :regex "\\s*\\bJJJ\\s*:=\\s*" :tests ("test := 1234"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "go"
         :regex "func\\s+\\\([^\\\)]*\\\)\\s+JJJ\\s*\\\("
         :tests ("func (s *blah) test(filename string) string {"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "go"
         :regex "func\\s+JJJ\\s*\\\("
         :tests ("func test(url string) (string, error)"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "go"
         :regex "type\\s+JJJ\\s+struct\\s+\\\{"
         :tests ("type test struct {"))

  ;; javascript extended
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "javascript"
         :regex "(service|factory)\\\(['\"]JJJ['\"]" :tags ("angular")
         :tests ("module.factory('test', [\"$rootScope\", function($rootScope) {"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "javascript"
         :regex "\\bJJJ\\s*[=:]\\s*\\\([^\\\)]*\\\)\\s+=>" :tags ("es6")
         :tests ("const test = (foo) => " "test: (foo) => {" "  test: (foo) => {"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "javascript"
         :regex "\\bJJJ\\s*\\([^()]*\\)\\s*[{]" :tags ("es6")
         :tests ("test(foo) {" "test (foo){" "test(foo){")
         :not ("test = blah.then(function(){"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "javascript" :tags ("es6")
         :regex "class\\s*JJJ\\s*[\\\(\\\{]"
         :tests ("class test(object) {" "class test{"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "javascript" :tags ("es6")
         :regex "class\\s*JJJ\\s+extends"
         :tests ("class test extends Component{"))

  ;; javascript
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "javascript"
         :regex "\\s*\\bJJJ\\s*=[^=\\n]+" :tests ("test = 1234" "const test = props =>") :not ("if (test === 1234)"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "javascript"
         :regex "\\bfunction\\b[^\\(]*\\\(\\s*[^\\)]*\\bJJJ\\b\\s*,?\\s*\\\)?"
         :tests ("function (test)" "function (test, blah)" "function somefunc(test, blah) {" "function(blah, test)")
         :not ("function (testLen)" "function (test1, blah)" "function somefunc(testFirst, blah) {" "function(blah, testLast)"
               "function (Lentest)" "function (blahtest, blah)" "function somefunc(Firsttest, blah) {" "function(blah, Lasttest)"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "javascript"
         :regex "function\\s*JJJ\\s*\\\("
         :tests ("function test()" "function test ()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "javascript"
         :regex "\\bJJJ\\s*:\\s*function\\s*\\\("
         :tests ("test: function()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "javascript"
         :regex "\\bJJJ\\s*=\\s*function\\s*\\\("
         :tests ("test = function()"))

  ;; typescript
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "(service|factory)\\\(['\"]JJJ['\"]" :tags ("angular")
         :tests ("module.factory('test', [\"$rootScope\", function($rootScope) {"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "\\bJJJ\\s*[=:]\\s*\\\([^\\\)]*\\\)\\s+=>"
         :tests ("const test = (foo) => " "test: (foo) => {" "  test: (foo) => {"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "\\bJJJ\\s*\\([^()]*\\)\\s*[{]"
         :tests ("test(foo) {" "test (foo){" "test(foo){")
         :not ("test = blah.then(function(){"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "class\\s*JJJ\\s*[\\\(\\\{]"
         :tests ("class test{"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "class\\s*JJJ\\s+extends"
         :tests ("class test extends Component{"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "function\\s*JJJ\\s*\\\("
         :tests ("function test()" "function test ()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "\\bJJJ\\s*:\\s*function\\s*\\\("
         :tests ("test: function()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "\\bJJJ\\s*=\\s*function\\s*\\\("
         :tests ("test = function()"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "\\s*\\bJJJ\\s*=[^=\\n]+" :tests ("test = 1234" "const test = props =>") :not ("if (test === 1234)"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
         :regex "\\bfunction\\b[^\\(]*\\\(\\s*[^\\)]*\\bJJJ\\b\\s*,?\\s*\\\)?"
         :tests ("function (test)" "function (test, blah)" "function somefunc(test, blah) {" "function(blah, test)")
         :not ("function (testLen)" "function (test1, blah)" "function somefunc(testFirst, blah) {" "function(blah, testLast)"
               "function (Lentest)" "function (blahtest, blah)" "function somefunc(Firsttest, blah) {" "function(blah, Lasttest)"))

  ;; julia
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "julia"
         :regex "(@noinline|@inline)?\\s*function\\s*JJJ(\\{[^\\}]*\\})?\\("
         :tests ("function test()" "@inline function test()"
                 "function test{T}(h)"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "julia"
         :regex "(@noinline|@inline)?JJJ(\\{[^\\}]*\\})?\\([^\\)]*\\)\s*="
         :tests ("test(a)=1" "test(a,b)=1*8"
                 "@noinline test()=1" "test{T}(x)=x"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "julia"
         :regex "macro\\s*JJJ\\("
         :tests ("macro test(a)=1" " macro test(a,b)=1*8"))

  (:type "variable" :supports ("ag" "rg") :language "julia"
         :regex "const\\s+JJJ\\b"
         :tests ("const test = "))

  (:type "type" :supports ("ag" "rg") :language "julia"
         :regex "(mutable)?\\s*struct\\s*JJJ"
         :tests ("struct test"))

  (:type "type" :supports ("ag" "rg") :language "julia"
         :regex "(type|immutable|abstract)\\s*JJJ"
         :tests ("type test" "immutable test" "abstract test <:Testable" ))

  ;; haskell
  (:type "module" :supports ("ag" "rg") :language "haskell"
         :regex "^module\\s+JJJ\\s+"
         :tests ("module Test (exportA, exportB) where"))

  ; TODO Doesn't support any '=' in arguments. E.g. 'foo A{a = b,..} = bar'.
  (:type "top level function" :supports ("ag" "rg") :language "haskell"
         :regex "^\\bJJJ(?!(\\s+::))\\s+((.|\\s)*?)=\\s+"
         :tests ("test n = n * 2"
                 "test X{..} (Y a b c) \n bcd \n =\n x * y"
                 "test ab cd e@Datatype {..} (Another thing, inTheRow) = \n undefined"
                 "test = runRealBasedMode @ext @ctx identity identity"
                 "test unwrap wrap nr@Naoeu {..} (Action action, specSpecs) = \n    undefined")
         :not ("nottest n = n * 2"
               "let testnot x y = x * y" "test $ y z" "let test a o = mda"
               "test :: Sometype -> AnotherType aoeu kek = undefined"))

  (:type "type-like" :supports ("ag" "rg") :language "haskell"
         :regex "^\\s*((data(\\s+family)?)|(newtype)|(type(\\s+family)?))\\s+JJJ\\s+"
         :tests ("newtype Test a = Something { b :: Kek }"
                 "data Test a b = Somecase a | Othercase b"
                 "type family Test (x :: *) (xs :: [*]) :: Nat where"
                 "data family Test "
                 "type Test = TestAlias")
         :not ("newtype NotTest a = NotTest (Not a)"
               "data TestNot b = Aoeu"))

  ; datatype contstuctor that doesn't match type definition.
  (:type "(data)type constructor 1" :supports ("ag" "rg") :language "haskell"
         :regex "(data|newtype)\\s{1,3}(?!JJJ\\s+)([^=]{1,40})=((\\s{0,3}JJJ\\s+)|([^=]{0,500}?((?<!(-- ))\\|\\s{0,3}JJJ\\s+)))"
         :tests ("data Something a = Test { b :: Kek }"
                 "data Mem a = TrueMem { b :: Kek } | Test (Mem Int) deriving Mda"
                 "newtype SafeTest a = Test (Kek a) deriving (YonedaEmbedding)")
         :not ("data Test = Test { b :: Kek }"))


  (:type "data/newtype record field" :supports ("ag" "rg") :language "haskell"
         :regex "(data|newtype)([^=]*)=[^=]*?({([^=}]*?)(\\bJJJ)\\s+::[^=}]+})"
         :tests ("data Mem = Mem { \n mda :: A \n  , test :: Kek \n , \n aoeu :: E \n }"
                 "data Mem = Mem { \n test :: A \n  , mda :: Kek \n , \n aoeu :: E \n }"
                 "data Mem = Mem { \n mda :: A \n  , aoeu :: Kek \n , \n test :: E \n }"
                 "data Mem = Mem { test :: Kek } deriving Mda"
                 "data Mem = Mem { \n test :: Kek \n } deriving Mda"
                 "newtype Mem = Mem { \n test :: Kek \n } deriving (Eq)"
                 "newtype Mem = Mem { -- | Some docs \n test :: Kek -- ^ More docs } deriving Eq"
                 "newtype Mem = Mem { test :: Kek } deriving (Eq,Monad)"
                 "newtype NewMem = OldMem { test :: [Tx] }"
                 "newtype BlockHeaderList ssc = BHL\n { test :: ([Aoeu a], [Ssss])\n    } deriving (Eq)")
         :not ("data Heh = Mda { sometest :: Kek, testsome :: Mem }"))

  (:type "typeclass" :supports ("ag" "rg") :language "haskell"
         :regex "^class\\s+(.+=>\\s*)?JJJ\\s+"
         :tests (
                 "class (Constr1 m, Constr 2) => Test (Kek a) where"
                 "class  Test  (Veryovka a)  where ")
         :not ("class Test2 (Kek a) where"
               "class MakeTest (AoeuTest x y z) where"))

  ;; ocaml
  (:type "type" :supports ("ag" "rg") :language "ocaml"
         :regex "^\\s*(and|type)\\s+.*\\bJJJ\\b"
         :tests ("type test ="
                 "and test ="
                 "type 'a test ="
                 "type ('a, _, 'c) test"))

  (:type "variable" :supports ("ag" "rg") :language "ocaml"
         :regex "let\\s+JJJ\\b"
         :tests ("let test ="
                 "let test x y ="))

  (:type "variable" :supports ("ag" "rg") :language "ocaml"
         :regex "let\\s+rec\\s+JJJ\\b"
         :tests ("let rec test ="
                 "let rec  test x y ="))

  (:type "variable" :supports ("ag" "rg") :language "ocaml"
         :regex "\\s*val\\s*\\bJJJ\\b\\s*"
         :tests ("val test"))

  (:type "module" :supports ("ag" "rg") :language "ocaml"
         :regex "^\\s*module\\s*\\bJJJ\\b"
         :tests ("module test ="))

  (:type "module" :supports ("ag" "rg") :language "ocaml"
         :regex "^\\s*module\\s*type\\s*\\bJJJ\\b"
         :tests ("module type test ="))

  ;; lua
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "lua"
         :regex "\\s*\\bJJJ\\s*=[^=\\n]+" :tests ("test = 1234") :not ("if test === 1234"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "lua"
         :regex "\\bfunction\\b[^\\(]*\\\(\\s*[^\\)]*\\bJJJ\\b\\s*,?\\s*\\\)?"
         :tests ("function (test)" "function (test, blah)" "function somefunc(test, blah)" "function(blah, test)")
         :not ("function (testLen)" "function (test1, blah)" "function somefunc(testFirst, blah)" "function(blah, testLast)"
               "function (Lentest)" "function (blahtest, blah)" "function somefunc(Firsttest, blah)" "function(blah, Lasttest)"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "lua"
         :regex "function\\s*JJJ\\s*\\\("
         :tests ("function test()" "function test ()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "lua"
         :regex "function\\s*.+[.:]JJJ\\s*\\\("
         :tests ("function MyClass.test()" "function MyClass.test ()"
                 "function MyClass:test()" "function MyClass:test ()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "lua"
         :regex "\\bJJJ\\s*=\\s*function\\s*\\\("
         :tests ("test = function()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "lua"
         :regex "\\b.+\\.JJJ\\s*=\\s*function\\s*\\\("
         :tests ("MyClass.test = function()"))

  ;; rust
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "\\blet\\s+(\\\([^=\\n]*)?(mut\s+)?JJJ([^=\\n]*\\\))?(:\\s*[^=\\n]+)?\\s*=\\s*[^=\\n]+"
         :tests ("let test = 1234;"
                 "let test: u32 = 1234;"
                 "let test: Vec<u32> = Vec::new();"
                 "let mut test = 1234;"
                 "let mut test: Vec<u32> = Vec::new();"
                 "let (a, test, b) = (1, 2, 3);"
                 "let (a, mut test, mut b) = (1, 2, 3);"
                 "let (mut a, mut test): (u32, usize) = (1, 2);"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "\\bconst\\s+JJJ:\\s*[^=\\n]+\\s*=[^=\\n]+"
         :tests ("const test: u32 = 1234;"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "\\bstatic\\s+(mut\\s+)?JJJ:\\s*[^=\\n]+\\s*=[^=\\n]+"
         :tests ("static test: u32 = 1234;"
                 "static mut test: u32 = 1234;"))

  ;; variable in method signature
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "\\bfn\\s+.+\\s*\\\((.+,\\s+)?JJJ:\\s*[^=\\n]+\\s*(,\\s*.+)*\\\)"
         :tests ("fn abc(test: u32) -> u32 {"
                 "fn abc(x: u32, y: u32, test: Vec<u32>, z: Vec<Foo>)"
                 "fn abc(x: u32, y: u32, test: &mut Vec<u32>, z: Vec<Foo>)"))

  ;; "if let" and "while let" desugaring
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "(if|while)\\s+let\\s+([^=\\n]+)?(mut\\s+)?JJJ([^=\\n\\\(]+)?\\s*=\\s*[^=\\n]+"
         :tests ("if let Some(test) = abc() {"
                 "if let Some(mut test) = abc() {"
                 "if let Ok(test) = abc() {"
                 "if let Ok(mut test) = abc() {"
                 "if let Foo(mut test) = foo {"
                 "if let test = abc() {"
                 "if let Some(test) = abc()"
                 "if let Some((a, test, b)) = abc()"
                 "while let Some(test) = abc() {"
                 "while let Some(mut test) = abc() {"
                 "while let Ok(test) = abc() {"
                 "while let Ok(mut test) = abc() {")
         :not ("while let test(foo) = abc() {"))

  ;; structure fields
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "struct\\s+[^\\n{]+[{][^}]*(\\s*JJJ\\s*:\\s*[^\\n},]+)[^}]*}"
         :tests ("struct Foo { abc: u32, test: Vec<String>, b: PathBuf }"
                 "struct Foo<T>{test:Vec<T>}"
                 "struct FooBar<'a> { test: Vec<String> }")
         :not ("struct Foo { abc: u32, b: Vec<String> }"
               "/// ... construct the equivalent ...\nfn abc() {\n"))

  ;; enum variants
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "enum\\s+[^\\n{]+\\s*[{][^}]*\\bJJJ\\b[^}]*}"
         :tests ("enum Foo { VariantA, test, VariantB(u32) }"
                 "enum Foo<T> { test(T) }"
                 "enum BadStyle{test}"
                 "enum Foo32 { Bar, testing, test(u8) }")
         :not ("enum Foo { testing }"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "\\bfn\\s+JJJ\\s*\\\("
         :tests ("fn test(asdf: u32)" "fn test()" "pub fn test()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "\\bmacro_rules!\\s+JJJ"
         :tests ("macro_rules! test"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "struct\\s+JJJ\\s*[{\\\(]?"
         :tests ("struct test(u32, u32)"
                 "struct test;"
                 "struct test { abc: u32, def: Vec<String> }"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "trait\\s+JJJ\\s*[{]?"
         :tests ("trait test;" "trait test { fn abc() -> u32; }"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "\\btype\\s+JJJ([^=\\n]+)?\\s*=[^=\\n]+;"
         :tests ("type test<T> = Rc<RefCell<T>>;"
                 "type test = Arc<RwLock<Vec<u32>>>;"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "impl\\s+((\\w+::)*\\w+\\s+for\\s+)?(\\w+::)*JJJ\\s+[{]?"
         :tests ("impl test {"
                 "impl abc::test {"
                 "impl std::io::Read for test {"
                 "impl std::io::Read for abc::test {"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "rust"
         :regex "mod\\s+JJJ\\s*[{]?"
         :tests ("mod test;" "pub mod test {"))

  ;; elixir
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "elixir"
         :regex "\\bdef(p)?\\s+JJJ\\s*[ ,\\\(]"
         :tests ("def test do"
                 "def test, do:"
                 "def test() do"
                 "def test(), do:"
                 "def test(foo, bar) do"
                 "def test(foo, bar), do:"
                 "defp test do"
                 "defp test(), do:"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "elixir"
         :regex "\\s*JJJ\\s*=[^=\\n]+"
         :tests ("test = 1234")
         :not ("if test == 1234"))

  (:type "module" :supports ("ag" "grep" "rg" "git-grep") :language "elixir"
         :regex "defmodule\\s+(\\w+\\.)*JJJ\\s+"
         :tests ("defmodule test do"
                 "defmodule Foo.Bar.test do"))

  (:type "module" :supports ("ag" "grep" "rg" "git-grep") :language "elixir"
         :regex "defprotocol\\s+(\\w+\\.)*JJJ\\s+"
         :tests ("defprotocol test do"
                 "defprotocol Foo.Bar.test do"))

  ;; erlang
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "erlang"
         :regex "^JJJ\\b\\s*\\\("
         :tests ("test() ->"
                 "test()->"
                 "test(Foo) ->"
                 "test (Foo,Bar) ->"
                 "test(Foo, Bar)->"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "erlang"
         :regex "\\s*JJJ\\s*=[^:=\\n]+"
         :tests ("test = 1234")
         :not ("if test =:= 1234"
               "if test == 1234"))

  (:type "module" :supports ("ag" "grep" "rg" "git-grep") :language "erlang"
         :regex "^-module\\\(JJJ\\\)"
         :tests ("-module(test)."))

  ;; scss
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "scss"
         :regex "@mixin\\sJJJ\\b\\s*\\\("
         :tests ("@mixin test()"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "scss"
         :regex "@function\\sJJJ\\b\\s*\\\("
         :tests ("@function test()"))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "scss"
         :regex "JJJ\\s*:\\s*"
         :tests ("test  :"))

  ;; sml
  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "sml"
         :regex "\\s*(data)?type\\s+.*\\bJJJ\\b"
         :tests ("datatype test ="
                 "datatype test="
                 "datatype 'a test ="
                 "type test ="
                 "type 'a test ="
                 "type 'a test"
                 "type test")
         :not ("datatypetest ="))

  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "sml"
         :regex "\\s*val\\s+\\bJJJ\\b"
         :tests ("val test ="
                 "val test="
                 "val test : bool"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "sml"
         :regex "\\s*fun\\s+\\bJJJ\\b.*\\s*="
         :tests ("fun test list ="
                 "fun test (STRING_NIL, a) ="
                 "fun test ((s1,s2): 'a queue) : 'a * 'a queue ="
                 "fun test (var : q) : int ="
                 "fun test f e xs ="))

  (:type "module" :supports ("ag" "grep" "rg" "git-grep") :language "sml"
         :regex "\\s*(structure|signature|functor)\\s+\\bJJJ\\b"
         :tests ("structure test ="
                 "structure test : MYTEST ="
                 "signature test ="
                 "functor test (T:TEST) ="
                 "functor test(T:TEST) ="))

  ;; sql
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "sql"
         :regex "(CREATE|create)\\s+(.+?\\s+)?(FUNCTION|function|PROCEDURE|procedure)\\s+JJJ\\s*\\\("
         :tests ("CREATE FUNCTION test(i INT) RETURNS INT"
                 "create or replace function test (int)"
                 "CREATE PROCEDURE test (OUT p INT)"
                 "create definer = 'test'@'localhost' procedure test()"))

  (:type "table" :supports ("ag" "grep" "rg" "git-grep") :language "sql"
         :regex "(CREATE|create)\\s+(.+?\\s+)?(TABLE|table)(\\s+(IF NOT EXISTS|if not exists))?\\s+JJJ\\b"
         :tests ("CREATE TABLE test ("
                 "create temporary table if not exists test"
                 "CREATE TABLE IF NOT EXISTS test ("
                 "create global temporary table test"))

  (:type "view" :supports ("ag" "grep" "rg" "git-grep") :language "sql"
         :regex "(CREATE|create)\\s+(.+?\\s+)?(VIEW|view)\\s+JJJ\\b"
         :tests ("CREATE VIEW test ("
                 "create sql security definer view test"
                 "CREATE OR REPLACE VIEW test AS foo"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "sql"
         :regex "(CREATE|create)\\s+(.+?\\s+)?(TYPE|type)\\s+JJJ\\b"
         :tests ("CREATE TYPE test"
                 "CREATE OR REPLACE TYPE test AS foo ("
                 "create type test as ("))

  ;; systemverilog
  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "systemverilog"
         :regex "\\s*class\\s+\\bJJJ\\b"
         :tests ("virtual class test;" "class test;" "class test extends some_class")
         :not ("virtual class testing;" "class test2;" "class some_test" "class some_class extends test"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "systemverilog"
         :regex "\\s*task\\s+\\bJJJ\\b"
         :tests ("task test (" "task test(")
         :not ("task testing (" "task test2("))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "systemverilog"
         :regex "\\s*\\bJJJ\\b\\s*="
         :tests ("assign test =" "assign test=" "int test =" "int test=")
         :not ("assign testing =" "assign test2="))

  (:type "function" :supports ("ag" "rg" "git-grep") :language "systemverilog"
         :regex "function\\s[^\\s]+\\s*\\bJJJ\\b"
         :tests ("function Matrix test ;" "function Matrix test;")
         :not ("function test blah"))

      ;; matches SV class handle declarations
  (:type "function" :supports ("ag" "rg" "git-grep") :language "systemverilog"
         :regex "^\\s*[^\\s]*\\s*[^\\s]+\\s+\\bJJJ\\b"
         :tests ("some_class_name test" "  another_class_name  test ;" "some_class test[];" "some_class #(1) test")
         :not ("test some_class_name" "class some_class extends test"))

  ;; vhdl
  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "vhdl"
         :regex "\\s*type\\s+\\bJJJ\\b"
         :tests ("type test is" "type test  is")
         :not ("type testing is" "type test2  is"))

  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "vhdl"
         :regex "\\s*constant\\s+\\bJJJ\\b"
         :tests ("constant test :" "constant test:")
         :not ("constant testing " "constant test2:"))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "vhdl"
         :regex "function\\s*\"?JJJ\"?\\s*\\\("
         :tests ("function test(signal)" "function test (signal)" "function \"test\" (signal)")
         :not ("function testing(signal"))

  ;; latex
  (:type "command" :supports ("ag" "grep" "rg" "git-grep") :language "tex"
         :regex "\\\\.*newcommand\\\*?\\s*\\\{\\s*(\\\\)JJJ\\s*}"
         :tests ("\\newcommand{\\test}" "\\renewcommand{\\test}" "\\renewcommand*{\\test}" "\\newcommand*{\\test}" "\\renewcommand{ \\test }")
         :not("\\test"  "test"))

  (:type "command" :supports ("ag" "grep" "rg" "git-grep") :language "tex"
         :regex "\\\\.*newcommand\\\*?\\s*(\\\\)JJJ\\j"
         :tests ("\\newcommand\\test {}" "\\renewcommand\\test{}" "\\newcommand \\test")
         :not("\\test"  "test"))

  (:type "length" :supports ("ag" "grep" "rg" "git-grep") :language "tex"
         :regex "\\\\(s)etlength\\s*\\\{\\s*(\\\\)JJJ\\s*}"
         :tests ("\\setlength { \\test}" "\\setlength{\\test}" "\\setlength{\\test}{morecommands}" )
         :not("\\test"  "test"))

  (:type "counter" :supports ("ag" "grep" "rg" "git-grep") :language "tex"
         :regex "\\\\newcounter\\\{\\s*JJJ\\s*}"
         :tests ("\\newcounter{test}" )
         :not("\\test"  "test"))

  (:type "environment" :supports ("ag" "grep" "rg" "git-grep") :language "tex"
         :regex "\\\\.*newenvironment\\s*\\\{\\s*JJJ\\s*}"
         :tests ("\\newenvironment{test}" "\\newenvironment {test}{morecommands}" "\\lstnewenvironment{test}" "\\newenvironment {test}" )
         :not("\\test"  "test" ))

  ;; pascal (todo: var, type, const)
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "pascal"
         :regex "\\bfunction\\s+JJJ\\b"
         :tests ("  function test : "))

  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "pascal"
         :regex "\\bprocedure\\s+JJJ\\b"
         :tests ("  procedure test ; "))

  ;; f#
  (:type "variable" :supports ("ag" "grep" "git-grep") :language "fsharp"
   :regex "let\\s+JJJ\\b.*\\\="
   :tests ("let test = 1234" "let test() = 1234" "let test abc def = 1234")
   :not ("let testnot = 1234" "let testnot() = 1234" "let testnot abc def = 1234"))

  (:type "interface" :supports ("ag" "grep" "git-grep") :language "fsharp"
   :regex "member(\\b.+\\.|\\s+)JJJ\\b.*\\\="
   :tests ("member test = 1234" "member this.test = 1234")
   :not ("member testnot = 1234" "member this.testnot = 1234"))

  (:type "type" :supports ("ag" "grep" "git-grep") :language "fsharp"
   :regex "type\\s+JJJ\\b.*\\\="
   :tests ("type test = 1234")
   :not ("type testnot = 1234"))

  ;; kotlin
  (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "kotlin"
         :regex "fun\\s*(<[^>]*>)?\\s*JJJ\\s*\\("
         :tests ("fun test()" "fun <T> test()"))
  (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "kotlin"
         :regex "(val|var)\\s*JJJ\\b"
         :not ("val testval" "var testvar")
         :tests ("val test " "var test"))
  (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "kotlin"
         :regex "(class|interface)\\s*JJJ\\b"
         :tests ("class test" "class test : SomeInterface" "interface test"))

  ;; protobuf
  (:type "message" :supports ("ag" "grep" "rg" "git-grep") :language "protobuf"
         :regex "message\\s+JJJ\\s*\\\{"
         :tests ("message test{" "message test {"))

  (:type "enum" :supports ("ag" "grep" "rg" "git-grep") :language "protobuf"
         :regex "enum\\s+JJJ\\s*\\\{"
         :tests ("enum test{" "enum test {")))
