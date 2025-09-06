;; Title: OrangeProtocol - Sovereign Bitcoin Governance
;;
;; Summary: A comprehensive decentralized autonomous organization (DAO) built on Stacks
;; that enables Bitcoin-native governance, community-driven treasury management, and
;; democratic decision-making for Bitcoin Layer 2 ecosystems.
;;
;; Description: OrangeProtocol revolutionizes Bitcoin governance by providing a trustless
;; framework for collective decision-making, fund allocation, and investment tracking.
;; Built specifically for Stacks blockchain, it features advanced delegation mechanisms,
;; emergency controls, configurable governance parameters, and automated return distribution
;; systems. The protocol ensures Bitcoin's decentralized ethos while enabling sophisticated
;; governance operations including proposal creation, voting, treasury management, and
;; member rewards distribution.
;;
;; Key Features:
;; - Bitcoin-native governance with STX-based voting power
;; - Dynamic delegation system for flexible vote management  
;; - Emergency pause mechanisms for protocol security
;; - Configurable governance parameters for adaptability
;; - Automated investment return distribution
;; - Multi-tier proposal validation and execution
;; - Transparent treasury management with audit trails

;; ERROR CONSTANTS

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-VOTED (err u101))
(define-constant ERR-PROPOSAL-EXPIRED (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-INVALID-AMOUNT (err u104))
(define-constant ERR-PROPOSAL-NOT-ACTIVE (err u105))
(define-constant ERR-QUORUM-NOT-REACHED (err u106))
(define-constant ERR-NO-DELEGATE (err u110))
(define-constant ERR-INVALID-DELEGATE (err u111))
(define-constant ERR-EMERGENCY-ACTIVE (err u112))
(define-constant ERR-NOT-EMERGENCY (err u113))
(define-constant ERR-INVALID-PARAMETER (err u114))
(define-constant ERR-NO-RETURNS (err u115))

;; DATA VARIABLES

(define-data-var dao-admin principal tx-sender)
(define-data-var minimum-quorum uint u500) ;; 50% in basis points
(define-data-var voting-period uint u144) ;; ~1 day in blocks
(define-data-var proposal-count uint u0)
(define-data-var treasury-balance uint u0)
(define-data-var emergency-state bool false)

;; GOVERNANCE PARAMETERS

(define-data-var dao-parameters {
  proposal-fee: uint,
  min-proposal-amount: uint,
  max-proposal-amount: uint,
  voting-delay: uint,
  voting-period: uint,
  timelock-period: uint,
  quorum-threshold: uint,
  super-majority: uint,
} {
  proposal-fee: u100000, ;; 0.1 STX
  min-proposal-amount: u1000000, ;; 1 STX
  max-proposal-amount: u1000000000, ;; 1000 STX
  voting-delay: u100, ;; blocks before voting starts
  voting-period: u144, ;; ~1 day in blocks
  timelock-period: u72, ;; ~12 hours in blocks
  quorum-threshold: u500, ;; 50% in basis points
  super-majority: u667, ;; 66.7% in basis points
})

;; DATA MAPS

;; Member registry with voting power and contribution tracking
(define-map members
  principal
  {
    voting-power: uint,
    joined-block: uint,
    total-contributed: uint,
    last-withdrawal: uint,
  }
)

;; Proposal storage with comprehensive metadata
(define-map proposals
  uint
  {
    id: uint,
    proposer: principal,
    title: (string-ascii 100),
    description: (string-utf8 1000),
    amount: uint,
    target: principal,
    start-block: uint,
    end-block: uint,
    yes-votes: uint,
    no-votes: uint,
    status: (string-ascii 20),
    executed: bool,
  }
)

;; Vote tracking per proposal and voter
(define-map votes
  {
    proposal-id: uint,
    voter: principal,
  }
  {
    amount: uint,
    support: bool,
  }
)

;; Emergency administration privileges
(define-map emergency-admins
  principal
  bool
)

;; Vote delegation system
(define-map delegations
  principal
  {
    delegate: principal,
    amount: uint,
    expiry: uint,
  }
)

;; Investment return distribution pools
(define-map return-pools
  uint
  {
    total-amount: uint,
    distributed-amount: uint,
    distribution-start: uint,
    distribution-end: uint,
    claims: (list 200 principal),
  }
)

;; Member claims tracking for return pools
(define-map member-claims
  {
    member: principal,
    pool-id: uint,
  }
  {
    amount: uint,
    claimed: bool,
  }
)

;; EMERGENCY CONTROLS

;; Toggle emergency state for protocol security
(define-public (set-emergency-state (state bool))
  (begin
    (asserts! (is-emergency-admin tx-sender) ERR-NOT-AUTHORIZED)
    (var-set emergency-state state)
    (ok true)
  )
)

;; Add emergency administrator with validation
(define-public (add-emergency-admin (admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get dao-admin)) ERR-NOT-AUTHORIZED)
    ;; Prevent contract self-assignment as admin
    (asserts! (not (is-eq admin (as-contract tx-sender))) ERR-INVALID-PARAMETER)
    (map-set emergency-admins admin true)
    (ok true)
  )
)

