#lang eopl
;Autores: Andres Felipe Chaparro 2266252
;; Valor procedimiento de Cauca. El cuerpo se conserva sin evaluar.
(require "sintaxis.rkt")

(define-datatype procval procval?
  (cerradura
   (ids (list-of symbol?))
   (body expresion?)
   ;; Predicado permisivo para romper el ciclo entre valores y ambientes.
   (env (lambda (v) #t))))

(provide (all-defined-out))
