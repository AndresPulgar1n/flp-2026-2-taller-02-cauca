#lang eopl
;Autores: Andres Felipe Chaparro 2266252
;; Fachada que reúne y reexporta los seis módulos del intérprete.
(require "src/sintaxis.rkt")
(require "src/valores.rkt")
(require "src/ambiente.rkt")
(require "src/primitivas.rkt")
(require "src/interprete.rkt")
(require "src/interfaz.rkt")
(provide (all-from-out "src/sintaxis.rkt"
                       "src/valores.rkt"
                       "src/ambiente.rkt"
                       "src/primitivas.rkt"
                       "src/interprete.rkt"
                       "src/interfaz.rkt"))

;; Ejemplos de scanner (las clases de tokens esperadas se anotan al lado):
;; (scanner "add1(n)")                    ; primitiva, paréntesis, identificador
;; (scanner "-3.5")                        ; número negativo decimal
;; (scanner "// comentario\ntrue")      ; el comentario se omite; queda true
;; (scanner "let x = 2 in x end")          ; palabras clave, identificador y número
;; (scanner "apply f (1, 2)")              ; apply, identificadores, números y separador
;;
;; Ejemplos de parser (estructura principal esperada):
;; (parser "42")                            ; a-program(lit-exp(42))
;; (parser "if >(n, m) then n else m end") ; a-program(if-exp(...))
;; (parser "let x = 2 y = 3 in *(x, y) end") ; a-program(let-exp(...))
;; (parser "proc (x) add1(x) end")          ; a-program(proc-exp(...))
;; (parser "case n of 1 => 10 otherwise => 0 end") ; a-program(case-exp(...))
;;
;; Ejemplos de ejecución (resultado esperado):
;; (interpretar "let x = 2 y = 3 in *(x, y) end") ; 6
;; (interpretar "+(1, 2, 3)")                   ; 6
;; (interpretar "-(10, 3, 2)")                  ; 5
;; (interpretar "*(2, 3, 4)")                   ; 24
;; (interpretar "/(100, 5, 2)")                 ; 10
;; (interpretar "add1(n)")                      ; 11
;; (interpretar "sub1(n)")                      ; 9
;; (interpretar ">=(m, m)")                     ; #t
;; (interpretar "<(q, r)")                      ; #t
;; (interpretar "<=(r, q)")                     ; #f
;; (interpretar "==(n, 10)")                    ; #t
;; (interpretar "not(true)")                    ; #f
;; (interpretar "and(true, false)")             ; #f
;; (interpretar "or(true, false)")              ; #t
;; (interpretar "if >(n, m) then n else m end") ; 10
;; (interpretar "promedio(1, 2, 3, 4)") ; 5/2
;; (interpretar "mcd(12, 18, 24)") ; 6
;; (interpretar "xor(true, false)") ; #t
;; (interpretar "entre(5, 1, 10)") ; #t
;; (interpretar "let f = proc (x) add1(x) end in apply f (9) end") ; 10
;; (interpretar "letrec fact (n) = if ==(n, 0) then 1 else *(n, apply fact (sub1(n))) end in apply fact (5) end") ; 120
;; (interpretar "case 3 of 1 => 10 of 3 => 30 otherwise => 0 end") ; 30
;; (interpretar "let factor = 10 in let escalar = proc (v) *(v, factor) end in let factor = 1000 in apply escalar (5) end end end") ; 50
;; Errores esperados:
;; (interpretar "if 1 then 2 else 3 end") ; condición no booleana
;; (interpretar "desconocida") ; variable no ligada
;; (interpretar "apply 5 (1)") ; operador no procedimiento
;; (interpretar "let f = proc (a, b) +(a, b) end in apply f (1) end") ; aridad incorrecta
;; (interpretar "+(1, true)") ; argumento de tipo incorrecto
;; (interpretar "case true of 1 => 1 otherwise => 0 end") ; control de case no numérico

