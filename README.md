# SongToken
A decentralized music tokenization platform built on Sui blockchain that enables artists to mint and sell fractional ownership tokens of their songs using USDC payments.



# Features

Artist Token Minting: Artists can create tokenized representations of their songs with customizable supply

USDC Integration: Seamless purchasing of song tokens using USDC stablecoin

Fractional Ownership: Fans can buy fractional ownership of songs through tokenization

Vault System(Escrow): Secure token distribution and payment collection mechanism

Built With
Sui Move - Smart contract development

USDC - Stablecoin integration for payments

Sui Framework - Blockchain infrastructure

# Getting Started bash
# Build the project
sui move build

# Deploy to Sui network
sui client publish --gas-budget 100000000

Usage
1. Artists mint song tokens using mint_artist_token
2. Fans purchase tokens with USDC via buy_songtoken_with_usdc
3. Token ownership represents fractional rights to the song

# Caution
This prototype has not been fully tested.The buy_songtoken_with_usdc function payment amount is not set yet as so it will drain your testnet usdc.