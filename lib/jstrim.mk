JSTRIM=${HOME}/tinymce/JSTrim_mono.exe

%.js: %_src.js
	$(JSTRIM) $< $@
