package main

import (
	"fmt"
	"os"
	"os/signal"
	"readmine-tools/config"
	"readmine-tools/redmine"
	"readmine-tools/ui"
	"strconv"
	"syscall"

	progressbar "github.com/schollz/progressbar/v3"
)

var version = "dev"

func main() {
	// Check for version flag
	if len(os.Args) > 1 && (os.Args[1] == "--version" || os.Args[1] == "-v") {
		fmt.Printf("redmine-tools version %s\n", version)
		return
	}
	// Setup signal handling for graceful shutdown
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		fmt.Println("\n\n🥲 Ơ ơ, cancel rồi à? Okela bye bye nhaaa! 👋")
		fmt.Println("🫶 See you again bestie!")
		os.Exit(0)
	}()

	// Load existing config
	cfg, err := config.LoadConfig()
	if err != nil {
		fmt.Printf("🙄 Hmm config hơi lỗi xíu: %v\n", err)
		cfg = &config.Config{}
	}

	// Show current config if exists
	if cfg.APIKey != "" || cfg.Username != "" {
		// Set default auth type for existing configs
		if cfg.AuthType == "" {
			if cfg.APIKey != "" && cfg.Username != "" {
				cfg.AuthType = "both"
			} else if cfg.APIKey != "" {
				cfg.AuthType = "api_key"
			} else if cfg.Username != "" {
				cfg.AuthType = "basic_auth"
			}
		}
		cfg.Print()
		useExisting := ui.PromptConfirm("💫 Xài config cũ luôn khum? (y/n)")
		if !useExisting {
			cfg = &config.Config{}
		}
	}

	// Nhập thông tin cấu hình nếu chưa có hoặc không muốn dùng cũ
	if cfg.AuthType == "" {
		authType := ui.PromptSelect("🔐 Chọn kiểu xác thực nào nè:", []string{
			"API Key",
			"Basic Authentication (Username/Password)",
			"Both API Key & Basic Authentication",
		})
		if authType == 0 {
			cfg.AuthType = "api_key"
		} else if authType == 1 {
			cfg.AuthType = "basic_auth"
		} else {
			cfg.AuthType = "both"
		}
	}

	if cfg.AuthType == "api_key" || cfg.AuthType == "both" {
		if cfg.APIKey == "" {
			cfg.APIKey = ui.PromptInput("🔑 Alo alo, API Key đâu rồi:")
		}
	}
	
	if cfg.AuthType == "basic_auth" || cfg.AuthType == "both" {
		if cfg.Username == "" {
			cfg.Username = ui.PromptInput("👤 Username đâu rồi bestie:")
		}
		if cfg.Password == "" {
			cfg.Password = ui.PromptPassword("🔒 Password đi nào:")
		}
	}
	if cfg.Domain == "" {
		cfg.Domain = ui.PromptInput("🌐 Domain Redmine ở đâu vậy bestie (VD: https://redmine.example.com):")
	}
	if cfg.ProjectKey == "" {
		cfg.ProjectKey = ui.PromptInput("📂 Project key gì nè:")
	}
	if cfg.StartID == 0 {
		startIDStr := ui.PromptInput("🚀 Issue ID bắt đầu từ số mấy:")
		cfg.StartID, _ = strconv.Atoi(startIDStr)
	}
	if cfg.EndID == 0 {
		endIDStr := ui.PromptInput("🏁 Issue ID kết thúc ở số mấy:")
		cfg.EndID, _ = strconv.Atoi(endIDStr)
	}

	// Save config
	if err := cfg.Save(); err != nil {
		fmt.Printf("😅 Ối save config bị lỗi rồi: %v\n", err)
	}

	// Create auth config
	auth := &redmine.AuthConfig{
		AuthType: cfg.AuthType,
		APIKey:   cfg.APIKey,
		Username: cfg.Username,
		Password: cfg.Password,
	}

	// Step 1: Lấy danh sách ticket trước
	fmt.Println("🎣 Đang lấy ALL ticket từ project...")
	issues, err := redmine.GetIssues(cfg.Domain, auth, cfg.ProjectKey, cfg.StartID, cfg.EndID)
	if err != nil {
		fmt.Println("� Ối giời ơi, lấy ticket bị fail:", err)
		os.Exit(1)
	}

	if len(issues) == 0 {
		fmt.Println("😭 Huhu không có issue nào trong range này bestie ơ")
		os.Exit(0)
	}

	// Step 2: User chọn ticket nào cần update
	selected := ui.SelectIssues(issues)
	if len(selected) == 0 {
		fmt.Println("🤷‍♀️ Hmm bestie không chọn ticket nào cả, thôi bye!")
		os.Exit(0)
	}

	// Step 3: Lấy danh sách status và cho user chọn
	fmt.Println("🔍 Đang lục lọi danh sách status...")
	statuses, err := redmine.GetStatuses(cfg.Domain, auth)
	if err != nil {
		fmt.Println("� Ôi dồi ôi, lấy status bị lỗi rồi:", err)
		os.Exit(1)
	}
	status := ui.SelectStatus(statuses)

	// Step 4: Cập nhật status cho các ticket đã chọn
	fmt.Printf("\n🎉 Okayy, giờ update %d ticket sang status: %s nhaaa!\n", len(selected), status.Name)

	bar := progressbar.NewOptions(len(selected),
		progressbar.OptionSetDescription("🚀 Đang bắn update nè..."),
		progressbar.OptionSetWidth(30),
		progressbar.OptionShowCount(),
		progressbar.OptionShowIts(),
		progressbar.OptionSetItsString("ticket"),
	)

	successCount := 0
	var successTickets []redmine.Issue
	var failedTickets []struct {
		Issue redmine.Issue
		Error string
	}

	for _, issue := range selected {
		err := redmine.UpdateIssueStatus(cfg.Domain, auth, issue.ID, status.ID)
		bar.Add(1)

		if err != nil {
			failedTickets = append(failedTickets, struct {
				Issue redmine.Issue
				Error string
			}{issue, err.Error()})
		} else {
			successCount++
			successTickets = append(successTickets, issue)
		}
	}

	// Hiển thị kết quả chi tiết
	fmt.Printf("\n\n🎊 KẾT QUẢ UPDATE CHO BESTIE:\n")
	fmt.Printf("═══════════════════════════════════════════════\n")

	if len(successTickets) > 0 {
		fmt.Printf("🎯 SUCCESS GÒYYYY (%d ticket):\n", len(successTickets))
		for _, ticket := range successTickets {
			fmt.Printf("   🔥 #%-6d %s\n", ticket.ID, ticket.Title)
		}
		fmt.Println()
	}

	if len(failedTickets) > 0 {
		fmt.Printf("😭 MẤY EM NÀY FAIL RỒI (%d ticket):\n", len(failedTickets))
		for _, failed := range failedTickets {
			fmt.Printf("   💀 #%-6d %s\n", failed.Issue.ID, failed.Issue.Title)
			fmt.Printf("           😵 Lý do: %s\n", failed.Error)
		}
		fmt.Println()
	}

	fmt.Printf("🏆 THÀNH TÍCH CỦA BESTIE: %d/%d ticket đã update thành công (%.1f%%) 💪\n",
		successCount, len(selected), float64(successCount)/float64(len(selected))*100)
	fmt.Printf("═══════════════════════════════════════════════\n")
}
