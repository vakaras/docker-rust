SHELL := /bin/bash
IMAGE_VERSION=0.0.1
IMAGE_NAME="vakaras/rust:${IMAGE_VERSION}"

run_container: workspace
	sudo docker run --rm -ti \
		-v "$(shell pwd)/workspace:/data" \
		"${IMAGE_NAME}" /usr/bin/fish

run_jupyter: workspace nbworkspace
	sudo docker run --rm -ti \
		-v "$(shell pwd)/workspace:/data" \
		-v "$(shell pwd)/nbworkspace:/home/jovyan/work" \
		--user root \
		-e GEN_CERT=yes \
		-e NB_UID=1007 \
		-p 23123:8888 jupyter/datascience-notebook

workspace/.config/fish/config.fish: | workspace
	mkdir -p workspace/.config/fish
	echo 'set -x JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8' > workspace/.config/fish/config.fish
	echo 'set -x LANG en_US.UTF-8' >> workspace/.config/fish/config.fish
	echo 'set -x LANGUAGE en_US:en' >> workspace/.config/fish/config.fish
	echo 'set -x LC_ALL en_US.UTF-8' >> workspace/.config/fish/config.fish
	echo 'set -x Z3_EXE /usr/bin/z3' >> workspace/.config/fish/config.fish
	echo 'set -x BOOGIE_EXE /usr/bin/boogie' >> workspace/.config/fish/config.fish

workspace:
	mkdir -p workspace

nbworkspace:
	mkdir -p nbworkspace

workspace_root:
	mkdir -p workspace_root

build_image:
	sudo docker build -t "${IMAGE_NAME}" .

clean: clean-workspace
	rm -rf .cache

clean-workspace:
	rm -rf \
		workspace \
		workspace_root
