.PHONY: help setup migrate test validate clean coverage lint format check-format

# Default target
help:
	@echo "KerjaFlow ASEAN Statutory Framework"
	@echo "===================================="
	@echo ""
	@echo "Available commands:"
	@echo "  make setup          - Install dependencies and setup environment"
	@echo "  make migrate        - Run all database migrations"
	@echo "  make test           - Run test suite"
	@echo "  make validate       - Validate statutory rates"
	@echo "  make coverage       - Generate coverage report"
	@echo "  make lint           - Run linters"
	@echo "  make format         - Format code with black"
	@echo "  make check-format   - Check code formatting"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make all            - Run migrate + test + validate"
	@echo ""
	@echo "Database Setup:"
	@echo "  1. Set environment variables:"
	@echo "     export KFLOW_DB_HOST=localhost"
	@echo "     export KFLOW_DB_NAME=kerjaflow"
	@echo "     export KFLOW_DB_USER=postgres"
	@echo "     export KFLOW_DB_PASSWORD=your_password"
	@echo "  2. Run: make migrate"
	@echo "  3. Run: make test"
	@echo "  4. Run: make validate"

setup:
	@echo "Installing dependencies..."
	cd backend && pip install -e ".[dev]"
	@echo "✅ Setup complete"

migrate:
	@echo "Running database migrations..."
	@for file in database/migrations/*.sql; do \
		echo "Executing $$file..."; \
		psql -h $(KFLOW_DB_HOST) -U $(KFLOW_DB_USER) -d $(KFLOW_DB_NAME) -f $$file || exit 1; \
	done
	@echo "✅ All migrations completed"

test:
	@echo "Running test suite..."
	cd backend && pytest kerjaflow/tests/ -v --tb=short
	@echo "✅ Tests complete"

validate:
	@echo "Validating statutory rates..."
	cd backend && python ../validation/statutory_rate_validator.py --all
	@echo "✅ Validation complete"

coverage:
	@echo "Generating coverage report..."
	cd backend && pytest kerjaflow/tests/ --cov=kerjaflow --cov-report=html --cov-report=term
	@echo "✅ Coverage report generated: backend/htmlcov/index.html"

lint:
	@echo "Running linters..."
	cd backend && flake8 kerjaflow/ --count --select=E9,F63,F7,F82 --show-source --statistics
	cd backend && flake8 kerjaflow/ --count --exit-zero --max-complexity=10 --max-line-length=100 --statistics
	cd backend && mypy kerjaflow/ --ignore-missing-imports
	@echo "✅ Linting complete"

format:
	@echo "Formatting code..."
	cd backend && black kerjaflow/
	@echo "✅ Formatting complete"

check-format:
	@echo "Checking code formatting..."
	cd backend && black --check kerjaflow/
	@echo "✅ Format check complete"

clean:
	@echo "Cleaning build artifacts..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".coverage" -delete 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@echo "✅ Cleanup complete"

all: migrate test validate
	@echo ""
	@echo "=========================================="
	@echo "✅ ALL TASKS COMPLETED SUCCESSFULLY"
	@echo "=========================================="
	@echo ""
	@echo "Summary:"
	@echo "  ✓ Database migrations applied"
	@echo "  ✓ Test suite passed"
	@echo "  ✓ Statutory rates validated"
	@echo ""
	@echo "Next steps:"
	@echo "  - Review test coverage: make coverage"
	@echo "  - Check code quality: make lint"
	@echo "  - Format code: make format"

# Quick validation for specific countries
validate-my:
	cd backend && python ../validation/statutory_rate_validator.py --country MY

validate-sg:
	cd backend && python ../validation/statutory_rate_validator.py --country SG

validate-id:
	cd backend && python ../validation/statutory_rate_validator.py --country ID

validate-th:
	cd backend && python ../validation/statutory_rate_validator.py --country TH

validate-ph:
	cd backend && python ../validation/statutory_rate_validator.py --country PH

validate-vn:
	cd backend && python ../validation/statutory_rate_validator.py --country VN

validate-kh:
	cd backend && python ../validation/statutory_rate_validator.py --country KH

validate-mm:
	cd backend && python ../validation/statutory_rate_validator.py --country MM

validate-bn:
	cd backend && python ../validation/statutory_rate_validator.py --country BN
