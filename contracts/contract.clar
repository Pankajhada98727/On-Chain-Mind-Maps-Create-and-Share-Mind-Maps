;; On-Chain Mind Maps: Create and Share Mind Maps

;; Stores mind maps with (owner + title) as key and content as value
(define-map mind-maps 
  (tuple (owner principal) (title (string-ascii 32))) 
  (string-utf8 256))

;; Stores a list of mind map titles for each user
(define-map user-maps principal (list 100 (string-ascii 32)))

;; Errors
(define-constant err-empty-content (err u100))
(define-constant err-title-too-short (err u101))
(define-constant err-not-owner (err u102))
(define-constant err-title-not-found (err u103))

;; Save or update a mind map
(define-public (save-mindmap (title (string-ascii 32)) (content (string-utf8 256)))
  (begin
    (asserts! (> (len title) u0) err-title-too-short)
    (asserts! (> (len content) u0) err-empty-content)

    ;; Save or update map content
    (map-set mind-maps {owner: tx-sender, title: title} content)

    ;; Update title list if it's a new title
    (let (
      (existing (map-get? mind-maps {owner: tx-sender, title: title}))
      (user-titles (default-to (list) (map-get? user-maps tx-sender)))
    )
      (if (is-some existing)
        ;; already exists, do nothing
        (ok true)
        ;; new title, add to title list
        (begin
          (map-set user-maps tx-sender (append user-titles (list title)))
          (ok true)))))
    (ok true))

;; Get a mind map by owner and title
(define-read-only (get-mindmap (owner principal) (title (string-ascii 32)))
  (ok (map-get? mind-maps {owner: owner, title: title})))

;; List all map titles for a user
(define-read-only (list-user-maps (user principal))
  (ok (default-to (list) (map-get? user-maps user))))

;; Delete a mind map (only by owner)
(define-public (delete-mindmap (title (string-ascii 32)))
  (let (
    (key {owner: tx-sender, title: title})
    (existing (map-get? mind-maps key))
  )
    (begin
      (asserts! (is-some existing) err-title-not-found)
      (map-delete mind-maps key)
      ;; Optionally remove from user-maps (skipped here for simplicity)
      (ok true))))
