#|
  This file is a part of set-proc-title project.
|#

(in-package :cl-user)
(defpackage set-proc-title-test-asd
  (:use :cl :asdf))
(in-package :set-proc-title-test-asd)

(defsystem set-proc-title-test
  :author ""
  :license ""
  :depends-on (:set-proc-title
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "set-proc-title"))))
  :description "Test system for set-proc-title"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
