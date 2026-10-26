#lang eopl
;Autores: Andres Felipe Chaparro 2266252
;; Sintaxis concreta de Cauca. Define el scanner, el parser y los datatypes del AST.

(define especificacion-lexica
  '((whitespace (whitespace) skip)
    (comentario ("//" (arbno (not #\newline))) skip)
    (identifier (letter (arbno (or letter digit "_" "?"))) symbol)
    (number (digit (arbno digit) "." digit (arbno digit)) number)
    (number ("-" digit (arbno digit) "." digit (arbno digit)) number)
    (number (digit (arbno digit)) number)
    (number ("-" digit (arbno digit)) number)))

(define especificacion-gramatical
  '((programa (expresion) a-program)
    (expresion (number) lit-exp)
    (expresion (identifier) var-exp)
    (expresion ("true") true-exp)
    (expresion ("false") false-exp)
    (expresion (primitiva "(" (separated-list expresion ",") ")") prim-exp)
    (expresion ("if" expresion "then" expresion "else" expresion "end") if-exp)
    (expresion ("let" (arbno identifier "=" expresion) "in" expresion "end") let-exp)
    (expresion ("proc" "(" (separated-list identifier ",") ")" expresion "end") proc-exp)
    (expresion ("apply" expresion "(" (separated-list expresion ",") ")") app-exp)
    (expresion ("letrec" (arbno identifier "(" (separated-list identifier ",") ")" "=" expresion) "in" expresion "end") letrec-exp)
    ;; arbno produce las listas paralelas de valores/acciones; parser valida que no estén vacías.
    (expresion ("case" expresion (arbno "of" number "=>" expresion) "otherwise" "=>" expresion "end") case-exp)
    (primitiva ("+") sum-prim)
    (primitiva ("-") minus-prim)
    (primitiva ("*") mult-prim)
    (primitiva ("/") div-prim)
    (primitiva ("add1") add-prim)
    (primitiva ("sub1") sub-prim)
    (primitiva (">") mayor-prim)
    (primitiva (">=") mayorigual-prim)
    (primitiva ("<") menor-prim)
    (primitiva ("<=") menorigual-prim)
    (primitiva ("==") igual-prim)
    (primitiva ("not") not-prim)
    (primitiva ("and") and-prim)
    (primitiva ("or") or-prim)
    (primitiva ("abs") abs-prim)
    (primitiva ("mcd") mcd-prim)
    (primitiva ("mcm") mcm-prim)
    (primitiva ("promedio") promedio-prim)
    (primitiva ("xor") xor-prim)
    (primitiva ("implica") implica-prim)
    (primitiva ("entre") entre-prim)))

;; Los tipos programa, expresion y primitiva se generan a partir de la gramática.
(sllgen:make-define-datatypes especificacion-lexica especificacion-gramatical)

;; mostrar-datatypes : -> void. Muestra los datatypes creados por SLLGEN.
(define mostrar-datatypes
  (lambda ()
    (sllgen:list-define-datatypes especificacion-lexica especificacion-gramatical)))

;; scanner : string -> lista de tokens. Convierte texto en tokens léxicos.
(define scanner
  (sllgen:make-string-scanner especificacion-lexica especificacion-gramatical))

;; parser-sin-validar : string -> programa. Parser SLLGEN generado desde la gramática.
(define parser-sin-validar
  (sllgen:make-string-parser especificacion-lexica especificacion-gramatical))

;; validar-lista-expresiones : lista-de-expresiones -> boolean. Valida recursivamente
;; las expresiones contenidas en listas de argumentos, ramas o cuerpos recursivos.
(define validar-lista-expresiones
  (lambda (expresiones)
    (if (null? expresiones)
        #t
        (begin
          (validar-expresion-sintactica (car expresiones))
          (validar-lista-expresiones (cdr expresiones))))))

;; operador-app-exp? : expresion -> boolean. Detecta una aplicación usada directamente
;; como operador de otra aplicación, forma que el lenguaje excluye.
(define operador-app-exp?
  (lambda (exp)
    (cases expresion exp
      (app-exp (rator rands) #t)
      (else #f))))

;; validar-expresion-sintactica : expresion -> boolean. Verifica restricciones de la
;; gramática que SLLGEN expresa como arbno (cero o más), pero Cauca exige en case al
;; menos una rama; también rechaza aplicaciones anidadas directamente como operador.
(define validar-expresion-sintactica
  (lambda (exp)
    (cases expresion exp
      (lit-exp (dato) #t)
      (var-exp (id) #t)
      (true-exp () #t)
      (false-exp () #t)
      (prim-exp (prim rands) (validar-lista-expresiones rands))
      (if-exp (test true-exp false-exp)
        (begin
          (validar-expresion-sintactica test)
          (validar-expresion-sintactica true-exp)
          (validar-expresion-sintactica false-exp)))
      (let-exp (ids rands body)
        (begin
          (validar-lista-expresiones rands)
          (validar-expresion-sintactica body)))
      (proc-exp (ids body) (validar-expresion-sintactica body))
      (app-exp (rator rands)
        (if (operador-app-exp? rator)
            (eopl:error 'parser
                        "Una aplicación no puede ser operador directo de otra; use let")
            (begin
              (validar-expresion-sintactica rator)
              (validar-lista-expresiones rands))))
      (letrec-exp (proc-names idss bodies body)
        (begin
          (validar-lista-expresiones bodies)
          (validar-expresion-sintactica body)))
      (case-exp (control valores acciones default)
        (if (null? valores)
            (eopl:error 'parser "case requiere al menos una rama of")
            (begin
              (validar-expresion-sintactica control)
              (validar-lista-expresiones acciones)
              (validar-expresion-sintactica default)))))))

;; parser : string -> programa. Analiza el texto y rechaza construcciones que Cauca
;; excluye aunque la forma general de arbno de SLLGEN pueda reconocerlas.
(define parser
  (lambda (texto)
    (let ((pgm (parser-sin-validar texto)))
      (cases programa pgm
        (a-program (exp) (validar-expresion-sintactica exp)))
      pgm)))

(provide (all-defined-out))
