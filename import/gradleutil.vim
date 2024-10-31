vim9script

import "./fileutil.vim"

var gradleJdkVersionCache = {}
var classpathCache = {}

# This is an example task that can be added to the build.gradle file to write
# out each entry in the classpath to a separate line in .classpath-cache:
#
# task printRuntimeClasspath {
#     def runtimeClasspath = sourceSets.main.runtimeClasspath
#     inputs.files( runtimeClasspath )
#     doLast {
#         new File('.classpath-cache').withWriter('utf-8') { writer ->
#             writer.writeLine(runtimeClasspath.join(":"))
#         }
#     }
# }

export def FetchJdkVersion(path: string): any
    if has_key(gradleJdkVersionCache, path)
        return gradleJdkVersionCache[path]
    endif

    return v:null
enddef

export def IdentifyGradleJdkVersion(path: string): string
    if has_key(gradleJdkVersionCache, path)
        return gradleJdkVersionCache[path]
    endif

    var buildGradleText = readfile(path)
    for ln in buildGradleText
        var parts = matchlist(ln, 'JavaVersion.toVersion(.\(\d\+\).)')
        if len(parts) > 1
            gradleJdkVersionCache[path] = parts[1]
            return gradleJdkVersionCache[path]
        endif
    endfor

    return ""
enddef

def ReadClasspathFromFile(filePath: string): string
    var lines = readfile(filePath)
    return trim(join(lines, ""))
enddef

export def ClasspathDiskCacheFilePath(buildGradlePath: string): string
    return buildGradlePath .. ".classpath-cache"
enddef

export def RegenerateClasspathGradle(gradlePath: string): void
    var cpTextFilePath = ClasspathDiskCacheFilePath(gradlePath)
    var workDirPath = fnamemodify(gradlePath, ":h")
    job_start(
        ["./gradlew", "printRuntimeClasspath"],
        {
            "cwd": workDirPath,
            "stoponexit": "term",
            "exit_cb": (job: any, status: number) => {
                classpathCache[gradlePath] = ReadClasspathFromFile(cpTextFilePath)
                echomsg "Determined classpath: " .. classpathCache[gradlePath]
            }
        })
enddef

export def FetchClasspath(buildGradlePath: string): any
    if has_key(classpathCache, buildGradlePath)
        return classpathCache[buildGradlePath]
    endif

    if filereadable(ClasspathDiskCacheFilePath(buildGradlePath))
        return ReadClasspathFromFile(ClasspathDiskCacheFilePath(buildGradlePath))
    endif

    RegenerateClasspathGradle(buildGradlePath)
    return v:null
enddef

export def FindBuildGradle(path: string): string
    return fileutil.FindFileAbove("build.gradle", path)
enddef

