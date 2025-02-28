;; Achievement Badges Contract
(define-non-fungible-token badges uint)

(define-map badge-types
  { badge-id: uint }
  {
    name: (string-ascii 64),
    description: (string-ascii 256),
    required-score: uint
  }
)

(define-data-var next-badge-id uint u1)

(define-public (initialize-badge-type 
  (name (string-ascii 64))
  (description (string-ascii 256))
  (required-score uint))
  (let ((badge-id (var-get next-badge-id)))
    (asserts! (is-eq tx-sender contract-owner) (err u401))
    (map-set badge-types
      { badge-id: badge-id }
      {
        name: name,
        description: description,
        required-score: required-score
      })
    (var-set next-badge-id (+ badge-id u1))
    (ok badge-id)))

(define-public (mint-achievement-badge 
  (vault-id uint)
  (badge-id uint))
  (let (
    (vault (unwrap! (contract-call? .vault get-vault vault-id) (err u404)))
    (badge-type (unwrap! (map-get? badge-types { badge-id: badge-id }) (err u404)))
  )
    (asserts! (>= (get score vault) (get required-score badge-type)) (err u403))
    (asserts! (is-eq tx-sender (get owner vault)) (err u403))
    (nft-mint? badges badge-id tx-sender)))
