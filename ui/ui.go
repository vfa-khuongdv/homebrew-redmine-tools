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

func PromptPassword(label string) string {
	prompt := promptui.Prompt{
		Label: label,
		Mask:  '*',
	}
	result, err := prompt.Run()
	if err != nil {
		fmt.Println("\n🥺 Huhu cancel rồi à? Okela bye bestie!")
		os.Exit(0)
	}
	return result
}

func PromptSelect(label string, options []string) int {
	prompt := promptui.Select{
		Label: label,
		Items: options,
	}
	index, _, err := prompt.Run()
	if err != nil {
		fmt.Println("\n🥺 Huhu cancel rồi à? Okela bye bestie!")
		os.Exit(0)
	}
	return index
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
			fmt.Println("💎 TICKETS IN CART:")
			fmt.Println("┌─────────┬─────────────────────────────────────────────────────────────────┐")
			fmt.Println("│ TICKET  │ TITLE                                                           │")
			fmt.Println("├─────────┼─────────────────────────────────────────────────────────────────┤")
			for _, sel := range selected {
				title := sel.Title
				if len(title) > 65 {
					title = title[:62] + "..."
				}
				fmt.Printf("│ #%-6d │ %-63s │\n", sel.ID, title)
			}
			fmt.Println("└─────────┴─────────────────────────────────────────────────────────────────┘")
		}

		// Hiển thị danh sách issues với format đẹp hơn
		fmt.Println("\n📋 ALL TICKETS (✅ = selected, ⬜ = not selected):")
		fmt.Println("┌─────┬─────────┬─────────────────────────────────────────────────────────────┐")
		fmt.Println("│ SEL │ TICKET  │ TITLE                                                       │")
		fmt.Println("├─────┼─────────┼─────────────────────────────────────────────────────────────┤")
		
		var items []string
		for _, issue := range issues {
			status := "⬜"
			for _, sel := range selected {
				if sel.ID == issue.ID {
					status = "✅"
					break
				}
			}
			
			title := issue.Title
			if len(title) > 59 {
				title = title[:56] + "..."
			}
			
			displayLine := fmt.Sprintf("│ %s │ #%-6d │ %-59s │", status, issue.ID, title)
			items = append(items, displayLine)
		}
		
		items = append(items, "│ 🚀  │ FINISH  │ DONE - PROCEED TO STATUS SELECTION                     │")

		prompt := promptui.Select{
			Label:     "\n💫 Select a ticket to add/remove from selection (↑↓ navigate, Enter to toggle)",
			Items:     items,
			CursorPos: currentIndex,
			Size:      12, // Show more items at once
			Templates: &promptui.SelectTemplates{
				Active:   "👉 {{ . | cyan | bold }}",
				Inactive: "   {{ . }}",
				Selected: "✨ {{ . | green | bold }}",
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

	// Final summary with improved formatting
	fmt.Print("\033[2J\033[H")
	fmt.Printf("╔═══════════════════════════════════════════════════════════════════════════╗\n")
	fmt.Printf("║                          🎊 SELECTION COMPLETE!                          ║\n")
	fmt.Printf("║                        Selected %d tickets for update                     ║\n", len(selected))
	fmt.Printf("╚═══════════════════════════════════════════════════════════════════════════╝\n")
	
	if len(selected) > 0 {
		fmt.Println("\n🎯 FINAL SELECTION:")
		fmt.Println("┌─────────┬─────────────────────────────────────────────────────────────────┐")
		fmt.Println("│ TICKET  │ TITLE                                                           │")
		fmt.Println("├─────────┼─────────────────────────────────────────────────────────────────┤")
		for _, sel := range selected {
			title := sel.Title
			if len(title) > 65 {
				title = title[:62] + "..."
			}
			fmt.Printf("│ #%-6d │ %-63s │\n", sel.ID, title)
		}
		fmt.Println("└─────────┴─────────────────────────────────────────────────────────────────┘")
		fmt.Println("\n🚀 Ready to proceed to status selection!")
	} else {
		fmt.Println("\n⚠️  No tickets selected. The operation will be cancelled.")
	}

	return selected
}
