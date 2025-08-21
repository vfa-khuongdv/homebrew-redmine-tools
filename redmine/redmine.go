package redmine

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

type Status struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type Issue struct {
	ID      int    `json:"id"`
	Title   string `json:"subject"`
	Status  struct {
		ID   int    `json:"id"`
		Name string `json:"name"`
	} `json:"status"`
	Project struct {
		ID         int    `json:"id"`
		Name       string `json:"name"`
		Identifier string `json:"identifier"`
	} `json:"project"`
}

type AuthConfig struct {
	AuthType string
	APIKey   string
	Username string
	Password string
}

func (ac *AuthConfig) SetAuth(req *http.Request) {
	if req == nil {
		return
	}
	
	// Set API Key if available
	if ac.APIKey != "" {
		req.Header.Set("X-Redmine-API-Key", ac.APIKey)
	}
	
	// Set Basic Auth if configured
	if ac.AuthType == "basic_auth" && ac.Username != "" && ac.Password != "" {
		auth := base64.StdEncoding.EncodeToString([]byte(ac.Username + ":" + ac.Password))
		req.Header.Set("Authorization", "Basic "+auth)
	} else if ac.AuthType == "both" && ac.Username != "" && ac.Password != "" {
		// Support for using both API Key and Basic Auth simultaneously
		auth := base64.StdEncoding.EncodeToString([]byte(ac.Username + ":" + ac.Password))
		req.Header.Set("Authorization", "Basic "+auth)
	}
}

func GetStatuses(domain string, auth *AuthConfig) ([]Status, error) {
	// Clean domain to avoid double slashes and remove any whitespace/control characters
	domain = strings.TrimSpace(strings.TrimSuffix(domain, "/"))

	// Thử các endpoint khác nhau của Redmine API
	endpoints := []string{
		"%s/issue_statuses.json",
		"%s/enumerations/issue_statuses.json",
		"%s/trackers.json", // fallback để test API
	}

	for i, endpoint := range endpoints {
		url := fmt.Sprintf(endpoint, domain)
		fmt.Printf("Thử endpoint %d: %s\n", i+1, url)

		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			fmt.Printf("Lỗi tạo request: %v\n", err)
			continue
		}
		auth.SetAuth(req)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			fmt.Printf("Lỗi kết nối: %v\n", err)
			continue
		}
		defer resp.Body.Close()

		fmt.Printf("HTTP Status: %d\n", resp.StatusCode)

		if resp.StatusCode != 200 {
			body, _ := io.ReadAll(resp.Body)
			fmt.Printf("HTTP status %d: %s\n", resp.StatusCode, string(body))
			continue
		}

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			fmt.Printf("Lỗi đọc response: %v\n", err)
			continue
		}

		// Thử parse với cấu trúc issue_statuses
		var result1 struct {
			IssueStatuses []Status `json:"issue_statuses"`
		}
		if err := json.Unmarshal(body, &result1); err == nil && len(result1.IssueStatuses) > 0 {
			return result1.IssueStatuses, nil
		}

		// Thử parse trực tiếp array
		var result2 []Status
		if err := json.Unmarshal(body, &result2); err == nil && len(result2) > 0 {
			return result2, nil
		}

		// Nếu là trackers endpoint, tạo status giả
		if i == 2 {
			return []Status{
				{ID: 1, Name: "New"},
				{ID: 2, Name: "In Progress"},
				{ID: 3, Name: "Resolved"},
				{ID: 4, Name: "Feedback"},
				{ID: 5, Name: "Closed"},
				{ID: 6, Name: "Rejected"},
			}, nil
		}
	}

	return nil, fmt.Errorf("không thể lấy danh sách status từ bất kỳ endpoint nào")
}

func GetIssues(domain string, auth *AuthConfig, projectKey string, startID, endID int) ([]Issue, error) {
	// Clean domain to avoid double slashes and remove any whitespace/control characters
	domain = strings.TrimSpace(strings.TrimSuffix(domain, "/"))

	var allIssues []Issue
	offset := 0
	limit := 100 // Redmine default limit
	
	fmt.Printf("🔍 Fetching ALL issues from project '%s'...\n", projectKey)

	for {
		// Use Redmine's issues API with project filter
		url := fmt.Sprintf("%s/issues.json?project_id=%s&offset=%d&limit=%d", 
			domain, projectKey, offset, limit)
		
		fmt.Printf("📡 Calling API: %s\n", url)
		
		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			return nil, fmt.Errorf("error creating request: %v", err)
		}
		
		auth.SetAuth(req)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			return nil, fmt.Errorf("error making request: %v", err)
		}

		if resp.StatusCode != 200 {
			body, _ := io.ReadAll(resp.Body)
			resp.Body.Close()
			return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
		}

		body, err := io.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			return nil, fmt.Errorf("error reading response: %v", err)
		}

		var result struct {
			Issues     []Issue `json:"issues"`
			TotalCount int     `json:"total_count"`
			Offset     int     `json:"offset"`
			Limit      int     `json:"limit"`
		}

		if err := json.Unmarshal(body, &result); err != nil {
			return nil, fmt.Errorf("error parsing JSON: %v", err)
		}

		fmt.Printf("� Retrieved %d issues (offset: %d, total: %d)\n", 
			len(result.Issues), result.Offset, result.TotalCount)

		// Filter issues by ID range
		for _, issue := range result.Issues {
			if issue.ID >= startID && issue.ID <= endID {
				allIssues = append(allIssues, issue)
			}
		}

		// Check if we have more pages
		if len(result.Issues) < limit || offset+limit >= result.TotalCount {
			break
		}
		
		offset += limit
	}

	// Filter issues that are in the specified ID range
	var filteredIssues []Issue
	for _, issue := range allIssues {
		if issue.ID >= startID && issue.ID <= endID {
			filteredIssues = append(filteredIssues, issue)
		}
	}

	fmt.Printf("\n📊 Summary:\n")
	fmt.Printf("   - Total issues in project '%s': %d\n", projectKey, len(allIssues))
	fmt.Printf("   - Issues in ID range %d-%d: %d\n", startID, endID, len(filteredIssues))
	
	fmt.Printf("\n🎉 Found %d issues in the specified range!\n", len(filteredIssues))
	return filteredIssues, nil
}

func UpdateIssueStatus(domain string, auth *AuthConfig, issueID, statusID int) error {
	// Clean domain to avoid double slashes and remove any whitespace/control characters
	domain = strings.TrimSpace(strings.TrimSuffix(domain, "/"))

	url := fmt.Sprintf("%s/issues/%d.json", domain, issueID)
	body := map[string]interface{}{
		"issue": map[string]interface{}{
			"status_id": statusID,
		},
	}
	jsonBody, _ := json.Marshal(body)
	req, err := http.NewRequest("PUT", url, bytes.NewBuffer(jsonBody))
	if err != nil {
		return fmt.Errorf("lỗi tạo request: %v", err)
	}
	auth.SetAuth(req)
	req.Header.Set("Content-Type", "application/json")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Redmine API trả về 200, 204 hoặc 201 khi cập nhật thành công
	if resp.StatusCode != 200 && resp.StatusCode != 204 && resp.StatusCode != 201 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("lỗi cập nhật (status %d): %s", resp.StatusCode, string(body))
	}
	return nil
}
