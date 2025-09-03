## Project Overview
I'm porting apache lucene from java to platform agnostic kotlin common code.
This project is the root directory of the porting project and the directory name is lp.
Under this directory you find two sub directories:

1. lucene sub directory
    This is the source code of java lucene. the commit id is fixed to ec75fcad5a4208c7b9e35e870229d9b703cda8f3 until all java classes/unit tests ported. After all ported, the project will proceed to the next phase to port commit by commit from this commit id to catch up with the latest lucene code.

2. lucene-kmp sub directory.
    This is the kotlin multiplatform ported code. 

## Porting Guideline

- The GitHub copilot never make any change to lucene java source code but only read, copy from, analyze and answer question based on its content. If it's in agent mode, it can use git commands which does not change any code but only read the code and history.

- When porting, class name, interface name, method name, variable name should be the same as much as possible especially for APIs which is used by other classes.

- root package name of java lucene is org.apache.lucene. The root package name of the kotlin common code is org.gnit.lucene-kmp. The sub package structure under the root package should be the same as much as possible.

- When porting, when the certain java class included in JDK (e.g. java.util.List, java.util.Map, java.lang.String, etc) is used in lucene java code, you should use kotlin common code equivalent class (e.g. kotlin.collections.List, kotlin.collections.Map, kotlin.String, etc) instead of the JDK class. If those equivalent class is not found in kotlin common code of kotlin standard library, this project will copy the source code of the JDK class which is missing in kotlin std lib and port it into kotlin common code in a package called org.gnit.lucene-kmp.jdkport. These jdk ported classes/interface need to have annotation called @Ported with argument called from like this: @Ported(from="java.util.List") So when porting, if you encounter compilation error saying unresolved reference to certain JDK class/interface, you should first look into the package org.gnit.lucene-kmp.jdkport to see if the ported class/interface is already there. Only when if not found, it should be ported form JDK source code. Most of the missing JDK classes are already in the package.

- The ported project is targeting following platforms:
    1. jvm (jvm server, jvm desktop, Android)
    2. native (iOS, linux)

- The linux native target is not for projection but for development in linux desktop environment. The kotlin native uses LLVM as its compiler and gradle kotlin compile job emits almost exact same compilation error for native/linux and native/iOS. So even in the linux box which does not have build toolchain for iOS, you can quickly check if the ported code compiles for iOS or not by compiling for native/linux target.

- The porting project prioritizes kotlin common code over expect/actual mechanism to reduce the amount of platform specific code. So when porting, first try to use kotlin common code only. Only when if not possible, you should use expect/actual mechanism. When using expect/actual mechanism, the platform specific code should be created in following 2 source sets: 
    1. jvmAndroidMain, jvmAndroidTest for jvm/android platform
    2. nativeMain, nativeTest for native platform (iOS, linux)

## Specific Instruction
* do not use String.toByteArray() but use String.encodeToByteArray() instead.
* because this project is kotlin common project, in common code, do not use String.format function but use kotlin string interpolation.

## Logging
* when logging, use the following code:
* import io.github.oshai.kotlinlogging.KotlinLogging
* private val logger = KotlinLogging.logger {}
* logger.debug { "message" }

## Running Unit Tests

### Priority 1, JetBrains MCP Server
When you have access to JetBrains MCP server, you should use the IDEA's internal test runner. Using the mcp, find run configuration then run test via found run configuration to compile, test, read test result and do other works needed for debugging and development.

### Priority 2, Gradle command line
When you don't have access to JetBrains MCP server, you should use the command line Gradle test runner.