;; Ejemplos adicionales de ejecución: primitivas de la Parte 2.
;; abs (tres resultados y un error de tipo)
;; (interpretar "abs(7)")             ; 7
;; (interpretar "abs(-7)")            ; 7
;; (interpretar "abs(-3.5)")          ; 3.5
;; (interpretar "abs(true)")          ; error: se esperaba un número
;; mcd (tres resultados y un error de tipo)
;; (interpretar "mcd(12, 18)")         ; 6
;; (interpretar "mcd(7, 13)")          ; 1
;; (interpretar "mcd(12, 18, 24)")     ; 6
;; (interpretar "mcd(1.5, 2)")         ; error: se esperaban enteros
;; mcm (tres resultados y un error de tipo)
;; (interpretar "mcm(4, 6)")           ; 12
;; (interpretar "mcm(3, 5)")           ; 15
;; (interpretar "mcm(2, 3, 4)")        ; 12
;; (interpretar "mcm(false, 2)")       ; error: se esperaban enteros
;; promedio (tres resultados y un error de tipo)
;; (interpretar "promedio(1, 2, 3, 4)") ; 5/2
;; (interpretar "promedio(10)")         ; 10
;; (interpretar "promedio(n, m)")       ; 13/2
;; (interpretar "promedio(true, 2)")    ; error: se esperaba un número
;; xor (tres resultados y un error de tipo)
;; (interpretar "xor(true, false)")     ; #t
;; (interpretar "xor(true, true)")      ; #f
;; (interpretar "xor(false, false)")    ; #f
;; (interpretar "xor(1, true)")         ; error: se esperaban booleanos
;; implica (tres resultados y un error de tipo)
;; (interpretar "implica(true, false)") ; #f
;; (interpretar "implica(false, false)") ; #t
;; (interpretar "implica(true, true)")  ; #t
;; (interpretar "implica(true, 2)")     ; error: se esperaban booleanos
;; entre (tres resultados y un error de tipo)
;; (interpretar "entre(5, 1, 10)")      ; #t
;; (interpretar "entre(1, 1, 10)")      ; #t
;; (interpretar "entre(11, 1, 10)")    ; #f
;; (interpretar "entre(true, 1, 3)")   ; error: se esperaba un número

;; Ejemplos adicionales de procedimientos (Parte 3).
;; (interpretar "let f = proc () 7 end in apply f () end") ; 7
;; (interpretar "let f = proc (x) add1(x) end in apply f (9) end") ; 10
;; (interpretar "let f = proc (a, b, c) +(a, b, c) end in apply f (1, 2, 3) end") ; 6
;; (interpretar "let aplicardos = proc (f, x) apply f (apply f (x)) end doble = proc (v) *(v, 2) end in apply aplicardos (doble, 5) end") ; 20
;; (interpretar "let sumador = proc (a) proc (b) +(a, b) end end in let suma3 = apply sumador (3) in apply suma3 (4) end end") ; 7
;; (interpretar "apply 5 (1)") ; error: el operador no es un procedimiento
;; (interpretar "let f = proc (a, b) +(a, b) end in apply f (1) end") ; error: aridad incorrecta

;; Ejemplos adicionales de letrec (Parte 4.1).
;; (interpretar "letrec factorial (n) = if ==(n, 0) then 1 else *(n, apply factorial (sub1(n))) end in apply factorial (5) end") ; 120
;; (interpretar "letrec potencia (base, exp) = if ==(exp, 0) then 1 else *(base, apply potencia (base, sub1(exp))) end in apply potencia (2, 10) end") ; 1024
;; (interpretar "letrec par? (n) = if ==(n, 0) then true else apply impar? (sub1(n)) end impar? (n) = if ==(n, 0) then false else apply par? (sub1(n)) end in apply par? (10) end") ; #t
;; (interpretar "letrec aplicarn (f, x, veces) = if ==(veces, 0) then x else apply f (apply aplicarn (f, x, sub1(veces))) end in let doble = proc (v) *(v, 2) end in apply aplicarn (doble, 1, 5) end end") ; 32

;; Ejemplos adicionales de case (Parte 4.2).
;; (interpretar "case 3 of 1 => 10 of 3 => 30 otherwise => 0 end") ; 30
;; (interpretar "case 5 of 1 => 10 of 3 => 30 otherwise => 0 end") ; 0 (otherwise)
;; (interpretar "case 3 of 3 => 10 of 3 => 20 otherwise => 0 end") ; 10 (primera coincidencia)
;; (interpretar "case true of 1 => 10 otherwise => 0 end") ; error: control no numérico
