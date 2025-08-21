package config

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

type Config struct {
	APIKey     string `json:"api_key"`
	Domain     string `json:"domain"`
	ProjectKey string `json:"project_key"`
	StartID    int    `json:"start_id"`
	EndID      int    `json:"end_id"`
}

func GetConfigPath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".redmine-tools-config.json")
}

func LoadConfig() (*Config, error) {
	configPath := GetConfigPath()
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		return &Config{}, nil
	}

	data, err := os.ReadFile(configPath)
	if err != nil {
		return nil, err
	}

	var config Config
	err = json.Unmarshal(data, &config)
	return &config, err
}

func (c *Config) Save() error {
	configPath := GetConfigPath()
	data, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(configPath, data, 0644)
}

func (c *Config) Print() {
	fmt.Printf("Cấu hình hiện tại:\n")
	fmt.Printf("- API Key: %s\n", maskAPIKey(c.APIKey))
	fmt.Printf("- Domain: %s\n", c.Domain)
	fmt.Printf("- Project Key: %s\n", c.ProjectKey)
	fmt.Printf("- Issue Range: %d -> %d\n", c.StartID, c.EndID)
}

func maskAPIKey(apiKey string) string {
	if len(apiKey) <= 8 {
		return "***"
	}
	return apiKey[:4] + "***" + apiKey[len(apiKey)-4:]
}
