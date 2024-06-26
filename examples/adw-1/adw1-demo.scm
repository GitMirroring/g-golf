#! /bin/sh
# -*- mode: scheme; coding: utf-8 -*-
exec guile -e main -s "$0" "$@"
!#


;;;;
;;;; Copyright (C) 2023
;;;; Free Software Foundation, Inc.

;;;; This file is part of GNU G-Golf

;;;; GNU G-Golf is free software; you can redistribute it and/or modify
;;;; it under the terms of the GNU Lesser General Public License as
;;;; published by the Free Software Foundation; either version 3 of the
;;;; License, or (at your option) any later version.

;;;; GNU G-Golf is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; Lesser General Public License for more details.

;;;; You should have received a copy of the GNU Lesser General Public
;;;; License along with GNU G-Golf.  If not, see
;;;; <https://www.gnu.org/licenses/lgpl.html>.
;;;;

;;; Commentary:

;;; Code:


(eval-when (expand load eval)
  (use-modules (oop goops))

  (default-duplicate-binding-handler
    '(merge-generics replace warn-override-core warn last))

  (use-modules (g-golf))

  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Application")))


(add-to-load-path
 (dirname (current-filename)))

(use-modules (adw1-demo window))


(define (main args)
  (letrec ((debug? (or (member "-d" args)
                       (member "--debug" args)))
           (async-api? (or (member "-a" args)
                           (member "--async-api" args)))
           (animate
            (lambda ()
              (let ((app (make <adw-application>
                           #:application-id "org.gnu.g-golf.adw-1.demo")))
                (set! *random-state* (random-state-from-platform))
                (connect app 'activate show-window)
                (let ((status (g-application-run app '())))
                  #;(exit status)
                  'done)))))

    (cond ((and debug? async-api?)
           (parameterize ((%debug #t) (%async-api #t))
             (animate)))
          (debug?
           (parameterize ((%debug #t))
             (animate)))
          (async-api?
           (parameterize ((%async-api #t))
             (animate)))
          (else
           (animate)))))
