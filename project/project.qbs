import qbs

CppApplication {
    name: "project"
    consoleApplication: true

    Depends { name: 'cpp' }
    
    Properties {

        cpp.cxxLanguageVersion: "c++17"
        cpp.cxxStandardLibrary: "libc++"

        cpp.commonCompilerFlags: {
            /// INFO: Start with base warnings settings
            var flags = [
                "-Wno-error",
            ]

            const GLOBAL_FLAGS = project.GLOBAL_FLAGS;

            if (GLOBAL_FLAGS) {
                flags = flags.concat(GLOBAL_FLAGS);
            }

            return flags;
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