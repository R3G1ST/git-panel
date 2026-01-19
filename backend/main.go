package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"xferant-vpn/backend/internal/api"
	"xferant-vpn/backend/internal/config"
	"xferant-vpn/backend/internal/database"
)

func main() {
	// 1. Загрузка конфигурации
	log.Println("Loading configuration...")
	cfg := config.Load()
	
	// 2. Подключение к базе данных
	log.Println("Connecting to database...")
	db, err := database.Init(cfg.Database)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	log.Println("Database connection established")
	
	// 3. Создание и настройка сервера
	log.Println("Initializing API server...")
	server := api.NewServer(cfg, db)
	
	// 4. Настройка graceful shutdown
	ctx, stop := signal.NotifyContext(context.Background(), 
		os.Interrupt, syscall.SIGTERM, syscall.SIGQUIT)
	defer stop()
	
	// 5. Запуск сервера в отдельной горутине
	serverErr := make(chan error, 1)
	go func() {
		log.Printf("Starting server on %s", cfg.Server.Address)
		if err := server.Start(); err != nil {
			serverErr <- err
		}
	}()
	
	// 6. Ожидание сигнала завершения
	select {
	case err := <-serverErr:
		log.Fatalf("Server error: %v", err)
	case <-ctx.Done():
		log.Println("Shutdown signal received")
	}
	
	// 7. Graceful shutdown
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	
	log.Println("Shutting down server gracefully...")
	// Здесь можно добавить закрытие ресурсов (база данных, пулы и т.д.)
	
	log.Println("Server stopped")
}