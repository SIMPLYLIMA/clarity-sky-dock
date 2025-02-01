;; Vault Management Contract
(define-data-var last-vault-id uint u0)

(define-map vaults
  { vault-id: uint }
  {
    owner: principal,
    name: (string-ascii 64),
    size: uint,
    files: uint,
    score: uint,
    last-update: uint
  }
)

(define-public (create-vault (name (string-ascii 64)))
  (let ((vault-id (+ (var-get last-vault-id) u1)))
    (var-set last-vault-id vault-id)
    (map-set vaults
      { vault-id: vault-id }
      {
        owner: tx-sender,
        name: name,
        size: u0,
        files: u0,
        score: u100,
        last-update: block-height
      }
    )
    (ok vault-id))
)

(define-public (update-vault-stats 
  (vault-id uint) 
  (new-size uint)
  (new-files uint))
  (let ((vault (unwrap! (get-vault vault-id) (err u404))))
    (asserts! (is-eq tx-sender (get owner vault)) (err u403))
    (ok (map-set vaults
      { vault-id: vault-id }
      {
        owner: (get owner vault),
        name: (get name vault),
        size: new-size,
        files: new-files,
        score: (calculate-score new-size new-files),
        last-update: block-height
      }
    )))
)

(define-read-only (get-vault (vault-id uint))
  (map-get? vaults { vault-id: vault-id })
)

(define-private (calculate-score (size uint) (files uint))
  (if (is-eq files u0)
    u0
    (/ (* size u100) files))
)
