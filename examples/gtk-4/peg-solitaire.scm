#! /bin/sh
# -*- mode: scheme; coding: utf-8 -*-
exec guile -e main -s "$0" "$@"
!#


(eval-when (expand load eval)
  (use-modules (oop goops))

  (default-duplicate-binding-handler
    '(merge-generics replace warn-override-core warn last))

  (use-modules (g-golf))

  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gdk" name))
      '("Paintable"))

  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Application"
        "ApplicationWindow"
        "HeaderBar"
        "CssProvider"
        "Grid"
        "Button"
        "Image")))


(define-class <solitaire-peg> (<gobject> <gdk-paintable>)
  (i #:accessor !i #:init-keyword #:i)
  (j #:accessor !j #:init-keyword #:j))

(define-vfunc (get-flags-vfunc (self <solitaire-peg>))
  '(size contents))

(define-vfunc (get-intrinsic-width-vfunc (self <solitaire-peg>))
  32)

(define-vfunc (get-intrinsic-height-vfunc (self <solitaire-peg>))
  32)

;; For some unknown reason(s) still, the snapshot vfunc is not called with the
;; the intrinsic width and height values. However both the get-intrinsic-width
;; and get-intrinsic-height methods work fine, they call their corresponding
;; vfunc, that we override here above. Till I find out why, let's call those
;; method explicitly and temporarily comment the width height args.

(define-vfunc (snapshot-vfunc (self <solitaire-peg>) snapshot width height)
  (append-color snapshot
                '(0.6 0.3 0.0 1.0)
                (graphene-rect-init (graphene-rect-alloc)
                                    0 0
                                    ;; width height
                                    (get-intrinsic-width self)
                                    (get-intrinsic-height self))))

(define %css-data
  ".solitaire-field {
border: 1px solid lightgray;
}")

(define (create-board window)
  (let* ((grid (make <gtk-grid>
                 #:margin-top 24
                 #:margin-start 24
                 #:margin-bottom 24
                 #:margin-end 24
                 #:halign 'center
                 #:valign 'center
                 #:column-spacing 6
                 #:column-homogeneous #t
                 #:row-spacing 6
                 #:row-homogeneous #t))
         (css-provider (let ((provider (make <gtk-css-provider>)))
                         (gtk-css-provider-load-from-data provider %css-data -1)
                         provider)))
    (set-child window grid)
    (do ((i 0
            (+ i 1)))
        ((= i 7))
      (do ((j 0
              (+ j 1)))
          ((= j 7))
        (unless (and (or (< i 2) (>= i 5))
                     (or (< j 2) (>= j 5)))
          (let ((image (make <gtk-image> #:icon-size 'large)))
            (add-provider (get-style-context image) css-provider 800)
            (add-css-class image "solitaire-field")
            (unless (and (= i 3) (= j 3))
              (let ((peg (make <solitaire-peg> #:i i #:j j)))
                (set-from-paintable image peg)))
            (attach grid image i j 1 1)))))))


(define (activate app)
  (let ((window (make <gtk-application-window>
                  #:title "Peg Solitaire"
                  #:default-width 420
                  #:default-height 420
                  #:application app))
        (header-bar (make <gtk-header-bar>))
        (restart (make <gtk-button>
                   #:icon-name "view-refresh-symbolic")))

    (connect restart
             'clicked
             (lambda (bt)
               (dimfi 'restarting 'the 'game)))

    (set-titlebar window header-bar)
    (pack-start header-bar restart)
    (create-board window)
    (show window)))


(define (main args)
  (let ((app (make <gtk-application>
               #:application-id "org.gtk.example")))
    (connect app 'activate activate)
    (let ((status (g-application-run app (length args) args)))
      (exit status))))


#;(define (main args)
  (parameterize ((%debug #t))
    (let ((app (make <gtk-application>
                 #:application-id "org.gtk.example")))
      ;; (connect app 'activate activate)
      (let ((status (g-application-run app (length args) args)))
        (dimfi 'status status)))))
