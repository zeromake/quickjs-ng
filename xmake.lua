add_rules("mode.debug", "mode.release")

set_languages("c11")
set_encodings("utf-8")
includes("rules/embed-js.lua")

add_repositories("zeromake https://github.com/zeromake/xrepo.git")
add_requires("zeromake.rules")

if is_plat("windows", "mingw") then
    add_cflags("/TC", {tools = {"clang_cl", "cl"}})
    add_cflags("/experimental:c11atomics", {tools = {"clang_cl", "cl"}, force = true})
    add_cxxflags("/EHsc", {tools = {"clang_cl", "cl"}})
    add_defines(
        "UNICODE",
        "_UNICODE",
        "WIN32_LEAN_AND_MEAN",
        "_WIN32_WINNT=0x0602",
        "_CRT_SECURE_NO_WARNINGS"
    )
end

add_defines(
    "_GNU_SOURCE"
)

target("quickjs")
    set_kind("shared")
    add_files(
        "cutils.c",
        "libbf.c",
        "libregexp.c",
        "libunicode.c",
        "quickjs.c"
    )
    add_packages("zeromake.rules")
    add_headerfiles("quickjs.h", {prefixdir = "quickjs"})
    add_files("quickjs-libc.c")
    add_rules("@zeromake.rules/export_symbol", {file = 'quickjs.sym'})

target("qjsc")
    add_files(
        "cutils.c",
        "libbf.c",
        "libregexp.c",
        "libunicode.c",
        "quickjs.c",
        "quickjs-libc.c",
        "qjsc.c"
    )
    if is_plat("windows", "mingw") then
        add_files("resource.rc")
    end

target("qjs")
    add_rules("embed-js")
    add_files("qjs.c", "repl.js")
    add_deps("quickjs")
    if is_plat("windows", "mingw") then
        add_files("resource.rc")
    end


target("fib")
    set_default(false)
    set_kind("shared")
    add_deps("quickjs")
    set_prefixname("")
    set_extension(".so")
    add_packages("zeromake.rules")
    add_rules("@zeromake.rules/export_symbol", {export = {"js_init_module"}})
    add_files(
        "examples/fib.c"
    )
    add_defines(
        "JS_SHARED_LIBRARY=1"
    )
