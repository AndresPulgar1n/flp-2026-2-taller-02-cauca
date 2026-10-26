#lang eopl
;Autores: Andres Felipe Chaparro 2266252
;; Punto de entrada para texto y REPL interactivo de Cauca.
(require "sintaxis.rkt")
(require "interprete.rkt")

;; interpretar : string -> valor. Analiza el texto y evalúa el programa resultante.
(define interpretar
  (lambda (texto)
    (evaluar-programa (parser texto))))

;; interpretador : -> void. Ejecuta el REPL de SLLGEN para el lenguaje Cauca.
;; make-rep-loop devuelve el procedimiento del ciclo; se define directamente para
;; que una llamada a (interpretador) entre en el REPL, en lugar de devolver otro
;; procedimiento sin ejecutarlo.
(define interpretador
  (sllgen:make-rep-loop
   "Cauca> "
   (lambda (pgm)
     ;; Mantiene en el REPL las mismas restricciones sintácticas que parser.
     (cases programa pgm
       (a-program (exp)
         (begin
           (validar-expresion-sintactica exp)
           (evaluar-programa pgm)))))
   (sllgen:make-stream-parser especificacion-lexica especificacion-gramatical)))

(provide (all-defined-out))
