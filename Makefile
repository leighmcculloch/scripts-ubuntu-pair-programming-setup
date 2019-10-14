ID ?= 0
TZ ?= $(shell readlink /etc/localtime | sed -E 's/.*\/([A-Za-z_]+\/[A-Za-z_]+)/\1/g')
HOST ?= $(shell hostname | tr '[:upper:]' '[:lower:]' | sed 's/\.local$$//')
LOCAL_DIR = $(PWD)/.instance-$(ID)

start:
	rm -rf $(LOCAL_DIR)
	mkdir -p $(LOCAL_DIR)
	ssh-keygen -t ed25519 -f $(LOCAL_DIR)/id_ed25519 -N ''
	docker network create devenv || true
	docker run -d -i -t \
		--network="devenv" \
		--hostname="devenv-$(ID)" \
		-e TZ=$(TZ) \
		-e DISPLAY=docker.for.mac.localhost:0 \
		-e HOST="$(HOST)" \
		-v="$(PWD):/home/$(USER)/devel/.devenv" \
		-v="/var/run/docker.sock:/var/run/docker.sock" \
		-v="$(LOCAL_DIR)/id_ed25519.pub:/home/$(USER)/.ssh/authorized_keys" \
		--security-opt="apparmor=unconfined" \
		--cap-add=SYS_PTRACE \
		-p="222$(ID):22" \
		-p="8$(ID)00-8$(ID)08:8000-8008" \
		--name="devenv-$(ID)" \
		leighmcculloch/devenv:latest \
		|| docker start "devenv-$(ID)"
	docker ps

join:
	docker ps
	ssh -i $(LOCAL_DIR)/id_ed25519 localhost -p 222$(ID) \
		-t 'rm -f /home/$(USER)/.gnupg/S.*' || true
	ssh -i $(LOCAL_DIR)/id_ed25519 localhost -p 222$(ID) \
		-R /home/$(USER)/.gnupg/S.gpg-agent:$(HOME)/.gnupg/S.gpg-agent.extra \
		-R /home/$(USER)/.gnupg/S.gpg-agent.ssh:$(HOME)/.gnupg/S.gpg-agent.ssh \
		-t 'tmux -2 attach -t 0'
	docker ps

join-nossh:
	docker ps
	docker exec -i -t "devenv-$(ID)" tmux -2 attach -t 0 || true
	docker ps

attach:
	docker ps
	docker attach --detach-keys="ctrl-a,d" "devenv-$(ID)" || true
	docker ps

stop:
	docker stop -t 0 $$(docker ps -aq --filter 'name=devenv-$(ID)') || true

rm:
	docker rm $$(docker ps -aq --filter 'name=devenv-$(ID)') || true

build:
	docker build --build-arg USER=$(USER) -t leighmcculloch/devenv:latest .

buildnc:
	docker build --build-arg USER=$(USER) --no-cache -t leighmcculloch/devenv:latest .

pull:
	docker pull leighmcculloch/devenv:latest
