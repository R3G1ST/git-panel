package database

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"log"
	"xferant-vpn/internal/config"
)

func Init(cfg config.DatabaseConfig) (*gorm.DB, error) {
	dsn := buildDSN(cfg)
	
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	
	// Auto migrate models
	err = db.AutoMigrate(&User{})
	if err != nil {
		return nil, err
	}
	
	log.Println("Database connection established")
	return db, nil
}

func buildDSN(cfg config.DatabaseConfig) string {
	return "host=" + cfg.Host +
		" user=" + cfg.User +
		" password=" + cfg.Password +
		" dbname=" + cfg.DBName +
		" port=" + cfg.Port +
		" sslmode=" + cfg.SSLMode
}

type User struct {
	ID        string `gorm:"primaryKey"`
	Email     string `gorm:"uniqueIndex"`
	Username  string
	Status    string
	CreatedAt int64
}
