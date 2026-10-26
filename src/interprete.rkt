#lang eopl
;Autores: Andres Felipe Chaparro 2266252
;; Evaluación del AST y aplicación de procedimientos.
(require "sintaxis.rkt")
(require "valores.rkt")
(require "ambiente.rkt")
(require "primitivas.rkt")

;; apply-procedure : procval x lista-de-valores -> valor. Evalúa en la clausura.
(define apply-procedure
  (lambda (proc args)
    (cases procval proc
      (cerradura (ids body env-def)
        (if (= (length ids) (length args))
            (evaluar-expresion body (ambiente-extendido ids args env-def))
            (eopl:error 'apply-procedure
                        "Aridad incorrecta: se esperaban ~s argumentos y llegaron ~s"
                        (length ids) (length args)))))))

;; evaluar-programa : programa -> valor. Evalúa el programa en el ambiente inicial.
(define evaluar-programa
  (lambda (pgm)
    (cases programa pgm
      (a-program (exp) (evaluar-expresion exp (ambiente-inicial))))))

;; evaluar-rands : lista-de-expresiones x ambiente -> lista-de-valores.
;; Evalúa los argumentos de izquierda a derecha en un mismo ambiente.
(define evaluar-rands
  (lambda (rands env)
    (if (null? rands)
        '()
        (cons (evaluar-expresion (car rands) env)
              (evaluar-rands (cdr rands) env)))))

;; buscar-rama : número x lista-de-números x lista-de-expresiones x ambiente
;;             -> lista con un resultado o #f. Busca la primera rama coincidente;
;; devuelve una lista de un elemento para distinguir una acción que retorna #f.
(define buscar-rama
  (lambda (control valores acciones env)
    (cond
      ((null? valores) #f)
      ((= control (car valores))
       (list (evaluar-expresion (car acciones) env)))
      (else (buscar-rama control (cdr valores) (cdr acciones) env)))))

;; aplicacion-como-operador? : expresion -> boolean. Detecta el caso que Cauca
;; excluye explícitamente: usar una expresión app-exp directamente como operador.
(define aplicacion-como-operador?
  (lambda (exp-operador)
    (cases expresion exp-operador
      (app-exp (rator rands) #t)
      (else #f))))

;; evaluar-expresion : expresion x ambiente -> valor. Implementa la semántica de Cauca.
(define evaluar-expresion
  (lambda (exp env)
    (cases expresion exp
      (lit-exp (dato) dato)
      (var-exp (id) (apply-env env id))
      (true-exp () #t)
      (false-exp () #f)
      (prim-exp (prim rands)
        (evaluar-primitiva prim (evaluar-rands rands env)))
      (if-exp (test true-exp false-exp)
        (let ((test-value (evaluar-expresion test env)))
          (if (boolean? test-value)
              (if test-value
                  (evaluar-expresion true-exp env)
                  (evaluar-expresion false-exp env))
              (eopl:error 'evaluar-expresion
                          "La condicion de if debe ser booleana; se recibio ~s"
                          test-value))))
      (let-exp (ids rands body)
        (let ((values (evaluar-rands rands env)))
          (evaluar-expresion body (ambiente-extendido ids values env))))
      (proc-exp (ids body)
        (cerradura ids body env))
      (app-exp (rator rands)
        (if (aplicacion-como-operador? rator)
            (eopl:error 'evaluar-expresion
                        "Una aplicación no puede usarse directamente como operador; ligue el resultado con let")
            (let ((proc (evaluar-expresion rator env)))
              (if (procval? proc)
                  (apply-procedure proc (evaluar-rands rands env))
                  (eopl:error 'evaluar-expresion
                              "El operador de apply no es un procedimiento: ~s" proc)))))
      (letrec-exp (proc-names idss bodies body)
        (evaluar-expresion body
                           (ambiente-recursivo proc-names idss bodies env)))
      (case-exp (control valores acciones default)
        (if (null? valores)
            (eopl:error 'evaluar-expresion "case requiere al menos una rama of")
            (let ((test-value (evaluar-expresion control env)))
              (if (number? test-value)
                  (let ((respuesta (buscar-rama test-value valores acciones env)))
                    (if respuesta
                        (car respuesta)
                        (evaluar-expresion default env)))
                  (eopl:error 'evaluar-expresion
                              "La expresion de control de case debe ser numerica: ~s"
                              test-value))))))))

(provide (all-defined-out))