;; DELEGATION SYSTEM

;; Delegate voting power to another member
(define-public (delegate-votes
    (delegate-to principal)
    (amount uint)
    (expiry uint)
  )
  (let (
      (caller tx-sender)
      (member-info (unwrap! (get-member-info caller) ERR-NOT-AUTHORIZED))
    )
    ;; Comprehensive delegation validation
    (asserts! (not (is-eq delegate-to caller)) ERR-INVALID-DELEGATE)
    (asserts! (is-some (get-member-info delegate-to)) ERR-INVALID-DELEGATE)
    (asserts! (>= (get voting-power member-info) amount) ERR-INSUFFICIENT-FUNDS)
    (asserts! (> expiry stacks-block-height) ERR-INVALID-PARAMETER)

    ;; Record delegation
    (map-set delegations caller {
      delegate: delegate-to,
      amount: amount,
      expiry: expiry,
    })

    ;; Update delegator's voting power
    (map-set members caller
      (merge member-info { voting-power: (- (get voting-power member-info) amount) })
    )
    (ok true)
  )
)

;; PROPOSAL MANAGEMENT

;; Create new governance proposal with comprehensive validation
(define-public (create-proposal
    (title (string-ascii 100))
    (description (string-utf8 1000))
    (amount uint)
    (target principal)
  )
  (let (
      (caller tx-sender)
      (current-block stacks-block-height)
      (proposal-id (+ (var-get proposal-count) u1))
      (params (var-get dao-parameters))
      (end-block (+ current-block (get voting-period params)))
    )
    ;; Extensive input validation
    (asserts! (not (is-eq target (as-contract tx-sender))) ERR-INVALID-PARAMETER)
    (asserts! (> (len title) u0) ERR-INVALID-PARAMETER)
    (asserts! (> (len description) u0) ERR-INVALID-PARAMETER)
    (asserts! (is-some (get-member-info caller)) ERR-NOT-AUTHORIZED)
    (asserts! (>= (var-get treasury-balance) amount) ERR-INSUFFICIENT-FUNDS)
    (asserts! (>= amount (get min-proposal-amount params)) ERR-INVALID-AMOUNT)
    (asserts! (<= amount (get max-proposal-amount params)) ERR-INVALID-AMOUNT)

    ;; Collect proposal fee
    (try! (stx-transfer? (get proposal-fee params) caller (as-contract tx-sender)))

    ;; Store proposal with complete metadata
    (map-set proposals proposal-id {
      id: proposal-id,
      proposer: caller,
      title: title,
      description: description,
      amount: amount,
      target: target,
      start-block: (+ current-block (get voting-delay params)),
      end-block: end-block,
      yes-votes: u0,
      no-votes: u0,
      status: "active",
      executed: false,
    })
    (var-set proposal-count proposal-id)
    (ok proposal-id)
  )
)

;; RETURN DISTRIBUTION SYSTEM

;; Create investment return pool for executed proposals
(define-public (create-return-pool
    (proposal-id uint)
    (total-amount uint)
  )
  (let (
      (caller tx-sender)
      (proposal (unwrap! (get-proposal-by-id proposal-id) ERR-PROPOSAL-NOT-ACTIVE))
    )
    ;; Validate pool creation prerequisites
    (asserts! (is-eq caller (var-get dao-admin)) ERR-NOT-AUTHORIZED)
    (asserts! (> total-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (is-eq (get status proposal) "executed") ERR-PROPOSAL-NOT-ACTIVE)

    ;; Initialize return pool
    (map-set return-pools proposal-id {
      total-amount: total-amount,
      distributed-amount: u0,
      distribution-start: stacks-block-height,
      distribution-end: (+ stacks-block-height (get timelock-period (var-get dao-parameters))),
      claims: (list),
    })
    (ok true)
  )
)

;; Claim proportional returns from investment pools
(define-public (claim-returns (proposal-id uint))
  (let (
      (caller tx-sender)
      (pool (unwrap! (get-return-pool proposal-id) ERR-NO-RETURNS))
      (member-info (unwrap! (get-member-info caller) ERR-NOT-AUTHORIZED))
      (claim-amount (calculate-member-share caller proposal-id))
    )
    ;; Validate claim eligibility
    (asserts! (> claim-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (not (has-claimed caller proposal-id)) ERR-ALREADY-VOTED)

    ;; Record member claim
    (map-set member-claims {
      member: caller,
      pool-id: proposal-id,
    } {
      amount: claim-amount,
      claimed: true,
    })

    ;; Update pool distribution tracking
    (map-set return-pools proposal-id
      (merge pool {
        distributed-amount: (+ (get distributed-amount pool) claim-amount),
        claims: (unwrap! (as-max-len? (append (get claims pool) caller) u200)
          ERR-INVALID-PARAMETER
        ),
      })
    )

    ;; Execute return transfer
    (try! (stx-transfer? claim-amount (as-contract tx-sender) caller))
    (ok true)
  )
)