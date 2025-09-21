.PHONY: setup db agent dashboard collector
setup:
	git submodule update --init --recursive
	npm i -g pnpm
	pnpm -w install
	python -m pip install -r dashboard/requirements.txt
	python scripts/init_db.py
db:
	python scripts/init_db.py
agent:
	cd agent && node server.js
dashboard:
	cd dashboard && python app.py
collector:
	cd collector && node src/collector.js
