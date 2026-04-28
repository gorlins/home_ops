schematics/%.json: schematics/%.yaml
	curl -X POST --data-binary @$^ https://factory.talos.dev/schematics > $@

scripts/rook/import-external-cluster.sh:
	wget -O $@ https://raw.githubusercontent.com/rook/rook/refs/tags/v1.19.4/deploy/examples/import-external-cluster.sh
