;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016 - 2022
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


(define-module (g-golf init)
  #:use-module (system foreign)

  #:export (%libgirepository
	    %libglib
	    %libgobject
            %libg-golf

            %debug
            %iface-vfunc-warnings

            %async-api))


(define %libgirepository (dynamic-link "libgirepository-1.0"))
(define %libglib (dynamic-link "libglib-2.0"))
;; (define %libgdk (dynamic-link "libgdk-3"))
(define %libgobject (dynamic-link "libgobject-2.0"))

(define %libg-golf (dynamic-link "libg-golf"))

(define %debug (make-parameter #f))
(define %iface-vfunc-warnings (make-parameter #f))

;; The AdwMessageDialog class offers two ways to capture the user
;; response: (1) the traditional dialog 'response signal callback and
;; (2) the Gio Async API.

;; For some misterious reason (still), I couldn't (yet) make the Gio
;; Async API approach work. See the commit dc9ff1f as well as the
;; comments in the (adw1-demo dialogs) module for a detailed description
;; of the problem.

;; Till I or someone else figures out what's going on and how to fix it,
;; I'll swith to use the dialog 'response signal callback model, but to
;; be able to later track and possibly fix this problem, I add this
;; parameter, that together with the ./examples/adw-1/adw1-demo.scm -a,
;; --async-api command line option, allows the (adw1-demo dialogs) to
;; implement and selectively switch to one response model or the other.

(define %async-api (make-parameter #f))
