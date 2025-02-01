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

(define-public (mint-achievement-badge 
  (vault-id uint)
  (badge-id uint))
  (let (
    (vault (unwrap! (contract-call? .vault get-vault vault-id) (err u404)))
    (badge-type (unwrap! (map-get? badge-types { badge-id: badge-id }) (err u404)))
  )
    (asserts! (>= (get score vault) (get required-score badge-type)) (err u403))
    (nft-mint? badges badge-id tx-sender))
)
