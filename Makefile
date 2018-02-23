.PHONY: new server-update server-updatebuild maps build buildasan config updateconfig initdb updatedb givegm updates

new: build config initdb

server-update: updateconfig updatedb

server-updatebuild: build updateconfig updatedb

maps:
	cd ../tools/hercules/ ; ./tmx_converter.py ../../client-data/ ../../server-data ; ./convert_tmx_to_mapcache.py

build:
	cd ../tools/localserver/ ; ./build.sh

buildasan:
	cd ../tools/localserver/ ; ./buildasan.sh

config:
	cd ../tools/localserver/ ; ./installconfigs.sh

updateconfig:
	cd ../tools/localserver/ ; ./updateconfigs.sh

initdb:
	cd ../tools/localserver/ ; ./initdb.sh

updatedb:
	cd ../tools/localserver/ ; ./updatedb.sh

givegm:
	cd ../tools/localserver/ ; ./givegm.sh ${ID}

updates:
	cd ../tools/update/ ; ./createnew.sh ; ./create_music.sh
