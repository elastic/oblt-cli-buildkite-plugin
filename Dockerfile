FROM buildkite/plugin-tester:latest

# Create non-root user
RUN adduser --disabled-password --gecos "" plugin-tester
USER plugin-tester
