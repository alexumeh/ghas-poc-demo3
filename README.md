# Demo 3 - Third Party Integration with GHAS

The following demo shows how to integrate with third party services that push SARIF format findings back into GitHub Advanced Security.

## SARIF Format Introduction

First we are going to walk through the OASIS SARIF format. 

The term SARIF stands for "Static Analysis Results Interchange Format". This is a JSON based standard for the output of static analysis tooling. 

Microsoft provides a (fairly old) tutorial on SARIF that can be accessed on GitHub at:

https://github.com/microsoft/sarif-tutorials

For those not familiar with the concept static analysis toolis work by exmaining the code for issues without executing it (hence the difference with DAST - Dynamic analysis). Within the static anaylsis ecosystem there are security related tools as well as those that fall outside of security, such as linters and style checkers.

Leveraging security tools that can output findings in SARIF format, means you can aggregate your results in GitHub Advanced Security, thus providing a single pane of glass around vulnerabilities. 

An addiitonal benefit of SARIF format tools is that tools which complement GHAS such as Endor labs can be integrated into your CI/CD workflows, thus providing teams with a "leveled up" experience. 

In today's demo we will look at integrating the GitHub repository with commerical tooling from Endor labs, and open source tooling in the form of the Trivy IaC scanner. 


## Endor Labs Example

Ensure you have an Endor Labs account setup at https://www.endorlabs.com

### Setup


Once your account is in place you will need:

1. A tenant

2. A namespace configured

3. Access Control policy setup, this should be: 

a. An AUTH POLICY 

b. ID Provider should be GitHub Action 

c. Rule should be user=<your GitHub Org name> 

d. Permissions should be Code Scanner e. Under Advanced, set the namespace to yours, and select the Propagate this policy to all child namespaces option


With this setup, you can then configure the Actions for each projct typ elisted below, to point to your tenant and namespace. 



### JavaScript Example Program 

An example of a vulnerable JavaScript application. This is coupled with an example Endor Labs GitHub Action.


### Endor Labs Action

Add the following Action to your workflow:

```yaml

name: "Endor Labs: Example Scan of JavaScript"
on:
  pull_request:
    branches: [ "main" ]
jobs:
  create_project_javascript:
    permissions:
      id-token: write # This is required for requesting the JWT
      contents: read  # Required by actions/checkout@v4 to checkout a private repository
      actions: read
      repository-projects: read
      pull-requests: read
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout Repository'
        uses: actions/checkout@v4
      - name: 'Use Node.js'
        uses: actions/setup-node@v4
        with:
          node-version: '20.x'
      - run: npm ci
        working-directory: ./my-vulnerable-nodejs-app
      - run: npm run build --if-present
        working-directory: ./my-vulnerable-nodejs-app
      - name: 'Scan JS with Endor Labs'
        uses: endorlabs/github-action@main # This workflow uses the Endor Labs GitHub action to scan.
        with:
          namespace: 'your_name_space_here'
          pr: false
          scan_secrets: true
          scan_dependencies: true
          log_verbose: true
          scan_summary_output_type: 'table'
          sarif_file: 'findings.sarif'
      - name: 'Upload findings to GitHub'
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'findings.sarif'
```

## Trivy Example


Trivy is an IaC scanner that outputs findings in SARIF format. These can then be ingested into GitHub and displayed for remediation.


```yaml

name: build
on:
  push:
    branches:
      - main
  pull_request:
jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner in repo mode
        uses: aquasecurity/trivy-action@0.20.0
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL'

      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

```


