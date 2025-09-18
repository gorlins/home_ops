schematics/%.json: schematics/%.yaml
	curl -X POST --data-binary @$^ https://factory.talos.dev/schematics > $@
