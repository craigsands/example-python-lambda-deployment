LOG_LEVEL := WARNING
VENV := venv
PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip
PACKAGE_NAME := example

all: venv

build:
	$(PYTHON) -m build
	mkdir -p package
	pip install --upgrade --only-binary :all: --platform manylinux2014_x86_64 --target package dist/*.whl
	{ cd package; zip -r -q ../dist/my-lambda.zip * -x '*.pyc'; cd ../; }
	rm -rf package

clean:
	rm -rf __pycache__ .pytest_cache dist $(VENV)
	rm -f .coverage coverage.xml
	find . -type f -name '*.pyc' -delete

ci:
	$(PYTHON) -m pytest --junitxml=report.xml

coverage:
	$(PYTHON) -m pytest --cov-report term-missing --cov-report xml --cov=src/$(PACKAGE_NAME) --log-cli-level=$(LOG_LEVEL) -s

fmt:
	$(PYTHON) -m black .
	$(PYTHON) -m isort .

lint:
	$(PYTHON) -m flake8 src/$(PACKAGE_NAME)

$(VENV)/bin/activate: pyproject.toml requirements-dev.txt
	python3 -m venv $(VENV)
	$(PIP) install -r requirements-dev.txt

venv: $(VENV)/bin/activate

.PHONY: all build clean ci coverage fmt lint venv
