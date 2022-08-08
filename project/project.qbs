import qbs
import qbs.File

CppApplication {
    name: "project"
    consoleApplication: true

    property bool isCcacheEnabled : File.exists("/usr/local/bin/ccache")

    // This is solution for ccache's problem with newly genereated 'gch' files. 
    property bool useWorkaround: false

    Depends { name: 'cpp' }
    
    Properties {

        cpp.cxxLanguageVersion: "c++17"
        cpp.cxxStandardLibrary: "libc++"

        cpp.compilerWrapper: isCcacheEnabled ? ["ccache"] : original
        cpp.useCxxPrecompiledHeader : useWorkaround ? false : original
        cpp.prefixHeaders : useWorkaround ? ["precompile.pch.h"] : original

        cpp.commonCompilerFlags: {
            var flags = [
                "-Wno-error",
            ]
            const GLOBAL_FLAGS = project.GLOBAL_FLAGS;

            if (GLOBAL_FLAGS) {
                flags = flags.concat(GLOBAL_FLAGS);
            }

            return flags;useWorkaround
        }

        cpp.separateDebugInformation: false
    }

    cpp.includePaths: [
        "include",
    ]

    Group {
        name: "PCH"
        files: "precompile.pch.h"
        fileTags: ["cpp_pch_src"]
    }

    files: [
        "source/*.cpp",
        "include/*.hpp",
    ]
}