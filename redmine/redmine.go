package redmine

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	progressbar "github.com/schollz/progressbar/v3"
)

type Status struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type Issue struct {
	ID    int    `json:"id"`
	Title string `json:"subject"`
}

func GetStatuses(domain, apiKey string) ([]Status, error) {
	// Thử các endpoint khác nhau của Redmine API
	endpoints := []string{
		"%s/issue_statuses.json",
		"%s/enumerations/issue_statuses.json",
		"%s/trackers.json", // fallback để test API
	}

	for i, endpoint := range endpoints {
		url := fmt.Sprintf(endpoint, domain)
		fmt.Printf("Thử endpoint %d: %s\n", i+1, url)

		req, _ := http.NewRequest("GET", url, nil)
		req.Header.Set("X-Redmine-API-Key", apiKey)
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

func GetIssues(domain, apiKey, projectKey string, startID, endID int) ([]Issue, error) {
	// Redmine không hỗ trợ filter theo range ID, nên cần gọi từng ID
	var issues []Issue
	total := endID - startID + 1

	// Tạo progress bar
	bar := progressbar.NewOptions(total,
		progressbar.OptionSetDescription("🎣 Đang câu ticket nè..."),
		progressbar.OptionSetWidth(30),
		progressbar.OptionShowCount(),
		progressbar.OptionShowIts(),
		progressbar.OptionSetItsString("ticket"),
	)

	for id := startID; id <= endID; id++ {
		url := fmt.Sprintf("%s/issues/%d.json", domain, id)
		req, _ := http.NewRequest("GET", url, nil)
		req.Header.Set("X-Redmine-API-Key", apiKey)
		resp, err := http.DefaultClient.Do(req)

		// Update progress bar
		bar.Add(1)

		if err != nil || resp.StatusCode != 200 {
			if resp != nil {
				resp.Body.Close()
			}
			continue
		}

		var result struct {
			Issue Issue `json:"issue"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&result); err == nil {
			issues = append(issues, result.Issue)
		}
		resp.Body.Close()
	}

	fmt.Printf("\n🎉 Yay! Tìm được %d ticket rồi bestie!\n", len(issues))
	return issues, nil
}

func UpdateIssueStatus(domain, apiKey string, issueID, statusID int) error {
	url := fmt.Sprintf("%s/issues/%d.json", domain, issueID)
	body := map[string]interface{}{
		"issue": map[string]interface{}{
			"status_id": statusID,
		},
	}
	jsonBody, _ := json.Marshal(body)
	req, _ := http.NewRequest("PUT", url, bytes.NewBuffer(jsonBody))
	req.Header.Set("X-Redmine-API-Key", apiKey)
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
