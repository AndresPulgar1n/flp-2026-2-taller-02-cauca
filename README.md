# Taller 2 — El intérprete de Cauca

**Curso:** Fundamentos de Interpretación y Compilación de Lenguajes de Programación  
**Universidad:** Universidad del Valle  
**Profesor:** Carlos Andrés Delgado Saavedra

## Integrantes

Antes de entregar, complete cada fila con el nombre, código y correo institucional reales de cada integrante. No deje campos en blanco.

||||
|-|-|-|
|Nombre completo: Andres Felipe Chaparro|Código: 2266252|chaparro.andres@correounivalle.edu.co|

## Descripción

Este taller construye el intérprete del lenguaje Cauca mediante `#lang eopl` y SLLGEN. La solución está dividida en módulos que especifican la sintaxis, representan clausuras, gestionan ambientes, evalúan primitivas y recorren el AST. El lenguaje incluye números, booleanos, condicionales, ligaduras locales, procedimientos con alcance léxico, `letrec` para recursión y `case` para selección por valor. Los informes de `docs/` documentan el AST, una traza de evaluación y argumentos de corrección de las reglas centrales.

## Organización

```text
src/
  sintaxis.rkt       Especificación léxica y gramatical, scanner y parser
  valores.rkt        Datatype de clausuras
  ambiente.rkt       Ambientes, apply-env y ambiente inicial
  primitivas.rkt     Primitivas y validaciones de tipos/aridad
  interprete.rkt     Evaluación y aplicación de procedimientos
  interfaz.rkt       Función interpretar y REPL
interprete-cauca.rkt Fachada pública
pruebas-cauca.rkt    Pruebas con rackunit
docs/
  informe-ast.md
  informe-correccion.md
```

## Ejecutar las pruebas

Desde la raíz del repositorio, con Racket y EOPL instalados:

```bash
racket pruebas-cauca.rkt
```

En DrRacket, cargue la fachada y ejecute, por ejemplo:

```racket
(require "interprete-cauca.rkt")
(interpretar "let x = 2 y = 3 in \\\\\\\\\\\\\\\*(x, y) end")
(interpretar "letrec factorial (n) = if ==(n, 0) then 1 else \\\\\\\\\\\\\\\*(n, apply factorial (sub1(n))) end in apply factorial (5) end")
```

El intérprete debe entregar `6` para el primer programa y `120` para el segundo.

