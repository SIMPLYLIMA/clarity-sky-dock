;; Rewards Contract
(define-fungible-token sky-points)

(define-map user-points 
  { user: principal }
  { balance: uint }
)

(define-public (claim-daily-reward (vault-id uint))
  (let (
    (vault (unwrap! (contract-call? .vault get-vault vault-id) (err u404)))
    (points (calculate-reward-points (get score vault)))
  )
    (asserts! (is-eq tx-sender (get owner vault)) (err u403))
    (ft-mint? sky-points points tx-sender))
)

(define-private (calculate-reward-points (score uint))
  (* score u10))
