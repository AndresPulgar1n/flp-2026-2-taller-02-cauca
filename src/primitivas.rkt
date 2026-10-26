#lang eopl
;Autores: Andres Felipe Chaparro 2266252
;; Primitivas de Cauca con validación explícita de aridad y tipos.
(require "sintaxis.rkt")

;; exigir-numeros : lista x symbol -> boolean. Rechaza argumentos no numéricos.
(define exigir-numeros
  (lambda (args quien)
    (cond ((null? args) #t)
          ((number? (car args)) (exigir-numeros (cdr args) quien))
          (else (eopl:error quien "Se esperaban numeros; argumento recibido: ~s" (car args))))))

;; exigir-enteros : lista x symbol -> boolean. Rechaza valores no enteros.
(define exigir-enteros
  (lambda (args quien)
    (cond ((null? args) #t)
          ((and (number? (car args)) (integer? (car args)) (exact? (car args)))
           (exigir-enteros (cdr args) quien))
          (else (eopl:error quien "Se esperaban enteros; argumento recibido: ~s" (car args))))))

;; exigir-booleanos : lista x symbol -> boolean. Rechaza valores no booleanos.
(define exigir-booleanos
  (lambda (args quien)
    (cond ((null? args) #t)
          ((boolean? (car args)) (exigir-booleanos (cdr args) quien))
          (else (eopl:error quien "Se esperaban booleanos; argumento recibido: ~s" (car args))))))

;; exigir-cantidad : lista x entero x symbol -> boolean. Exige aridad exacta.
(define exigir-cantidad
  (lambda (args n quien)
    (if (= (length args) n)
        #t
        (eopl:error quien "Se esperaban ~s argumentos y llegaron ~s" n (length args)))))

;; exigir-minimo : lista x entero x symbol -> boolean. Exige una aridad mínima.
(define exigir-minimo
  (lambda (args n quien)
    (if (>= (length args) n)
        #t
        (eopl:error quien "Se esperaban al menos ~s argumentos y llegaron ~s" n (length args)))))

;; sumar-lista : lista-numérica -> número. Suma una lista.
(define sumar-lista
  (lambda (args)
    (if (null? args) 0 (+ (car args) (sumar-lista (cdr args))))))

;; producto-lista : lista-numérica -> número. Multiplica una lista.
(define producto-lista
  (lambda (args)
    (if (null? args) 1 (* (car args) (producto-lista (cdr args))))))

;; mcd-dos : entero x entero -> entero. Calcula el MCD mediante Euclides.
(define mcd-dos
  (lambda (a b)
    (if (= b 0) (abs a) (mcd-dos b (remainder a b)))))

;; mcd-lista : lista-de-enteros -> entero. Calcula el MCD de varios enteros.
(define mcd-lista
  (lambda (args)
    (if (null? (cdr args))
        (abs (car args))
        (mcd-dos (car args) (mcd-lista (cdr args))))))

;; dividir-restantes : número x lista-de-números -> número. Divide de izquierda a derecha.
(define dividir-restantes
  (lambda (resultado args)
    (if (null? args)
        resultado
        (dividir-restantes (/ resultado (car args)) (cdr args)))))

;; mcm-dos : entero x entero -> entero. Calcula el MCM, incluyendo ceros.
(define mcm-dos
  (lambda (a b)
    (if (or (= a 0) (= b 0))
        0
        (abs (quotient (* a b) (mcd-dos a b))))))

;; mcm-lista : lista-de-enteros -> entero. Calcula el MCM de una lista.
(define mcm-lista
  (lambda (args)
    (if (null? (cdr args))
        (abs (car args))
        (mcm-dos (car args) (mcm-lista (cdr args))))))

;; evaluar-primitiva : primitiva x lista-de-valores -> valor. Aplica una primitiva validada.
(define evaluar-primitiva
  (lambda (prim args)
    (cases primitiva prim
      (sum-prim ()
        (exigir-numeros args '+)
        (sumar-lista args))
      (minus-prim ()
        (exigir-minimo args 1 '-)
        (exigir-numeros args '-)
        (if (null? (cdr args)) (- (car args))
            (- (car args) (sumar-lista (cdr args)))))
      (mult-prim ()
        (exigir-numeros args '*)
        (producto-lista args))
      (div-prim ()
        (exigir-minimo args 1 '/)
        (exigir-numeros args '/)
        (if (null? (cdr args)) (/ 1 (car args))
            (dividir-restantes (car args) (cdr args))))
      (add-prim ()
        (exigir-cantidad args 1 'add1)
        (exigir-numeros args 'add1)
        (+ (car args) 1))
      (sub-prim ()
        (exigir-cantidad args 1 'sub1)
        (exigir-numeros args 'sub1)
        (- (car args) 1))
      (mayor-prim ()
        (exigir-cantidad args 2 '>) (exigir-numeros args '>)
        (> (car args) (cadr args)))
      (mayorigual-prim ()
        (exigir-cantidad args 2 '>=) (exigir-numeros args '>=)
        (>= (car args) (cadr args)))
      (menor-prim ()
        (exigir-cantidad args 2 '<) (exigir-numeros args '<)
        (< (car args) (cadr args)))
      (menorigual-prim ()
        (exigir-cantidad args 2 '<=) (exigir-numeros args '<=)
        (<= (car args) (cadr args)))
      (igual-prim ()
        (exigir-cantidad args 2 '==) (exigir-numeros args '==)
        (= (car args) (cadr args)))
      (not-prim ()
        (exigir-cantidad args 1 'not) (exigir-booleanos args 'not)
        (not (car args)))
      (and-prim ()
        (exigir-cantidad args 2 'and) (exigir-booleanos args 'and)
        (and (car args) (cadr args)))
      (or-prim ()
        (exigir-cantidad args 2 'or) (exigir-booleanos args 'or)
        (or (car args) (cadr args)))
      (abs-prim ()
        (exigir-cantidad args 1 'abs) (exigir-numeros args 'abs)
        (abs (car args)))
      (mcd-prim ()
        (exigir-minimo args 2 'mcd) (exigir-enteros args 'mcd)
        (mcd-lista args))
      (mcm-prim ()
        (exigir-minimo args 2 'mcm) (exigir-enteros args 'mcm)
        (mcm-lista args))
      (promedio-prim ()
        (exigir-minimo args 1 'promedio) (exigir-numeros args 'promedio)
        (/ (sumar-lista args) (length args)))
      (xor-prim ()
        (exigir-cantidad args 2 'xor) (exigir-booleanos args 'xor)
        (not (eq? (car args) (cadr args))))
      (implica-prim ()
        (exigir-cantidad args 2 'implica) (exigir-booleanos args 'implica)
        (or (not (car args)) (cadr args)))
      (entre-prim ()
        (exigir-cantidad args 3 'entre) (exigir-numeros args 'entre)
        (and (<= (cadr args) (car args)) (<= (car args) (caddr args)))))))

(provide (all-defined-out))
