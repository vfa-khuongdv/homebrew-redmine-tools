package config

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

type Config struct {
	APIKey     string `json:"api_key"`
	Username   string `json:"username"`
	Password   string `json:"password"`
	Domain     string `json:"domain"`
	ProjectKey string `json:"project_key"`
	StartID    int    `json:"start_id"`
	EndID      int    `json:"end_id"`
	AuthType   string `json:"auth_type"` // "api_key", "basic_auth", or "both"
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

func (c *Config) IsBasicAuth() bool {
	return c.AuthType == "basic_auth" || c.AuthType == "both"
}

func (c *Config) Print() {
	fmt.Printf("Cấu hình hiện tại:\n")
	if c.AuthType == "basic_auth" {
		fmt.Printf("- Auth Type: Basic Authentication\n")
		fmt.Printf("- Username: %s\n", c.Username)
		fmt.Printf("- Password: %s\n", maskPassword(c.Password))
	} else if c.AuthType == "both" {
		fmt.Printf("- Auth Type: Both API Key & Basic Authentication\n")
		fmt.Printf("- API Key: %s\n", maskAPIKey(c.APIKey))
		fmt.Printf("- Username: %s\n", c.Username)
		fmt.Printf("- Password: %s\n", maskPassword(c.Password))
	} else {
		fmt.Printf("- Auth Type: API Key\n")
		fmt.Printf("- API Key: %s\n", maskAPIKey(c.APIKey))
	}
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

func maskPassword(password string) string {
	if len(password) == 0 {
		return ""
	}
	if len(password) <= 3 {
		return "***"
	}
	return password[:1] + "***" + password[len(password)-1:]
}
