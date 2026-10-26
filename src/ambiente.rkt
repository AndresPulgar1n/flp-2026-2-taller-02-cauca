#lang eopl
;Autores: Andres Felipe Chaparro 2266252
;; TAD de ambientes, búsqueda de identificadores y ambiente inicial.
(require "sintaxis.rkt")
(require "valores.rkt")

(define-datatype ambiente ambiente?
  (ambiente-vacio)
  (ambiente-extendido
   (ids (list-of symbol?))
   (valores list?)
   (anterior ambiente?))
  (ambiente-recursivo
   (proc-names (list-of symbol?))
   (idss list?)
   (bodies (list-of expresion?))
   (anterior ambiente?)))

;; indice-de : symbol x lista-de-simbolos -> entero. Busca la posición de un nombre.
(define indice-de
  (lambda (id ids)
    (cond
      ((null? ids) (eopl:error 'apply-env "Ligadura inconsistente para ~s" id))
      ((eqv? id (car ids)) 0)
      (else (+ 1 (indice-de id (cdr ids)))))))

;; buscar-procedimiento : symbol x listas de letrec -> procval o #f.
;; Construye una clausura cuyo ambiente de definición es el ambiente recursivo completo.
(define buscar-procedimiento
  (lambda (id nombres parametros cuerpos ambiente-rec)
    (cond
      ((null? nombres) #f)
      ((eqv? id (car nombres))
       (cerradura (car parametros) (car cuerpos) ambiente-rec))
      (else
       (buscar-procedimiento id (cdr nombres) (cdr parametros) (cdr cuerpos) ambiente-rec)))))

;; apply-env : ambiente x symbol -> valor. Busca desde la ligadura más reciente.
(define apply-env
  (lambda (env id)
    (cases ambiente env
      (ambiente-vacio ()
        (eopl:error 'apply-env "Variable no ligada: ~s" id))
      (ambiente-extendido (ids valores anterior)
        (if (memq id ids)
            (list-ref valores (indice-de id ids))
            (apply-env anterior id)))
      (ambiente-recursivo (proc-names idss bodies anterior)
        (let ((proc (buscar-procedimiento id proc-names idss bodies env)))
          (if proc proc (apply-env anterior id)))))))

;; ambiente-inicial : -> ambiente. Define n=10, m=3, p=7, q=2 y r=5.
(define ambiente-inicial
  (lambda ()
    (ambiente-extendido '(n m p q r) '(10 3 7 2 5) (ambiente-vacio))))

(provide (all-defined-out))
