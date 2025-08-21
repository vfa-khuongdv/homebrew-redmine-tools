package ui

import (
	"fmt"
	"os"
	"readmine-tools/redmine"

	"github.com/manifoldco/promptui"
)

func PromptInput(label string) string {
	prompt := promptui.Prompt{
		Label: label,
	}
	result, err := prompt.Run()
	if err != nil {
		fmt.Println("\n🥺 Huhu cancel rồi à? Okela bye bestie!")
		os.Exit(0)
	}
	return result
}

func PromptConfirm(label string) bool {
	prompt := promptui.Prompt{
		Label:     label,
		IsConfirm: true,
	}
	result, err := prompt.Run()
	return err == nil && (result == "y" || result == "Y")
}

func SelectStatus(statuses []redmine.Status) redmine.Status {
	templates := &promptui.SelectTemplates{
		Label:    "{{ . }}?",
		Active:   "✨ {{ .Name | cyan }} ({{ .ID }})",
		Inactive: "  {{ .Name | cyan }} ({{ .ID }})",
		Selected: "🎯 {{ .Name | red | cyan }}",
	}

	prompt := promptui.Select{
		Label:     "🌈 Chọn status nào để flex nè",
		Items:     statuses,
		Templates: templates,
	}

	i, _, err := prompt.Run()
	if err != nil {
		fmt.Println("\n� Ơ cancel status rồi, bye bye!")
		os.Exit(0)
	}

	return statuses[i]
}

func SelectIssues(issues []redmine.Issue) []redmine.Issue {
	if len(issues) == 0 {
		fmt.Println("😭 Huhu không có issue nào trong range này bestie ơiii")
		return []redmine.Issue{}
	}

	// Sử dụng promptui với custom template để chọn multiple
	var selected []redmine.Issue
	currentIndex := 0 // Track current cursor position

	for {
		// Clear screen để hiển thị fresh list
		fmt.Print("\033[2J\033[H")

		// Hiển thị header
		fmt.Printf("🎮 TICKET SELECTOR PRO MAX PLUS (Đã pick: %d/%d)\n", len(selected), len(issues))
		fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		// Hiển thị danh sách đã chọn nếu có
		if len(selected) > 0 {
			fmt.Println("💎 Tickets trong giỏ hàng:")
			for _, sel := range selected {
				fmt.Printf("   🛒 #%d - %s\n", sel.ID, sel.Title)
			}
			fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		}

		// Hiển thị danh sách issues với status đã chọn
		var items []string
		for _, issue := range issues {
			status := "⬜"
			for _, sel := range selected {
				if sel.ID == issue.ID {
					status = "✅"
					break
				}
			}
			items = append(items, fmt.Sprintf("%s #%d - %s", status, issue.ID, issue.Title))
		}
		items = append(items, "🚀 Xong rồi! Ship đi thôi!")

		prompt := promptui.Select{
			Label:     "💫 Chọn ticket nào để bỏ vào giỏ (Enter để add/remove)",
			Items:     items,
			CursorPos: currentIndex, // Set cursor position
			Templates: &promptui.SelectTemplates{
				Active:   "👉 {{ . | cyan }}",
				Inactive: "   {{ . }}",
				Selected: "✨ {{ . | green }}",
			},
		}

		idx, _, err := prompt.Run()
		if err != nil {
			fmt.Println("\n🛑 Ơ cancel ticket rồi, bye bye!")
			os.Exit(0)
		}

		// Update cursor position for next iteration
		currentIndex = idx

		// Nếu chọn "Xong"
		if idx == len(issues) {
			break
		}

		// Toggle selection
		issue := issues[idx]
		found := false
		for i, sel := range selected {
			if sel.ID == issue.ID {
				// Remove from selected
				selected = append(selected[:i], selected[i+1:]...)
				found = true
				break
			}
		}
		if !found {
			// Add to selected
			selected = append(selected, issue)
		}

		// Continue immediately without pause
	}

	// Final summary
	fmt.Print("\033[2J\033[H")
	fmt.Printf("🎊 YAS QUEEN! Đã chọn %d tickets để update nè!\n", len(selected))
	if len(selected) > 0 {
		fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		for _, sel := range selected {
			fmt.Printf("   🎯 #%d - %s\n", sel.ID, sel.Title)
		}
		fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	}

	return selected
}
