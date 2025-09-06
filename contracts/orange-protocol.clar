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