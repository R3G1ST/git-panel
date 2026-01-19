package main

import (
	"log"
	"os"
	"xferant-vpn/internal/api"
	"xferant-vpn/internal/config"
	"xferant-vpn/internal/database"
)

func main() {
	// Load configuration
	cfg := config.Load()
	
	// Initialize database
	db, err := database.Init(cfg.Database)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	
	// Initialize and start server
	server := api.NewServer(cfg, db)
	
	log.Printf("Starting server on %s", cfg.Server.Address)
	if err := server.Start(); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
