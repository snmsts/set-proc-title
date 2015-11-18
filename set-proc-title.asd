#|
  This file is a part of set-proc-title project.
|#

(in-package :cl-user)
(defpackage set-proc-title-asd
  (:use :cl :asdf))
(in-package :set-proc-title-asd)

(defsystem set-proc-title
  :version "0.1"
  :author "SANO Masatoshi"
  :license "MIT"
  :depends-on (:trivial-features :cffi)
  :components ((:module "src"
                :components
                ((:file "set-proc-title"))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op set-proc-title-test))))
