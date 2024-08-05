;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2024
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

;;    Initially written to be part of Grip,
;;    https://www.nongnu.org/grip/index.html, I locally added the module
;;    to my grip (local) devel branch, but never did commit it. I'll
;;    need to extend a little bit its functionality to be part of G-Golf
;;    anyway.

;; Notes and Naming Conventiond:
;; -----------------------------

;; A color is a list of 4 floats in the [0,1] range, each representing
;; the value of the RED (r) GREEN (g) BLUE (b) ALPHA (a) channels, in
;; that order. For example:

;;	(rgb->color #x73d216)
;;	$3 = (0.45 0.82 0.09 1.0)
;;   or
;;      (rgba->color #x73d216aa)
;;      $4 = (0.45 0.82 0.09 0.67)

;; In the above, #73d216 is the rgb hexadecimal representation of the
;; color, and #73d216aa is the rgba hexadecimal representation of the
;; same color with an alpha channel value of 0.67.

;; For those who wouldn't know, note that the #x73d216 expression is
;; evaluated, as '#x' triggers the (predefined) read hash extend
;; procedure for 'x', that is, the guile reader for hexadecimal values,
;; which returns an integer, the color code (cc).

;; With the above introduction and example in mind, within the context
;; of this module and/or this module use, the following aliases (short
;; names and/or acronyms) 'stands for' translation table applies:

;;       <- stands for ->

;; cc                     color code
;; rgb->color             
;; rgba->color            expect an rgb/rgba cc and return a color
;; string->color          expect an hex color string "#rrggbb", "rrggbb"
;;                        alo accepted, or "#rrggbbaa" "rrggbbaa" and
;;                        return a color

;;; Code:


(define-module (g-golf support color)
  #:use-module (ice-9 match)

  #:export (rgb->color
            rgba->color
            string->color

	    %tango-butter
	    %tango-butter-light
	    %tango-butter-dark

	    %tango-orange
	    %tango-orange-light
	    %tango-orange-dark

	    %tango-chocolate
	    %tango-chocolate-light
	    %tango-chocolate-dark

	    %tango-chameleon
	    %tango-chameleon-light
	    %tango-chameleon-dark

	    %tango-sky-blue
	    %tango-sky-blue-light
	    %tango-sky-blue-dark

	    %tango-plum
	    %tango-plum-light
	    %tango-plum-dark

	    %tango-scarlet-red
	    %tango-scarlet-red-light
	    %tango-scarlet-red-dark

	    %tango-aluminium-1
	    %tango-aluminium-2
	    %tango-aluminium-3
	    %tango-aluminium-4
	    %tango-aluminium-5
	    %tango-aluminium-6

            %tango-trash-outline
            %tango-trash-highlight
            %tango-trash-content))


;;;
;;;
;;;

(define (cc-chan cc offset)
   "Returns the 8-bit color value, in the range [0,1], for CC (a color
code) and OFFSET (in bits)."
  (let ((mask (ash #xff offset)))
    (float-round (/ (ash (logand mask cc)
	                 (- offset))
                    255.0))))

(define (rgb->color cc)
  "Returns a color, composed of the red, green, blue values for CC, in
the [0,1] range, and 1.0 for the alpha channel."
  (list (cc-chan cc 16)
	(cc-chan cc 8)
	(cc-chan cc 0)
        1.0))

(define (rgba->color cc)
  "Returns a color, composed of the red, green, blue, alpha values for
CC, in the [0,1] range."
  (list (cc-chan cc 24)
	(cc-chan cc 16)
	(cc-chan cc 8)
        (cc-chan cc 0)))

(define (hex->digit c)
    (match c
      (#\0 0)
      (#\1 1)
      (#\2 2)
      (#\3 3)
      (#\4 4)
      (#\5 5)
      (#\6 6)
      (#\7 7)
      (#\8 8)
      (#\9 9)
      ((or #\a #\A) 10)
      ((or #\b #\B) 11)
      ((or #\c #\C) 12)
      ((or #\d #\D) 13)
      ((or #\e #\E) 14)
      ((or #\f #\F) 15)))

(define (string-chan str offset)
  (let ((c1 (string-ref str offset))
        (c2 (string-ref str (+ offset 1))))
    (float-round (/ (+ (* (hex->digit c1) 16)
                       (hex->digit c2))
                    255.0))))

(define (string->color str)
   "Returns the color, for STR, an hexadecimal color string. Accepted
STR formats are: \"#rrggbb\", \"rrggbb\", \"#rrggbbaa\" and
\"rrggbbaa\","
   (let* ((start (if (string-prefix? "#" str) 1 0))
          (alpha? (> (string-length str) (+ start 6)))
          (red (string-chan str start))
          (green (string-chan str (+ start 2)))
          (blue (string-chan str (+ start 4)))
          (alpha (if alpha?
                     (string-chan str (+ start 6))
                     1.0)))
     (list red green blue alpha)))


;;;
;;; Utils
;;;

(define* (float-round float #:optional (n-dec 2))
  (let ((m (expt 10 n-dec)))
    (/ (round (* m float)) m)))


;;;
;;; Tango color pallete
;;;   http://tango.freedesktop.org
;;;

(define %tango-butter (string->color "#edd400"))
(define %tango-butter-light (string->color "#fce94f"))
(define %tango-butter-dark (string->color "#c4a000"))

(define %tango-orange (string->color "#f57900"))
(define %tango-orange-light (string->color "#fcaf3e"))
(define %tango-orange-dark (string->color "#ce5c00"))

(define %tango-chocolate (string->color "#c17d11"))
(define %tango-chocolate-light (string->color "#e9b96e"))
(define %tango-chocolate-dark (string->color "#8f5902"))

(define %tango-chameleon (string->color "#73d216"))
(define %tango-chameleon-light (string->color "#8ae234"))
(define %tango-chameleon-dark (string->color "#4e9a06"))

(define %tango-sky-blue (string->color "#3465a4"))
(define %tango-sky-blue-light (string->color "#729fcf"))
(define %tango-sky-blue-dark (string->color "#204a87"))

(define %tango-plum (string->color "#75507b"))
(define %tango-plum-light (string->color "#ad7fa8"))
(define %tango-plum-dark (string->color "#5c3566"))

(define %tango-scarlet-red (string->color "#cc0000"))
(define %tango-scarlet-red-light (string->color "#ef2929"))
(define %tango-scarlet-red-dark (string->color "#a40000"))

(define %tango-aluminium-1 (string->color "#eeeeec"))
(define %tango-aluminium-2 (string->color "#d3d7cf"))
(define %tango-aluminium-3 (string->color "#babdb6"))
(define %tango-aluminium-4 (string->color "#888a85"))
(define %tango-aluminium-5 (string->color "#555753"))
(define %tango-aluminium-6 (string->color "#2e3436"))

(define %tango-trash-outline (string->color "#495106"))
(define %tango-trash-highlight (string->color "#c9d182"))
(define %tango-trash-content (string->color "#858e3f"))
