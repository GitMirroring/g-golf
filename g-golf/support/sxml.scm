;; -*- mode: scheme; coding: utf-8 -*-

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


(define-module (g-golf support sxml)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (ice-9 pretty-print)
  #:use-module (sxml simple)
  #:use-module (sxml transform)

  #:export (ui->sxml
            sxml->ui))


;;;
;;; sxml support for template and ui files
;;;   wip

(define (ui->sxml filename)
  (let* ((d-name (dirname filename))
         (b-name (basename filename ".ui"))
         (s-name (string-append d-name "/" b-name ".scm")))
    (call-with-output-file s-name
      (lambda (port)
        (pretty-print (call-with-input-file filename
                        (lambda (port) (xml->sxml port #:trim-whitespace? #t)))
                      port)))))

(define %xml-doctype
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")

(define* (sxml->ui sxml
                   #:key (transform-rules '()))
  (display %xml-doctype)
  (sxml->xml sxml)
  (display "\n"))
