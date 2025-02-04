step%:
	@swift build --product $@
	[ -L .build/$@ ] || ln -s "$(shell swift build --show-bin-path)/$@" .build/$@
clean:
	@rm -fr .build/

step0:
	@make step0_repl
step1:
	@make step1_read_print
step2:
	@make step2_eval
step3:
	@make step3_env
step4:
	@make step4_if_fn_do
step5:
	@make step5_tco
step6:
	@make step6_file
step7:
	@make step7_quote
step8:
	@make step8_macros
step9:
	@make step9_try
stepA:
	@make stepA_mal
