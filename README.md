# 🧠 headers-checker.sh

A **secure Bash-based HTTP header scanner** that helps **pentesters**, **bug bounty hunters**, and **DevSecOps teams** quickly identify missing or weak **security headers**.

---

## 🔍 Overview

`headers-checker.sh` scans a given URL and reports key **HTTP security headers** such as:

- `Strict-Transport-Security`  
- `Content-Security-Policy`  
- `X-Frame-Options`  
- `X-Content-Type-Options`  
- `Referrer-Policy`  

These headers are critical for preventing attacks like **clickjacking**, **MIME sniffing**, and **content injection**.

---

## ⚙️ Features

✅ **Color-coded output** – visually spot missing headers  
✅ **JSON output** (`--json-out`) – great for CI/CD pipelines or bug reports  
✅ **Safe curl usage** – no `eval`, strict error handling, and SSL verification  
✅ **CI/CD friendly** (`--non-interactive`) – predictable exit codes for automation  
✅ **URL validation & HTTPS enforcement** – prevents mis-scans and mistakes  
✅ **Cross-platform** – works on Linux, macOS, and WSL  

---

## 💡 Why use this instead of plain `curl -I`?

While `curl -I` only dumps raw headers, `headers-checker.sh` adds:
- **Readable & color-coded output** highlighting missing protections  
- **Safe defaults & meaningful exit codes** for scripting/CI  
- **Automatic HTTPS checks & URL validation**  
- **JSON results** for structured automation  
- **Extensible checks** – add new headers or logic anytime  

👉 **Think of it as “curl -I on steroids” — safer, smarter, and CI-ready.**

---

## 🚀 Usage Examples

```bash
# Basic scan
./headers-checker.sh https://example.com

# Save results to JSON
./headers-checker.sh --json-out results.json https://example.com

# Skip HTTPS warnings (for self-signed environments)
./headers-checker.sh --insecure https://test.local

# Non-interactive mode (for CI/CD)
./headers-checker.sh --non-interactive https://example.com
Example output:

pgsql
Copy code
[+] Checking: https://example.com
✅ Strict-Transport-Security found
❌ Content-Security-Policy missing
✅ X-Frame-Options found
✅ X-Content-Type-Options found
❌ Referrer-Policy missing

Scan completed successfully!
🧰 Exit Codes
Code	Meaning
0	Success
1	Usage error
2	Connection failed
3	Invalid URL
4	User aborted
5	Output error

🧩 Future Improvements
Add cookie flag analysis (Secure, HttpOnly, SameSite)

Add header strength scoring (HSTS duration, CSP rules)

Integrate into GitHub Actions / CI workflows

🛠 Example CI/CD Workflow
Here’s a ready-to-use GitHub Actions workflow you can include as .github/workflows/header-scan.yml:

yaml
Copy code
name: Security Header Scan

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run headers-checker
        run: |
          chmod +x headers-checker.sh
          ./headers-checker.sh --non-interactive --json-out results.json https://example.com
      - name: Upload JSON result
        uses: actions/upload-artifact@v4
        with:
          name: header-scan-results
          path: results.json
