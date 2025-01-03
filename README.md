# CI/CD Pipeline Documentation

This GitHub Actions pipeline is designed to manage the CI/CD lifecycle
of a Python-based application. It supports actions such as deploying
a Dockerized application to an AWS EC2 instance or terminating the
instance. The workflow automates tasks like version extraction,
code linting, building, validation, Docker image deployment,
and managing EC2 instances.

## Workflow Jobs

### 1. **Extract Versions**

**Path:** `.github/workflows/extract-versions.yml`

- **Description:**
  - Extracts application and Python version information from
  the `project.properties` file.
  - Provides the versions through output variables for use in subsequent jobs.
- **Trigger:** Skipped if the `terminate` action is selected.

### 2. **Lint**

**Path:** `.github/workflows/lint.yml`

- **Description:**
  - Analyzes the codebase for potential issues and ensures compliance
    with Python style guidelines.
  - Uses `flake8`, `editorconfig-checker`, and `markdownlint` for linting.
- **Dependencies:** Needs the `extract-versions` job for the Python version.

### 3. **Build**

**Path:** `.github/workflows/build.yml`

- **Description:**
  - Compiles and builds the application.
  - Uploads 3 artifacts: the application source code,
    Dockerfile and sql scripts.
- **Dependencies:** Needs the `lint` and `extract-versions` jobs.

### 4. **Validate Build**

**Path:** `.github/workflows/validate-build.yml`

- **Description:**
  - Validates the build using tools like SonarQube for code quality
    and Snyk for vulnerability scanning.
- **Dependencies:** Needs the `build` and `extract-versions` jobs.

### 5. **Docker**

**Description:**

- **Steps:**
  - Downloads the application source code and Dockerfile as artifacts.
  - Builds a multi-platform Docker image and pushes it to Docker Hub.
- **Dependencies:** Needs the `extract-versions` and `validate-build` jobs.

### 6. **Deploy**

**Trigger:** Runs only when the `deploy` action is selected.

- **Description:**
  - Provisions an AWS EC2 instance and deploys the Docker container.
  - Configures AWS credentials using
    `aws-actions/configure-aws-credentials@v3`.
  - Sets up an SSH key pair for accessing the EC2 instance.
  - Starts an EC2 instance using the specified AMI, instance type,
    security group, and subnet and gets it's ID.
  - Waits for the instance to be fully initialized before proceeding.
  - Retrieves the EC2 instance's public IP.
  - Connects to the instance via SSH, installs Docker and runs
    the Docker Container from Dockerhub.
  - Commits the instance ID to the repository for later reference.
  - Cleans up temporary SSH key files.
- **Dependencies:** Needs the `docker` and `extract-versions` jobs.

### 7. **Terminate**

**Trigger:** Runs only when the `terminate` action is selected.

- **Description:**
  - Reads the EC2 instance ID from the repository and terminates the instance.
  - Waits for the instance to be fully terminated before completing the job.
- **Dependencies:** None.

## Inputs

### Workflow Dispatch Inputs

- `action` (Required): Defines the workflow action to execute.
  - Options: `deploy`, `terminate`
  - Default: `deploy`
  - On `deploy`, the workflow provisions an EC2 instance, connects to it via
    ssh, installs docker and runs the container from dockerhub.
  - On `terminate`, the workflow terminates the EC2 instance,
    whose id is saved in a file in the repository.

## Secrets

- **AWS\_ACCESS\_KEY**: AWS access key ID.
- **AWS\_SECRET\_ACCESS\_KEY**: AWS secret access key.
- **AWS\_REGION**: AWS region for EC2 operations.
- **EB\_APP\_NAME**: Elastic Beanstalk application name (if applicable).
- **EB\_ENV\_NAME**: Elastic Beanstalk environment name (if applicable).
- **DOCKERHUB\_USERNAME**: Docker Hub username.
- **DOCKERHUB\_TOKEN**: Docker Hub access token.
- **SONAR\_TOKEN**: SonarQube access token for build validation.
- **SNYK\_TOKEN**: Snyk access token for vulnerability scanning.
- **EC2\_KEY\_PAIR**: EC2 key pair private key content.
- **EC2\_KEY\_PAIR\_NAME**: EC2 key pair name.
- **AWS\_AMI\_ID**: AWS AMI ID for EC2 instance.
- **EC2\_INSTANCE\_TYPE**: EC2 instance type.
- **AWS\_SECURITY\_GROUP\_ID**: Security group ID for EC2 instance.
- **AWS\_PUBLIC\_SUBNET\_ID**: Public subnet ID for EC2 instance.
