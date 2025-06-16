;; Store latest mind map node per user
(define-map mind-map
  {user: principal}           ;; key
  {node: (string-ascii 100)}) ;; value

(define-constant err-empty-node (err u100))

;; Public function to add/update mind map node
(define-public (add-node (node (string-ascii 100)))
  (begin
    (asserts! (> (len node) u0) err-empty-node)
    (map-set mind-map {user: tx-sender} {node: node})
    (ok true)))

;; Read-only function to get the latest node by user
(define-read-only (get-latest-node)
  (let ((entry (map-get? mind-map {user: tx-sender})))
    (ok (match entry
         val (some {node: (get node val)})
         none))))
