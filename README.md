This reproduces a crash involving XDebug and the DDTrace extension.

To reproduce:
* Run `docker build -t xdebug-segfault .`
* Run `docker run --rm xdebug-segfault` and notice that the exit code is 139, which indicates a segmentation fault.

Note that the crash only happens the first time the command is run. To make it happen again, either create a new Docker container based on the same image, or remove the `var` directory to clear the Symfony cache.

The Docker image includes gdb, so it's possible to debug:

```
$ docker run -it --rm xdebug-segfault /bin/bash
# Inside Docker container
$ gdb --args php src/entry
(gdb) run
...
Thread 1 "php" received signal SIGSEGV, Segmentation fault.
```

The output of `bt full` is:

```
#0  0x0000fffff3f6b0fc in zval_from_stack_add_frame_variables (opa=0xfffff4063300, symbols=<optimized out>, edata=0x0, frame=0xfffff203a660)
    at /tmp/pear/temp/xdebug/src/develop/stack.c:431
        symbol_name = <optimized out>
        symbol = {value = {lval = 281474976689216, dval = 1.3906711614610732e-309, counted = 0xffffffffac40, str = 0xffffffffac40, arr = 0xffffffffac40,
            obj = 0xffffffffac40, res = 0xffffffffac40, ref = 0xffffffffac40, ast = 0xffffffffac40, zv = 0xffffffffac40, ptr = 0xffffffffac40, ce = 0xffffffffac40,
            func = 0xffffffffac40, ww = {w1 = 4294945856, w2 = 65535}}, u1 = {type_info = 4093031544, v = {type = 120 'x', type_flags = 180 '\264', u = {
                extra = 62454}}}, u2 = {next = 65535, cache_slot = 65535, opline_num = 65535, lineno = 65535, num_args = 65535, fe_pos = 65535, fe_iter_idx = 65535,
            guard = 65535, constant_flags = 65535, extra = 65535}}
        j = 0
        variables = {value = {lval = 281474754886552, dval = 1.3906700656103088e-309, counted = 0xfffff2c73b98, str = 0xfffff2c73b98, arr = 0xfffff2c73b98,
            obj = 0xfffff2c73b98, res = 0xfffff2c73b98, ref = 0xfffff2c73b98, ast = 0xfffff2c73b98, zv = 0xfffff2c73b98, ptr = 0xfffff2c73b98, ce = 0xfffff2c73b98,
            func = 0xfffff2c73b98, ww = {w1 = 4073143192, w2 = 65535}}, u1 = {type_info = 775, v = {type = 7 '\a', type_flags = 3 '\003', u = {extra = 0}}}, u2 = {
            next = 43690, cache_slot = 43690, opline_num = 43690, lineno = 43690, num_args = 43690, fe_pos = 43690, fe_iter_idx = 43690, guard = 43690,
            constant_flags = 43690, extra = 43690}}
#1  zval_from_stack_add_frame (output=0xfffff3fa2378 <xdebug_globals+1048>, fse=0xaaaaabe2e6a0, edata=0x0, add_local_vars=true, params_as_values=<optimized out>)
    at /tmp/pear/temp/xdebug/src/develop/stack.c:467
        frame = 0xfffff203a660
#2  0x0000fffff3f6b4cc in zval_from_stack (output=output@entry=0xfffff3fa2378 <xdebug_globals+1048>, add_local_vars=add_local_vars@entry=true,
    params_as_values=params_as_values@entry=true) at /tmp/pear/temp/xdebug/src/develop/stack.c:495
        fse = 0xaaaaabe2e6a0
        next_fse = 0xaaaaabe2e790
        i = 1
#3  0x0000fffff3f6d6cc in xdebug_develop_throw_exception_hook (exception=exception@entry=0xfffff2064820, file=file@entry=0xfffff2064878, line=line@entry=0xfffff2064888,
    code=code@entry=0xfffff2064868, code_str=code_str@entry=0x0, message=message@entry=0xfffff2064848) at /tmp/pear/temp/xdebug/src/develop/stack.c:1252
        exception_ce = 0xaaaaabcf16e0
        exception_trace = <optimized out>
        tmp_str = {l = 9019, a = 9572,
          d = 0xaaaaabe2b2e0 "\nReflectionException: Function include() does not exist in /root/vendor/symfony/var-dumper/Caster/ExceptionCaster.php on line 342\n\nCall Stack:\n    0.0078    2916064   1. {main}() /root/src/entry:0\n   "...}
        z_previous_exception = 0xaaaaabadff00 <executor_globals>
        z_last_exception_slot = <optimized out>
        z_previous_trace = <optimized out>
        previous_exception_obj = <optimized out>
        dummy = {value = {lval = 281474976689520, dval = 1.3906711614625751e-309, counted = 0xffffffffad70, str = 0xffffffffad70, arr = 0xffffffffad70,
            obj = 0xffffffffad70, res = 0xffffffffad70, ref = 0xffffffffad70, ast = 0xffffffffad70, zv = 0xffffffffad70, ptr = 0xffffffffad70, ce = 0xffffffffad70,
            func = 0xffffffffad70, ww = {w1 = 4294946160, w2 = 65535}}, u1 = {type_info = 4092876996, v = {type = 196 '\304', type_flags = 88 'X', u = {extra = 62452}}},
          u2 = {next = 65535, cache_slot = 65535, opline_num = 65535, lineno = 65535, num_args = 65535, fe_pos = 65535, fe_iter_idx = 65535, guard = 65535,
            constant_flags = 65535, extra = 65535}}
#4  0x0000fffff3f4597c in xdebug_throw_exception_hook (exception=0xfffff2064820) at /tmp/pear/temp/xdebug/src/base/base.c:1580
        code = 0xfffff2064868
        message = 0xfffff2064848
        file = 0xfffff2064878
        line = 0xfffff2064888
        exception_ce = <optimized out>
        code_str = 0x0
        dummy = {value = {lval = 281474976689648, dval = 1.3906711614632076e-309, counted = 0xffffffffadf0, str = 0xffffffffadf0, arr = 0xffffffffadf0,
            obj = 0xffffffffadf0, res = 0xffffffffadf0, ref = 0xffffffffadf0, ast = 0xffffffffadf0, zv = 0xffffffffadf0, ptr = 0xffffffffadf0, ce = 0xffffffffadf0,
            func = 0xffffffffadf0, ww = {w1 = 4294946288, w2 = 65535}}, u1 = {type_info = 3559593728, v = {type = 0 '\000', type_flags = 23 '\027', u = {
                extra = 54315}}}, u2 = {next = 4286588792, cache_slot = 4286588792, opline_num = 4286588792, lineno = 4286588792, num_args = 4286588792,
            fe_pos = 4286588792, fe_iter_idx = 4286588792, guard = 4286588792, constant_flags = 4286588792, extra = 4286588792}}
#5  xdebug_throw_exception_hook (exception=0xfffff2064820) at /tmp/pear/temp/xdebug/src/base/base.c:1532
        code = <optimized out>
        message = <optimized out>
        file = <optimized out>
        line = <optimized out>
        exception_ce = <optimized out>
        code_str = 0x0
        dummy = <optimized out>
#6  0x0000aaaaaabe0e98 in zend_throw_exception_internal ()
No symbol table info available.
#7  0x0000aaaaaabe0fc0 in ?? ()
No symbol table info available.
#8  0x0000aaaaaabe106c in zend_throw_exception ()
No symbol table info available.
#9  0x0000aaaaaabe1170 in zend_throw_exception_ex ()
No symbol table info available.
#10 0x0000aaaaaada0444 in ?? ()
No symbol table info available.
#11 0x0000aaaaaabdeb94 in ?? ()
No symbol table info available.
#12 0x0000aaaaaaf92e84 in execute_ex ()
No symbol table info available.
#13 0x0000aaaaaabdeaf8 in ?? ()
No symbol table info available.
#14 0x0000aaaaaaf92e84 in execute_ex ()
No symbol table info available.
#15 0x0000aaaaaabdeaf8 in ?? ()
No symbol table info available.
#16 0x0000aaaaaaf92e84 in execute_ex ()
No symbol table info available.
#17 0x0000aaaaaabdeaf8 in ?? ()
No symbol table info available.
#18 0x0000aaaaaaf92e84 in execute_ex ()
No symbol table info available.
#19 0x0000aaaaaabdeaf8 in ?? ()
No symbol table info available.
#20 0x0000aaaaaaf92e84 in execute_ex ()
No symbol table info available.
#21 0x0000aaaaaabdeaf8 in ?? ()
No symbol table info available.
#22 0x0000aaaaaaf92e84 in execute_ex ()
No symbol table info available.
#23 0x0000aaaaaabdeaf8 in ?? ()
No symbol table info available.
#24 0x0000aaaaaaf92e84 in execute_ex ()
No symbol table info available.
#25 0x0000aaaaaabdeaf8 in ?? ()
No symbol table info available.
#26 0x0000aaaaaaf92e84 in execute_ex ()
No symbol table info available.
#27 0x0000aaaaaabdeaf8 in ?? ()
No symbol table info available.
#28 0x0000aaaaaaf92e84 in execute_ex ()
No symbol table info available.
#29 0x0000aaaaaaefdf18 in zend_call_function ()
No symbol table info available.
#30 0x0000aaaaaaefe340 in _call_user_function_impl ()
No symbol table info available.
#31 0x0000fffff3af4268 in zim_DDTrace_ExceptionOrErrorHandler_execute (execute_data=0x308, return_value=0xfffff2216be0)
    at /home/circleci/datadog/tmp/build_extension/ext/handlers_exception.c:317
        params = {{value = {lval = 281474744019936, dval = 1.3906700119220923e-309, counted = 0xfffff2216be0, str = 0xfffff2216be0, arr = 0xfffff2216be0,
              obj = 0xfffff2216be0, res = 0xfffff2216be0, ref = 0xfffff2216be0, ast = 0xfffff2216be0, zv = 0xfffff2216be0, ptr = 0xfffff2216be0, ce = 0xfffff2216be0,
              func = 0xfffff2216be0, ww = {w1 = 4062276576, w2 = 65535}}, u1 = {type_info = 776, v = {type = 8 '\b', type_flags = 3 '\003', u = {extra = 0}}}, u2 = {
              next = 0, cache_slot = 0, opline_num = 0, lineno = 0, num_args = 0, fe_pos = 0, fe_iter_idx = 0, guard = 0, constant_flags = 0, extra = 0}}}
        __orig_bailout = 0xbd0
        __bailout = {{__jmpbuf = {281474744319208, 1, 0, 0, 281474976693688, 281474976693784, 187650001469184, 0, 0, 281474976693944, 281474976692512,
              11600046097445617978, 187649989111968, 11600046097375427078, 0, 0, 0, 0, 0, 0, 0, 0}, __mask_was_saved = 0, __saved_mask = {__val = {281474976693472,
                281474774622540, 187650004508256, 187650004936592, 0, 281474775004664, 281474976693536, 187649989008980, 187650001492804, 281474774366576,
                281474976693536, 187649989008948, 281474976693792, 281474744019936, 281474976693912, 281474976693928}}}}
        root_span = 0xfffff40ae000
        exception = 0xfffff2216be0
        span_exception = 0xfffff40ae0d8
        old_exception = {value = {lval = 3024, dval = 1.4940545130239295e-320, counted = 0xbd0, str = 0xbd0, arr = 0xbd0, obj = 0xbd0, res = 0xbd0, ref = 0xbd0,
            ast = 0xbd0, zv = 0xbd0, ptr = 0xbd0, ce = 0xbd0, func = 0xbd0, ww = {w1 = 3024, w2 = 0}}, u1 = {type_info = 1, v = {type = 1 '\001', type_flags = 0 '\000',
              u = {extra = 0}}}, u2 = {next = 0, cache_slot = 0, opline_num = 0, lineno = 0, num_args = 0, fe_pos = 0, fe_iter_idx = 0, guard = 0, constant_flags = 0,
            extra = 0}}
        has_bailout = false
        is_error_handler = <optimized out>
        handler = 0x1
#32 0x0000aaaaaaefdc48 in zend_call_function ()
No symbol table info available.
#33 0x0000aaaaaaefe340 in _call_user_function_impl ()
No symbol table info available.
#34 0x0000aaaaaabd1470 in zend_user_exception_handler ()
No symbol table info available.
#35 0x0000aaaaaaf0e310 in zend_execute_scripts ()
No symbol table info available.
#36 0x0000aaaaaaea0a40 in php_execute_script ()
No symbol table info available.
#37 0x0000aaaaab008070 in ?? ()
No symbol table info available.
#38 0x0000aaaaaabe8e50 in ?? ()
No symbol table info available.
#39 0x0000fffff72c7780 in __libc_start_call_main (main=main@entry=0xaaaaaabe8b80, argc=argc@entry=2, argv=argv@entry=0xfffffffffa28)
    at ../sysdeps/nptl/libc_start_call_main.h:58
        self = <optimized out>
        result = <optimized out>
        unwind_buf = {cancel_jmp_buf = {{jmp_buf = {281474976709160, 2, 187650000656552, 187649985776512, 281474976709184, 281474842483600, 0, 281474842484776,
                187650000656552, 0, 281474976708784, 11600046097520931942, 18410758676599740160, 11600046097375411094, 0, 0, 0, 0, 0, 0, 0, 0}, mask_was_saved = 0}},
          priv = {pad = {0x0, 0x0, 0xfffff7ffdb90 <_rtld_global_ro>, 0xfffff7440080 <_dl_audit_preinit@got.plt>}, data = {prev = 0x0, cleanup = 0x0,
              canceltype = -134227056}}}
        not_first_call = <optimized out>
#40 0x0000fffff72c7858 in __libc_start_main_impl (main=0xaaaaaabe8b80, argc=2, argv=0xfffffffffa28, init=<optimized out>, fini=<optimized out>,
    rtld_fini=<optimized out>, stack_end=<optimized out>) at ../csu/libc-start.c:360
No locals.
#41 0x0000aaaaaabe8f30 in _start ()
No symbol table info available.
```
