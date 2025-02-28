;; Rewards Contract
(define-fungible-token sky-points)

(define-map user-points 
  { user: principal }
  { 
    balance: uint,
    last-claim: uint
  }
)

(define-constant DAY_BLOCKS u144) ;; ~24 hours in blocks

(define-public (claim-daily-reward (vault-id uint))
  (let (
    (vault (unwrap! (contract-call? .vault get-vault vault-id) (err u404)))
    (points (calculate-reward-points (get score vault)))
    (user-data (default-to 
      { balance: u0, last-claim: u0 } 
      (map-get? user-points { user: tx-sender })))
  )
    (asserts! (is-eq tx-sender (get owner vault)) (err u403))
    (asserts! (>= (- block-height (get last-claim user-data)) DAY_BLOCKS) (err u429))
    (map-set user-points 
      { user: tx-sender }
      { 
        balance: (+ (get balance user-data) points),
        last-claim: block-height
      })
    (ft-mint? sky-points points tx-sender))
)

(define-private (calculate-reward-points (score uint))
  (* score u10))
