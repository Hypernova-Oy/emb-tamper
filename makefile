programName=emb-tamper
confDir=etc/$(programName)
systemdServiceDir=etc/systemd/system
systemPath=/usr/local/bin
logPath=/var/log/$(programName)


#Macro to check the exit code of a make expression and possibly not fail on warnings
RC      := test $$? -lt 100 


build: compile

restart: serviceEnable

install: build configure perlDeploy scriptsLink serviceEnable

perlDeploy:
	./Build installdeps
	./Build install

compile:
	#Build Perl modules
	perl Build.PL
	./Build

test:
	prove -Ilib -I. t/*.t

configure:
	mkdir -p /$(confDir)
	cp --backup=numbered $(confDir)/daemon.conf /$(confDir)/daemon.conf
	cp --backup=numbered $(confDir)/log4perl.conf /$(confDir)/log4perl.conf

	cp $(systemdServiceDir)/$(programName).service /$(systemdServiceDir)/$(programName).service

	mkdir -p $(logPath)
	chown -R toveri:toveri $(logPath)

unconfigure:
	rm -r /$(confDir) || $(RC)
	rm -r $(logPath) || $(RC)

serviceEnable:
	systemctl daemon-reload
	systemctl enable $(programName)
	systemctl restart $(programName)

serviceDisable:
	systemctl stop $(programName)
	rm /$(systemdServiceDir)/$(programName).service
	systemctl daemon-reload

scriptsLink:
	cp scripts/tamper $(systemPath)/

scriptsUnlink:
	rm $(systemPath)/tamper

clean:
	./Build realclean

uninstall: serviceDisable unconfigure scriptsUnlink clean

