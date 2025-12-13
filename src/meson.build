avi_studio_sources = [
    'api/api.c',
    'api/dirmonitor.c',
    'api/renderer.c',
    'api/renwindow.c',
    'api/regex.c',
    'api/system.c',
    'api/process.c',
    'api/channel.c',
    'api/thread.c',
    'api/shmem.c',
    'api/canvas.c',
    'api/utf8.c',
    'api/encoding.c',
    'api/diff.c',
    'api/utils/lxlauxlib.c',
    'arena_allocator.c',
    'custom_events.c',
    'renderer.c',
    'renwindow.c',
    'rencache.c',
    'main.c',
]

if lua_jit_found
    avi_studio_sources += 'ffiexports.c'
    # Export all local symbols for LuaJIT FFI Access
    if host_machine.system() != 'windows' and host_machine.system() != 'darwin'
        # reminder: on mingw the valid flag is -Wl,--export-all-symbols
        avi_studio_link_args += '-Wl,--export-dynamic'
    elif host_machine.system() == 'darwin'
        # macOS export dynamic symbols option slightly different
        avi_studio_link_args += '-Wl,-export_dynamic'
    endif
endif

dirmonitor_backends = get_option('dirmonitor_backends')

if dirmonitor_backends.length() == 0
    if cc.has_function('inotify_init', prefix : '#include<sys/inotify.h>')
        dirmonitor_backends += 'inotify'
    endif

    if host_machine.system() == 'darwin' and cc.check_header('CoreServices/CoreServices.h')
        dirmonitor_backends += 'fsevents'
    endif

    if cc.has_function('kqueue', prefix : '#include<sys/event.h>')
        dirmonitor_backends += 'kqueue'
    endif

    if cc.has_function('create_inode_watcher', prefix : '#include<fcntl.h>')
        dirmonitor_backends += 'inodewatcher'
    endif

    if dependency('libkqueue', required : false).found()
        dirmonitor_backends += 'kqueue'
    endif

    if host_machine.system() == 'windows'
        dirmonitor_backends += 'win32'
    endif

    dirmonitor_backends += 'dummy'
endif

foreach backend : dirmonitor_backends
    if backend == 'inotify'
        avi_studio_sources += 'api' / 'dirmonitor' / 'inotify.c'
        avi_studio_cargs += '-DDIRMONITOR_INOTIFY'
    elif backend == 'fsevents'
        avi_studio_sources += 'api' / 'dirmonitor' / 'fsevents.c'
        avi_studio_cargs += '-DDIRMONITOR_FSEVENTS'
    elif backend == 'kqueue'
        avi_studio_sources += 'api' / 'dirmonitor' / 'kqueue.c'
        libkqueue_dep = dependency('libkqueue', required : false)
        if libkqueue_dep.found()
            avi_studio_deps += libkqueue_dep
        endif
        avi_studio_cargs += '-DDIRMONITOR_KQUEUE'
    elif backend == 'inodewatcher'
        add_languages('cpp')
        avi_studio_sources += 'api' / 'dirmonitor' / 'inodewatcher.cpp'
        avi_studio_cargs += '-DDIRMONITOR_INODEWATCHER'
    elif backend == 'win32'
        avi_studio_sources += 'api' / 'dirmonitor' / 'win32.c'
        avi_studio_cargs += '-DDIRMONITOR_WIN32'
    elif backend == 'dummy'
        avi_studio_sources += 'api' / 'dirmonitor' / 'dummy.c'
        avi_studio_cargs += '-DDIRMONITOR_DUMMY'
    else
        error('Unknown dirmonitor backend @0@'.format(backend))
    endif
endforeach

summary('dirmonitor backends', dirmonitor_backends)

# luajit compatibility files
if lua_compat_needed
    avi_studio_sources += [
        'compat/liolib.c',
        'compat/lstrlib.c',
        'compat/ltablib.c',
        'compat/lutf8lib.c'
    ]

    if not lua_jit_found
        avi_studio_sources += 'compat/ljbitlib.c'
    endif
endif

message('lua-compat-5.3 needed: @0@'.format(lua_compat_needed))

avi_studio_rc = []
if host_machine.system() == 'windows'
    windows = import('windows')
    avi_studio_rc += windows.compile_resources('../resources/icons/icon.rc')
    avi_studio_rc += windows.compile_resources('../resources/windows/manifest.rc')

    # solve missing symbols when building from sdl3 cmake subproject
    if sdl_dep.type_name() == 'internal'
        avi_studio_deps += cc.find_library('winmm', required : true)
        avi_studio_deps += cc.find_library('imm32', required: true)
        avi_studio_deps += cc.find_library('setupapi', required: true)
        avi_studio_deps += cc.find_library('version', required: true)
    endif
elif host_machine.system() == 'darwin'
    avi_studio_sources += 'bundle_open.m'

    # solve missing symbols when building from sdl3 cmake subproject
    if sdl_dep.type_name() == 'internal'
        avi_studio_link_args += [
            '-framework', 'Carbon',
            '-framework', 'CoreFoundation',
            '-framework', 'Metal',
            '-framework', 'AppKit',
            '-framework', 'CoreVideo',
            '-framework', 'IOKit',
            '-framework', 'UniformTypeIdentifiers'
        ]
    endif
endif

avi_studio_includes += include_directories('.')

# load and configure linenoise
if get_option('repl_history')
    if lua_jit_found
        linenoise_jit = 'jit=true'
    else
        linenoise_jit = 'jit=false'
    endif
    avi_studio_deps += subproject('linenoise',
        default_options: default_fallback_options + [
            'default_library=static', linenoise_jit
        ]
    ).get_variable('linenoise_dep')
    avi_studio_cargs += '-DAVI_STUDIO_REPL_HISTORY'
endif

executable('avi-studio',
    avi_studio_sources + avi_studio_rc,
    include_directories: avi_studio_includes,
    dependencies: avi_studio_deps,
    c_args: avi_studio_cargs,
    objc_args: avi_studio_cargs,
    link_args: avi_studio_link_args,
    install_dir: avi_studio_bindir,
    install: true,
    win_subsystem: 'windows',
)

if host_machine.system() == 'windows'
    executable('avi-studio',
        avi_studio_sources + avi_studio_rc,
        include_directories: avi_studio_includes,
        dependencies: avi_studio_deps,
        c_args: avi_studio_cargs,
        objc_args: avi_studio_cargs,
        link_args: avi_studio_link_args,
        name_suffix: 'com',
        install_dir: avi_studio_bindir,
        install: true,
        win_subsystem: 'console',
    )
endif
