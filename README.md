# Assignment 3 — CI/CD with GitHub Actions

A Bash-based DevOps utility with a local CI pipeline using GitHub Actions and Docker.

## Project Structure

```text
assignment-3/
├── README.md
├── app/
│   └── app.sh
├── scripts/
│   ├── lint.sh
│   └── build.sh
├── tests/
│   └── test.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── Dockerfile
├── compose.yaml
└── .dockerignore