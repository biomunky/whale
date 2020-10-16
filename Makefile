base_dir:=~/.whale
build_dir:=./build
install_dir:=${base_dir}/bin
dependency_binary_dir:=${base_dir}/libexec
python_directory:=databuilder
python3_alias:=python3
wheel_dir:=${build_dir}/wheel_tmp


.PHONY: all
all: python
	cargo build --release --manifest-path cli/Cargo.toml

.PHONY: python
python:
	mkdir -p ${build_dir}
	${python3_alias} -m venv ${build_dir}/env
	. ${build_dir}/env/bin/activate && pip3 install -r ${python_directory}/requirements.txt
	pip3 wheel ${python_directory}/. --wheel-dir=${wheel_dir}
	pip3 install whalebuilder --no-index --find-links=${wheel_dir}
	cp ${python_directory}/build_script.py ${build_dir}

.PHONY: install
install:
	mkdir -p ${install_dir}
	mkdir -p ${dependency_binary_dir}
	cp ./cli/target/release/whale ${install_dir}
	cp -r ${build_dir}/* ${dependency_binary_dir}

.PHONY: test_python
test_python:
	${python3_alias} -b -m pytest ${python_directory}/tests
	pytest --cov=whalebuilder --cov-report=xml ${python_directory}/tests/
	flake8 ${python_directory}/whalebuilder/. --exit-zero

.PHONY: test
test: test_python
